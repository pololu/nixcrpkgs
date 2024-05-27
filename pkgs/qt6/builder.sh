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

mkdir build
cd build

PKG_CONFIG=pkg-config-cross ../src/configure -prefix $out $configure_flags
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


if [ "$arch" == "i686" ]; then
  cat <<END >> $out/lib/cmake/Qt6Core/Qt6CoreAdditionalTargetInfo.cmake
target_compile_options(Qt6::Core INTERFACE -msse2)
END
fi
