source $setup
$qt/bin/qt-cmake $src -DCMAKE_INSTALL_PREFIX=$out #--debug-find-pkg=XCB
cmake --build .
cmake --install .
