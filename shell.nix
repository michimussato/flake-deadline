{
  pkgs ? import <nixpkgs> { },
}:

# https://blog.tiserbox.com/posts/2026-09-01-using-build-fhs-env-for-dynamically-linked-libraries.html
# doc/build-helpers/special/fhs-environments.section.md
# https://github.com/NixOS/nixpkgs/tree/master/pkgs/build-support/build-fhsenv-bubblewrap

let
  base = pkgs.appimageTools.defaultFhsEnvArgs;

  custom = import (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/9888686702533cf29d1e5dcd26f4d885d5dedb96) {};

in

  (pkgs.buildFHSEnv (base //
  {
  name = "fhs-deadline";
  targetPkgs = pkgs:
    # pkgs.buildFHSEnv provides only a minimal FHS environment,
    # lacking many basic packages needed by most software.
    # Therefore, we need to add them manually.
    #
    # pkgs.appimageTools provides basic packages required by most software.
    (base.targetPkgs pkgs) ++ (with pkgs; [
      pkg-config
      ncurses
      custom.libffi
      # Feel free to add more packages here if needed.
      # foo

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


    ]
  );
  profile = ''
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
      custom.libffi
    ]}:/data/share/tools/.stage/test/lib/python3/lib

    # export QT_DEBUG_PLUGINS=1

    export PYTHONHOME="/data/share/tools/.stage/test/lib/python3"
  '';

  extraOutputsToInstall = ["dev"];
})).env
# Todo:
#  - [ ] # sudo: The "no new privileges" flag is set, which prevents sudo from running as root.
#        # sudo: If sudo is running in a container, you may need to adjust the container configuration to disable the flag.
#        -> https://gist.github.com/Jayman2000/366d389f5d54cc3ea762e0a7b142dfe9

#   vim