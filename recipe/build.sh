#!/bin/bash
set -euxo pipefail

BUILD_DIR="${SRC_DIR}/build"
rm -rf "${BUILD_DIR}" || true
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# python-abi3 is only in host for the abi3 variants; free-threaded CPython makes
# Py_LIMITED_API a compile-time error, so the limited API must stay off there.
if [[ -n "${PY_LIMITED_API:-}" ]]; then
    LIMITED_API=ON
else
    LIMITED_API=OFF
fi

cmake ${CMAKE_ARGS} \
    -G Ninja \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON \
    -D SimpleITK_BUILD_STRIP:BOOL=ON \
    -D BUILD_SHARED_LIBS:BOOL=OFF \
    -D BUILD_TESTING:BOOL=OFF \
    -D SimpleITK_PYTHON_USE_VIRTUALENV:BOOL=OFF \
    -D SimpleITK_PYTHON_USE_LIMITED_API:BOOL=${LIMITED_API} \
    "${SRC_DIR}"/Wrapping/Python

cmake --build . --config Release
"${PYTHON}" -m pip install .
