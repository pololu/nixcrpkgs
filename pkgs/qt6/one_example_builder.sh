source $setup

mkdir build
cd build

mkdir $out
cmake-cross $src -DCMAKE_INSTALL_PREFIX=$out
#  -DQT_DISABLE_NO_DEFAULT_PATH_IN_QT_PACKAGES=ON \
#  --trace 2> $out/log
exit 0
cmake --build .
cmake --install .
