set terminal pngcairo  transparent enhanced font "DejaVuSans,17" fontscale 1.0 size 600, 400 
set output 'memory_es.png'

# set datafile missing '-'
set style data histograms
set xtics border in scale 0,0 nomirror norotate  autojustify
set xtics norangelimit  font ",17"
set xtics   ()
set ytics border in scale 0,0 mirror norotate  autojustify
set ytics  norangelimit autofreq  font ",17"
set ztics border in scale 0,0 nomirror norotate  autojustify
set cbtics border in scale 0,0 mirror norotate  autojustify
set rtics axis in scale 0,0 nomirror norotate  autojustify
set xlabel offset character 0, -2, 0 font "" textcolor lt -1 norotate 
set xlabel offset 0,0.9
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback
set ylabel "Memory occupation [MB]" offset 1.5
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
set style histogram clustered gap 1 title offset 0,-1
set style histogram errorbars linewidth 3 
set tmargin 0.5
set bmargin 2.5
set lmargin 7
set rmargin 1


#set key outside left horizontal Left reverse noenhanced autotitle columnhead nobox  samplen 2
set key inside left Left reverse samplen 2 font ",17"
#set key box opaque 

#set style fill solid 0.5 noborder
#plot 'memory_hll.dat' using ($0):(1) with boxes lt rgb "grey"

set xtics ("C1" 2, "C2" 4, "M1" 6, "M2" 8) offset 0,0.2
#set xtics ("m=64" 5, "m=128" 15)
set xrange [ 0.5 : 9.5 ]
set yrange [ 0.200 : 1.200 ]

set style line 5 lt 1 lc rgb "grey" 


#set style fill solid
set boxwidth 0.5

plot newhistogram "ES", \
     'memory_es.dat' using ($0*2+1.5):"Standard" with boxes  lt 1 fs pattern 1 t "Baseline \(m=512K\)",\
     'memory_es.dat' using ($0*2+2):"Static_qCHT" with boxes lt 1 lw 1 fs solid 0.3 fc '#969696' notitle,\
     'memory_es.dat' using ($0*2+2.5):"Static_qCHT_sparser" with boxes  lt 1 lw 1 fs solid 0.3 fc '#969696' notitle,\
     'memory_es.dat' using ($0*2+2):"qCHT" with boxes  lt 4 fs pattern 4 t "SPADA-ES \(m=512K\)",\
     'memory_es.dat' using ($0*2+2.5):"qCHT_sparser" with boxes  lt 4 fs pattern 3 t "SPADA-ES \(m=4M\)",\
     'memory_es.dat' using ($0*2+2):"qCHT":"qCHT_min":"qCHT_max" with yerrorbars lw 2 lt 1 notitle,\
     'memory_es.dat' using ($0*2+2.5):"qCHT_sparser":"qCHT_sparser_min":"qCHT_sparser_max" with yerrorbars lw 2 lt 1 notitle,\
     keyentry with boxes lt 1 lw 1 fs solid 0.3 fc '#969696' t "static p (double of worst observed)",\


unset multiplot


#       Memory    occupancy     (in           KB)         of              the             different  solutions           
#Trace Standard Standard_min Standard_max CHT CHT_min CHT_max qCHT qCHT_min qCHT_max Standard2 Standard2_min Standard2_max CHT2 CHT2_min CHT2_max qCHT2 qCHT2_min qCHT2_max
#C1  1556 1531 1588 291 286 298 213 210 218 2971 2924 3033 302 297 308 221 218 226 
#C2  1503 1411 1534 274 258 280 202 190 207 2870 2694 2929 282 265 287 209 196 213 
#C3  485  299  504 111  65 116  76  45  79  926  571  963 118  69 123  80  48  84 
#C1	1.556	1.531	1.588	.320	.315	.328	.234	.231	.240	2.971	2.924	3.033	.332	.327	.339	.243	.240	.249
#C2	1.503	1.411	1.534	.301	.284	.308	.222	.209	.228	2.870	2.694	2.929	.310	.292	.316	.230	.216	.234
#C3	.485	.299	.504	.122	.072	.128	.084	.050	.087	.926	.571	.963	.130	.076	.135	.088	.053	.092
#

# plot \
# newhistogram "m=64", 'memory_hll.dat'\
# using "Standard":"Standard_min":"Standard_max":xtic(1) t "Baseline" lt 1  fs pattern 1,\
# '' u  "CHT":"CHT_min":"CHT_max"  t "SPADA-CHT" lt 2  fs pattern 2,\
# '' u  "qCHT":"qCHT_min":"qCHT_max" t "SPADA-qCHT"  lt 4  fs pattern 4,\
# newhistogram "m=128", 'memory_hll.dat'\
# using "Standard2":"Standard2_min":"Standard2_max":xtic(1)  not lt 1  fs pattern 1,\
# '' u  "CHT2":"CHT2_min":"CHT2_max"  not lt 2  fs pattern 2,\
# '' u  "qCHT2":"qCHT2_min":"qCHT2_max" not lt 4  fs pattern 4,\


