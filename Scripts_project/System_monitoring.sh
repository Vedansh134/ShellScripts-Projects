#!/bin/bash

# =======================================================================================================
#
# Script Name : monitoring.sh
# Author      : Vedansh kumar
# Created on  : 03-08-2026
# Description : Monitor Linux server and Docker containers.
#               Raise alerts when resource usage exceeds defined thresholds.
#
# =======================================================================================================
#
#
# Test for any errors in the script
set -euo pipefail


# ==============================================================
# Threshold Configuration Parameters
# ==============================================================

CRITICAL_THRESHOLD=90
WARNING_THRESHOLD=80


# ==============================================================
# Server Information Parameters
# ==============================================================


DATE=$(date "+%A, %B %d, %Y %I:%M:%S %p")
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $2}')
OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
KERNAL_NAME=$(uname -r)
UPTIME=$(uptime -p)

NAME=("MyWorkMyDay-Frontend")
ENV=("Staging")


# =============================================================
# Define the webhook URL
# =============================================================
WEBHOOK_URL=""
#
# 
# Create functions for check the CPU, MEMEORY, DISK, PROCESS and gchat
#
#
# =============================================================
# Google Chat Alert Function
# =============================================================
#
send_gchat_alert(){
    local REPORT_BODY="$1"

    # Send gchat alert based on the alert type 
    local FULL_MESSAGE="✅ *[System Health Report]* 

    *- HOST :* \`${HOSTNAME}\`
    *- DATE :* \`${DATE}\`
    *- IP :* \`${IP}\`
    *- NAME :* \`${NAME}\`
    *- ENVIRONMENT :* \`${ENV}\`
    
    ----------------------------------------------------
    
    ${REPORT_BODY}

    "

    # Send to Google Chat
    curl -s -X POST -H 'Content-Type: application/json' \
         -d "{\"text\": \"$FULL_MESSAGE\"}" \
         "${WEBHOOK_URL}" > /dev/null
}

# =============================================================
# System Info
# =============================================================
#
get_system_info(){
    echo ""
    printf "%-15s : %s\n" "Date" "$(date "+%A, %B %d, %Y %I:%M:%S %p")"
    printf "%-15s : %s\n" "Hostname" "$(hostname)"
    printf "%-15s : %s\n" "IP" "$(hostname -I | awk '{print $2}')"
    printf "%-15s : %s\n" "OS" "$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
    printf "%-15s : %s\n" "Kernel" "$(uname -r)"
    printf "%-15s : %s\n" "Uptime" "$(uptime -p | sed 's/up //')"
    echo ""
    echo ""
}
#
#
# -------------------------------------------------------------
# Check Disk Usage
# -------------------------------------------------------------
#
#
get_check_disk(){
    local DISK_USAGE=$(df -hP / | awk 'NR==2 {gsub("%","",$5); print $5}')

    local SUGGESTION="High disk usage detected. Run 'du -sh /* 2>/dev/null | sort -rh | head -10' to find large files/directories. Consider cleaning old logs or expanding the partition."


    if [ "$DISK_USAGE" -ge "$CRITICAL_THRESHOLD" ]; then        
        echo "🚨 *DISK*   : ${DISK_USAGE}% (CRITICAL)\n   ➔ Suggestion : ${SUGGESTION}"
        echo "\n"
    elif [ "$DISK_USAGE" -ge "$WARNING_THRESHOLD" ]; then
        echo "⚠️ *DISK*   : ${DISK_USAGE}% (WARNING)\n   ➔ Suggestion : ${SUGGESTION}"
        echo "\n"
    else
        echo "✅ *DISK*   : ${DISK_USAGE}% (NORMAL)\n"
    fi
}

# -------------------------------------------------------------
# Check Memory Usage
# -------------------------------------------------------------

get_check_memory(){
    local MEM_TOTAL=$(free -k | awk '/^Mem:/ {print $2}')
    local MEM_USED=$(free -k | awk '/^Mem:/ {print $3}')
    local MEM_USAGE=$(( (MEM_USED * 100) / MEM_TOTAL ))

    local SUGGESTION="High memory consumption. Run 'ps aux --sort=-%mem | head -10' to identify the top memory processes. Consider restarting the app or adding Swap/RAM."
    

    if [ "$MEM_USAGE" -ge "$CRITICAL_THRESHOLD" ]; then
        echo "🚨 *MEMORY*   : ${MEM_USAGE}% (CRITICAL)\n   ➔ Suggestion : ${SUGGESTION}"
        echo "\n"
    elif [ "$MEM_USAGE" -ge "$WARNING_THRESHOLD" ]; then
        echo "⚠️ *MEMORY*   : ${MEM_USAGE}% (WARNING)\n   ➔ Suggestion : ${SUGGESTION}"
        echo "\n"
    else
        echo "✅ *MEMORY*   : ${MEM_USAGE}% (NORMAL)\n"
    fi
}

# -------------------------------------------------------------
# Checking CPU Usage
# -------------------------------------------------------------

get_check_cpu(){
    local CPU_RAW=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    local CPU_USAGE=$(printf "%.0f" "$CPU_RAW")

    local SUGGESTION="High CPU usage. Run 'top -bn1 | head -20' to see the top CPU-consuming tasks. Identify and terminate any stuck or zombie processes."


    if [ "$CPU_USAGE" -ge "$CRITICAL_THRESHOLD" ]; then 
        echo "🚨 *CPU*   : ${CPU_USAGE}% (CRITICAL)\n   ➔ Suggestion : ${SUGGESTION}"
        echo "\n"
    elif [ "$CPU_USAGE" -ge "$WARNING_THRESHOLD" ]; then
        echo "⚠️ *CPU*   : ${CPU_USAGE}% (WARNING)\n   ➔ Suggestion : ${SUGGESTION}"
        echo "\n"
    else    
        echo "✅ *CPU*   : ${CPU_USAGE}% (NORMAL)\n"
    fi
}

# -------------------------------------------------------------
# Check Load Average
# -------------------------------------------------------------

get_check_load(){
    local LOAD=$(uptime | awk -F'load average: ' '{print $2}' | cut -d, -f1)
    local CORES=$(nproc)

    local LOAD_PERCENT=$(awk "BEGIN { printf \"%.0f\", ($LOAD/$CORES)*100}")

    local SUGGESTION="System is heavily overloaded. Check for Disk I/O spikes using 'iostat -x 1 5' and check high CPU processes. If normal, consider scaling up server cores."


    if [ "$LOAD_PERCENT" -ge "$CRITICAL_THRESHOLD" ]; then
        echo "🚨 *LOAD*   : ${LOAD_PERCENT}% (CRITICAL)\n   ➔ Suggestion : ${SUGGESTION}"
        echo "\n"
    elif [ "$LOAD_PERCENT" -ge "$WARNING_THRESHOLD" ]; then
        echo "⚠️ *LOAD*   : ${LOAD_PERCENT}% (WARNING)\n   ➔ Suggestion : ${SUGGESTION}"
        echo "\n"
    else
        echo "✅ *LOAD*   : ${LOAD_PERCENT}% (NORMAL)\n"
    fi
}

# -------------------------------------------------------------
# Top Processes 
# -------------------------------------------------------------

get_process_cpu(){
    echo ""
    echo "[INFO] Top 5 CPU-Consuming Processes : "

    echo "\n"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6
}

# -------------------------------------------------------------
# Check Docker Container and Services Status
# -------------------------------------------------------------

get_check_container(){
    echo "\n-------------------------------------------------------\n"
    echo " "
    printf "Docker Service Status :"
    echo " "

    local DOCKER_CONTAINER=("mwmd_frontend_container")
    local DOCKER_SVC=$(systemctl is-active docker)
    local SUGGEST_DOCKER_STATUS_CRITICAL="Docker daemon is stopped. Run 'sudo systemctl start docker' immediately!"

    local SUGGEST_PORT_WARN="Container '$DOCKER_CONTAINER' is running but no port is exposed. Check docker run -p flags."

    local SUGGEST_STOP_CRITICAL="Container '$DOCKER_CONTAINER' is stopped. Run 'docker start $DOCKER_CONTAINER' immediately!"
    local SUGGEST_NOT_EXIST_CRITICAL="Container '$DOCKER_CONTAINER' does not exist. Please deploy it again!"


    # 1. Check Docker Service
    if [ "$DOCKER_SVC" = "active" ]; then
        echo ""
        echo "✅ Docker service is running."
    else 
        echo "[CRITICAL] Docker service is NOT RUNNING!"
        echo "🚨 *DOCKER* : Service Down (CRITICAL)\n   ➔ Suggestion : ${SUGGEST_DOCKER_STATUS_CRITICAL}"
    fi

    # 2. Check Container Status & Find its Port
    for CONTAINER_NAME in "${DOCKER_CONTAINER[@]}"; do
        if docker ps --format '{{.Names}}' | grep -w "^$CONTAINER_NAME$" >/dev/null; then
            echo "✅ Container '$CONTAINER_NAME' is running"
            echo ""

            local CONTAINER_PORT=$(docker port "$CONTAINER_NAME" 2>/dev/null | awk '{print $3}' | head -1 | sed 's/0.0.0.0://')
            local DOCKER_STATS=$(docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}" | grep "$DOCKER_CONTAINER")

            # Use awk to get the exact CPU and MEM percentages from the stats line
            # Example: mwmd_frontend_container   0.34%     2.24%
            local DOCKER_CPU=$(echo "$DOCKER_STATS" | awk '{print $2}' | sed 's/%//')
            local DOCKER_MEM=$(echo "$DOCKER_STATS" | awk '{print $3}' | sed 's/%//')


            if [ -n "$CONTAINER_PORT" ]; then
                echo "   ➔ Port Mapping : *Port ${CONTAINER_PORT} is listening* (Accessible)"
                echo "   ➔ Docker Stats : CPU: ${DOCKER_CPU}% | MEM: ${DOCKER_MEM}%"
                echo ""

                # local DOCKER_SUMMARY=$(printf "Running | Port: %s | CPU: %s%% | MEM: %s%%" "$CONTAINER_PORT" "$DOCKER_CPU" "$DOCKER_MEM")
                # echo "✅ *DOCKER* : ${DOCKER_SUMMARY}"
            else
                echo "   ➔ Port Mapping : No public port is exposed for this container"
                echo "⚠️ *DOCKER* : Container running, but Port Missing (WARNING)\n   ➔ Suggestion : ${SUGGEST_PORT_WARN}"
            fi

        else
            # check if it is exists but is stopped
            if docker ps -a --format '{{.Names}}' | grep -w "^$CONTAINER_NAME$" >/dev/null; then
                echo "[CRITICAL] Container '$CONTAINER_NAME' is STOPPED!"
                echo "🚨 *DOCKER* : Container STOPPED (CRITICAL)\n   ➔ Suggestion : ${SUGGEST_STOP_CRITICAL}"
            else
                echo "[CRITICAL] Container '$CONTAINER_NAME' does not EXIST!"
                echo "🚨 *DOCKER* : Container does not exist (CRITICAL)\n   ➔ Suggestion : ${SUGGEST_NOT_EXIST_CRITICAL}"
            fi
        fi 
    done 
}


main(){
    echo "================================================================"
    echo "       SYSTEM HEALTH REPORT - $(date)"
    echo "================================================================"

    echo ""
    # Display System Info
    get_system_info

    local MASTER_REPORT=""

    # CORRECTED: Run the commands first, and IF it fails, append "|| true" properly
    local DISK_OUT="$(get_check_disk)" || true
    local MEM_OUT="$(get_check_memory)" || true
    local CPU_OUT="$(get_check_cpu)" || true
    local LOAD_OUT="$(get_check_load)" || true
    #local PROC_OUT="$(get_process_cpu)" || true
    local DOCKER_OUT="$(get_check_container)" || true

    # Now append the pure, clean outputs into the master report
    MASTER_REPORT+="${DISK_OUT}"
    MASTER_REPORT+="${MEM_OUT}"
    MASTER_REPORT+="${CPU_OUT}"
    MASTER_REPORT+="${LOAD_OUT}"
    #MASTER_REPORT+="${PROC_OUT}"
    MASTER_REPORT+="${DOCKER_OUT}"


    echo ""
    echo "================================================================"


    # Print to linux terminal
    echo -e "$MASTER_REPORT"


    # Send one master message which containing all messages related to error if good or bad
    send_gchat_alert "$MASTER_REPORT"
}

main