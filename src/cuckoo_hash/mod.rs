use std::collections::hash_map::DefaultHasher;
use std::hash::Hash;
use std::hash::Hasher;
use std::collections::HashMap;

// for bins structure, first level of vectors represent different datapaths
// for each datapath, we have a vector of hashmaps

//#[derive(Iterator)]
#[derive(Debug)]
pub struct CuckooHash<K: std::fmt::Debug + std::hash::Hash + std::cmp::PartialEq + std::clone::Clone, T: std::clone::Clone + std::cmp::PartialEq> {
    //#[into_iterator(owned, ref,  ref_mut)]
    stash: Vec<Vec<(K,T)>>,
    bins: Vec<Vec<HashMap<usize,Vec<(K,T)>>>>,
    bins_count: usize,
    tables_count: usize,
    slot_count: usize,
    stash_size: usize,
    datapath_count: usize,
    insertion_loop_limit: usize,
    failure: bool,
    recirculation_counter: usize,
}

impl <K: std::fmt::Debug + std::hash::Hash + std::cmp::PartialEq + std::clone::Clone,T: std::fmt::Debug + std::clone::Clone+ std::cmp::PartialEq> CuckooHash<K,T> {
    pub fn iter(&self) -> impl Iterator<Item=&(K,T)> {
        self.bins.iter()
        .flatten()
        .flatten()
        .map(|x| {x.1})
        .flatten()
        .chain(
            self.stash.iter()
            .flatten()
        )
    }
    
    pub fn build_cuckoo_hash(bins_count: usize, tables_count: usize, slot_count: usize, stash_size: usize, datapath_count: usize, insertion_loop_limit: usize) -> CuckooHash<K,T> {
        CuckooHash {
            bins: vec![ vec![HashMap::with_capacity(bins_count); tables_count]; datapath_count], 
            stash: vec![ vec! [ ]; datapath_count ],
            bins_count: bins_count,
            tables_count: tables_count,
            slot_count: slot_count,
            stash_size: stash_size,
            datapath_count: datapath_count,
            insertion_loop_limit,
            failure: false,
            recirculation_counter: 0,
        }
    }


    pub fn get_recirculation_loops(&self) -> usize {
        self.recirculation_counter
    }
    
    pub fn clear_recirculation_loops(&mut self) {
        self.recirculation_counter=0;
    }

    pub fn debug_print(&self) {
        for i in 0..self.datapath_count {
            println!("Datapath {}", i);
            for j in 0..self.tables_count {
                println!("table {} value count {}", j, self.bins[i][j].len());
            }
        }
        for i in 0..self.stash.len() {
            println!("Stash {} len {}", i , self.stash[i].len());
        }
        println!("Total loops: {}", self.recirculation_counter);
    }

    /// Insert a new key-value pair
    pub fn insert(&mut self, key: K, value: T) -> bool {
        let mut inserted = false;
        //we already failed the previous insertion
        if self.failure {
            return false;
        }
        if let Some(_) = self.get_key_value(key.clone()) {
            //already inserted 
            //println!("hit");
            inserted = true;
        }
        if !inserted {
            // select datapath 
            let datapath = self.select_datapath(key.clone());
            // get datapath tables 
            let tables = &mut self.bins[datapath];
            // get datapath stash 
            let stash = &mut self.stash[datapath];
            // try inserting into tables 
            for i in 0..self.tables_count {
                let mut hash = DefaultHasher::default();
                // hash keyed by datapath
                datapath.hash(&mut hash);
                // hash keyed by table index 
                i.hash(&mut hash);
                // hash key
                key.clone().hash(&mut hash);
                // index modulo table length
                let index = (hash.finish() as usize) % self.bins_count;
                //println!("datapath {} table {} index {}", datapath, i, index);
                // using index as hash table key -> one (key,value) per position
                if tables[i].get_key_value(&index) == None {
                    tables[i].insert(index,vec![(key.clone(),value.clone())]);
                    inserted = true;
                    //println!("inserted into datapath {} table {} index {}", datapath, i, index);
                    break
                } else if let Some(v) = tables[i].get_mut(&index) {
                    if v.len() < self.slot_count {
                        v.push((key.clone(),value.clone()));
                        inserted = true;
                        //println!("inserted into datapath {} table {} index {}", datapath, i, index);
                        break;
                    }
                }
            }
            // try inserting into stash in case of table insertion failure
            if stash.len() < self.stash_size && !inserted {
                stash.push((key,value));
                //println!("inserted into datapath {} stash key {}", datapath, key);
                inserted = true;
            }
        }
        if inserted {
            self.recirculate();
        } else {
            //self.debug_print();
            self.failure = true;
        }
        return inserted;
    }

    fn recirculate_condition(&self) -> bool {
        let all_stash_half_full = self.stash.iter().map(|v| { v.len() > (self.stash_size/2)}).reduce(|acc, v| { acc && v }).unwrap();
        let all_stash_threequarter_full = self.stash.iter().map(|v| { v.len() > ((self.stash_size*3)/4)}).reduce(|acc, v| { acc && v }).unwrap();
        let all_stash_onequarter_full = self.stash.iter().map(|v| { v.len() > (self.stash_size/4)}).reduce(|acc, v| { acc && v }).unwrap();
        let one_stash_onequarter_full = self.stash.iter().map(|v| { v.len() > (self.stash_size/4)}).reduce(|acc, v| { acc || v }).unwrap();
        let one_stash_almost_full = self.stash.iter().map(|v| { v.len() == (self.stash_size - 1)}).reduce(|acc, v| { acc || v }).unwrap();
        return all_stash_half_full || one_stash_almost_full;
        //return all_stash_threequarter_full || one_stash_almost_full;
        //return all_stash_onequarter_full || one_stash_almost_full;
        //return one_stash_onequarter_full || one_stash_almost_full;
    }

    fn recirculate(&mut self) {
        //println!("into recirculation");
        let mut recirculation_counter = 0;
        let mut insert_into_stash = true;
        //while self.recirculate_condition() && recirculation_counter < self.insertion_loop_limit {
        while self.recirculate_condition() {
            // sure that each stash contains at least one element 
            recirculation_counter += 1;
            for d in 0..self.datapath_count {
                insert_into_stash = true;
                if self.stash[d].len() == 0 {
                    continue;
                }
                // pop key-value from the stash
                let mut key_value = self.stash[d].remove(0);
                for i in 0..self.tables_count { 
                    let mut hash = DefaultHasher::default();
                    d.hash(&mut hash);
                    i.hash(&mut hash);
                    key_value.0.hash(&mut hash);
                    let index = (hash.finish() as usize) % self.bins_count;
                    let temp = self.bins[d][i].get_mut(&index);
                    if let Some(v) = temp {
                        if v.len() < self.slot_count {
                            v.push(key_value.clone());
                            insert_into_stash = false;
                            break
                        } else {
                            let to_swap = v.remove(0);
                            v.push(key_value.clone());
                            key_value = to_swap;
                        }
                    } else {
                        self.bins[d][i].insert(index, vec![key_value.clone()]); 
                        insert_into_stash = false;
                        break;
                    }
                }
                if insert_into_stash {
                    self.stash[d].push(key_value);
                }
            }
        }
        self.recirculation_counter += recirculation_counter;
    }


    fn select_datapath(&self, key: K) -> usize {
        let mut hash = DefaultHasher::default();
        //TODO: selectable datapath hash key
        175u32.hash(&mut hash);
        key.hash(&mut hash);
        let datapath = (hash.finish() as usize) % self.datapath_count;
        //println!("datapath {}", datapath);
        datapath
    }

    pub fn update(&mut self, key: K, value: T)  {
        // select datapath
        let datapath = self.select_datapath(key.clone());
        let tables = &mut self.bins[datapath];
        let stash = &mut self.stash[datapath];
        for i in 0..self.tables_count { 
            let mut hash = DefaultHasher::default();
            datapath.hash(&mut hash);
            i.hash(&mut hash);
            key.clone().hash(&mut hash);
            let index = (hash.finish() as usize) % self.bins_count;
            if let Some(v) = tables[i].get_mut(&index) {
                for item in v {
                    if item.0 == key {
                        *item = (key.clone(),value.clone());
                        break;
                    }
                }
            }
        }
        for i in 0..stash.len() {
            if stash[i].0 == key { 
               stash[i] = (key,value); 
               break;
            }
        }
    }

    pub fn get_key_value(&self, key: K) -> Option<T> {
        // select datapath
        let datapath = self.select_datapath(key.clone());
        let tables = &self.bins[datapath];
        let stash = &self.stash[datapath];
        for i in 0..self.tables_count { 
            let mut hash = DefaultHasher::default();
            datapath.hash(&mut hash);
            i.hash(&mut hash);
            key.hash(&mut hash);
            let index = (hash.finish() as usize) % self.bins_count;
            if let Some((_,v)) = tables[i].get_key_value(&index) {
                for item in v {
                    if item.0 == key {
                        return Some(item.1.clone());
                    }
                }
            }
        }
        for i in 0..stash.len() {
            if stash[i].0 == key { 
                return Some(stash[i].1.clone());
            }
        }
        return None;
    }

    pub fn get_inserted_keys(&self) -> usize {
        let mut stash_counter:usize=0;
        for i in 0..self.stash.len() {
            stash_counter += self.stash[i].len();
        }
        let mut temp_counter = 0;
        for path in &self.bins { 
            for table in path {
                for item in table {
                    temp_counter += item.1.len();
                }
            }
        }
        temp_counter+stash_counter
    }

    pub fn get_occupancy(&self) -> f32 {
        let mut temp_counter = 0;
        for path in &self.bins { 
            for table in path {
                for item in table {
                    temp_counter += item.1.len();
                }
            }
        }
        return (temp_counter as f32)/((self.bins_count*self.tables_count*self.datapath_count) as f32);
    }

    pub fn get_total_bins_count(&self) -> usize {
        self.bins_count * self.slot_count * self.tables_count * self.datapath_count
    }

    pub fn clear(&mut self) {
        for d in &mut self.bins {
            for t in d {
                t.clear();
            }
        }
        self.stash.clear();
    }

}

pub struct QCuckooHash<T: std::clone::Clone + std::cmp::PartialEq> {
    bins: Vec<Vec<HashMap<usize,Vec<(u128,T)>>>>,
    stash: Vec<Vec<(u128,T)>>,
    bins_count: usize,
    tables_count: usize,
    slot_count: usize,
    stash_size: usize,
    datapath_count: usize,
    insertion_loop_limit: usize,
    failure: bool,
    recirculation_counter: usize,
    hash_functions: Vec<Vec<bijection::Bijection>>,
    key_length: usize,
    hack: u128,
    hack_set: std::collections::HashMap<u128,u128>
}


impl <T: std::clone::Clone + std::cmp::PartialEq> QCuckooHash<T> {
    pub fn build_cuckoo_hash(bins_count: usize, tables_count: usize, slot_count: usize, stash_size: usize, datapath_count: usize, insertion_loop_limit: usize, key_length: usize) -> QCuckooHash<T> {
        // check that bins_count is a power of 2, needed for computing index and fingerprint
        assert_eq!((bins_count as f32).log2(), (bins_count as f32).log2().round());
        let mut hash_functions = vec![];
        for d in 0..datapath_count {
            let mut temp_vec = vec![];
            for t in 0..tables_count {
                temp_vec.push(bijection::Bijection::new(&format!("{}{}",d,t)));
            }
            hash_functions.push(temp_vec);
        }
        QCuckooHash {
            bins: vec![ vec![HashMap::with_capacity(bins_count); tables_count]; datapath_count], 
            stash: vec![ vec! [ ]; datapath_count ],
            bins_count: bins_count,
            tables_count: tables_count,
            slot_count: slot_count,
            stash_size: stash_size,
            datapath_count: datapath_count,
            insertion_loop_limit,
            failure: false,
            recirculation_counter: 0,
            hash_functions: hash_functions,
            key_length: key_length,
            hack: 7498237423,
            hack_set: std::collections::HashMap::new()
        }
    }


    fn key_to_hash(&mut self, key: u128, datapath: usize, table: usize) -> u128 {
        let bij = &mut self.hash_functions[datapath][table];
        let ret = bij.convert_bytes(&key.to_be_bytes()[..]).unwrap();
        let mut temp = u128::from_be_bytes([ret[0],ret[1],ret[2],ret[3],ret[4],ret[5],ret[6],ret[7],ret[8],ret[9],ret[10],ret[11],ret[12],ret[13],ret[14],ret[15]]);
        let hack_value = temp % self.hack;
        temp = temp + hack_value;
        //try to get hack value binded to the hash
        if let None = self.hack_set.get(&temp) {
            self.hack_set.insert(temp, hack_value);
        }
        //println!("key {} hash {}", key , temp);
        temp
    }

    fn hash_to_key(&mut self, hash: u128, datapath: usize, table: usize) -> u128 {
        let bij = &mut self.hash_functions[datapath][table];
        let hack_value = self.hack_set.get(&hash).unwrap();
        let true_hash = hash - hack_value;
        let ret = bij.revert_bytes(&true_hash.to_be_bytes()[..]).unwrap();
        let temp = u128::from_be_bytes([ret[0],ret[1],ret[2],ret[3],ret[4],ret[5],ret[6],ret[7],ret[8],ret[9],ret[10],ret[11],ret[12],ret[13],ret[14],ret[15]]);
        //println!("hash {} key {}", hash, temp);
        temp
    }


    pub fn get_recirculation_loops(&self) -> usize {
        self.recirculation_counter
    }

    pub fn debug_print(&self) {
        for i in 0..self.datapath_count {
            println!("Datapath {}", i);
            for j in 0..self.tables_count {
                println!("table {} value count {}", j, self.bins[i][j].len());
            }
        }
        for i in 0..self.stash.len() {
            println!("Stash {} len {}", i , self.stash[i].len());
        }
        println!("Total loops: {}", self.recirculation_counter);
    }

    /// Insert a new key-value pair
    pub fn insert(&mut self, key: u128, value: T) -> bool {
        let mut inserted = false;
        //we already failed the previous insertion
        if self.failure {
            return false;
        }
        if let Some(_) = self.get_key_value(key.clone()) {
            //already inserted 
            //println!("hit");
            inserted = true;
        }
        if !inserted {
            // select datapath 
            let datapath = self.select_datapath(key.clone());
            // get datapath tables
            //let tables = &mut self.bins[datapath];
            // get datapath stash 
            //let stash = &mut self.stash[datapath];
            // try inserting into tables 
            for i in 0..self.tables_count {
                let hash = self.key_to_hash(key, datapath, i);
                let index = (hash % self.bins_count as u128) as usize;
                // round shouldn't be needed!
                let fp = hash >> ((self.bins_count as f32).log2().round() as u128);
                //println!("datapath {} table {} key {} index {}", datapath, i, key, index);
                // using index as hash table key -> one (key,value) per position
                if self.bins[datapath][i].get_key_value(&index) == None {
                    self.bins[datapath][i].insert(index,vec![(fp.clone(),value.clone())]);
                    inserted = true;
                    //println!("inserted into datapath {} table {} index {}", datapath, i, index);
                    break
                } else if let Some(v) = self.bins[datapath][i].get_mut(&index) {
                    if v.len() < self.slot_count {
                        v.push((fp.clone(),value.clone()));
                        inserted = true;
                        //println!("inserted into datapath {} table {} index {}", datapath, i, index);
                        break;
                    }
                }
            }
            // try inserting into stash in case of table insertion failure
            if self.stash[datapath].len() < self.stash_size && !inserted {
                self.stash[datapath].push((key,value));
                //println!("inserted into datapath {} stash key {}", datapath, key);
                inserted = true;
            }
        }
        if inserted {
            self.recirculate();
        } else {
            //self.debug_print();
            self.failure = true;
        }
        return inserted;
    }

    fn recirculate_condition(&self) -> bool {
        let all_stash_half_full = self.stash.iter().map(|v| { v.len() > (self.stash_size/2)}).reduce(|acc, v| { acc && v }).unwrap();
        let all_stash_threequarter_full = self.stash.iter().map(|v| { v.len() > ((self.stash_size*3)/4)}).reduce(|acc, v| { acc && v }).unwrap();
        let all_stash_onequarter_full = self.stash.iter().map(|v| { v.len() > (self.stash_size/4)}).reduce(|acc, v| { acc && v }).unwrap();
        let one_stash_almost_full = self.stash.iter().map(|v| { v.len() == (self.stash_size - 1)}).reduce(|acc, v| { acc || v }).unwrap();
        return all_stash_onequarter_full || one_stash_almost_full;
    }

    fn recirculate(&mut self) {
        //println!("into recirculation");
        let mut recirculation_counter = 0;
        let mut insert_into_stash = true;
        //while self.recirculate_condition() && recirculation_counter < self.insertion_loop_limit {
        while self.recirculate_condition() {
            // sure that each stash contains at least one element 
            recirculation_counter += 1;
            for d in 0..self.datapath_count {
                insert_into_stash = true;
                if self.stash[d].len() == 0 {
                    continue;
                }
                // pop key-value from the stash
                let mut key_value = self.stash[d].remove(0);
                for i in 0..self.tables_count { 
                    let hash = self.key_to_hash(key_value.0, d, i);
                    let index = (hash % self.bins_count as u128) as usize;
                    let fp = hash >> ((self.bins_count as f32).log2().round() as u128);
                    let temp = self.bins[d][i].get_mut(&index);
                    if let Some(v) = temp {
                        if v.len() < self.slot_count {
                            v.push((fp.clone(), key_value.1.clone()));
                            insert_into_stash = false;
                            break
                        } else {
                            let to_swap = v.remove(0);
                            v.push((fp.clone(), key_value.1.clone()));
                            key_value = to_swap;
                            // rebuild key
                            let mut temp_hash: u128 = key_value.0;
                            temp_hash = temp_hash << ((self.bins_count as f32).log2().round() as u128);
                            temp_hash = temp_hash | index as u128;
                            key_value.0 = self.hash_to_key(temp_hash, d, i);
                        }
                    } else {
                        self.bins[d][i].insert(index, vec![(fp.clone(), key_value.1.clone())]); 
                        insert_into_stash = false;
                        break;
                    }
                }
                if insert_into_stash {
                    self.stash[d].push(key_value);
                }
            }
        }
        self.recirculation_counter += recirculation_counter;
    }


    fn select_datapath(&self, key: u128) -> usize {
        let mut hash = DefaultHasher::default();
        //TODO: selectable datapath hash key
        175u32.hash(&mut hash);
        key.hash(&mut hash);
        let datapath = (hash.finish() as usize) % self.datapath_count;
        //println!("datapath {}", datapath);
        datapath
    }

    pub fn update(&mut self, key: u128, value: T)  {
        // select datapath
        let datapath = self.select_datapath(key.clone());
        //let tables = &mut self.bins[datapath];
        //let stash = &mut self.stash[datapath];
        for i in 0..self.tables_count { 
            let hash = self.key_to_hash(key, datapath, i);
            let index = (hash % self.bins_count as u128) as usize;
            let fp = hash >> ((self.bins_count as f32).log2().round() as u128);
            if let Some(v) = self.bins[datapath][i].get_mut(&index) {
                for item in v {
                    if item.0 == fp {
                        *item = (fp.clone(),value.clone());
                        break;
                    }
                }
            }
        }
        for i in 0..self.stash[datapath].len() {
            if self.stash[datapath][i].0 == key { 
               self.stash[datapath][i] = (key,value); 
               break;
            }
        }
    }

    pub fn get_key_value(&mut self, key: u128) -> Option<T> {
        // select datapath
        let datapath = self.select_datapath(key.clone());
        //let tables = &self.bins[datapath];
        //let stash = &self.stash[datapath];
        for i in 0..self.tables_count { 
            let hash = self.key_to_hash(key, datapath, i);
            let index = (hash % self.bins_count as u128) as usize;
            let fp = hash >> ((self.bins_count as f32).log2().round() as u128);
            if let Some((_,v)) = self.bins[datapath][i].get_key_value(&index) {
                for item in v {
                    if item.0 == fp {
                        return Some(item.1.clone());
                    }
                }
            }
        }
        for i in 0..self.stash[datapath].len() {
            if self.stash[datapath][i].0 == key { 
                return Some(self.stash[datapath][i].1.clone());
            }
        }
        return None;
    }

    pub fn get_inserted_keys(&self) -> usize {
        let mut temp_counter = 0;
        for path in &self.bins { 
            for table in path {
                for item in table {
                    temp_counter += item.1.len();
                }
            }
        }
        temp_counter
    }

    pub fn get_occupancy(&self) -> f32 {
        let mut temp_counter = 0;
        for path in &self.bins { 
            for table in path {
                for item in table {
                    temp_counter += item.1.len();
                }
            }
        }
        return (temp_counter as f32)/((self.bins_count*self.tables_count*self.datapath_count) as f32);
    }

    pub fn get_total_bins_count(&self) -> usize {
        self.bins_count * self.slot_count * self.tables_count * self.datapath_count
    }

    pub fn clear(&mut self) {
        for d in &mut self.bins {
            for t in d {
                t.clear();
            }
        }
        self.stash.clear();
    }

}
