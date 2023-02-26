source $setup

cp -r $src src
chmod u+w -R src

mkdir build
cd build

$base/bin/qt-configure-module ../src -- -DCMAKE_INSTALL_PREFIX=$out

cmake --build .
cmake --install .
