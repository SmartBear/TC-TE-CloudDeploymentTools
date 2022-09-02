<#
.SYNOPSIS
    Run Tagged TestComplete Tests by passing Tags (e.g. from Zephyr Enterprise)
.DESCRIPTION
    We can invoke a single TestComplete instance to run a dynamic list of TestCases by
    passing in a a list of tags associated with Test Cases e.g. in Zephyr Enterprise. The tags must be 
    preceeded with the "@" symbol and the list must be separated by a space character
    e.g. "@TestCase01 @TestCase02 @TestCase03" . This can be passed automatically from Zephyr Enterprise
    via Vortex automations, using the ${TestName} or ${TestID} parameter, for example. 
    For each item passed, there needs to be a matching Tag on the Keyword Test or Script in the TestComplete project.
    The script can be run from a script location, and accesses the default Project Location for TestComplete i.e.
    ${HOME}\Documents\TestComplete 15 Projects . 
.PARAMETER Path
    The path to the .
.PARAMETER LiteralPath
    Specifies a path to one or more locations. Unlike Path, the value of 
    LiteralPath is used exactly as it is typed. No characters are interpreted 
    as wildcards. If the path includes escape characters, enclose it in single
    quotation marks. Single quotation marks tell Windows PowerShell not to 
    interpret any characters as escape sequences.
.EXAMPLE
    C:\PS> runTCTaggedTestcases.ps1 -projectName TestProject01 -LogDir C:\Logs -TagList "@TestCase1 @TestCase2"
.NOTES
    Author: Dermot Canniffe
    Date:   Jan 11, 2022    
#>

# Specify command line parameters of ProjectName, LogDir and TagList 
# Override the defaults below for more suitable values

param (
    [String]$projectName='RunningWithTags' #gives us Project name for invoking TestComplete, and locating the Project directory and file
    ,[String]$LogDir='C:\TestLogs' #pass in a Log location for Zbot, or other automation agent to access 
    ,[String]$taglist='@Test1' #a list of tags associated with Test Cases in Zephyr Enterprise, separated by a space character
    )

    function processTags {
        param(
            [Parameter()]
            [string] $inputList
        )
        # Modify this function if you need further processing of the tag values that are passed to the script
        $tagsArray = $inputList.Split(" ")
        $listOfTags = [String]::Join(' or ', $tagsArray)
        return $listOfTags    
    }

# Where are we running this script from? We'll need to return upon completion    
$currentDir = Get-Location
# Process the tag list to make a Tag Expression using Logical 'OR' 
$tags = processTags($taglist)
Write-Debug ('Running TestComplete for the following Tag Expression : ' + $tags)
# Set Default location for the TestComplete Binary
$testComplete = "C:\Program Files (x86)\SmartBear\TestComplete 15\x64\Bin\testcomplete.exe"
$projectFile = "${projectName}.pjs"
$date = get-date -f yyyyMMddHHmmss # We need to make unique log files or we'll get overwrite errors from TestComplete

Set-Location ${HOME}\Documents\"TestComplete 15 Projects"\${projectName}
#starts a process, waits for it to finish and then checks the exit code.
$p = Start-Process "$testComplete" -ArgumentList "${projectFile} /run /project:${projectName} /tags:${tags} /ExportLog:${LogDir}\${date}-ResultsLog /ExportSummary:${LogDir}\${date}-Results.xml /exit" -Verb RunAs 
$p.HasExited
$p.ExitCode

# Return to our starting location
Set-Location $currentDir
return $p.ExitCode
