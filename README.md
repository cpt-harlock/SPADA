## SPADA: A Sparse Approximate Data Structure representation for data plane per-flow monitoring

This repository contains the simulator code used to evaluate the SPADA paradigm for data plane monitoring systems in the
research paper [SPADA: A Sparse Approximate Data Structure representation for data plane per-flow monitoring]().
SPADA consists of a compact encoding of monitoring data structures in the data plane: due to the skewed nature of 
network traffic, such data structures are, in practice, heavily underutilized, thus wasting a significant amount of
memory. The main idea od SPADA is to replace full sketches with a series of non-zero counters, hence dynamically 
adjusting the memory footprint of each (virtual) sketch to the actual skewness of the flow(s) monitored using that 
sketch.

### Network Traces

The system is evaluated using four network traces (extracted from the MAWI and CAIDA datasets). Before running the 
simulation, please ensure to properly place ``CAIDA1.pcap``, ``CAIDA2.pcap``, ``MAWI1.pcap`` and ``MAWI2.pcap`` under 
the [traces/caida/]() and [traces/mawi/]() folders respectively.

### Compile the simulator

the simulator is written in the Rust language. Please [install Rust](https://www.rust-lang.org/tools/install)
on your machine, then compile the code with the command

```shell
$ cargo build
```

### Memory footprint simulation

Script [scripts/run_hll_ddsketch.sh](scripts/run_hll_ddsketch.sh) runs the monitoring pipeline in multiple settings for
two sketch use cases (HLL and DDSketch). Each use case is evaluated for two different (virtual) sketch size, which is 
related to their measurement accuracy, and over four network traces. 

To run the simulation, just launch the script from the root folder:

```shell
$ ./scripts/run_hll_ddsketch.sh
```

The simulation outputs memory requirements for different implementation of SPADA and compares them with a baseline where
monitoring data is stored in the traditional form of plain sketches. Simulation raw results are stored at 
[logs/hll_ddsketch](logs/hll_ddsketch), while final metrics are exported under the [plots](plots) directory in the form 
of two figures [memory_hll.png](plots/memory_hll.png) and [memory_ddsketch.png](plots/memory_ddsketch.png) together with
their respective data files. The folder also contains source ``gnuplot`` files used to generate these pictures.

### Recirculation simulation

Script [scripts/run_recirculation.sh](scripts/run_recirculation.sh) runs multiple configurations of the HLL use case 
evaluating the system overhead due to recirculations occurring when the overall sketch load is high. In particular, it 
sizes the system based on the input trace so that 90% of buckets are used, then evaluates the recirculation ratio both
in general (overall recirculation rate) and restricting solely to the case when the load is actually 90% (worst case 
recirculation rate). 

To run the simulation, just launch the script from the root folder:

```shell
$ ./scripts/run_recirculation.sh
```

The simulation outputs observed recirculation rates using three different pipeline configuration in terms of parallel
number of datapaths (1, 2, and 4 datapaths with a common stash recirculating at the same time in a batch fashion). 
Raw results are stored at [logs/recirculation](logs/recirculation), while final metrics are exported under the 
[plots](plots) directory in the form of two figures [recirculation_overall.png](plots/recirculation_overall.png) and 
[recirculation_worst_case.png](plots/recirculation_worst_case.png) together with their respective data. The folder
also contains source ``gnuplot`` files used to generate these pictures.


### References
For details about SPADA, please refer to the following research paper. We kindly ask you to cite it should you use SPADA 
in your work.
- Monterubbiano A., Azorin R., Castellano G., Gallo M., Pontarelli S., Rossi D., [SPADA: A Sparse Approximate Data 
Structure representation for data plane per-flow monitoring](). In ACM CoNext 2023 (Proceedings of the ACM on Networking
(PACMNET)).
