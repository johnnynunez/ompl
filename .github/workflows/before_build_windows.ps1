# Define the CastXML version
$castxml_version = "0.6.11"

# Download and extract CastXML source
Invoke-WebRequest -Uri "https://github.com/CastXML/CastXML/archive/refs/tags/v${castxml_version}.tar.gz" -OutFile "castxml.tar.gz"
tar -xzf "castxml.tar.gz"

# Install Clang (via LLVM) since it’s not pre-installed
choco install llvm --force --yes
$env:Path += ";C:\Program Files\LLVM\bin"  # Ensure clang and llvm-config are in PATH

# Get Clang resource directory
$clang_resource_dir = (& "clang" -print-resource-dir).Trim()
if (-not $clang_resource_dir) {
    Write-Error "Failed to determine Clang resource directory"
    exit 1
}

# Try to get LLVM CMake directory from llvm-config
$llvm_cmakedir = (& "llvm-config" --cmakedir).Trim()
Write-Host "LLVM CMake directory: $llvm_cmakedir"
if ($llvm_cmakedir -and (Test-Path "$llvm_cmakedir\LLVMConfig.cmake")) {
    $llvm_dir = $llvm_cmakedir
} else {
    # Fallback: search for LLVMConfig.cmake
    $llvm_config_file = Get-ChildItem -Path "C:\Program Files\LLVM" -Recurse -Filter "LLVMConfig.cmake" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($llvm_config_file) {
        $llvm_dir = $llvm_config_file.DirectoryName
    } else {
        Write-Error "Could not find LLVMConfig.cmake"
        exit 1
    }
}

# Configure, build, and install CastXML
Set-Location -Path "CastXML-${castxml_version}"
New-Item -ItemType Directory -Path "build" -Force
Set-Location -Path "build"
cmake -G "Visual Studio 17 2022" -A x64 -DCLANG_RESOURCE_DIR="$clang_resource_dir" -DLLVM_DIR="$llvm_dir" -DCMAKE_INSTALL_PREFIX="C:\castxml" ..
cmake --build . --config Release --target install

# Add CastXML to PATH for subsequent steps
echo "C:\castxml\bin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append