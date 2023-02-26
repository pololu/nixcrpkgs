source $setup

cp -r $src src
chmod u+w -R src

mkdir build
cd build

cmake-cross ../src -DCMAKE_INSTALL_PREFIX=$out

cmake --build .
cmake --install .
