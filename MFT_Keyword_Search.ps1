<#
Description: PowerShell script to automate the search of the MFT csv file created after the use of MFTECmd.

Author: Mike Dunn

Creation Date: 4/3/2023

Version: 1

NOTE: Requires a keyword text file.
#>

Add-Type -AssemblyName System.Windows.Forms
$fileDialog = New-Object System.Windows.Forms.OpenFileDialog
$fileDialog.Title = "Select Keyword Text File"
$fileDialog.Filter = "TXT files (*.txt)|*.txt"

if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $KeywordFilePath = $fileDialog.FileName
    Write-Host "Selected file: $KeywordFilePath"
} else {
    Write-Host "File selection canceled"
    break
}

Add-Type -AssemblyName System.Windows.Forms
$fileDialog = New-Object System.Windows.Forms.OpenFileDialog
$fileDialog.Title = "Select MFT CSV file"
$fileDialog.Filter = "CSV files (*.csv)|*.csv"

if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $MFTFilePath = $fileDialog.FileName
    Write-Host "Selected file: $MFTFilePath"
} else {
    Write-Host "File selection canceled"
    break
}

$keywordList = New-Object System.Collections.ArrayList
Get-Content $KeywordFilePath | ForEach-Object { $keywordList.Add($_) | Out-Null }

Write-Host "Importing MFT CSV File, please wait..."
$csv = Import-Csv $MFTFilePath | Select-Object "FileName"

$totalRows = $csv.Count
$currentRow = 0
$percentComplete = 0
Write-Progress -Activity "Searching for matches" -Status "Processing row $currentRow of $totalRows" -PercentComplete $percentComplete


foreach ($row in $csv) {
    foreach ($keyword in $keywordList) {
        if ($row -match $keyword) {
            $row | Export-Csv -Path "$env:UserProfile\Desktop\Results.csv" -Append -Force -NoTypeInformation
            break
        }
    }
    $currentRow++
    $percentComplete = [int]($currentRow / $totalRows * 100)
    Write-Progress -Activity "Searching for matches" -Status "Processing row $currentRow of $totalRows" -PercentComplete $percentComplete
}

Write-Progress -Activity "Searching for matches" -Status "Complete" -PercentComplete 100
