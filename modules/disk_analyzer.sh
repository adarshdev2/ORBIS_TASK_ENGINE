
#!/bin/bash
source utils.sh

echo -e "${BLUE}==== Disk Analyzer (Flexible & Safe) ====${RESET}"

while true; do
    echo ""
    echo "1) Show disk usage summary"
    echo "2) Show top 10 largest files (fast) in a directory"
    echo "3) Show top 10 largest directories (fast) in a directory"
    echo "4) Save report to file (last scanned directory)"
    echo "5) Show previous logs"
    echo "6) Return to main menu"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            echo -e "${YELLOW}Disk Usage Summary:${RESET}"
            df -h
            log_event "Disk Analyzer" "Displayed disk usage summary"
            ;;
        2)
            read -p "Enter directory path (default: $HOME): " dir
            dir=${dir:-$HOME}
            if [ ! -d "$dir" ]; then
                echo -e "${RED}Directory does not exist!${RESET}"
                log_event "Disk Analyzer" "Failed top 10 files: $dir does not exist"
                continue
            fi
            files=$(ls -lSh "$dir" 2>/dev/null | grep '^-')
            if [ -z "$files" ]; then
                echo -e "${YELLOW}No files found in $dir${RESET}"
                log_event "Disk Analyzer" "No files found in $dir"
            else
                echo -e "${YELLOW}Top 10 largest files in $dir:${RESET}"
                echo "$files" | head -n 10
                log_event "Disk Analyzer" "Listed top 10 largest files in $dir"
            fi
            ;;
        3)
            read -p "Enter directory path (default: $HOME): " dir
            dir=${dir:-$HOME}
            if [ ! -d "$dir" ]; then
                echo -e "${RED}Directory does not exist!${RESET}"
                log_event "Disk Analyzer" "Failed top 10 directories: $dir does not exist"
                continue
            fi
            dirs=$(du -sh "$dir"/* 2>/dev/null)
            if [ -z "$dirs" ]; then
                echo -e "${YELLOW}No directories found in $dir${RESET}"
                log_event "Disk Analyzer" "No directories found in $dir"
            else
                echo -e "${YELLOW}Top 10 largest directories in $dir:${RESET}"
                echo "$dirs" | sort -rh | head -n 10
                log_event "Disk Analyzer" "Listed top 10 largest directories in $dir"
            fi
            ;;
        4)
            report_file="db/disk_report_$(date +%F_%H-%M).txt"
            echo -e "${BLUE}Saving report...${RESET}"
            {
                echo "==== Disk Analyzer Report ===="
                echo "Date: $(date)"
                echo ""
                echo "Disk Usage Summary:"
                df -h
                echo ""
                echo "Top 10 largest files in last scanned directory:"
                files=$(ls -lSh "$dir" 2>/dev/null | grep '^-')
                if [ -z "$files" ]; then
                    echo "No files found in $dir"
                else
                    echo "$files" | head -n 10
                fi
                echo ""
                echo "Top 10 largest directories in last scanned directory:"
                dirs=$(du -sh "$dir"/* 2>/dev/null)
                if [ -z "$dirs" ]; then
                    echo "No directories found in $dir"
                else
                    echo "$dirs" | sort -rh | head -n 10
                fi
            } > "$report_file"
            echo -e "${GREEN}Report saved to $report_file${RESET}"
            log_event "Disk Analyzer" "Saved disk analysis report to $report_file"
            ;;
        5)
            echo -e "${BLUE}==== Previous Disk Analyzer Logs ====${RESET}"
            sqlite3 db/orbis_engine.db "SELECT id, timestamp, message FROM logs WHERE module='Disk Analyzer' ORDER BY id DESC LIMIT 20;"
            ;;
        6)
            break
            ;;
        *)
            echo -e "${RED}Invalid choice${RESET}"
            ;;
    esac

    read -p "Press Enter to continue..."
done
