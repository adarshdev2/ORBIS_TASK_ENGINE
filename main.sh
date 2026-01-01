#!/bin/bash
# Orbis Task Engine - Main CLI

source utils.sh
[ -f config/config.cfg ] && source config/config.cfg

# Validate modules directory
if [ ! -d modules ]; then
    echo -e "${RED}❌ 'modules/' folder not found.${RESET}"
    exit 1
fi

clear
show_banner
loading_animation

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
    echo "7) Scheduled Task Runner"
    echo "8) Network Usage Viewer"
    echo "9) App Usage Tracker"
    echo "10) System Log Viewer"
    echo "11) Orbis Internal Logs"
    echo "12) Exit"
    echo

    read -p "Enter choice [1-12]: " choice
    echo

    MODULE_PATH=""

    case "$choice" in
        1) MODULE_PATH="modules/disk_analyzer.sh" ;;
        2) MODULE_PATH="modules/file_organizer.sh" ;;
        3) MODULE_PATH="modules/resource_monitor.sh" ;;
        4) MODULE_PATH="modules/task_manager.sh" ;;
        5) MODULE_PATH="modules/system_cleaner.sh" ;;
        6) MODULE_PATH="modules/boot_time_logger.sh" ;;
        7) MODULE_PATH="modules/scheduled_task_runner.sh" ;;
        8) MODULE_PATH="modules/network_usage_viewer.sh" ;;
        9) MODULE_PATH="modules/app_usage_tracker.sh" ;;
        10) MODULE_PATH="modules/log_viewer.sh" ;;
        11)
            read -p "How many internal logs? (default 10): " n
            show_logs "${n:-10}"
            read -p "Press Enter to continue..."
            continue
            ;;
        12)
            echo -e "${GREEN}Exiting Orbis Task Engine. Goodbye!${RESET}"
            log_event "MainCLI" "Exited Orbis Task Engine" "INFO"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Try again.${RESET}"
            sleep 1
            continue
            ;;
    esac

    # Execute selected module safely
    if [ -f "$MODULE_PATH" ]; then
        bash "$MODULE_PATH"
        log_event "MainCLI" "Executed module: $MODULE_PATH" "INFO"
    else
        echo -e "${RED}❌ Module not found: $MODULE_PATH${RESET}"
        log_event "MainCLI" "Missing module: $MODULE_PATH" "ERROR"
        sleep 1
    fi
done
