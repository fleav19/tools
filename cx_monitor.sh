#!/bin/bash 
# TODO in 2.0
# get_location() {
#   echo "JJJ"
# }

#Globals
source $HOME/.nb/tools/CXMonitor/code/install_data
echo ${OUTPUT_DIR}
#TEMP< REMOVE!!!!!!!!!!!
OUTPUT_DIR=/USERS/aavila/code/tools/debug

year=$(date +"%Y")
month=$(date +%b)
day=$(date +"%d")
timestamp=$(date +%s)
date=$(date +"%Y-%m-%dT%H:%M:%S%:z")
JUST_DATE=$(date +"%Y-%m-%d")
time=$(date +%H:%M)
statefile=${OUTPUT_DIR}/metadata/statefile
log=${OUTPUT_DIR}/log.txt
errorlog=${OUTPUT_DIR}/error_log.txt
resultfile=${OUTPUT_DIR}/results.txt
HASHMAP_FILE=${OUTPUT_DIR}/metadata/tmp

# # Need to move ...not sure where, curretly being done somewhere else
# Can probably move if we do check create file in setup.sh
# source $statefile

temp=false
#DEBGU
WIFI_NAME=mockwifi6
# # REMOVE
# exit 0

# Happens either at start of new day
closeout_logs () {
  echo "here"
  echo $LAST_RAN_DATE
  echo "--------REPORT FOR:${LAST_RAN_DATE}---------" >> $resultfile
  # Only strange case is if we are at 00:00 and the cx was off
  # For all other cases (ie we dropped wifi for multiple dates, just ignore that the cx was in dropped state, only count what was recorded
    # Might be good to make a note in report about there possibly being more time that is not counted
  if [[ "$time" == "00:00" && "$isConnected_p" = false ]]; then
    echo "Weird case"
    diff=$((timestamp-lostCxTimestamp_p))
    downtime_p=$((downtime_p+diff))
    echo "double check math...it happened...cx was out through midnight on: ${date}" >> $error_log
  fi

  # report to results file for ALL WIFIs
  for FILE in ${HASHMAP_FILE}/*; do 
    KEY=$(basename $FILE)
    echo "logging...${KEY}"
    source ${HASHMAP_FILE}/$KEY
    echo "HH"
    echo "${downtime_p}"
    humanReadableDowntime=$(printf '%dh:%dm:%ds\n' $((downtime_p/3600)) $((downtime_p%3600/60)) $((downtime_p%60)))
    echo "Total downtime for ${KEY}---- ${humanReadableDowntime}" >> $resultfile
  done
  echo "-------------------------------" >> $resultfile

  # restart all counters
  isConnected_p=true
  lostCxTimestamp_p=0
  foundCxTimestamp_p=0
  # Remove all files (keys) in tmp dir (hashmap)
  rm ${HASHMAP_FILE}/*
}

check_connection() {
  # MOVE to setup, check if it exists before doing
  # If the persistence file exists, read the variable value from it
  if [ -f "$statefile" ]; then
    source $statefile
  else
    echo "Couldn't find file on ${date}" >> $errorlog
    #init all vars
    isConnected_p=true
    lostCxTimestamp_p=0
    foundCxTimestamp_p=0
    LAST_RAN_DATE=$JUST_DATE
  fi

  HASHMAP_KEY=${HASHMAP_FILE}/${WIFI_NAME}
  if [ -f "${HASHMAP_KEY}" ]; then
    source $HASHMAP_KEY
  else
    echo "FRESH START"
    downtime_p=0
    # Because this key didn't exist, safe to assume it's a new wifi cx for the day
    # We'll abandon the previous statefile and start fresh here
    isConnected_p=true
  fi

  # TODO: 2.0 add weekly reporting
  # check if diff day
  if [[ $JUST_DATE != $LAST_RAN_DATE ]]; then
    closeout_logs
  fi

  # Debug
  if [[ $temp = true ]]; then
  # if nc -zw1 google.com 443; then
    echo "all good"
    foundCxTimestamp_p=${timestamp}
    if [ "$isConnected_p" = false ]; then
      #FINISH LOG FROM LOST CONNECTION
      # COULD ADD A LAST_WRITTEN_FILE TO GO BACK AND CLOSED INTERRUPTED DROPPED CX LOGS
      # JUST A THOUGHT
      diff=$((timestamp-lostCxTimestamp_p))
      echo "before: ${downtime_p}"
      downtime_p=$((downtime_p+diff))
      echo "afer: ${downtime_p}"
      timeDiff=$(printf '%dh:%dm:%ds\n' $((diff/3600)) $((diff%3600/60)) $((diff%60)))


      echo "...recovered connection on ${WIFI_NAME}" >> $file
      echo "[down time seconds]: ${diff}" >> $file
      echo "[down time]: ${timeDiff}" >> $file
      echo "------------------" >> $file
      echo "" >> $file
    fi
    isConnected_p=true
  else
    if [[ $isConnected_p = true ]]; then
      lostCxTimestamp_p=${timestamp}
      #we just lost connection, lets log
      echo "------------------" >> $file
      echo " ALERT!!! ALERT!!!" >> $file
      echo "------------------" >> $file
      echo "we lost connectivity on ${WIFI_NAME}" >> $file
      echo "raw timestamp: ${timestamp}" >>  $file
      echo "${date}" >> $file
      echo "..." >> $file
      isConnected_p=false
    fi
  fi

  > $statefile
  echo isConnected_p=${isConnected_p} >> $statefile
  echo foundCxTimestamp_p=${foundCxTimestamp_p} >> $statefile
  echo lostCxTimestamp_p=${lostCxTimestamp_p} >> $statefile
  echo LAST_RAN_DATETIME=${date} >> $statefile
  echo LAST_RAN_DATE=${JUST_DATE} >> $statefile
  echo downtime_p=${downtime_p} > ${HASHMAP_KEY}
}

## MIGHT BE GOOD TO MOVE check_connection function out to a diff file
# WIFI_NAME=$(/Sy*/L*/Priv*/Apple8*/V*/C*/R*/airport -I | awk '/ SSID:/ {print $2}')
dir=${OUTPUT_DIR}/${WIFI_NAME}/${year}/${month}/${day}
file=${dir}/output.txt

if [ -z "$WIFI_NAME" ]
then
  echo "No Wifi Don't bother running"
  #
  if [ ! -d ${dir} ]; then
    echo "Created...${dir}"
    mkdir -p "${dir}"
  fi
      check_connection
else
  if [ ! -d ${dir} ]; then
    echo "Created...${dir}"
    mkdir -p "${dir}"
  fi
      check_connection
fi
