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
            printf "%-12s %-20s %-12s\n" "INTERFACE" "IP ADDRESS" "STATE"
            echo "------------------------------------------------"
            ip -br addr | awk '{printf "%-12s %-20s %-12s\n",$1,$3,$2}'
            ;;
        2)
            clear
            echo "---- Active Internet Connections ----"
            printf "%-6s %-22s %-22s %-10s\n" "PROTO" "LOCAL ADDRESS" "REMOTE ADDRESS" "STATE"
            echo "---------------------------------------------------------------------"
            ss -tun | awk 'NR>1 {
                state=$2
                if(state=="ESTAB") color="\033[32m"
                else if(state=="CLOSE-WAIT") color="\033[31m"
                else color="\033[0m"
                printf "%-6s %-22s %-22s ${color}%-10s\033[0m\n",$1,$5,$6,$2
            }' | head -20
            ;;
        3)
            clear
            echo "---- Network Interface Usage (MB) ----"
            printf "%-12s %-15s %-15s\n" "INTERFACE" "RECEIVED" "SENT"
            echo "------------------------------------------------"
            awk 'NR>2 {rx=$2/1024/1024; tx=$10/1024/1024; printf "%-12s %-15.2f %-15.2f\n",$1,rx,tx}' /proc/net/dev | sed 's/://'
            ;;
        4)
            file="$REPORT_DIR/network_usage_$(date +%F_%H%M%S).txt"
            awk 'NR>2 {rx=$2/1024/1024; tx=$10/1024/1024; printf "%-12s %-15.2f %-15.2f\n",$1,rx,tx}' /proc/net/dev | sed 's/://' > "$file"
            echo "Network usage report saved at $file"
            log_event "NetworkUsageViewer" "Saved report: $file" "INFO"
            ;;
        5) break ;;
        *) echo "Invalid option." ;;
    esac

    echo
    read -p "Press Enter to continue..."
done
