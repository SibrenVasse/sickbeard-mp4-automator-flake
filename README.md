# NixOS Flake for Sickbeard's MP4 Automator

This is the repository for pulling [Sickbeard's MP4 Automator](https://github.com/mdhiggins/sickbeard_mp4_automator) into a flake.

## Binaries

- `sbmp4a`: This is the `manual.py` of the original archive, properly wrapped and set up for use.

## Usage

Dylan hasn't mastered [Colmena](https://github.com/zhaofengli/colmena) yet to figure out how to make it a flake input, so he pulls it in using a nix file like below. There are definately better ways to do it, this just works.

```nix
inputs @ {
  pkgs,
  ...
}: let
  system = "x86_64-linux";
  sbmp4a-flake = builtins.getFlake "git+https://src.mfgames.com/nixos-contrib/sickbeard-mp4-automator-flake?rev=dcfad411fe22dbe1561cbb84aecc95e4e42d9af0";
in {
  environment.systemPackages = with pkgs; [
    ffmpeg
    sbmp4a-flake.defaultPackage.${system}
  ];
}
```
