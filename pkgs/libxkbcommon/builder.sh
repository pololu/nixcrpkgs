source $setup

tar -xf $src
mv libxkbcommon-* src

mkdir build
cd build

meson-cross . ../src --prefix $out $configure_flags
ninja
ninja install
