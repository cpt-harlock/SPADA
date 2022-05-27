/*use hash32::{Hash, Hasher, BuildHasher, Murmur3Hasher};
use hash32::BuildHasherDefault;
pub struct sparseHLL {
    prefix_bit_length: usize,
    hash_table: cuckoo<usize,usize>,
}


impl HLL {
    pub fn build_hll(prefix_bit_length: usize, bin_size: usize) -> HLL {
        HLL {
            prefix_bit_length,
            //bins : vec![0; 2usize.pow(prefix_bit_length as u32)],
            bin_size,
        }
    }

    pub fn insert_data<T: Hash>(&mut self, index:usize, value: T) {
        let (i,v) self.compute_bin_prefix_pair(value);
        if v > self.bins.query(i) { 
                self.bins[i] = std::cmp::min(2usize.pow(self.bin_size as u32) - 1, v);
        } 
    }

    pub fn compute_bin_prefix_pair<T: Hash>(&self, value: T) -> (usize, usize) {
        let mut s: Murmur3Hasher = BuildHasherDefault::default().build_hasher();
        value.hash(&mut s);
        let hashed_value: u32 = s.finish();
        let bin_index = hashed_value >> 32 - self.prefix_bit_length; 
        let leading_zeros = HLL::compute_leading_zeros(hashed_value << self.prefix_bit_length, self.prefix_bit_length);
        (bin_index as usize, leading_zeros)
    }

    pub fn compute_leading_zeros(hashed_value: u32, prefix_bit_length: usize) -> usize {
        let mut count = 1;
        for i in 0..((32 - prefix_bit_length) - 1){
            if (hashed_value & (1 << (32 - 1 - i))) != 0 {
                break;
            }
            count += 1;
        }
        count 
    }
}
*/
