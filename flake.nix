{

  description = ''
    Deadline Flake
    - https://blog.tiserbox.com/posts/2026-09-01-using-build-fhs-env-for-dynamically-linked-libraries.html
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  };

  outputs = {
    self,
    nixpkgs,
    ...
  }:

  let

    # Tested
    # - deadlinelauncher
    # - deadlinemonitor
    # - deadlineworker (=deadlineslave)
    #   - [ ] qt.qpa.xcb: QXcbConnection: XCB error: 3 (BadWindow), sequence: 551, resource id: 31457286, major code: 4 (DestroyWindow), minor code: 0
    # - deadlinepulse
    #   - [ ] System.DllNotFoundException: Unable to load shared library 'python2.7' or one of its dependencies. In order to help diagnose loading problems, consider setting the LD_DEBUG environment variable: libpython2.7: cannot open shared object file: No such file or directory
    #            at Python.Runtime.Runtime.Py_SetPythonHome(IntPtr home)
    #            at Python.Runtime.PythonEngine.set_PythonHome(String value)
    #            at FranticX.Scripting.PythonNetScriptEngine.Initialize(Boolean setUnbufferedStdioFlag, String home, String programName)
    #         An error occurred while trying to initialize Deadline's Python Engine:
    #         System.Exception: Attempted python home: /data/share/tools/.stage/test, Unable to load shared library 'python2.7' or one of its dependencies. In order to help diagnose loading problems, consider setting the LD_DEBUG environment variable: libpython2.7: cannot open shared object file: No such file or directory
    #            at Deadline.Scripting.DeadlineScriptManager.a()
    #            at Deadline.Scripting.DeadlineScriptManager..ctor(DataController aet, Boolean aeu, Boolean aev)
    #            at Deadline.Scripting.DeadlineScriptManager.GetInstance(DataController dataController, Boolean redirectOutput, Boolean syncAPI)
    #            at DeadlineBalancer.DeadlineBalancerApp.a(CommandLineParser d)
    #         System.DllNotFoundException: Unable to load shared library 'python2.7' or one of its dependencies. In order to help diagnose loading problems, consider setting the LD_DEBUG environment variable: libpython2.7: cannot open shared object file: No such file or directory
    #            at Python.Runtime.Runtime.Py_SetPythonHome(IntPtr home)
    #            at Python.Runtime.PythonEngine.set_PythonHome(String value)
    #            at FranticX.Scripting.PythonNetScriptEngine.Initialize(Boolean setUnbufferedStdioFlag, String home, String programName)
    #         Exception on Startup: System.Exception: Attempted python home: /data/share/tools/.stage/test, Unable to load shared library 'python2.7' or one of its dependencies. In order to help diagnose loading problems, consider setting the LD_DEBUG environment variable: libpython2.7: cannot open shared object file: No such file or directory
    #            at DeadlineBalancer.DeadlineBalancerApp.a(CommandLineParser d)
    #            at DeadlineBalancer.DeadlineBalancerAppStartup.Main(String[] args)
    #
    #         Deadline Balancer will now exit.
    # - deadlinewebservice

    # Deadline 10.2
    version = "10.2.1.1";
    version-dashed = builtins.replaceStrings ["."] ["-"] version;
    path = "/data/share/tools/.stage/test";

    pkgs = import nixpkgs { system = "x86_64-linux"; };

    # We need libffi.6
    # - https://history.nix-packages.com/package/libffi/3.2.1
    # - https://github.com/NixOS/nixpkgs/tree/9888686702533cf29d1e5dcd26f4d885d5dedb96
    src-nixpkgs-legacy = pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "9888686702533cf29d1e5dcd26f4d885d5dedb96";
      sha256 = "sha256-WDRA2yhKh19cViUaNfF6nmt60LkNOf2YPeJSkMrcv1U=";
    };
    pkgs-legacy = import src-nixpkgs-legacy { system = "x86_64-linux"; };

    pkgs-nogui = with pkgs; [
      zlib
    ];

    pkgs-gui = with pkgs; [
      libX11
      libXrender
      libXfixes
      libxext
      libxkbcommon
      libSM
      libICE
      libGL
      fontconfig
#      libxcb
#      libxcb-image
#      libxcb-render-util
#      libxcb-cursor
#      libxcb-keysyms
#      libxcb-wm
      libxcrypt-legacy
      pkgs-legacy.libffi
    ] ++ pkgs-nogui;

    fhs-nogui = pkgs.buildFHSEnv {
      name = "fhs-deadline";
      targetPkgs = pkgs: (pkgs-nogui);
      runScript = "bash";
    };

    fhs = pkgs.buildFHSEnv {
      name = "fhs-deadline";
      targetPkgs = pkgs: (pkgs-gui);
      runScript = "bash";
    };

  in {
    devShells.x86_64-linux = rec {

      default = deadline-gui;

      deadline-gui = pkgs.mkShell {
        packages = [
          fhs
        ];

        shellHook = ''
          export FHS=1
          # /home/michael/Thinkbox/Deadline10/
          # https://docs.thinkboxsoftware.com/products/deadline/10.2/1_User%20Manual/manual/deploy-client-centrally-managed.html?highlight=environment%20variables#deploy-client-env-vars-ref-label
          # https://docs.thinkboxsoftware.com/products/deadline/10.2/1_User%20Manual/manual/worker.html#worker-local-data-storage-ref-label

          export DEADLINE_PATH="${path}/bin"
          export DEADLINE_SYSTEM_PATH="$HOME/.temp/Deadline/var/lib/Thinkbox"
          export DEADLINE_LOG_PATH="$HOME/.temp/Deadline/var/log/Thinkbox"
          export DEADLINE_CONFIG_FILE="/home/michael/git/repos/flake-deadline/deadline.ini"

          export LD_DEBUG=all
          export LD_DEBUG_OUTPUT="$HOME/.temp/Deadline/ld_debug/debug.log"
          # mkdir -p $HOME/.temp/Deadline/ld_debug

          # export QT_PLUGIN_PATH="${path}/lib/python3/lib/platforms:${path}/lib/platforms"
          export QT_QPA_PLATFORM_PLUGIN_PATH="${path}/lib/python3/lib/platforms"
          # qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in "${path}/lib/python3/lib/platforms"

          # export QT_PLUGIN_PATH="${path}/lib/python3/lib/platforms:${path}/lib/platforms"
          # export QT_QPA_PLATFORM_PLUGIN_PATH="${path}/lib/python3/lib/platforms:${path}/lib/platforms"

          PATH="$DEADLINE_PATH:$PATH"

          # ln -sfn ${pkgs.libxcrypt}/lib/libcrypt.so.2.0.0 ${path}/mylib/libcrypt.so.1.0.0
          # ${path}/bin/python3/python3

          # find ${path} -name "libpython3.7m*" 2>/dev/null
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
            pkgs.wayland
            pkgs.libxcrypt-legacy
            pkgs-legacy.libffi
          ]}:${path}/lib/python3/lib

          # export QT_DEBUG_PLUGINS=1

          export PYTHONHOME="${path}/lib/python3"

          echo "Run: fhs-deadline"
          # echo "Run: ${path}/bin/deadlinelauncher.exe -monitor"

          echo "Available commands:"
          echo $(find ${path}/bin -maxdepth 1 -type f -executable -iname "*.exe" -printf "%f\n" | sort)
        '';
      };

      deadline-nogui = pkgs.mkShell {
        packages = [
          fhs-nogui
        ];

        shellHook = ''
          export FHS=1

          export DEADLINE_PATH="${path}/bin"
          export DEADLINE_SYSTEM_PATH="$HOME/.temp/Deadline/var/lib/Thinkbox"
          export DEADLINE_LOG_PATH="$HOME/.temp/Deadline/var/log/Thinkbox"
          export DEADLINE_CONFIG_FILE="/home/michael/git/repos/flake-deadline/deadline.ini"

          export LD_DEBUG=all
          export LD_DEBUG_OUTPUT="$HOME/.temp/Deadline/ld_debug/debug.log"

          export QT_QPA_PLATFORM_PLUGIN_PATH="${path}/lib/python3/lib/platforms"

          PATH="$DEADLINE_PATH:$PATH"

          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
            pkgs.wayland
            pkgs.libxcrypt-legacy
            pkgs-legacy.libffi
          ]}:${path}/lib/python3/lib

          export PYTHONHOME="${path}/lib/python3"

          echo "Run: fhs-deadline"

          echo "Available commands:"
          echo $(find ${path}/bin -maxdepth 1 -type f -executable -iname "*.exe" -printf "%f\n" | sort)
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