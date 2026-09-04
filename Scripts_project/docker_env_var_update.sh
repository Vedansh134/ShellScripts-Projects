#!/bin/bash

# =======================================================================================================================
#
# Author : Vedansh kumar
# Created on : 03-09-2026
# Version : v1
# Description : Automate application build, Docker restart after environment variable changes and application health checks.
#
# =======================================================================================================================
#
# Test for errors in script
set -euo pipefail

# ============================================
# Application configuration 
# ============================================


CONTAINER_NAME="mwmd_frontend_container"
APP_NAME="mwmd-app"
APP_URL="http://10.101.10.105:3000"
APP_PORT="3000"
APP_DIR="/opt/myworkmyday"
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
echo "Time          : $DATE"
echo "App Container : $CONTAINER_NAME"
echo "Directory     : $APP_DIR"
echo "====================================================="
echo ""


# =====================================================
# Stop Docker containers
# =====================================================


echo "[INFO] Stopping Dcoker Containers..."

docker compose down

echo "[PASS] Docker Containers stopped successfully"
echo ""


# =====================================================
# Verify Docker container status 
# =====================================================


echo "[INFO] Checking Docker container status..."

docker compose ps -a

echo ""


# =====================================================
# Build and start application containers
# =====================================================


echo "[INFO] Building and starting Docker containers..."

docker compose up -d --build --force-recreate

echo "[PASS] Docker compose up successfully"
echo ""


# =====================================================
# Verify running Docker containers
# =====================================================


echo "[INFO] Checking running Docker container..."

docker compose ps
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

if curl -fsS --max-time 10 "$APP_URL" -o /dev/null; then
    echo "[PASS] Application health check successful."
else
    echo "[ERROR] Application health check failed."
    exit 1
fi


# ============================================================
# Final Status
# ============================================================


echo "====================================================================="
echo ""
echo "[SUCCESS] App restart and Environment update completed successfully."
echo "Application : $APP_NAME"
echo "Time        : $DATE"
echo ""
echo "====================================================================="
