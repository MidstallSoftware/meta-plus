{
  description = "Meta+ is a more advanced type utilities library than Zig's standard meta.";

  nixConfig = rec {
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    substituters = [ "https://cache.nixos.org" "https://cache.garnix.io" ];
    trusted-substituters = substituters;
    fallback = true;
    http2 = false;
  };

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixpkgs.url = github:ExpidusOS/nixpkgs;

  inputs.zig-overlay.url = github:mitchellh/zig-overlay;

  outputs = { self, expidus-sdk, nixpkgs, zig-overlay }@inputs:
    with expidus-sdk.lib;
    flake-utils.eachSystem flake-utils.allSystems (system:
      let
        pkgs = expidus-sdk.legacyPackages.${system}.appendOverlays [
          zig-overlay.overlays.default
          (f: p: {
            zig = f.zigpkgs.master;
          })
        ];
      in {
        devShells.default = pkgs.mkShell {
          name = "meta-plus";

          packages = with pkgs; [ zig ];
        };
      });
}
