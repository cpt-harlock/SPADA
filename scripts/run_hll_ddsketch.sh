#!/bin/bash

# This script runs HLL & DDSketch simulations on CAIDA and MAWI traces for different sketch data configuration and plots
# two figures comparing memory stats. Figures are saved under ./plots/

# Usage:
# Traces are supposed to be in a directory ./traces/<mawi/caida>/<CAIDA1|CAIDA2|MAWI1|MAWI2>.pcap
# From the root directory:
# $ cargo build
# $ ./scripts/run_hll_ddsketch.sh


rm -r ./logs/hll_ddsketch 2> /dev/null
mkdir ./logs/hll_ddsketch
touch ./logs/hll_ddsketch/avg_sparsities.txt

rm ./plots/memory_hll.dat 2> /dev/null
rm ./plots/memory_ddsketch.dat 2> /dev/null


# RUN SIMULATIONS

echo "Simulations started...";

## HLL

### m = 64
./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_MAWI1_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_MAWI1_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_MAWI1_m6_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_MAWI2_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_MAWI2_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_MAWI2_m6_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_CAIDA1_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_CAIDA1_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_CAIDA1_m6_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_CAIDA2_m6_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_CAIDA2_m6_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_CAIDA2_m6_d1_HLL.txt"}}' &

### m = 128
./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_MAWI1_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_MAWI1_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_MAWI1_m7_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 60.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_MAWI2_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_MAWI2_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_MAWI2_m7_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_CAIDA1_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_CAIDA1_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_CAIDA1_m7_d1_HLL.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 1.0 | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_CAIDA2_m7_d1_HLL.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_CAIDA2_m7_d1_HLL.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_CAIDA2_m7_d1_HLL.txt"}}' &

wait

## DDSketch

### m = 32
./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_MAWI1_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_MAWI1_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_MAWI1_m5_d1_DDSketch.txt"}}' &

./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_MAWI2_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_MAWI2_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_MAWI2_m5_d1_DDSketch.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_CAIDA1_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_CAIDA1_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_CAIDA1_m5_d1_DDSketch.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 5 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_CAIDA2_m5_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_CAIDA2_m5_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_CAIDA2_m5_d1_DDSketch.txt"}}' &

### m = 64
./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_MAWI1_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_MAWI1_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_MAWI1_m6_d1_DDSketch.txt"}}' &

./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_MAWI2_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_MAWI2_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_MAWI2_m6_d1_DDSketch.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_CAIDA1_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_CAIDA1_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_CAIDA1_m6_d1_DDSketch.txt"}}' &

./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 -D | egrep "stat|plot|sparsity" | \
awk '{if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/hll_ddsketch/stats_CAIDA2_m6_d1_DDSketch.txt"} else if ($0 ~ /plot/) {printf("%s\n", $0) > "logs/hll_ddsketch/plot_CAIDA2_m6_d1_DDSketch.txt"} else if ($0 ~ /sparsity/) {printf("%s\n", $0) > "logs/hll_ddsketch/sparsity_CAIDA2_m6_d1_DDSketch.txt"}}' &

wait;
echo "Simulations completed.";


# COMPUTE AVERAGE SPARSITY

rm ./logs/hll_ddsketch/avg_sparsities.txt 2> /dev/null
touch ./logs/hll_ddsketch/avg_sparsities.txt

## HLL
cat ./logs/hll_ddsketch/sparsity_MAWI1_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m6 HLL sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;
cat ./logs/hll_ddsketch/sparsity_MAWI1_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m7 HLL sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;

cat ./logs/hll_ddsketch/sparsity_MAWI2_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m6 HLL sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;
cat ./logs/hll_ddsketch/sparsity_MAWI2_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m7 HLL sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;

cat ./logs/hll_ddsketch/sparsity_CAIDA1_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "CAIDA1 m6 HLL sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;
cat ./logs/hll_ddsketch/sparsity_CAIDA1_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "CAIDA1 m7 HLL sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;

cat ./logs/hll_ddsketch/sparsity_CAIDA2_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "CAIDA2 m6 HLL sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;
cat ./logs/hll_ddsketch/sparsity_CAIDA2_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "CAIDA2 m7 HLL sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;

## DDSketch
cat ./logs/hll_ddsketch/sparsity_MAWI1_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m5 DDSketch sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;
cat ./logs/hll_ddsketch/sparsity_MAWI1_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m6 DDSketch sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;

cat ./logs/hll_ddsketch/sparsity_MAWI2_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m5 DDSketch sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;
cat ./logs/hll_ddsketch/sparsity_MAWI2_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m6 DDSketch sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;

cat ./logs/hll_ddsketch/sparsity_CAIDA1_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "CAIDA1 m5 DDSketch sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;
cat ./logs/hll_ddsketch/sparsity_CAIDA1_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "CAIDA1 m6 DDSketch sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;

cat ./logs/hll_ddsketch/sparsity_CAIDA2_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "CAIDA2 m5 DDSketch sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;
cat ./logs/hll_ddsketch/sparsity_CAIDA2_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "CAIDA2 m6 DDSketch sparsity: " sum / NR }' >> ./logs/hll_ddsketch/avg_sparsities.txt;

echo "Sparsity values computed.";

# COMPUTE AVERAGE FLOWS

rm ./logs/hll_ddsketch/avg_flows.txt 2> /dev/null
touch ./logs/hll_ddsketch/avg_flows.txt

## HLL
cat ./logs/hll_ddsketch/stats_MAWI1_m6_d1_HLL.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "MAWI1 m6 HLL flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;
cat ./logs/hll_ddsketch/stats_MAWI1_m7_d1_HLL.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "MAWI1 m7 HLL flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;

cat ./logs/hll_ddsketch/stats_MAWI2_m6_d1_HLL.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "MAWI2 m6 HLL flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;
cat ./logs/hll_ddsketch/stats_MAWI2_m7_d1_HLL.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "MAWI2 m7 HLL flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;

cat ./logs/hll_ddsketch/stats_CAIDA1_m6_d1_HLL.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "CAIDA1 m6 HLL flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;
cat ./logs/hll_ddsketch/stats_CAIDA1_m7_d1_HLL.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "CAIDA1 m7 HLL flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;

cat ./logs/hll_ddsketch/stats_CAIDA2_m6_d1_HLL.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "CAIDA2 m6 HLL flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;
cat ./logs/hll_ddsketch/stats_CAIDA2_m7_d1_HLL.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "CAIDA2 m7 HLL flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;

## DDSketch
cat ./logs/hll_ddsketch/stats_MAWI1_m5_d1_DDSketch.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "MAWI1 m5 DDSketch flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;
cat ./logs/hll_ddsketch/stats_MAWI1_m6_d1_DDSketch.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "MAWI1 m6 DDSketch flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;

cat ./logs/hll_ddsketch/stats_MAWI2_m5_d1_DDSketch.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "MAWI2 m5 DDSketch flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;
cat ./logs/hll_ddsketch/stats_MAWI2_m6_d1_DDSketch.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "MAWI2 m6 DDSketch flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;

cat ./logs/hll_ddsketch/stats_CAIDA1_m5_d1_DDSketch.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "CAIDA1 m5 DDSketch flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;
cat ./logs/hll_ddsketch/stats_CAIDA1_m6_d1_DDSketch.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "CAIDA1 m6 DDSketch flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;

cat ./logs/hll_ddsketch/stats_CAIDA2_m5_d1_DDSketch.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "CAIDA2 m5 DDSketch flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;
cat ./logs/hll_ddsketch/stats_CAIDA2_m6_d1_DDSketch.txt | head -n -2 | tail -n +2 | awk '{ sum += $4 } END { if (NR > 0) print "CAIDA2 m6 DDSketch flows: " sum / NR }' >> ./logs/hll_ddsketch/avg_flows.txt;

echo "Flows computed.";


# PARSE MEMORY RESULTS

## HLL
rm ./plots/memory_hll.dat 2> /dev/null
touch ./plots/memory_hll.dat;
echo "Trace Standard Standard_min Standard_max CHT CHT_min CHT_max qCHT qCHT_min qCHT_max Standard2 Standard2_min Standard2_max CHT2 CHT2_min CHT2_max qCHT2 qCHT2_min qCHT2_max Static_CHT Static_qCHT Static2_CHT Static2_qCHT s_p1 s_p2" >> plots/memory_hll.dat;

### worst case static sparsity
m6_p=$(cat logs/hll_ddsketch/avg_sparsities.txt | grep "m6 HLL" | awk 'BEGIN{p=   0}{if ($5>0+p) p=$5 fi} END{print p*2}')
m7_p=$(cat logs/hll_ddsketch/avg_sparsities.txt | grep "m7 HLL" | awk 'BEGIN{p=   0}{if ($5>0+p) p=$5 fi} END{print p*2}')

f=$(cat logs/hll_ddsketch/avg_flows.txt | grep "CAIDA1" | grep "HLL" | head -1 | awk '{print $5}')
s_cht=$(python -c"import scripts.static_mem as sm; sm.tot_hll_cht(float('$f'), 6, float('$m6_p'))")
s_qcht=$(python -c"import scripts.static_mem as sm; sm.tot_hll_qcht(float('$f'), 6, float('$m6_p'))")
s_cht2=$(python -c"import scripts.static_mem as sm; sm.tot_hll_cht(float('$f'), 7, float('$m7_p'))")
s_qcht2=$(python -c"import scripts.static_mem as sm; sm.tot_hll_qcht(float('$f'), 7, float('$m7_p'))")
tail -3 logs/hll_ddsketch/plot_CAIDA1_m6_d1_HLL.txt | \
cat - <(tail -3 logs/hll_ddsketch/plot_CAIDA1_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{printf "C1" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 / 1000}' >> plots/memory_hll.dat;
echo -e "\t $s_cht \t $s_qcht \t $s_cht2 \t $s_qcht2 \t $m6_p \t $m7_p" >> plots/memory_hll.dat;

f=$(cat logs/hll_ddsketch/avg_flows.txt | grep "CAIDA2" | grep "HLL" | head -1 | awk '{print $5}')
s_cht=$(python -c"import scripts.static_mem as sm; sm.tot_hll_cht(float('$f'), 6, float('$m6_p'))")
s_qcht=$(python -c"import scripts.static_mem as sm; sm.tot_hll_qcht(float('$f'), 6, float('$m6_p'))")
s_cht2=$(python -c"import scripts.static_mem as sm; sm.tot_hll_cht(float('$f'), 7, float('$m7_p'))")
s_qcht2=$(python -c"import scripts.static_mem as sm; sm.tot_hll_qcht(float('$f'), 7, float('$m7_p'))")
tail -3 logs/hll_ddsketch/plot_CAIDA2_m6_d1_HLL.txt | \
cat - <(tail -3 logs/hll_ddsketch/plot_CAIDA2_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{printf "C2" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 / 1000}' >> plots/memory_hll.dat;
echo -e "\t $s_cht \t $s_qcht \t $s_cht2 \t $s_qcht2 \t $m6_p \t $m7_p" >> plots/memory_hll.dat;

f=$(cat logs/hll_ddsketch/avg_flows.txt | grep "MAWI1" | grep "HLL" | head -1 | awk '{print $5}')
s_cht=$(python -c"import scripts.static_mem as sm; sm.tot_hll_cht(float('$f'), 6, float('$m6_p'))")
s_qcht=$(python -c"import scripts.static_mem as sm; sm.tot_hll_qcht(float('$f'), 6, float('$m6_p'))")
s_cht2=$(python -c"import scripts.static_mem as sm; sm.tot_hll_cht(float('$f'), 7, float('$m7_p'))")
s_qcht2=$(python -c"import scripts.static_mem as sm; sm.tot_hll_qcht(float('$f'), 7, float('$m7_p'))")
tail -3 logs/hll_ddsketch/plot_MAWI1_m6_d1_HLL.txt | \
cat - <(tail -3 logs/hll_ddsketch/plot_MAWI1_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{printf "M1" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 / 1000}' >> plots/memory_hll.dat;
echo -e "\t $s_cht \t $s_qcht \t $s_cht2 \t $s_qcht2 \t $m6_p \t $m7_p" >> plots/memory_hll.dat;

f=$(cat logs/hll_ddsketch/avg_flows.txt | grep "MAWI2" | grep "HLL" | head -1 | awk '{print $5}')
s_cht=$(python -c"import scripts.static_mem as sm; sm.tot_hll_cht(float('$f'), 6, float('$m6_p'))")
s_qcht=$(python -c"import scripts.static_mem as sm; sm.tot_hll_qcht(float('$f'), 6, float('$m6_p'))")
s_cht2=$(python -c"import scripts.static_mem as sm; sm.tot_hll_cht(float('$f'), 7, float('$m7_p'))")
s_qcht2=$(python -c"import scripts.static_mem as sm; sm.tot_hll_qcht(float('$f'), 7, float('$m7_p'))")
tail -3 logs/hll_ddsketch/plot_MAWI2_m6_d1_HLL.txt | \
cat - <(tail -3 logs/hll_ddsketch/plot_MAWI2_m7_d1_HLL.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{printf "M2" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 / 1000}' >> plots/memory_hll.dat;
echo -e "\t $s_cht \t $s_qcht \t $s_cht2 \t $s_qcht2 \t $m6_p \t $m7_p" >> plots/memory_hll.dat;

## DDSketch
rm plots/memory_ddsketch.dat 2> /dev/null
touch plots/memory_ddsketch.dat;
echo "Trace Standard Standard_min Standard_max CHT CHT_min CHT_max qCHT qCHT_min qCHT_max pIBLT pIBLT_min pIBLT_max Standard2 Standard2_min Standard2_max CHT2 CHT2_min CHT2_max qCHT2 qCHT2_min qCHT2_max pIBLT2 pIBLT2_min pIBLT2_max Static_CHT Static_qCHT Static_pIBLT Static2_CHT Static2_qCHT Static2_pIBLT s_p1 s_p2" >> plots/memory_ddsketch.dat;

### worst case static sparsity
m5_p=$(cat logs/hll_ddsketch/avg_sparsities.txt | grep "m5 DDSketch" | awk 'BEGIN{p=   0}{if ($5>0+p) p=$5 fi} END{print p*2}')
m6_p=$(cat logs/hll_ddsketch/avg_sparsities.txt | grep "m6 DDSketch" | awk 'BEGIN{p=   0}{if ($5>0+p) p=$5 fi} END{print p*2}')

f=$(cat logs/hll_ddsketch/avg_flows.txt | grep "CAIDA1" | grep "DDSketch" | head -1 | awk '{print $5}')
s_cht=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_cht(float('$f'), 5, float('$m5_p'))")
s_qcht=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_qcht(float('$f'), 5, float('$m5_p'))")
s_piblt=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_piblt(float('$f'), 5, float('$m5_p'))")
s_cht2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_cht(float('$f'), 6, float('$m6_p'))")
s_qcht2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_qcht(float('$f'), 6, float('$m6_p'))")
s_piblt2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_piblt(float('$f'), 6, float('$m6_p'))")
tail -4 logs/hll_ddsketch/plot_CAIDA1_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/hll_ddsketch/plot_CAIDA1_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{printf "C1" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 /1000 "\t" $33 /1000 "\t" $34 /1000 "\t" $35 /1000 "\t" $38 /1000 "\t" $39 /1000 "\t" $40 / 1000}' >> plots/memory_ddsketch.dat;
echo -e "\t $s_cht \t $s_qcht \t $s_piblt \t $s_cht2 \t $s_qcht2 \t $s_piblt2 \t $m5_p \t $m6_p" >> plots/memory_ddsketch.dat;

f=$(cat logs/hll_ddsketch/avg_flows.txt | grep "CAIDA2" | grep "DDSketch" | head -1 | awk '{print $5}')
s_cht=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_cht(float('$f'), 5, float('$m5_p'))")
s_qcht=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_qcht(float('$f'), 5, float('$m5_p'))")
s_piblt=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_piblt(float('$f'), 5, float('$m5_p'))")
s_cht2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_cht(float('$f'), 6, float('$m6_p'))")
s_qcht2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_qcht(float('$f'), 6, float('$m6_p'))")
s_piblt2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_piblt(float('$f'), 6, float('$m6_p'))")
tail -4 logs/hll_ddsketch/plot_CAIDA2_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/hll_ddsketch/plot_CAIDA2_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{printf "C2" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 /1000 "\t" $33 /1000 "\t" $34 /1000 "\t" $35 /1000 "\t" $38 /1000 "\t" $39 /1000 "\t" $40 / 1000}' >> plots/memory_ddsketch.dat;
echo -e "\t $s_cht \t $s_qcht \t $s_piblt \t $s_cht2 \t $s_qcht2 \t $s_piblt2 \t $m5_p \t $m6_p" >> plots/memory_ddsketch.dat;

f=$(cat logs/hll_ddsketch/avg_flows.txt | grep "MAWI1" | grep "DDSketch" | head -1 | awk '{print $5}')
s_cht=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_cht(float('$f'), 5, float('$m5_p'))")
s_qcht=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_qcht(float('$f'), 5, float('$m5_p'))")
s_piblt=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_piblt(float('$f'), 5, float('$m5_p'))")
s_cht2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_cht(float('$f'), 6, float('$m6_p'))")
s_qcht2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_qcht(float('$f'), 6, float('$m6_p'))")
s_piblt2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_piblt(float('$f'), 6, float('$m6_p'))")
tail -4 logs/hll_ddsketch/plot_MAWI1_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/hll_ddsketch/plot_MAWI1_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{printf "M1" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 /1000 "\t" $33 /1000 "\t" $34 /1000 "\t" $35 /1000 "\t" $38 /1000 "\t" $39 /1000 "\t" $40 / 1000}' >> plots/memory_ddsketch.dat;
echo -e "\t $s_cht \t $s_qcht \t $s_piblt \t $s_cht2 \t $s_qcht2 \t $s_piblt2 \t $m5_p \t $m6_p" >> plots/memory_ddsketch.dat;

f=$(cat logs/hll_ddsketch/avg_flows.txt | grep "MAWI2" | grep "DDSketch" | head -1 | awk '{print $5}')
s_cht=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_cht(float('$f'), 5, float('$m5_p'))")
s_qcht=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_qcht(float('$f'), 5, float('$m5_p'))")
s_piblt=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_piblt(float('$f'), 5, float('$m5_p'))")
s_cht2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_cht(float('$f'), 6, float('$m6_p'))")
s_qcht2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_qcht(float('$f'), 6, float('$m6_p'))")
s_piblt2=$(python -c"import scripts.static_mem as sm; sm.tot_ddsketch_piblt(float('$f'), 6, float('$m6_p'))")
tail -4 logs/hll_ddsketch/plot_MAWI2_m5_d1_DDSketch.txt | \
cat - <(tail -4 logs/hll_ddsketch/plot_MAWI2_m6_d1_DDSketch.txt) | \
tr '\n' '\t' | \
awk -F "\t" '{printf "M2" "\t" $3 /1000 "\t" $4 /1000 "\t" $5 /1000 "\t" $8 /1000 "\t" $9 /1000 "\t" $10 /1000 "\t" $13 /1000 "\t" $14 /1000 "\t" $15 /1000 "\t" $18 /1000 "\t" $19 /1000 "\t" $20 /1000 "\t" $23 /1000 "\t" $24 /1000 "\t" $25 /1000 "\t" $28 /1000 "\t" $29 /1000 "\t" $30 /1000 "\t" $33 /1000 "\t" $34 /1000 "\t" $35 /1000 "\t" $38 /1000 "\t" $39 /1000 "\t" $40 / 1000}' >> plots/memory_ddsketch.dat;
echo -e "\t $s_cht \t $s_qcht \t $s_piblt \t $s_cht2 \t $s_qcht2 \t $s_piblt2 \t $m5_p \t $m6_p" >> plots/memory_ddsketch.dat;

echo "Results parsed.";


# DRAW PLOTS

cd ./plots || exit;
gnuplot memory_hll.gp;
gnuplot memory_ddsketch.gp;

echo "Plots saved.";
