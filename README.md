# powershell_github_clone
## Description
This powershell function's main purpose is to keep a local directory updated with all of an accounts repositories.  It has some built in saftey features:

* Clones all new repositories at the same level as any existing repository
* Checks existing directories to make sure they are git repositories
* Runs git pull --all on any existing repositories

It gathers the repositories by connecting to the github api to fetch a current listing of all repositories.

## Usage
The .ps1 file is not self executing.  You will have to add 'GitHub-Clone' to the end of the file if you would like it to execute without any other commands.  otherwise you can run:

* powershell "github-clone.ps1"

The ps1 file can also be added to your user powershell file so that the cmdlet is always available.

## Dependencies

* Powershell 3.0 or greater
* Git tools
* Internet Connection