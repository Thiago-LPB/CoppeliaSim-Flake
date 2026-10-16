# Installing using Flake
```nix
//flake.nix
{
  description = "My Flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    coppelia = {
      url = "github:Thiago-LPB/CoppeliaSim-Flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
};
```
### Add to systemPackages
```nix
///configuration.nix
environment.systemPackages = with pkgs; [
        inputs.coppelia.packages.${stdenv.hostPlatform.system}.default
];
```
##### Or

```nix
///configuration.nix
environment.systemPackages = [
        inputs.coppelia.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

# Running without installing

```bash
$ nix run github:Thiago-LPB/CoppeliaSim-Flake
```
