{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    nur
  }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {

    nixosConfigurations."framework" = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ken = import ./home.nix;
            nixpkgs.overlays = [ nur.overlay ];
        }
        nur.nixosModules.nur
      ];
    };

    homeConfigurations."ken@ken-work" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home.nix
      ];
    };

  };
}
