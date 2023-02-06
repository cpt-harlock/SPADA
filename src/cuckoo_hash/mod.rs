use std::collections::hash_map::DefaultHasher;
use std::hash::Hash;
use std::hash::Hasher;
use rand::Rng;
use std::collections::HashMap;
use std::collections::VecDeque;

//extra bool allows key = 0
// for bins structure, first level of vectors represent different datapaths
// for each datapath, we have a vector of hashmaps
pub struct CuckooHash<K: std::fmt::Debug + std::hash::Hash + std::cmp::PartialEq + std::clone::Clone, T: std::clone::Clone + std::cmp::PartialEq> {
    bins: Vec<Vec<HashMap<usize,Vec<(K,T)>>>>,
    stash: Vec<Vec<(K,T)>>,
    bins_count: usize,
    tables_count: usize,
    slot_count: usize,
    stash_size: usize,
    datapath_count: usize,
    insertion_loop_limit: usize,
    failure: bool,
    recirculation_counter: usize,
}


impl <K: std::fmt::Debug + std::hash::Hash + std::cmp::PartialEq + std::clone::Clone,T: std::clone::Clone+ std::cmp::PartialEq> CuckooHash<K,T> {
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
        //debug
        //for i in 0..self.stash.len() {
        //    println!("Stash {} len {}", i, self.stash[i].len());
        //}
        //println!("recirculate_condition {}", self.stash.iter().map(|v| { v.len() > 0}).reduce(|acc, v| { acc && v }).unwrap());
        let stash_count_sum = self.stash.iter().map(|v| { v.len() }).reduce(|acc, v| { acc + v }).unwrap();
        let all_stash_not_empty = self.stash.iter().map(|v| { v.len() > 0}).reduce(|acc, v| { acc && v }).unwrap();
        return stash_count_sum >= self.stash_size - 1 || all_stash_not_empty;
    }

    fn recirculate(&mut self) {
        //println!("into recirculation");
        let mut recirculation_counter = 0;
        let mut insert_into_stash = true;
        while self.recirculate_condition() && recirculation_counter < self.insertion_loop_limit {
            // sure that each stash contains at least one element 
            recirculation_counter += 1;
            for d in 0..self.datapath_count {
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


pub struct QCuckooHash {
    bins: Vec<Vec<HashMap<usize,(u128,u128)>>>,
    stash: Vec<Vec<(u128,u128)>>,
    bins_count: usize,
    tables_count: usize,
    stash_size: usize,
    datapath_count: usize,
    insertion_loop_limit: usize,
    failure: bool,
    recirculation_counter: usize,
}


impl QCuckooHash {
    pub fn build_cuckoo_hash(bins_count: usize, tables_count: usize, stash_size: usize, datapath_count: usize, insertion_loop_limit: usize) -> QCuckooHash {
        QCuckooHash {
            bins: vec![ vec![HashMap::with_capacity(bins_count); tables_count]; datapath_count], 
            stash: vec![ vec! [ ]; datapath_count ],
            bins_count: bins_count,
            tables_count: tables_count,
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
    pub fn insert(&mut self, key: u128, value: u128) -> bool {
        let mut inserted = false;
        //we already failed the previous insertion
        if self.failure {
            return false;
        }
        if let Some(v) = self.get_key_value(key) {
            //already inserted 
            inserted = true;
        }
        if !inserted {
            // select datapath 
            let datapath = self.select_datapath(key);
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
                key.hash(&mut hash);
                // index modulo table length
                let index = (hash.finish() as usize) % self.bins_count;
                //println!("datapath {} table {} index {}", datapath, i, index);
                // using index as hash table key -> one (key,value) per position
                if tables[i].get_key_value(&index) == None {
                    tables[i].insert(index,(key,value));
                    inserted = true;
                    //println!("inserted into datapath {} table {} index {}", datapath, i, index);
                    break
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
        //debug
        //for i in 0..self.stash.len() {
        //    println!("Stash {} len {}", i, self.stash[i].len());
        //}
        //println!("recirculate_condition {}", self.stash.iter().map(|v| { v.len() > 0}).reduce(|acc, v| { acc && v }).unwrap());
        let stash_count_sum = self.stash.iter().map(|v| { v.len() }).reduce(|acc, v| { acc + v }).unwrap();
        let all_stash_not_empty = self.stash.iter().map(|v| { v.len() > 0}).reduce(|acc, v| { acc && v }).unwrap();
        return stash_count_sum >= self.stash_size - 1 || all_stash_not_empty;
    }

    fn recirculate(&mut self) {
        //println!("into recirculation");
        let mut recirculation_counter = 0;
        while self.recirculate_condition() && recirculation_counter < self.insertion_loop_limit {
            // sure that each stash contains at least one element 
            recirculation_counter += 1;
            for d in 0..self.datapath_count {
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
                    let temp = *self.bins[d][i].get_key_value(&index).unwrap_or((&0,&(0,0))).1;
                    self.bins[d][i].insert(index, key_value);
                    if temp == (0,0) { 
                        key_value = (0,0);
                        //println!("succesfull recirculation");
                        break;
                    } else {
                        key_value = temp;
                    }
                }
                if key_value != (0,0) {
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
    pub fn get_key_value(&self, key: u128) -> Option<u128> {
        // select datapath
        let datapath = self.select_datapath(key);
        let tables = &self.bins[datapath];
        let stash = &self.stash[datapath];
        for i in 0..self.tables_count { 
            let mut hash = DefaultHasher::default();
            datapath.hash(&mut hash);
            i.hash(&mut hash);
            key.hash(&mut hash);
            let index = (hash.finish() as usize) % self.bins_count;
            if let Some((_,v)) = tables[i].get_key_value(&index) {
                if v.0 == key {
                    return Some(v.1);
                }
            }
        }
        for i in 0..stash.len() {
            if stash[i].0 == key { 
                return Some(stash[i].1);
            }
        }
        return None;
    }

    pub fn get_occupancy(&self) -> f32 {
        let mut temp_counter = 0;
        for path in &self.bins { 
            for table in path {
                temp_counter += table.len()
            }
        }
        return (temp_counter as f32)/((self.bins_count*self.tables_count*self.datapath_count) as f32);
    }

}

