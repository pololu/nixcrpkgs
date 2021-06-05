source $setup

tar -xf $src
mv mpc-* libmpc

mkdir build
cd build

../libmpc/configure --prefix=$out --host=$host --disable-shared \
  --with-gmp=$gmp --with-mpfr=$mpfr

make

make install
