{
  pkgs ? import <nixpkgs> { },
}:

# https://blog.tiserbox.com/posts/2026-09-01-using-build-fhs-env-for-dynamically-linked-libraries.html
# doc/build-helpers/special/fhs-environments.section.md
# https://github.com/NixOS/nixpkgs/tree/master/pkgs/build-support/build-fhsenv-bubblewrap

let
  base = pkgs.appimageTools.defaultFhsEnvArgs;
#  deadline-fhs-env = pkgs.buildFHSEnv.override {
#
#
#  };

#  foo = pkgs.stdenv.mkDerivation {
#
#    phases = [
#      "installPhase"
#    ];
#    name = "foo";
##    buildPhase = ''
##      #some shell script
##      # mkdir -p $out/var/lib/Thinkbox
##    '';
#    installPhase = ''
#      #some shell script
#      mkdir -p $out/var/lib
#      ln -sfn /home/michael/.temp/logs $out/var/lib/Thinkbox
#      # touch $out/var/lib/Thinkbox/hello
#    '';
#  };
in

  (pkgs.buildFHSEnv (base // {
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
      # Feel free to add more packages here if needed.
      # foo
    ]
  );
  profile = "export FHS=1";

#  extraBuildCommands = ''
#    ln -sfn /home/michael/.temp/logs /var/log/Thinkbox
#  '';
  extraOutputsToInstall = ["dev"];
})).env
# Todo:
#  - [ ] # sudo: The "no new privileges" flag is set, which prevents sudo from running as root.
#        # sudo: If sudo is running in a container, you may need to adjust the container configuration to disable the flag.
#        -> https://gist.github.com/Jayman2000/366d389f5d54cc3ea762e0a7b142dfe9

#   vim