set terminal pngcairo  transparent enhanced font "DejaVuSans,17"  fontscale 1.0 size 600, 400 
set output 'fig8.png'
#set border 3 front lt black linewidth 1.000 dashtype solid
set datafile missing '-'
set style data histograms
set xtics border in scale 0,0 nomirror rotate by -45  autojustify
set xtics norangelimit  font ",17"
set xtics   ()
set ytics border in scale 0,0 mirror norotate  autojustify
set ytics  norangelimit autofreq  font ",17"
set ztics border in scale 0,0 nomirror norotate  autojustify
set cbtics border in scale 0,0 mirror norotate  autojustify
set rtics axis in scale 0,0 nomirror norotate  autojustify
set xlabel  offset character 0, -2, 0 font "" textcolor lt -1 norotate
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
set bmargin 4

#set key outside left horizontal Left reverse noenhanced autotitle columnhead nobox  samplen 2
set key inside left Left reverse samplen 1.5
#set key box opaque 

plot \
newhistogram "m=32", 'memory_ddsketch.dat'\
using "Standard":"Standard_min":"Standard_max":xtic(1) t "Baseline" lt 1  fs pattern 1,\
'' u  "CHT":"CHT_min":"CHT_max"  t "SPADA-CHT" lt 2  fs pattern 2,\
'' u  "qCHT":"qCHT_min":"qCHT_max" t "SPADA-qCHT"  lt 4  fs pattern 4,\
'' u  "pIBLT":"pIBLT_min":"pIBLT_max" t "SPADA-pIBLT"  lt 6  fs pattern 6,\
newhistogram "m=64" at 4.2, 'memory_ddsketch.dat'\
using "Standard2":"Standard2_min":"Standard2_max":xtic(1)  not lt 1  fs pattern 1,\
'' u  "CHT2":"CHT2_min":"CHT2_max"  not lt 2  fs pattern 2,\
'' u  "qCHT2":"qCHT2_min":"qCHT2_max" not lt 4  fs pattern 4,\
'' u  "pIBLT2":"pIBLT2_min":"pIBLT2_max" not lt 6  fs pattern 6,\
