{ crossenv, libudev, libxall, at-spi2-headers, dejavu-fonts }:

let
  version = "6.4.1";
  name = "qtbase-${version}";

  nixpkgs = crossenv.nixpkgs;

  base_src = crossenv.nixpkgs.fetchurl {
    url = "https://download.qt.io/official_releases/qt/6.4/${version}/submodules/qtbase-everywhere-src-${version}.tar.xz";
    hash = "sha256-UyrXHMD5yPfLknZsR7w9IyY8YIdr7NkFOAL5cnryT64=";
  };

  # First build Qt for the host, which provides tools like moc and rcc.
  qt_host = crossenv.native.make_derivation rec {
    name = "qtbase-host-${version}";

    src = base_src;

    gcc_lib = nixpkgs.gccForLibs.lib;
    glibc = nixpkgs.glibc;
    pcre2 = nixpkgs.pcre2;
    zlib = nixpkgs.zlib;
    zlib_out = zlib.out;

    native_inputs = [ nixpkgs.perl pcre2.dev nixpkgs.patchelf ];

    rpath = "${pcre2.out}/lib:${zlib.out}/lib:${glibc}/lib:${gcc_lib}/lib";

    builder = ./qt_host_builder.sh;

    configure_flags =
      "-system-zlib " +
      "-system-pcre " +
      "-no-feature-androiddeployqt " +
      "-no-feature-concurrent " +
      "-no-feature-gui " +
      "-no-feature-network " +
      "-no-feature-qmake " +
      "-no-feature-sql " +
      "-no-feature-testlib " +
      "-no-feature-xml " +
      "-- " +
      # ZLIB_INCLUDE_DIR is an uncdocumented variable used by cmake's FindZLIB.
      "-DZLIB_ROOT=${zlib} -DZLIB_INCLUDE_DIR=${zlib.dev}/include " +
      # Might not be important, but this prevents src/corelib/CMakeLists.txt
      # from reading /bin/ls to determine the ELF interpreter.
      "-DELF_INTERPRETER=${glibc}/lib/ld-linux-x86-64.so.2" +
      "";
  };

  platform =
    let
      os_code =
        if crossenv.os == "windows" then "win32"
        else if crossenv.os == "macos" then "macx"
        else if crossenv.os == "linux" then "devices/linux-generic"
        else crossenv.os;
      compiler_code =
        if crossenv.compiler == "gcc" then "g++"
        else crossenv.compiler;
    in "${os_code}-${compiler_code}";

  base = crossenv.make_derivation {
    name = "qtbase-${version}";
    inherit version;

    src = base_src;
    patches = [
      ./megapatch.patch

      # This fixes a linker error when building Qt for Linux, which is caused by
      # it not respecting the info in XCB's .pc files.
      ./find_xcb.patch
    ];

    builder = ./builder.sh;

    native_inputs = [ crossenv.nixpkgs.perl ];

    cross_inputs = if crossenv.os == "linux" then [ libxall ]
      else [];

    configure_flags =
      "-qt-host-path ${qt_host} " +
      "-xplatform ${platform} " +
      "-device-option CROSS_COMPILE=${crossenv.host}- " +
      "-release " +
      "-no-shared -static " +
      (if crossenv.os == "linux" then
        "-xcb " +
        "-no-opengl "  # TODO: support OpenGL on Linux
      else "") +
      "-- " +
      "-DFEATURE_system_xcb_xinput=ON " +
      "-DCMAKE_TOOLCHAIN_FILE=${crossenv.wrappers}/cmake_toolchain.txt ";
  };

  examples = crossenv.make_derivation {
    name = "qt-examples-${version}";
    src = base_src;
    cross_inputs = [ base ];
    builder = ./examples_builder.sh;
  };
in
  base // { inherit examples; }
