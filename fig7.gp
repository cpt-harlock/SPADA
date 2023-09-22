set terminal pngcairo  transparent enhanced font "arial,14" fontscale 1.0 size 600, 400 
set output 'fig7.png'
set datafile missing '-'
set xtics norangelimit  font ",14"
set xtics   ()
set ytics border in scale 0,0 mirror norotate  autojustify
set ytics  norangelimit autofreq  font ",14"
set xrange [ * : * ] noreverse writeback
set ylabel "Average additional memory \n accesses per packet" 
set xlabel "Epoch"
set key outside left above Left samplen 1 font "arial,14"
set key box 

plot \
'insertions_caida1_m6.dat' using ($5/$3)    t "Caida1 m=64" w lp lt 1 ,\
'insertions_caida1_m7.dat' using ($5/$3)    t "Caida1 m=128" w lp lt 2 ,\
'insertions_caida2_m6.dat' using ($5/$3)    t "Caida2 m=64" w lp lt 3 ,\
'insertions_caida2_m7.dat' using ($5/$3)    t "Caida2 m=128" w lp lt 4 ,\
'insertions_caida3_m6.dat' using ($5/$3)    t "Caida3 m=64" w lp lt 5 ,\
'insertions_caida3_m7.dat' using ($5/$3)    t "Caida3 m=128" w lp lt 6 ,\

