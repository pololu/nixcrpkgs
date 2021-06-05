source $setup

mkdir -p $out/bin

cd $out/bin

CXXFLAGS="$CXXFLAGS -DWRAPPER_PATH=\\\"$out/bin:$clang/bin\\\""

eval "g++ $CXXFLAGS $src_file -o $host-wrapper"

ln -s $clang/bin/llvm-dsymutil dsymutil

ln -s $ld/bin/$host-ld

ln -s $misc/bin/$host-libtool
ln -s $misc/bin/lipo
ln -s $misc/bin/$host-nm
ln -s $misc/bin/$host-ranlib
ln -s $misc/bin/$host-size
ln -s $misc/bin/$host-strings
ln -s $misc/bin/$host-strip

ln -s $ar/bin/$host-ar

ln -s $host-wrapper $host-cc
ln -s $host-wrapper $host-c++

ln -s $host-wrapper $host-clang
ln -s $host-wrapper $host-clang++

ln -s $host-wrapper $host-gcc
ln -s $host-wrapper $host-g++
