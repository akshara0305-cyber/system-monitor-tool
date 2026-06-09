#!/bin/bash
# =============================================================================
# Personal System Monitor & Reporter Tool
# Author: Akshara
# GitHub: akshara0305-cyber
# Created: 2026-06-09
# Version: 1.0
# Description: Monitors system resources and generates reports
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
LOG_FILE="/tmp/sysmonitor_$$.log"
REPORT_DIR="$HOME/reports"
mkdir -p "$REPORT_DIR"

# Defaults
OUTPUT_FILE=""
VERBOSE=false
INTERACTIVE=true

usage() {
    echo "Usage: $0 [-o OUTPUT_FILE] [-v] [-h]"
    echo "  -o    Custom report filename"
    echo "  -v    Verbose mode"
    echo "  -h    Show help"
    exit 1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*"
}

cleanup() {
    log "Cleaning up temporary resources..."
    rm -f "/tmp/sysmonitor_$$"* 2>/dev/null || true
    log "Cleanup completed."
}

show_system_info() {
    echo -e "${BLUE}=== System Information ===${NC}"
    echo "Date & Time     : $(date)"
    echo "Hostname        : $(hostname)"
    echo "Uptime          : $(uptime -p)"
    echo "Logged In User  : $(whoami)"
    echo "Current Dir     : $(pwd)"
    echo "Disk Usage      : $(df -h / | awk 'NR==2 {print $5 " used"}')"
    echo ""
}

show_top_processes() {
    echo -e "${BLUE}=== Top 5 CPU Processes ===${NC}"
    ps aux --sort=-%cpu | head -n 6
    echo ""
}

generate_report() {
    local report_file="$1"
    cat > "$report_file" << CONTENT
# System Report - Generated on $(date)
# =====================================

Hostname        : $(hostname)
Uptime          : $(uptime -p)
Logged In User  : $(whoami)
Current Dir     : $(pwd)
Disk Usage      : $(df -h / | awk 'NR==2 {print $5 " used"}')

Top 5 CPU Processes:
$(ps aux --sort=-%cpu | head -n 6)
CONTENT
    echo -e "${GREEN}✅ Report saved to: $report_file${NC}"
}

# Traps
trap cleanup EXIT
trap cleanup SIGINT SIGTERM

# Parse options
while getopts ":o:vh" opt; do
    case $opt in
        o) OUTPUT_FILE="$OPTARG"; INTERACTIVE=false ;;
        v) VERBOSE=true ;;
        h) usage ;;
        \?) echo "Invalid option"; usage ;;
        :) echo "Option requires argument"; usage ;;
    esac
done

if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="$REPORT_DIR/system_report_$(date +%Y%m%d_%H%M%S).txt"
fi

# Main
log "System Monitor started"
echo -e "${BLUE}=== Personal System Monitor & Reporter ===${NC}"

if [ "$VERBOSE" = true ]; then
    echo -e "${YELLOW}Verbose mode enabled${NC}"
fi

if [ "$INTERACTIVE" = true ]; then
    while true; do
        echo ""
        echo "1. Show System Information"
        echo "2. Show Top Processes"
        echo "3. Generate Full Report"
        echo "4. Exit"
        echo -n "Enter your choice: "
        read choice

        case $choice in
            1) show_system_info ;;
            2) show_top_processes ;;
            3) generate_report "$OUTPUT_FILE" ;;
            4) echo "Goodbye!"; exit 0 ;;
            *) echo -e "${RED}Invalid choice!${NC}" ;;
        esac
    done
else
    show_system_info
    show_top_processes
    generate_report "$OUTPUT_FILE"
fi

log "Script completed successfully"
