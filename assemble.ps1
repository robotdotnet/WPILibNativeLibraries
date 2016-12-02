param (
  [switch]$release = $false,
  [switch]$beta = $false
)

If (Test-Path Env:APPVEYOR_REPO_TAG_NAME) {
  $version = ($env:APPVEYOR_REPO_TAG_NAME).Substring(1)
  if (($env:APPVEYOR_REPO_TAG_NAME).Contains("-") -eq $false) {
    #Building a Full Release
     $release = $true
     echo "Tagged Release"
    } Else {
      #Building a Beta
      $beta = $true
      echo "Tag but not release"
    }
} Else {
  $version = "2017.0.0-CI-"
}


If ($release -Or $beta) {
 $revision =  "-Pversion=`"{0}`"" -f $version
} Else {
 $revision = @{ $true = $env:APPVEYOR_BUILD_NUMBER; $false = 1 }[$env:APPVEYOR_BUILD_NUMBER -ne $NULL];
 $revision = "-Pversion=`"{1}{0:D4}`"" -f [convert]::ToInt32($revision, 10), $version
}

echo $revision

./gradlew build $revision

If (($env:APPVEYOR_REPO_BRANCH -eq "master") -and (!$env:APPVEYOR_PULL_REQUEST_NUMBER)) {
  if ($env:APPVEYOR) {
    Get-ChildItem .\build\distributions\*.nupkg | % { Push-AppveyorArtifact $_.FullName -FileName $_.Name }
  }
}
