# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: base-machine.nix
# Path: ./modules/modules/nixos/base-machine.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.nixosModules.base-machine = {
    config,
    lib,
    ...
  }: let
    inherit
      (lib)
      mkEnableOption
      mkOption
      types
      mkIf
      mkDefault
      ;
    inherit
      (types)
      enum
      str
      ;
    cfg = config.my.base-machine;
  in {
    options.my.base-machine = {
      enable = mkEnableOption "Base machine config (boot, SOPS, FS)";

      bootMode = mkOption {
        type = enum [
          "uefi"
          "legacy"
          "rpi"
        ];
        default = "uefi";
        description = "Boot loader type";
      };

      rootDevice = mkOption {
        type = str;
        default = "/dev/sda1";
        description = "Path of main disk. ignored if Disko is used";
      };
    };

    config = mkIf cfg.enable {
      services.openssh.enable = true;

      sops.age.sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];

      boot = {
        loader =
          if cfg.bootMode == "uefi"
          then {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          }
          else if cfg.bootMode == "legacy"
          then {
            grub = {
              enable = true;
              devices = ["/dev/sda"];
            };
          }
          else {
            grub = {
              enable = false;
            };
            generic-extlinux-compatible.enable = true;
          };
      };

      fileSystems."/" = {
        device = mkDefault cfg.rootDevice;
        fsType = mkDefault "ext4";
      };
    };
  };
}
