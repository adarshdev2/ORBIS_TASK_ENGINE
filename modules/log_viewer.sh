#!/bin/bash
# ORBIS – Log Viewer

# Load utilities (REQUIRED)
source utils.sh

DB_PATH="db/orbis_engine.db"
REPORT_DIR="reports"
mkdir -p "$REPORT_DIR"

while true; do
    clear
    echo "======================================"
    echo "            ORBIS – Log Viewer"
    echo "======================================"
    echo
    echo "1) Recent Logs"
    echo "2) Search Logs"
    echo "3) Error Logs"
    echo "4) Save Search Result"
    echo "5) Back to Main Menu"
    echo

    read -p "Choose an option [1-5]: " choice
    case "$choice" in

        1)
            read -p "Number of recent logs (default 10): " n
            show_logs "${n:-10}"
            ;;

        2)
            read -p "Enter keyword to search: " kw
            clear
            echo "---- Search Logs ----"
            printf "%-20s %-8s %-20s %-s\n" "TIMESTAMP" "LEVEL" "MODULE" "MESSAGE"
            echo "---------------------------------------------------------------"

            sqlite3 "$DB_PATH" \
            "SELECT timestamp, level, module, message FROM logs
             WHERE message LIKE '%$kw%'
             ORDER BY id DESC;" | \
            while IFS='|' read -r ts lvl mod msg; do
                case "$lvl" in
                    INFO) color="$GREEN" ;;
                    WARN) color="$YELLOW" ;;
                    ERROR) color="$RED" ;;
                    *) color="$RESET" ;;
                esac
                printf "%-20s ${color}%-8s${RESET} %-20s %-s\n" \
                       "$ts" "$lvl" "$mod" "$msg"
            done
            ;;

        3)
            clear
            echo "---- Error Logs ----"
            printf "%-20s %-8s %-20s %-s\n" "TIMESTAMP" "LEVEL" "MODULE" "MESSAGE"
            echo "---------------------------------------------------------------"

            sqlite3 "$DB_PATH" \
            "SELECT timestamp, level, module, message FROM logs
             WHERE level='ERROR'
             ORDER BY id DESC;" | \
            while IFS='|' read -r ts lvl mod msg; do
                printf "%-20s ${RED}%-8s${RESET} %-20s %-s\n" \
                       "$ts" "$lvl" "$mod" "$msg"
            done
            ;;

        4)
            read -p "Enter keyword to save: " kw
            file="$REPORT_DIR/log_search_$(date +%F_%H%M%S).txt"

            sqlite3 "$DB_PATH" \
            "SELECT timestamp, level, module, message FROM logs
             WHERE message LIKE '%$kw%'
             ORDER BY id DESC;" > "$file"

            echo -e "${GREEN}Search results saved at $file${RESET}"
            log_event "LogViewer" "Saved log search result: $file" "INFO"
            ;;

        5)
            log_event "LogViewer" "Exited Log Viewer module" "INFO"
            break
            ;;

        *)
            echo -e "${RED}Invalid option.${RESET}"
            ;;
    esac

    echo
    read -p "Press Enter to continue..."
done
