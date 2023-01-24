source $stdenv/setup

unset CC CXX CFLAGS LDFLAGS LD AR AS RANLIB SIZE STRINGS NM STRIP OBJCOPY

tar -xf $src
mv binutils-* src

cd src
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done

# Clear the default library search path (noSysDirs)
echo 'NATIVE_LIB_DIRS=' >> ld/configure.tgt

cd ..

mkdir build
cd build

../src/configure --prefix=$out $configure_flags

make -j1

make -j1 install

