if [ -z ${CONDA_BUILD+x} ]; then
    source /Users/jrodriguez/.local/anaconda/conda-bld/simpleitk_1664738747721/work/build_env_setup.sh
fi
#!/bin/bash
set -euxo pipefail

BUILD_DIR="${SRC_DIR}/build"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

if [[ $CONDA_BUILD_CROSS_COMPILATION == "1" && $target_platform == "osx-arm64" ]]; then
  # workarounds for https://github.com/conda-forge/simpleitk-feedstock/pull/27#issuecomment-1264707645
  # refs: 
  # - https://github.com/scikit-build/scikit-build/issues/589
  # - https://github.com/conda-forge/slycot-feedstock/issues/34
  export CMAKE_OSX_ARCHITECTURES="arm64"
  rm -rf $PREFIX/lib/libpython${PY_VER}.dylib
  ln -sf $PREFIX/lib/libc++.dylib $PREFIX/lib/libpython${PY_VER}.dylib
fi

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
"${PYTHON}" setup.py install
