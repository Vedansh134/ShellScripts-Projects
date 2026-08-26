#!/bin/bash

# ==========================================================================================
#
# Author : Vedansh kumar
# Created on : 25-08-2026
# Version : v1
# Description : To automate the process of update the application after updated the env var.
#
# ===========================================================================================
#
# Test for errors in script
set -euo pipefail

# ============================================
# Build the application
# ============================================

echo ""
npm run build
echo "App build successfully"
echo ""

# ============================================
# Restart the pm2
# ============================================

echo ""
pm2 restart myworkmyday --update-env
echo "Environment variables updated successfully"
echo ""

# =================================================
# save pm2 application
# =================================================

echo ""
pm2 save
echo "pm2 save successufully"
echo ""

# ================================================
# describe the pm2 
# ================================================

echo ""
pm2 describe myworkmyday
echo ""

# check pm2 status

echo ""
pm2 status
echo ""

# check the application is listening and on which port
curl http://10.101.10.105
ss -tulpn | grep 3000
echo ""

echo "env updated successfully"
echo ""