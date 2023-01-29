{ crossenv, libudev, xlibs, at-spi2-headers, dejavu-fonts }:

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
      # This fixes a linker error when building Qt for Linux, which is caused by
      # it not respecting the info in XCB's .pc files.
      # https://invent.kde.org/frameworks/extra-cmake-modules/-/merge_requests/327
      ./find_xcb.patch

      # Fixes a compilation error. qtx11extra_p.h uses <xcb/xcb.h>.
      ./qtx11extras.patch

      # Fixes a compilation error.  qxcbcursor.cpp uses X11/cursorfont.h.
      ./find_x11.patch

      # On Linux, look for fonts in the same directory as the application by
      # default if the QT_QPA_FONTDIR environment variable is not present.
      # Without this patch, Qt tries to look for a font directory in the nix
      # store that does not exist, and prints warnings.
      # You must put a font file in the same directory as your executable
      # (e.g. a TTF file from the nixcrpkgs dejavu-fonts package).
      ./font_dir.patch

      # The CUPS library is not detected in our environment and Qt prints a
      # message saying it isn't detected, but for some reason it tries to
      # link to it anyway.
      ./macos_cups.patch
    ];

    builder = ./builder.sh;

    native_inputs = [ crossenv.nixpkgs.perl ];

    cross_inputs =
      if crossenv.os == "linux" then xlibs ++ [ libudev at-spi2-headers ]
      else [];

    configure_flags =
      "-qt-host-path ${qt_host} " +
      "-xplatform ${platform} " +
      "-device-option CROSS_COMPILE=${crossenv.host}- " +
      "-release " +
      "-no-shared -static " +
      (if crossenv.os == "linux" then
        "-xcb " +
        "-no-opengl " +  # TODO: support OpenGL on Linux
        "-- " +
        "-DFEATURE_system_xcb_xinput=ON "
      else if crossenv.os == "macos" then
        "-no-opengl " +  # TODO: support OpenGL on macOS
        "-- " +
        "-DCMAKE_FRAMEWORK_PATH=${crossenv.sdk}/System/Library/Frameworks/ "
      else "-- ") +
      "-DCMAKE_TOOLCHAIN_FILE=${crossenv.wrappers}/cmake_toolchain.txt";
  };

  examples = crossenv.make_derivation {
    name = "qt-examples-${version}";
    src = base_src;
    cross_inputs = [ base ];
    builder = ./examples_builder.sh;
    font = if crossenv.os == "linux" then "${dejavu-fonts}/ttf/DejaVuSans.ttf"
      else "";
  };
in
  base // { inherit examples; }
