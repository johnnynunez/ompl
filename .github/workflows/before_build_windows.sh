#!/usr/bin/env bash

# Dependency versions.
castxml_version="0.6.11"

curl -L "https://github.com/CastXML/CastXML/archive/refs/tags/v${castxml_version}.tar.gz" | tar xz

clang_resource_dir=$(clang -print-resource-dir)

pushd "CastXML-${castxml_version}"
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCLANG_RESOURCE_DIR="${clang_resource_dir}" ..
cmake --build .
make install
popd