source $setup

tar -xf $src
mv gmp-* gmp

mkdir build
cd build

../gmp/configure --prefix=$out $configure_flags

make

make install
