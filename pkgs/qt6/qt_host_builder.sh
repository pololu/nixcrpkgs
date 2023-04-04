source $setup

cp -r $src src
chmod u+w -R src
cd src
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cd ..

mkdir build
cd build

../src/configure -prefix $out $configure_flags
cmake --build . --parallel --verbose
cmake --install .

cd $out
rpath=$rpath:$out/lib
patchelf --set-rpath $rpath --set-interpreter $glibc/lib/ld-linux-x86-64.so.2 \
  libexec/{cmake_automoc_parser,moc,qlalr,qvkgen,rcc,tracegen,uic}
patchelf --set-rpath $rpath lib/*.so
