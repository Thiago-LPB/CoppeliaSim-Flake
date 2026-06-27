{
  description = "Coppelia-nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    desktopItem = pkgs.makeDesktopItem {
      name = "coppelia";
      exec = "coppeliaSim";
      icon = "coppelia";
      desktopName = "CoppeliaSim";
      categories = [ "Development" "Education" ];
    };
      
    pythonEnv = pkgs.python3.withPackages (ps: with ps; [
      pyzmq 
      cbor2     
      numpy
      ipykernel
    ]);

    rpmSrc = pkgs.fetchurl {
        url = "https://rpmfind.net/linux/mageia/distrib/9/x86_64/media/core/updates/lib64sodium23-1.0.18-3.1.mga9.x86_64.rpm";
        hash = "sha256-C7fmrGQqEV4xDalP8MbW84FNJg+jMbXY1QILkHFQ2xs=";
    };

    buildInputs = let

          xorg-deps = with pkgs; [
            libX11
            libXau
            libXcursor
            libXdmcp
            libXrender
            libxcb
          ];

         qt-deps = with pkgs.libsForQt5; [
          qtbase
          qtsvg
         ];

        in with pkgs; [
          dbus
          ffmpeg_4.lib
          fontconfig
          freetype
          glib
          libGL
          libkrb5
          libxkbcommon
          stdenv.cc.cc
          zlib
          libbsd
        ] ++ xorg-deps ++ qt-deps;

    ld_path = pkgs.lib.makeLibraryPath buildInputs;
  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      inherit buildInputs;
      pname = "Coppelia-nix";
      version = "0.1.0";

      src = pkgs.fetchurl {
        url = "https://downloads.coppeliarobotics.com/V4_10_0_rev0/CoppeliaSim_Edu_V4_10_0_rev0_Ubuntu24_04.tar.xz";
        hash = "sha256-+2KUfDynAV5/UmgwrqwEoeeRQCc2itIjCmQZD5f2i7o=";
      };

      nativeBuildInputs = with pkgs; [ 
        makeWrapper 
        libarchive
      ];

      postUnpack = ''
        bsdtar -xf ${rpmSrc}
        cp -r usr/lib64/* $sourceRoot
      '';

      installPhase = ''
        set -x

        mkdir -p $out/bin
        mkdir -p $out/share/applications

        cp -r ./* $out/

        makeWrapper $out/coppeliaSim.sh $out/bin/coppeliaSim \
        --set LD_LIBRARY_PATH "${ld_path}" \
        --prefix PATH : "${pythonEnv}/bin"

        cp -r ${desktopItem}/share/applications/*.desktop $out/share/applications/

      '';
      dontWrapQtApps = true;

      meta = {
        description = "Copelia-nix";
        maintainers = [ "Tlpb" ];
      };
    };
    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.default}/bin/coppeliaSim";
    };
  };
}
