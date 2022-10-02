if [ -z ${CONDA_BUILD+x} ]; then
    source /Users/jrodriguez/.local/anaconda/conda-bld/simpleitk_1664738747721/work/build_env_setup.sh
fi
#!/bin/bash
set -euxo pipefail

BUILD_DIR="${SRC_DIR}/build"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

OUR_CMAKE_ARGS=""
OUR_CMAKE_ARGS+="-D CMAKE_BUILD_TYPE:STRING=Release "
OUR_CMAKE_ARGS+="-D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON "
OUR_CMAKE_ARGS+="-D SimpleITK_BUILD_STRIP:BOOL=ON "
OUR_CMAKE_ARGS+="-D BUILD_SHARED_LIBS:BOOL=OFF "
OUR_CMAKE_ARGS+="-D BUILD_TESTING:BOOL=OFF "
OUR_CMAKE_ARGS+="-D SimpleITK_PYTHON_USE_VIRTUALENV:BOOL=OFF "
# if [[ ${CONDA_BUILD_CROSS_COMPILATION:-} == "1" ]]; then
#   OUR_CMAKE_ARGS+="-D SITK_UNDEFINED_SYMBOLS_ALLOWED:BOOL=ON"
# fi

cmake \
    ${CMAKE_ARGS} \
    ${OUR_CMAKE_ARGS} \
    -G Ninja \
    "${SRC_DIR}"/Wrapping/Python

cmake --build . --config Release
"${PYTHON}" setup.py install
