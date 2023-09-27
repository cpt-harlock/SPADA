#!/bin/bash

# HLL

# MAWI 1
cat ../logs/sparsity_MAWI1_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m6 HLL sparsity: " sum / NR }';
cat ../logs/sparsity_MAWI1_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m7 HLL sparsity: " sum / NR }';

# MAWI 2
cat ../logs/sparsity_MAWI2_m6_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m6 HLL sparsity: " sum / NR }';
cat ../logs/sparsity_MAWI2_m7_d1_HLL.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m7 HLL sparsity: " sum / NR }';

# DDSketch

# MAWI 1
cat ../logs/sparsity_MAWI1_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m5 DDSketch sparsity: " sum / NR }';
cat ../logs/sparsity_MAWI1_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI1 m6 DDSketch sparsity: " sum / NR }';

# MAWI 2
cat ../logs/sparsity_MAWI2_m5_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m5 DDSketch sparsity: " sum / NR }';
cat ../logs/sparsity_MAWI2_m6_d1_DDSketch.txt | awk '{ sum += $3 } END { if (NR > 0) print "MAWI2 m6 DDSketch sparsity: " sum / NR }';