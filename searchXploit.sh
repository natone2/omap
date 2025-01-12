#!/bin/bash

# =========================================================
# Nmap Result Analyzer and Exploit Finder
# by StGlz
# =========================================================
# DESCRIPTION:
# This script analyzes an Nmap result file, searches for
# vulnerabilities using searchsploit, and provides hints
# on how to exploit them. Use responsibly!
# =========================================================

# Colors for aesthetics
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Function to parse Nmap results and extract vulnerabilities
function parse_nmap_results() {
    local nmap_file="$1"
    echo -e "${BLUE}${BOLD}Parsing Nmap results...${RESET}"

    # Extract vulnerability lines (lines starting with |_)
    grep -E "^\|_" "$nmap_file" | sed 's/|_//g' | while IFS= read -r vuln_line; do
        echo -e "${YELLOW}Found vulnerability:${RESET} $vuln_line"
        search_exploit "$vuln_line"
    done
}

# Function to search for exploits using searchsploit
function search_exploit() {
    local vuln="$1"
    echo -e "${BLUE}${BOLD}Searching exploits for:${RESET} $vuln"
    local exploits
    exploits=$(searchsploit "$vuln" 2>/dev/null)

    if [[ -z "$exploits" ]]; then
        echo -e "${RED}No exploits found for:${RESET} $vuln"
    else
        echo -e "${GREEN}Exploits found:${RESET}"
        echo "$exploits"
        echo -e "\n${CYAN}${BOLD}How to use:${RESET}"
        echo "$exploits" | while IFS= read -r exploit_line; do
            if [[ $exploit_line == *".rb"* ]]; then
                echo -e "  • Use in Metasploit: ${BOLD}msfconsole -r <exploit_path>${RESET}"
            elif [[ $exploit_line == *".py"* ]]; then
                echo -e "  • Run directly: ${BOLD}python <exploit_path>${RESET}"
            elif [[ $exploit_line == *".sh"* ]]; then
                echo -e "  • Execute script: ${BOLD}bash <exploit_path>${RESET}"
            else
                echo -e "  • Review exploit manually: ${BOLD}$exploit_line${RESET}"
            fi
        done
    fi
    echo ""
}

# Main function
function main() {
    echo -e "${CYAN}${BOLD}=== Nmap Result Analyzer ===${RESET}"
    echo -e "${GREEN}Analyze Nmap results and find exploits with searchsploit.${RESET}"

    # Check if searchsploit is installed
    if ! command -v searchsploit &>/dev/null; then
        echo -e "${RED}Error: searchsploit is not installed. Please install it and try again.${RESET}"
        exit 1
    fi

    # Ask for the Nmap results file
    echo -ne "${CYAN}Enter the path to the Nmap results file: ${RESET}"
    read nmap_file

    if [[ ! -f "$nmap_file" ]]; then
        echo -e "${RED}Error: File not found.${RESET}"
        exit 1
    fi

    # Parse the Nmap results and search for exploits
    parse_nmap_results "$nmap_file"
}

# Run the main function
main
