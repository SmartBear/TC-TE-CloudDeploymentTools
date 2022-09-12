<#
.SYNOPSIS
    Perform Auto Configuration of SLM Auth file for TestLeft or TestExecute 
.DESCRIPTION
    In the event that a customer wishes to spin up a new instance of 
    TestLeft or TestExecute as and when needed, it is 
    necessary with the new SLM to ensure that the smartbear.auth file is placed
    in the correct folder for each user and instance. 
    The repository that contains this script can be used as an example 
    for setting up an internal repo with the correct smartbear.auth file 
    and latest TestLeft installer . 
.PARAMETER GitRepo
    Git Repo where the Smartbear.auth file will be made available
.PARAMETER userEmail
    email address for Git
.PARAMETER userName
    user name for Git  
.EXAMPLE
    C:\PS> TE_SLM_CloudVMDeployment.ps1 -GitRepo http://git.server/repo -userEmail email@email.com -userName "User Name"
.NOTES
    Author: Dermot Canniffe
    Date:   Sep 12, 2022    
#>

# Specify command line parameters 
# Override the defaults below for more suitable values

param (
    [String]$GitRepo='https://github.com/SmartBear/TC-TE-CloudDeploymentTools' # GitRepo for auth file
    ,[String]$UserName='userName' # username for configuring Git
    ,[String]$userEmail='user@email.com' # user email for configuring Git
    )

    function setupEnv {
        Set-ExecutionPolicy Bypass -Force;
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
        choco install git -y;
        git config --global user.name $UserName;
        git config --global user.email $UserEmail;
        choco install awscli -y;
        #choco install visualstudio2019community -y;
        #choco install GoogleChrome -y
        #Write-Output "at time of writing, TestLeft supports up to IntelliJ IDEA 2017. If brought up to date, you can add a semi-colon to the previous line and uncomment the following choco install command, or else run manually:"
        #Write-Output "choco install intellijidea-community -y"
        refreshenv

    }

# Where are we running this script from? We'll need to return upon completion    
$currentDir = Get-Location
$currentUser = Get-LocalUser
$destinationPath = "C:\Users\${currentUser}\"
$testLeftInstaller = "TestLeft_T499401992907.exe" # Set to whatever is the correct installer
$setup = "False" # we don't always need to setup a fresh environment

Write-Debug ('Setting up the environment for ' + $currentUser)
if ( $setup == "True" ) {
    setupEnv
}
Write-Debug ('Placing smartbear.auth file for ' + $currentUser)
# Pull files from the TL repo 
# I'm using * wildcards here but you can put the correct path in the 
# Copy-Item statements below 
Set-Location ".."
git clone $GitRepo
Copy-Item */smartbear.auth $destinationPath
Copy-Item */${testLeftInstaller} .\

Write-Debug ('Running Installer : ' + $testLeftInstaller)
$p = Start-Process "$testLeftInstaller" -ArgumentList "-SilentInstall" -Verb RunAs 
$p.HasExited
$p.ExitCode

# Return to our starting location
Set-Location $currentDir
return $p.ExitCode


