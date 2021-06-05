source $setup

tar -xf $src
mv mpfr-* mpfr

mkdir build
cd build

../mpfr/configure --prefix=$out $configure_flags

make

make install
