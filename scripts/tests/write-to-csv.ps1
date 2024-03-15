function Add-RepoToCSV {
    param (
        [string]$RepoName,
        [string]$CreationDate,
        [string]$LastUsed,
        [string]$Contributors,
        [string]$CSVFilePath
    )

    # Replace empty variables with "null"
    if ([string]::IsNullOrEmpty($RepoName)) { $RepoName = "null" }
    if ([string]::IsNullOrEmpty($CreationDate)) { $CreationDate = "null" }
    if ([string]::IsNullOrEmpty($LastUsed)) { $LastUsed = "null" }
    if ([string]::IsNullOrEmpty($Contributors)) { $Contributors = "null" }

    # Create custom object
    $repoObject = [PSCustomObject]@{
        RepoName = $RepoName
        CreationDate = $CreationDate
        LastUsed = $LastUsed
        Contributors = $Contributors
    }

    # Append object to CSV file
    $repoObject | Export-Csv -Path $CSVFilePath -Append -NoTypeInformation
}