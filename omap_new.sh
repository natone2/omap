#!/bin/bash

# =========================================================
# OMAP - Full Power with nmap (Enhanced with Export)
# by StGlz
# contact: natone@riseup.net
# visit my ws: https://www.stglz-ecke.digital
# =========================================================
# DESCRIPTION:
# This script unleashes the full potential of Nmap, offering
# all possible scans, stylish output, export options, and
# powerful combinations for pentesters. Use responsibly!
# =========================================================

# Colors for aesthetics
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Export results
OUTPUT_FILE=""

# Loading animation
function loading_animation() {
    local message="$1"
    echo -ne "${CYAN}${BOLD}${message}${RESET}"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.5
    done
    echo ""
}

# Display results with style
function display_result() {
    echo -e "\n${YELLOW}${BOLD}=== RESULTS ===${RESET}"
    echo -e "$1" | while IFS= read -r line; do
        if [[ $line == *"open"* ]]; then
            echo -e "${GREEN}${line}${RESET}"
        elif [[ $line == *"closed"* || $line == *"filtered"* ]]; then
            echo -e "${RED}${line}${RESET}"
        else
            echo -e "${CYAN}${line}${RESET}"
        fi
    done
}

# Export results
function export_result() {
    if [[ -n "$OUTPUT_FILE" ]]; then
        echo -e "${CYAN}Saving results to ${BOLD}${OUTPUT_FILE}${RESET}..."
        echo "$1" >"$OUTPUT_FILE"
        echo -e "${GREEN}Results saved successfully.${RESET}"
    fi
}

# Basic scans
function basic_scans() {
    echo -e "${BLUE}${BOLD}=== Basic Scans ===${RESET}"
    echo -e "${CYAN}1. Ping Scan${RESET}"
    echo -e "${CYAN}2. Quick Scan (common ports)${RESET}"
    echo -e "${CYAN}3. Full Scan (all ports)${RESET}"
    echo -ne "${CYAN}Choose an option (1-3): ${RESET}"
    read CHOICE

    case $CHOICE in
    1)
        loading_animation "Performing Ping Scan"
        result=$(nmap -sn "$TARGET")
        ;;
    2)
        loading_animation "Performing Quick Scan"
        result=$(nmap -F "$TARGET")
        ;;
    3)
        loading_animation "Performing Full Scan"
        result=$(nmap -p- "$TARGET")
        ;;
    *)
        echo -e "${RED}Invalid option.${RESET}"
        return
        ;;
    esac
    display_result "$result"
    export_result "$result"
}

# Advanced scans
function advanced_scans() {
    echo -e "${BLUE}${BOLD}=== Advanced Scans ===${RESET}"
    echo -e "${CYAN}1. OS Detection${RESET}"
    echo -e "${CYAN}2. Service Version Detection${RESET}"
    echo -e "${CYAN}3. Scan with Vulnerability Scripts${RESET}"
    echo -ne "${CYAN}Choose an option (1-3): ${RESET}"
    read CHOICE

    case $CHOICE in
    1)
        loading_animation "Detecting Operating System"
        result=$(nmap -O "$TARGET")
        ;;
    2)
        loading_animation "Detecting Service Versions"
        result=$(nmap -sV "$TARGET")
        ;;
    3)
        loading_animation "Scanning with Vulnerability Scripts"
        result=$(nmap --script vuln "$TARGET")
        ;;
    *)
        echo -e "${RED}Invalid option.${RESET}"
        return
        ;;
    esac
    display_result "$result"
    export_result "$result"
}

# Combined scans
function combined_scans() {
    echo -e "${BLUE}${BOLD}=== Combined Scans ===${RESET}"
    echo -e "${CYAN}1. Full Ports + OS Detection${RESET}"
    echo -e "${CYAN}2. Full Scan + Vulnerability Scripts${RESET}"
    echo -ne "${CYAN}Choose an option (1-2): ${RESET}"
    read CHOICE

    case $CHOICE in
    1)
        loading_animation "Performing Full Ports + OS Detection"
        result=$(nmap -p- -O "$TARGET")
        ;;
    2)
        loading_animation "Performing Full Scan + Vulnerability Scripts"
        result=$(nmap -p- --script vuln "$TARGET")
        ;;
    *)
        echo -e "${RED}Invalid option.${RESET}"
        return
        ;;
    esac
    display_result "$result"
    export_result "$result"
}

# Main function
function main_menu() {
    clear
    echo -e "${CYAN}${BOLD}=== Welcome to OMAP, the automated nmap tool ===${RESET}"
    echo -e "${GREEN}Unleash the full power of Nmap.${RESET}"
    echo -e "${RED}Reminder: Only scan networks you own or have permission to test.${RESET}\n"

    echo -ne "${CYAN}Enter the target IP or range (e.g., 192.168.1.0/24): ${RESET}"
    read TARGET

    if [ -z "$TARGET" ]; then
        echo -e "${RED}No target provided. Exiting...${RESET}"
        exit 1
    fi

    echo -ne "${CYAN}Enter output file name (e.g., results.txt) or leave blank to skip saving: ${RESET}"
    read OUTPUT_FILE

    while true; do
        echo -e "\n${CYAN}${BOLD}=== Main Menu ===${RESET}"
        echo -e "${GREEN}1. Basic Scans${RESET}"
        echo -e "${GREEN}2. Advanced Scans${RESET}"
        echo -e "${GREEN}3. Combined Scans${RESET}"
        echo -e "${GREEN}4. Exit${RESET}"
        echo -ne "${CYAN}Choose an option (1-4): ${RESET}"
        read OPTION

        case $OPTION in
        1)
            basic_scans
            ;;
        2)
            advanced_scans
            ;;
        3)
            combined_scans
            ;;
        4)
            echo -e "${CYAN}Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option.${RESET}"
            ;;
        esac
    done
}

# Check if Nmap is installed
if ! command -v nmap &>/dev/null; then
    echo -e "${RED}Error: Nmap is not installed. Please install it and try again.${RESET}"
    exit 1
fi

# Run the main menu
main_menu


# Run the main menu
main_menu
