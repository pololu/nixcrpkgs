source $setup

cp -r --no-preserve=mode $src src

mkdir build
cd build

$base/bin/qt-configure-module ../src -- -DCMAKE_INSTALL_PREFIX=$out

cmake --build .
cmake --install .
