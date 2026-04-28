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
      catalog = inputs.dendritic.lib.moduleCatalog;

      commonSystemSoftware = with catalog.systemSoftware; [
        base
        networking
        audioPipewire
        desktopServices
        desktopKde
        displaySddm
        flatpak
        fonts
        wallpaper
      ];

      commonUserSoftware = with catalog.userSoftware; [
        onepassword
        steam
      ];

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
          hardware = with catalog.hardware; [
            cpuAmd
          ];
          systemSoftware = commonSystemSoftware;
          userSoftware = commonUserSoftware;
        };

        example-nvidia = inputs.dendritic.lib.mkDendriticHost {
          hostname = "example-nvidia";
          username = "alice";
          hostModule = ./hosts/example-nvidia;
          homeModule = ./home/alice/home.nix;
          hardware = with catalog.hardware; [
            cpuIntel
            nvidia
          ];
          systemSoftware = commonSystemSoftware;
          userSoftware = commonUserSoftware;
        };

        installer = installerSystem;
      };

      packages.${system}.installer-iso = installerSystem.config.system.build.isoImage;
    };
}
