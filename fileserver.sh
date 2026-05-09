#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/fileserver.pid"
LOG_FILE="$SCRIPT_DIR/fileserver_access.log"

start_server() {
    clear
    echo ""
    echo "=== START FILE SERVER ==="
    echo ""

    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Server already running! (PID: $pid)"
            read -p "Press Enter..."
            return
        else
            rm "$PID_FILE"
        fi
    fi

    echo -n "Directory to share: "
    read share_dir

    if [ ! -d "$share_dir" ]; then
        echo "Directory does not exist!"
        read -p "Press Enter..."
        return
    fi

    echo -n "Port (Enter for 8000): "
    read port

    if [ -z "$port" ]; then
        port=8000
    fi

    if ! [ "$port" -eq "$port" ] 2>/dev/null; then
        echo "Invalid port number!"
        read -p "Press Enter..."
        return
    fi

    echo "$(date) | Server STARTED | Directory: $share_dir | Port: $port" >> "$LOG_FILE"

    cd "$share_dir"
    python3 -m http.server "$port" >> "$LOG_FILE" 2>&1 &
    server_pid=$!
    cd "$SCRIPT_DIR"

    echo "$server_pid" > "$PID_FILE"

    echo ""
    echo "Server started!"
    echo "Access at: http://localhost:$port"
    echo "PID: $(cat "$PID_FILE")"
    echo ""
    read -p "Press Enter..."
}

stop_server() {
    clear
    echo ""
    echo "=== STOP FILE SERVER ==="
    echo ""

    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo "Server stopped! (PID: $pid)"
            echo "$(date) | Server STOPPED | PID: $pid" >> "$LOG_FILE"
        else
            echo "Process not found."
        fi
        rm "$PID_FILE"
    else
        echo "No server running."
    fi

    echo ""
    read -p "Press Enter..."
}

show_logs() {
    clear
    echo ""
    echo "=== SERVER LOGS ==="
    echo ""

    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        cat "$LOG_FILE"
    else
        echo "No logs found."
    fi

    echo ""
    read -p "Press Enter..."
}

while true; do
    clear
    echo ""
    echo "=== FILE SERVER ==="
    echo "1. Start Server"
    echo "2. Stop Server"
    echo "3. View Logs"
    echo "4. Back to Menu"
    echo -n "Choice: "
    read choice

    if [ "$choice" = "1" ]; then
        start_server
    elif [ "$choice" = "2" ]; then
        stop_server
    elif [ "$choice" = "3" ]; then
        show_logs
    elif [ "$choice" = "4" ]; then
        exit 0
    else
        echo "Invalid choice"
        sleep 1
    fi
done
