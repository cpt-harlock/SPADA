set terminal pngcairo  transparent enhanced font "DejaVuSans,17" fontscale 1.0 size 600, 400 
set output 'memory_hll.png'

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
set lmargin 6
set rmargin 1

set multiplot layout 1,1

     #set key outside left horizontal Left reverse noenhanced autotitle columnhead nobox  samplen 2
     set key inside left Left reverse samplen 2 font ",17"
     #set key box opaque 

     #set style fill solid 0.5 noborder
     #plot 'memory_hll.dat' using ($0):(1) with boxes lt rgb "grey"

     set xtics ("C1" 2, "C2" 4, "M1" 6, "M2" 8, "C1" 11, "C2" 13, "M1" 15, "M2" 17) offset 0,0.2
     #set xtics ("m=64" 5, "m=128" 15)
     set xrange [ 0 : 19 ]
     #set yrange [ 0 : 4 ]

     set style line 5 lt 1 lc rgb "grey" 


     #set style fill solid
     set boxwidth 0.5

     plot newhistogram "m=64", \
          'memory_hll.dat' using ($0*2+1.5):"Standard" with boxes  lt 1 fs pattern 1 t "Baseline",\
          'memory_hll.dat' using ($0*2+2):"Static_CHT" with boxes lt 1 lw 1 fs solid 0.3 fc '#969696' notitle,\
          'memory_hll.dat' using ($0*2+2.5):"Static_qCHT" with boxes  lt 1 lw 1 fs solid 0.3 fc '#969696' notitle,\
          'memory_hll.dat' using ($0*2+2):"CHT" with boxes  lt 2 fs pattern 2 t "SPADA-CHT",\
          'memory_hll.dat' using ($0*2+2.5):"qCHT" with boxes  lt 4 fs pattern 4 t "SPADA-qCHT",\
          'memory_hll.dat' using ($0*2+1.5):"Standard":"Standard_min":"Standard_max" with yerrorbars lw 2 lt 1 notitle,\
          'memory_hll.dat' using ($0*2+2):"CHT":"CHT_min":"CHT_max" with yerrorbars lw 2 lt 2 notitle,\
          'memory_hll.dat' using ($0*2+2.5):"qCHT":"qCHT_min":"qCHT_max" with yerrorbars lw 2 lt 4 notitle,\
          newhistogram "m=128", \
          'memory_hll.dat' using (9+$0*2+1.5):"Standard2" with boxes  lt 1 fs pattern 1 notitle,\
          'memory_hll.dat' using (9+$0*2+2):"Static2_CHT" with boxes  lt 1 lw 1 fs solid 0.3 fc '#969696' t "static p",\
          'memory_hll.dat' using (9+$0*2+2.5):"Static2_qCHT" with boxes  lt 1 lw 1 fs solid 0.3 fc '#969696' notitle,\
          'memory_hll.dat' using (9+$0*2+2):"CHT2" with boxes  lt 2 fs pattern 2 notitle,\
          'memory_hll.dat' using (9+$0*2+2.5):"qCHT2" with boxes  lt 4 fs pattern 4 notitle,\
          'memory_hll.dat' using (9+$0*2+1.5):"Standard2":"Standard2_min":"Standard2_max" with yerrorbars lw 2 lt 1 notitle,\
          'memory_hll.dat' using (9+$0*2+2):"CHT2":"CHT2_min":"CHT2_max" with yerrorbars lw 2 lt 2 notitle,\
          'memory_hll.dat' using (9+$0*2+2.5):"qCHT2":"qCHT2_min":"qCHT2_max" with yerrorbars lw 2 lt 4 notitle,\

     set xtics norangelimit  font ",17"
     set xtics border in scale 0,0 nomirror norotate autojustify
     set xtics ("m=64" 5, "m=128" 15) offset 0,-1
     set origin 0,0 # This is not needed in version 5.0
     replot

unset multiplot


#'memory_hll.dat' using ($0*2+2):"Static_CHT":(sprintf(" p=%.2f", column("s_p1"))) with labels rotate left font ",8" notitle,\
