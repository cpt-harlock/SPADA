set terminal pngcairo enhanced font "DejaVuSans,17"  fontscale 1.0 size 600, 400 
set output 'fig10c.png'
#set border 3 front lt black linewidth 1.000 dashtype solid
set datafile missing '-'
set style data histograms
set xtics border in scale 0,0 nomirror rotate by -45  autojustify offset -0.7,0
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
set ylabel "Recirculation rate [%]" offset 1.5
set yrange [ 0 : 22 ] noreverse writeback
set y2range [ * : * ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
set style histogram clustered gap 1 title offset 0,-1
#set style histogram errorbars linewidth 3 
set bmargin 4

#set key outside left horizontal Left reverse noenhanced autotitle columnhead nobox  samplen 2
set key inside left Left reverse samplen 1.5
#set key box opaque 
set margins 5, 0.2, 2.7, 0.1

plot \
newhistogram "m=64", 'recirculation_worstcase.dat'\
using "Datapath1m32":xtic(1) t "1 datapath" lt 3 lc 6 fs pattern 1,\
'' u "Datapath2m32":xtic(1) t "2 datapaths" lt 5 lc 4 fs pattern 2,\
'' u "Datapath4m32":xtic(1) t "4 datapaths" lt 6 lc 2 fs pattern 4,\
newhistogram "m=128" at 4.2, 'recirculation_worstcase.dat'\
using "Datapath1m64":xtic(1) not lt 3 lc 6 fs pattern 1,\
'' u "Datapath2m64":xtic(1) not lt 5 lc 4 fs pattern 2,\
'' u "Datapath4m64":xtic(1) not lt 6 lc 2 fs pattern 4,\
