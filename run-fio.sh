#!/bin/bash
# run-fio.sh

sudo -v
sudo apt-get install fio -y &> /dev/null

declare FIO_JOB="iometer-file-access-server.fio"
declare START_DATETIME=$(date +%F_%H%M)
declare PLOT_OUTPUT_DIR=${HOME}/gnuplot-${START_DATETIME}
declare -a FS_TYPE=("ext4" "xfs")
declare -a SCHEDULERS=("noop" "deadline")
declare TIMES_TO_RUN=10

cd ${HOME}
cp /usr/share/doc/fio/examples/${FIO_JOB} .
echo "per_job_logs=0" >> ${FIO_JOB}
echo "write_bw_log=bw-${START_DATETIME}" >> ${FIO_JOB}
mkdir ${PLOT_OUTPUT_DIR}

for fs in "${FS_TYPE[@]}"; do
  if [[ ${fs} == "xfs" ]]; then
    cd /mnt/
  fi
  for sched in "${SCHEDULERS[@]}"; do
    if [[ ${fs} == "ext4" ]]; then
      echo "${sched}" | sudo tee /sys/block/sda/queue/scheduler > /dev/null
    else
      echo "${sched}" | sudo tee /sys/block/sdc/queue/scheduler > /dev/null
    fi
    for testrun in $(seq 1 ${TIMES_TO_RUN}); do
      echo -ne "\r\e[KMeasurement ${testrun} of ${TIMES_TO_RUN} fs:${fs} scheduler:${sched}"
      sudo fio ${HOME}/${FIO_JOB} | grep "bw=" >> ${PLOT_OUTPUT_DIR}/${fs}-${sched}.log
    done
  done
done

echo ""

# prepare data for plotting
cd ${PLOT_OUTPUT_DIR}
for logfile in $(ls -1); do
  readlog=$(basename ${logfile} .log)-read.log
  writelog=$(basename ${logfile} .log)-write.log
  echo "no $(basename ${logfile} .log)" > ${readlog}
  echo "no $(basename ${logfile} .log)" > ${writelog}
  grep read ${logfile} | sed -e 's/.*\(bw=\)\(.*\)KB.*/\2/' >> ${readlog}
  grep write ${logfile} | sed -e 's/.*\(bw=\)\(.*\)KB.*/\2/' >> ${writelog}
done


#mv bw-${START_DATETIME}* ${PLOT_OUTPUT_DIR}
#cd ${PLOT_OUTPUT_DIR};

# run gnuplot only in KVM guest environment
lsmod | egrep "(kvm|vbox)" >/dev/null
if [[ "$?" -eq "1" ]]; then
  fio2gnuplot --bandwidth --gnuplot --keep
fi

unset FIO_JOB START_DATETIME PLOT_OUTPUT_DIR FS_TYPE SCHEDULERS
exit 0
