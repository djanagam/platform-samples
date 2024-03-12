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
    return $content
}

# Example usage:
$repoOwner = "Amex-Eng"
$repoName = "test-repo"
$token = "your_github_token_here"

$collaborators = Get-GitHubRepoCollaborators -RepoOwner $repoOwner -RepoName $repoName -Token $token
$creationDate = Get-GitHubRepoCreationDate -RepoOwner $repoOwner -RepoName $repoName -Token $token
$recentCommit = Get-GitHubRepoRecentCommit -RepoOwner $repoOwner -RepoName $repoName -Token $token
$fileContent = Get-GitHubFileContent -RepoOwner $repoOwner -RepoName $repoName -Token $token -FilePath ".amex/buildblocks.yaml"

Write-Host "Collaborators:"
$collaborators

Write-Host "Creation Date: $creationDate"

Write-Host "Most Recent Commit:"
$recentCommit

Write-Host "Content of .amex/buildblocks.yaml:"
$fileContent

##################################
#Another functionvrovget more soecific content of yaml file 

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

<#
Usage
$repoOwner = "Amex-Eng"
$repoName = "test-repo"
$token = "your_github_token_here"

$id = Get-GitHubFileContent -RepoOwner $repoOwner -RepoName $repoName -Token $token -FilePath ".amex/buildblocks.yaml"

Write-Host "Value of 'id': $id"
#>

