#!/bin/bash
source utils.sh

echo -e "${BLUE}==== Resource Monitor ====${RESET}"

# Get system info
cpu_usage=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}') 
mem_used=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
disk_used=$(df -h / | awk 'NR==2 {print $3 "/" $2}')
net_conn=$(ss -tun | wc -l)
uptime=$(uptime -p)

# Optional: Get top 3 memory-heavy processes
top_processes=$(ps --sort=-%mem -eo pid,comm,%mem --no-headers | head -n 3)

# Optional: Battery (for laptops)
if [ -f /sys/class/power_supply/BAT0/capacity ]; then
    battery="$(cat /sys/class/power_supply/BAT0/capacity)%"
else
    battery="N/A"
fi

# Optional: Temperature (if sensors available)
if command -v sensors &> /dev/null; then
    temp=$(sensors | grep -m1 'temp1' | awk '{print $2}')
else
    temp="N/A"
fi

# Display everything
echo -e "${YELLOW}CPU Usage:        %${cpu_usage}${RESET}"
echo -e "${YELLOW}Memory Usage:     ${mem_used}${RESET}"
echo -e "${YELLOW}Disk Usage:       ${disk_used}${RESET}"
echo -e "${YELLOW}Network Conns:    ${net_conn}${RESET}"
echo -e "${YELLOW}Uptime:           ${uptime}${RESET}"
echo -e "${YELLOW}Battery:          ${battery}${RESET}"
echo -e "${YELLOW}Temperature:      ${temp}${RESET}"
echo -e "${YELLOW}Top 3 RAM Processes:${RESET}"
echo -e "${CYAN}$top_processes${RESET}"

# Log to SQLite
log_event "Resource Monitor" "CPU:$cpu_usage Mem:$mem_used Disk:$disk_used Net:$net_conn Temp:$temp Batt:$battery"

# Ask to save report
read -p "Save this snapshot as report file? (y/n): " save_report
if [[ "$save_report" == "y" || "$save_report" == "Y" ]]; then
    report_file="reports/resource_monitor_$(date +%Y%m%d_%H%M%S).log"
    mkdir -p reports
    {
        echo "=== Orbis Resource Monitor Report ==="
        echo "Date: $(date)"
        echo "CPU Usage: %$cpu_usage"
        echo "Memory Usage: $mem_used"
        echo "Disk Usage: $disk_used"
        echo "Network Connections: $net_conn"
        echo "Uptime: $uptime"
        echo "Battery: $battery"
        echo "Temperature: $temp"
        echo "Top RAM Processes:"
        echo "$top_processes"
    } >> "$report_file"
    echo -e "${GREEN}✅ Report saved to $report_file${RESET}"
fi
