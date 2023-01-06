{ crossenv }:

if crossenv.os != "windows" then "windows only" else

# TODO: Why is this version not showing USB descriptors, while the
# older version from MSYS2 (commit c4ba9c6) is?  Maybe because we
# used that weird linker option?

crossenv.make_derivation rec {
  name = "usbview-${version}";

  version = "2019-01-24";

  src = crossenv.nixpkgs.fetchFromGitHub {
    owner = "Microsoft";
    repo = "Windows-driver-samples";
    rev = "39d39e7485faddf601d51c897863ff2f876e391e";
    sha256 = "0nyw3wzlh68zxpb0ydzkgpf5c83scapfp6zsc5gahxlcgrhy3xwj";
  };

  patches = [ ./megapatch.patch ];

  my_xmlhelper_c = ./my_xmlhelper.c;

  builder = ./builder.sh;
}
