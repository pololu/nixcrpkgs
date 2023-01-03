source $setup

tar -xf $src
mv pololu-usb-avr-programmer-v2-* src

mkdir build
cd build

cmake-cross ../src -DCMAKE_INSTALL_PREFIX=$out
make
make install
