#!/bin/bash
# Utilities for Orbis Task Engine

# === Terminal Colors ===
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
RESET="\e[0m"

# === Path to SQLite DB ===
DB_PATH="db/orbis_engine.db"

# === Setup Directories ===
mkdir -p "$(dirname "$DB_PATH")"
mkdir -p modules
mkdir -p reports
mkdir -p logs

# === Check sqlite3 ===
if ! command -v sqlite3 &> /dev/null; then
    echo -e "${RED}❌ sqlite3 is not installed. Please install it.${RESET}"
    exit 1
fi

# === Create DB if missing ===
[ ! -f "$DB_PATH" ] && touch "$DB_PATH"

# === Create logs table ===
sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS logs(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    module TEXT,
    level TEXT,
    message TEXT,
    timestamp TEXT
);"

# === Logger Function ===
log_event() {
    local module="$1"
    local message="$2"
    local level="${3:-INFO}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Escape single quotes for SQLite
    message="${message//\'/\'\'}"
    module="${module//\'/\'\'}"
    level="${level//\'/\'\'}"

    sqlite3 "$DB_PATH" "INSERT INTO logs (module, level, message, timestamp)
                        VALUES ('$module', '$level', '$message', '$timestamp');"

    echo "[$timestamp] [$level] [$module] $message" >> logs/orbis_engine.log
}

# === Show last N logs ===
show_logs() {
    local n="${1:-10}"
    echo -e "${CYAN}=== Last $n Logs ===${RESET}"
    printf "%-20s %-8s %-20s %-s\n" "TIMESTAMP" "LEVEL" "MODULE" "MESSAGE"
    sqlite3 "$DB_PATH" "SELECT timestamp, level, module, message FROM logs ORDER BY id DESC LIMIT $n;" | \
	while IFS='|' read -r ts lvl mod msg; do
    	case "$lvl" in
       	 INFO) color="$GREEN" ;;
       	 WARN) color="$YELLOW" ;;
       	 ERROR) color="$RED" ;;
       	 *) color="$RESET" ;;
   	    esac
   	    printf "%-20s ${color}%-8s${RESET} %-20s %-s\n" "$ts" "$lvl" "$mod" "$msg"
    done
}

# === Banner ===
# === Banner ===
show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
 ██████╗ ██████╗ ██████╗ ██╗███████╗     ████████╗ █████╗ ███████╗██╗  ██╗
██╔═══██╗██╔══██╗██╔══██╗██║██╔════╝     ╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝
██║   ██║██████╔╝██║████║██║███████╗        ██║   ███████║███████╗█████╔╝ 
██║   ██║██╔══██╗██║  ██║██║╚════██║        ██║   ██╔══██║╚════██║██╔═██╗ 
╚██████╔╝██║  ██║██████╔╝██║███████║        ██║   ██║  ██║███████║██║  ██╗
 ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝╚══════╝        ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

                  ███████╗███╗  ██╗ ██████╗ ██╗███╗  ██╗███████╗
                  ██╔════╝████╗ ██║██╔════╝ ██║████╗ ██║██╔════╝
                  █████╗  ██╔██╗██║██║  ███╗██║██╔██╗██║█████╗  
                  ██╔══╝  ██║╚████║██║   ██║██║██║╚████║██╔══╝  
                  ███████╗██║ ╚███║╚██████╔╝██║██║ ╚███║███████╗
                  ╚══════╝╚═╝  ╚══╝ ╚═════╝ ╚═╝╚═╝  ╚══╝╚══════╝
EOF
    echo -e "${RESET}"
}


# === Loading animation ===
loading_animation() {
    echo -ne "${YELLOW}Initializing"
    for i in {1..5}; do
        echo -ne "."
        sleep 0.3
    done
    echo -e "${RESET}\n"
}

# === Typewriter print ===
typewriter() {
    local text="$1"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.03
    done
    echo
}
