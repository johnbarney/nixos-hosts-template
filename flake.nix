{
  description = "NixOS host configs using the dendritic public base";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    dendritic = {
      url = "github:johnbarney/nixos-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    nixosConfigurations.example-desktop = inputs.dendritic.lib.mkDendriticHost {
      hostname = "example-desktop";
      username = "alice";
      hostModule = ./hosts/example-desktop;
      homeModule = ./home/alice/home.nix;
      profile = inputs.dendritic.nixosModules.desktop-nvidia;
    };
  };
}
