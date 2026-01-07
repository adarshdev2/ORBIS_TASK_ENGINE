#!/bin/bash
source utils.sh

# Colors
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
CYAN="\033[1;36m"
RESET="\033[0m"

# === ASCII Spinner ===
ascii_spinner() {
    local pid=$1
    local delay=0.1
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    while kill -0 "$pid" 2>/dev/null; do
        for frame in "${frames[@]}"; do
            printf "\r[%s] " "$frame"
            sleep "$delay"
        done
    done
    printf "\r      \r"
}

# === Get directory size ===
get_size() {
    [ -d "$1" ] && du -sh "$1" 2>/dev/null | awk '{print $1}' || echo "0"
}

# === Preview Mode ===
preview_cache() {
    local path=$1
    local name=$2
    local size
    size=$(get_size "$path")

    echo -e "${CYAN}$name${RESET}"
    echo "Path : $path"
    echo "Size : $size"
    echo "---------------------------"
}

# === Clean Cache ===
clean_cache() {
    local path=$1
    local name=$2
    local size
    size=$(get_size "$path")

    if [ "$size" = "0" ]; then
        echo -e "${GREEN}No $name to clean.${RESET}"
        return
    fi

    echo -ne "${YELLOW}Cleaning $name (Size: $size)...${RESET}"
    rm -rf "$path"/* 2>/dev/null &
    pid=$!
    ascii_spinner "$pid"
    wait "$pid"

    echo -e "${GREEN} Done!${RESET}"
    log_event "System Cleaner" "$name cleared (was $size)"
}

# === Sub-modules ===
clean_user_cache() {
    clean_cache "$HOME/.cache" "User Cache"
}

clean_thumbnail_cache() {
    clean_cache "$HOME/.cache/thumbnails" "Thumbnail Cache"
}

clean_trash() {
    clean_cache "$HOME/.local/share/Trash/files" "Trash"
}

clean_browser_cache() {
    if [ -d "$HOME/.mozilla/firefox" ]; then
        for profile in "$HOME/.mozilla/firefox"/*/cache2; do
            [ -d "$profile" ] || continue
            profile_name=$(basename "$(dirname "$profile")")
            clean_cache "$profile" "Firefox Cache ($profile_name)"
        done
    fi

    if [ -d "$HOME/.cache/google-chrome" ]; then
        clean_cache "$HOME/.cache/google-chrome" "Chrome Cache"
    fi
}

# === Preview All ===
preview_all() {
    echo -e "${BLUE}--- Cache Preview (Dry Run) ---${RESET}"
    preview_cache "$HOME/.cache" "User Cache"
    preview_cache "$HOME/.cache/thumbnails" "Thumbnail Cache"
    preview_cache "$HOME/.local/share/Trash/files" "Trash"
    preview_cache "$HOME/.mozilla/firefox" "Firefox Cache"
    preview_cache "$HOME/.cache/google-chrome" "Chrome Cache"
}

# === Main Menu ===
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
    echo "5) Clean browser cache"
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
        5) clean_browser_cache ;;
        6)
            clean_user_cache
            clean_thumbnail_cache
            clean_trash
            clean_browser_cache
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
