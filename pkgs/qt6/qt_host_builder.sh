source $setup

tar -xf $src
mv qtbase-everywhere-src-* src
cd src
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd ..

mkdir build
cd build

set -x
../src/configure -prefix $out $configure_flags
cmake --build . --parallel --verbose
cmake --install .

cd $out/libexec
rpath=$rpath:$out/lib
patchelf --set-rpath $rpath cmake_automoc_parser moc qlalr qvkgen rcc tracegen uic

# Not sure if this helps
patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 cmake_automoc_parser moc qlalr qvkgen rcc tracegen uic

# Not sure if this helps
ln -s $zlib_out/lib/libz.so.1 .
