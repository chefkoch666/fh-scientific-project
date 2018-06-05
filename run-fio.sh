#!/bin/bash
# run-fio.sh

sudo -v
sudo apt-get install fio -y &> /dev/null

declare FIO_JOB="iometer-file-access-server.fio"
declare START_DATETIME=$(date +%F_%H%M)
declare PLOT_OUTPUT_DIR=${HOME}/gnuplot-${START_DATETIME}
declare -a FS_TYPE=("ext4" "xfs")
declare -a SCHEDULERS=("noop" "deadline")

cd ${HOME}
cp /usr/share/doc/fio/examples/${FIO_JOB} .
echo "per_job_logs=0" >> ${FIO_JOB}
echo "write_bw_log=bw-${START_DATETIME}" >> ${FIO_JOB}
mkdir ${PLOT_OUTPUT_DIR}

#sudo -v && for sched in "${SCHEDULERS[@]}"; do
#  echo Try setting ${sched} as I/O scheduler
#  echo "${sched}" | sudo tee /sys/block/sda/queue/scheduler > /dev/null
#  echo Check current scheduler:
#  sed -e 's/.*\[\(.*\)\].*/\1/' /sys/block/sda/queue/scheduler
#  for testrun in $(seq 0 1); do
#    echo Test:"${testrun}" fs:"${FS_TYPE}" scheduler:"${sched}"
#    sudo fio ${FIO_JOB} | grep "bw=" | tee -a ${PLOT_OUTPUT_DIR}/fio-average-${START_DATETIME}.log
#  done
#done

#sudo -v && for fs in "${FS_TYPE[@]}"; do
for fs in "${FS_TYPE[@]}"; do
  if [[ ${fs} == "xfs" ]]; then
    cd /mnt/
  fi
  for sched in "${SCHEDULERS[@]}"; do
#    echo Try setting ${sched} as I/O scheduler
    echo "${sched}" | sudo tee /sys/block/sda/queue/scheduler > /dev/null
    echo -n "Current scheduler was just changed to : "
    sed -e 's/.*\[\(.*\)\].*/\1/' /sys/block/sda/queue/scheduler
    for testrun in $(seq 0 1); do
      echo Test:"${testrun}" fs:"${fs}" scheduler:"${sched}"
      sudo fio ${HOME}/${FIO_JOB} | grep "bw=" | tee -a ${PLOT_OUTPUT_DIR}/fio-average-${START_DATETIME}-${fs}-${sched}.log
    done
  done
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
