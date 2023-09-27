# Automated folder/file backup

# Enter your backup related directories here
$sourceFoldersToBackup = @("C:\Path\To\Files", "C:\Path\To\Files2", "C:\Path\To\Files3")
$backupDestination = "C:\Path\To\Backup"
$logFilePath = "C:\Path\To\Log\"

# Folder contents for verification
$sourceFolderContents = @{}
$backupFolderContents = @{}

# If script should output to the console
$printToConsole = $true

# Create backup destination folder if it doesn't exist
if (-not (Test-Path -Path $backupDestination -PathType Container)) {
    New-Item -Path $backupDestination -ItemType Directory
} else {
    Write-Host "Backup directory exists"
}

# Create backup folder for current backup
$backupFolder = Join-Path -Path $backupDestination -ChildPath (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
New-Item -Path $backupFolder -ItemType Directory

# Create Log file path for current backup
$logFilePath = Join-Path -Path $logFilePath -ChildPath (Split-Path $backupFolder -Leaf)
New-Item -Path $logFilePath -ItemType Directory

# Create empty log file 
$logFilePathAndName = Join-Path -Path $logFilePath -ChildPath ("Backup_Log_" + (Split-Path $backupFolder -Leaf) + ".log")
New-Item -Path $logFilePathAndName -ItemType File

# Copy source folders to new backup folder and populate FolderContents hash tables for verification
foreach ($folderToBackup in $sourceFoldersToBackup) {
    # Get folder to be copied name
    $folderJustCopied = Split-Path $folderToBackup -Leaf
    Copy-Item -Path $folderToBackup -Destination $backupFolder -Recurse

    # Create hash tables for verification and sort for readability
    $sourceFolderContents[$folderJustCopied] = Get-ChildItem -Path $folderToBackup -Recurse | Sort-Object Fullname
    $backupFolderContents[$folderJustCopied] = Get-ChildItem -Path (Join-Path -Path $backupFolder -ChildPath $folderJustCopied) -Recurse | Sort-Object Fullname
}

Write-Host "Backup complete, starting verification"
Write-Host

# Check if backup had any files it could not copy
$validationResults = Compare-Object @($sourceFolderContents.Keys) @($backupFolderContents.Keys)
if ($validationResults.Count -eq 0) {
    Write-Host "Backup completed successfully, outputting results to log"
    Write-Host
} else {
    Write-Host "Backup completed with errors, outputting results to log"
    Write-Host
}

# Create log file and print results to terminal
foreach ($key in $backupFolderContents.Keys) {
    $value = $backupFolderContents[$key]

    foreach ($file in $value) {
        if ($printToConsole) {
            Write-Host "Success " -ForegroundColor Green -NoNewline
            Write-Host "Folder: $key     File: $file"
        } else {
            $line = "Success Folder: $key     File: $file"
        }

        # Check if there is a mismatch in the validation results
        $mismatch = $validationResults | Where-Object { $_.InputObject -eq $key }

        if ($mismatch) {
            if ($printToConsole) {
                Write-Host "Failed  " -ForegroundColor Red -NoNewline
                Write-Host "Folder: $key     File: $file"
            } else {
                $line = "Failed: Folder: $key     File: $file"
            }
        }

        Add-Content -Path $logFilePathAndName -Value $line
    }
}

Write-Host
Write-Host "Log completed"

