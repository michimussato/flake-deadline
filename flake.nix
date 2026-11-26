{

  description = ''
    Deadline Flake
    - https://blog.tiserbox.com/posts/2026-09-01-using-build-fhs-env-for-dynamically-linked-libraries.html
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  };

  outputs = {
    self,
    nixpkgs,
    ...
  }:

  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };

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
#      libmcrypt
      # steam-run
    ] ++ pkgs-base;

    fhs = pkgs.buildFHSEnv {
      name = "fhs-deadline";

      targetPkgs = pkgs: (pkgs-deps-deadline);
#        pkgs: with pkgs; [];

      runScript = "bash";
    };
  in {
    devShells.x86_64-linux = {
      default = pkgs.mkShell {
        packages = [
          fhs
        ];

        shellHook = ''
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

          PATH="$DEADLINE_PATH:$PATH"

          # ln -sfn ${pkgs.libxcrypt}/lib/libcrypt.so.2.0.0 /data/share/tools/.stage/test/mylib/libcrypt.so.1.0.0
          # /data/share/tools/.stage/test/bin/python3/python3

          # find /data/share/tools/.stage/test -name "libpython3.7m*" 2>/dev/null
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
            pkgs.wayland
            # pkgs.libxcrypt
            pkgs.libxcrypt-legacy
          # ]}:/data/share/tools/.stage/test/bin/:/data/share/tools/.stage/test/bin/python/:/data/share/tools/.stage/test/lib/python3/lib/:/data/share/tools/.stage/test/lib/python3/lib/:/data/share/tools/.stage/test/lib/python3/lib/python3.7/config-3.7m-x86_64-linux-gnu/:/data/share/tools/.stage/test/bin/
          ]}:/data/share/tools/.stage/test/lib/python3/lib

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