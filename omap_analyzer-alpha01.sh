#!/bin/bash

# =========================================================
# OMAP - Full Power Nmap with Automated Vulnerability Analysis
# by StGlz
# contact: natone@riseup.net
# visit my ws: https://www.stglz-ecke.digital
# =========================================================
# DESCRIPTION:
# Combines Nmap scans with searchsploit to analyze results
# and find relevant exploits. Use responsibly!
# =========================================================

# Colors for aesthetics
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
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

# Function to parse Nmap results and extract vulnerabilities
function parse_nmap_results() {
    local nmap_results="$1"
    echo -e "${BLUE}${BOLD}Parsing Nmap results...${RESET}"

    echo "$nmap_results" | grep -E "^\|_" | sed 's/|_//g' | while IFS= read -r vuln_line; do
        echo -e "${YELLOW}Found vulnerability:${RESET} $vuln_line"
        search_exploit "$vuln_line"
    done
}

# Function to search for exploits using searchsploit
function search_exploit() {
    local vuln="$1"

    # Extract the vulnerability identifier
    local clean_vuln
    clean_vuln=$(echo "$vuln" | grep -oE '(ms[0-9]{2}-[0-9]{3}|cve-[0-9]{4}-[0-9]+)')

    if [[ -z "$clean_vuln" ]]; then
        echo -e "${RED}No valid vulnerability identifier found in:${RESET} $vuln"
        return
    fi

    echo -e "${BLUE}${BOLD}Searching exploits for:${RESET} $clean_vuln"
    local exploits
    exploits=$(searchsploit -w "$clean_vuln" 2>/dev/null)

    # Filter useful results
    local filtered_exploits
    filtered_exploits=$(echo "$exploits" | awk 'NR > 2 && $1 != "Shellcodes:")')

    if [[ -z "$filtered_exploits" ]]; then
        echo -e "${RED}No exploits found for:${RESET} $clean_vuln"
    else
        echo -e "${GREEN}Exploits found:${RESET}"
        echo "$filtered_exploits" | while IFS= read -r exploit_line; do
            # Extract exploit path
            exploit_path=$(echo "$exploit_line" | awk '{print $NF}')

            # Determine exploit type by extension
            if [[ "$exploit_path" == *.rb ]]; then
                echo -e "  • Use in Metasploit: ${BOLD}msfconsole -r $exploit_path${RESET}"
            elif [[ "$exploit_path" == *.py ]]; then
                echo -e "  • Run directly: ${BOLD}python $exploit_path${RESET}"
            elif [[ "$exploit_path" == *.sh ]]; then
                echo -e "  • Execute script: ${BOLD}bash $exploit_path${RESET}"
            elif [[ "$exploit_path" == *.c ]]; then
                echo -e "  • Compile and run: ${BOLD}gcc -o exploit $exploit_path && ./exploit${RESET}"
            else
                echo -e "  • Review manually: ${BOLD}$exploit_line${RESET}"
            fi
        done
    fi
    echo ""
}

# Main function
function main_menu() {
    clear
    echo -e "${CYAN}${BOLD}=== Nmap + Exploit Analyzer ===${RESET}"
    echo -e "${GREEN}Run Nmap scans and analyze vulnerabilities with searchsploit.${RESET}"
    echo -e "${RED}Reminder: Only scan networks you own or have permission to test.${RESET}\n"

    echo -ne "${CYAN}Enter the target IP or range (e.g., 192.168.1.0/24): ${RESET}"
    read TARGET

    if [[ -z "$TARGET" ]]; then
        echo -e "${RED}No target provided. Exiting...${RESET}"
        exit 1
    fi

    echo -e "${BLUE}${BOLD}Performing Quick Scan...${RESET}"
    loading_animation "Scanning"
    nmap_results=$(nmap -sV --script vuln "$TARGET")

    display_result "$nmap_results"
    parse_nmap_results "$nmap_results"
}

# Check if required tools are installed
if ! command -v nmap &>/dev/null; then
    echo -e "${RED}Error: Nmap is not installed. Please install it and try again.${RESET}"
    exit 1
fi

if ! command -v searchsploit &>/dev/null; then
    echo -e "${RED}Error: searchsploit is not installed. Please install it and try again.${RESET}"
    exit 1
fi

# Run the main menu
main_menu
