source $setup

tar -xf $src
mv xcb-* src

mkdir build
cd build

PKG_CONFIG=pkg-config-cross \
../src/configure --prefix=$out $configure_flags

make

make install

sed -i 's/Requires.private/Requires/' $out/lib/pkgconfig/*.pc
ln -sf $libxcb/lib/pkgconfig/*.pc $out/lib/pkgconfig/
ln -sf $xcb_util_renderutil/lib/pkgconfig/*.pc $out/lib/pkgconfig/
ln -sf $xcb_util_image/lib/pkgconfig/*.pc $out/lib/pkgconfig/

