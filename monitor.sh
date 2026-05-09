#!/bin/bash
# monitor.sh - Simple System Monitor Module
# Uses: while loops, if statements, sleep, clear (from Lab 06-08)

# Colors for warnings (simple echo with escape codes)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to get CPU usage (simple, no complex parsing)
get_cpu() {
    # top -bn1 gets one snapshot, grep "Cpu(s)", cut to get percentage
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
    cpu_usage=$(echo "100 - $cpu_idle" | bc)
    echo "$cpu_usage"
}

# Function to get Memory usage
get_memory() {
    # free command, grep Mem, awk to get percentage used
    mem_info=$(free | grep Mem)
    mem_total=$(echo $mem_info | awk '{print $2}')
    mem_used=$(echo $mem_info | awk '{print $3}')
    mem_percent=$(echo "scale=1; ($mem_used / $mem_total) * 100" | bc)
    echo "$mem_percent"
}

# Function to get Disk usage
get_disk() {
    # df for root partition, awk to get percentage
    df / | tail -1 | awk '{print $5}' | sed 's/%//'
}

# Function to display current stats (one snapshot)
show_stats() {
    clear
    echo "=========================================="
    echo "       SYSTEM HEALTH DASHBOARD            "
    echo "=========================================="
    echo ""
    
    # CPU
    cpu=$(get_cpu)
    echo -n "CPU Usage:    ${cpu}%"
    if (( $(echo "$cpu > 80" | bc -l) )); then
        echo -e " ${RED}[WARNING: HIGH]${NC}"
    else
        echo -e " ${GREEN}[OK]${NC}"
    fi
    
    # Memory
    mem=$(get_memory)
    echo -n "Memory Usage: ${mem}%"
    if (( $(echo "$mem > 80" | bc -l) )); then
        echo -e " ${RED}[WARNING: HIGH]${NC}"
    else
        echo -e " ${GREEN}[OK]${NC}"
    fi
    
    # Disk
    disk=$(get_disk)
    echo -n "Disk Usage:   ${disk}%"
    if [ "$disk" -gt 80 ]; then
        echo -e " ${RED}[WARNING: HIGH]${NC}"
    else
        echo -e " ${GREEN}[OK]${NC}"
    fi
    
    echo ""
    echo "=========================================="
    echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
}

# Main menu for monitor module
monitor_menu() {
    while true; do
        clear
        echo "========== MONITOR MENU =========="
        echo "1. Show current stats (one time)"
        echo "2. Auto-refresh mode (press Ctrl+C to stop)"
        echo "3. Back to main menu"
        echo "=================================="
        echo -n "Enter choice [1-3]: "
        read choice
        
        case $choice in
            1)
                show_stats
                echo ""
                echo -n "Press Enter to continue..."
                read
                ;;
            2)
                # THE FIX: Simple single loop with break condition
                # No nested loops, clean exit with 'q'
                echo ""
                echo "Auto-refresh starting..."
                echo "Press 'q' then Enter to quit, or Ctrl+C"
                sleep 1
                
                while true; do
                    show_stats
                    echo ""
                    echo "Refresh in 3 seconds... (q + Enter to quit)"
                    
                    # Read with timeout - THE KEY FIX!
                    # -t 3 waits 3 seconds, if no input, continues loop
                    # This prevents hanging and stacking
                    read -t 3 quit_input
                    
                    # Check if user wants to quit
                    if [ "$quit_input" = "q" ]; then
                        echo "Stopping auto-refresh..."
                        sleep 1
                        break  # Exit only THIS loop, clean!
                    fi
                done
                ;;
            3)
                break  # Exit monitor menu
                ;;
            *)
                echo "Invalid choice!"
                sleep 1
                ;;
        esac
    done
}

# Run the menu
monitor_menu
