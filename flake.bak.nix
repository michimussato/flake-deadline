#{
#  # Based on:
#  # - https://git.voidarc.co.uk/adumh00man/dendritic-tutorial
#  # - https://www.youtube.com/watch?v=_R1odY2EW_o
#
#  description = "Dendritic Flake Template";
#
#  inputs = {
#    nixpkgs = {
#      url = "github:nixos/nixpkgs/nixos-26.05";
#    };
#    flake-parts = {
#      # https://flake.parts/
#      url = "github:hercules-ci/flake-parts";
#      inputs.nixpkgs-lib.follows = "nixpkgs";
#    };
#    import-tree = {
#      # https://import-tree.denful.dev/
#      url = "github:denful/import-tree";
#      # inputs.nixpkgs.follows = "nixpkgs";
#    };
#
#    devshell = {
#      url = "github:numtide/devshell";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#  };
#
#  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
#    (inputs.import-tree ./modules);
#
#}

{
  description = ''
    Deadline Flake
    - https://blog.tiserbox.com/posts/2026-09-01-using-build-fhs-env-for-dynamically-linked-libraries.html
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

#    systemd-nix = {
#      url = github:serokell/systemd-nix;
#      inputs.nixpkgs.follows =
#        "nixpkgs"; # Make sure the nixpkgs version matches
#    };
#
#    deploy.url = github:serokell/deploy;
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      # Overlays
      # - https://wiki.nixos.org/wiki/Overlays

#      thinkbox = pkgs.stdenv.mkDerivation {
#        phases = [
#          "installPhase"
#        ];
#        name = "thinkbox";
#    #    buildPhase = ''
#    #      #some shell script
#    #      # mkdir -p $out/var/lib/Thinkbox
#    #    '';
#        installPhase = ''
#          #some shell script
#          ls -al .
#          mkdir -p $out/var/lib
#          ln -sfn /home/michael/.temp/logs $out/var/lib/Thinkbox
#          # touch $out/var/lib/Thinkbox/hello
#        '';
#      };

      fhs = pkgs.buildFHSEnv {
        name = "fhs-deadline";

        targetPkgs =
          pkgs: with pkgs; [
            # esphome
            # esptool

            # cmake
            # ninja
            # libusb1
          ];

        runScript = "bash";
      };
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          fhs
        ];

        shellHook = ''
          echo "Run: fhs-deadline"
        '';
      };
    };
}