#!/bin/bash
# run-fio.sh

#if [[ "$EUID" > 0 ]]; then
#  echo "Please run as root directly"
#  exit 1
#fi

declare FIO_JOB="iometer-file-access-server.fio"
declare START_DATETIME=$(date +%F_%H%M)
declare PLOT_OUTPUT_DIR=gnuplot-${START_DATETIME}
declare FS_TYPE=$(df --output=fstype / | grep -v Type)
declare -a SCHEDULERS=("noop" "deadline")

cd ${HOME}
cp /usr/share/doc/fio/examples/${FIO_JOB} .
echo "per_job_logs=0" >> ${FIO_JOB}
echo "write_bw_log=bw-${START_DATETIME}" >> ${FIO_JOB}
mkdir ${PLOT_OUTPUT_DIR}

sudo -v && for sched in "${SCHEDULERS[@]}"; do
  echo Try setting ${sched} as I/O scheduler
  echo "${sched}" | sudo tee /sys/block/sda/queue/scheduler > /dev/null
  echo Check current scheduler:
  sed -e 's/.*\[\(.*\)\].*/\1/' /sys/block/sda/queue/scheduler
  for testrun in $(seq 0 1); do
    echo Test:"${testrun}" fs:"${FS_TYPE}" scheduler:"${sched}"
    sudo fio ${FIO_JOB} | grep "bw=" | tee -a ${PLOT_OUTPUT_DIR}/fio-average-${START_DATETIME}.log
  done
done

mv bw-${START_DATETIME}* ${PLOT_OUTPUT_DIR}
cd ${PLOT_OUTPUT_DIR};
fio2gnuplot --bandwidth --gnuplot --keep

unset FIO_JOB START_DATETIME PLOT_OUTPUT_DIR FS_TYPE SCHEDULERS
exit 0
