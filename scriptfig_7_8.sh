#!/bin/bash

# TODO: 
# - Error messages for DDSketch simulations (e.g., ERROR min -0.0000030994415283203125)

# Usage
# Traces are supposed to be in a new directory ./traces/<mawi|caida>/<MAWI1|MAWI2|CAIDA1|CAIDA2>.pcap
# run `./scriptfig_7_8.sh`

# Preprocess MAWI traces

# MAWI_1: trace 201904092215.pcap filtered from 2019-04-09 UTC 15:15:00 to 2019-04-09 UTC 15:18:00 (5 minutes) TCP traffic only
(sudo editcap -F pcap -A 2019-04-0915:15:00 -B 2019-04-0915:20:00 ./traces/mawi/201904092215.pcap ./traces/mawi/201904092215_15h15_5minute.pcap;
tshark -r ./traces/mawi/201904092215_15h15_5minute.pcap -Y tcp -w ./traces/mawi/MAWI1.pcap -F pcap) & 
# MAWI_2: trace 201904091315.pcap filtered from 2019-04-09 UTC 09:15:00 to 2019-04-09 UTC 09:18:00 (5 minutes) TCP traffic only
(sudo editcap -F pcap -A 2019-04-0906:15:00 -B 2019-04-0906:20:00 ./traces/mawi/201904091315.pcap ./traces/mawi/201904091315_06h15_5minute.pcap;
tshark -r ./traces/mawi/201904091315_06h15_5minute.pcap -Y tcp -w ./traces/mawi/MAWI2.pcap -F pcap) & 
wait;
echo "MAWI PCAPs preprocessed";

# Simulations

# HLL

# m = 64
./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI1_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI1_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI1_m6_d1_HLL.txt"}}' &
./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI2_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI2_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI2_m6_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA1_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA1_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA1_m6_d1_HLL.txt"}}' &
./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA2_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA2_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA2_m6_d1_HLL.txt"}}' &

# m = 128
./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI1_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI1_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI1_m7_d1_HLL.txt"}}' &
./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI2_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI2_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI2_m7_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA1_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA1_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA1_m7_d1_HLL.txt"}}' &
./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA2_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA2_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA2_m7_d1_HLL.txt"}}' &

# DDSketch

# m = 32
./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI1_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI1_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI1_m5_d1_DDSketch.txt"}}' & 
./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI2_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI2_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI2_m5_d1_DDSketch.txt"}}' & 

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA1_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA1_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA1_m5_d1_DDSketch.txt"}}' & 
./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA2_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA2_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA2_m5_d1_DDSketch.txt"}}' & 

# m = 64
./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI1_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI1_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI1_m6_d1_DDSketch.txt"}}' &
./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI2_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI2_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI2_m6_d1_DDSketch.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA1_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA1_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA1_m6_d1_DDSketch.txt"}}' &
./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA2_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA2_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA2_m6_d1_DDSketch.txt"}}' &

wait;
echo "Simulations complete.";


# Create .dat files for plotting

# HLL
touch plots/memory_hll.dat;
echo "Trace Standard Standard_min Standard_max CHT CHT_min CHT_max qCHT qCHT_min qCHT_max Standard2 Standard2_min Standard2_max CHT2 CHT2_min CHT2_max qCHT2 qCHT2_min qCHT2_max" >> plots/memory_hll.dat;
# M1
tail -3 logs/plot_MAWI1_m6_d1_HLL.txt | \
cat - <(tail -3 logs/plot_MAWI1_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "M1" "\t" $3 "\t" $4 "\t" $5 "\t" $8 "\t" $9 "\t" $10 "\t" $13 "\t" $14 "\t" $15 "\t" $18 "\t" $19 "\t" $20 "\t" $23 "\t" $24 "\t" $25 "\t" $28 "\t" $29 "\t" $30}' >> plots/memory_hll.dat;
# M2
tail -3 logs/plot_MAWI2_m6_d1_HLL.txt | \
cat - <(tail -3 logs/plot_MAWI2_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "M2" "\t" $3 "\t" $4 "\t" $5 "\t" $8 "\t" $9 "\t" $10 "\t" $13 "\t" $14 "\t" $15 "\t" $18 "\t" $19 "\t" $20 "\t" $23 "\t" $24 "\t" $25 "\t" $28 "\t" $29 "\t" $30}' >> plots/memory_hll.dat;
# C1
tail -3 logs/plot_CAIDA1_m6_d1_HLL.txt | \
cat - <(tail -3 logs/plot_CAIDA1_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "C1" "\t" $3 "\t" $4 "\t" $5 "\t" $8 "\t" $9 "\t" $10 "\t" $13 "\t" $14 "\t" $15 "\t" $18 "\t" $19 "\t" $20 "\t" $23 "\t" $24 "\t" $25 "\t" $28 "\t" $29 "\t" $30}' >> plots/memory_hll.dat;
# C2
tail -3 logs/plot_CAIDA2_m6_d1_HLL.txt | \
cat - <(tail -3 logs/plot_CAIDA2_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "C2" "\t" $3 "\t" $4 "\t" $5 "\t" $8 "\t" $9 "\t" $10 "\t" $13 "\t" $14 "\t" $15 "\t" $18 "\t" $19 "\t" $20 "\t" $23 "\t" $24 "\t" $25 "\t" $28 "\t" $29 "\t" $30}' >> plots/memory_hll.dat;


# DDSketch
touch plots/memory_ddsketch.dat;
echo "Trace Standard Standard_min Standard_max CHT CHT_min CHT_max qCHT qCHT_min qCHT_max pIBLT pIBLT_min pIBLT_max Standard2 Standard2_min Standard2_max CHT2 CHT2_min CHT2_max qCHT2 qCHT2_min qCHT2_max pIBLT2 pIBLT2_min pIBLT2_max" >> plots/memory_ddsketch.dat;
# M1
tail -4 logs/plot_MAWI1_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/plot_MAWI1_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "M1" "\t" $3 "\t" $4 "\t" $5 "\t" $8 "\t" $9 "\t" $10 "\t" $13 "\t" $14 "\t" $15 "\t" $18 "\t" $19 "\t" $20 "\t" $23 "\t" $24 "\t" $25 "\t" $28 "\t" $29 "\t" $30 "\t" $33 "\t" $34 "\t" $35 "\t" $38 "\t" $39 "\t" $40}' >> plots/memory_ddsketch.dat;
# M2
tail -4 logs/plot_MAWI2_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/plot_MAWI2_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "M2" "\t" $3 "\t" $4 "\t" $5 "\t" $8 "\t" $9 "\t" $10 "\t" $13 "\t" $14 "\t" $15 "\t" $18 "\t" $19 "\t" $20 "\t" $23 "\t" $24 "\t" $25 "\t" $28 "\t" $29 "\t" $30 "\t" $33 "\t" $34 "\t" $35 "\t" $38 "\t" $39 "\t" $40}' >> plots/memory_ddsketch.dat;
# C1
tail -4 logs/plot_CAIDA1_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/plot_CAIDA1_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "C1" "\t" $3 "\t" $4 "\t" $5 "\t" $8 "\t" $9 "\t" $10 "\t" $13 "\t" $14 "\t" $15 "\t" $18 "\t" $19 "\t" $20 "\t" $23 "\t" $24 "\t" $25 "\t" $28 "\t" $29 "\t" $30 "\t" $33 "\t" $34 "\t" $35 "\t" $38 "\t" $39 "\t" $40}' | \
tr '\t' ' ' >> plots/memory_ddsketch.dat;
# C2
tail -4 logs/plot_CAIDA2_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/plot_CAIDA2_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "C2" "\t" $3 "\t" $4 "\t" $5 "\t" $8 "\t" $9 "\t" $10 "\t" $13 "\t" $14 "\t" $15 "\t" $18 "\t" $19 "\t" $20 "\t" $23 "\t" $24 "\t" $25 "\t" $28 "\t" $29 "\t" $30 "\t" $33 "\t" $34 "\t" $35 "\t" $38 "\t" $39 "\t" $40}' | \
tr '\t' ' ' >> plots/memory_ddsketch.dat;

echo ".dat files parsed.";

# Draw the plots

cd ./plots;
gnuplot fig7.gp;
gnuplot fig8.gp;
echo "Plots complete.";


# Compute average sparsity

./avg_sparsity.sh > avg_sparsities.txt;
echo "Sparsity computed.";
