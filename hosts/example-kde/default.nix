{ hostname, username, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Fallbacks keep the template evaluable before a real hardware config exists.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub.devices = lib.mkDefault [ "/dev/sda" ];

  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.zsh;
  };
}
