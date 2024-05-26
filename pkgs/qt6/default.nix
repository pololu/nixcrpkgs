{ crossenv, libudev, xlibs, at-spi2-headers, dejavu-fonts }:

let
  version = "6.5.3";
  name = "qtbase-${version}";

  nixpkgs = crossenv.nixpkgs;

  base_src = crossenv.nixpkgs.fetchzip {
    url = "https://download.qt.io/official_releases/qt/6.5/${version}/submodules/qtbase-everywhere-src-${version}.tar.xz";
    hash = "sha256-iRv13GxSF89FWQCBAJwOEpXNsuc5rf9WxoFlNfrs9u0=";
  };

  # First build Qt for the host, which provides tools like moc and rcc.
  qt_host = crossenv.native.make_derivation rec {
    name = "qtbase-host-${version}";

    src = base_src;
    patches = [ ./pwd.patch ];

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
      # Don't use /bin/pwd.
      ./pwd.patch

      # This fixes a linker error when building Qt for Linux, which is caused by
      # it not respecting the info in XCB's .pc files.
      # https://invent.kde.org/frameworks/extra-cmake-modules/-/merge_requests/327
      ./find_xcb.patch

      # Prevent Qt from trying to set the RPATH of installed executables on
      # Linux since we are using static linking and the files have no RPATH.
      ./no_rpath_for_static.patch

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

      # Tell Qt to not ignore CMAKE_PREFIX_PATH (set by cmake-cross) when
      # searching for its own modules (e.g. QtSerialPort).
      ./find_modules.patch

      # Tell Qt to look for files like FindWrapIconv.cmake in the appropriate
      # directory of the module that needs it.
      ./module_path.patch
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
        "-no-feature-printsupport " + # can't find one of its headers in Qt 6.5.3
        "-- "
      else "-- ") +
      (if crossenv.arch == "i686" then
      "-DCMAKE_CXX_FLAGS=-msse2 " else "") +
      "-DCMAKE_TOOLCHAIN_FILE=${crossenv.wrappers}/cmake_toolchain.txt";
  };

  module = { name, src }: crossenv.make_derivation {
    name = "${name}-${version}";
    inherit src;
    native_inputs = [ nixpkgs.perl ];
    cross_inputs = [ base ];
    builder = ./module_builder.sh;
  };

  qtserialport = module {
    name = "qtserialport";
    src = crossenv.nixpkgs.fetchzip {
      url = "https://download.qt.io/official_releases/qt/6.5/${version}/submodules/qtserialport-everywhere-src-${version}.tar.xz";
      hash = "sha256-kfropjqD5Htz1V2FHxTbwaLtXEPlMVJSG1deEu8iryQ=";
    };
  };

  qt5compat = module {
    name = "qt5compat";
    src = crossenv.nixpkgs.fetchzip {
      url = "https://download.qt.io/official_releases/qt/6.5/${version}/submodules/qt5compat-everywhere-src-${version}.tar.xz";
      hash = "sha256-4QgoK2IKVMhAvGahLcqI+U6ASXjR4RySyBjWEPzAROE=";
    };
  };

  # Build a selection of Qt examples that help us see if the library and its
  # modules are working.
  examples = crossenv.make_derivation {
    name = "qt-examples-${version}";
    examples = [
      "${qtserialport.src}/examples/serialport/terminal"
      "${qt5compat.src}/examples/core5/widgets/tools/codecs"
      "${base_src}/examples/network/http"
      "${base_src}/examples/qtconcurrent/imagescaling"
      "${base_src}/examples/widgets/mainwindows/menus"
      "${base_src}/examples/widgets/tools/regularexpression"
      "${base_src}/examples/widgets/painting/composition"
      "${base_src}/examples/widgets/effects/blurpicker"
      "${base_src}/examples/corelib/threads/mandelbrot"
    ];
    cross_inputs = [ base qtserialport qt5compat ];
    builder = ./examples_builder.sh;
    font = if crossenv.os == "linux" then "${dejavu-fonts}/ttf/DejaVuSans.ttf"
      else "";
  };
in
  base // { inherit qt_host qtserialport qt5compat examples; }
