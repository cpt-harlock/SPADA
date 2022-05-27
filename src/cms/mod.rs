use std::hash::Hash;
use std::hash::Hasher;
use std::cmp::min;
#[derive(Clone)]
pub struct CMS {
    filter_size: usize,
    hash_function_count: usize,
    filter_bins: Vec<u32>,
}


impl CMS {
    pub fn build_cms(filter_size: usize, hash_function_count: usize) -> CMS {
        let filter_bins = vec![0; filter_size*hash_function_count];
        CMS {
            filter_size, 
            hash_function_count,
            filter_bins,
        }
    }

    pub fn index<T: Hash>(&mut self, key: T) -> [i32;4] {
        let mut result = [-1;4];
        let range = 0..self.hash_function_count;
        let hash_function_range = self.filter_size; 
        for i in range {
            let mut hasher = std::collections::hash_map::DefaultHasher::default();
            i.hash(&mut hasher);
            key.hash(&mut hasher);
            let mut index = hasher.finish() as usize;
            index = index % hash_function_range;
            index = index + i*hash_function_range; 
            result[i] = index as i32;
            self.filter_bins[index] = self.filter_bins[index] + 1 ;
        }
        result
    }
    
    pub fn insert<T: Hash>(&mut self, key: T) {
        let range = 0..self.hash_function_count;
        let hash_function_range = self.filter_size; 
        for i in range {
            let mut hasher = std::collections::hash_map::DefaultHasher::default();
            i.hash(&mut hasher);
            key.hash(&mut hasher);
            let mut index = hasher.finish() as usize;
            index = index % hash_function_range;
            index = index + i*hash_function_range; 
            self.filter_bins[index] = self.filter_bins[index] + 1 ;
        }
    }

    pub fn query<T: Hash>(&self, key: T) -> u32 {
        let mut result= u32::MAX;
        let range = 0..self.hash_function_count;
        let hash_function_range = self.filter_size; 
        for i in range {
            let mut hasher = std::collections::hash_map::DefaultHasher::default();
            i.hash(&mut hasher);
            key.hash(&mut hasher);
            let mut index = hasher.finish() as usize;
            index = index % hash_function_range;
            index = index + i*hash_function_range; 
            result = min(result,self.filter_bins[index]);
            }
        return result;
    }

    pub fn clear(&mut self) {
        for x in self.filter_bins.iter_mut() {
            *x = 0;
        }
    }
    pub fn get_load(&self) -> f32 {
        self.filter_bins.iter().map(|x| if *x>0 {1.0} else {0.0} ).sum::<f32>() / (self.filter_size *self.hash_function_count) as f32
    }

    pub fn dump(&mut self) {
        for (n,x) in self.filter_bins.iter().enumerate() {
            println!("row [{}]={}",n, x);
        }
    }
}
