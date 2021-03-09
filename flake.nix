{
  description = "Tools for cross-compiling standalone applications using Nix.";

  outputs = { self }: {
    lib.nixcrpkgs = import ./top.nix;
  };
}
