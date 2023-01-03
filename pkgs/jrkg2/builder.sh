source $setup

tar -xf $src
mv pololu-jrk-g2-software-* src

mkdir build
cd build

cmake-cross ../src -DBUILD_SHARED_LIBS=false -DCMAKE_INSTALL_PREFIX=$out
make
make install
