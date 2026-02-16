# Attendance Tracker Deployment Agent

## Overview

This project provides an automated deployment script (`setup_project.sh`) that bootstraps a complete Student Attendance Tracker application. The script demonstrates Infrastructure as Code (IaC) principles by automating project setup, configuration management, and graceful error handling.

## Features

### 1. **Automated Directory Architecture**
- Creates a parent directory named `attendance_tracker_{input}`
- Generates the complete project structure:
  ```
  attendance_tracker_{input}/
  ├── attendance_checker.py
  ├── Helpers/
  │   ├── assets.csv
  │   └── config.json
  └── reports/
      └── reports.log
  ```

### 2. **Dynamic Configuration (Stream Editing)**
- Interactive prompts for customizing attendance thresholds
- Input validation for numeric values (0-100 range)
- Uses `sed` for in-place editing of `config.json`
- Default values: Warning (75%), Failure (50%)

### 3. **Process Management (Signal Handling)**
- Implements a SIGINT trap for graceful interruption handling
- On Ctrl+C:
  - Creates a compressed archive: `attendance_tracker_{input}_archive.tar.gz`
  - Removes the incomplete directory to maintain clean workspace
  - Displays cleanup progress with colored output

### 4. **Environment Validation**
- Checks for Python 3 installation using `python3 --version`
- Verifies complete directory structure
- Validates all required files exist

## Prerequisites

- Bash shell (version 4.0 or higher recommended)
- Python 3.x (for running the attendance tracker)
- `tar` command (for archive creation)
- `sed` command (for configuration editing)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/deploy_agent_YourGithubUsername.git
   cd deploy_agent_YourGithubUsername
   ```

2. Make the script executable:
   ```bash
   chmod +x setup_project.sh
   ```

## Usage

### Basic Setup

Run the script:
```bash
./setup_project.sh
```

Follow the interactive prompts:
1. Enter a project identifier (e.g., "cs101", "spring2024")
2. Choose whether to update attendance thresholds
3. If updating, enter warning and failure percentages

### Running the Attendance Tracker

After successful setup:
```bash
cd attendance_tracker_{your_input}
python3 attendance_checker.py
```

### Triggering the Archive Feature

The archive feature is automatically triggered when you interrupt the script:

**Method 1: During Initial Setup**
1. Run `./setup_project.sh`
2. Press `Ctrl+C` at any point during execution
3. The script will:
   - Create `attendance_tracker_{input}_archive.tar.gz`
   - Delete the incomplete `attendance_tracker_{input}` directory
   - Display cleanup messages

**Method 2: Intentional Testing**
```bash
# Start the script
./setup_project.sh

# Press Ctrl+C after entering the project name
# Archive will be created automatically
```

### Extracting an Archive

If you have an archived project:
```bash
tar -xzf attendance_tracker_{input}_archive.tar.gz
cd attendance_tracker_{input}
python3 attendance_checker.py
```

## Script Structure

### Main Functions

1. **`cleanup_on_interrupt()`**
   - Signal handler for SIGINT
   - Creates compressed archive
   - Removes incomplete directory

2. **`validate_python()`**
   - Checks for Python 3 installation
   - Displays version information

3. **`validate_input()`**
   - Validates numeric input
   - Ensures values are within 0-100 range

4. **`update_config()`**
   - Interactive threshold configuration
   - Uses `sed` for in-place JSON editing

5. **`create_directory_structure()`**
   - Creates main and subdirectories
   - Handles existing directory conflicts

6. **`create_project_files()`**
   - Generates all required project files
   - Populates with sample data

7. **`verify_structure()`**
   - Validates complete project setup
   - Performs health check

## Project Files

### attendance_checker.py
Main Python application that:
- Loads configuration from `config.json`
- Reads student data from `assets.csv`
- Analyzes attendance rates
- Generates reports in `reports/reports.log`

### Helpers/config.json
Configuration file containing:
- `warning_threshold`: Percentage for warning status
- `failure_threshold`: Percentage for failing status
- `report_format`: Output format setting
- `auto_notify`: Notification preference

### Helpers/assets.csv
Sample student attendance data with columns:
- `student_id`: Unique student identifier
- `name`: Student name
- `attendance_rate`: Attendance percentage

### reports/reports.log
Output file for generated attendance reports

## Error Handling

The script includes robust error handling for:
- Empty or invalid project identifiers
- Existing directory conflicts
- File creation failures
- Invalid numeric input
- Missing Python installation
- Permission denied errors

## Color-Coded Output

- **Green (✓)**: Successful operations
- **Red (✗)**: Errors or failures
- **Yellow (!)**: Warnings or interruptions
- **Blue (===)**: Section headers and information

## Testing the Script

### Test Case 1: Normal Execution
```bash
./setup_project.sh
# Enter: test1
# Choose: y
# Warning: 80
# Failure: 60
```

### Test Case 2: Default Configuration
```bash
./setup_project.sh
# Enter: test2
# Choose: n
```

### Test Case 3: Archive Creation
```bash
./setup_project.sh
# Enter: test3
# Press: Ctrl+C immediately
# Verify: test3_archive.tar.gz exists
```

### Test Case 4: Existing Directory
```bash
./setup_project.sh
# Enter: test1 (from Test Case 1)
# Choose: y (to overwrite)
```

## Troubleshooting

**Issue**: Script fails with "Permission denied"
- **Solution**: Run `chmod +x setup_project.sh`

**Issue**: "python3: command not found"
- **Solution**: Install Python 3 on your system

**Issue**: Archive not created on Ctrl+C
- **Solution**: Ensure you press Ctrl+C during script execution, not before

**Issue**: sed command not found
- **Solution**: Install GNU sed (usually pre-installed on Linux/Mac)

## Learning Outcomes

This project demonstrates:
- Shell scripting fundamentals
- Signal handling and traps
- Stream editing with sed
- Error handling and validation
- Automation and IaC principles
- Version control best practices

## License

This project is created for educational purposes as part of the ALU Introduction to Linux and IT Tools course.

## Author

Created by: [Your Name]
GitHub: [@YourUsername]
Course: Introduction to Linux and IT Tools - January 2026

## Submission Checklist

- [x] `setup_project.sh` - Main deployment script
- [x] `README.md` - Complete documentation
- [ ] Video walkthrough - Explanation of approach and logic
- [ ] GitHub repository - Named `deploy_agent_GithubUsername`
- [ ] Clean commit history - Demonstrating development process

## Video Walkthrough Notes

The video should cover:
1. Project structure and requirements overview
2. Script architecture and function breakdown
3. Signal trap implementation and testing
4. Sed usage for dynamic configuration
5. Live demonstration of:
   - Normal execution
   - Archive creation via Ctrl+C
   - Running the attendance tracker
6. Edge cases and error handling
7. GitHub workflow and version control

## Contact

For questions or issues, please open an issue on GitHub or contact through the course platform.
