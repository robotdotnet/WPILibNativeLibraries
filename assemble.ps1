param (
  [switch]$release = $false,
  [switch]$beta = $false
)

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


echo $version
echo $type
echo $buildNumber

./gradlew build -PbuildVersion="$version" -PbuildType="$type" -PbuildNumber="$buildNumber"

If (($env:APPVEYOR_REPO_BRANCH -eq "master") -and (!$env:APPVEYOR_PULL_REQUEST_NUMBER)) {
  if ($env:APPVEYOR) {
    Get-ChildItem .\build\distributions\*.nupkg | % { Push-AppveyorArtifact $_.FullName -FileName $_.Name }
  }
}
