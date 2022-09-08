source $setup

mkdir -p $out
pushd $out
tar -xf $src
mv qtbase-everywhere-src-* src
cd src
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd src/3rdparty
rm -r angle xcb
popd

mkdir build
cd build

PKG_CONFIG=pkg-config-cross \
$out/src/configure -prefix $out $configure_flags

# Qt 5.12.4 finds our X libraries but Qt 5.12.12 needs help.
if [ -n "$libxall" ]; then
  mkdir include
  ln -s $libxall/include/xcb include/
fi

# -j1 makes it much easier to see which error stopped the build.
make -j1

make install

