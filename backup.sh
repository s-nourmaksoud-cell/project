#!/bin/bash

clear
echo ""
echo "=== BACKUP UTILITY ==="
echo ""

echo -n "Enter directory to backup: "
read source_dir

if [ ! -d "$source_dir" ]; then
    echo "ERROR: Directory does not exist!"
    read -p "Press Enter to continue..."
    exit 1
fi

echo -n "Enter destination (Enter for current): "
read dest_dir

if [ -z "$dest_dir" ]; then
    dest_dir="."
fi

if [ ! -d "$dest_dir" ]; then
    echo "ERROR: Destination does not exist!"
    read -p "Press Enter to continue..."
    exit 1
fi

timestamp=$(date +%Y-%m-%d_%H-%M-%S)
backup_name="backup_$timestamp.tar.gz"
backup_path="$dest_dir/$backup_name"

echo ""
echo "Source: $source_dir"
echo "Destination: $dest_dir"
echo "Backup file: $backup_name"
echo ""
echo "Creating backup..."

tar -czf "$backup_path" "$source_dir" 2>/dev/null

if [ -f "$backup_path" ]; then
    size=$(ls -lh "$backup_path" | awk '{print $5}')
    echo ""
    echo "Backup created successfully!"
    echo "Size: $size"
    echo "$(date) | Source: $source_dir | Destination: $dest_dir | Size: $size" >> backup.log
    echo "Log saved to backup.log"
else
    echo "Backup failed!"
fi

echo ""
read -p "Press Enter to continue..."
exit 0
