source $setup

tar -xf $src
mv gmp-* gmp

mkdir build
cd build

../gmp/configure --prefix=$out --host=$host --disable-shared

make

make install
