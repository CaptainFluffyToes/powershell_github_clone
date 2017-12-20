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
            if ($Account == $Null) {
                Write-Host 'No account name entered!'
            }
        } while ($Account == $Null)
        if ($Repos == $Null) {
            [array]$Repos = @(
                "chef_roles",
                "chef_jenkins_configuration",
                "chef_conjur_configuration",
                "chef_base_configuration",
                "chef_plex_configuration",
                "chef_media_configuration",
                "chef_docker_configuration"
            )            
        }
        foreach ($Repo in $Repos) {
            [array]$URL =+ "https://github.com/$Account/$Repo.git"
        }
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
        }
    }
    End
    {
    }
}