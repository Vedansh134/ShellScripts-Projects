#!/bin/bash

# =======================================================================================================================
#
# Author : Vedansh kumar
# Created on : 25-08-2026
# Version : v1
# Description : Automate application build, PM2 restart after environment variable changes and application health checks.
#
# =======================================================================================================================
#
# Test for errors in script
set -euo pipefail

# ============================================
# Application configuration 
# ============================================


APP_NAME="strapi-staging"
APP_URL="http://10.101.10.87:1337"
APP_PORT="1337"
APP_DIR="/opt/strapi-app"
APP_USER="deploy"

DATE=$(date "+%A, %B %d, %Y %I:%M:%S %p")


# =================================================================
# Checked directory and user
# =================================================================


if [[ "$PWD" != "$APP_DIR" ]]; then
    echo "[ERROR] Please run this script from : $APP_DIR"
    exit 1
fi

if [[ "$(id -un)" != "$APP_USER" ]]; then
    echo "[ERROR] Please run this script from $APP_USER user"
    exit 1
fi


# =====================================================
# Application Information
# =====================================================


echo ""
echo "====================================================="
echo "=========== Starting Application Update ============="
echo ""
echo "Time        : $DATE"
echo "Application : $APP_NAME"
echo "Directory   : $APP_DIR"
echo "====================================================="
echo ""


# =====================================================
# Build Application
# =====================================================


echo "[INFO] Building application..."
npm run build
echo "[PASS] Application Build completed successfully."
echo ""


# =====================================================
# Restart PM2 with updated env variables
# =====================================================


echo "[INFO] Restarting PM2..."
pm2 restart "$APP_NAME" --update-env
echo "[PASS] PM2 application restarted successfully."
echo ""


# =====================================================
# Save PM2 
# =====================================================


echo "[INFO] Saving PM2 process list"
pm2 save
echo "[PASS] PM2 process list saved"
echo ""


# =====================================================
# Check PM2 Status
# =====================================================


echo "[INFO] Checking PM2 Status..."
pm2 status "$APP_NAME"
echo ""


# =====================================================
# Check Application Port
# =====================================================


echo "[INFO] Checking port $APP_PORT..."
if ss -lnt | grep -q ":$APP_PORT"; then
    echo "[PASS] Port $APP_PORT is listening."
else
    echo "[ERROR] Port $APP_PORT is not listening."
    exit 1
fi


# =====================================================
# Check Application Health
# =====================================================

echo "[INFO] Checking application health..."

if curl -fsS --max-time 10 "$APP_URL" >/dev/null; then
    echo "[PASS] Application health check successful."
else
    echo "[ERROR] Application health check failed."
exit 1
fi


# ============================================================
# Final Status
# ============================================================


echo "===================================================================="
echo ""
echo "[SUCCESS] App restart and Environment update completed successfully."
echo "Application : $APP_NAME"
echo "Time        : $DATE"
echo ""
echo "===================================================================="
