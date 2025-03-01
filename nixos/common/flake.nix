{ config, lib, pkgs, ... }:

let
  cfg = config.srvos;
in
{
  options.srvos = {
    flake = lib.mkOption {
      # FIXME what is the type of a flake?
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = lib.mdDoc ''
        Flake that the nixos contains the nixos configuration.
      '';
    };

    symlinkFlake = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        Symlinks the flake the system was built with to `/run/current-system`
        Having access to the flake the system was installed with can be useful for introspection.

        i.e. Get a development environment for the currently running kernel

        ```
        $ nix develop "$(realpath /run/booted-system/flake)#nixosConfigurations.turingmachine.config.boot.kernelPackages.kernel"
        $ tar -xvf $src
        $ cd linux-*
        $ zcat /proc/config.gz  > .config
        $ make scripts prepare modules_prepare
        $ make -C . M=drivers/block/null_blk
        ```

        Set this option to false if you want to avoid uploading your configuration to every machine (i.e. in large monorepos)
      '';
    };
  };
  config = lib.mkIf (cfg.flake != null) {
    system.extraSystemBuilderCmds = lib.optionalString cfg.symlinkFlake ''
      ln -s ${cfg.flake} $out/flake
    '';

    services.telegraf.extraConfig.inputs.file =
      let
        inputsWithDate = lib.filterAttrs (_: input: input ? lastModified) cfg.flake.inputs;
        flakeAttrs = input: (lib.mapAttrsToList (n: v: ''${n}="${v}"'')
          (lib.filterAttrs (_: v: (builtins.typeOf v) == "string") input));
        lastModified = name: input: ''
          flake_input_last_modified{input="${name}",${lib.concatStringsSep "," (flakeAttrs input)}} ${toString input.lastModified}'';

        # avoid adding store path references on flakes which me not need at runtime.
        promText = builtins.unsafeDiscardStringContext ''
          # HELP flake_registry_last_modified Last modification date of flake input in unixtime
          # TYPE flake_input_last_modified gauge
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList lastModified inputsWithDate)}
        '';
      in
      [
        {
          data_format = "prometheus";
          files = [
            (pkgs.writeText "flake-inputs.prom" promText)
          ];
        }
      ];
  };
}
