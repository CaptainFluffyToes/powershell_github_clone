<#
.Synopsis
   This cmdlet will clone an entire github account into the local machine
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   The input of this cmdlet is the 
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
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
        # This parameter is the location of the repos that are going to be used.
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [string]$Account,

        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true, 
        ValueFromRemainingArguments=$false, 
        Position=1)]
        [array]$Repos
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
            [array]$Repos = @(
                "chef_roles",
                "chef_jenkins_configuration",
                "chef_conjur_configuration",
                "chef_base_configuration",
                "chef_plex_configuration",
                "chef_media_configuration",
                "chef_docker_configuration",
                "bash_chefclient",
                "docker_media_nzbget",
                "docker_media_plexpy",
                "docker_media_couchpotato",
                "docker_media_sabnzbd",
                "docker_media_sonarr",
                "docker_media_plex",
                "docker_admin_jenkins",
                "conjur_admin_policy",
                "powershell_github_clone",
                "docker_network_unifi",
                "powershell_iits",
                "demo_conjur_jenkins",
                "demo_aim_jenkins",
                "VMwareBackup"
            )            
        }
    }
    Process
    {
        [array]$existing_dir = Get-ChildItem
        if ($existing_dir -eq $Null) {
            foreach ($new_repo in $Repos) {
                git clone "https://github.com/$Account/$new_repo.git"
            }
        }
        else {
            $comparison = Compare-Object -ReferenceObject $existing_dir.name -DifferenceObject $Repos -IncludeEqual
            $existing_repos = $($comparison | Where-Object {($_.SideIndicator -match "==")}).InputObject
            if ($existing_repos -eq $Null) {
                Write-Verbose -Message 'No existing repositories' 
            }
            else {
                $total_repos = ($existing_repos | Measure-Object).count
                $number = 1
                foreach ($existing_repo in $existing_repos) {
                    Set-location -Path .\$existing_repo
                    Write-Host "Working on repository $existing_repo. Number $number of $total_repos" -foregroundcolor Red
                    git pull --all 
                    Set-Location ..
                    $number++
                }
            }
        }
    }
    End
    {
    }
}