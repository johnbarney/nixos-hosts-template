# NixOS Hosts Template

Thin host flake that consumes the public `dendritic` base:

```text
nixos-hosts-template -> github:johnbarney/nixos-config
```

Use this as a public reference template. Keep reusable modules and
installer code in the public base. Keep real host identity, generated hardware
configuration, and private machine choices in a private copy.

## Layout

- `flake.nix` defines example host outputs using `dendritic.lib.mkDendriticHost`.
- `flake.nix` also defines an installer ISO package using `dendritic.nixosModules.installer`.
- `hosts/example-desktop/` shows a generic desktop host.
- `hosts/example-nvidia/` shows a desktop host using NVIDIA hardware support.
- `home/alice/` shows the host repo side of Home Manager state.
- `Makefile` provides common check, rebuild, lock-update, and post-install
  migration commands.

Hosts are assembled from four explicit menus exported by the base:

```nix
hardware = with inputs.dendritic.lib.moduleCatalog.hardware; [
  cpuAmd
];

systemSoftware = with inputs.dendritic.lib.moduleCatalog.systemSoftware; [
  base
  networking
  audioPipewire
  desktopServices
  desktopKdeFull
  displaySddm
  flatpak
  fonts
  wallpaper
];

userSoftware = with inputs.dendritic.lib.moduleCatalog.userSoftware; [
  chromium
  heroic
  onepassword
  steam
  vscode
];

homeSoftware = with inputs.dendritic.lib.moduleCatalog.homeSoftware; [
  base
  shellZsh
  sshOnepasswordAgent
  vscode
  terminalKitty
  themeBreezeDark
  plasmaBreezeDark
];
```

`example-desktop` uses the common desktop menu without NVIDIA. `example-nvidia`
adds `nvidia` to its hardware menu.

## First Use

1. Fork or copy this repo into a private hosts repo.
2. Rename `example-desktop` and `alice` to match your machine and user.
3. Generate or copy the real hardware config into
   `hosts/<host>/hardware-configuration.nix`.
4. Validate, then build or switch the host:

   ```sh
   make check
   make switch HOST=<host>
   ```

Generated `hardware-configuration.nix` files are expected in private host repos.
Keep this public template sanitized.

## Installer ISO

Build the installer from the hosts repo so the install workflow belongs next to
the host definitions:

```sh
make build-iso
make iso-path
```

The ISO is copied to `./result/iso/*.iso`. It provides `install-nixos-host`,
which installs from a hosts flake at `/mnt/etc/nixos` or copies one from a local
path:

```sh
sudo install-nixos-host <host>
sudo install-nixos-host <host> /path/to/hosts-repo
```

## Add Another Host

1. Copy `hosts/example-desktop` or `hosts/example-nvidia` to `hosts/<new-host>`.
2. Add another `nixosConfigurations.<new-host>` entry in `flake.nix`.
3. Set `hostname`, `username`, `hostModule`, and `homeModule` for that host.
4. Generate the real hardware config on the target machine.

## Update the Public Base

```sh
make update-base
```

Commit the lockfile after testing.

## Track Template Changes

For a private repo created from this template, keep this repo as an explicit
upstream remote:

```sh
git remote add upstream git@github.com:johnbarney/nixos-hosts-template.git
git fetch upstream
git merge upstream/main
```

Template updates are occasional structure/docs changes. Normal NixOS module
updates should come through the `dendritic` flake input instead.
