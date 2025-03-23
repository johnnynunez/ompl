Param(
    [string]$CastxmlVersion = "v0.6.11.post2",
    [string]$CastxmlZip = "castxml-windows-2025-x86_64.zip"
)

$CastxmlUrl = "https://github.com/CastXML/CastXMLSuperbuild/releases/download/$CastxmlVersion/$CastxmlZip"

Write-Host "Downloading CastXML from $CastxmlUrl..."
Invoke-WebRequest -Uri $CastxmlUrl -OutFile $CastxmlZip

Write-Host "Unzipping CastXML..."
Expand-Archive -Path $CastxmlZip -DestinationPath "castxml" -Force

# Add castxml/bin to PATH in this process;
# cibuildwheel runs 'CIBW_BEFORE_BUILD_WINDOWS' in the same shell, so subsequent
# build commands will have 'castxml.exe' available.
$binPath = (Resolve-Path "castxml\bin").ToString()
Write-Host "Adding $binPath to PATH in this process..."
$Env:PATH = "$binPath;$($Env:PATH)"

Write-Host "CastXML installation complete. 'castxml.exe' is now on PATH."
