# Automated folder/file backup

# Enter your backup related directories here
$sourceFoldersToBackup = @("C:\Path\To\Files", "C:\Path\To\Files2", "C:\Path\To\Files3")
$backupDestination = "C:\Path\To\Test\Backup"
$logFilePath = "C:\Path\To\Logs\"

try {
    # Create backup destination folder if it doesn't exist
    if (-not (Test-Path -Path $backupDestination -PathType Container)) {
        New-Item -Path $backupDestination -ItemType Directory
    }

    # Create backup folder for current backup
    $backupFolder = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

    # Create Log file path for current backup
    $logFilePath = Join-Path -Path $logFilePath -ChildPath (Split-Path $backupFolder -Leaf)
    New-Item -Path $logFilePath -ItemType Directory

    # Create empty log file 
    $logFilePathAndName = Join-Path -Path $logFilePath -ChildPath ("Backup_Log_" + (Split-Path $backupFolder -Leaf) + ".log")
    New-Item -Path $logFilePathAndName -ItemType File
    Write-Host
} catch {
    Write-Host "An unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Cannot continue with backup, exiting..." -ForegroundColor Red
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

            # Add result of copy to the log
            Add-Content -Path $logFilePathAndName -Value "Success Copied: $($item.FullName)"
        } catch {
            # Display and log a simple error message
            $errorMessage = "Error: $($_.Exception.Message)"
            Write-Host $errorMessage -ForegroundColor Red 
            
            Add-Content -Path $logFilePathAndName -Value $errorMessage
        }
    }
}
