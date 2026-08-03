#!/bin/bash
set -euxo pipefail

BUILD_DIR="${SRC_DIR}/build"
rm -rf "${BUILD_DIR}" || true
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# CMake's FindPython rejects the free-threaded "t" ABI by default (Python_FIND_ABI's
# gil_disabled flag defaults to OFF), leaving Development.Module not-found even
# though ${PYTHON} is valid; only free-threaded builds need these hints.
EXTRA_CMAKE_ARGS=()
IS_FREE_THREADED=$("${PYTHON}" -c "import sysconfig; print(bool(sysconfig.get_config_var('Py_GIL_DISABLED')))")
if [[ "${IS_FREE_THREADED}" == "True" ]]; then
    PYTHON_INCLUDE_DIR=$("${PYTHON}" -c "import sysconfig; print(sysconfig.get_path('include'))")
    EXTRA_CMAKE_ARGS=(
        -D "Python_EXECUTABLE:FILEPATH=${PYTHON}"
        -D "Python_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}"
        -D "Python_FIND_ABI:STRING=ANY;ANY;ANY;ANY"
    )
fi

cmake ${CMAKE_ARGS} \
    -G Ninja \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON \
    -D SimpleITK_BUILD_STRIP:BOOL=ON \
    -D BUILD_SHARED_LIBS:BOOL=OFF \
    -D BUILD_TESTING:BOOL=OFF \
    "${EXTRA_CMAKE_ARGS[@]+"${EXTRA_CMAKE_ARGS[@]}"}" \
    -D SimpleITK_PYTHON_USE_VIRTUALENV:BOOL=OFF \
    -D SimpleITK_PYTHON_USE_LIMITED_API:BOOL=OFF \
    "${SRC_DIR}"/Wrapping/Python

cmake --build . --config Release
"${PYTHON}" -m pip install .
