#!/bin/bash 
# TODO in 2.0
# get_location() {
#   echo "JJJ"
# }

#Globals
source $HOME/.nb/tools/CXMonitor/code/install_data
echo ${OUTPUT_DIR}
# SHould get from install_result

year=$(date +"%Y")
month=$(date +%b)
day=$(date +"%d")
timestamp=$(date +%s)
date=$(date +"%Y-%m-%dT%H:%M:%S%:z")
time=$(date +%H:%M)
statefile=${OUTPUT_DIR}/metadata/statefile
dir=${OUTPUT_DIR}/${year}/${month}/${day}
file=${dir}/output.txt
log=${OUTPUT_DIR}/log.txt
errorlog=${OUTPUT_DIR}/error_log.txt
resultfile=${OUTPUT_DIR}/results.txt

if [ $1 ]; then
 echo "debug end"
 exit 1
fi

if [ ! -d ${dir} ]; then
  echo "Created...${dir}"
  mkdir -p "${dir}"
fi

check_connection() {
  # If the persistence file exists, read the variable value from it
  if [ -f "$statefile" ]; then
    wasStatefileMissing=false
    source $statefile
  else
    echo "Couldn't find file on ${date}" >> $errorlog
    #init all vars
    isConnected_p=true
    lostCxTimestamp_p=0
    foundCxTimestamp_p=0
    wasStatefileMissing=true
    downtime_p=0
  fi

  # check if 00:00 on a Sunday
  if [[ "$time" == "00:00" ]]; then
    # if cx is currently dropped, calculate remaining total for day
    # it wont double count since we are setting lostCx time stamp to now
    # if it happens that the connection is back at 00:00 then the new days count will just be 0
    if [ "$isConnected_p" = false ]; then
      diff=$((timestamp-lostCxTimestamp_p))
      downtime_p=$((downtime_p+diff))
      echo "double check math...it happened...cx was out through midnight on: ${date}" >> $error_log
    fi
    # report to results file
    humanReadableDowntime=$(printf '%dh:%dm:%ds\n' $((downtime_p/3600)) $((downtime_p%3600/60)) $((downtime_p%60)))
    echo "Total downtime on ${date}::${humanReadableDowntime}" >> $resultfile

    # restart all counters
    lostCxTimestamp_p=${timestamp}
    foundCxTimestamp_p=${timestamp}
    downtime_p=0
  fi
  # if so - 
  # end running total and reset to 0
  # running day total in line > results

  if nc -zw1 google.com 443; then
    echo "all good"
    foundCxTimestamp_p=${timestamp}
    foundCxTimestamp_p=${timestamp}
    if [ "$isConnected_p" = false ]; then
      #FINISH LOG FROM LOST CONNECTION
      diff=$((timestamp-lostCxTimestamp_p))
      downtime_p=$((downtime_p+diff))
      timeDiff=$(printf '%dh:%dm:%ds\n' $((diff/3600)) $((diff%3600/60)) $((diff%60)))


      echo "...recovered connection" >> $file
      echo "[down time seconds]: ${diff}" >> $file
      echo "[down time]: ${timeDiff}" >> $file
      echo "" >> $file
    fi
    isConnected_p=true
  else
    lostCxTimestamp_p=${timestamp}
    if [ $isConnected_p ]; then
    #we just lost connection, lets log
    echo "lost at ${timestamp}"
    fi
    echo "------------------" >> $file
    echo " ALERT!!! ALERT!!!" >> $file
    echo "------------------" >> $file
    echo "we lost connectivity" >> $file
    echo "raw timestamp: ${timestamp}" >>  $file
    echo "${date}" >> $file
    echo "------------------" >> $file
    echo "..." >> $file
    isConnected_p=false
  fi

  # once we source, lets clear for future writing
  > $statefile
  echo isConnected_p=${isConnected_p} >> $statefile
  echo foundCxTimestamp_p=${foundCxTimestamp_p} >> $statefile
  echo lostCxTimestamp_p=${lostCxTimestamp_p} >> $statefile
  echo downtime_p=${downtime_p} >> $statefile
}

wifiName=$(/Sy*/L*/Priv*/Apple8*/V*/C*/R*/airport -I | awk '/ SSID:/ {print $2}')
if [ -z "$wifiName" ]
then
      echo "No Wifi Don't bother running"
      # UPDATE TO ONLY DO THIS WHEN CONNECTED TO MY WIFI OR CREATE REPORT FOR EACH WIFI
      #for debug
      # check_connection
else
      check_connection
fi
