#!/bin/bash
source utils.sh

echo -e "${BLUE}==== Task Manager ====${RESET}"

while true; do
    echo
    echo -e "${YELLOW}1) List top CPU consuming processes${RESET}"
    echo "2) List top Memory consuming processes"
    echo "3) Search for a process by name"
    echo "4) Kill a process by PID"
    echo "5) Kill processes by name pattern"
    echo "6) Suspend/Resume a process"
    echo "7) Return to main menu"
    echo

    read -p "Enter choice: " tchoice
    echo

    case $tchoice in
        1)
            echo -e "${CYAN}Top 10 CPU Consuming Processes:${RESET}"
            printf "%-8s %-12s %-8s %-25s\n" "PID" "USER" "%CPU" "COMMAND"
            printf "%-8s %-12s %-8s %-25s\n" "--------" "------------" "------" "-------------------------"

            ps -eo pid,user,%cpu,comm --sort=-%cpu | head -n 11 | tail -n 10 | \
            awk '{ printf "%-8s %-12s %-8s %-25s\n", $1, $2, $3, $4 }'

            log_event "Task Manager" "Listed top 10 CPU processes"
            ;;
        2)
            echo -e "${CYAN}Top 10 Memory Consuming Processes:${RESET}"
            printf "%-8s %-12s %-8s %-25s\n" "PID" "USER" "%MEM" "COMMAND"
            printf "%-8s %-12s %-8s %-25s\n" "--------" "------------" "------" "-------------------------"

            ps -eo pid,user,%mem,comm --sort=-%mem | head -n 11 | tail -n 10 | \
            awk '{ printf "%-8s %-12s %-8s %-25s\n", $1, $2, $3, $4 }'

            log_event "Task Manager" "Listed top 10 Memory processes"
            ;;
        3)
            read -p "Enter process name or pattern: " pname
            echo -e "${CYAN}Matching Processes:${RESET}"

            printf "%-8s %-12s %-8s %-8s %-25s\n" "PID" "USER" "%CPU" "%MEM" "COMMAND"
            printf "%-8s %-12s %-8s %-8s %-25s\n" "--------" "------------" "------" "------" "-------------------------"

            ps -eo pid,user,%cpu,%mem,comm | grep -i "$pname" | grep -v grep | \
            awk '{ printf "%-8s %-12s %-8s %-8s %-25s\n", $1, $2, $3, $4, $5 }'

            log_event "Task Manager" "Searched for processes matching '$pname'"
            ;;
        4)
            read -p "Enter PID to kill: " pid
            if kill -9 $pid 2>/dev/null; then
                echo -e "${GREEN}Process $pid killed.${RESET}"
                log_event "Task Manager" "Killed PID $pid"
            else
                echo -e "${RED}Failed to kill PID $pid or invalid PID.${RESET}"
                log_event "Task Manager" "Failed to kill PID $pid"
            fi
            ;;
        5)
            read -p "Enter process name pattern to kill: " pname
            pids=$(pgrep -f "$pname")
            if [ -z "$pids" ]; then
                echo -e "${RED}No processes found matching '$pname'.${RESET}"
                log_event "Task Manager" "No processes found to kill matching '$pname'"
            else
                echo "$pids" | xargs -r kill -9
                echo -e "${GREEN}Killed processes matching '$pname': $pids${RESET}"
                log_event "Task Manager" "Killed processes matching '$pname': $pids"
            fi
            ;;
        6)
            read -p "Enter PID to suspend/resume: " pid
            read -p "Choose action (suspend/resume): " action
            if [[ "$action" == "suspend" ]]; then
                kill -STOP $pid 2>/dev/null && echo -e "${GREEN}Process $pid suspended.${RESET}" && log_event "Task Manager" "Suspended PID $pid" || echo -e "${RED}Failed to suspend PID $pid.${RESET}"
            elif [[ "$action" == "resume" ]]; then
                kill -CONT $pid 2>/dev/null && echo -e "${GREEN}Process $pid resumed.${RESET}" && log_event "Task Manager" "Resumed PID $pid" || echo -e "${RED}Failed to resume PID $pid.${RESET}"
            else
                echo -e "${RED}Invalid action.${RESET}"
            fi
            ;;
        7)
            break
            ;;
        *)
            echo -e "${RED}Invalid choice${RESET}"
            ;;
    esac
done
