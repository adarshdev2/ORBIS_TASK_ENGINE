#!/bin/bash
# Orbis Task Engine - Main CLI 

# Load utility functions (colors + DB + logger)
source utils.sh

# Optional: Load configuration file
[ -f config/config.cfg ] && source config/config.cfg

# Ensure modules directory exists
[ ! -d modules ] && { echo -e "${RED}❌ 'modules/' folder not found. Please create it and add modules.${RESET}"; exit 1; }

clear
show_banner
loading_animation

# Display version info
echo -e "${BLUE}Orbis Task Engine v1.0${RESET}"
echo "Developed by MR ADARSH P"
sleep 2

while true; do
    clear
    show_banner
   
    echo -e "${YELLOW}Select a module to run:${RESET}"
    echo "1) Disk Analyzer"
    echo "2) File Organizer"
    echo "3) Resource Monitor"
    echo "4) Task Manager"
    echo "5) System Cleaner"
    echo "6) Boot Time Logger"
    echo "7) View Recent Logs"
    echo "8) Exit"
    echo

    read -p "Enter choice [1-8]: " choice
    echo

    case "$choice" in
        1) MODULE_PATH="modules/disk_analyzer.sh" ;;
        2) MODULE_PATH="modules/file_organizer.sh" ;;
        3) MODULE_PATH="modules/resource_monitor.sh" ;;
        4) MODULE_PATH="modules/task_manager.sh" ;;
        5) MODULE_PATH="modules/system_cleaner.sh" ;;
        6) MODULE_PATH="modules/boot_time_logger.sh" ;;
        7)
            read -p "How many recent logs to display? (default 10): " logcount
            logcount=${logcount:-10}
            show_logs "$logcount"
            read -p "Press Enter to return to the main menu..."
            continue
            ;;
        8)
            echo -e "${GREEN}Exiting Orbis Task Engine. Goodbye!${RESET}"
            log_event "System" "Exited Orbis Task Engine CLI" "INFO"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${RESET}"
            sleep 1
            continue
            ;;
    esac

    # Check if module exists before running
    if [ -f "$MODULE_PATH" ]; then
        bash "$MODULE_PATH"
        log_event "System" "Executed module: $MODULE_PATH" "INFO"
    else
        echo -e "${RED}Module not found: $MODULE_PATH${RESET}"
        log_event "System" "Attempted to run missing module: $MODULE_PATH" "ERROR"
        sleep 1
    fi

    echo
    read -p "Press Enter to return to the main menu..."
done
