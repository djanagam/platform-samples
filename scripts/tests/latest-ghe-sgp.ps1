# Define functions
function Get-GitHubRepoCollaborators {
    param (
        [string]$RepoOwner,
        [string]$RepoName,
        [string]$Token
    )

    $uri = "https://api.github.com/repos/$RepoOwner/$RepoName/collaborators"
    $headers = @{
        "Authorization" = "token $Token"
        "User-Agent" = "PowerShell"
    }

    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    return $response
}

function Get-GitHubRepoCreationDate {
    param (
        [string]$RepoOwner,
        [string]$RepoName,
        [string]$Token
    )

    $uri = "https://api.github.com/repos/$RepoOwner/$RepoName"
    $headers = @{
        "Authorization" = "token $Token"
        "User-Agent" = "PowerShell"
    }

    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    return $response.created_at
}

function Get-GitHubRepoRecentCommit {
    param (
        [string]$RepoOwner,
        [string]$RepoName,
        [string]$Token
    )

    $uri = "https://api.github.com/repos/$RepoOwner/$RepoName/commits"
    $headers = @{
        "Authorization" = "token $Token"
        "User-Agent" = "PowerShell"
    }

    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    return $response[0].commit
}

function Get-GitHubFileContent {
    param (
        [string]$RepoOwner,
        [string]$RepoName,
        [string]$Token,
        [string]$FilePath
    )

    $uri = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/$FilePath"
    $headers = @{
        "Authorization" = "token $Token"
        "User-Agent" = "PowerShell"
    }

    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    $content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($response.content))

    # Parse the YAML content
    $yaml = ConvertFrom-Yaml -InputObject $content

    # Extract the value of 'id'
    $id = $yaml.central.id

    return $id
}

# Read input file
$inputFile = "input.txt"
$outputFile = "report.csv"

# Initialize an empty array to store results
$results = @()

# Process each line in the input file
foreach ($line in Get-Content $inputFile) {
    $repoOwner, $repoName, $token = $line -split ","
    
    # Execute functions for each repository
    $collaborators = Get-GitHubRepoCollaborators -RepoOwner $repoOwner -RepoName $repoName -Token $token
    $creationDate = Get-GitHubRepoCreationDate -RepoOwner $repoOwner -RepoName $repoName -Token $token
    $recentCommit = Get-GitHubRepoRecentCommit -RepoOwner $repoOwner -RepoName $repoName -Token $token
    $id = Get-GitHubFileContent -RepoOwner $repoOwner -RepoName $repoName -Token $token -FilePath ".amex/buildblocks.yaml"
    
    # Extract collaborators' names or email IDs
    $collaboratorInfo = $collaborators | ForEach-Object {
        $_.login  # Use $_.email for email IDs
    }
    
    # Create a custom object with repository details and collaborators' information
    $reportObj = [PSCustomObject]@{
        "Repository" = "$repoOwner/$repoName"
        "CreationDate" = $creationDate
        "RecentCommit" = $recentCommit.sha
        "IDFromYAML" = $id
        "Collaborators" = $collaboratorInfo -join ", "
    }

    # Add the custom object to the results array
    $results += $reportObj
}

# Export results to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation -Force