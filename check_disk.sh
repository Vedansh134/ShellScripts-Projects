#!/bin/bash

# ============================= Disk usage script ============================

echo "disk usage"

alert=15
echo "your limit : $alert"

backup_date=$(date +'%m/%d/%Y %H:%M:%S')
df -H | awk '{print $5 " " $1}' | while read output;


do
	#echo "Disk details : $output"
	usage=$(echo $output | awk '{print $1 }' | cut -d'%' -f1)
	file_sys=$(echo $output | awk '{print $2}' )
	#echo $usage
	if [[ $usage -ge $alert ]]; then
		echo "WARNING!! CRITICAL FOR $file_sys on $backup_date"
		df -H | grep $file_sys
	fi
done

# =========================================================
