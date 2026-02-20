#!/bin/bash
# ====================================================
# Boot Time Logger Module - Orbis Task Engine
# ====================================================

source utils.sh

MODULE_NAME="Boot Time Logger"

while true; do
    clear
    show_banner
    echo -e "${CYAN}=== $MODULE_NAME ===${RESET}"
    echo
    echo -e "${YELLOW}Select an action:${RESET}"
    echo "1) Log current boot info"
    echo "2) View last boot record"
    echo "3) Show recent boot logs (Structured Table)"
    echo "4) Generate detailed boot report"
    echo "5) Return to main menu"
    echo

    read -p "Enter your choice [1-5]: " sub_choice
    echo

    case "$sub_choice" in
        1)
            echo -e "${BLUE}Collecting current boot information...${RESET}"

            BOOT_TIME=$(uptime -s)
            UP_TIME=$(uptime -p)
            KERNEL=$(uname -r)
            LAST_LOGGED=$(who -b | awk '{print $3" "$4}')
            BOOT_COUNT=$(last reboot | grep -c "reboot")
            HOST=$(hostname)
            USER=$(whoami)

            echo -e "${GREEN}System Boot Time:${RESET} $BOOT_TIME"
            echo -e "${GREEN}Uptime:${RESET} $UP_TIME"
            echo -e "${GREEN}Kernel:${RESET} $KERNEL"
            echo -e "${GREEN}Last Boot:${RESET} $LAST_LOGGED"
            echo -e "${GREEN}Boot Count:${RESET} $BOOT_COUNT"
            echo -e "${GREEN}Host:${RESET} $HOST"
            echo -e "${GREEN}User:${RESET} $USER"

            log_event "$MODULE_NAME" "Boot info recorded (Boot Time: $BOOT_TIME, Uptime: $UP_TIME)" "INFO"
            ;;
            
        2)
            echo -e "${YELLOW}Fetching last boot record from DB...${RESET}"
            echo
            sqlite3 "$DB_PATH" "SELECT timestamp, message FROM logs WHERE module='$MODULE_NAME' ORDER BY id DESC LIMIT 1;" | \
            while IFS='|' read -r ts msg; do
                echo -e "${CYAN}$ts${RESET} → ${WHITE}$msg${RESET}"
            done

            log_event "$MODULE_NAME" "Viewed last boot record" "INFO"
            ;;

        3)
            echo -e "${YELLOW}Showing latest boot log entries (Structured Table View)...${RESET}"
            echo

            # Table Header
            printf "%-12s | %-8s | %-25s | %s\n" "DATE" "TIME" "SERVICE" "MESSAGE"
            printf "%-12s-+-%-8s-+-%-25s-+-%s\n" \
            "------------" \
            "--------" \
            "-------------------------" \
            "--------------------------------------------------------------"

            # Fetch logs without hint message
            journalctl -b -n 20 --no-pager -q -o short-iso | \
            while read -r line; do

                # Extract date (YYYY-MM-DD)
                date=$(echo "$line" | awk '{print substr($1,1,10)}')

                # Extract time (HH:MM:SS)
                time=$(echo "$line" | awk '{print substr($1,12,8)}')

                # Extract service name (remove colon)
                service=$(echo "$line" | awk '{print $3}' | sed 's/://')

                # Extract full message after service
                message=$(echo "$line" | cut -d' ' -f4-)

                # Print aligned row
                printf "%-12s | %-8s | %-25s | %s\n" \
                "$date" "$time" "$service" "$message"

            done

            echo
            log_event "$MODULE_NAME" "Viewed structured recent boot logs" "INFO"
            ;;

        4)
            echo -e "${BLUE}Generating detailed boot report...${RESET}"

            mkdir -p reports
            REPORT_PATH="reports/boot_report_$(date +%Y%m%d_%H%M%S).txt"

            {
                echo "===== Boot Report ====="
                echo "Generated: $(date)"
                echo "Host: $(hostname)"
                echo "User: $(whoami)"
                echo
                echo "--- System Info ---"
                uname -a
                echo
                echo "--- Boot Time ---"
                uptime -s
                echo "--- Uptime ---"
                uptime -p
                echo
                echo "--- Boot History ---"
                last reboot | head -n 10
                echo
                echo "--- dmesg (Last 10 lines) ---"
                dmesg | tail -n 10
            } > "$REPORT_PATH"

            echo -e "${GREEN}Report saved to:${RESET} $REPORT_PATH"
            log_event "$MODULE_NAME" "Generated boot report: $REPORT_PATH" "INFO"
            ;;

        5)
            echo -e "${MAGENTA}Returning to main menu...${RESET}"
            log_event "$MODULE_NAME" "Exited Boot Time Logger" "INFO"
            break
            ;;
            
        *)
            echo -e "${RED}Invalid choice!${RESET}"
            ;;
    esac

    echo
    read -p "Press any key to continue inside Boot Time Logger..." -n 1 -r
done