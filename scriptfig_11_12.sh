#!/bin/bash
./target/release/spada -f ../../tracce/caida1.pcap -t 4 -s 1 -r 13000 -m 6 -d 1 | grep stat > logs/log_c1_m6_d1.txt   &
./target/release/spada -f ../../tracce/caida1.pcap -t 4 -s 1 -r 13000 -m 7 -d 1 | grep stat > logs/log_c1_m7_d1.txt   & 
./target/release/spada -f ../../tracce/caida2.pcap -t 4 -s 1 -r 12000 -m 6 -d 1 | grep stat > logs/log_c2_m6_d1.txt   &  
./target/release/spada -f ../../tracce/caida2.pcap -t 4 -s 1 -r 12000 -m 7 -d 1 | grep stat > logs/log_c2_m7_d1.txt   & 
./target/release/spada -f ../../tracce/caida3.pcap -t 4 -s 1 -r 5800  -m 6 -d 1 | grep stat > logs/log_c3_m6_d1.txt   & 
./target/release/spada -f ../../tracce/caida3.pcap -t 4 -s 1 -r 6100  -m 7 -d 1 | grep stat > logs/log_c3_m7_d1.txt   & 

./target/release/spada -f ../../tracce/caida1.pcap -t 4 -s 1 -r 6500 -m 6 -d 2 | grep stat > logs/log_c1_m6_d2.txt   & 
./target/release/spada -f ../../tracce/caida1.pcap -t 4 -s 1 -r 6500 -m 7 -d 2 | grep stat > logs/log_c1_m7_d2.txt   & 
./target/release/spada -f ../../tracce/caida2.pcap -t 4 -s 1 -r 6000 -m 6 -d 2 | grep stat > logs/log_c2_m6_d2.txt   & 
./target/release/spada -f ../../tracce/caida2.pcap -t 4 -s 1 -r 6000 -m 7 -d 2 | grep stat > logs/log_c2_m7_d2.txt   & 
./target/release/spada -f ../../tracce/caida3.pcap -t 4 -s 1 -r 2900 -m 6 -d 2 | grep stat > logs/log_c3_m6_d2.txt  & 
./target/release/spada -f ../../tracce/caida3.pcap -t 4 -s 1 -r 3050 -m 7 -d 2 | grep stat > logs/log_c3_m7_d2.txt  & 

 
./target/release/spada -f ../../tracce/caida1.pcap -t 4 -s 1 -r 3250  -m 6 -d 4 | grep stat > logs/log_c1_m6_d4.txt   & 
./target/release/spada -f ../../tracce/caida1.pcap -t 4 -s 1 -r 3250  -m 7 -d 4 | grep stat > logs/log_c1_m7_d4.txt   & 
./target/release/spada -f ../../tracce/caida2.pcap -t 4 -s 1 -r 3000  -m 6 -d 4 | grep stat > logs/log_c2_m6_d4.txt   & 
./target/release/spada -f ../../tracce/caida2.pcap -t 4 -s 1 -r 3000  -m 7 -d 4 | grep stat > logs/log_c2_m7_d4.txt   & 
./target/release/spada -f ../../tracce/caida3.pcap -t 4 -s 1 -r 1450  -m 6 -d 4 | grep stat > logs/log_c3_m6_d4.txt   & 
./target/release/spada -f ../../tracce/caida3.pcap -t 4 -s 1 -r 1500  -m 7 -d 4 | grep stat > logs/log_c3_m7_d4.txt   & 
