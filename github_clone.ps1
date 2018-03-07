<#
.Synopsis
   This cmdlet is designed to make your life easier with github repositories.
.DESCRIPTION
   This cmdlet will get a full listing of repositories for the specified account by connecting to the GitHub api to pull down the repos.  It will then check the existing directory to see if there are any existing repositories and perform a git pull --all to fetch the latest changes.  It will clone any non existing repos into the same directory.
.EXAMPLE
   GitHub-Clone -Account "CaptainFluffyToes"
.EXAMPLE
   GitHub-Clone -Account "CaptainFluffyToes" -User_Repos "docker_media_plex"
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
        [string]$Account,

        #This parameter is the list of repositories that has been specified to be pulled.
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [array]$User_Repos
    )

    Begin
    {
        #Set TLS method to 1.2 from the default 1.0.
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #Gathering information about the GitHub account that we are going to use for the repo download
        do {
            $Account = Read-Host -Prompt 'Please enter the name of the GitHub Account.'
            if ($Account -eq $Null) {
                Write-Host 'No account name entered!'
            }
        } while ($Account -eq $Null)

        #We will pull all of the repos from the account since no specific repo was specified.  Accounting for pagination in case there are more than 30 repos in the Account.
        if ($User_Repos -eq $Null) {
            $page = 1
            do {
                $Repos_list = Invoke-RestMethod -Method GET -Uri "https://api.github.com/users/$Account/repos?page=$page&per_page=100"
                $repo_count = ($Repos_list | Measure-Object).Count
                if ($repo_count -ne 0) {
                    $Repos += $Repos_list
                    $page++
                }
                else {
                    Write-Host "Stepped through all available repositories." -ForegroundColor Red -BackgroundColor White
                }
            } while ($repo_count -ne 0)
            $Repos_count = ($Repos | Measure-Object).count
            if ($Repos_count -gt 0) {
                $continue = $true
                Write-Host "Found $Repos_count repositories in account $Account." -ForegroundColor Red -BackgroundColor White
            }
            else {
                $continue = $false
                Write-Host "Found $Repos_count in account $Account.  Ending program." -ForegroundColor Red -BackgroundColor White
            }
        }

        #Checking to make sure that the specified repo(s) exist in the GitHub account
        elseif ($User_Repos -ne $Null) {
            $Web_Repos = Invoke-RestMethod -Method GET -Uri "https://api.github.com/users/$Account/repos"
            foreach ($User_Repo in $User_Repos) {
                [array]$matched_repo = ($Web_Repos | Where-Object {($_.name -match "$User_Repo")})
                if ($matched_repo -eq $Null) {
                    Write-Host "Coudn't match $User_repo to the list of online repositories for $Account." -ForegroundColor Red -BackgroundColor White
                }
                else {
                    [array]$Repos += $matched_repo
                    Write-Host "Found matching repository $matched_repo for user entered repository $User_repo" -ForegroundColor Red -BackgroundColor White
                }
            }
            if ($matched_repo -eq $Null) {
                $continue = $false
                Write-Host "No matching repos found for entered list." -ForegroundColor Red -BackgroundColor White
            }
            else {
                $continue = $true
            }
        }
    }
    Process
    {
        if ($continue -eq $true) {
            #Getting list of existing directories that may or may not be git repos
            [array]$existing_repos = Get-ChildItem -Directory

            #Cloning all repos that are needed since no existing directories were found
            if ($existing_repos -eq $Null) {
                $count = 1
                foreach ($new_repo in $Repos) {
                    Write-Host "Creating new repository $($new_repo.name). Number $count of $(($Repos.name | Measure-Object).count)" -ForegroundColor Red -BackgroundColor White
                    git clone "$($new_repo.clone_url)"
                    $count++
                }
            }

            #Found existing directories that might be repos. 
            else {

                #Checking the name of the current potential repositories against the list of repos that we are trying to work with from the web.
                $comparison = Compare-Object -ReferenceObject $existing_repos.name -DifferenceObject $Repos.name

                #Storing new repositories in new variable
                $new_repos = ($comparison | Where-Object {($_.SideIndicator -match "=>")}).InputObject

                #Working on existing directories
                if ($existing_repos -ne $Null) {

                    #Finding total existing directories
                    $total_repos = ($existing_repos | Measure-Object).count
                    $number = 1
                    foreach ($existing_repo in $existing_repos) {
                        Set-location -Path .\$($existing_repo.name)

                        #Checking each directory to see if a .git folder exists (hidden or not)
                        if (($(Get-ChildItem -Hidden) -match ".git") -or ($(Get-ChildItem) -match ".git")) {
                            Write-Host "Working on repository $($existing_repo.name). Number $number of $total_repos" -ForegroundColor Red -BackgroundColor White

                            #get list of branches in repo
                            $local_branches = git branch
                            $online_branches = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/$Account/$existing_repo/branches"
                            
                            $status = git status
                            if ($status -match 'up') {
                                
                            }
                            git pull --all 
                            Set-Location ..
                            $number++   
                        }
                        else {
                            Write-Host "This is not a git repository" -ForegroundColor Red -BackgroundColor White
                            Set-Location ..
                        }
                    }
                }
                
                #Checking to see if there are any new repositories to be cloned into the directory
                if ($new_repos -ne $Null) {
                    $count =1
                    $total = ($new_repos | Measure-Object).count
                    foreach ($new_repo in $new_repos) {
                        $clone_repo = $Repos | Where-Object {($_.name -eq $new_repo)}
                        Write-Host "Working on new repository $($clone_repo.name).  Number $count of $total." -ForegroundColor Red -BackgroundColor White
                        git clone $clone_repo.clone_url
                        $count++
                    }
                }
            }            
        }
        else {
        }
    }
    End
    {
    }
}

#Execute cmdlet
GitHub-Clone