source $setup

cp -r $src src
chmod u+w -R src

mkdir build
cd build

mkdir -p $out/lib/cmake/Qt6

$qt/bin/qt-cmake ../src -DCMAKE_INSTALL_PREFIX=$out
cmake --build .
cmake --install .

rmdir $out/lib/cmake/Qt6 || true
