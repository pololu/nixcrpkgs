source $setup

tar -xf $src
mv mpc-* libmpc

mkdir build
cd build

../libmpc/configure --prefix=$out $configure_flags

make

make install
