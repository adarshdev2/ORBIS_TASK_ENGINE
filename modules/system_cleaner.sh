#!/bin/bash
source utils.sh

# ================= COLORS =================
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
CYAN="\033[1;36m"
RESET="\033[0m"

# ================= SPINNER =================
ascii_spinner() {
    local pid=$1
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    while kill -0 "$pid" 2>/dev/null; do
        for f in "${frames[@]}"; do
            printf "\r[%s] " "$f"
            sleep 0.1
        done
    done
    printf "\r      \r"
}

# ================= SMART SIZE =================
get_size() {
    local path=$1

    if [ ! -d "$path" ]; then
        echo "0"
        return
    fi

    local count
    count=$(find "$path" -mindepth 1 2>/dev/null | wc -l)

    if [ "$count" -eq 0 ]; then
        echo "0"
    else
        du -sh "$path" 2>/dev/null | awk '{print $1}'
    fi
}

# ================= PREVIEW =================
preview_cache() {
    local path=$1
    local name=$2

    echo -e "${CYAN}$name${RESET}"
    echo "Path : $path"
    echo "Size : $(get_size "$path")"
    echo "---------------------------"
}

# ================= CLEAN CORE =================
clean_cache() {
    local path=$1
    local name=$2

    if [ ! -d "$path" ] || [ "$(get_size "$path")" = "0" ]; then
        echo -e "${GREEN}No $name to clean.${RESET}"
        return
    fi

    local size
    size=$(get_size "$path")

    echo -ne "${YELLOW}Cleaning $name (Size: $size)...${RESET}"

    find "$path" -mindepth 1 -exec rm -rf {} + 2>/dev/null &
    pid=$!
    ascii_spinner "$pid"
    wait "$pid"

    echo -e "${GREEN} Done!${RESET}"
    log_event "System Cleaner" "$name cleared (was $size)"
}

# ================= MODULES =================
clean_user_cache() {
    clean_cache "$HOME/.cache" "User Cache"
}

clean_thumbnail_cache() {
    clean_cache "$HOME/.cache/thumbnails" "Thumbnail Cache"
}

clean_trash() {
    clean_cache "$HOME/.local/share/Trash/files" "Trash Files"
    clean_cache "$HOME/.local/share/Trash/info" "Trash Info"
}

clean_firefox_cache() {
    if [ ! -d "$HOME/.mozilla/firefox" ]; then
        echo -e "${GREEN}Firefox not installed.${RESET}"
        return
    fi

    for profile in "$HOME/.mozilla/firefox"/*.default*; do
        [ -d "$profile/cache2" ] || continue
        pname=$(basename "$profile")
        clean_cache "$profile/cache2" "Firefox Cache ($pname)"
    done
}

# ================= PREVIEW ALL =================
preview_all() {
    echo -e "${BLUE}--- Cache Preview (Dry Run) ---${RESET}"

    preview_cache "$HOME/.cache" "User Cache"
    preview_cache "$HOME/.cache/thumbnails" "Thumbnail Cache"
    preview_cache "$HOME/.local/share/Trash/files" "Trash Files"
    preview_cache "$HOME/.local/share/Trash/info" "Trash Info"

    if [ -d "$HOME/.mozilla/firefox" ]; then
        for profile in "$HOME/.mozilla/firefox"/*.default*; do
            preview_cache "$profile/cache2" "Firefox Cache ($(basename "$profile"))"
        done
    fi
}

# ================= MENU =================
while true; do
    clear
    echo -e "${BLUE}=========================================${RESET}"
    echo -e "${BLUE}   ORBIS – Advanced System Cache Cleaner ${RESET}"
    echo -e "${BLUE}=========================================${RESET}"
    echo
    echo "1) Preview cache sizes (Dry Run)"
    echo "2) Clean user cache"
    echo "3) Clean thumbnail cache"
    echo "4) Empty trash"
    echo "5) Clean Firefox cache"
    echo "6) Clean ALL caches"
    echo "7) Back to main menu"
    echo

    read -rp "Choose an option [1-7]: " choice
    echo

    case "$choice" in
        1) preview_all ;;
        2) clean_user_cache ;;
        3) clean_thumbnail_cache ;;
        4) clean_trash ;;
        5) clean_firefox_cache ;;
        6)
            clean_user_cache
            clean_thumbnail_cache
            clean_trash
            clean_firefox_cache
            ;;
        7)
            log_event "System Cleaner" "Exited system cleaner module"
            break
            ;;
        *)
            echo -e "${RED}Invalid option.${RESET}"
            ;;
    esac

    echo
    read -rp "Press Enter to continue..."
done
