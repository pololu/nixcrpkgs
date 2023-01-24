source $setup

tar -xf $src
mv qtbase-everywhere-src-* src

examples="
qpa/qrasterwindow
qpa/windows
network/http
qtconcurrent/imagescaling
widgets/mainwindows/mainwindow
widgets/itemviews/chart
widgets/tools/regularexpression
widgets/painting/composition
widgets/effects/blurpicker
widgets/dialogs/findfiles
widgets/widgets/elidedlabel
widgets/layouts/dynamiclayouts
corelib/threads/mandelbrot
"

mkdir build
cd build
for example in $examples
do
  cmake-cross ../src/examples/$example -DCMAKE_INSTALL_PREFIX=$out
  cmake --build .
  cmake --install .
  rm -r ../build/*
done

$host-strip $(find $out -type f -executable)
