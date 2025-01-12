#!/bin/bash

# =========================================================
# OMAP Analyzer & Exploiter
# by StGlz
# contact: natone@riseup.net
# visit my ws: https://www.stglz-ecke.digital
# =========================================================
# DESCRIPTION:
# Combines the power of Nmap and searchsploit. Analyze Nmap
# scan results, identify vulnerabilities, and find related
# exploits with instructions to use them.
# =========================================================

# Colors for aesthetics
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Function to search exploits
function search_exploit() {
    local vuln="$1"
    local clean_vuln
    clean_vuln=$(echo "$vuln" | grep -oE '(ms[0-9]{2}-[0-9]{3}|cve-[0-9]{4}-[0-9]+)')

    if [[ -z "$clean_vuln" ]]; then
        echo -e "${RED}No valid vulnerability identifier found in:${RESET} $vuln"
        return
    fi

    echo -e "${BLUE}${BOLD}Searching exploits for:${RESET} $clean_vuln"
    local exploits
    exploits=$(searchsploit -w "$clean_vuln" 2>/dev/null)

    local filtered_exploits
    filtered_exploits=$(echo "$exploits" | awk 'NR > 2 && $1 != "Shellcodes:"')

    if [[ -z "$filtered_exploits" ]]; then
        echo -e "${RED}No exploits found for:${RESET} $clean_vuln"
    else
        echo -e "${GREEN}Exploits found:${RESET}"
        echo "$filtered_exploits" | while IFS= read -r exploit_line; do
            exploit_path=$(echo "$exploit_line" | awk '{print $NF}')
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

# Function to parse Nmap results
function parse_nmap_results() {
    local file="$1"
    echo -e "${BLUE}${BOLD}Parsing Nmap results...${RESET}"

    if [[ ! -f "$file" ]]; then
        echo -e "${RED}Error: File not found: $file${RESET}"
        exit 1
    fi

    local vulnerabilities
    vulnerabilities=$(grep -oE '_smb-[^:]+: [^,]+' "$file" | sed 's/^_//')

    if [[ -z "$vulnerabilities" ]]; then
        echo -e "${RED}No vulnerabilities found in Nmap results.${RESET}"
        exit 0
    fi

    echo -e "${GREEN}Found vulnerabilities:${RESET}"
    echo "$vulnerabilities"

    echo -e "\n${CYAN}${BOLD}Analyzing vulnerabilities...${RESET}"
    while IFS= read -r vuln; do
        echo -e "\n${YELLOW}Found vulnerability:${RESET} $vuln"
        search_exploit "$vuln"
    done <<<"$vulnerabilities"
}

# Main function
function main_menu() {
    clear
    echo -e "${CYAN}${BOLD}=== Welcome to OMAP Analyzer & Exploiter ===${RESET}"
    echo -e "${GREEN}Analyze Nmap results and find exploits.${RESET}"

    echo -ne "${CYAN}Enter the path to the Nmap results file: ${RESET}"
    read results_file

    parse_nmap_results "$results_file"
}

# Check if required tools are installed
if ! command -v nmap &>/dev/null || ! command -v searchsploit &>/dev/null; then
    echo -e "${RED}Error: Required tools (Nmap, searchsploit) are not installed.${RESET}"
    exit 1
fi

# Run the main menu
main_menu
