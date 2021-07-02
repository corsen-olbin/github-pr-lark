# GitHub PR Lark
Does your team use rotating PRs? Do you constantly not notice emails for these PRs?
Well here's a tool for you. Just need to setup a personal access token and supply your username and the script will let you 
know if any PRs have your name on it. 

## Setup
1. Create Personal Access Token for your GitHub account with repo scope.
2. Use PAT to set environment variable with

<pre>[Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_TOKEN", '<i>Your PAT here</i>', 'User')</pre>

## Usage

### To Check PRs in Powershell
<pre>checkPRs.ps1 -Username '<i>Your GitHub Username here</i>'</pre>

### To Create Windows Notification if you have Open PRs
<pre>checkPRs.ps1 -Username '<i>Your GitHub Username here</i>' -WindowsNotification</pre>

This is the recommended way if you set it up to run in Task Scheduler
