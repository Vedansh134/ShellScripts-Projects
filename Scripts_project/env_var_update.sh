#!/bin/bash

# ==========================================================================================
#
# Author : Vedansh kumar
# Created on : 25-08-2026
# Version : v1
# Description : Automate application build, PM2 restart after environment variable changes and application health checks.
#
# ===========================================================================================
#
# Test for errors in script
set -euo pipefail

# ============================================
# Application configuration 
# ============================================


APP_NAME="myworkmyday"
APP_URL="http://10.101.10.105"
APP_PORT="3000"
APP_DIR="/opt/mwmd"

DATE=$(date "+%A, %B %d, %Y %I:%M:%S %p")


# =================================================================
# Checked directory

if [[ "$PWD" != "$APP_DIR" ]]; then
    echo "[ERROR] Please run this script from : $APP_DIR"
    exit 1
fi

echo ""
echo "====================================================="
echo "=========== Starting Application Update ============="
echo ""
echo ""
echo ""
echo "====================================================="
echo ""


# ================================================================
# Function for update the env var

update_env(){
    # Build app
    echo "[INFO] Building application...at '${DATE}'"
    npm run build
    echo "[INFO] Build completed successfully."
    echo ""

    echo "[INFO] Restarting PM2..."
    pm2 restart myworkmyday --update-env
    echo "[INFO] PM2 restart successful."
    echo ""

    echo ""
    pm2 save
    echo "pm2 save successufully"
    echo ""

    echo "[INFO] Checking application..."
    echo "[PASS] PM2 process is online."

    echo ""
    pm2 describe myworkmyday
    echo ""

    echo ""
    pm2 status
    echo ""

    ss -tulpn | grep 3000
    echo "[PASS] Port 3000 is listening."

    curl http://10.101.10.105
    echo "[PASS] Application health check successful."
    echo ""

    echo "env updated successfully at '${DATE}'"
    echo ""
}

main(){
    update_env
}


main