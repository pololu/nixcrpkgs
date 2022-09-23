{ crossenv, qt, libusbp }:

crossenv.make_derivation rec {
  name = "tic-${version}";

  version = "1.8.1";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://github.com/pololu/pololu-tic-software/archive/${version}.tar.gz";
    sha256 = "MnGSSodR1lqmI1aMvmAFCP8VmZfJDSNZD4dlOyMzxXQ=";
  };

  builder = ./builder.sh;

  cross_inputs = [ libusbp qt ];
}
