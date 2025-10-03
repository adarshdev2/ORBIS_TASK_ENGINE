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
mkdir -p "$(dirname "$DB_PATH")"  # ensure db/ exists
mkdir -p modules                  # optional: auto-create modules folder
mkdir -p reports                  # for Resource Monitor snapshots
mkdir -p logs                     # plain text log backup

# === Check if sqlite3 is installed ===
if ! command -v sqlite3 &> /dev/null; then
    echo -e "${RED}❌ sqlite3 is not installed. Please install it to use Orbis Task Engine.${RESET}"
    exit 1
fi

# === Create database file if not exists ===
[ ! -f "$DB_PATH" ] && touch "$DB_PATH"

# === Create logs table if not exists ===
sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS logs(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    module TEXT,
    level TEXT,
    message TEXT,
    timestamp TEXT
);"

# === Logger Function (safe for special chars) ===
log_event() {
    local module="$1"
    local message="$2"
    local level="${3:-INFO}"  # default level is INFO
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Escape single quotes for SQLite
    message="${message//\'/\'\'}"
    module="${module//\'/\'\'}"
    level="${level//\'/\'\'}"

    # Insert into SQLite
    sqlite3 "$DB_PATH" "INSERT INTO logs (module, level, message, timestamp) VALUES ('$module', '$level', '$message', '$timestamp');"

    # Backup in plain text log
    echo "[$timestamp] [$level] [$module] $message" >> logs/orbis_engine.log
}

# === Print with color helper ===
print_color() {
    local color="$1"
    local msg="$2"
    echo -e "${color}${msg}${RESET}"
}

# === Show last N logs in table format ===
show_logs() {
    local n="${1:-10}"
    echo -e "${CYAN}=== Last $n Logs ===${RESET}"
    printf "%-20s %-8s %-20s %-s\n" "TIMESTAMP" "LEVEL" "MODULE" "MESSAGE"
    sqlite3 "$DB_PATH" "SELECT timestamp, level, module, message FROM logs ORDER BY id DESC LIMIT $n;" | while IFS='|' read -r ts lvl mod msg; do
        printf "%-20s %-8s %-20s %-s\n" "$ts" "$lvl" "$mod" "$msg"
    done
}

# === Disk space helper (optional) ===
check_disk() {
    df -h | awk 'NR==1 || $5>80 {print}'
}
