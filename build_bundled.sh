#!/bin/sh

VERSION="${1:-}"

BUILD_DIR=./build
INSTALL_DIR=./build/root

mkdir -p "${BUILD_DIR}"

if [ -f ./sentencepiece/src/CMakeLists.txt ]; then
  SRC_DIR=./sentencepiece
elif [ -f ./CMakeLists.txt ]; then
  SRC_DIR=.
else
  # Try tagged version. Otherwise, use head.
  if ! git clone https://github.com/joelvaneenwyk/sentencepiece.git -b v"${VERSION}" --depth 1; then
    git clone https://github.com/joelvaneenwyk/sentencepiece.git --depth 1
  fi
  SRC_DIR=./sentencepiece
fi

cmake -S "${SRC_DIR}" -B "${BUILD_DIR}" \
  -DSPM_ENABLE_SHARED=OFF \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}"
cmake --build "${BUILD_DIR}" \
  --config Release \
  --target install \
  --parallel
