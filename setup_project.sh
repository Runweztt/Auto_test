#!/bin/bash

# Automated Project Bootstrapping for Student Attendance Tracker
# This script creates the project structure, generates files, and handles interruptions

PROJECT_NAME=""
PROJECT_DIR=""

# Signal handler for Ctrl+C
cleanup_on_interrupt() {
    echo ""
    echo "Signal received! Cleaning up..."
    
    if [ -d "$PROJECT_DIR" ]; then
        ARCHIVE_NAME="${PROJECT_NAME}_archive.tar.gz"
        echo "Creating archive: ${ARCHIVE_NAME}"
        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR" 2>/dev/null
        
        echo "Removing incomplete directory: ${PROJECT_DIR}"
        rm -rf "$PROJECT_DIR"
    fi
    
    echo "Setup interrupted."
    exit 1
}

# Validate numeric input
validate_input() {
    local input=$1
    local min=$2
    local max=$3
    
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    
    if [ "$input" -lt "$min" ] || [ "$input" -gt "$max" ]; then
        return 1
    fi
    
    return 0
}

# Check Python installation
validate_python() {
    echo ""
    echo "Checking Python installation..."
    
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1)
        echo "Found: ${PYTHON_VERSION}"
        return 0
    else
        echo "Warning: Python 3 not found"
        return 1
    fi
}

# Update configuration thresholds
update_config() {
    echo ""
    echo -n "Update attendance thresholds? (y/n): "
    read -r UPDATE_CONFIG
    
    if [[ "$UPDATE_CONFIG" =~ ^[Yy]$ ]]; then
        WARNING_THRESHOLD=75
        FAILURE_THRESHOLD=50
        
        while true; do
            echo -n "Warning threshold (0-100) [75]: "
            read -r WARNING_INPUT
            
            if [ -z "$WARNING_INPUT" ]; then
                WARNING_INPUT=$WARNING_THRESHOLD
            fi
            
            if validate_input "$WARNING_INPUT" 0 100; then
                WARNING_THRESHOLD=$WARNING_INPUT
                break
            else
                echo "Invalid. Enter a number between 0 and 100."
            fi
        done
        
        while true; do
            echo -n "Failure threshold (0-100) [50]: "
            read -r FAILURE_INPUT
            
            if [ -z "$FAILURE_INPUT" ]; then
                FAILURE_INPUT=$FAILURE_THRESHOLD
            fi
            
            if validate_input "$FAILURE_INPUT" 0 100; then
                FAILURE_THRESHOLD=$FAILURE_INPUT
                break
            else
                echo "Invalid. Enter a number between 0 and 100."
            fi
        done
        
        CONFIG_FILE="${PROJECT_DIR}/Helpers/config.json"
        sed -i "s/\"warning\": [0-9]\+/\"warning\": ${WARNING_THRESHOLD}/" "$CONFIG_FILE"
        sed -i "s/\"failure\": [0-9]\+/\"failure\": ${FAILURE_THRESHOLD}/" "$CONFIG_FILE"
        
        echo "Configuration updated: Warning=${WARNING_THRESHOLD}%, Failure=${FAILURE_THRESHOLD}%"
    else
        echo "Using defaults: Warning=75%, Failure=50%"
    fi
}

# Create directory structure
create_directory_structure() {
    echo ""
    echo "Creating directory structure..."
    
    if [ -d "$PROJECT_DIR" ]; then
        echo "Warning: Directory already exists"
        echo -n "Overwrite? (y/n): "
        read -r OVERWRITE
        
        if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR"
        else
            echo "Cancelled."
            exit 1
        fi
    fi
    
    mkdir -p "$PROJECT_DIR"
    mkdir -p "${PROJECT_DIR}/Helpers"
    mkdir -p "${PROJECT_DIR}/reports"
    
    echo "Created: ${PROJECT_DIR}"
    echo "Created: ${PROJECT_DIR}/Helpers"
    echo "Created: ${PROJECT_DIR}/reports"
}

# Generate project files
create_project_files() {
    echo ""
    echo "Creating project files..."
    
    cat > "${PROJECT_DIR}/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
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
    
    chmod +x "${PROJECT_DIR}/attendance_checker.py"
    
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
    
    cat > "${PROJECT_DIR}/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
    
    touch "${PROJECT_DIR}/reports/reports.log"
    
    echo "Created: attendance_checker.py"
    echo "Created: Helpers/config.json"
    echo "Created: Helpers/assets.csv"
    echo "Created: reports/reports.log"
}

# Verify structure
verify_structure() {
    echo ""
    echo "Verifying structure..."
    
    [ -d "$PROJECT_DIR" ] && echo "✓ Main directory"
    [ -d "${PROJECT_DIR}/Helpers" ] && echo "✓ Helpers directory"
    [ -d "${PROJECT_DIR}/reports" ] && echo "✓ reports directory"
    [ -f "${PROJECT_DIR}/attendance_checker.py" ] && echo "✓ attendance_checker.py"
    [ -f "${PROJECT_DIR}/Helpers/config.json" ] && echo "✓ config.json"
    [ -f "${PROJECT_DIR}/Helpers/assets.csv" ] && echo "✓ assets.csv"
    [ -f "${PROJECT_DIR}/reports/reports.log" ] && echo "✓ reports.log"
}

# Main execution
trap cleanup_on_interrupt SIGINT


echo "Attendance Tracker Setup"
echo ""
echo -n "Enter project identifier: "
read -r PROJECT_INPUT

if [ -z "$PROJECT_INPUT" ]; then
    echo "Error: Project identifier required"
    exit 1
fi

PROJECT_NAME="attendance_tracker_${PROJECT_INPUT}"
PROJECT_DIR="./${PROJECT_NAME}"

echo "Project: ${PROJECT_NAME}"

create_directory_structure
create_project_files
update_config
validate_python
verify_structure

echo ""
echo "Setup Complete!"
echo "Location: ${PROJECT_DIR}"
echo ""
echo "To run:"
echo "  cd ${PROJECT_DIR}"
echo "  python3 attendance_checker.py"
echo ""