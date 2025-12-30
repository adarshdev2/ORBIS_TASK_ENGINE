#!/bin/bash

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
            sqlite3 db/orbis_engine.db "SELECT timestamp, level, module, message FROM logs WHERE message LIKE '%$kw%' ORDER BY id DESC;" | \
            while IFS='|' read -r ts lvl mod msg; do
                case "$lvl" in
                    INFO) color="\e[32m" ;;
                    WARN) color="\e[33m" ;;
                    ERROR) color="\e[31m" ;;
                    *) color="\e[0m" ;;
                esac
                printf "%-20s ${color}%-8s\e[0m %-20s %-s\n" "$ts" "$lvl" "$mod" "$msg"
            done
            ;;
        3)
            clear
            echo "---- Error Logs ----"
            sqlite3 db/orbis_engine.db "SELECT timestamp, level, module, message FROM logs WHERE level='ERROR' ORDER BY id DESC;" | \
            while IFS='|' read -r ts lvl mod msg; do
                printf "%-20s \e[31m%-8s\e[0m %-20s %-s\n" "$ts" "$lvl" "$mod" "$msg"
            done
            ;;
        4)
            read -p "Enter keyword to save: " kw
            file="reports/log_search_$(date +%F_%H%M%S).txt"
            sqlite3 db/orbis_engine.db "SELECT timestamp, level, module, message FROM logs WHERE message LIKE '%$kw%' ORDER BY id DESC;" > "$file"
            echo "Search results saved at $file"
            log_event "LogViewer" "Saved log search result: $file" "INFO"
            ;;
        5) break ;;
        *) echo "Invalid option." ;;
    esac

    echo
    read -p "Press Enter to continue..."
done
    