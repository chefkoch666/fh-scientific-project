plot "fio-average-2018-06-06_1234-ext4-deadline-read.log" using 1:2 with linespoints title 'ext4-deadline-read', \
"fio-average-2018-06-06_1234-ext4-deadline-write.log" using 1:2 with linespoints title 'ext4-deadline-write', \
"fio-average-2018-06-06_1234-ext4-noop-read.log" using 1:2 with linespoints title 'ext4-noop-read', \
"fio-average-2018-06-06_1234-ext4-noop-write.log" using 1:2 with linespoints title 'ext4-noop-write
set title 'Test'
set key outside left box
set ylabel 'Bandwidth in KB/sec'
set pointsize 1.5
replot
pause -1 "Hit any key to continue"
#fio-average-2018-06-06_1234-ext4-noop-read.log fio-average-2018-06-06_1234-ext4-noop-write.log
