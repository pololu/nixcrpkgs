source $setup

cp --no-preserve=mode -r $src/usb/usbview .

cd usbview
rm usbschema.hpp xmlhelper.cpp
for patch in $patches; do
  echo applying patch $patch
  patch -p1 -i $patch
done
cp $my_xmlhelper_c .
cd ..

mkdir build
cd build

$host-windres ../usbview/uvcview.rc rc.o

# Note: --allow-multiple-definition is a hack that lets this program compile
# but it might cause bugs if different compilation units are using
# different definitions of the same variable.

$host-gcc -mwindows -std=gnu99 -O2 \
  -Wl,--allow-multiple-definition \
  -Iinclude \
  ../usbview/*.c rc.o \
  -lcomctl32 -lcomdlg32 -lsetupapi -lshell32 -lshlwapi -lole32 -lgdi32 \
  -o usbview.exe

mkdir -p $out/bin $out/license
cp usbview.exe $out/bin
cp $src/LICENSE $out/license
