#!/bin/bash 
echo $HOME
INSTALL_DIR=$HOME/.nb/tools/CXMonitor/code
OUTPUT_DIR=$HOME/.nb/tools/CXMonitor/output
#improve to accept users directory

if [ ! -d ${INSTALL_DIR} ]; then
  echo "CX Monitor isntalled in...${INSTALL_DIR}"
  mkdir -p "${INSTALL_DIR}"
else
  echo "Looks like tool is already installed........updating"
fi

if [ ! -d ${OUTPUT_DIR} ]; then
  mkdir -p "${OUTPUT_DIR}"
fi
if [ ! -d ${OUTPUT_DIR}/metadata ]; then
  mkdir -p "${OUTPUT_DIR}/metadata"
fi
if [ ! -d ${OUTPUT_DIR}/metadata/tmp ]; then
  mkdir -p "${OUTPUT_DIR}/metadata/tmp"
fi

cp cx_monitor.sh ${INSTALL_DIR}/cx_monitor.sh

INSTALLER_DATA=$INSTALL_DIR/install_data

> ${INSTALLER_DATA}
echo OUTPUT_DIR=${OUTPUT_DIR} >> ${INSTALLER_DATA}

croncmd=${INSTALL_DIR}/cx_monitor.sh >/dev/null 2>&1
cronjob="*/1 * * * * bash $croncmd"

eval '( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -'

echo "DONE!"
