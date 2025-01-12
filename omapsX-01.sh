#!/bin/bash

# =========================================================
# omapsX ver. 0.1
# by StGlz
# =========================================================
# DESCRIPTION:
# This script combines Nmap scanning and vulnerability analysis
# with exploit searching using searchsploit. No files are saved;
# everything is processed and displayed in real time.
# =========================================================

# Colors for aesthetics
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Function to parse Nmap results and extract vulnerabilities
function parse_nmap_results() {
    local nmap_output="$1"
    echo -e "${BLUE}${BOLD}Parsing Nmap results...${RESET}"

    # Extract vulnerability lines (lines starting with |_)
    echo "$nmap_output" | grep -E "^\|_" | sed 's/|_//g' | while IFS= read -r vuln_line; do
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
    exploits=$(searchsploit "$clean_vuln" 2>/dev/null)

    # Filter useful results
    local filtered_exploits
    filtered_exploits=$(echo "$exploits" | awk 'NR > 2 {print}')

    if [[ -z "$filtered_exploits" ]]; then
        echo -e "${RED}No exploits found for:${RESET} $clean_vuln"
    else
        echo -e "${GREEN}Exploits found:${RESET}"
        echo "$filtered_exploits" | while IFS= read -r exploit_line; do
            # Extract the exploit path
            exploit_path=$(echo "$exploit_line" | awk '{print $NF}')

            # Determine exploit type based on file extension
            if [[ "$exploit_path" == *".rb" ]]; then
                echo -e "  • Use in Metasploit: ${BOLD}msfconsole -r $exploit_path${RESET}"
            elif [[ "$exploit_path" == *".py" ]]; then
                echo -e "  • Run directly: ${BOLD}python $exploit_path${RESET}"
            elif [[ "$exploit_path" == *".sh" ]]; then
                echo -e "  • Execute script: ${BOLD}bash $exploit_path${RESET}"
            elif [[ "$exploit_path" == *".c" ]]; then
                echo -e "  • Compile and run: ${BOLD}gcc -o exploit $exploit_path && ./exploit${RESET}"
            else
                echo -e "  • Review manually: ${BOLD}$exploit_line${RESET}"
            fi
        done
    fi
    echo ""
}

# Main function
function main() {
    echo -e "${CYAN}${BOLD}=== OMAPsX, unleash the beast ===${RESET}"
    echo -e "${GREEN}OMAP & sX together. Analyze Nmap results and find exploits with searchsploit.${RESET}"

    # Check if Nmap and searchsploit are installed
    if ! command -v nmap &>/dev/null || ! command -v searchsploit &>/dev/null; then
        echo -e "${RED}Error: Nmap and/or searchsploit are not installed. Please install them and try again.${RESET}"
        exit 1
    fi

    # Ask for the target IP or range
    echo -ne "${CYAN}Enter the target IP or range (e.g., 192.168.1.0/24): ${RESET}"
    read TARGET

    if [[ -z "$TARGET" ]]; then
        echo -e "${RED}No target provided. Exiting...${RESET}"
        exit 1
    fi

    # Perform Nmap scan with vulnerability scripts
    echo -e "${CYAN}${BOLD}Running Nmap scan with vulnerability scripts...${RESET}"
    nmap_output=$(nmap --script vuln "$TARGET")
    echo "$nmap_output"

    # Parse and analyze Nmap results
    parse_nmap_results "$nmap_output"
}

# Run the main function
main
