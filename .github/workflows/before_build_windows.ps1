# Define the CastXML version
$castxml_version = "0.6.11"

# Download and extract CastXML source
Invoke-WebRequest -Uri "https://github.com/CastXML/CastXML/archive/refs/tags/v${castxml_version}.tar.gz" -OutFile "castxml.tar.gz"
tar -xzf "castxml.tar.gz"

# Install Clang (via LLVM) since it’s not pre-installed
choco install llvm --force --yes

# Define the expected path to llvm-config.exe
$llvm_config_path = "C:\Program Files\LLVM\bin\llvm-config.exe"

# Verify that llvm-config.exe exists
if (-not (Test-Path $llvm_config_path)) {
    Write-Error "llvm-config.exe not found at $llvm_config_path. Check LLVM installation."
    # Optional: List contents of the bin directory for debugging
    Write-Host "Contents of C:\Program Files\LLVM\bin:"
    Get-ChildItem "C:\Program Files\LLVM\bin" | ForEach-Object { Write-Host $_.Name }
    exit 1
} else {
    Write-Host "llvm-config.exe found at $llvm_config_path"
}

# Get LLVM CMake directory using the full path
$llvm_cmakedir = (& $llvm_config_path --cmakedir).Trim()
Write-Host "LLVM CMake directory: $llvm_cmakedir"

# Verify that LLVMConfig.cmake exists
$llvm_config_file = Join-Path $llvm_cmakedir "LLVMConfig.cmake"
if (-not (Test-Path $llvm_config_file)) {
    Write-Error "LLVMConfig.cmake not found in $llvm_cmakedir"
    exit 1
}

# Get Clang resource directory
$clang_exe = "C:\Program Files\LLVM\bin\clang.exe"
$clang_resource_dir = (& $clang_exe -print-resource-dir).Trim()
if (-not $clang_resource_dir) {
    Write-Error "Failed to determine Clang resource directory"
    exit 1
}

# Configure, build, and install CastXML
Set-Location -Path "CastXML-${castxml_version}"
New-Item -ItemType Directory -Path "build" -Force
Set-Location -Path "build"
cmake -G "Visual Studio 17 2022" -A x64 -DCLANG_RESOURCE_DIR="$clang_resource_dir" -DLLVM_DIR="$llvm_cmakedir" -DCMAKE_INSTALL_PREFIX="C:\castxml" ..
cmake --build . --config Release --target install

# Add CastXML to PATH for subsequent steps
echo "C:\castxml\bin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append