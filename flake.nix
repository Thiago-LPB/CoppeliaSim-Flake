{
  description = "Coppelia-nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

      version = "4.10.0";
      rev = "rev0";
      full_version = "V" + (pkgs.lib.replaceStrings ["."] ["_"] version) + "_" + rev;
      ubuntu_version = "24_04";

      desktopItem = pkgs.makeDesktopItem {
        name = "coppelia";
        exec = "coppeliaSim";
        icon = "coppelia";
        desktopName = "CoppeliaSim";
        categories = [
          "Development"
          "Education"
        ];
      };

      meta = {
        description = "Copelia-nix";
        maintainers = [ "Tlpb" ];
      };

      pythonEnv = pkgs.python3.withPackages (
        ps: with ps; [
          pyzmq
          cbor2
          numpy
          ipykernel
        ]
      );

      rpmSrc = pkgs.fetchurl {
        url = "https://rpmfind.net/linux/mageia/distrib/9/x86_64/media/core/updates/lib64sodium23-1.0.18-3.1.mga9.x86_64.rpm";
        hash = "sha256-C7fmrGQqEV4xDalP8MbW84FNJg+jMbXY1QILkHFQ2xs=";
      };
      coppeliaIcon = pkgs.fetchurl {
        url = "https://www.coppeliarobotics.com/assets/img/coppeliaSim.svg";
        hash = "sha256-4HRnRKKyPz/fq/u3wiK0DzObJ1OGe2+qpibMlVmRlnE=";
      };

      buildInputs =
        let

          xorg-deps = with pkgs; [
            libX11
            libXau
            libXcursor
            libXdmcp
            libXrender
            libxcb
          ];

          graphics-deps = with pkgs; [
            mesa
            libGL
            glib
            vulkan-loader
            vulkan-tools
          ];

        in
        with pkgs;
        [
          dbus
          ffmpeg_4.lib
          fontconfig
          freetype
          libkrb5
          libxkbcommon
          stdenv.cc.cc
          zlib
          libbsd
        ]
        ++ xorg-deps
        ++ graphics-deps;

      ld_path = pkgs.lib.makeLibraryPath buildInputs;
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        inherit buildInputs meta version;
        pname = "Coppelia-nix";

        src = pkgs.fetchurl {
          url = "https://downloads.coppeliarobotics.com/${full_version}/CoppeliaSim_Edu_${full_version}_Ubuntu${ubuntu_version}.tar.xz";
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

          sed -i 's|export LD_LIBRARY_PATH=.*|export LD_LIBRARY_PATH="$dirname:$LD_LIBRARY_PATH"|' \
          $out/coppeliaSim.sh

          makeWrapper $out/coppeliaSim.sh $out/bin/coppeliaSim \
          --unset QT_STYLE_OVERRIDE \
          --set QT_QPA_PLATFORM xcb \
          --set LD_LIBRARY_PATH "${ld_path}" \
          --prefix PATH : "${pythonEnv}/bin"

          cp -r ${desktopItem}/share/applications/*.desktop $out/share/applications/

          mkdir -p $out/share/icons/hicolor/scalable/apps
          install -Dm644 ${coppeliaIcon} $out/share/icons/hicolor/scalable/apps/coppelia.svg

        '';

      };
      apps.${system}.default = {
        inherit meta;
        type = "app";
        program = "${self.packages.${system}.default}/bin/coppeliaSim";
      };
    };
}
