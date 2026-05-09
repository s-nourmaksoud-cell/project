#!/bin/bash

TASK_FILE=".admin_tasks.csv"

if [ ! -f "$TASK_FILE" ]; then
    echo "PRIORITY,DUE_DATE,DESCRIPTION" > "$TASK_FILE"
fi

view_tasks() {
    echo ""
    echo "=== ADMIN TASKS ==="
    echo ""

    line_count=$(wc -l < "$TASK_FILE")
    if [ "$line_count" -le 1 ]; then
        echo "No tasks found."
        echo ""
        return
    fi

    echo "ID | Priority | Due Date | Description"
    echo "----------------------------------------"

    # Sort by priority (HIGH, MED, LOW) then by due date within each priority
    tail -n +2 "$TASK_FILE" | sort -t',' -k1,1 -k2,2 > /tmp/sorted_tasks.txt 2>/dev/null

    # Reorder: HIGH first, then MED, then LOW (sort puts LOW before MED before HIGH alphabetically)
    grep "^HIGH" /tmp/sorted_tasks.txt > /tmp/high_tasks.txt 2>/dev/null
    grep "^MED" /tmp/sorted_tasks.txt > /tmp/med_tasks.txt 2>/dev/null
    grep "^LOW" /tmp/sorted_tasks.txt > /tmp/low_tasks.txt 2>/dev/null

    id=1
    if [ -s /tmp/high_tasks.txt ]; then
        while IFS= read -r line; do
            echo "$id | $line"
            id=$((id + 1))
        done < /tmp/high_tasks.txt
    fi
    if [ -s /tmp/med_tasks.txt ]; then
        while IFS= read -r line; do
            echo "$id | $line"
            id=$((id + 1))
        done < /tmp/med_tasks.txt
    fi
    if [ -s /tmp/low_tasks.txt ]; then
        while IFS= read -r line; do
            echo "$id | $line"
            id=$((id + 1))
        done < /tmp/low_tasks.txt
    fi

    echo "----------------------------------------"
    echo ""

    rm -f /tmp/sorted_tasks.txt /tmp/high_tasks.txt /tmp/med_tasks.txt /tmp/low_tasks.txt
}

add_task() {
    echo ""
    echo "=== ADD TASK ==="
    echo ""
    echo -n "Priority (HIGH/MED/LOW): "
    read priority

    if [ "$priority" != "HIGH" ] && [ "$priority" != "MED" ] && [ "$priority" != "LOW" ]; then
        echo "Invalid priority! Use HIGH, MED, or LOW."
        return
    fi

    echo -n "Due date (YYYY-MM-DD): "
    read due_date

    if [ ${#due_date} -ne 10 ]; then
        echo "Invalid date format! Use YYYY-MM-DD"
        return
    fi

    echo -n "Description: "
    read description

    echo "$priority,$due_date,$description" >> "$TASK_FILE"
    echo "Task added!"
}

edit_task() {
    echo ""
    echo "=== EDIT TASK ==="
    echo ""

    line_count=$(wc -l < "$TASK_FILE")
    if [ "$line_count" -le 1 ]; then
        echo "No tasks to edit."
        return
    fi

    view_tasks
    echo -n "Enter task ID to edit: "
    read task_id

    if ! [ "$task_id" -eq "$task_id" ] 2>/dev/null; then
        echo "Invalid ID!"
        return
    fi

    # Fix: Valid IDs are 1 to (line_count - 1) because line 1 is header
    if [ "$task_id" -lt 1 ] || [ "$task_id" -ge "$line_count" ]; then
        echo "Invalid ID!"
        return
    fi

    # Adjust: Add 1 to task_id because line 1 is header
    actual_line=$((task_id + 1))

    echo -n "New Priority (HIGH/MED/LOW): "
    read new_priority
    if [ "$new_priority" != "HIGH" ] && [ "$new_priority" != "MED" ] && [ "$new_priority" != "LOW" ]; then
        echo "Invalid priority!"
        return
    fi

    echo -n "New Due date (YYYY-MM-DD): "
    read new_date
    if [ ${#new_date} -ne 10 ]; then
        echo "Invalid date format!"
        return
    fi

    echo -n "New Description: "
    read new_desc

    temp_file=$(mktemp)
    counter=1
    while IFS= read -r current_line; do
        if [ "$counter" -eq "$actual_line" ]; then
            echo "$new_priority,$new_date,$new_desc" >> "$temp_file"
        else
            echo "$current_line" >> "$temp_file"
        fi
        counter=$((counter + 1))
    done < "$TASK_FILE"

    mv "$temp_file" "$TASK_FILE"
    echo "Task updated!"
}

delete_task() {
    echo ""
    echo "=== DELETE TASK ==="
    echo ""

    line_count=$(wc -l < "$TASK_FILE")
    if [ "$line_count" -le 1 ]; then
        echo "No tasks to delete."
        return
    fi

    view_tasks
    echo -n "Enter task ID to delete: "
    read task_id

    if ! [ "$task_id" -eq "$task_id" ] 2>/dev/null; then
        echo "Invalid ID!"
        return
    fi

    # Fix: Valid IDs are 1 to (line_count - 1)
    if [ "$task_id" -lt 1 ] || [ "$task_id" -ge "$line_count" ]; then
        echo "Invalid ID!"
        return
    fi

    # Adjust: Add 1 to task_id because line 1 is header
    actual_line=$((task_id + 1))

    temp_file=$(mktemp)
    echo "PRIORITY,DUE_DATE,DESCRIPTION" > "$temp_file"

    counter=1
    while IFS= read -r current_line; do
        if [ "$counter" -ne "$actual_line" ]; then
            echo "$current_line" >> "$temp_file"
        fi
        counter=$((counter + 1))
    done < "$TASK_FILE"

    mv "$temp_file" "$TASK_FILE"
    echo "Task deleted!"
}

while true; do
    clear
    echo ""
    echo "=== TASK MANAGER ==="
    echo "1. View Tasks"
    echo "2. Add Task"
    echo "3. Edit Task"
    echo "4. Delete Task"
    echo "5. Back to Menu"
    echo -n "Choice: "
    read choice

    if [ "$choice" = "1" ]; then
        view_tasks
        read -p "Press Enter..."
    elif [ "$choice" = "2" ]; then
        add_task
        read -p "Press Enter..."
    elif [ "$choice" = "3" ]; then
        edit_task
        read -p "Press Enter..."
    elif [ "$choice" = "4" ]; then
        delete_task
        read -p "Press Enter..."
    elif [ "$choice" = "5" ]; then
        exit 0
    else
        echo "Invalid choice"
        sleep 1
    fi
done
