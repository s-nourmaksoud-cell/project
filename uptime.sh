#!/bin/bash

WATCH_FILE=".watchlist.conf"
LOG_FILE="uptime.log"

if [ ! -f "$WATCH_FILE" ]; then
    touch "$WATCH_FILE"
fi

view_servers() {
    echo ""
    echo "=== MONITORED SERVERS ==="
    echo ""

    if [ ! -s "$WATCH_FILE" ]; then
        echo "No servers in list."
    else
        line_num=1
        while IFS= read -r server; do
            echo "$line_num. $server"
            line_num=$((line_num + 1))
        done < "$WATCH_FILE"
    fi
    echo ""
}

add_server() {
    echo ""
    echo "=== ADD SERVER ==="
    echo -n "Enter server (IP or domain): "
    read server

    if [ -z "$server" ]; then
        echo "Cannot be empty!"
        return
    fi

    if grep -q "^$server$" "$WATCH_FILE"; then
        echo "Server already exists!"
        return
    fi

    echo "$server" >> "$WATCH_FILE"
    echo "Server added!"
}

remove_server() {
    echo ""
    echo "=== REMOVE SERVER ==="
    echo ""

    if [ ! -s "$WATCH_FILE" ]; then
        echo "No servers to remove."
        return
    fi

    view_servers
    echo -n "Enter server number to remove: "
    read num

    temp_file=$(mktemp)
    line_num=1
    while IFS= read -r server; do
        if [ "$line_num" -ne "$num" ]; then
            echo "$server" >> "$temp_file"
        fi
        line_num=$((line_num + 1))
    done < "$WATCH_FILE"

    mv "$temp_file" "$WATCH_FILE"
    echo "Server removed!"
}

check_servers() {
    clear
    echo ""
    echo "=== REMOTE MONITOR ==="
    echo ""

    if [ ! -s "$WATCH_FILE" ]; then
        echo "No servers to monitor!"
        read -p "Press Enter..."
        return
    fi

    total=0
    up=0
    down=0

    while IFS= read -r server; do
        if [ -z "$server" ]; then
            continue
        fi

        total=$((total + 1))
        echo -n "$server ... "

        ping_output=$(ping -c 1 -W 2 "$server" 2>/dev/null)
        ping_status=$?

        if [ "$ping_status" -eq 0 ]; then
            response_time=$(echo "$ping_output" | grep "time=" | head -1 | cut -d'=' -f4 | cut -d' ' -f1)
            if [ -n "$response_time" ]; then
                echo "UP ($response_time ms)"
            else
                echo "UP"
            fi
            up=$((up + 1))
        else
            echo "DOWN"
            down=$((down + 1))
            echo "$(date) | $server is DOWN" >> "$LOG_FILE"
        fi
    done < "$WATCH_FILE"

    echo ""
    echo "Total: $total | Up: $up | Down: $down"
    echo ""

    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        echo "Recent failures:"
        tail -3 "$LOG_FILE"
    else
        echo "No failures logged."
    fi

    echo ""
    read -p "Press Enter..."
}

while true; do
    clear
    echo ""
    echo "=== REMOTE MONITOR ==="
    echo "1. Monitor Servers"
    echo "2. Add Server"
    echo "3. Remove Server"
    echo "4. View Server List"
    echo "5. Back to Menu"
    echo -n "Choice: "
    read choice

    if [ "$choice" = "1" ]; then
        check_servers
    elif [ "$choice" = "2" ]; then
        add_server
        read -p "Press Enter..."
    elif [ "$choice" = "3" ]; then
        remove_server
        read -p "Press Enter..."
    elif [ "$choice" = "4" ]; then
        view_servers
        read -p "Press Enter..."
    elif [ "$choice" = "5" ]; then
        exit 0
    else
        echo "Invalid choice"
        sleep 1
    fi
done
