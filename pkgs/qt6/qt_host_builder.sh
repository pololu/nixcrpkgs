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
cmake --build . --parallel
cmake --install .
