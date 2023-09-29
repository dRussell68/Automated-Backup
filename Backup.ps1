# Automated folder/file backup

# Enter your backup related directories here
$sourceFoldersToBackup = @("C:\Path\To\Files", "C:\Path\To\Files2", "C:\Path\To\Files3")
$backupDestination = "C:\Path\To\Backup"
$logFilePath = "C:\Path\To\Logs"
[bool]$disableLogging = $false
$invalidPaths = New-Object System.Collections.Generic.List[string]

# Backup folder name for current backup
$backupFolder = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Check if source backup folders are valid
foreach ($path in $sourceFoldersToBackup) {
    if (-not(Test-Path -Path $path -PathType Container)) {
        $invalidPaths.Add($path)
    }
}

# If invalid paths are found, let the user know and exit
if ($invalidPaths.Length -gt 0) {
    foreach ($path in $invalidPaths) {
        Write-Host "Invalid source backup path, please correct $path" -ForegroundColor Red
    }

    Write-Host
    Write-Host "Error cannot continue with backup until source backup folder paths are corrected, exiting..." -ForegroundColor Red
    Exit
}



# Check if creating log folder and file is possible
try {
    # Create Log file path for current backup
    $logFilePath = Join-Path -Path $logFilePath -ChildPath (Split-Path $backupFolder -Leaf)
    New-Item -Path $logFilePath -ItemType Directory

    # Create empty log file 
    $logFile = Join-Path -Path $logFilePath -ChildPath ("Backup_Log_" + (Split-Path $backupFolder -Leaf) + ".log")
    New-Item -Path $logFile -ItemType File
    Write-Host
} catch {
    Write-Host "An unexpected error occurred: $($_.Exception.Message) ($logFilePath)" -ForegroundColor Red
    Write-Host "Will not be able to log backup" -ForegroundColor Red
    Write-Host
    $disableLogging = $true
}

# Check if creating backup folder is possible
try {
    # Create backup destination folder if it doesn't exist
    if (-not (Test-Path -Path $backupDestination -PathType Container)) {
        New-Item -Path $backupDestination -ItemType Directory
    }
} catch {
    Write-Host "An unexpected error occurred: $($_.Exception.Message) ($backupDestination)" -ForegroundColor Red
    Write-Host "Cannot continue with backup" -ForegroundColor Red
    Write-Host

    if (-not $disableLogging) {
        Add-Content -Path $logFile -Value "An unexpected error occurred: $($_.Exception.Message)"
        Add-Content -Path $logFile -Value "Cannot continue with backup, exiting..."
    }

    Write-Host "Exiting..." -ForegroundColor Red
    Exit
}

# Copy source folders to new backup folder and verify and log
foreach ($folderToBackup in $sourceFoldersToBackup) {
    # Get folder to be copied name
    $parentFolder = Split-Path $folderToBackup -Leaf

    # Copy each item of folders to backup, log errors
    foreach ($item in Get-ChildItem -Path $folderToBackup -File -Recurse) {
        $parentPath = $item.Directory -replace ".*\\$parentFolder", $parentFolder

        # Catch an error copying files and then continue copying
        try {
            # Create the folder the current file belongs to
            $newFolder = Join-Path -Path $backupDestination -ChildPath $backupFolder
            $newFolder = Join-Path -Path $newFolder -ChildPath $parentPath
            if (-not(Test-Path -Path $newFolder -PathType Container)) {
                New-Item -Path $newFolder -ItemType Directory
            }

            # Copy item to folder
            Copy-Item -Path $item.FullName -Destination $newFolder -Force -ErrorAction Stop

            # Print to console current files being copied
            Write-Host "Success " -ForegroundColor Green -NoNewline
            Write-Host "Copied: $($item.FullName)"

            
            if (-not $disableLogging) {
                # Add result of copy to the log
                Add-Content -Path $logFile -Value "Success Copied: $($item.FullName)"
            }
        } catch {
            # Display and log a simple error message
            $errorMessage = "Error: $($_.Exception.Message)"
            Write-Host $errorMessage -ForegroundColor Red 
            
            if (-not $disableLogging) {
                Add-Content -Path $logFile -Value $errorMessage
            }
        }
    }
}
