{ native, host, binutils, headers, gcc_options }:

let
  nixpkgs = native.nixpkgs;
  isl = nixpkgs.isl;
  inherit (nixpkgs) stdenv lib fetchurl;
  inherit (nixpkgs) gmp libmpc libelf mpfr zlib;
in

native.make_derivation rec {
  name = "gcc-${version}-${host}";

  version = "14.1.0";
  src = fetchurl {
    url = "mirror://gnu/gcc/gcc-${version}/gcc-${version}.tar.xz";
    hash = "sha256-4oPGVJh6/j3p2AgLwL15U0tcoNaBpzoR/ytdN2dCaEA=";
  };

  musl_version = "1.2.5";
  musl_src = nixpkgs.fetchurl {
    url = "https://www.musl-libc.org/releases/musl-${musl_version}.tar.gz";
    hash = "sha256-qaEYu+hNh2TaDqDSizqz+uhHf8fkCF2QECuFlvx8deQ=";
  };

  inherit host headers;

  builder = ./builder.sh;

  patches = [
    # This patch is from nixpkgs.
    ./libstdc++-target.patch

    # This patch fixes the linker argument sequence for libcc and libc.
    # libgcc and libc depend on eachother, so GCC should almost always link
    # them into your program by passing these arguments to the linker:
    #     --start-group -lgcc -lc --end-group
    # However, someone trying to be overly clever decided that they could
    # make their toolchain slightly faster by linking them like this:
    #     -lgcc -lc -lgcc
    # They assumed that if '-static' is not passed to GCC, then GCC will be
    # linking against shared objects for libgcc and libc, and the sequence above
    # would be OK.  That is NOT true for us because we only want to only provide
    # static libraries for those things, so those static libraries are used
    # whether the user passes '-static' or not.
    # This bad assumption in GCC causes the build to fail with a cryptic error:
    # "Link tests are not allowed after GCC_NO_EXECUTABLES." during the
    # target "configure-target-libstdc++-v3", which is built by
    # the command "make -C build_gcc".
    ./link_gcc_c_sequence_spec.patch
  ];

  native_inputs = [ binutils ];

  gcc_conf =
    "--target=${host} " +
    gcc_options +
    "--with-gnu-as " +
    "--with-gnu-ld " +
    "--with-as=${binutils}/bin/${host}-as " +
    "--with-ld=${binutils}/bin/${host}-ld " +
    "--with-isl=${isl} " +
    "--with-gmp-include=${gmp.dev}/include " +
    "--with-gmp-lib=${gmp.out}/lib " +
    "--with-libelf=${libelf}" +
    "--with-mpfr=${mpfr.dev} " +
    "--with-mpfr-include=${mpfr.dev}/include " +
    "--with-mpfr-lib=${mpfr.out}/lib " +
    "--with-mpc=${libmpc.out} " +
    "--with-zlib-include=${zlib.dev}/include " +
    "--with-zlib-lib=${zlib.out}/lib " +
    "--enable-deterministic-archives " +
    "--enable-languages=c,c++ " +
    "--enable-libstdcxx-time " +
    "--enable-static " +
    "--enable-tls " +
    "--disable-gnu-indirect-function " +
    "--disable-libmudflap " +
    "--disable-libmpx " +
    "--disable-libsanitizer " +
    "--disable-multilib " +
    "--disable-shared " +
    "--disable-werror";

  musl_conf =
    "--target=${host} " +
    "--disable-shared";

  hardeningDisable = [ "format" ];
}

