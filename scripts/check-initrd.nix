# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# nix eval --impure --json --file scripts/check-initrd.nix
let
  flake = builtins.getFlake (toString ./..);
  inherit (flake.inputs.nixpkgs) lib;
in
  builtins.mapAttrs (name: host: let
    cfg = host.config;
    isPi5Image = builtins.elem name ["aperture-bootstrap" "valve"];
  in
    assert cfg.boot.initrd.systemd.enable;
    assert cfg.warnings == [];
    assert isPi5Image -> cfg.fileSystems."/".device == "/dev/disk/by-label/NIXOS_SD";
    assert isPi5Image -> builtins.elem "mmc_block" cfg.boot.initrd.kernelModules;
    assert isPi5Image -> builtins.elem "x-systemd.device-timeout=infinity" cfg.fileSystems."/".options;
    assert isPi5Image -> cfg.boot.initrd.systemd.root == "fstab";
    assert isPi5Image -> lib.hasInfix "x-systemd.device-timeout=infinity" cfg.environment.etc.fstab.text;
      cfg.system.build.initialRamdisk.drvPath)
  flake.nixosConfigurations
