{ crossenv, libudev, libxall, at-spi2-headers, dejavu-fonts }:

let
  version = "6.4.1";
  name = "qtbase-${version}";

  base_src = crossenv.nixpkgs.fetchurl {
    url = "https://download.qt.io/official_releases/qt/6.4/${version}/submodules/qtbase-everywhere-src-${version}.tar.xz";
    hash = "sha256-UyrXHMD5yPfLknZsR7w9IyY8YIdr7NkFOAL5cnryT64=";
  };

  # First build Qt for the host, which provides tools like moc and rcc.
  qt_host = crossenv.native.make_derivation rec {
    name = "qtbase-host-${version}";

    src = base_src;

    patches = [];

    pcre2 = crossenv.nixpkgs.pcre2;
    pcre2_dev = pcre2.dev;

    zlib = crossenv.nixpkgs.zlib;
    zlib_dev = zlib.dev;

    native_inputs = [ crossenv.nixpkgs.perl pcre2_dev ];

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
      "-DZLIB_ROOT=${zlib} -DZLIB_INCLUDE_DIR=${zlib_dev}/include " +
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

  base_raw = crossenv.make_derivation {
    name = "qtbase-raw-${version}";
    inherit version;
    src = base_src;
    builder = ./builder.sh;

    patches = [
      ./megapatch.patch
    ];

    native_inputs = [ crossenv.nixpkgs.perl ];

    inherit qt_host;

    # TODO: see https://stackoverflow.com/questions/70113095/how-to-cross-compile-qt6-on-linux-for-windows

    configure_flags =
      "-cmake-generator Ninja " +
      "-qt-host-path ${qt_host}/lib/cmake/Qt6HostInfo/ " +
      "-xplatform ${platform} " +
      "-device-option CROSS_COMPILE=${crossenv.host}- " +
      "-release " +  # change to -debug if you want debugging symbols
      "-no-shared -static " +
      "-- " +
      #"-DQT_FORCE_BUILD_TOOLS=ON " +
      "-DCMAKE_TOOLCHAIN_FILE=${crossenv.wrappers}/cmake_toolchain.txt ";
  };
in
  base_raw
