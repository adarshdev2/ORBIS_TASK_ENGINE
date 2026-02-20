#!/bin/bash
# Orbis Task Engine – Fully Functional GUI Launcher

# Configuration
TASK_FILE="db/orbis_tasks.txt"
mkdir -p db
touch "$TASK_FILE"

# App Definitions
declare -A APPS_MAP
APPS_MAP=(
    ["firefox"]="/usr/bin/firefox"
    ["gedit"]="/usr/bin/gedit"
    ["nautilus"]="/usr/bin/nautilus"
    ["calculator"]="/usr/bin/gnome-calculator"
    ["terminal"]="/usr/bin/gnome-terminal"
)
APP_NAMES=("firefox" "gedit" "nautilus" "calculator" "terminal")

# --- Helper Functions ---

get_next_run_timestamp() {
    local hour=$1
    local minute=$2
    local now=$(date +%s)
    local run_today=$(date -d "$(date +%Y-%m-%d) $hour:$minute:00" +%s)
    if (( run_today > now )); then
        echo $run_today
    else
        echo $(date -d "tomorrow $hour:$minute:00" +%s)
    fi
}

launch_app() {
    local app_path=$1
    export DISPLAY=${DISPLAY:-:0}
    export XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}

    if [[ -x "$app_path" ]]; then
        # Launch detached from the terminal session
        ( setsid "$app_path" >/dev/null 2>&1 & )
    else
        echo "[$(date)] Error: Cannot execute $app_path" >> error.log
    fi
}

run_due_tasks() {
    local now=$(date +%s)
    local tmp_file="${TASK_FILE}.tmp"
    local launched=0
    
    [[ ! -s "$TASK_FILE" ]] && return
    
    > "$tmp_file"
    while IFS='|' read -r tname ts app type; do
        [[ -z "$tname" ]] && continue
        
        if (( now >= ts )); then
            echo -e "\n\e[32m[!] Launching: $tname...\e[0m"
            launch_app "$app"
            launched=1

            if [[ "$type" == "RECURRING" ]]; then
                local hour=$(date -d "@$ts" +%H)
                local minute=$(date -d "@$ts" +%M)
                local next_ts=$(get_next_run_timestamp "$hour" "$minute")
                echo "$tname|$next_ts|$app|RECURRING" >> "$tmp_file"
            fi
        else
            echo "$tname|$ts|$app|$type" >> "$tmp_file"
        fi
    done < "$TASK_FILE"
    mv "$tmp_file" "$TASK_FILE"
    [[ $launched -eq 1 ]] && sleep 1
}

# --- UI Functions ---

list_tasks() {
    echo "Current Schedule:"
    echo "--------------------------------------------------------------------------------"
    if [[ ! -s "$TASK_FILE" ]]; then
        echo "   (No tasks scheduled)"
    else
        printf "  %-5s %-15s %-20s %-15s\n" "ID" "TASK NAME" "NEXT RUN" "TYPE"
        echo "  ----------------------------------------------------------------------------"
        local id=1
        while IFS='|' read -r tname ts app type; do
            [[ -z "$tname" ]] && continue
            local time_str=$(date -d "@$ts" +"%I:%M %p")
            printf "  %-5s %-15s %-20s %-15s\n" "[$id]" "$tname" "$time_str" "$type"
            ((id++))
        done < "$TASK_FILE"
    fi
    echo "--------------------------------------------------------------------------------"
}

# --- Main Logic ---

while true; do
    clear
    echo "========================================"
    echo "         Scheduled Task Runner          "
    echo "========================================"
    
    run_due_tasks
    list_tasks
    
    echo "Menu: [1] Add Recurring  [2] One-Time  [3] Remove  [4] Clear All  [q] Quit"
    echo -n "Action: "
    
    # Refresh every 2 seconds to check if a task is due
    read -t 2 -n 1 choice
    
    case "$choice" in
        1)
            echo -e "\n\nSelect App:"
            for i in "${!APP_NAMES[@]}"; do echo "$((i+1))) ${APP_NAMES[$i]}"; done
            read -p "Number: " app_idx
            app_name=${APP_NAMES[$((app_idx-1))]}
            app_path=${APPS_MAP[$app_name]}
            
            [[ -z "$app_path" ]] && echo "Invalid selection" && sleep 1 && continue

            read -p "Task Name: " tname
            read -p "Time (e.g. 02:30 pm): " ttime
            
            formatted_time=$(date -d "$ttime" +%H:%M 2>/dev/null)
            if [[ -z "$formatted_time" ]]; then
                echo "Invalid time format!"; sleep 1
            else
                ts=$(get_next_run_timestamp ${formatted_time%%:*} ${formatted_time##*:})
                echo "$tname|$ts|$app_path|RECURRING" >> "$TASK_FILE"
            fi
            ;;
        2)
            echo -e "\n\nSelect App:"
            for i in "${!APP_NAMES[@]}"; do echo "$((i+1))) ${APP_NAMES[$i]}"; done
            read -p "Number: " app_idx
            app_name=${APP_NAMES[$((app_idx-1))]}
            app_path=${APPS_MAP[$app_name]}
            
            [[ -z "$app_path" ]] && echo "Invalid selection" && sleep 1 && continue

            read -p "Label: " tname
            # Adds to file to show in list, but ONE-TIME logic in run_due_tasks will remove it after launch
            echo "$tname|$(date +%s)|$app_path|ONE-TIME" >> "$TASK_FILE"
            ;;
        3)
            echo -e "\n"
            read -p "Enter ID Number or Exact Name to remove: " val
            if [[ -n "$val" ]]; then
                if [[ "$val" =~ ^[0-9]+$ ]]; then
                    # Remove by ID number
                    sed -i "${val}d" "$TASK_FILE"
                    echo "Task #$val removed."
                else
                    # Remove by Name
                    sed -i "/^$val|/d" "$TASK_FILE"
                    echo "Task '$val' removed."
                fi
                sleep 1
            fi
            ;;
        4)
            > "$TASK_FILE"
            echo -e "\nSchedule cleared."; sleep 1
            ;;
        q)
            echo -e "\nExiting..."
            exit 0
            ;;
    esac
done