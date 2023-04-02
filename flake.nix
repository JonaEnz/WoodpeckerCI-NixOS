{
  description = "Configuration for a Woodpecker CI server";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.agenix.url = "github:ryantm/agenix";

  outputs = inputs @ { self, nixpkgs, agenix }:
    with builtins;
    let
      pkgs = import nixpkgs {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.woodpecker = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./configuration.nix
          ./nginx.nix
          ./woodpecker.nix
          ./tailscale.nix
          ./minio.nix
          ./monitoring.nix
          agenix.nixosModules.default
        ];
      };
    };
}
