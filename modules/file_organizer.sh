#!/bin/bash
source utils.sh

echo -e "${BLUE}==== File Organizer Module ====${RESET}"

read -p "Enter directory to organize: " target_dir

if [ ! -d "$target_dir" ]; then
    echo -e "${RED}Directory does not exist!${RESET}"
    log_event "File Organizer" "Failed: $target_dir does not exist"
    exit 1
fi

organized_count=0

# --- Organize by extension ---
organize_by_extension() {
    for file in "$target_dir"/*; do
        [ -f "$file" ] || continue
        ext="${file##*.}"
        mkdir -p "$target_dir/$ext"
        mv "$file" "$target_dir/$ext/" && ((organized_count++))
    done
}

# --- Organize by date modified ---
organize_by_date() {
    for file in "$target_dir"/*; do
        [ -f "$file" ] || continue
        mod_date=$(date -r "$file" "+%Y-%m-%d")
        mkdir -p "$target_dir/$mod_date"
        mv "$file" "$target_dir/$mod_date/" && ((organized_count++))
    done
}

# --- Organize by file size ---
organize_by_size() {
    for file in "$target_dir"/*; do
        [ -f "$file" ] || continue
        size_bytes=$(stat -c%s "$file")
        if [ "$size_bytes" -lt 1048576 ]; then
            size_folder="Small"       # <1MB
        elif [ "$size_bytes" -lt 10485760 ]; then
            size_folder="Medium"      # 1MB–10MB
        else
            size_folder="Large"       # >10MB
        fi
        mkdir -p "$target_dir/$size_folder"
        mv "$file" "$target_dir/$size_folder/" && ((organized_count++))
    done
}

# --- Mode selection ---
echo -e "${YELLOW}Select organizing method:${RESET}"
echo "1. By File Extension"
echo "2. By Date Modified"
echo "3. By File Size"
read -p "Enter choice [1-3]: " choice

echo -e "${CYAN}Organizing files in: $target_dir${RESET}"

case "$choice" in
    1)
        organize_by_extension
        method="By Extension"
        ;;
    2)
        organize_by_date
        method="By Date Modified"
        ;;
    3)
        organize_by_size
        method="By File Size"
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${RESET}"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ Organized $organized_count files using method: $method${RESET}"
log_event "File Organizer" "Organized $organized_count files in $target_dir ($method)"
