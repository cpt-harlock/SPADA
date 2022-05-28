use std::collections::hash_map::DefaultHasher;
use std::hash::Hash;
use std::hash::Hasher;
use rand::Rng;

//extra bool allows key = 0
pub struct CuckooHash<K,V> {
    bins: Vec<Vec<Vec<(Option<K>,Option<V>)>>>,
    rows: usize,
    slots: usize,
    extra_location: (Option<K>, Option<V>),
    insertion_loop_limit: usize,
}


impl <K: std::fmt::Debug + Hash + std::cmp::PartialEq+ std::clone::Clone,V:  std::clone::Clone>CuckooHash<K,V> {
    pub fn build_cuckoo_hash(rows: usize, slots: usize, insertion_loop_limit: usize) -> CuckooHash<K,V> {
        CuckooHash {
            bins: vec![vec![vec![(None,None);slots];rows];2],
            rows,
            slots,
            extra_location: (None,None),
            insertion_loop_limit,
        }
    }

    /// Insert a new key-value pair
    /// NOTE: insertion is not protected, should check before
    /// if the key is already in the CH
    pub fn insert(&mut self, key: K, value: V) -> i32 {
        //we already failed the previous insertion
        if self.extra_location.0 != None  {
            return -1;
        }
        let mut loop_counter = 1;
        self.extra_location = (Some(key), Some(value));
        let mut kick=0;
        loop {
            let mut hash_1 = DefaultHasher::default();
            let mut hash_2 = DefaultHasher::default();
            0u32.hash(&mut hash_1);
            1u32.hash(&mut hash_2);
            //try first bin 
            self.extra_location.0.hash(&mut hash_1);
            let first_index = hash_1.finish() as usize % self.rows;

            //insert if there's space
            for i in 0..self.slots {
                if self.bins[0][first_index][i].0 ==None {
                    self.bins[0][first_index][i]=self.extra_location.clone();
                    //println!("Inserted {:?} in {},{}",self.extra_location.0,first_index,i);
                    self.extra_location = (None,None);
                    return loop_counter;
                }
            }

            //try second bin
            self.extra_location.0.hash(&mut hash_2);
            let second_index = hash_2.finish() as usize % self.rows;

            //insert if there's space
            for i in 0..self.slots {
                if self.bins[1][second_index][i].0 == None {
                    self.bins[1][second_index][i]=self.extra_location.clone();
                    self.extra_location = (None,None);
                    return loop_counter;
                }
            }
            
            //else, pop a random element from the vector
            let s=rand::thread_rng().gen_range(0..self.slots);
            let mut index=first_index;
            if kick==1 {
                index=second_index; 
            }
            let temp = self.extra_location.clone();
            self.extra_location = self.bins[kick][index][s].clone();
            self.bins[kick][index][s]=temp;

            kick = (kick +1) %2;
            loop_counter += 1;
            if loop_counter > self.insertion_loop_limit as i32 {
                break;
            }
        }
        return -1;
    }


    pub fn get_key_value(&self, key: K) -> Option<V> {
        let mut hash_1 = DefaultHasher::default();
        let mut hash_2 = DefaultHasher::default();
        0u32.hash(&mut hash_1);
        1u32.hash(&mut hash_2);
        Some(&key).hash(&mut hash_1);
        Some(&key).hash(&mut hash_2);
        let first_index = hash_1.finish() as usize % self.rows;
        let second_index = hash_2.finish() as usize % self.rows;

        //try first bin 
        for i in 0..self.slots {
            if let Some(test) =&self.bins[0][first_index][i].0 {
                if *test==key {
                    return self.bins[0][first_index][i].1.clone();
                }
            }
        }

        //try second bin
        for i in 0..self.slots {
            if let Some(test) =&self.bins[1][second_index][i].0 {
                if *test==key {
                    return self.bins[1][second_index][i].1.clone();
                }
            }
        }
        return None;
    }


// update if it is present, otherwise return false!
    pub fn update(&mut self, key: K, value: V) -> bool {
        let mut hash_1 = DefaultHasher::default();
        let mut hash_2 = DefaultHasher::default();
        0u32.hash(&mut hash_1);
        1u32.hash(&mut hash_2);
        Some(&key).hash(&mut hash_1);
        Some(&key).hash(&mut hash_2);
        let first_index = hash_1.finish() as usize % self.rows;
        let second_index = hash_2.finish() as usize % self.rows;

        //try first bin 
        for i in 0..self.slots {
            if let Some(test) =&self.bins[0][first_index][i].0 {
                if *test==key {
                    self.bins[0][first_index][i].1=Some(value);
                    return true;
                }
            }
        }

        //try second bin
        for i in 0..self.slots {
            if let Some(test) =&self.bins[1][second_index][i].0 {
                if *test==key {
                    self.bins[1][second_index][i].1=Some(value);
                    return true;
                }
            }
        }
        return false;
    }

    pub fn check(&self, key: K) -> bool {
        let mut hash_1 = DefaultHasher::default();
        let mut hash_2 = DefaultHasher::default();
        0u32.hash(&mut hash_1);
        1u32.hash(&mut hash_2);
        Some(&key).hash(&mut hash_1);
        Some(&key).hash(&mut hash_2);
        let first_index = hash_1.finish() as usize % self.rows;
        let second_index = hash_2.finish() as usize % self.rows;

        //try first bin 
        for i in 0..self.slots {
            if let Some(test) =&self.bins[0][first_index][i].0 {
                if *test==key {
                    //println!("Checked {:?} in {},{}",key,first_index,i);
                    return true; 
                }
            }
        }

        //try second bin
        for i in 0..self.slots {
            if let Some(test) =&self.bins[1][second_index][i].0 { 
                if *test==key {
                    //println!("Checked {:?} in {},{}",key,second_index,i);
                    return true; 
                }
            }
        }
        return false;
    }

    pub fn clear(&mut self) {
        for i in 0..self.slots {
            for j in 0..self.rows {
                self.bins[0][j][i]= (None,None);
                self.bins[1][j][i]= (None,None);
            }
        }
    }
}



