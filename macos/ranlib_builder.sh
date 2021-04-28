source $setup

tar -xf $src
mv cctools-port-* cctools-port

cd cctools-port

for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done

# Similar to but not the same as the other _structs.h.
rm cctools/include/foreign/mach/i386/_structs.h

# Causes a troublesome undefined reference.
rm cctools/libstuff/vm_flush_cache.c

cd ..

mv cctools-port/cctools/misc .
mv cctools-port/cctools/include .
mv cctools-port/cctools/libstuff .
rm -r cctools-port

mkdir build
cd build

CFLAGS="-Wno-deprecated -Wno-deprecated-declarations -Wno-unused-result -Wno-format-overflow"
CFLAGS+=" -Wfatal-errors -O2 -g"
CFLAGS+=" -I../include -I../include/foreign"
CFLAGS+=" -DPROGRAM_PREFIX=\\\"$host-\\\""
CFLAGS+=" -DPACKAGE_NAME=\\\"cctools\\\" -DPACKAGE_VERSION=\\\"$apple_version\\\""
CFLAGS+=" -D__LITTLE_ENDIAN__ -D__private_extern__= -D__DARWIN_UNIX03"
CFLAGS+=" -DEMULATED_HOST_CPU_TYPE=16777223 -DEMULATED_HOST_CPU_SUBTYPE=3"
CFLAGS+=" -DHAVE_BCMP -DHAVE_BZERO -DHAVE_BCOPY -DHAVE_INDEX -DHAVE_RINDEX"

CXXFLAGS="-std=gnu++17 $CFLAGS"

LDFLAGS="-ldl"

for f in ../libstuff/*.c ; do
  echo "compiling $f"
  eval "gcc -c $CFLAGS $f -o $(basename $f).o"
done

eval "gcc $CFLAGS ../misc/libtool.c *.o $LDFLAGS -o $host-libtool"
eval "gcc $CFLAGS -DRANLIB ../misc/libtool.c *.o $LDFLAGS -o $host-ranlib"

mkdir -p $out/bin
cp $host-libtool $host-ranlib $out/bin/
