source $setup

mkdir build
cd build
for example in $examples; do
  cmake-cross $example -DCMAKE_INSTALL_PREFIX=../staging
  cmake --build .
  cmake --install .
  rm -r ../build/*
done

mkdir -p $out/bin
cp -r $(find ../staging -name \*.app -prune -o -type f -executable) $out/bin/
$host-strip $(find $out/bin -type f -executable)

if [ -n "$font" ]; then
  cp $font $out/bin/
fi
