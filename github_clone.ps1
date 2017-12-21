<#
.Synopsis
   This cmdlet is designed to make your life easier with github repositories.
.DESCRIPTION
   This cmdlet will get a full listing of repositories for the specified account by connecting to the GitHub api to pull down the repos.  It will then check the existing directory to see if there are any existing repositories and perform a git pull --all to fetch the latest changes.  It will clone any non existing repos into the same directory.
.EXAMPLE
   GitHub-Clone -Account "CaptainFluffyToes"
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function GitHub-Clone
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # This parameter is the account of the repos that are going to be used.
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [string]$Account
    )

    Begin
    {
        do {
            $Account = Read-Host -Prompt 'Please enter the name of the GitHub Account.'
            if ($Account -eq $Null) {
                Write-Host 'No account name entered!'
            }
        } while ($Account -eq $Null)
        if ($Repos -eq $Null) {
            $Repos = Invoke-RestMethod -Method GET -Uri "https://api.github.com/users/$Account/repos"
        }
    }
    Process
    {
        [array]$existing_repos = Get-ChildItem -Directory
        if ($existing_repos -eq $Null) {
            $count = 1
            foreach ($new_repo in $Repos) {
                Write-Host "Creating new repository $($new_repo.name). Number $count of $(($Repos.name | Measure-Object).count)" -ForegroundColor Red
                git clone "$($new_repo.clone_url)"
                $count++
            }
        }
        else {
            $comparison = Compare-Object -ReferenceObject $existing_repos.name -DifferenceObject $Repos.name
            $new_repos = ($comparison | Where-Object {($_.SideIndicator -match "=>")}).InputObject
            if ($existing_repos -ne $Null) {
                $total_repos = ($existing_repos | Measure-Object).count
                $number = 1
                foreach ($existing_repo in $existing_repos) {
                    Set-location -Path .\$($existing_repo.name)
                    if (($(Get-ChildItem -Hidden) -match ".git") -or ($(Get-ChildItem) -match ".git")) {
                        Write-Host "Working on repository $($existing_repo.name). Number $number of $total_repos" -foregroundcolor Red
                        git pull --all 
                        Set-Location ..
                        $number++   
                    }
                    else {
                        Write-Host "This is not a git repository" -ForegroundColor Red
                        Set-Location ..
                    }
                }
            }
            if ($new_repos -ne $Null) {
                foreach ($new_repo in $new_repos) {
                    $clone_url = ($Repos | Where-Object {($_.name -eq $new_repo)}).clone_url
                    git clone $clone_url
                }
            }
        }
    }
    End
    {
    }
}