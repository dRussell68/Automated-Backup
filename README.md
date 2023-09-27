# Automated Folder and File Backup with PowerShell
## Overview
This PowerShell script automates the process of creating backups for specified source folders and files, with verification and logging.

## Features
- Source Folders: You can specify multiple source folders to be backed up.

- Backup Destination: Choose the location where the backup will be stored.

- Logging: The script logs the backup process and verification results to a text file.

- Color-coded Output: Visual feedback with green for success and red for failure makes it easy to spot issues.

## Usage
**Define Backup Parameters** 
  Open the script and configure the following parameters:
```
$sourceFoldersToBackup = @(
    "C:\Path\To\Files",
    "C:\Path\To\Files2",
    "C:\Path\To\Files3"
)

$backupDestination = "C:\Path\To\Backup"
$logFilePath = "C:\Path\To\Log\"
```
### Run the Script
- Execute the script to start the backup process.

### Backup Folder
- A backup folder with a timestamp (e.g., yyyy-MM-dd_HH-mm-ss) is created in the specified backup destination.

### Copying Files
- The script copies the contents of the source folders to the backup folder while maintaining the folder structure.

### Verification
- Compares the source and backup folder contents, ensuring data integrity.

### Logging
- Logs are generated, capturing the backup process and any verification discrepancies.

## Requirements
PowerShell (Windows PowerShell or PowerShell Core)

## Important Notes
Ensure that the source folders and backup destination paths are correctly set before running the script.

## Author
Derrek Russell

## License
This project is licensed under the MIT License - see the LICENSE.md file for details.
