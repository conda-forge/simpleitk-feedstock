#!/bin/bash
set -euxo pipefail

BUILD_DIR="${SRC_DIR}/build"

mkdir "${BUILD_DIR}"
cd "${BUILD_DIR}"

cmake ${CMAKE_ARGS} \
    -G Ninja \
    -D "CMAKE_CXX_FLAGS:STRING=-fvisibility=hidden -fvisibility-inlines-hidden ${CXXFLAGS}" \
    -D "CMAKE_C_FLAGS:STRING=-fvisibility=hidden ${CFLAGS}" \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON \
    -D SimpleITK_BUILD_STRIP:BOOL=ON \
    -D BUILD_SHARED_LIBS:BOOL=OFF \
    -D BUILD_TESTING:BOOL=OFF \
    -D SimpleITK_PYTHON_USE_VIRTUALENV:BOOL=OFF \
    "${SRC_DIR}"/Wrapping/Python

cmake --build . --config Release
${PYTHON} setup.py install
