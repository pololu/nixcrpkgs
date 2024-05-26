source $setup

cp -r $src src
chmod u+w -R src
cd src
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd src/3rdparty
rm -r xcb
cd ../../..

# Create our own toolchain file so we can add important compiler flags.
mkdir -p $out/lib/cmake
cmake_toolchain=$out/lib/cmake/toolchain.txt
cp --no-preserve=mode $cmake_toolchain_from_env $cmake_toolchain
if [ "$arch" == "i686" ]; then
  cat <<END >> $cmake_toolchain
set(CMAKE_C_FLAGS "-msse2")
set(CMAKE_CXX_FLAGS "-msse2")
END
fi

mkdir build
cd build

PKG_CONFIG=pkg-config-cross ../src/configure -prefix $out $configure_flags \
  -DCMAKE_TOOLCHAIN_FILE=$cmake_toolchain
cmake --build . --parallel
cmake --install .

mkdir -p $out/lib/pkgconfig
cd $out
for i in $cross_inputs; do
  if [ -d $i/lib/pkgconfig ]; then
    for pc in $i/lib/pkgconfig/*; do
      ln -sf $(realpath $pc) lib/pkgconfig/
    done
  fi
done

# Replace qt-cmake with a better version.
mv $out/bin/qt-cmake{,-orig}
cat <<END > $out/bin/qt-cmake
#!$(which bash)
PKG_CONFIG=$(which pkg-config-cross) \\
CMAKE_PREFIX_PATH=\$CMAKE_CROSS_PREFIX_PATH \\
exec $(which cmake) -DCMAKE_TOOLCHAIN_FILE=$out/lib/cmake/Qt6/qt.toolchain.cmake "\$@"
END
chmod a+x $out/bin/qt-cmake
