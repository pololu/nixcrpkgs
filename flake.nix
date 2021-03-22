{
  description = "Tools for cross-compiling standalone applications using Nix.";

  outputs = { self }: {
    lib.nixcrpkgs = { nixpkgs, macos_sdk ? null }: import ./top.nix { inherit nixpkgs macos_sdk; };
  };
}
