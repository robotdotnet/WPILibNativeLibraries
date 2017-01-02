
if ($env:APPVEYOR) {
    $localFolder = "$env:APPVEYOR_BUILD_FOLDER\temp"
} else {
    $localFolder = ".\temp"
}

# Create temp directory to store stuff in
if ((Test-Path $localFolder) -eq $false) {
  md $localFolder
}

$compilerName = "compiler"

echo "Downloading Compiler"
(New-Object System.Net.WebClient).DownloadFile("http://first.wpi.edu/FRC/roborio/toolchains/FRC-2017-Windows-Toolchain-4.9.3.zip", "$localFolder\$compilerName.zip")

# unzip everything
Add-Type -assembly "system.io.compression.filesystem"

function Unzip($file)
{
  [io.compression.zipfile]::ExtractToDirectory("$localFolder\$file.zip", "$localFolder\$file")
}

echo "Extracting Compiler"
Unzip($compilerName)

echo "Adding compiler to path"
$env:Path += ";$localFolder\compiler\frc\bin"