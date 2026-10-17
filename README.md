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
//configuration.nix
{inputs, ...}:
environment.systemPackages = with pkgs; [
        inputs.coppelia.packages.${stdenv.hostPlatform.system}.default // Loads edu version by default
        //inputs.coppelia.packages.${stdenv.hostPlatform.system}.edu
        //inputs.coppelia.packages.${stdenv.hostPlatform.system}.lite
        //inputs.coppelia.packages.${stdenv.hostPlatform.system}.pro
];
```

# Running without installing

### Edu version
```bash
nix run github:Thiago-LPB/CoppeliaSim-Flake
```
### Lite version
```bash
nix run github:Thiago-LPB/CoppeliaSim-Flake#lite
```
### Pro version
```bash
nix run github:Thiago-LPB/CoppeliaSim-Flake#pro
```
