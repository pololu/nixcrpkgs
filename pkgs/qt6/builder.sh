source $setup

tar -xf $src
mv qtbase-everywhere-src-* src
cd src
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd src/3rdparty
rm -r xcb
cd ../../..

mkdir build
cd build

PKG_CONFIG=pkg-config-cross ../src/configure -prefix $out $configure_flags
cmake --build . --parallel
cmake --install .

cd $out
for i in $cross_inputs; do
  if [ -d $i/lib/pkgconfig ]; then
    mkdir -p lib/pkgconfig
    ln -s $i/lib/pkgconfig/* lib/pkgconfig/
  fi
done
