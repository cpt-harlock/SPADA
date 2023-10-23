#!/bin/bash

# This script runs HLL recirculation simulations for m = 64 and m = 128
# on CAIDA and MAWI traces and plots two figures. 

# Usage:
# Traces are supposed to be in a directory ./traces/<mawi/caida>/<CAIDA1|CAIDA2|MAWI1|MAWI2>.pcap
# From the root directory:
# $ cargo build
# $ ./scripts/run_recirculation.sh


rm -r ./logs/recirculation 2> /dev/null
mkdir ./logs/recirculation

rm ./plots/recirculation_overall.dat 2> /dev/null
rm ./plots/recirculation_worst_case.dat 2> /dev/null


# Run a first series of simulations to pre-compute the appropriate number of CHT rows
echo "Pre-computing the number of rows to reach 90% load factor...";

## MAWI

### HLL m = 64
(
    ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 | \
    grep "Overprovisioned"  | \
    awk '{printf("%s\n", $0) > "logs/recirculation/nrows_MAWI1_m6_d1_HLL.txt"}';
) &
(
    ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 60.0 | \
    grep "Overprovisioned"  | \
    awk '{printf("%s\n", $0) > "logs/recirculation/nrows_MAWI2_m6_d1_HLL.txt"}';
) &

### HLL m = 128
(
    ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 60.0 | \
    grep "Overprovisioned"  | \
    awk '{printf("%s\n", $0) > "logs/recirculation/nrows_MAWI1_m7_d1_HLL.txt"}';
) &
(
    ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 60.0 | \
    grep "Overprovisioned"  | \
    awk '{printf("%s\n", $0) > "logs/recirculation/nrows_MAWI2_m7_d1_HLL.txt"}';
) &

## CAIDA

### HLL m = 64
(
    ./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 | \
    grep "Overprovisioned"  | \
    awk '{printf("%s\n", $0) > "logs/recirculation/nrows_CAIDA1_m6_d1_HLL.txt"}';
) &
(
    ./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 6 -d 1 -e 1.0 | \
    grep "Overprovisioned"  | \
    awk '{printf("%s\n", $0) > "logs/recirculation/nrows_CAIDA2_m6_d1_HLL.txt"}';
) &

### HLL m = 128
(
    ./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 1.0 | \
    grep "Overprovisioned"  | \
    awk '{printf("%s\n", $0) > "logs/recirculation/nrows_CAIDA1_m7_d1_HLL.txt"}';
) &
(
    ./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r 1048576 -m 7 -d 1 -e 1.0 | \
    grep "Overprovisioned"  | \
    awk '{printf("%s\n", $0) > "logs/recirculation/nrows_CAIDA2_m7_d1_HLL.txt"}';
) &

wait;

# Parse results to compute CHT number of rows for each configuration

nrows_mawi1_m6_d1=$(cat ./logs/recirculation/nrows_MAWI1_m6_d1_HLL.txt | awk '{ sum += $6 } END { if (NR > 0) print int(sum / NR) }');
echo "- MAWI1 m6 HLL nrows for 90% load factor: $nrows_mawi1_m6_d1";
nrows_mawi2_m6_d1=$(cat ./logs/recirculation/nrows_MAWI2_m6_d1_HLL.txt | awk '{ sum += $6 } END { if (NR > 0) print int(sum / NR) }');
echo "- MAWI2 m6 HLL nrows for 90% load factor: $nrows_mawi2_m6_d1";
nrows_mawi1_m7_d1=$(cat ./logs/recirculation/nrows_MAWI1_m7_d1_HLL.txt | awk '{ sum += $6 } END { if (NR > 0) print int(sum / NR) }');
echo "- MAWI1 m7 HLL nrows for 90% load factor: $nrows_mawi1_m7_d1";
nrows_mawi2_m7_d1=$(cat ./logs/recirculation/nrows_MAWI2_m7_d1_HLL.txt | awk '{ sum += $6 } END { if (NR > 0) print int(sum / NR) }');
echo "- MAWI2 m7 HLL nrows for 90% load factor: $nrows_mawi2_m7_d1";
nrows_caida1_m6_d1=$(cat ./logs/recirculation/nrows_CAIDA1_m6_d1_HLL.txt | awk '{ sum += $6 } END { if (NR > 0) print int(sum / NR) }');
echo "- CAIDA1 m6 HLL nrows for 90% load factor: $nrows_caida1_m6_d1";
nrows_caida2_m6_d1=$(cat ./logs/recirculation/nrows_CAIDA2_m6_d1_HLL.txt | awk '{ sum += $6 } END { if (NR > 0) print int(sum / NR) }');
echo "- CAIDA2 m6 HLL nrows for 90% load factor: $nrows_caida2_m6_d1";
nrows_caida1_m7_d1=$(cat ./logs/recirculation/nrows_CAIDA1_m7_d1_HLL.txt | awk '{ sum += $6 } END { if (NR > 0) print int(sum / NR) }');
echo "- CAIDA1 m7 HLL nrows for 90% load factor: $nrows_caida1_m7_d1";
nrows_caida2_m7_d1=$(cat ./logs/recirculation/nrows_CAIDA2_m7_d1_HLL.txt | awk '{ sum += $6 } END { if (NR > 0) print int(sum / NR) }');
echo "- CAIDA2 m7 HLL nrows for 90% load factor: $nrows_caida2_m7_d1";


# Run actual recirculation simulations
echo "Running recirculation simulations with 90% load factor...";

## MAWI

### HLL m = 64
(
    ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r $nrows_mawi1_m6_d1 -m 6 -d 1 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI1_m6_d1_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI1_m6_d1_HLL.txt"}}';
) &
(
    nrows_mawi1_m6_d2=$(awk -v var=$nrows_mawi1_m6_d1 'BEGIN { print int(var / 2) + 1}');
    ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r $nrows_mawi1_m6_d2 -m 6 -d 2 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI1_m6_d2_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI1_m6_d2_HLL.txt"}}';
) &
(
    nrows_mawi1_m6_d4=$(awk -v var=$nrows_mawi1_m6_d1 'BEGIN { print int(var / 4) + 3}');
    ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r $nrows_mawi1_m6_d4 -m 6 -d 4 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI1_m6_d4_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI1_m6_d4_HLL.txt"}}';
) &
(
    ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r $nrows_mawi2_m6_d1 -m 6 -d 1 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI2_m6_d1_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI2_m6_d1_HLL.txt"}}';
) &
(
    nrows_mawi2_m6_d2=$(awk -v var=$nrows_mawi2_m6_d1 'BEGIN { print int(var / 2) + 1}');
    ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r $nrows_mawi2_m6_d2 -m 6 -d 2 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI2_m6_d2_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI2_m6_d2_HLL.txt"}}';
) &
(
    nrows_mawi2_m6_d4=$(awk -v var=$nrows_mawi2_m6_d1 'BEGIN { print int(var / 4) + 3}');
    ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r $nrows_mawi2_m6_d4 -m 6 -d 4 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI2_m6_d4_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI2_m6_d4_HLL.txt"}}';
) &
wait

### HLL m = 128
(
    ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r $nrows_mawi1_m7_d1 -m 7 -d 1 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI1_m7_d1_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI1_m7_d1_HLL.txt"}}';
) &
(
    nrows_mawi1_m7_d2=$(awk -v var=$nrows_mawi1_m7_d1 'BEGIN { print int(var / 2) + 1}');
    ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r $nrows_mawi1_m7_d2 -m 7 -d 2 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI1_m7_d2_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI1_m7_d2_HLL.txt"}}';
) &
(
    nrows_mawi1_m7_d4=$(awk -v var=$nrows_mawi1_m7_d1 'BEGIN { print int(var / 4) + 3}');
    ./target/debug/spada -f ./traces/mawi/MAWI1.pcap -t 4 -s 1 -r $nrows_mawi1_m7_d4 -m 7 -d 4 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI1_m7_d4_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI1_m7_d4_HLL.txt"}}';
) &
(
    ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r $nrows_mawi2_m7_d1 -m 7 -d 1 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI2_m7_d1_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI2_m7_d1_HLL.txt"}}';
) &
(
    nrows_mawi2_m7_d2=$(awk -v var=$nrows_mawi2_m7_d1 'BEGIN { print int(var / 2) + 1}');
    ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r $nrows_mawi2_m7_d2 -m 7 -d 2 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI2_m7_d2_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI2_m7_d2_HLL.txt"}}';
) &
(
    nrows_mawi2_m7_d4=$(awk -v var=$nrows_mawi2_m7_d1 'BEGIN { print int(var / 4) + 3}');
    ./target/debug/spada -f ./traces/mawi/MAWI2.pcap -t 4 -s 1 -r $nrows_mawi2_m7_d4 -m 7 -d 4 -e 60.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_MAWI2_m7_d4_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_MAWI2_m7_d4_HLL.txt"}}';
) &
wait

## CAIDA

### HLL m = 64
(
    ./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r $nrows_caida1_m6_d1 -m 6 -d 1 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA1_m6_d1_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA1_m6_d1_HLL.txt"}}';
) &
(
    nrows_caida1_m6_d2=$(awk -v var=$nrows_caida1_m6_d1 'BEGIN { print int(var / 2) + 1}');
    ./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r $nrows_caida1_m6_d2 -m 6 -d 2 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA1_m6_d2_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA1_m6_d2_HLL.txt"}}';
) &
(
    nrows_caida1_m6_d4=$(awk -v var=$nrows_caida1_m6_d1 'BEGIN { print int(var / 4) + 3}');
    ./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r $nrows_caida1_m6_d4 -m 6 -d 4 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA1_m6_d4_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA1_m6_d4_HLL.txt"}}';
) &
(
    ./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r $nrows_caida2_m6_d1 -m 6 -d 1 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA2_m6_d1_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA2_m6_d1_HLL.txt"}}';
) &
(
    nrows_caida2_m6_d2=$(awk -v var=$nrows_caida2_m6_d1 'BEGIN { print int(var / 2) + 1}');
    ./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r $nrows_caida2_m6_d2 -m 6 -d 2 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA2_m6_d2_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA2_m6_d2_HLL.txt"}}';
) &
(
    nrows_caida2_m6_d4=$(awk -v var=$nrows_caida2_m6_d1 'BEGIN { print int(var / 4) + 3}');
    ./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r $nrows_caida2_m6_d4 -m 6 -d 4 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA2_m6_d4_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA2_m6_d4_HLL.txt"}}';
) &
wait

### HLL m = 128
(
    ./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r $nrows_caida1_m7_d1 -m 7 -d 1 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA1_m7_d1_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA1_m7_d1_HLL.txt"}}';
) &
(
    nrows_caida1_m7_d2=$(awk -v var=$nrows_caida1_m7_d1 'BEGIN { print int(var / 2) + 1}');
    ./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r $nrows_caida1_m7_d2 -m 7 -d 2 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA1_m7_d2_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA1_m7_d2_HLL.txt"}}';
) &
(
    nrows_caida1_m7_d4=$(awk -v var=$nrows_caida1_m7_d1 'BEGIN { print int(var / 4) + 3}');
    ./target/debug/spada -f ./traces/caida/CAIDA1.pcap -t 4 -s 1 -r $nrows_caida1_m7_d4 -m 7 -d 4 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA1_m7_d4_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA1_m7_d4_HLL.txt"}}';
) &
(
    ./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r $nrows_caida2_m7_d1 -m 7 -d 1 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA2_m7_d1_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA2_m7_d1_HLL.txt"}}';
) &
(
    nrows_caida2_m7_d2=$(awk -v var=$nrows_caida2_m7_d1 'BEGIN { print int(var / 2) + 1}');
    ./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r $nrows_caida2_m7_d2 -m 7 -d 2 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA2_m7_d2_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA2_m7_d2_HLL.txt"}}';
) &
(
    nrows_caida2_m7_d4=$(awk -v var=$nrows_caida2_m7_d1 'BEGIN { print int(var / 4) + 3}');
    ./target/debug/spada -f ./traces/caida/CAIDA2.pcap -t 4 -s 1 -r $nrows_caida2_m7_d4 -m 7 -d 4 -e 1.0 | \
    egrep "loads|stat" | \
    awk '{if ($0 ~ /loads/) {printf("%s\n", $0) > "logs/recirculation/load_CAIDA2_m7_d4_HLL.txt"} else if ($0 ~ /stat/) {printf("%s\n", $0) > "logs/recirculation/stats_CAIDA2_m7_d4_HLL.txt"}}';
) &
wait;

echo "Simulations completed.";


# Parse simulation results
touch ./plots/recirculation_overall.dat;
echo "Trace Datapath1m32 Datapath1m64 Datapath2m32 Datapath2m64 Datapath4m32 Datapath4m64" >> ./plots/recirculation_overall.dat;

## MAWI
tail -1 logs/recirculation/stats_MAWI1_m6_d1_HLL.txt | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m7_d1_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m6_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m7_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m6_d4_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m7_d4_HLL.txt) | tr '\n' '\t' | \
awk -F "\t" '{print "M1" "\t" $4  "\t" $10  "\t" $16  "\t" $22  "\t" $28  "\t" $34}' >> plots/recirculation_overall.dat;

tail -1 logs/recirculation/stats_MAWI2_m6_d1_HLL.txt | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m7_d1_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m6_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m7_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m6_d4_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m7_d4_HLL.txt) | tr '\n' '\t' | \
awk -F "\t" '{print "M2" "\t" $4  "\t" $10  "\t" $16  "\t" $22  "\t" $28  "\t" $34}' >> plots/recirculation_overall.dat;

## CAIDA
tail -1 logs/recirculation/stats_CAIDA1_m6_d1_HLL.txt | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m7_d1_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m6_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m7_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m6_d4_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m7_d4_HLL.txt) | tr '\n' '\t' | \
awk -F "\t" '{print "C1" "\t" $4  "\t" $10  "\t" $16  "\t" $22  "\t" $28  "\t" $34}' >> plots/recirculation_overall.dat;

tail -1 logs/recirculation/stats_CAIDA2_m6_d1_HLL.txt | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m7_d1_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m6_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m7_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m6_d4_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m7_d4_HLL.txt) | tr '\n' '\t' | \
awk -F "\t" '{print "C2" "\t" $4  "\t" $10  "\t" $16  "\t" $22  "\t" $28  "\t" $34}' >> plots/recirculation_overall.dat;

touch ./plots/recirculation_worst_case.dat;
echo "Trace Datapath1m32 Datapath1m64 Datapath2m32 Datapath2m64 Datapath4m32 Datapath4m64" >> ./plots/recirculation_worst_case.dat;

## MAWI
tail -1 logs/recirculation/stats_MAWI1_m6_d1_HLL.txt | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m7_d1_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m6_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m7_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m6_d4_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI1_m7_d4_HLL.txt) | tr '\n' '\t' | \
awk -F "\t" '{print "M1" "\t" $5  "\t" $11  "\t" $17  "\t" $23  "\t" $29  "\t" $35}' >> plots/recirculation_worst_case.dat;

tail -1 logs/recirculation/stats_MAWI2_m6_d1_HLL.txt | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m7_d1_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m6_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m7_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m6_d4_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_MAWI2_m7_d4_HLL.txt) | tr '\n' '\t' | \
awk -F "\t" '{print "M2" "\t" $5  "\t" $11  "\t" $17  "\t" $23  "\t" $29  "\t" $35}' >> plots/recirculation_worst_case.dat;

## CAIDA
tail -1 logs/recirculation/stats_CAIDA1_m6_d1_HLL.txt | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m7_d1_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m6_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m7_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m6_d4_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA1_m7_d4_HLL.txt) | tr '\n' '\t' | \
awk -F "\t" '{print "C1" "\t" $5  "\t" $11  "\t" $17  "\t" $23  "\t" $29  "\t" $35}' >> plots/recirculation_worst_case.dat;

tail -1 logs/recirculation/stats_CAIDA2_m6_d1_HLL.txt | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m7_d1_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m6_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m7_d2_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m6_d4_HLL.txt) | tr '\n' '\t' | \
cat - <(tail -1 logs/recirculation/stats_CAIDA2_m7_d4_HLL.txt) | tr '\n' '\t' | \
awk -F "\t" '{print "C2" "\t" $5  "\t" $11  "\t" $17  "\t" $23  "\t" $29  "\t" $35}' >> plots/recirculation_worst_case.dat;

echo "Results parsed.";


# Plot results

cd ./plots || exit;
gnuplot recirculation_overall.gp;
gnuplot recirculation_worst_case.gp;

echo "Plots saved.";
