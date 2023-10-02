#!/bin/bash

# This script runs HLL & DDSketch simulations on two CAIDA traces
# and plot a two figures including results from MAWI (stored). 

# Usage
# Traces are supposed to be in a directory ./traces/caida>/<CAIDA1|CAIDA2>.pcap
# run cargo build
# run ./scriptfig_7_8_andrea.sh


# Simulations
echo "Simulations started...";

# HLL

# m = 64
# ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
# awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI1_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI1_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI1_m6_d1_HLL.txt"}}' &

# ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
# awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI2_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI2_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI2_m6_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA1_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA1_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA1_m6_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA2_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA2_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA2_m6_d1_HLL.txt"}}' &

# m = 128
# ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
# awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI1_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI1_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI1_m7_d1_HLL.txt"}}' &

# ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
# awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI2_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI2_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI2_m7_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA1_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA1_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA1_m7_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA2_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA2_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA2_m7_d1_HLL.txt"}}' &

# DDSketch

# m = 32
# ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
# awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI1_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI1_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI1_m5_d1_DDSketch.txt"}}' & 

# ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
# awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI2_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI2_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI2_m5_d1_DDSketch.txt"}}' & 

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA1_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA1_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA1_m5_d1_DDSketch.txt"}}' & 

./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA2_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA2_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA2_m5_d1_DDSketch.txt"}}' & 

# # m = 64
# ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
# awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI1_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI1_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI1_m6_d1_DDSketch.txt"}}' &

# ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
# awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_MAWI2_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_MAWI2_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_MAWI2_m6_d1_DDSketch.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA1_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA1_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA1_m6_d1_DDSketch.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/stats_CAIDA2_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/plot_CAIDA2_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/sparsity_CAIDA2_m6_d1_DDSketch.txt"}}' &

wait;
echo "Simulations completed.";


# Parse results for plots

# HLL
# touch ./plots/memory_hll.dat;
# echo "Trace Standard Standard_min Standard_max CHT CHT_min CHT_max qCHT qCHT_min qCHT_max Standard2 Standard2_min Standard2_max CHT2 CHT2_min CHT2_max qCHT2 qCHT2_min qCHT2_max" >> plots/memory_hll.dat;

# tail -3 logs/plot_MAWI1_m6_d1_HLL.txt | \
# cat - <(tail -3 logs/plot_MAWI1_m7_d1_HLL.txt) | \
# tr '\n' '\t' | \
# awk -F "\t" '{print "M1" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 / 1000}' >> plots/memory_hll.dat;

# tail -3 logs/plot_MAWI2_m6_d1_HLL.txt | \
# cat - <(tail -3 logs/plot_MAWI2_m7_d1_HLL.txt) | \
# tr '\n' '\t' | \
# awk -F "\t" '{print "M2" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 / 1000}' >> plots/memory_hll.dat;

tail -3 logs/plot_CAIDA1_m6_d1_HLL.txt | \
cat - <(tail -3 logs/plot_CAIDA1_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "C1" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 / 1000}' >> plots/memory_hll.dat;

tail -3 logs/plot_CAIDA2_m6_d1_HLL.txt | \
cat - <(tail -3 logs/plot_CAIDA2_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "C2" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 / 1000}' >> plots/memory_hll.dat;

# DDSketch
# touch plots/memory_ddsketch.dat;
# echo "Trace Standard Standard_min Standard_max CHT CHT_min CHT_max qCHT qCHT_min qCHT_max pIBLT pIBLT_min pIBLT_max Standard2 Standard2_min Standard2_max CHT2 CHT2_min CHT2_max qCHT2 qCHT2_min qCHT2_max pIBLT2 pIBLT2_min pIBLT2_max" >> plots/memory_ddsketch.dat;

# tail -4 logs/plot_MAWI1_m5_d1_DDSketch.txt | \
# cat - <(tail -4 logs/plot_MAWI1_m6_d1_DDSketch.txt) | \
# tr '\n' '\t' | \
# awk -F "\t" '{print "M1" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 /1000 "\t" $33 /1000 "\t" $34 /1000 "\t" $35 /1000 "\t" $38 /1000 "\t" $39 /1000 "\t" $40 / 1000}' >> plots/memory_ddsketch.dat;

# tail -4 logs/plot_MAWI2_m5_d1_DDSketch.txt | \
# cat - <(tail -4 logs/plot_MAWI2_m6_d1_DDSketch.txt) | \
# tr '\n' '\t' | \
# awk -F "\t" '{print "M2" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 /1000 "\t" $33 /1000 "\t" $34 /1000 "\t" $35 /1000 "\t" $38 /1000 "\t" $39 /1000 "\t" $40 / 1000}' >> plots/memory_ddsketch.dat;

tail -4 logs/plot_CAIDA1_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/plot_CAIDA1_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "C1" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 /1000 "\t" $33 /1000 "\t" $34 /1000 "\t" $35 /1000 "\t" $38 /1000 "\t" $39 /1000 "\t" $40 / 1000}' | \
tr '\t' ' ' >> plots/memory_ddsketch.dat;

tail -4 logs/plot_CAIDA2_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/plot_CAIDA2_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{print "C2" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 /1000 "\t" $33 /1000 "\t" $34 /1000 "\t" $35 /1000 "\t" $38 /1000 "\t" $39 /1000 "\t" $40 / 1000}' | \
tr '\t' ' ' >> plots/memory_ddsketch.dat;

echo "Results parsed.";

# Compute average sparsity

touch ./logs/avg_sparsities.txt

# HLL
# cat ./logs/sparsity_MAWI1_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m6 HLL sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;
# cat ./logs/sparsity_MAWI1_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m7 HLL sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;

# cat ./logs/sparsity_MAWI2_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m6 HLL sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;
# cat ./logs/sparsity_MAWI2_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m7 HLL sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;

cat ./logs/sparsity_CAIDA1_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m6 HLL sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;
cat ./logs/sparsity_CAIDA1_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m7 HLL sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;

cat ./logs/sparsity_CAIDA2_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m6 HLL sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;
cat ./logs/sparsity_CAIDA2_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m7 HLL sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;

# DDSketch
# cat ./logs/sparsity_MAWI1_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m5 DDSketch sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;
# cat ./logs/sparsity_MAWI1_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m6 DDSketch sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;

# cat ./logs/sparsity_MAWI2_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m5 DDSketch sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;
# cat ./logs/sparsity_MAWI2_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m6 DDSketch sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;

cat ./logs/sparsity_CAIDA1_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m5 DDSketch sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;
cat ./logs/sparsity_CAIDA1_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m6 DDSketch sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;

cat ./logs/sparsity_CAIDA2_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m5 DDSketch sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;
cat ./logs/sparsity_CAIDA2_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m6 DDSketch sparsity: " sum / NR }' >> ./logs/avg_sparsities.txt;

echo "Sparsity computed.";


# Draw the plots

cd ./plots;
gnuplot fig7.gp;
gnuplot fig8.gp;

echo "Plots saved.";



