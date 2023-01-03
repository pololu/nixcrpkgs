{ native, arch, stage ? 2, binutils, libc }:

let
  nixpkgs = native.nixpkgs;
  isl = nixpkgs.isl;
  inherit (nixpkgs) stdenv lib fetchurl;
  inherit (nixpkgs) gettext gmp libmpc libelf mpfr texinfo which zlib;

  stageName = if stage == 1 then "-stage1"
              else assert stage == 2; "";
in

native.make_derivation rec {
  name = "gcc-${version}-${target}${stageName}";

  target = "${arch}-w64-mingw32";

  version = "12.2.0";  # 2022-08-19

  src = fetchurl {
    url = "mirror://gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
    hash = "sha256-5UnPnPNZSgDie2WJ1DItcOByDN0hPzm+tBgeBpJiMP8=";
  };

  builder = ./builder.sh;

  patches = [
    # NATIVE_SYSTEM_HEADER_DIR:  The GCC configuration files for MinGW throw
    # away our --with-native-system-header-dir argument because of POSIX path
    # conversion issues when the host system is Windows:
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=52947
    # However this workaround causes problems for us because our include files
    # are not inside a "mingw" directory.  It also causes problems in MSYS2
    # (see the sed command in the PKGBUILD).  I believe there should be a better
    # solution possible in GCC but it's hard to know all the requirements.
    #
    # STANDARD_STARTFILE_PREFIX: I haven't looked into this one as much but it
    # causes important system libraries to not be found, breaking the build
    # of libstdc++-v3.
    ./mingw-search-paths.patch
  ];

  native_inputs = [
    binutils texinfo gettext which
  ];

  configure_flags =
    "--target=${arch}-w64-mingw32 " +
    "--with-sysroot=${libc} " +
    "--with-native-system-header-dir=/include " +
    "--with-gnu-as " +
    "--with-gnu-ld " +
    "--with-as=${binutils}/bin/${arch}-w64-mingw32-as " +
    "--with-ld=${binutils}/bin/${arch}-w64-mingw32-ld " +
    "--with-isl=${isl} " +
    "--with-gmp-include=${gmp.dev}/include " +
    "--with-gmp-lib=${gmp.out}/lib " +
    "--with-mpfr-include=${mpfr.dev}/include " +
    "--with-mpfr-lib=${mpfr.out}/lib " +
    "--with-mpc=${libmpc} " +
    "--with-zlib-include=${zlib.dev}/include " +
    "--with-zlib-lib=${zlib.out}/lib " +
    "--enable-lto " +
    "--enable-plugin " +
    "--enable-static " +
    "--enable-sjlj-exceptions " +
    "--enable-__cxa_atexit " +
    "--enable-long-long " +
    "--with-dwarf2 " +
    "--enable-fully-dynamic-string " +
    (if stage == 1 then
      "--enable-languages=c " +
      "--enable-threads=win32 "
    else
      "--enable-languages=c,c++ " +
      "--enable-threads=posix "
    ) +
    "--without-included-gettext " +
    "--disable-libstdcxx-pch " +
    "--disable-nls " +
    "--disable-shared " +
    "--disable-multilib " +
    "--disable-libssp " +
    "--disable-win32-registry " +
    "--disable-bootstrap";

  make_flags =
    if stage == 1 then
      ["all-gcc" "all-target-libgcc"]
    else
      [];

  install_targets =
    if stage == 1 then
      ["install-gcc install-target-libgcc"]
    else
      ["install-strip"];

  hardeningDisable = [ "format" ];
}

# TODO: why is GCC providing a fixed limits.h?
