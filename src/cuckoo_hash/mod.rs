use std::collections::hash_map::DefaultHasher;
use std::hash::Hash;
use std::hash::Hasher;
use rand::Rng;

//extra bool allows key = 0
pub struct CuckooHash<K,V> {
    bins: Vec<Vec<Vec<(Option<K>,Option<V>)>>>,
    rows: usize,
    slots: usize,
    tables: usize,
    extra_location: (Option<K>, Option<V>),
    insertion_loop_limit: usize,
}


impl <K: std::fmt::Debug + Hash + std::cmp::PartialEq+ std::clone::Clone,V:  std::clone::Clone>CuckooHash<K,V> {
    pub fn build_cuckoo_hash(rows: usize, slots: usize, tables: usize, insertion_loop_limit: usize) -> CuckooHash<K,V> {
        CuckooHash {
            bins: vec![vec![vec![(None,None);slots];rows];tables],
            rows,
            slots,
            tables,
            extra_location: (None,None),
            insertion_loop_limit,
        }
    }
    
    pub fn load(&self) -> f32 {
        let mut cont=0;
        for t in 0..self.tables {
            for i in 0..self.rows {
                for j in 0..self.slots {
                    if self.bins[t][i][j].0 !=None {
                        cont +=1;
                    }
                }
            }
        }
        return (cont as f32)/((self.rows*self.slots*self.tables) as f32); 
    }

    pub fn len(&self) -> usize {
        let mut cont=0;
        for t in 0..self.tables {
            for i in 0..self.rows {
                for j in 0..self.slots {
                    if self.bins[t][i][j].0 !=None {
                        cont +=1;
                    }
                }
            }
        }
        cont 
    }

    /// Insert a new key-value pair
    /// NOTE: insertion is not protected, should check before
    /// if the key is already in the CH
    pub fn insert(&mut self, key: K, value: V) -> i32 {
        //we already failed the previous insertion
        if self.extra_location.0 != None  {
            return -1;
        }
        let mut loop_counter = 0;
        self.extra_location = (Some(key), Some(value));
        loop {
            for t in 0..self.tables {
                let mut hash = DefaultHasher::default();
                (t as u32).hash(&mut hash);
                self.extra_location.0.hash(&mut hash);
                let index = hash.finish() as usize % self.rows;

                //insert if there's space in T[t]
                for i in 0..self.slots {
                    if self.bins[t][index][i].0 ==None {
                        self.bins[t][index][i]=self.extra_location.clone();
                        //println!("Inserted {:?} in {},{}",self.extra_location.0,first_index,i);
                        self.extra_location = (None,None);
                        return loop_counter;
                    }
                }
            }

            //else, pop a random element from the vector
            let t=rand::thread_rng().gen_range(0..self.tables);
            let s=rand::thread_rng().gen_range(0..self.slots);
            let temp = self.extra_location.clone();
            let mut hash = DefaultHasher::default();
            (t as u32).hash(&mut hash);
            self.extra_location.0.hash(&mut hash);
            let index = hash.finish() as usize % self.rows;
            self.extra_location = self.bins[t][index][s].clone();
            self.bins[t][index][s]=temp;

            loop_counter += 1;
            if loop_counter > self.insertion_loop_limit as i32 {
                break;
            }
        }
        return -1;
    }


    pub fn get_key_value(&self, key: K) -> Option<V> {
            for t in 0..self.tables {
                let mut hash = DefaultHasher::default();
                (t as u32).hash(&mut hash);
                Some(&key).hash(&mut hash);
                let index = hash.finish() as usize % self.rows;

                //try if is in T[t]
                for i in 0..self.slots {
                    if let Some(test) =&self.bins[t][index][i].0 {
                        if *test==key {
                        return self.bins[t][index][i].1.clone();
                        }
                    }
                }
            }
        return None;
    }


// update if it is present, otherwise return false!
    pub fn update(&mut self, key: K, value: V) -> bool {
        for t in 0..self.tables {
            let mut hash = DefaultHasher::default();
            (t as u32).hash(&mut hash);
            Some(&key).hash(&mut hash);
            let index = hash.finish() as usize % self.rows;

            //try if is in T[t]
            for i in 0..self.slots {
                if let Some(test) =&self.bins[t][index][i].0 {
                    if *test==key {
                        self.bins[t][index][i].1=Some(value);
                        return true;
                    }
                }
            }
        }
        return false;
    }

    pub fn check(&self, key: K) -> bool {
        for t in 0..self.tables {
            let mut hash = DefaultHasher::default();
            (t as u32).hash(&mut hash);
            Some(&key).hash(&mut hash);
            let index = hash.finish() as usize % self.rows;

            //try if is in T[t]
            for i in 0..self.slots {
                if let Some(test) =&self.bins[t][index][i].0 {
                    if *test==key {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    pub fn clear(&mut self) {
        for t in 0..self.tables {
            for i in 0..self.slots {
                for j in 0..self.rows {
                    self.bins[t][j][i]= (None,None);
                }
            }
        }
    }
}



