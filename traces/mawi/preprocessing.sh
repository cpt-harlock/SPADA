# Preprocess MAWI traces
# MAWI_1: trace 201904092215.pcap filtered from 2019-04-09 UTC 15:15:00 to 2019-04-09 UTC 15:20:00 (5 minutes) TCP traffic only
(sudo editcap -F pcap -A 2019-04-0915:15:00 -B 2019-04-0915:20:00 201904092215.pcap 201904092215_15h15_5minute.pcap;
tshark -r 201904092215_15h15_5minute.pcap -Y tcp -w MAWI1.pcap -F pcap) & 

# MAWI_2: trace 201904091315.pcap filtered from 2019-04-09 UTC 09:15:00 to 2019-04-09 UTC 09:20:00 (5 minutes) TCP traffic only
(sudo editcap -F pcap -A 2019-04-0906:15:00 -B 2019-04-0906:20:00 201904091315.pcap 201904091315_06h15_5minute.pcap;
tshark -r 201904091315_06h15_5minute.pcap -Y tcp -w MAWI2.pcap -F pcap) & 
wait;
echo "MAWI PCAPs preprocessed";
