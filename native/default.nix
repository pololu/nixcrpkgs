{ nixpkgs }:

let
  native_base = {
    inherit nixpkgs;

    is_cross = false;

    default_native_inputs = [
      nixpkgs.bashInteractive
      nixpkgs.binutils
      (nixpkgs.binutils-unwrapped or nixpkgs.binutils)
      nixpkgs.bzip2
      nixpkgs.cmake
      nixpkgs.coreutils
      nixpkgs.diffutils
      nixpkgs.findutils
      nixpkgs.gcc
      nixpkgs.gawk
      nixpkgs.gnumake
      nixpkgs.gnugrep
      nixpkgs.gnused
      nixpkgs.gnutar
      nixpkgs.gzip
      nixpkgs.ninja
      nixpkgs.patch
      nixpkgs.which
      nixpkgs.xz
    ];

    make_derivation = import ../make_derivation.nix native_base;
  };

  native = native_base // rec {
    pkgconf = import ./pkgconf { env = native_base; };
    gmp = import ../pkgs/gmp { env = native_base; };
    mpfr = import ../pkgs/mpfr { env = native_base; inherit gmp; };
    libmpc = import ../pkgs/libmpc { env = native_base; inherit gmp mpfr; };

    default_native_inputs = native_base.default_native_inputs ++ [
      pkgconf
    ];

    make_derivation = import ../make_derivation.nix native;
  };

in native
