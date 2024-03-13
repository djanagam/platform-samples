# Function to retrieve repository names with a specific topic from GitHub
function Get-GitHubRepositoriesWithTopic {
    param (
        [string]$Topic,
        [string]$Token
    )

    $uri = "https://api.github.com/search/repositories?q=topic:$Topic"
    $headers = @{
        "Authorization" = "token $Token"
        "User-Agent" = "PowerShell"
    }

    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    return $response.items.name
}

# Write repository names with the topic "sgp-code" to input.txt
$token = "your_github_token_here"
$topic = "sgp-code"
$repositories = Get-GitHubRepositoriesWithTopic -Topic $topic -Token $token
$repositories | Out-File -FilePath "input.txt"

# Rest of the script remains the same as before
# Define other functions...

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