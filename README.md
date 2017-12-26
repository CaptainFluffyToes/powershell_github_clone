# powershell_github_clone
## Description
This powershell function's main purpose is to keep a local directory updated with all of an accounts repositories.  It has some built in saftey features:

* Clones all new repositories at the same level as any existing repository.
* Checks existing directories to make sure they are git repositories.
* Runs git pull --all on any existing repositories.
* Verifies than any passed through repository exists before attempting to clone/fetch changes.
* Will terminate if the entered repository names do not match with any of the online names.
* Handles accounts with more than 30 repos.
* Terminates if there are no repos present in the named account.

It gathers the repositories by connecting to the github api to fetch a current listing of all repositories.

## Usage
The .ps1 file is self executing.  Drop the file into the directory that you would like to use for your GitHub repositories.  Then execute the .ps1 file from a powershell prompt.

## Dependencies

* Powershell 3.0 or greater
* Git tools
* Internet Connection
* GitHub Account