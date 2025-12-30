#!/bin/bash
# Orbis Task Engine – Scheduled Task Runner

# Load utilities for logging
source utils.sh

# Task storage file
TASK_FILE="db/orbis_tasks.txt"
mkdir -p db
touch "$TASK_FILE"

while true; do
    clear
    echo "========================================"
    echo "        ORBIS – Scheduled Task Runner"
    echo "========================================"
    echo
    echo "1) Add Scheduled Task"
    echo "2) Add One-Time Task (Immediate)"
    echo "3) List Tasks"
    echo "4) Remove Task"
    echo "5) Remove All Tasks"
    echo "6) Back to Main Menu"
    echo

    read -p "Choose an option [1-6]: " choice
    case "$choice" in
        1)
            read -p "Enter task name: " tname
            read -p "Enter schedule (cron format, e.g., */5 * * * *): " schedule
            read -p "Enter command to run: " cmd
            echo "$tname|$schedule|$cmd" >> "$TASK_FILE"
            echo -e "${GREEN}Task '$tname' added successfully!${RESET}"
            log_event "ScheduledTaskRunner" "Added scheduled task: $tname" "INFO"
            ;;
        2)
            read -p "Enter task name: " tname
            read -p "Enter command to run immediately: " cmd
            bash -c "$cmd" &
            echo "$tname|$(date '+%Y-%m-%d %H:%M:%S')|$cmd|ONE-TIME" >> "$TASK_FILE"
            echo -e "${GREEN}One-time task '$tname' executed immediately!${RESET}"
            log_event "ScheduledTaskRunner" "Executed one-time task: $tname" "INFO"
            ;;
        3)
            clear
            echo "---- Scheduled Tasks ----"
            printf "%-5s %-20s %-20s %-s\n" "ID" "TASK NAME" "SCHEDULE/EXEC TIME" "COMMAND"
            echo "---------------------------------------------------------------"
            nl -w2 -s'. ' "$TASK_FILE" | awk -F'|' '{printf "%-5s %-20s %-20s %-s\n",$1,$2,$3,$4}'
            ;;
        4)
            read -p "Enter task ID or Name to remove: " val
            if [[ "$val" =~ ^[0-9]+$ ]]; then
                sed -i "${val}d" "$TASK_FILE"
            else
                grep -v "^$val|" "$TASK_FILE" > "${TASK_FILE}.tmp" && mv "${TASK_FILE}.tmp" "$TASK_FILE"
            fi
            echo -e "${YELLOW}Task '$val' removed (if existed).${RESET}"
            log_event "ScheduledTaskRunner" "Removed task: $val" "WARN"
            ;;
        5)
            read -p "Are you sure to remove all tasks? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                > "$TASK_FILE"
                echo -e "${YELLOW}All tasks removed.${RESET}"
                log_event "ScheduledTaskRunner" "Removed all tasks" "WARN"
            fi
            ;;
        6) break ;;
        *) echo -e "${RED}Invalid option.${RESET}" ;;
    esac

    echo
    read -p "Press Enter to continue..."
done
