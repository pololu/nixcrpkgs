source $setup

#mkdir -p $out
#pushd $out
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
#popd

mkdir build
cd build

set -x
PKG_CONFIG=pkg-config-cross \
../src/configure -prefix $out $configure_flags

#PKG_CONFIG=pkg-config-cross \
#cmake-cross \
#  -G Ninja \
#  -DBUILD_SHARED_LIBS=OFF \
#  -DCMAKE_INSTALL_PREFIX=$out \
#  -DQT_QMAKE_TARGET_MKSPEC=win32-g++ \
#  -DCMAKE_BUILD_TYPE=Release \
#  -DQT_QMAKE_DEVICE_OPTIONS=CROSS_COMPILE=i686-w64-mingw32- \
#  ../src

# Qt 5.12.4 finds our X libraries but Qt 5.12.12 needs help.
#if [ -n "$libxall" ]; then
#  mkdir include
#  ln -s $libxall/include/xcb include/
#fi

cmake --build .
cmake --install .


