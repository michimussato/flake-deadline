{

  description = ''
    Deadline Flake
    - https://blog.tiserbox.com/posts/2026-09-01-using-build-fhs-env-for-dynamically-linked-libraries.html
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";


    # https://history.nix-packages.com/package/libffi/3.2.1
#    nixpkgs-legacy.url = "github:nixos/nixpkgs/nixos-21.05";
#    nixpkgs-legacy.url = "github:NixOS/nixpkgs/9888686702533cf29d1e5dcd26f4d885d5dedb96";
    # https://github.com/NixOS/nixpkgs/tree/9888686702533cf29d1e5dcd26f4d885d5dedb96

  };

  outputs = {
    self,
    nixpkgs,
    ...
  }:

  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
    # pkgs-legacy = import nixpkgs-legacy { system = "x86_64-linux"; };
    src-nixpkgs-legacy = pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "9888686702533cf29d1e5dcd26f4d885d5dedb96";
      sha256 = "sha256-WDRA2yhKh19cViUaNfF6nmt60LkNOf2YPeJSkMrcv1U=";
    };
    pkgs-legacy = import src-nixpkgs-legacy { system = "x86_64-linux"; };
    # pkgs-legacy = import (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/9888686702533cf29d1e5dcd26f4d885d5dedb96) { system = "x86_64-linux"; };

#    libffi6 = pkgs-legacy.libffi;

    pkgs-base = with pkgs; [
      udev
      alsa-lib
      libX11
      libXrender
      libXfixes
      libXi
      libxkbcommon
      libSM
      libICE
      libGL
      wayland
      egl-wayland
    ];

#    # Blender 4.4.3
#    version = "4.4.3";
#    version-dashed = builtins.replaceStrings ["."] ["-"] version;
#    path = "/data/share/tools/blender-${version}-linux-x64";
#    # # Deps
    pkgs-deps-deadline = with pkgs; [
      libxxf86vm
      libdecor

      ## For Ayon Launcher
      glib
      fontconfig
      freetype
      xwayland
      qt5.qtwayland
      qt6.qtwayland
      libxext
      libxcb
      libxcb-image
      libxcb-render-util
      libxcb-cursor
      libxcb-keysyms
      libxcb-wm

      # testing manual command
      zlib
      zstd
      dbus
      libc
#      libgcrypt
      # libxcrypt
      libxcrypt-legacy
      # pkgs-legacy.libffi
      pkgs-legacy.libffi
#      libmcrypt
      # steam-run

        bash
        ncurses5
        xmessage
        curl

        libGLU
        libGL
        alsa-lib
        fontconfig
        zlib
        libpng
        dbus
        nss
        nspr
        expat
        pciutils
        libxkbcommon
        libudev0-shim
        tbb
        xwayland
        qt5.qtwayland
        qt5.qtbase
        nettools  # needed by licensing tools
        bintools  # needed for ld and other tools, so ctypes can find/load sos from python
        ocl-icd  # needed for opencl
        numactl  # needed by hfs ocl backend
        zstd  # needed from 20.0

        libice
        libsm
        libxmu
        libxi
        libxext
        libx11
        libxrender
        libxcursor
        libxfixes
        libxcomposite
        libxdamage
        libxtst
        libxcb
        libxscrnsaver
        libxrandr
        libxcb-util
        libxcb-image
        libxcb-render-util
        libxcb-cursor
        libxcb-keysyms
        libxcb-wm

        libdrm
        libxshmfence
        libxkbfile

    ] ++ pkgs-base;

    fhs = pkgs.buildFHSEnv {
      name = "fhs-deadline";
      targetPkgs = pkgs: (pkgs-deps-deadline);
      runScript = "bash";
    };

  in {
    devShells.x86_64-linux = rec {

      default = deadline;

      deadline = pkgs.mkShell {
        packages = [
          fhs
        ];

        shellHook = ''
          export FHS=1
          echo "Run: fhs-deadline"
          echo "Run: /data/share/tools/.stage/test/bin/deadlinelauncher.exe -monitor"
          # /home/michael/Thinkbox/Deadline10/
          # https://docs.thinkboxsoftware.com/products/deadline/10.2/1_User%20Manual/manual/deploy-client-centrally-managed.html?highlight=environment%20variables#deploy-client-env-vars-ref-label
          # https://docs.thinkboxsoftware.com/products/deadline/10.2/1_User%20Manual/manual/worker.html#worker-local-data-storage-ref-label

          export DEADLINE_PATH="/data/share/tools/.stage/test/bin"
          export DEADLINE_SYSTEM_PATH="$HOME/.temp/Deadline/var/lib/Thinkbox"
          export DEADLINE_LOG_PATH="$HOME/.temp/Deadline/var/log/Thinkbox"
          export DEADLINE_CONFIG_FILE="/home/michael/git/repos/flake-deadline/deadline.ini"

          export LD_DEBUG=all
          export LD_DEBUG_OUTPUT="$HOME/.temp/Deadline/ld_debug/debug.log"
          # mkdir -p $HOME/.temp/Deadline/ld_debug

          # export QT_PLUGIN_PATH="/data/share/tools/.stage/test/lib/python3/lib/platforms:/data/share/tools/.stage/test/lib/platforms"
          export QT_QPA_PLATFORM_PLUGIN_PATH="/data/share/tools/.stage/test/lib/python3/lib/platforms"
          # qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in "/data/share/tools/.stage/test/lib/python3/lib/platforms"

          # export QT_PLUGIN_PATH="/data/share/tools/.stage/test/lib/python3/lib/platforms:/data/share/tools/.stage/test/lib/platforms"
          # export QT_QPA_PLATFORM_PLUGIN_PATH="/data/share/tools/.stage/test/lib/python3/lib/platforms:/data/share/tools/.stage/test/lib/platforms"

          PATH="$DEADLINE_PATH:$PATH"

          # ln -sfn ${pkgs.libxcrypt}/lib/libcrypt.so.2.0.0 /data/share/tools/.stage/test/mylib/libcrypt.so.1.0.0
          # /data/share/tools/.stage/test/bin/python3/python3

          # find /data/share/tools/.stage/test -name "libpython3.7m*" 2>/dev/null
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
            pkgs.wayland
            pkgs.libxcrypt-legacy
            pkgs-legacy.libffi
          ]}:/data/share/tools/.stage/test/lib/python3/lib

          # export QT_DEBUG_PLUGINS=1

          export PYTHONHOME="/data/share/tools/.stage/test/lib/python3"
        '';
      };

      # /data/share/tools/.stage/test/bin/python3/python3.7m

      # /data/share/tools/.stage/test/bin/deadlinelauncher.exe -nogui
      # /data/share/tools/.stage/test/bin/deadlinemonitor.exe -version

      # /data/share/tools/.stage/test/bin/python3/python3
      # /data/share/tools/.stage/test/bin/python3/python3: error while loading shared libraries: libcrypt.so.1: cannot open shared object file: No such file or directory
      # nix run github:nix-community/nix-index-database -- lib/libcrypt.so.1



#      env = {
#        name = "DEADLINE_SYSTEM_PATH";
#        value = "$HOME/.temp/Deadline/";
#      };
    };
  };
}