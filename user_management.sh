#!/bin/bash

# ========================== user management shell script =================================
# Version: 1.0
# Author: Vedansh
# Date: 17-10-2025
# Description: In this shell script with the help of function we can create, delete users
# =========================================================================================

# testing (change to set -xeou pipefail for testing)
set +xeou pipefail

# Define variables
SUDO='sudo'

# function to check for root priveleges
check_root(){
    if [ "$(id -u)" -ne 0 ];then
        echo "This script must be run as root user"
        exit 1
    fi
}

# Function to add user
add_user(){
    read -p "Enter the username : " username
    if id "$username" >/dev/null; then
        echo "Enter username '$username' is already exist! Type another name"
    else
        useradd -m "$username" && echo "user '$username' added successfully"
    fi
}

# Function to delete user
delete_user(){
    read -p "Enter username to delete : " username
    if id "$username" >/dev/null; then
        echo "User exist !"
        userdel -r "$username" && echo "user '$username' is delete successfully"
    else
        echo "Enter username '$username' is not exist"
    fi
}

# Function to add user in group
# user_add_group(){
#     read -p "Enter the group name : " groupname
#     read -p "Enter the username that you want to add in group" username
#     if
# }

main_menu(){
    while true; do
        echo "User management shell script ..."
        echo "1. To add the user"
        echo "2. To delete the user"
        echo "3. To add the user in group"
        echo "4. To remove the user from the group"
        echo "5. Exit ..."
        read -p "Enter your choice: " choice

        case $choice in
            1) add_user;;
            2) delete_user;;
            3) user_add_group;;
            4) user_remove_group;;
            5) exit 0;;
            *) echo "Invalid Choice";;
        esac
    done
}

# Execute the root checka and then main menu
check_root
main_menu


# ================================ end of script =====================================
