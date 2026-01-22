#!/bin/bash

# ============================= PROCESS CHECK =========================
# =====================================================================
#
# Author : Vedansh kumar
# Date : 22-01-2026
# Version: 1.0
# Description : This script check entire system process like cpu, mem, swap
#
# =====================================================================



# Define variable for memory, disk, swap and CPU
MEM_USAGE=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_FREE=$(free -m | awk '/Mem:/ {print $7}')

SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $4}' | sed 's/id,//' | awk '{print int(100 - $1)}')
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')

DISK_INFO=$(df -h | awk 'NR==1, NR==2')
DISK_USAGE=$(df -Ph | awk 'NR==2 {gsub(/%/,""); print $5}')


# Define the webhook, host, time and different threshold values
WEBHOOK_URL="https://chat.googleapis.com/v1/spaces/AAQAgXbcGN4/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=QH6aGdwcZYPzSdWAv6eCfJ8WOhe9Ga-w5HxHFhAiTwk"
HOSTNAME=$(hostname)
TIMESTAMP=$(date "+%A, %B %d, %Y %I:%M:%S %p")
MEM_THRESHOLD=3
DISK_THRESHOLD=5
CPU_THRESHOLD=2

echo ""
echo "This basic script to check the utilization of Memory, CPU, Disk and Swap memory"
echo ""


# Apply condition to check memory consumption
if [ "${MEM_USAGE}" -gt "${MEM_THRESHOLD}" ]; then
        echo ""
        echo "You ran out of Memory!"
        echo "Warning! Current Memory Usage : ${MEM_USAGE}%"
        echo "Available Free Memory : ${MEM_FREE}MB"

        FULL_MESSAGE="🚨*MEMORY ALERT*

        *- HOST :* ${HOSTNAME} - Vedansh kumar
        *- TIME :* \`${TIMESTAMP}\`

        ---------------------------------------------

        *Memory Usage :*

        *- THRESHOLD :* \`${THRESHOLD}%\`
        *- MEMORY USED :* \`${MEM_USAGE}%\`

        *- Suggestion :* \`Check the memory by lsblk, df -h and add extra memory or remove uneccesary data\`

        ---------------------------------------------"
        #Send to Google Chat

        curl -X POST -H 'Content-Type: application/json' \
             -d "{\"text\": \"$FULL_MESSAGE\"}" \
             "${WEBHOOK_URL}"

        echo ""
else
        echo "You have enough memory"
        echo "Current memory usage : ${MEM_USAGE}%"
        echo "Available free memory : ${MEM_FREE}MB / ${MEM_TOTAL}MB"
        echo ""
fi


# Check Swap Memory
echo "Used Swap : ${SWAP_USED}MB"
echo ""


# Check Disk Usuage
if [ "${DISK_USAGE}" -gt "${DISK_THRESHOLD}" ]; then
        echo "You ran out of disk usage : ${DISK_USAGE}%"
        echo "${DISK_INFO}"
        echo ""
        FULL_MESSAGE="🚨*DISK ALERT*

        *- HOST :* ${HOSTNAME} - Vedansh kumar
        *- TIME :* \`${TIMESTAMP}\`

        ------------------------------------------------

        *Disk Usage :*

        *- THRESHOLD :* \`${DISK_THRESHOLD}%\`
        *- DISK USED :* \`${DISK_USAGE}% (Partition: /)\`

        *- Suggestion :* \`Identify the disk, add extra dist or remove unwanted data\`

        ------------------------------------------------"

        #Send to Google Chat
        curl -X POST -H 'Content-Type: application/json' \
             -d "{\"text\": \"$FULL_MESSAGE\"}" \
             "${WEBHOOK_URL}"
        echo ""
else
        echo "You have enough disk : ${DISK_USAGE}%"
        echo "${DISK_INFO}"
        echo ""
fi


# Apply condition to check CPU Utilization
if [ "${CPU_USAGE}" -gt "${CPU_THRESHOLD}" ]; then
        echo "High Load Detected : ${LOAD_AVG}"
        echo "Alert : Current CPU Usage : ${CPU_USAGE}%"
        FULL_MESSAGE="🚨*CPU ALERT*

        *- HOST :* ${HOSTNAME} - Vedansh kumar
        *- TIME :* \`${TIMESTAMP}\`

        -------------------------------------------------

        *CPU Usage :*

        *- THRESHOLD :* \`${CPU_THRESHOLD}%\`
        *- CPU USED :* \`${CPU_USAGE}%\`

        *- Suggestion :* \`Check process, remove and terminate unwanted service\`

        -------------------------------------------------"

        #Send to Google Chat
        curl -X POST -H 'Content-Type: application/json' \
             -d "{\"text\": \"$FULL_MESSAGE\"}" \
             "${WEBHOOK_URL}"
        echo ""
else
        echo "You have enough CPU Usage"
        echo "Current CPU Usage : ${CPU_USAGE}%"
        echo ""
fi

# ========================= END OF SCRIPT ==============================