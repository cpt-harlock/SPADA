use std::hash::Hash;
use std::hash::Hasher;
#[derive(Clone)]
pub struct BloomFilter {
    filter_size: usize,
    hash_function_count: usize,
    filter_bins: Vec<bool>,
    num_items: usize
}


impl BloomFilter {
    pub fn build_bloom_filter(filter_size: usize, hash_function_count: usize) -> BloomFilter {
        let filter_bins = vec![false; filter_size];
        let num_items = 0;
        BloomFilter {
            filter_size, 
            hash_function_count,
            filter_bins,
            num_items,
        }
    }

    pub fn insert<T: Hash>(&mut self, key: T) {
        let range = 0..self.hash_function_count;
        let hash_function_range = self.filter_size/self.hash_function_count; 
        let mut flag=false;
        for i in range {
            let mut hasher = std::collections::hash_map::DefaultHasher::default();
            i.hash(&mut hasher);
            key.hash(&mut hasher);
            let mut index = hasher.finish() as usize;
            index = index % hash_function_range;
            index = index + i*hash_function_range; 
            if !self.filter_bins[index] {
                flag= true;
            }
            self.filter_bins[index] = true;
        }
        if flag {
            self.num_items = self.num_items +1;
        }
    }

    pub fn lazy_insert<T: Hash>(&mut self, key: T) {
        let range = 0..self.hash_function_count;
        let hash_function_range = self.filter_size/self.hash_function_count; 
        let mut flag=false;
        for i in range {
            let mut hasher = std::collections::hash_map::DefaultHasher::default();
            i.hash(&mut hasher);
            key.hash(&mut hasher);
            let mut index = hasher.finish() as usize;
            index = index % hash_function_range;
            index = index + i*hash_function_range; 
            if !self.filter_bins[index] {
                self.filter_bins[index] = true;
                flag= true;
                break;
            }
        }
        if flag {
            self.num_items = self.num_items +1;
        }
    }

    pub fn query<T: Hash>(&self, key: T) -> bool {
        let range = 0..self.hash_function_count;
        let hash_function_range = self.filter_size/self.hash_function_count; 
        for i in range {
            let mut hasher = std::collections::hash_map::DefaultHasher::default();
            i.hash(&mut hasher);
            key.hash(&mut hasher);
            let mut index = hasher.finish() as usize;
            index = index % hash_function_range;
            index = index + i*hash_function_range; 
            if self.filter_bins[index] == false {
                return false;
            }
        }
        return true;
    }

    pub fn clear(&mut self) {
        for x in self.filter_bins.iter_mut() {
            *x = false;
        }
        self.num_items =0;
    }
    pub fn get_num_items(&self) -> usize {
        self.num_items
    }
    pub fn get_load(&self) -> f32 {
        self.filter_bins.iter().map(|x| if *x {1.0} else {0.0} ).sum::<f32>() / self.filter_size as f32
    }
}
