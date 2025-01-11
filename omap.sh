#!/bin/bash

# =========================================================
# OMAP - Outstanding Multi-purpose Automated Pentester
# by StGlz
# contact: natone@riseup.net
# visit my ws: https://www.stglz-ecke.digital
# =========================================================
# What is OMAP? 
# OMAP is not your average network scanner. It’s a tool built for those 
# who want to dive into network scanning with style, flair, and maybe 
# even a bit of that "hacker in the movies" vibe.
# Use it responsibly, and don’t go scanning networks you don’t own. 
# Remember: being cool also means being ethical.
# =========================================================

# Terminal colors for the hacker vibe
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Small loading animation function to add drama
function loading_animation() {
    local message="$1"
    echo -ne "${CYAN}${BOLD}${message}${RESET}"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.5
    done
    echo ""
}

# Fake progress bar for extra drama
function fake_progress() {
    local message="$1"
    echo -e "${BLUE}${BOLD}${message}${RESET}"
    for i in $(seq 1 50); do
        echo -ne "${GREEN}#${RESET}"
        sleep 0.05
    done
    echo -e " ${CYAN}[DONE]${RESET}"
}

# Start with an epic intro
clear
echo -e "${CYAN}${BOLD}=== Welcome to OMAP - Outstanding Multi-purpose Automated Pentester ===${RESET}"
echo -e "${GREEN}This is your go-to tool for scanning networks like a pro—with a cinematic twist.${RESET}"
echo -e "${RED}Make sure you only scan networks you have permission to access!${RESET}\n"

# Ask the user for the target
echo -ne "${CYAN}Enter the target IP or range (e.g., 192.168.1.0/24): ${RESET}"
read TARGET

if [ -z "$TARGET" ]; then
    echo -e "${RED}Error: No target provided. Exiting...${RESET}"
    exit 1
fi

# Show the user the available scan options
echo -e "\n${CYAN}Choose your scan type:${RESET}"
echo -e "${GREEN}1. Quick Scan (common ports).${RESET}"
echo -e "${GREEN}2. Full Scan (all ports).${RESET}"
echo -e "${GREEN}3. Service Detection (services & versions).${RESET}"
echo -e "${GREEN}4. Vulnerability Scan (basic vulnerability check).${RESET}"
echo -e "${GREEN}5. Custom Scan (write your own Nmap parameters).${RESET}"
echo -ne "${CYAN}Select an option (1-5): ${RESET}"
read OPTION

# Validate the option
if [[ "$OPTION" -lt 1 || "$OPTION" -gt 5 ]]; then
    echo -e "${RED}Invalid option. Exiting...${RESET}"
    exit 1
fi

# Pretend we’re hacking into the matrix
loading_animation "Connecting to target network"
fake_progress "Loading OMAP modules"

# Define scan functions for each option
function quick_scan() {
    echo -e "\n${CYAN}Running a quick scan on ${TARGET}...${RESET}"
    loading_animation "Scanning common ports"
    nmap -F "$TARGET"
}

function full_scan() {
    echo -e "\n${CYAN}Running a full scan on ${TARGET}...${RESET}"
    loading_animation "Scanning all 65,535 ports. This might take a while."
    nmap -p- "$TARGET"
}

function service_scan() {
    echo -e "\n${CYAN}Detecting services and versions on ${TARGET}...${RESET}"
    loading_animation "Analyzing services"
    nmap -sV "$TARGET"
}

function vulnerability_scan() {
    echo -e "\n${CYAN}Checking for vulnerabilities on ${TARGET}...${RESET}"
    loading_animation "Running vulnerability scripts"
    nmap --script vuln "$TARGET"
}

function custom_scan() {
    echo -ne "${CYAN}Enter your custom Nmap parameters: ${RESET}"
    read CUSTOM_PARAMS
    echo -e "\n${CYAN}Running custom scan on ${TARGET} with: ${CUSTOM_PARAMS}${RESET}"
    loading_animation "Executing custom commands"
    nmap $CUSTOM_PARAMS "$TARGET"
}

# Run the selected scan
case $OPTION in
1)
    quick_scan
    ;;
2)
    full_scan
    ;;
3)
    service_scan
    ;;
4)
    vulnerability_scan
    ;;
5)
    custom_scan
    ;;
esac

# Wrap it up with style
fake_progress "Compiling results"
echo -e "\n${GREEN}${BOLD}Scan complete. Mission accomplished with OMAP!${RESET}"

