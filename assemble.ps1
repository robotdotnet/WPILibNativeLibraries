param (
  [switch]$release = $false
)

If (Test-Path Env:APPVEYOR_REPO_TAG_NAME) {
  if (($env:APPVEYOR_REPO_TAG_NAME).Contains("-") -eq $false) {
     $release = $true
     echo "Tagged Release"
    }
    echo "Tag but not release"
}

$version = "2017.0.1"


If ($release) {
 $revision =  "-Pversion=`"{0}`"" -f $version
} Else {
 $revision = @{ $true = $env:APPVEYOR_BUILD_NUMBER; $false = 1 }[$env:APPVEYOR_BUILD_NUMBER -ne $NULL];
 $revision = "-Pversion=`"{1}-beta-{0:D4}`"" -f [convert]::ToInt32($revision, 10), $version
}

echo $revision

./gradlew build $revision

If (($env:APPVEYOR_REPO_BRANCH -eq "master") -and (!$env:APPVEYOR_PULL_REQUEST_NUMBER)) {
  if ($env:APPVEYOR) {
    Get-ChildItem .\build\distributions\*.nupkg | % { Push-AppveyorArtifact $_.FullName -FileName $_.Name }
  }
}
