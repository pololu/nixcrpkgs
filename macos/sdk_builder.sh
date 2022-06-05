source $setup

tar -xf $src
mv MacOSX*.sdk $out

cd $out

ruby -rjson \
  -e "print JSON.load(File.read('SDKSettings.json')).fetch('Version')" \
  > version.txt

# Make sure the STL headers are in the expected place.
if [ -d usr/include/c++/v1 ]; then
  mv usr/include/c++/v1/* usr/include/c++/
  rmdir usr/include/c++/v1
fi
ls usr/include/c++/iterator > /dev/null
