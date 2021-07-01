<#

.SYNOPSIS
This is a Powershell script to check for PRs in GitHub.

.DESCRIPTION
Does your team use rotating PRs? Do you constantly not notice emails for said PRs? Are your coworkers tired of asking you for PRs?
Well then this script is for you! Just need to setup a personal access token and supply your username and the script will let you 
know if any PRs have your name on it. 

.PARAMETER Username
Your GitHub username to check PRs for.

.PARAMETER WindowsNotification
Flag that specifies if you want a windows notification to appear. Useful to set this flag when running script in the Task Scheduler.

#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String] $Username,
    [Switch] $WindowsNotification
)

if (-not $env:GITHUB_PERSONAL_TOKEN) {
    Write-Error "Environment Variable GITHUB_PERSONAL_TOKEN not set for the user."
    Exit 1
}

if ($WindowsNotification) {
    # make sure BurntToast is installed https://github.com/Windos/BurntToast
    if (Get-Module -ListAvailable -Name BurntToast) {
        Write-Host "BurntToast already installed"
    } 
    else {
        try {
            Install-Module -Name BurntToast -AllowClobber -Confirm:$False -Force  
        }
        catch [Exception] {
            Write-Error $_.message 
            Exit 1
        }
    }
}



$prs = Invoke-RestMethod -Uri "https://api.github.com/search/issues?q=review-requested:$($Username)+is:pr+is:open" -Headers @{"Authorization" = "token $($env:GITHUB_PERSONAL_TOKEN)"}

$prsToReview = @()
foreach ($pr in $prs.items) {
    $reviewers = Invoke-RestMethod -Uri "$($pr.pull_request.url)/requested_reviewers" -Headers @{"Authorization" = "token $($env:GITHUB_PERSONAL_TOKEN)"}
    
    foreach ($user in $reviewers.users) {
        if ($user.login -eq $Username) {
            $prsToReview += "$($pr.repository_url.Substring(29)) #$($pr.number)"
        }
    }
}

Write-Host "You have $($prsToReview.Length) PRs to review"
Write-Host ($prsToReview -join "`n")

# Only create Windows Notification if there are any PRs to review
if ($prsToReview.Length -gt 0) {
    if ($WindowsNotification) {
        New-BurntToastNotification -AppLogo .\github_logo.png -Text "You have $($prsToReview.Length) PRs to review",($prsToReview -join "`n")
    }
}
