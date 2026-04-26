{
  description = "NixOS host configs using the dendritic public base";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    dendritic = {
      url = "github:johnbarney/nixos-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      system = "x86_64-linux";

      installerSystem = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
          inputs.dendritic.nixosModules.installer
        ];
      };
    in
    {
      nixosConfigurations = {
        example-desktop = inputs.dendritic.lib.mkDendriticHost {
          hostname = "example-desktop";
          username = "alice";
          hostModule = ./hosts/example-desktop;
          homeModule = ./home/alice/home.nix;
          profile = inputs.dendritic.nixosModules.desktop-nvidia;
        };

        installer = installerSystem;
      };

      packages.${system}.installer-iso = installerSystem.config.system.build.isoImage;
    };
}
