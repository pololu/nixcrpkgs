source $setup

mkdir -p $out
tar -C $out --strip-components 1 -xf $src

xmlstarlet sel -t -v "/plist/dict/key[.='Version']/following-sibling::string[1]" "${out}/SDKSettings.plist" > $out/version.txt
