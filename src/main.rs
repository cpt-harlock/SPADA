//use spada::bloom_filter;
//use spada::cms;
use spada::cuckoo_hash;
use clap::{Arg, Command};

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
        .arg(Arg::new("epoch_time")
             .short('e')
             .long("epoch")
             .takes_value(true)
             .default_value("1.0")
             .help("time between epochs"))
        .get_matches();
    
    let filename = matches.value_of("filename").unwrap();
    let m = matches.value_of("m").unwrap().parse::<u32>().unwrap();
    let epoch_time=matches.value_of("epoch_time").unwrap().parse::<f64>().unwrap();



    let mut if_linktypes = Vec::new();
    let mut trace_linktype;
    let mut file = File::open(filename).unwrap();
    let mut buffer = Vec::new();
    let mut hashmap = std::collections::HashMap::new();
    let mut cuckoo = cuckoo_hash::CuckooHash::build_cuckoo_hash(1024,2000,4);
    let mut sparseSketchArray = cuckoo_hash::CuckooHash::build_cuckoo_hash(1024,2000,4);
    let mut first_packet=true;
    let mut epoch=0;
    let mut t0=0.0;
    let mut num_packets = 0;
    let mut FlowIDcounter:u32 = 0;
    let mut num_insertions = 0;


    println!("stat:\tEpoch\tpackets\tflows\tinsertions\t{}",m);


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
                        let key  = l3_packet.source(); //, l3_packet.destination(), proto, src_port, dst_port);
                        if first_packet {
                            t0=ts; 
                            first_packet=false;
                            println!("new epoch: [{}] ", epoch);
                        }
                        ts = ts-t0-epoch_time*(epoch as f64);
                        if ts>epoch_time {
                            epoch +=1;
                            ts -=epoch_time;
                            println!("#packets {}", num_packets);
                            println!("#flows {}", hashmap.len());
                            println!("#insertions {}", num_insertions);
                            println!("stat:\t{}\t{}\t{}\t{}",epoch,num_packets,hashmap.len(),num_insertions);
                            
                            
                            hashmap.clear();
                            cuckoo.clear();
                            sparseSketchArray.clear();
                            println!("new epoch: [{}] ", epoch);
                            num_packets =0;
                            num_insertions =0;
                            FlowIDcounter=0;
                        }


                        //insertion in first data structure (Key2IDCH)
                        num_packets += 1;
                        let values = hashmap.get(&key).unwrap_or(&0).clone(); 
                        hashmap.insert(key,values+1);
                        //print!("{} ", ts);
                        //println!(" key {:?} ", key);


                        let FlowID; 
                        if cuckoo.check(key) { //just update
                            let value:(u32,u32) = cuckoo.get_key_value(key).unwrap(); 
                            cuckoo.update(key,(value.0,value.1+1)); 
                            FlowID=value.0;
                        }
                        else { //first insertion
                            cuckoo.insert(key,(FlowIDcounter,1)); 
                            FlowID=FlowIDcounter;
                            FlowIDcounter +=1;
                        }

                        //insertion in second data structure (SparseSketchArray)
                        // (FlowID,index) for an HLL with m bins
                        let (index,leading_zeros)=compute_bin_prefix_pair(l3_packet.destination(),m);
                        if sparseSketchArray.check((FlowID,index)) { //just update
                            let value:u32 = sparseSketchArray.get_key_value((FlowID,index)).unwrap(); 

                            //hll update
                            if leading_zeros > value { 
                                sparseSketchArray.update((FlowID,index),leading_zeros); 
                            }
                        }
                        else { //first insertion
                            let ins = sparseSketchArray.insert((FlowID,index), leading_zeros); 
                            num_insertions +=ins;
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
    /*for (k,v) in &hashmap {
        println!("TRUE k: {:?} v: {}",k,v);
        println!("in cuckoo we have: {:?} {:?}",k,cuckoo.get_key_value(*k));
    }*/
}


