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
#latest - WEBHOOK_URL="https://chat.googleapis.com/v1/spaces/AAQACwrHb3w/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=MJxeOKQ4OeGG8OowhbhGT02CrEa380GNwWvRQBmeUWU"

WEBHOOK_URL="https://chat.googleapis.com/v1/spaces/AAQAKRep3V8/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=piseh4f0_bfmxeJr881E1FIHxlbhzTOFDETghtDsSXc"
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
    local FULL_MESSAGE="${ICON} *[${SEVERITY}] ${ALERT_TYPE}* 

    *- HOST :* \`${HOSTNAME}\`
    *- DATE :* \`${DATE}\`
    *- IP :* \`${IP}\`
    *- NAME :* \`${NAME}\`
    *- ENVIRONMENT :* \`${ENV}\`
    
    ----------------------------------------------------
    
    *System Status Report :*
    
    ${REPORT_BODY}

    ----------------------------------------------------"

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
        printf "[CRITICAL] %-10s : %s%%\n" "DISK Usage Extremely High" "$DISK_USAGE"
        echo "🚨 *DISK*   : ${DISK_USAGE}% (CRITICAL)\n   ➔ Suggestion: ${SUGGESTION}"

        return 1  # <--- Return an error code to indicate an issue occurred

    elif [ "$DISK_USAGE" -ge "$WARNING_THRESHOLD" ]; then
        printf "[WARNING] %-10s : %s%%\n" "DISK Usage" "$DISK_USAGE"
        echo "⚠️ *DISK*   : ${DISK_USAGE}% (WARNING)\n   ➔ Suggestion: ${SUGGESTION}"

        return 1

    else
        printf "[OK]      %-10s : %s%%\n" "DISK Usage" "$DISK_USAGE"
        echo "✅ *DISK*   : ${DISK_USAGE}% (NORMAL)"

        return 0  # <--- Return 0 (success) meaning everything is fine
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
        printf "[CRITICAL] %-10s : %s%%\n" "MEMORY Usage Extremely High" "$MEM_USAGE"
        echo "🚨 *MEMORY*   : ${MEM_USAGE}% (CRITICAL)\n   ➔ Suggestion: ${SUGGESTION}"

        return 1

    elif [ "$MEM_USAGE" -ge "$WARNING_THRESHOLD" ]; then
        printf "[WARNING] %-10s : %s%%\n" "MEMORY Usage" "$MEM_USAGE"
        echo "⚠️ *MEMORY*   : ${MEM_USAGE}% (WARNING)\n   ➔ Suggestion: ${SUGGESTION}"

        return 1

    else
        printf "[OK]      %-10s : %s%%\n" "MEMORY Usage" "$MEM_USAGE"
        echo "✅ *MEMORY*   : ${MEM_USAGE}% (NORMAL)\n"

        return 0
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
        printf "[CRITICAL] %-10s : %s%%\n" "CPU Usage Extremely High" "$CPU_USAGE"
        echo "🚨 *CPU*   : ${CPU_USAGE}% (CRITICAL)\n   ➔ Suggestion: ${SUGGESTION}"

        return 1

    elif [ "$CPU_USAGE" -ge "$WARNING_THRESHOLD" ]; then
        printf "[WARNING] %-10s : %s%%\n" "CPU Usage" "$CPU_USAGE"
        echo "⚠️ *CPU*   : ${CPU_USAGE}% (WARNING)\n   ➔ Suggestion: ${SUGGESTION}"

        return 1

    else    
        printf "[OK]      %-10s : %s%%\n" "CPU Usage" "$CPU_USAGE"
        echo "✅ *CPU*   : ${CPU_USAGE}% (NORMAL)\n"

        return 0
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
        printf "Critical - CPU Load : ${LOAD_PERCENT}%, (${LOAD} load on ${CORES} cores)"
        echo "🚨 *LOAD*   : ${LOAD_PERCENT}% (CRITICAL)\n   ➔ Suggestion: ${SUGGESTION}"

        return 1

    elif [ "$LOAD_PERCENT" -ge "$WARNING_THRESHOLD" ]; then
        printf "Warning - CPU Load : ${LOAD_PERCENT}%, (${LOAD} load on ${CORES} cores)"
        echo "⚠️ *LOAD*   : ${LOAD_PERCENT}% (WARNING)\n   ➔ Suggestion: ${SUGGESTION}"

        return 1

    else
        printf "[OK]   CPU Load : ${LOAD_PERCENT}%, (${LOAD} load on ${CORES} cores)"
        echo "✅ *LOAD*   : ${LOAD_PERCENT}% (NORMAL)\n"

        return 0
    fi
}

# -------------------------------------------------------------
# Top Processes 
# -------------------------------------------------------------

get_process_cpu(){
    echo ""
    echo "[INFO] Top 5 CPU-Consuming Processes : "

    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6
}

# -------------------------------------------------------------
# Check Docker Container and Services Status
# -------------------------------------------------------------

get_check_container(){
    echo "[INFO] Docker Service Status :"
    echo ""

    local DOCKER_CONTAINER=("mwmd_frontend_container")
    local DOCKER_SVC=$(systemctl is-active docker)
    local SUGGEST_DOCKER_STATUS_CRITICAL="Docker daemon is stopped. Run 'sudo systemctl start docker' immediately!"

    local SUGGEST_PORT_WARN="Container '$DOCKER_CONTAINER' is running but no port is exposed. Check docker run -p flags."

    local SUGGEST_STOP_CRITICAL="Container '$DOCKER_CONTAINER' is stopped. Run 'docker start $DOCKER_CONTAINER' immediately!"
    local SUGGEST_NOT_EXIST_CRITICAL="Container '$DOCKER_CONTAINER' does not exist. Please deploy it again!"


    # 1. Check Docker Service
    if [ "$DOCKER_SVC" = "active" ]; then
        echo ""
        echo "[OK] Docker service is running."

    else 
        echo "[CRITICAL] Docker service is NOT RUNNING!"
        echo "🚨 *DOCKER* : Service Down (CRITICAL)\n   ➔ Suggestion: ${SUGGEST_DOCKER_STATUS_CRITICAL}"
        
        return 1
    fi

    # 2. Check Container Status & Find its Port
    for CONTAINER_NAME in "${DOCKER_CONTAINER[@]}"; do
        if docker ps --format '{{.Names}}' | grep -w "^$CONTAINER_NAME$" >/dev/null; then
            echo "[OK] Container '$CONTAINER_NAME' is running"
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

                local DOCKER_SUMMARY=$(printf "Running | Port: %s | CPU: %s%% | MEM: %s%%" "$CONTAINER_PORT" "$DOCKER_CPU" "$DOCKER_MEM")
                echo "✅ *DOCKER* : ${DOCKER_SUMMARY}"
                return 0

            else
                echo "   ➔ Port Mapping : No public port is exposed for this container"
                echo "⚠️ *DOCKER* : Container running, but Port Missing (WARNING)\n   ➔ Suggestion: ${SUGGEST_PORT_WARN}"

                # Return 1 immediately so main() knows it failed, and stop the function.
                return 1 
            fi

        else
            # check if it is exists but is stopped
            if docker ps -a --format '{{.Names}}' | grep -w "^$CONTAINER_NAME$" >/dev/null; then
                echo "[CRITICAL] Container '$CONTAINER_NAME' is STOPPED!"
                echo "🚨 *DOCKER* : Container STOPPED (CRITICAL)\n   ➔ Suggestion: ${SUGGEST_STOP_CRITICAL}"
                
                return 1

            else
                echo "[CRITICAL] Container '$CONTAINER_NAME' does not EXIST!"
                echo "🚨 *DOCKER* : Container does not exist (CRITICAL)\n   ➔ Suggestion: ${SUGGEST_NOT_EXIST_CRITICAL}"
                
                return 1    # <--- This is required! It sets HAS_ISSUE=true in main()
            fi
        fi 
    done 


    # Top Docker Containers (Added || true to prevent crash if no containers)
    echo ""
    echo "[INFO] Top Containers by CPU Usage :"
    echo ""
    # docker stats --no-stream takes a single snapshot. --format allows clean output.
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.MemUsage}}" | head -2 || true 
}


main(){
    echo "================================================================"
    echo "       SYSTEM HEALTH REPORT - $(date)"
    echo "================================================================"

    echo ""
    # Display System Info
    get_system_info

    local MASTER_REPORT=""

    # Run each function check, if it is found anything in echo so it will append to MASTER_REPORT
    MASTER_REPORT+="$(get_check_disk)"
    MASTER_REPORT+="$(get_check_memory)"
    MASTER_REPORT+="$(get_check_cpu)"
    MASTER_REPORT+="$(get_check_load)"
    MASTER_REPORT+="$(get_process_cpu)"
    MASTER_REPORT+="$(get_check_container)"


    echo ""
    echo "================================================================"


    # Send one master message which containing all messages related to error if good or bad
    send_gchat_alert "$MASTER_REPORT"
}

main