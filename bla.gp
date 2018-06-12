stats "fio-average-2018-06-06_1234-ext4-deadline-read.log" using 1:2 nooutput
set style line 2 linewidth 1 linecolor rgb "red"
plot "fio-average-2018-06-06_1234-ext4-deadline-read.log" using 1:2 with linespoints title 'ext4-deadline-read' linestyle 2, \
"fio-average-2018-06-06_1234-ext4-deadline-write.log" using 1:2 with linespoints title 'ext4-deadline-write', \
"fio-average-2018-06-06_1234-ext4-noop-read.log" using 1:2 with linespoints title 'ext4-noop-read', \
"fio-average-2018-06-06_1234-ext4-noop-write.log" using 1:2 with linespoints title 'ext4-noop-write
set title 'Test'
set key outside left box
set ylabel 'Bandwidth in KB/sec'
set pointsize 1.5
#set label 1 sprintf('%.4f', STATS_stddev_y) center at STATS_mean_x,STATS_max_y offset 0,1 textcolor lt 1
set label 1 sprintf('%.4f', STATS_stddev_y) center at STATS_mean_x,STATS_max_y offset 0,1 textcolor linestyle 2

replot
pause -1 "Hit any key to continue"
#fio-average-2018-06-06_1234-ext4-noop-read.log fio-average-2018-06-06_1234-ext4-noop-write.log
