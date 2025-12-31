#!/bin/bash
# ORBIS – App Usage Tracker

# Load utilities for logging and colors
source utils.sh

REPORT_DIR="reports"
mkdir -p "$REPORT_DIR"

while true; do
    clear
    echo "======================================"
    echo "          ORBIS – App Usage Tracker"
    echo "======================================"
    echo
    echo "1) Top Applications (CPU & Memory)"
    echo "2) Search Application"
    echo "3) Save Usage Report"
    echo "4) Kill Application"
    echo "5) Back to Main Menu"
    echo

    read -p "Choose an option [1-5]: " choice
    case "$choice" in
        1)
            clear
            echo "---- Top Applications by CPU ----"
            printf "%-8s %-25s %-6s %-6s\n" "PID" "COMMAND" "CPU%" "MEM%"
            echo "------------------------------------------------------"
            ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -10 | \
            awk '{printf "%-8s %-25s %-6s %-6s\n",$1,$2,$3,$4}'
            ;;
        2)
            read -p "Enter application name to search: " app
            clear
            echo "---- Search Results ----"
            printf "%-8s %-25s %-6s %-6s\n" "PID" "COMMAND" "CPU%" "MEM%"
            ps -eo pid,comm,%cpu,%mem | grep -i "$app" | \
            awk '{printf "%-8s %-25s %-6s %-6s\n",$1,$2,$3,$4}'
            ;;
        3)
            file="$REPORT_DIR/app_usage_$(date +%F_%H%M%S).txt"
            ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -15 > "$file"
            echo -e "${GREEN}App usage report saved at $file${RESET}"
            log_event "AppUsageTracker" "Saved report: $file" "INFO"
            ;;
        4)
            read -p "Enter PID or Command to kill: " val
            if [[ "$val" =~ ^[0-9]+$ ]]; then
                kill -9 "$val" 2>/dev/null && echo -e "${YELLOW}Process $val killed.${RESET}"
            else
                pkill -f "$val" 2>/dev/null && echo -e "${YELLOW}Process '$val' killed.${RESET}"
            fi
            log_event "AppUsageTracker" "Killed process: $val" "WARN"
            ;;
        5) break ;;
        *) echo -e "${RED}Invalid option.${RESET}" ;;
    esac

    echo
    read -p "Press Enter to continue..."
done
