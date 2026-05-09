#!/bin/bash

USER_FILE=".sentinel_users"

if [ ! -f "$USER_FILE" ]; then
    touch "$USER_FILE"
    chmod 600 "$USER_FILE"
fi

hash_password() {
    echo -n "$1" | sha256sum | cut -d' ' -f1
}

sign_up() {
    echo ""
    echo "=== CREATE ACCOUNT ==="
    echo -n "Username: "
    read u
    echo -n "Password: "
    read -s p
    echo ""
    echo -n "Confirm: "
    read -s p2
    echo ""

    if [ "$p" != "$p2" ]; then
        echo "Passwords don't match!"
        return
    fi

    if grep -q "^$u:" "$USER_FILE"; then
        echo "Username exists!"
        return
    fi

    hashed=$(hash_password "$p")
    echo "$u:$hashed" >> "$USER_FILE"
    echo "Account created!"
}

sign_in() {
    echo ""
    echo "=== SIGN IN ==="
    echo -n "Username: "
    read u
    echo -n "Password: "
    read -s p
    echo ""

    hashed=$(hash_password "$p")

    if grep -q "^$u:$hashed$" "$USER_FILE"; then
        echo "Login successful!"
        return 0
    else
        echo "Login failed!"
        return 1
    fi
}

menu() {
    while true; do
        clear
        echo ""
        echo "=== THE SENTINEL ==="
        echo "1. System Monitor"
        echo "2. Backup"
        echo "3. Tasks"
        echo "4. Remote Monitor"
        echo "5. File Server"
        echo "6. Exit"
        echo -n "Choice: "
        read c

        if [ "$c" = "1" ]; then
            ./monitor.sh
        elif [ "$c" = "2" ]; then
            ./backup.sh
        elif [ "$c" = "3" ]; then
            ./tasks.sh
        elif [ "$c" = "4" ]; then
            ./uptime.sh
        elif [ "$c" = "5" ]; then
            ./fileserver.sh
        elif [ "$c" = "6" ]; then
            echo "Goodbye!"
            exit 0
        else
            echo "Invalid choice"
            sleep 1
        fi
    done
}

clear
echo "=== WELCOME TO SENTINEL ==="

while true; do
    echo ""
    echo "1. Sign In"
    echo "2. Sign Up"
    echo "3. Exit"
    echo -n "Choice: "
    read choice

    if [ "$choice" = "1" ]; then
        if sign_in; then
            menu
        fi
    elif [ "$choice" = "2" ]; then
        sign_up
    elif [ "$choice" = "3" ]; then
        echo "Goodbye!"
        exit 0
    else
        echo "Invalid choice"
    fi
done
