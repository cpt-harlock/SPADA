set terminal pngcairo  enhanced font "DejaVuSans,17" fontscale 1.0 size 600, 350 
set output 'latency2.png'
set datafile missing '-'

set tics scale 0.5

set ytics auto 

#set mytics 5
set grid y lt 0 dashtype solid

set key inside left Left reverse font "DejaVuSans,16"


#set logscale y
set xrange [ 60 : 89.5 ] noreverse writeback

set key title "Insertion rate" font "DejaVuSans,16"
set key width -12

set tmargin 0.5
set lmargin 6.5
set rmargin 7.2

#set format x " "
#set multiplot layout 2,1 rowsfirst \
#			  margins 0.12,0.97,0.17,0.97 \
#              spacing 0.01,0.03
set ylabel "Latency [#clk]" offset 1.3,0
#set y2label "Latency [ms]" offset 0.2,0
set xlabel "Load factor [%]" offset 0,0.3

set y2tics 20 nomirror tc lt 0 offset -0.7,0
set y2label 'Latency [ns]' tc lt 0 offset -1.9,0

set xtics add ("\ 90" 89.5)

set yrange [20:210] 
set ytics 0,50,250
set y2range [20*5:210*5]
set y2tics 0,250,250*5


plot 'fpga_latency_2/latency_results_key_every_1_pkts.dat' index 1 using ($1*100):2 t '1 every 1 pkts' w l lt 1 lc 6 lw 2, \
	 'fpga_latency_2/latency_results_key_every_3_pkts.dat' index 1 using ($1*100):2 t '1 every 3 pkts' w l ls 2 lw 2, \
	 'fpga_latency_2/latency_results_key_every_5_pkts.dat' index 1 using ($1*100):2 t '1 every 5 pkts' w l ls 3 lw 2, \
	 'fpga_latency_2/latency_results_key_every_10_pkts.dat' index 1 using ($1*100):2 t '1 every 10 pkts' w l ls 4 lw 2, \
	 'fpga_latency_2/latency_results_key_every_20_pkts.dat' index 1 using ($1*100):2 t '1 every 20 pkts' w l ls 5 lw 2
	

#set label "Recirculation Rate [%]" at graph -0.21,0.2 rotate by 90
