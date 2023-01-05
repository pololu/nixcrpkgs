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
patchelf --set-rpath $gcc_lib/lib:$glibc/lib:$pcre2_out/lib moc
# patchelf --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 moc
