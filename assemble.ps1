If (Test-Path Env:APPVEYOR_REPO_TAG_NAME) {
  $version = ($env:APPVEYOR_REPO_TAG_NAME).Substring(1)  
  if (($env:APPVEYOR_REPO_TAG_NAME).Contains("-") -eq $false) {
    #Building a Full Release
     $type = ""
     $buildNumber = ""
     echo "Tagged Release"
    } Else {
      #Building a Beta
      $version = ($version).Substring(0, (($env:APPVEYOR_REPO_TAG_NAME).IndexOf("-") - 1))
      $type = ($env:APPVEYOR_REPO_TAG_NAME).Substring((($env:APPVEYOR_REPO_TAG_NAME).IndexOf("-")))
      $buildNumber = ""
      echo "Tag but not release"
    }
} Else {
  $version = "2017.0.0"
  $type = "-ci-"
  $buildNumber = @{ $true = $env:APPVEYOR_BUILD_NUMBER; $false = 1 }[$env:APPVEYOR_BUILD_NUMBER -ne $NULL];
  $buildNumber = "{0:D4}" -f [convert]::ToInt32($buildNumber, 10), $buildNumber
}

# Taken from psake https://github.com/psake/psake

<#  
.SYNOPSIS
  This is a helper function that runs a scriptblock and checks the PS variable $lastexitcode
  to see if an error occcured. If an error is detected then an exception is thrown.
  This function allows you to run command-line programs without having to
  explicitly check the $lastexitcode variable.
.EXAMPLE
  exec { svn info $repository_trunk } "Error executing SVN. Please verify SVN command-line client is installed"
#>
function Exec  
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][scriptblock]$cmd,
        [Parameter(Position=1,Mandatory=0)][string]$errorMessage = ($msgs.error_bad_command -f $cmd)
    )
    & $cmd
    if ($lastexitcode -ne 0) {
        throw ("Exec: " + $errorMessage)
    }
}


echo "Building OpenCv Extern Library"
if ($env:APPVEYOR) {
    $localFolder = "$env:APPVEYOR_BUILD_FOLDER\temp"
} else {
    $localFolder = ".\temp"
}

./downloadCompiler.ps1

echo "Cloning FRC-OpenCvSharp repo"
git clone -q --branch=master https://github.com/robotdotnet/FRC-OpenCvSharp.git "$localFolder\cvsharp"

$startLocation = Get-Location

Set-Location "$localFolder\cvsharp"

$cvBuild = "$localFolder\cvsharp\gradlew.bat" 

./gradlew :arm:build

Set-Location $startLocation

if($LastExitCode -ne 0) { $host.SetShouldExit($LastExitCode )  }

echo $version
echo $type
echo $buildNumber

./gradlew build -PbuildVersion="$version" -PbuildType="$type" -PbuildNumber="$buildNumber"

If (($env:APPVEYOR_REPO_BRANCH -eq "master") -and (!$env:APPVEYOR_PULL_REQUEST_NUMBER)) {
  if ($env:APPVEYOR) {
    Get-ChildItem .\build\distributions\*.nupkg | % { Push-AppveyorArtifact $_.FullName -FileName $_.Name }
  }
}
