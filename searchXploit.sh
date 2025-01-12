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

    # Extraer el identificador de vulnerabilidad
    local clean_vuln
    clean_vuln=$(echo "$vuln" | grep -oE '(ms[0-9]{2}-[0-9]{3}|cve-[0-9]{4}-[0-9]+)')

    if [[ -z "$clean_vuln" ]]; then
        echo -e "${RED}No valid vulnerability identifier found in:${RESET} $vuln"
        return
    fi

    echo -e "${BLUE}${BOLD}Searching exploits for:${RESET} $clean_vuln"
    local exploits
    exploits=$(searchsploit -w "$clean_vuln" 2>/dev/null)

    # Filtrar resultados útiles
    local filtered_exploits
    filtered_exploits=$(echo "$exploits" | awk 'NR > 2 && $1 != "Shellcodes:"')

    if [[ -z "$filtered_exploits" ]]; then
        echo -e "${RED}No exploits found for:${RESET} $clean_vuln"
    else
        echo -e "${GREEN}Exploits found:${RESET}"
        echo "$filtered_exploits" | while IFS= read -r exploit_line; do
            # Extraer la ruta del exploit
            exploit_path=$(echo "$exploit_line" | awk '{print $NF}')
            
            # Determinar el tipo de exploit por extensión
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
