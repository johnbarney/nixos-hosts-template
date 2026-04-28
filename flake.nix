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
        flatpak
        fonts
        wallpaper
      ];

      kdeSystemSoftware = with catalog.systemSoftware; commonSystemSoftware ++ [
        desktopKdeFull
        displaySddm
      ];

      gnomeSystemSoftware = with catalog.systemSoftware; commonSystemSoftware ++ [
        desktopGnomeFull
        displayGdm
      ];

      kdeUserSoftware = with catalog.userSoftware; [
        chromium
        devCli
        heroic
        onepassword
        steam
        vscode
      ];

      gnomeUserSoftware = with catalog.userSoftware; [
        chromium
        devCli
        vscode
      ];

      aliceHomeSoftware = with catalog.homeSoftware; [
        base
        git
        shellZsh
        sshOnepasswordAgent
        vscode
        terminalKitty
        gtkQtBreezeDark
        plasmaBreezeDark
      ];

      bobHomeSoftware = with catalog.homeSoftware; [
        base
        git
        shellZsh
        ssh
        vscode
        terminalKitty
        gtkQtBreezeDark
        gnomeBreezeDark
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
        example-kde = inputs.dendritic.lib.mkDendriticHost {
          hostname = "example-kde";
          username = "alice";
          hostModule = ./hosts/example-kde;
          homeModule = ./home/alice/home.nix;
          hardware = with catalog.hardware; [
            cpuAmd
            graphicsAmd
          ];
          systemSoftware = kdeSystemSoftware;
          userSoftware = kdeUserSoftware;
          homeSoftware = aliceHomeSoftware;
        };

        example-kde-nvidia = inputs.dendritic.lib.mkDendriticHost {
          hostname = "example-kde-nvidia";
          username = "alice";
          hostModule = ./hosts/example-kde-nvidia;
          homeModule = ./home/alice/home.nix;
          hardware = with catalog.hardware; [
            cpuIntel
            graphicsNvidia
          ];
          systemSoftware = kdeSystemSoftware;
          userSoftware = kdeUserSoftware;
          homeSoftware = aliceHomeSoftware;
        };

        example-gnome = inputs.dendritic.lib.mkDendriticHost {
          hostname = "example-gnome";
          username = "bob";
          hostModule = ./hosts/example-gnome;
          homeModule = ./home/bob/home.nix;
          hardware = with catalog.hardware; [
            cpuAmd
            graphicsAmd
          ];
          systemSoftware = gnomeSystemSoftware;
          userSoftware = gnomeUserSoftware;
          homeSoftware = bobHomeSoftware;
        };

        installer = installerSystem;
      };

      packages.${system}.installer-iso = installerSystem.config.system.build.isoImage;
    };
}
