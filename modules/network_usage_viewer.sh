#!/bin/bash
REPORT_DIR="reports"
mkdir -p "$REPORT_DIR"

while true; do
    clear
    echo "========================================="
    echo "        ORBIS – Network Usage Viewer"
    echo "========================================="
    echo
    echo "1) Network Summary"
    echo "2) Active Internet Connections"
    echo "3) Network Interface Usage"
    echo "4) Save Interface Usage Report"
    echo "5) Back to Main Menu"
    echo

    read -p "Choose an option [1-5]: " choice
    case "$choice" in
        1)
            clear
            echo "---- Network Summary ----"
            printf "+------------+----------------------+------------+\n"
            printf "| %-10s | %-20s | %-10s |\n" "INTERFACE" "IP ADDRESS" "STATE"
            printf "+------------+----------------------+------------+\n"
            ip -br addr | awk '{printf "| %-10s | %-20s | %-10s |\n",$1,$3,$2}'
            printf "+------------+----------------------+------------+\n"
            ;;

        2)
            clear
            echo "---- Active Internet Connections ----"
            printf "+--------+------------------------+------------------------+------------+\n"
            printf "| %-6s | %-22s | %-22s | %-10s |\n" "PROTO" "LOCAL ADDRESS" "REMOTE ADDRESS" "STATE"
            printf "+--------+------------------------+------------------------+------------+\n"
            ss -tun | awk 'NR>1 {
                state=$2
                if(state=="ESTAB") color="\033[32m"
                else if(state=="CLOSE-WAIT") color="\033[31m"
                else color="\033[0m"
                
                local=$5
                remote=$6
                if(length(local)>22) local=substr(local,1,22)
                if(length(remote)>22) remote=substr(remote,1,22)
                printf "| %-6s | %-22s | %-22s | %s%-10s\033[0m |\n",$1,local,remote,color,$2
            }' | head -20
            printf "+--------+------------------------+------------------------+------------+\n"
            ;;

        3)
            clear
            echo "---- Network Interface Usage (MB) ----"
            printf "+------------+-----------------+-----------------+\n"
            printf "| %-10s | %-15s | %-15s |\n" "INTERFACE" "RECEIVED" "SENT"
            printf "+------------+-----------------+-----------------+\n"
            awk 'NR>2 {
                rx=$2/1024/1024
                tx=$10/1024/1024
                gsub(":", "", $1)
                printf "| %-10s | %-15.2f | %-15.2f |\n",$1,rx,tx
            }' /proc/net/dev
            printf "+------------+-----------------+-----------------+\n"
            ;;

        4)
            file="$REPORT_DIR/network_usage_$(date +%F_%H%M%S).txt"
            {
                printf "+------------+-----------------+-----------------+\n"
                printf "| %-10s | %-15s | %-15s |\n" "INTERFACE" "RECEIVED" "SENT"
                printf "+------------+-----------------+-----------------+\n"
                awk 'NR>2 {
                    rx=$2/1024/1024
                    tx=$10/1024/1024
                    gsub(":", "", $1)
                    printf "| %-10s | %-15.2f | %-15.2f |\n",$1,rx,tx
                }' /proc/net/dev
                printf "+------------+-----------------+-----------------+\n"
            } > "$file"
            echo "Network usage report saved at $file"
            log_event "NetworkUsageViewer" "Saved report: $file" "INFO"
            ;;

        5) break ;;
        *) echo "Invalid option." ;;
    esac

    echo
    read -p "Press Enter to continue..."
done