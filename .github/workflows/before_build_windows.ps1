# Define the CastXML version
$castxml_version = "0.6.11"

# Download and extract CastXML source
Invoke-WebRequest -Uri "https://github.com/CastXML/CastXML/archive/refs/tags/v${castxml_version}.tar.gz" -OutFile "castxml.tar.gz"
tar -xzf "castxml.tar.gz"

# Install Clang (via LLVM) since it’s not pre-installed
choco install llvm --yes
$env:Path += ";C:\Program Files\LLVM\bin"
$clang_resource_dir = (& "C:\Program Files\LLVM\bin\clang" -print-resource-dir).Trim()

# Find the directory containing LLVMConfig.cmake
$llvm_config_path = Get-ChildItem -Path "C:\Program Files\LLVM" -Recurse -Filter "LLVMConfig.cmake" | Select-Object -First 1 | Split-Path
if (-not $llvm_config_path) {
    Write-Error "Could not find LLVMConfig.cmake in C:\Program Files\LLVM"
    exit 1
}

# Configure, build, and install CastXML
Set-Location -Path "CastXML-${castxml_version}"
New-Item -ItemType Directory -Path "build" -Force
Set-Location -Path "build"
cmake -G "Visual Studio 17 2022" -A x64 -DCLANG_RESOURCE_DIR="$clang_resource_dir" -DLLVM_DIR="$llvm_config_path" -DCMAKE_INSTALL_PREFIX="C:\castxml" ..
cmake --build . --config Release --target install

# Add CastXML to PATH for subsequent steps
echo "C:\castxml\bin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append