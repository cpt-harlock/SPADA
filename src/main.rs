//use spada::bloom_filter;
//use spada::cms;
use spada::cuckoo_hash;
use clap::{Arg, Command};
use std::net::Ipv4Addr;
use std::u32::MAX;
//use std::intrinsics::log2f64;
use std::process::exit;
//use core::cmp::max;

pub use pcap_parser::traits::PcapReaderIterator;
pub use pcap_parser::*;
use pcap_parser::data::{get_packetdata, PacketData};
pub use std::fs::File;
pub use std::io::ErrorKind;
pub use std::io::Read;
pub use packet::ether::Packet as EthernetPacket; 
pub use packet::ip::Packet as IpPacket;
pub use packet::tcp::Packet as TcpPacket;
pub use packet::udp::Packet as UdpPacket;
pub use packet::Packet;
pub use csv::Writer;
pub use std::io::Write;
//use itertools::Itertools;
//use std::iter;
use std::hash::{Hash,BuildHasher,Hasher};
use hash32::Murmur3Hasher;
use hash32::BuildHasherDefault;



fn compute_bucket_index(iat:f64,m:u32) -> u32 {
    let min:f64=1e-8;
    let max:f64=1.0;
    let num_buckets=(1<<m) as f64;
    let gamma=(max/min).powf(1.0/num_buckets);
    let min_index=(min.log2()/gamma.log2());
    let t= iat.log2()/gamma.log2();
    let mut res= iat.log2()/gamma.log2()-min_index;
    if iat<min {println!("ERROR min {iat}");}
    if iat>max {println!("ERROR {iat}");}
    //println!("compute ddsketch index: iat {iat} t {t} gamma {gamma} min_index {min_index}, res {res}");
    if res.ceil() as u32 > (1<<m)-1 {
        res +=-1.0;
    }
    res.ceil() as u32
}

fn compute_bin_prefix_pair<T: Hash>(value: T, prefix_bit_length:u32) -> (u32, u32) {
    let mut s: Murmur3Hasher = BuildHasherDefault::default().build_hasher();
    value.hash(&mut s);
    let hashed_value = s.finish() as u32;
    let bin_index = hashed_value >> (32 - prefix_bit_length); 
    let leading_zeros = compute_leading_zeros(hashed_value << prefix_bit_length, prefix_bit_length);
    (bin_index, leading_zeros)
}

fn compute_leading_zeros(hashed_value: u32, prefix_bit_length: u32) -> u32 {
    let mut count = 1;
    for i in 0..((32 - prefix_bit_length) - 1){
        if (hashed_value & (1 << (32 - 1 - i))) != 0 {
            break;
        }
        count += 1;
    }
    count 
}

fn main() {

    let args: Vec<String> = std::env::args().collect();

    println!("command line is: {:?}", &args);
    let matches = Command::new("Spada simulator")
        .version("0.1.0")
        .author("sp")
        .about("Simulate Sparse Data structures")
        .arg(Arg::new("filename")
             .short('f')
             .long("file")
             .takes_value(true)
             .default_value("./test.pcap")
             .help("pcap file"))
        .arg(Arg::new("m")
             .short('m')
             .long("mhll")
             .takes_value(true)
             .default_value("6")
             .help("use 2^m bins per HLL"))
        .arg(Arg::new("r")
             .short('r')
             .long("rows")
             .takes_value(true)
             .default_value("16384")
             .help("use r rows for the cuckoo hashing"))
        .arg(Arg::new("s")
             .short('s')
             .long("slots")
             .takes_value(true)
             .default_value("1")
             .help("use s slots for the cuckoo hashing"))
        .arg(Arg::new("t")
             .short('t')
             .long("tables")
             .takes_value(true)
             .default_value("4")
             .help("use t Tables for the cuckoo hashing"))
        .arg(Arg::new("d")
             .short('d')
             .long("datapath")
             .takes_value(true)
             .default_value("1")
             .help("use d datapath for recirculation"))
        .arg(Arg::new("epoch_time")
             .short('e')
             .long("epoch")
             .takes_value(true)
             .default_value("1.0")
             .help("time between epochs"))
        .arg(Arg::new("DDSketch")
             .short('D')
             .long("ddsketch")
             //.default_value("false")
             .help("switch between HLL and DDSketch"))
        .get_matches();

    let filename = matches.value_of("filename").unwrap();
    let m = matches.value_of("m").unwrap().parse::<u32>().unwrap();
    let slots = matches.value_of("s").unwrap().parse::<usize>().unwrap();
    let rows = matches.value_of("r").unwrap().parse::<usize>().unwrap();
    let tables = matches.value_of("t").unwrap().parse::<usize>().unwrap();
    let datapath = matches.value_of("d").unwrap().parse::<usize>().unwrap();
    let epoch_time=matches.value_of("epoch_time").unwrap().parse::<f64>().unwrap();
    let ddsketch=matches.is_present("DDSketch");


    println!("parameters are: -f {:?} -m {:?} -e {:?} -s {:?} -r {:?} -t {:?} -d {:?} -D {:?}", filename, m, epoch_time,slots,rows,tables,datapath,ddsketch);



    let mut if_linktypes = Vec::new();
    let mut trace_linktype;
    let mut file = File::open(filename).unwrap();
    let mut buffer = Vec::new();
    let mut hashmap:std::collections::HashMap<(Ipv4Addr,Ipv4Addr,i32,u16,u16),f64> = std::collections::HashMap::new();
    let mut cuckoo = cuckoo_hash::CuckooHash::<u128,(u32,u32)>::build_cuckoo_hash(rows,tables,slots,16/datapath,datapath,2000);
    let mut sparseSketchArray = cuckoo_hash::CuckooHash::<u128,u32>::build_cuckoo_hash(rows,tables,slots,16/datapath,datapath,2000);
    let mut sparsehashmap:std::collections::HashMap<u128,u32> = std::collections::HashMap::new();
    let mut first_packet=true;
    let mut epoch=0;
    let mut t0=0.0;
    let mut num_packets = 0;
    let mut FlowIDcounter:u32 = 0;
    let mut num_insertions = 0;
    let mut last_num_insertions = 0;
    let mut max_num_insertions = 0;
    let mut num_m0_insertions = 0;

    let mut num=0;
    let mut min=[MAX;10];
    let mut max=[0u32;10];
    let mut maxf=[0.0f32;10];
    let mut tot=[0u32;10];

    println!("stat:\tEpoch\tpackets\tflows\tRecirculations [%]\tlast Recirculation [%]\tload\t{}",m);
    println!("plot hll:\tEpoch\tBaseline\tSPADA-CHT\tSPADA-qCHT\tpIBLT");


    file.read_to_end(&mut buffer).unwrap();
    // try pcap first
    match PcapCapture::from_file(&buffer) {
        Ok(capture) => {
            println!("Format: PCAP");
            //setting PCAP packet type
            trace_linktype = capture.header.network;
            for block in capture.iter() {
                match block {
                    PcapBlock::LegacyHeader(packet_header) => {
                        println!("Read pcap header!");
                        println!("{:?}", packet_header);
                        trace_linktype = packet_header.network;
                    }
                    PcapBlock::NG(Block::SectionHeader(ref _shb)) => {
                        // starting a new section, clear known interfaces
                        if_linktypes = Vec::new();
                        println!("ng block header");
                    }
                    PcapBlock::NG(Block::InterfaceDescription(ref idb)) => {
                        if_linktypes.push(idb.linktype);
                        println!("ng block interface desc");
                    }
                    PcapBlock::NG(Block::EnhancedPacket(ref epb)) => {
                        assert!((epb.if_id as usize) < if_linktypes.len());
                        println!("ng block enh pack");
                        #[cfg(feature = "data")]
                        let res = pcap_parser::data::get_packetdata(
                            epb.data,
                            linktype,
                            epb.caplen as usize,
                            );
                    }
                    PcapBlock::NG(Block::SimplePacket(ref _spb)) => {
                        assert!(if_linktypes.len() > 0);
                        println!("ng block simple pack");
                        #[cfg(feature = "data")]
                        let res = pcap_parser::data::get_packetdata(spb.data, linktype, blen);
                    }
                    PcapBlock::NG(_) => {
                        // can be statistics (ISB), name resolution (NRB), etc.
                        println!("ng block unsup");
                        eprintln!("unsupported block");
                    }

                    PcapBlock::Legacy(packet) => {
                        let pkt_data = get_packetdata(packet.data, trace_linktype, packet.caplen as usize).unwrap();
                        //println!("usec {}",packet.ts_sec as f64 + packet.ts_usec as f64 / 1000000.0);
                        let mut ts = packet.ts_sec as f64 + (packet.ts_usec as f64 /1000000.0);
                        let l2_packet; 
                        let l3_packet;
                        let l4_tcp_packet;
                        let l4_udp_packet;
                        let proto;
                        let src_port;
                        let dst_port;

                        //println!("read packet");
                        match pkt_data {
                            PacketData::L2(a) => {
                                //println!("Ethernet packet");
                                l2_packet = EthernetPacket::new(a).unwrap();
                                //unchecked as there's no payload
                                let temp_l3 = IpPacket::unchecked(l2_packet.payload());
                                match temp_l3 {
                                    IpPacket::V4(p) => {
                                        l3_packet = p;
                                    },
                                    _ => {   continue; }
                                }
                                if l3_packet.protocol() == packet::ip::Protocol::Tcp {
                                    proto=0x06;
                                    //println!("tcp inside ip");
                                    l4_tcp_packet = TcpPacket::new(l3_packet.payload()).unwrap();
                                    src_port = l4_tcp_packet.source();
                                    dst_port = l4_tcp_packet.destination();
                                    //println!("{:?}", l4_packet);
                                } 
                                else {
                                    if l3_packet.protocol() == packet::ip::Protocol::Udp {
                                        proto=0x11;
                                        l4_udp_packet = UdpPacket::new(l3_packet.payload()).unwrap();
                                        src_port = l4_udp_packet.source();
                                        dst_port = l4_udp_packet.destination();
                                    }
                                    else {                                    
                                        //println!("not tcp/udp");
                                        continue;
                                    }
                                }
                            },
                            PacketData::L3(_, b) => {
                                let temp_l3 = IpPacket::unchecked(b);
                                match temp_l3 {
                                    IpPacket::V4(p) => {l3_packet = p; },
                                    _ => { continue; }

                                }
                                if l3_packet.protocol() == packet::ip::Protocol::Tcp {
                                    //println!("tcp inside ip");
                                    proto=0x06;
                                    match TcpPacket::new(l3_packet.payload()) {
                                        Ok(p) => l4_tcp_packet = p,
                                        _ => continue,
                                    }
                                    src_port = l4_tcp_packet.source();
                                    dst_port = l4_tcp_packet.destination();
                                    //println!("{:?}", l4_tcp_packet);
                                } else {
                                    if l3_packet.protocol() == packet::ip::Protocol::Udp {
                                        proto=0x11;
                                        match UdpPacket::new(l3_packet.payload()) {
                                            Ok(p) => l4_udp_packet = p,
                                            _ => continue,
                                        }
                                        src_port = l4_udp_packet.source();
                                        dst_port = l4_udp_packet.destination();
                                    }
                                    else {                                    
                                        //println!("not tcp/udp");
                                        continue;
                                    }
                                }
                            },

                            PacketData::L4(_, _) => {
                                println!("L4 type");
                                continue;
                            },
                            PacketData::Unsupported(_a) => {
                                println!("Unsupported");
                                continue;
                            },
                        }
                        /**************************************************
                         *  Packet processing starts here
                         **************************************************/

                        //epoch reset and print
                        //let key  = (l3_packet.source(), l3_packet.destination(), proto, src_port, dst_port);
                        let key  = if ddsketch {
                            //(l3_packet.source(), l3_packet.destination(), proto, src_port, dst_port)
                            (l3_packet.source(),l3_packet.source(),0 ,0,0)
                        }
                        else 
                        {
                            (l3_packet.source(),l3_packet.source(),0 ,0,0)
                        };
                        if first_packet {
                            t0=ts; 
                            first_packet=false;
                            println!("\nnew epoch: [{}] ", epoch);
                        }
                        ts = ts-t0-epoch_time*(epoch as f64);
                        //if (epoch==2) {exit(0)};
                        if ts>epoch_time {
                            epoch +=1;
                            ts -=epoch_time;
                            num_insertions += sparseSketchArray.get_recirculation_loops();
                            println!("#packets {}", num_packets);
                            println!("#flows {}", hashmap.len());
                            println!("#insertions {}", num_insertions);
                            println!("#insertions >0 {}", num_m0_insertions);
                            println!("max #insertions {}", max_num_insertions);
                            println!("loads {} {}", cuckoo.get_occupancy(), sparseSketchArray.get_occupancy());
                            println!("stat:\t{}\t{}\t{}\t{:.2}\t{}\t{}",epoch,num_packets,hashmap.len(),100.0*(num_insertions as f32)/(num_packets as f32),(last_num_insertions as f32)/10.0,sparseSketchArray.get_occupancy());
                            tot[0] += num_insertions  as u32;
                            tot[5] += num_packets  as u32;
                            if sparseSketchArray.get_occupancy()<0.9 {
                                maxf[0] = maxf[0].max(100.0*(num_insertions as f32)/(num_packets as f32));
                                maxf[1] = maxf[1].max(last_num_insertions as f32);
                                maxf[2] = maxf[2].max(sparseSketchArray.get_occupancy());
                            }
                            num +=1;

                            // I use 111/819200 to say 90% load factor, size in KB (8192b)
                            let load_pct = 0.9;
                            if ddsketch {

                                let s_c = 8 as f32; // DDSketch bucket size (8-bit buckets)
                                let s_k = (32 + 16 + 32 + 16 + 8) as f32; // Size of key (5-tuple)
                                let n_s = hashmap.len() as f32; // Number of flows (i.e., sketches)
                                let overpr_n_s = ((n_s / load_pct) / tables as f32) as f32; // Overprovisioned to keep the load < load_pct

                                // Baseline
                                let mut value = overpr_n_s * (s_k + (overpr_n_s * tables as f32).log2().ceil() + 2u32.pow(m) as f32 * s_c);
                                value = value * tables as f32 / 8192 as f32;
                                min[1] = min[1].min(value as u32);
                                max[1] = max[1].max(value as u32);
                                tot[1] += value  as u32;
                                print!("plot dds:\t{}\t{}",epoch,value);

                                // SPADA - CHT. Suppose 16 bits for the FlowId + 8 for the bucket value
                                let n_u = sparseSketchArray.get_total_bins_count() as f32 * sparseSketchArray.get_occupancy(); // n_u here is sparsity across *all* counters
                                let overpr_n_u = ((n_u / load_pct) / tables as f32) as f32;
                                value = overpr_n_s * (s_k + (overpr_n_s * tables as f32).log2().ceil()) + overpr_n_u * ((overpr_n_s * tables as f32).log2().ceil() + m as f32 + s_c);
                                value = value * tables as f32 / 8192 as f32;
                                min[2] = min[2].min(value as u32);
                                max[2] = max[2].max(value as u32);
                                tot[2] += value as u32;
                                print!("\t{}",value);

                                // SPADA - qCHT. Suppose 4 tables of 14 bits to store (FlowId+Idx + the dds value)
                                let quotient = (overpr_n_s * 2u32.pow(m) as f32).log2().ceil() - overpr_n_u.log2().ceil();
                                value = overpr_n_s * (s_k + (overpr_n_s * tables as f32).log2().ceil()) + overpr_n_u * (quotient + s_c); 
                                value = value * tables as f32 / 8192 as f32;
                                min[3] = min[3].min(value as u32);
                                max[3] = max[3].max(value as u32);
                                tot[3] += value as u32;
                                print!("\t{}",value);

                                // SPADA - pIBLT. Suppose that we can use pIBLT with 3 tables of 8 bits to store the dds value + 64K*2^m bits (2^m*8KB) for the bitmap
                                let bitmap = ( (overpr_n_s * tables as f32) * 2u32.pow(m) as f32);
                                value = overpr_n_s * (s_k + (overpr_n_s * tables as f32).log2().ceil()) + (overpr_n_u * s_c);
                                value = value * tables as f32;
                                value = value + bitmap; // We use a single bitmap for all tables
                                value = value / 8192 as f32;
                                min[4] = min[4].min(value as u32);
                                max[4] = max[4].max(value as u32);
                                tot[4] += value as u32;
                                println!("\t{}",value);
                            }

                            // HLL
                            else {

                                let s_c = 5 as f32; // HLL bucket size (2**5 = 32 maximum number of leading zeros)
                                let s_k = 32 as f32; // Size of key (IP address)
                                let n_s = hashmap.len() as f32; // Number of flows (i.e., sketches)
                                let overpr_n_s = ((n_s / load_pct) / tables as f32) as f32; // Overprovisioned to keep the load < load_pct

                                // Baseline
                                let mut value = overpr_n_s * (s_k + (overpr_n_s * tables as f32).log2().ceil() + 2u32.pow(m) as f32 * s_c);
                                value = value * tables as f32 / 8192 as f32;
                                min[1] = min[1].min(value as u32);
                                max[1] = max[1].max(value as u32);
                                tot[1] += value  as u32;
                                print!("plot hll:\t{}\t{}",epoch,value);

                                // SPADA - CHT. Suppose 16 bits for the FlowId + 5 for the hll value
                                let n_u = sparseSketchArray.get_total_bins_count() as f32 * sparseSketchArray.get_occupancy(); // n_u here is sparsity across *all* counters
                                let overpr_n_u = ((n_u / load_pct) / tables as f32) as f32;
                                value = overpr_n_s * (s_k + (overpr_n_s * tables as f32).log2().ceil()) + overpr_n_u * ((overpr_n_s * tables as f32).log2().ceil() + m as f32 + s_c);
                                value = value * tables as f32 / 8192 as f32;
                                min[2] = min[2].min(value as u32);
                                max[2] = max[2].max(value as u32);
                                tot[2] += value  as u32;
                                print!("\t{}",value);

                                // SPADA - qCHT. Suppose 4 tables of 14 bits to store (FlowId+Idx + the hll value)
                                let quotient = (overpr_n_s * 2u32.pow(m) as f32).log2().ceil() - overpr_n_u.log2().ceil();
                                value = overpr_n_s * (s_k + (overpr_n_s * tables as f32).log2().ceil()) + overpr_n_u * (quotient + s_c);
                                value = value * tables as f32 / 8192 as f32;
                                min[3] = min[3].min(value as u32);
                                max[3] = max[3].max(value as u32);
                                tot[3] += value  as u32;
                                print!("\t{}",value); 
                                println!("\tN/A");

                                // Number of rows required to ensure a load factor of `load_pct` 
                                print!("Overprovisioned non-zero counters HLL SPADA-qCHT: {}\n",  overpr_n_u);
                            }

                            //test per oracolo perfetto
                            {
                                let mut sparse=0;
                                let mut tot =0;
                                let mut tot_sparse =0;
                                let mut tot_count =0;
                                let mut sparsity = 0.0;
                                let total_buckets = 1<<m;
                                for _v in cuckoo.iter() {
                                //        println!("fid:{:?}",v);
                                    tot_count +=1;
                                }
                                tot_count=0;
                                for flow_id in 0..hashmap.len() {
                                    let mut count=0;
                                    for id in 0..(1<<m) {
                                        let key_u128 = (flow_id as u128 )<< 32 | (id as u128);
                                        if let Some(v)= sparseSketchArray.get_key_value(key_u128) {
                                            //println!("count key: {} {} {} ",flow_id,id,v);
                                            count +=1;
                                            tot +=1;
                                        }
                                    }
                                    if count<8 {
                                            sparse +=1;
                                            tot_sparse += count;
                                    }
                                    tot_count += count;
                                    sparsity += (count as f64)/(total_buckets as f64);
                                }
                                sparsity /= (hashmap.len() as f64);
                                let dense=hashmap.len()-sparse;
                                println!("count: {}== {} =={}", tot,sparseSketchArray.get_inserted_keys(),sparsehashmap.len());
                                println!("sparse: {} dense: {} ratio:{}", sparse,dense,(sparse as f32)/(hashmap.len() as f32));
                                println!("sparse memory:  {}", 15*(sparse+dense)+4*tot_count);
                                println!("oracle memory:  {}", 45*dense+15*sparse+4*tot_sparse);
                                println!("average sparsity:  {}", sparsity);
                                //if let Some(value) = sparseSketchArray.get_key_value(key_u128)  //just update
                            }


                            hashmap.clear();
                            //cuckoo.clear();
                            //sparseSketchArray.clear();
                            cuckoo = cuckoo_hash::CuckooHash::<u128,(u32,u32)>::build_cuckoo_hash(rows,tables,slots,16,datapath,2000);
                            sparseSketchArray = cuckoo_hash::CuckooHash::<u128,u32>::build_cuckoo_hash(rows,tables,slots,16,datapath,2000);
                            sparsehashmap.clear();
                            println!("\nnew epoch: [{}] ", epoch);
                            num_packets =0;
                            num_insertions =0;
                            num_m0_insertions =0;
                            max_num_insertions =0;
                            FlowIDcounter=0;
                        }
                        if num_packets %1000==0 {
                            //println!("{num_packets}");
                            last_num_insertions=sparseSketchArray.get_recirculation_loops();
                            num_insertions += sparseSketchArray.get_recirculation_loops();
                            sparseSketchArray.clear_recirculation_loops();
                        }


                        //insertion in first data structure (Key2IDCH)
                        num_packets += 1;
                        let mut iat=0.0;
                        let mut first_of_a_flow=false;
                        if let Some(v)= hashmap.get_mut(&key) {
                            iat=ts-*v;
                            if iat==0.0 { iat=1e-8;}
                            *v=ts;
                            //if iat>1e-2 { iat=1e-2;}
                        } 
                        else {
                            hashmap.insert(key,ts);
                            // we cannot compute IAT for the first packet
                            if ddsketch {
                                first_of_a_flow=true;
                            }
                        }
                        //print!("{} ", ts);
                        //println!(" key {:?} ", key);


                        let flow_id; 
                        let mut key_u128: u128;
                        key_u128 = u32::from_ne_bytes(key.0.octets()) as u128;
                        key_u128 = (key_u128 << 32) | u32::from_ne_bytes(key.1.octets()) as u128;
                        key_u128 = (key_u128 << 16) | key.3 as u32 as u128;
                        key_u128 = (key_u128 << 16) | key.4 as u32 as u128;
                        key_u128 = (key_u128 << 8) | key.2 as u32 as u128;
                        if let Some(value) = cuckoo.get_key_value(key_u128) { //just update
                            cuckoo.update(key_u128,(value.0,value.1+1)); 
                            flow_id=value.0;
                        }
                        else { //first insertion
                            let r=cuckoo.insert(key_u128,(FlowIDcounter,1)); 
                            if !r {println!("ERROR in cuckoo insert"); exit(-1);}
                            flow_id=FlowIDcounter;
                            FlowIDcounter +=1;
                        }
                        // we cannot compute IAT for the first packet
                        if first_of_a_flow {continue};

                        //insertion in second data structure (SparseSketchArray)
                        // (FlowID,index) for an HLL with m bins

                        let (index,leading_zeros)= if ddsketch {
                            (compute_bucket_index(iat,m),1)
                        } 
                        else {
                            compute_bin_prefix_pair(l3_packet.destination(),m)
                        };

                        //TODO: generic also for key
                        key_u128 = flow_id as u128;
                        key_u128 = key_u128 << 32 | index as u128;
                        if let Some(value) = sparseSketchArray.get_key_value(key_u128) { //just update
                            if ddsketch {
                                //println!("update {flow_id} with id={index}");
                                sparseSketchArray.update(key_u128,value+1); 
                                if let Some(v)= sparsehashmap.get_mut(&key_u128) {
                                    *v=*v+1;
                                } 
                            } 
                            else { //hll update
                                if leading_zeros > value { 
                                    sparseSketchArray.update(key_u128,leading_zeros); 
                                    if let Some(v)= sparsehashmap.get_mut(&key_u128) {
                                        *v=leading_zeros;
                                    } 
                                }
                            }
                        }
                        else { //first insertion
                        //ddsketch/hll update
                            let ins = sparseSketchArray.insert(key_u128, leading_zeros);
                            sparsehashmap.insert(key_u128,leading_zeros); 

                            //num_insertions +=ins;
                            //max_num_insertions =max_num_insertions.max(ins);
                            //if ins>0 { num_m0_insertions +=1;}
                            //println!("INS={}",ins);
                            if !ins {
                                println!("ERROR in SparseArray insert"); 
                                exit(-1);
                            }
                        }

                            //println!("k: {:?} {:?} v: {:?}",key,l3_packet.destination(),(FlowID,index,leading_zeros));
                        }
                    }
                }
            },
                _ => { println!("error capture"); }
        }



        println!("#packets {}", num_packets);
        println!("#flows {}", hashmap.len());
        println!("#insertions {}", num_insertions);
        println!("#insertions >1 {}", num_m0_insertions);
        println!("stat: recirculations\t packets\t overall recirculation [%]\t last recirculation [%]\t load");
        println!("stat: \t{}\t{}\t{:.2}\t{}\t{:.2}",tot[0]/num,tot[5]/num,maxf[0],maxf[1]/10.0,maxf[2]);
        if ddsketch {
            println!("plot dds \t min:\t{}\t{}\t{}\t{}",min[1],min[2],min[3],min[4]);
            println!("plot dds \t ave:\t{}\t{}\t{}\t{}",tot[1]/num,tot[2]/num,tot[3]/num,tot[4]/num);
            println!("plot dds \t max:\t{}\t{}\t{}\t{}",max[1],max[2],max[3],max[4]);
            println!("plot dds \t [1]:\t{}\t{}\t{}",tot[1]/num,min[1],max[1]);
            println!("plot dds \t [2]:\t{}\t{}\t{}",tot[2]/num,min[2],max[2]);
            println!("plot dds \t [3]:\t{}\t{}\t{}",tot[3]/num,min[3],max[3]);
            println!("plot dds \t [4]:\t{}\t{}\t{}",tot[4]/num,min[4],max[4]);

        }
        else {
            println!("plot hll \t min:\t{}\t{}\t{}\tN/A",min[1],min[2],min[3]);
            println!("plot hll \t ave:\t{}\t{}\t{}\tN/A",tot[1]/num,tot[2]/num,tot[3]/num);
            println!("plot hll \t max:\t{}\t{}\t{}\tN/A",max[1],max[2],max[3]);
            println!("plot hll \t [1]:\t{}\t{}\t{}",tot[1]/num,min[1],max[1]);
            println!("plot hll \t [2]:\t{}\t{}\t{}",tot[2]/num,min[2],max[2]);
            println!("plot hll \t [3]:\t{}\t{}\t{}",tot[3]/num,min[3],max[3]);

        }       
        /*for (k,v) in &hashmap {
          println!("TRUE k: {:?} v: {}",k,v);
          println!("in cuckoo we have: {:?} {:?}",k,cuckoo.get_key_value(*k));
          }*/
    }


