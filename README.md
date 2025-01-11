OMAP - Full Power with Nmap

OMAP is an automated script designed to unleash the full potential of Nmap, one of the most powerful network scanning tools. This script provides an interactive interface to perform various scans, combine them, and display stylish results, offering a user-friendly and functional experience.

Key Features

All Possible Nmap Scans:

Basic scans (Ping Scan, Quick Scan, Full Scan).

Advanced scans (OS detection, service version detection, vulnerability scans).

Combined scans (Full ports + OS, Full Scan + Vulnerability scripts).

Stylish Results:

Organized and color-coded output to highlight key information (open ports, services, etc.).

Clear and attractive design, improving upon Nmap's default output.

Interactive Interface:

Selectable options from a main menu.

Modular and combinable scans.

Full Compatibility:

Designed to work on any system with Nmap installed.

Installation

Clone this repository:

git clone https://github.com/stglz/omap.git

Navigate to the project directory:

cd omap

Ensure Nmap is installed on your system:

sudo apt update && sudo apt install nmap

Grant execution permissions to the script:

chmod +x omap.sh

Usage

Run the script from the terminal:

./omap.sh

Main Menu

Basic Scans:

Ping Scan: Detect active devices on the network.

Quick Scan: Scan common ports.

Full Scan: Scan all ports.

Advanced Scans:

OS Detection: Identify the target's operating system.

Service Version Detection: Detect versions of active services.

Vulnerability Scan: Use Nmap scripts to find vulnerabilities.

Combined Scans:

Full Ports + OS Detection: Scan all ports and detect the OS.

Full Scan + Vulnerability Scripts: Complete scan with vulnerability analysis.

Exit: Exit the program.

Example Usage

Quick Scan:

Enter the target IP or range (e.g., 192.168.1.0/24).

Select "Basic Scans" > "Quick Scan".

View the stylish results on the screen.

Advanced Scan:

Select "Advanced Scans" > "OS Detection".

Provide the target IP.

Review detailed information about the detected operating system.

Requirements

Nmap: Ensure Nmap is installed on your system.

Bash: The script is designed to run in Bash environments.

Responsible Usage Notes

This script is designed for ethical penetration testing. Do not use it on networks or systems without authorization.

Any misuse is the responsibility of the user.

Author

StGlzContact: natone@riseup.netWebsite: https://www.stglz-ecke.digital

Explore and harness the full power of Nmap with OMAP!
