#!/bin/bash

# =============================================================================
# Project: Automated Project Bootstrapping & Process Management
# File: setup_project.sh
# Description: Factory script to bootstrap Student Attendance Tracker project
# =============================================================================

# Color codes for better output visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
PROJECT_NAME=""
PROJECT_DIR=""
INTERRUPTED=false

# =============================================================================
# Function: cleanup_on_interrupt
# Description: Signal handler for SIGINT (Ctrl+C)
# Creates an archive of the incomplete project and removes the directory
# =============================================================================
cleanup_on_interrupt() {
    echo -e "\n${YELLOW}Signal received! Cleaning up...${NC}"
    INTERRUPTED=true
    
    # Check if project directory exists
    if [ -d "$PROJECT_DIR" ]; then
        ARCHIVE_NAME="${PROJECT_NAME}_archive.tar.gz"
        
        echo -e "${BLUE}Creating archive: ${ARCHIVE_NAME}${NC}"
        
        # Create compressed archive of the incomplete project
        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Archive created successfully: ${ARCHIVE_NAME}${NC}"
        else
            echo -e "${RED}✗ Failed to create archive${NC}"
        fi
        
        # Delete the incomplete directory
        echo -e "${BLUE}Removing incomplete directory: ${PROJECT_DIR}${NC}"
        rm -rf "$PROJECT_DIR"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Directory removed successfully${NC}"
        else
            echo -e "${RED}✗ Failed to remove directory${NC}"
        fi
    fi
    
    echo -e "${YELLOW}Setup interrupted. Exiting...${NC}"
    exit 1
}

# =============================================================================
# Function: validate_python
# Description: Check if Python 3 is installed on the system
# =============================================================================
validate_python() {
    echo -e "\n${BLUE}=== Environment Validation ===${NC}"
    echo -n "Checking for Python 3 installation... "
    
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1)
        echo -e "${GREEN}✓ Found${NC}"
        echo -e "${GREEN}   ${PYTHON_VERSION}${NC}"
        return 0
    else
        echo -e "${RED}✗ Not Found${NC}"
        echo -e "${YELLOW}   Warning: Python 3 is not installed on this system${NC}"
        echo -e "${YELLOW}   The attendance tracker requires Python 3 to run${NC}"
        return 1
    fi
}

# =============================================================================
# Function: validate_input
# Description: Validate that input is a number within a valid range
# Parameters: $1 - input value, $2 - min value, $3 - max value
# =============================================================================
validate_input() {
    local input=$1
    local min=$2
    local max=$3
    
    # Check if input is a number
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    
    # Check if input is within range
    if [ "$input" -lt "$min" ] || [ "$input" -gt "$max" ]; then
        return 1
    fi
    
    return 0
}

# =============================================================================
# Function: update_config
# Description: Prompt user for attendance thresholds and update config.json
# =============================================================================
update_config() {
    echo -e "\n${BLUE}=== Configuration Setup ===${NC}"
    echo -n "Would you like to update attendance thresholds? (y/n): "
    read -r UPDATE_CONFIG
    
    if [[ "$UPDATE_CONFIG" =~ ^[Yy]$ ]]; then
        # Default values
        WARNING_THRESHOLD=75
        FAILURE_THRESHOLD=50
        
        # Prompt for warning threshold
        while true; do
            echo -n "Enter Warning threshold (0-100) [default: 75]: "
            read -r WARNING_INPUT
            
            # Use default if empty
            if [ -z "$WARNING_INPUT" ]; then
                WARNING_INPUT=$WARNING_THRESHOLD
            fi
            
            if validate_input "$WARNING_INPUT" 0 100; then
                WARNING_THRESHOLD=$WARNING_INPUT
                break
            else
                echo -e "${RED}Invalid input. Please enter a number between 0 and 100${NC}"
            fi
        done
        
        # Prompt for failure threshold
        while true; do
            echo -n "Enter Failure threshold (0-100) [default: 50]: "
            read -r FAILURE_INPUT
            
            # Use default if empty
            if [ -z "$FAILURE_INPUT" ]; then
                FAILURE_INPUT=$FAILURE_THRESHOLD
            fi
            
            if validate_input "$FAILURE_INPUT" 0 100; then
                FAILURE_THRESHOLD=$FAILURE_INPUT
                break
            else
                echo -e "${RED}Invalid input. Please enter a number between 0 and 100${NC}"
            fi
        done
        
        # Update config.json using sed
        CONFIG_FILE="${PROJECT_DIR}/Helpers/config.json"
        
        echo -e "${BLUE}Updating configuration file...${NC}"
        
        # Update warning threshold
        sed -i "s/\"warning\": [0-9]\+/\"warning\": ${WARNING_THRESHOLD}/" "$CONFIG_FILE"
        
        # Update failure threshold
        sed -i "s/\"failure\": [0-9]\+/\"failure\": ${FAILURE_THRESHOLD}/" "$CONFIG_FILE"
        
        echo -e "${GREEN}✓ Configuration updated:${NC}"
        echo -e "   Warning threshold: ${WARNING_THRESHOLD}%"
        echo -e "   Failure threshold: ${FAILURE_THRESHOLD}%"
    else
        echo -e "${BLUE}Using default thresholds (Warning: 75%, Failure: 50%)${NC}"
    fi
}

# =============================================================================
# Function: create_directory_structure
# Description: Create the project directory structure
# =============================================================================
create_directory_structure() {
    echo -e "\n${BLUE}=== Creating Directory Structure ===${NC}"
    
    # Check if directory already exists
    if [ -d "$PROJECT_DIR" ]; then
        echo -e "${YELLOW}Warning: Directory ${PROJECT_DIR} already exists${NC}"
        echo -n "Do you want to overwrite it? (y/n): "
        read -r OVERWRITE
        
        if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Removing existing directory...${NC}"
            rm -rf "$PROJECT_DIR"
        else
            echo -e "${RED}Setup cancelled by user${NC}"
            exit 1
        fi
    fi
    
    # Create main project directory
    mkdir -p "$PROJECT_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to create project directory${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Created: ${PROJECT_DIR}${NC}"
    
    # Create Helpers subdirectory
    mkdir -p "${PROJECT_DIR}/Helpers"
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to create Helpers directory${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Created: ${PROJECT_DIR}/Helpers${NC}"
    
    # Create reports subdirectory
    mkdir -p "${PROJECT_DIR}/reports"
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to create reports directory${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Created: ${PROJECT_DIR}/reports${NC}"
}

# =============================================================================
# Function: create_project_files
# Description: Generate all required project files with content
# =============================================================================
create_project_files() {
    echo -e "\n${BLUE}=== Creating Project Files ===${NC}"
    
    # Create attendance_checker.py
    cat > "${PROJECT_DIR}/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF
    
    if [ $? -eq 0 ]; then
        chmod +x "${PROJECT_DIR}/attendance_checker.py"
        echo -e "${GREEN}✓ Created: attendance_checker.py${NC}"
    else
        echo -e "${RED}✗ Failed to create attendance_checker.py${NC}"
        exit 1
    fi
    
    # Create config.json
    cat > "${PROJECT_DIR}/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Created: Helpers/config.json${NC}"
    else
        echo -e "${RED}✗ Failed to create config.json${NC}"
        exit 1
    fi
    
    # Create assets.csv
    cat > "${PROJECT_DIR}/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Created: Helpers/assets.csv${NC}"
    else
        echo -e "${RED}✗ Failed to create assets.csv${NC}"
        exit 1
    fi
    
    # Create reports.log (empty file)
    touch "${PROJECT_DIR}/reports/reports.log"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Created: reports/reports.log${NC}"
    else
        echo -e "${RED}✗ Failed to create reports.log${NC}"
        exit 1
    fi
}

# =============================================================================
# Function: verify_structure
# Description: Verify that all required files and directories exist
# =============================================================================
verify_structure() {
    echo -e "\n${BLUE}=== Verifying Project Structure ===${NC}"
    
    VALID=true
    
    # Check main directory
    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${RED}✗ Main directory missing: ${PROJECT_DIR}${NC}"
        VALID=false
    else
        echo -e "${GREEN}✓ Main directory exists${NC}"
    fi
    
    # Check Helpers directory
    if [ ! -d "${PROJECT_DIR}/Helpers" ]; then
        echo -e "${RED}✗ Helpers directory missing${NC}"
        VALID=false
    else
        echo -e "${GREEN}✓ Helpers directory exists${NC}"
    fi
    
    # Check reports directory
    if [ ! -d "${PROJECT_DIR}/reports" ]; then
        echo -e "${RED}✗ reports directory missing${NC}"
        VALID=false
    else
        echo -e "${GREEN}✓ reports directory exists${NC}"
    fi
    
    # Check attendance_checker.py
    if [ ! -f "${PROJECT_DIR}/attendance_checker.py" ]; then
        echo -e "${RED}✗ attendance_checker.py missing${NC}"
        VALID=false
    else
        echo -e "${GREEN}✓ attendance_checker.py exists${NC}"
    fi
    
    # Check config.json
    if [ ! -f "${PROJECT_DIR}/Helpers/config.json" ]; then
        echo -e "${RED}✗ config.json missing${NC}"
        VALID=false
    else
        echo -e "${GREEN}✓ config.json exists${NC}"
    fi
    
    # Check assets.csv
    if [ ! -f "${PROJECT_DIR}/Helpers/assets.csv" ]; then
        echo -e "${RED}✗ assets.csv missing${NC}"
        VALID=false
    else
        echo -e "${GREEN}✓ assets.csv exists${NC}"
    fi
    
    # Check reports.log
    if [ ! -f "${PROJECT_DIR}/reports/reports.log" ]; then
        echo -e "${RED}✗ reports.log missing${NC}"
        VALID=false
    else
        echo -e "${GREEN}✓ reports.log exists${NC}"
    fi
    
    if [ "$VALID" = true ]; then
        echo -e "\n${GREEN}✓ All files and directories verified successfully${NC}"
        return 0
    else
        echo -e "\n${RED}✗ Structure verification failed${NC}"
        return 1
    fi
}

# =============================================================================
# MAIN EXECUTION FLOW
# =============================================================================

# Set trap for SIGINT (Ctrl+C)
trap cleanup_on_interrupt SIGINT

# Display banner
echo -e "${BLUE}"
echo "============================================================================="
echo "    AUTOMATED PROJECT BOOTSTRAPPING - ATTENDANCE TRACKER FACTORY"
echo "============================================================================="
echo -e "${NC}"

# Prompt for project name
echo -n "Enter project identifier (e.g., 'cs101', 'spring2024'): "
read -r PROJECT_INPUT

# Validate input
if [ -z "$PROJECT_INPUT" ]; then
    echo -e "${RED}Error: Project identifier cannot be empty${NC}"
    exit 1
fi

# Set project variables
PROJECT_NAME="attendance_tracker_${PROJECT_INPUT}"
PROJECT_DIR="./${PROJECT_NAME}"

echo -e "\n${BLUE}Project Name: ${PROJECT_NAME}${NC}"
echo -e "${BLUE}Project Directory: ${PROJECT_DIR}${NC}"

# Execute setup steps
create_directory_structure
create_project_files
update_config
validate_python
verify_structure

# Final success message
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}============================================================================="
    echo "    PROJECT SETUP COMPLETE!"
    echo "=============================================================================${NC}"
    echo -e "${GREEN}✓ Project created successfully at: ${PROJECT_DIR}${NC}"
    echo -e "\n${BLUE}To run the attendance tracker:${NC}"
    echo -e "  cd ${PROJECT_DIR}"
    echo -e "  python3 attendance_checker.py"
    echo -e "\n${BLUE}To trigger the archive feature:${NC}"
    echo -e "  Run this script again and press Ctrl+C during execution"
    echo ""
else
    echo -e "\n${RED}Setup completed with warnings. Please review the output above.${NC}"
fi
