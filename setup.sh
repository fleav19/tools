#!/bin/bash 
# printf '%dh:%dm:%ds\n' $((secs/3600)) $((secs%3600/60)) $((secs%60))


humanReadableDowntime=$(printf '%dh:%dm:%ds\n' $((downtime_p/3600)) $((downtime_p%3600/60)) $((downtime_p%60)))
echo $humanReadableDowntime

echo $HOME
INSTALL_DIR=$HOME/.nb/tools/CXMonitor/code
OUTPUT_DIR=$HOME/.nb/tools/CXMonitor/output
#improve to accept users directory

if [ ! -d ${INSTALL_DIR} ]; then
  echo "CX Monitor isntalled in...${INSTALL_DIR}"
  mkdir -p "${INSTALL_DIR}"
else
  echo "Looks like tool is already installed. Delete directory '${INSTALL_DIR} and try again to re-install"
#   echo "....looks like tool already exists. Run with '-up' to upgrade. (Delete and reinstall)"
fi

if [ ! -d ${OUTPUT_DIR} ]; then
  mkdir -p "${OUTPUT_DIR}"
fi
if [ ! -d ${OUTPUT_DIR}/metadata ]; then
  mkdir -p "${OUTPUT_DIR}/metadata"
fi

cp cx_monitor.sh ${INSTALL_DIR}/cx_monitor.sh

echo "done"

INTSALL_HELPER=$INSTALL_DIR/install_data

> ${INTSALL_HELPER}
echo OUTPUT_DIR=${OUTPUT_DIR} >> ${INTSALL_HELPER}

croncmd=${INSTALL_DIR}/cx_monitor.sh >/dev/null 2>&1
cronjob="*/1 * * * * $croncmd"

eval '( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -'