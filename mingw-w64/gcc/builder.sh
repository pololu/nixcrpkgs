source $setup

tar -xf $src
mv gcc-* src

cd src
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd ..

mkdir build
cd build

../src/configure --prefix=$out $configure_flags

make $make_flags

make $install_targets

# Remove "install-tools" so we don't have a reference to bash.
rm -r "$out/libexec/gcc/$target/$version/install-tools/"
