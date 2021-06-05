source $setup

tar -xf $src
mv mpfr-* mpfr

mkdir build
cd build

../mpfr/configure --prefix=$out --host=$host --disable-shared \
  --with-gmp=$gmp

make

make install
