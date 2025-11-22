#!/bin/bash
source utils.sh

# Colors
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# ASCII animation function
ascii_spinner() {
    local pid=$1
    local delay=0.1
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    while kill -0 $pid 2>/dev/null; do
        for frame in "${frames[@]}"; do
            printf "\r[%s] " "$frame"
            sleep $delay
        done
    done
    printf "\r      \r"
}

# Function to display size of a directory
show_size() {
    [ -e "$1" ] && du -sh "$1" 2>/dev/null | awk '{print $1}' || echo "0"
}

# Function to clean cache with ASCII animation
clean_cache() {
    local path=$1
    local description=$2
    local size=$(show_size "$path")

    if [ "$size" != "0" ]; then
        echo -ne "${YELLOW}Cleaning $description (Size: $size)...${RESET}"
        rm -rf "$path"/* 2>/dev/null &
        pid=$!
        ascii_spinner $pid
        wait $pid
        echo -e "${GREEN} Done!${RESET}"
        log_event "System Cleaner" "$description cleared (was $size)"
    else
        echo -e "${GREEN}No $description to clean.${RESET}"
    fi
}

echo -e "${BLUE}==== Welcome to Friendly System Cache Cleaner ====${RESET}"
sleep 0.5

# === User cache cleanup ===
clean_cache ~/.cache "user cache"

# === Thumbnail cache cleanup ===
clean_cache ~/.cache/thumbnails "thumbnail cache"

# === Trash cleanup ===
clean_cache ~/.local/share/Trash "user trash"

# === Browser cache cleanup ===
# Firefox
if [ -d ~/.mozilla/firefox ]; then
    for profile in ~/.mozilla/firefox/*/cache2; do
        clean_cache "$profile" "Firefox cache for profile $(basename $(dirname $profile))"
    done
fi

# Chrome/Chromium
if [ -d ~/.cache/google-chrome ]; then
    clean_cache ~/.cache/google-chrome "Chrome/Chromium cache"
fi

echo -e "${BLUE}===========================================${RESET}"
echo -e "${GREEN}All cache cleaned! Your system feels lighter now 🙂${RESET}"
log_event "System Cleaner" "Cache-only cleanup executed successfully"
