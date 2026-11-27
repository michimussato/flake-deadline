# an example for github:numtide/devshell shells (see flake.nix also)

# https://dev.to/arnu515/easy-development-environments-with-nix-and-nix-flakes-21mb

{ inputs, self, ... }:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, lib, ... }:

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

#      pkgs = import nixpkgs { system = "x86_64-linux"; };

      # We need libffi.6 for Deadline 10.2
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

#      fhs-nogui = pkgs.buildFHSEnv {
#        name = "fhs-deadline";
#        inherit profile;
#        targetPkgs = pkgs: (pkgs-nogui);
#        runScript = pkgs.lib.getExe runScript-deadline-monitor-nogui;
#      };
#
#      pkgs-dev-deadline-monitor-nogui = (with pkgs; [
#        # fhs shell
#        (pkgs.buildFHSEnv {
#          name = "fhs-deadline";
#          runScript = "bash";
#          targetPkgs = pkgs: (pkgs-nogui);
#        })
#      ]);

      fhs-gui = pkgs.buildFHSEnv {
        name = "fhs";
        inherit profile;
        targetPkgs = pkgs: (pkgs-gui);
        runScript = pkgs.lib.getExe runScript-deadline-gui;
      };

      pkgs-dev-deadline-gui = (with pkgs; [
        # fhs shell
        (pkgs.buildFHSEnv {
          name = "fhs";
          runScript = "bash";
          targetPkgs = pkgs: (pkgs-gui);
        })
      ]);

      profile = ''
        export FHS=1

        export DEADLINE_PATH="${path}/bin"
        export DEADLINE_SYSTEM_PATH="$HOME/.temp/Deadline/var/lib/Thinkbox"
        export DEADLINE_LOG_PATH="$HOME/.temp/Deadline/var/log/Thinkbox"
        export DEADLINE_CONFIG_FILE="/home/michael/git/repos/flake-deadline/deadline.ini"

        export LD_DEBUG=all
        export LD_DEBUG_OUTPUT="$HOME/.temp/Deadline/ld_debug/debug.log"

        export QT_QPA_PLATFORM_PLUGIN_PATH="${path}/lib/python3/lib/platforms"

        export PATH="$DEADLINE_PATH:$PATH"

        export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
          pkgs.wayland
          pkgs.libxcrypt-legacy
          pkgs-legacy.libffi
        ]}:${path}/lib/python3/lib

        export PYTHONHOME="${path}/lib/python3"
      '';

      runScript-deadline-gui = pkgs.writeScriptBin "deadline-${version-dashed}-bin" ''
        echo "Process ID:" $$

        ${pkgs.util-linux}/bin/findmnt --task 1 /mounts/data/sshfs > /dev/null

        # $? represents the last return code
        if [ $? -gt 0 ]; then
          echo -e "\nIs /data mounted?\n"
          echo "Exitting."
          exit 1
        fi

        EXECUTABLE="''${1}"
        EXTRA_ARGS="''${@:2}"

        if [[ "''${EXECUTABLE}" != *.exe ]]; then
          echo -e "Calling \"''${EXECUTABLE}.exe\" instead instead of \"''${EXECUTABLE}\"..."
          EXECUTABLE="''${EXECUTABLE}.exe"
        fi

        echo "Running ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which ''${EXECUTABLE})..." \
          && ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which ''${EXECUTABLE}) | sort --ignore-leading-blanks --ignore-case | grep -E --color "\b(not found)\b|$" \
          && echo "Launching $(which ''${EXECUTABLE})" \
          && echo "- with default args \"${builtins.toString deadline-default-args-gui}\"" \
          && echo "- with extra args \"''${EXTRA_ARGS}\"" \
          && echo "..." \
          && ''${EXECUTABLE} ${builtins.toString deadline-default-args-gui} ''${EXTRA_ARGS}
      '';

#      runScript-deadline-monitor-nogui = pkgs.writeScriptBin "deadline-monitor-${version-dashed}-bin" ''
#        echo "Process ID:" $$
#
#        ${pkgs.util-linux}/bin/findmnt --task 1 /mounts/data/sshfs > /dev/null
#
#        # $? represents the last return code
#        if [ $? -gt 0 ]; then
#          echo -e "\nIs /data mounted?\n"
#          echo "Exitting."
#          exit 1
#        fi
#
#        echo "Running ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which deadlinemonitor.exe)..." \
#          && ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which deadlinemonitor.exe) | sort --ignore-leading-blanks --ignore-case | grep -E --color "\b(not found)\b|$" \
#          && echo "Launching $(which deadlinemonitor.exe)" \
#          && echo "- with default args \"${builtins.toString deadline-default-args-nogui}\"" \
#          && echo "- with extra args \"$@\"" \
#          && echo "..." \
#          && deadlinemonitor.exe ${builtins.toString deadline-default-args-nogui} $@
#      '';

    deadline-default-args = [
      # "-superuser true"
    ];

    deadline-default-args-gui = deadline-default-args ++ [
    ];

#    deadline-default-args-nogui = deadline-default-args ++ [
#      "-nogui"
#    ];

  in

  {
    # https://determinate.systems/blog/nix-run/
    # A simple executable package
    packages = {
      "deadline-gui-${version-dashed}-package" = fhs-gui;
#      "deadline-monitor-nogui-${version-dashed}-package" = fhs-nogui;
    };

    # https://discourse.nixos.org/t/flakes-way-of-creating-a-fhs-environment/20821
    # https://nixos.wiki/wiki/Flakes#nix_run
    # https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-run.html#apps
    # https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/#apps}
    apps = {
      "deadline-gui-${version-dashed}-app" = {
        type = "app";
        program = self.packages.x86_64-linux."deadline-gui-${version-dashed}-package";
        meta.description = "Launch Deadline ${version} in gui mode";
      };
#      "deadline-monitor-nogui-${version-dashed}-app" = {
#        type = "app";
#        program = self.packages.x86_64-linux."deadline-monitor-nogui-${version-dashed}-package";
#        meta.description = "Launch Deadline Monitor ${version} in nogui mode";
#      };
    };

    # https://hugosum.com/blog/recreating-development-environment-with-nix-flake
    devshells = rec {
      "deadline-gui-${version-dashed}-devshell" = {
        packages = pkgs-dev-deadline-gui;
        name = "deadline-gui-${version-dashed}-devshell";
        motd = ''
          You are now in a Deadline (gui) ${version} configured environment.
          Call "fhs" to setup File Hierarchy Standard.

          DEFAULT_ARGS = "$DEFAULT_ARGS"

          Exposed commands:

          $(find ${path}/bin -maxdepth 1 -type f -executable -iname "*.exe" -printf "%f\n" | sort)
        '';
        devshell.startup.fhs.text = ''
          # `inherit profile;` does not work for devshells.
          # so seems to be the only option to get the
          # same env in the devshell
          ${profile}

          # aliases are not exported to subshells
          # hence, use functions
          #
          # automatically export all functions declared here:
          # set -a

          # ayon-help() {
          #   set -x;
          #   command ayon $DEFAULT_ARGS --help;
          #   set +x;
          # }

          # ayon-interactive() {
          #   set -x;
          #   command ayon $DEFAULT_ARGS interactive;
          #   set +x;
          # }

          # set +a
        '';
        # Custom Env:
#        env = [
#          {
#            name = "AYON_LAUNCHER_STORAGE_DIR";
#            value = "/data/share/tools/AYON-deps";
#          }
#          # {
#          #   name = "PATH";
#          #   prefix = path;
#          # }
#          # {
#          #   name = "DEFAULT_ARGS";
#          #   value = "${builtins.toString blender-default-args}";
#          # }
#        ];
      };

#      "deadline-monitor-nogui-${version-dashed}-devshell" = {
#        packages = pkgs-dev-deadline-monitor-nogui;
#        name = "deadline-monitor-gui-${version-dashed}-devshell";
#        motd = ''
#          You are now in a Deadline Monitor (gui) ${version} configured environment.
#          Call "fhs-deadline" to setup File Hierarchy Standard.
#
#          DEFAULT_ARGS = "$DEFAULT_ARGS"
#
#          Available commands:
#          $(find ${path}/bin -maxdepth 1 -type f -executable -iname "*.exe" -printf "%f\n" | sort)
#        '';
#        devshell.startup.fhs.text = ''
#          # `inherit profile;` does not work for devshells.
#          # so seems to be the only option to get the
#          # same env in the devshell
#          ${profile}
#
#          # aliases are not exported to subshells
#          # hence, use functions
#          #
#          # automatically export all functions declared here:
#          # set -a
#
#          # ayon-help() {
#          #   set -x;
#          #   command ayon $DEFAULT_ARGS --help;
#          #   set +x;
#          # }
#
#          # ayon-interactive() {
#          #   set -x;
#          #   command ayon $DEFAULT_ARGS interactive;
#          #   set +x;
#          # }
#
#          # set +a
#        '';
#      };
    };
  };
}
