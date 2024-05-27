source $setup
cmake-cross $src -DCMAKE_INSTALL_PREFIX=$out
cmake --build .
cmake --install .
