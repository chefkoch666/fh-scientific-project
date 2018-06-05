plot "fio-average-2018-06-05_1901-ext4-deadline-read.log" using 1:2 notitle
set title 'Test'
set ylabel 'Bandwidth in KB/sec'
set xrange [0:3]
set pointsize 1.5
replot
pause -1 "Hit any key to continue"
