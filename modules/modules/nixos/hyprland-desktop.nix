# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: hyprland-desktop.nix
# Path: ./modules/modules/nixos/hyprland-desktop.nix
# Description: Escritorio Wayland liviano con Hyprland + autologin via greetd.
#              Diseñado para RPi5 con vc4-kms-v3d-pi5 (Wayland/DRM).
#              Reemplaza terminal-kiosk cuando se necesita un DE completo.
#              VNC opcional via wayvnc (wlr-screencopy, compatible con Hyprland).
# =====================
{lib, ...}: {
  flake.nixosModules.hyprland-desktop = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption mkIf types;
    cfg = config.my.hyprland-desktop;

    # Sin exec-once para VNC: exec-once solo corre después del primer frame renderizado.
    # Sin monitor físico, Hyprland no renderiza frames → exec-once nunca corre.
    # Solución: systemd user service que espera el socket Wayland de Hyprland.
    vncStartScript = "";

    # ── Paleta TokyoNight Night ─────────────────────────────────────────────────
    # Basada en tonybanters/hyprlua-btw y tonybanters/waybar
    # bg=#1a1b26  fg=#c0caf5  blu=#7aa2f7  mag=#bb9af7  cyn=#7dcfff
    # red=#f7768e grn=#9ece6a ylw=#e0af68  blk=#15161e  brblk=#414868

    # Config de Hyprland — TokyoNight + estilo tonybanters
    # RPi5: animaciones y blur OFF para conservar GPU/CPU
    hyprlandConf = pkgs.writeText "hyprland.conf" ''
      # =====================================================
      # Hyprland — aperture-science (RPi5)
      # Tema: TokyoNight Night — estilo tonybankers
      # =====================================================

      monitor = ,preferred,auto,1

      # ── Autostart ──────────────────────────────────────
      exec-once = waybar
      ${vncStartScript}

      # ── Variables ──────────────────────────────────────
      $terminal = foot
      $launcher  = wofi --show drun --allow-images

      # ── Input (tonybanters: repeat rate agresivo) ──────
      input {
        kb_layout    = us
        follow_mouse = 1
        sensitivity  = 0
        repeat_rate  = 35
        repeat_delay = 200
      }

      # ── General — TokyoNight ────────────────────────────
      # tonybanters usa gaps 0/0 — estilo minimalista tiled
      general {
        gaps_in    = 4
        gaps_out   = 6
        border_size = 2
        col.active_border   = rgba(7aa2f7ee) rgba(bb9af7ee) 45deg
        col.inactive_border = rgba(414868aa)
        layout = master
        resize_on_border = false
      }

      # ── Decoración — TokyoNight ─────────────────────────
      # rounding=10 como tonybanters; blur y sombra OFF (RPi5)
      decoration {
        rounding       = 10
        rounding_power = 2
        active_opacity   = 1.0
        inactive_opacity = 0.92
        blur {
          enabled = false
        }
        drop_shadow = false
      }

      # ── Animaciones: OFF (ahorra GPU en RPi5) ──────────
      animations {
        enabled = false
      }

      # ── Layout master (estilo tonybanters) ─────────────
      master {
        new_status = "master"
      }

      # ── Misc ────────────────────────────────────────────
      misc {
        force_default_wallpaper = 0
        disable_hyprland_logo   = true
      }

      # ── Cursor ──────────────────────────────────────────
      cursor {
        enable_hyprcursor   = false
        no_hardware_cursors = true
      }

      # ── Window rules ────────────────────────────────────
      windowrulev2 = suppressevent maximize, class:.*

      # ── Atajos — estilo vim (tonybanters: h/j/k/l) ─────
      bind = SUPER,       Return,      exec,           $terminal
      bind = SUPER,       D,           exec,           $launcher
      bind = SUPER,       Q,           killactive
      bind = SUPER SHIFT, Q,           exit
      bind = SUPER,       F,           fullscreen,     0
      bind = SUPER SHIFT, Space,       togglefloating
      bind = SUPER,       P,           pseudo

      # Mover foco (vim keys)
      bind = SUPER, H, movefocus, l
      bind = SUPER, L, movefocus, r
      bind = SUPER, K, movefocus, u
      bind = SUPER, J, movefocus, d

      # Mover ventanas
      bind = SUPER SHIFT, H, movewindow, l
      bind = SUPER SHIFT, L, movewindow, r
      bind = SUPER SHIFT, K, movewindow, u
      bind = SUPER SHIFT, J, movewindow, d

      # Workspaces 1-9
      bind = SUPER, 1, workspace, 1
      bind = SUPER, 2, workspace, 2
      bind = SUPER, 3, workspace, 3
      bind = SUPER, 4, workspace, 4
      bind = SUPER, 5, workspace, 5
      bind = SUPER, 6, workspace, 6
      bind = SUPER, 7, workspace, 7
      bind = SUPER, 8, workspace, 8
      bind = SUPER, 9, workspace, 9
      bind = SUPER SHIFT, 1, movetoworkspace, 1
      bind = SUPER SHIFT, 2, movetoworkspace, 2
      bind = SUPER SHIFT, 3, movetoworkspace, 3
      bind = SUPER SHIFT, 4, movetoworkspace, 4
      bind = SUPER SHIFT, 5, movetoworkspace, 5
      bind = SUPER SHIFT, 6, movetoworkspace, 6
      bind = SUPER SHIFT, 7, movetoworkspace, 7
      bind = SUPER SHIFT, 8, movetoworkspace, 8
      bind = SUPER SHIFT, 9, movetoworkspace, 9

      # Navegar workspaces con TAB (tonybanters style)
      bind = SUPER, TAB,       workspace, e+1
      bind = SUPER SHIFT, TAB, workspace, e-1

      # Mouse drag/resize
      bindm = SUPER, mouse:272, movewindow
      bindm = SUPER, mouse:273, resizewindow
    '';

    # ── Waybar — TokyoNight Night (estilo tonybanters) ─────────────────────────
    waybarConfig = pkgs.writeText "waybar-config.json" ''
      {
        "layer":    "top",
        "position": "top",
        "height":   30,
        "spacing":  4,

        "modules-left": [
          "hyprland/workspaces",
          "custom/sep",
          "hyprland/window"
        ],
        "modules-center": [],
        "modules-right": [
          "custom/sep",
          "temperature",
          "custom/sep",
          "cpu",
          "custom/sep",
          "memory",
          "custom/sep",
          "network",
          "custom/sep",
          "clock",
          "custom/sep"
        ],

        "hyprland/workspaces": {
          "disable-scroll": true,
          "all-outputs":    true,
          "format":         "{id}",
          "persistent-workspaces": { "*": 5 }
        },
        "hyprland/window": {
          "max-length":       40,
          "separate-outputs": false
        },
        "clock": {
          "format":     "{:%H:%M}",
          "format-alt": "{:%Y-%m-%d %H:%M}"
        },
        "cpu": {
          "format":  "CPU: {usage}%",
          "interval": 3,
          "tooltip":  false
        },
        "memory": {
          "format":   "Mem: {used:0.1f}G",
          "interval": 10
        },
        "temperature": {
          "thermal-zone":  0,
          "format":        "{temperatureC}°C",
          "interval":      5,
          "critical-threshold": 80
        },
        "network": {
          "format":              "Online",
          "format-disconnected": "Offline ⚠",
          "tooltip-format":      "{ifname}: {ipaddr}"
        },
        "custom/sep": {
          "format":   "|",
          "interval": 0
        }
      }
    '';

    # Waybar CSS — TokyoNight Night, basado en tonybanters/waybar
    waybarStyle = pkgs.writeText "waybar-style.css" ''
      /* TokyoNight Night — tonybanters/waybar */
      @define-color bg    #1a1b26;
      @define-color fg    #a9b1d6;
      @define-color blk   #32344a;
      @define-color red   #f7768e;
      @define-color grn   #9ece6a;
      @define-color ylw   #e0af68;
      @define-color blu   #7aa2f7;
      @define-color mag   #bb9af7;
      @define-color cyn   #7dcfff;
      @define-color brblk #444b6a;
      @define-color white #c0caf5;

      * {
        font-family: "JetBrainsMono Nerd Font", "Iosevka Nerd Font", monospace;
        font-size:   14px;
        font-weight: bold;
      }

      window#waybar {
        background-color: @bg;
        color: @fg;
      }

      /* Workspaces */
      #workspaces button {
        padding:      0 6px;
        color:        @cyn;
        background:   transparent;
        border-bottom: 3px solid @bg;
      }
      #workspaces button.active {
        color:        @cyn;
        border-bottom: 3px solid @mag;
      }
      #workspaces button.empty {
        color: @white;
      }
      #workspaces button.urgent {
        background-color: @red;
        color:            @bg;
      }
      button:hover {
        background:  inherit;
        box-shadow:  inset 0 -3px @white;
      }

      /* Módulos comunes */
      #clock,
      #cpu,
      #memory,
      #temperature,
      #network,
      #custom-sep,
      #window {
        padding: 0 8px;
        color:   @white;
      }

      /* Separador */
      #custom-sep {
        color: @brblk;
      }

      /* Clock — acento cyan */
      #clock {
        color:        @cyn;
        border-bottom: 4px solid @cyn;
      }

      /* CPU — acento verde */
      #cpu {
        color:        @grn;
        border-bottom: 4px solid @grn;
      }

      /* Memoria — acento magenta */
      #memory {
        color:        @mag;
        border-bottom: 4px solid @mag;
      }

      /* Temperatura — amarillo / rojo si crítica */
      #temperature {
        color:        @ylw;
        border-bottom: 4px solid @ylw;
      }
      #temperature.critical {
        color:        @red;
        border-bottom: 4px solid @red;
      }

      /* Red — acento azul */
      #network {
        color:        @blu;
        border-bottom: 4px solid @blu;
      }
      #network.disconnected {
        background-color: @red;
        color:            @bg;
      }

      /* Título de ventana */
      #window {
        color:      @fg;
        font-weight: normal;
        font-style:  italic;
      }
    '';

    # ── foot — TokyoNight Night (basado en tonybanters/hyprlua-btw/foot/foot.ini)
    footConf = pkgs.writeText "foot.ini" ''
      font=JetBrainsMono Nerd Font:size=13
      pad=4x4

      [colors]
      foreground=c0caf5
      background=1a1b26
      alpha=0.95

      ## Normal colors (0-7)
      regular0=15161e  # black
      regular1=f7768e  # red
      regular2=9ece6a  # green
      regular3=e0af68  # yellow
      regular4=7aa2f7  # blue
      regular5=bb9af7  # magenta
      regular6=7dcfff  # cyan
      regular7=a9b1d6  # white

      ## Bright colors (8-15)
      bright0=414868   # bright black
      bright1=f7768e   # bright red
      bright2=9ece6a   # bright green
      bright3=e0af68   # bright yellow
      bright4=7aa2f7   # bright blue
      bright5=bb9af7   # bright magenta
      bright6=7dcfff   # bright cyan
      bright7=c0caf5   # bright white
    '';

    # Wrapper que establece XDG_RUNTIME_DIR antes de lanzar Hyprland.
    # greetd lanza Hyprland sin sesión PAM completa en algunos casos, por lo que
    # XDG_RUNTIME_DIR (/run/user/<uid>) nunca se crea → Hyprland falla con
    # "CRIT: XDG_RUNTIME_DIR is not set!".
    # La solución: script explícito que crea el directorio y lo exporta antes de exec.
    hyprlandSession = pkgs.writeShellScript "hyprland-session" ''
      export XDG_RUNTIME_DIR=/run/user/$(id -u)
      mkdir -p "$XDG_RUNTIME_DIR"
      chmod 0700 "$XDG_RUNTIME_DIR"
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=Hyprland
      exec ${pkgs.dbus}/bin/dbus-run-session ${pkgs.hyprland}/bin/Hyprland
    '';
  in {
    options.my.hyprland-desktop = {
      enable = mkEnableOption "Escritorio Wayland con Hyprland + autologin";

      user = mkOption {
        type = types.str;
        description = "Usuario que ejecuta la sesión Hyprland";
      };

      vnc = {
        enable = mkEnableOption "Acceso remoto VNC via wayvnc (wlr-screencopy)";

        address = mkOption {
          type = types.str;
          default = "0.0.0.0";
          description = "Dirección de escucha de wayvnc. Usar 127.0.0.1 para solo localhost.";
        };

        port = mkOption {
          type = types.port;
          default = 5900;
          description = "Puerto VNC (default: 5900).";
        };

        openFirewall = mkOption {
          type = types.bool;
          default = true;
          description = "Abrir el puerto VNC en el firewall de NixOS.";
        };
      };
    };

    config = mkIf cfg.enable (lib.mkMerge [
      {
        # Gráficos y acceso al seat — igual que terminal-kiosk
        hardware.graphics.enable = true;
        services.seatd.enable = true;

        # Hyprland a nivel sistema (Wayland session portal + paquete)
        programs.hyprland.enable = true;

        # Paquetes del escritorio — TokyoNight stack
        environment.systemPackages = with pkgs; [
          foot # terminal (TokyoNight config incluido)
          wofi # launcher
          unstable.waybar # barra de estado (TokyoNight style)
          wl-clipboard # clipboard
          grim # screenshots
          slurp # selección de área para screenshots
          # Fuente Nerd Font para waybar e íconos
          nerd-fonts.jetbrains-mono
        ];

        # greetd: autologin directo a Hyprland
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${hyprlandSession}";
              user = cfg.user;
            };
            initial_session = {
              command = "${hyprlandSession}";
              user = cfg.user;
            };
          };
        };

        # Grupos necesarios para Wayland/seatd/audio
        users.users.${cfg.user}.extraGroups = [
          "seat"
          "video"
          "input"
          "render"
          "audio"
        ];

        # Variables de entorno para Wayland
        environment.variables = {
          COLORTERM = "truecolor";
          TERM = "xterm-256color";
          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "Hyprland";
        };

        boot.consoleLogLevel = 3;

        # Configuración de Hyprland, Waybar y foot en el home del usuario
        system.activationScripts."hyprland-config-${cfg.user}" = {
          text = ''
            USER_HOME="/home/${cfg.user}"
            HYPR_DIR="$USER_HOME/.config/hypr"
            WAYBAR_DIR="$USER_HOME/.config/waybar"
            FOOT_DIR="$USER_HOME/.config/foot"

            mkdir -p "$HYPR_DIR" "$WAYBAR_DIR" "$FOOT_DIR"

            ln -sf ${hyprlandConf}       "$HYPR_DIR/hyprland.conf"
            ln -sf ${waybarConfig}       "$WAYBAR_DIR/config"
            ln -sf ${waybarStyle}        "$WAYBAR_DIR/style.css"
            ln -sf ${footConf}           "$FOOT_DIR/foot.ini"

            chown -R ${cfg.user}:${cfg.user} "$USER_HOME/.config" 2>/dev/null || true
          '';
        };
      }

      # ── VNC opcional ────────────────────────────────────────────────────
      (lib.mkIf cfg.vnc.enable {
        environment.systemPackages = [pkgs.wayvnc];

        # Puerto VNC en el firewall
        networking.firewall.allowedTCPPorts = lib.mkIf cfg.vnc.openFirewall [cfg.vnc.port];

        # Path unit: dispara el servicio wayvnc cuando el socket Wayland aparece.
        # Sin monitor físico, Hyprland no renderiza frames → exec-once nunca corre.
        # En cambio, vigilamos la aparición del socket wayland-1 con PathExists.
        # %t = XDG_RUNTIME_DIR del usuario (/run/user/<uid>)
        systemd.user.paths.wayvnc = {
          description = "Vigilar socket Wayland para arrancar wayvnc";
          wantedBy = ["default.target"];
          pathConfig = {
            PathExists = "%t/wayland-1";
            Unit = "wayvnc.service";
          };
        };

        systemd.user.services.wayvnc = {
          description = "WayVNC server (Hyprland headless)";
          # No wantedBy: lo activa el path unit al detectar wayland-1.
          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            RestartSec = "5s";
            ExecStartPre = pkgs.writeShellScript "wayvnc-pre" ''
              # Limpiar socket de control de sesiones anteriores
              rm -f "$XDG_RUNTIME_DIR/wayvncctl"
              # Dar tiempo a que Hyprland complete la inicialización
              sleep 2
              # Crear output headless si no hay monitor activo
              HIS=$(ls -t "$XDG_RUNTIME_DIR/hypr/" 2>/dev/null | head -1)
              if [ -n "$HIS" ]; then
                export HYPRLAND_INSTANCE_SIGNATURE="$HIS"
                if ! ${pkgs.hyprland}/bin/hyprctl -j monitors 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q '"name"'; then
                  ${pkgs.hyprland}/bin/hyprctl output create headless || true
                  sleep 1
                fi
              fi
            '';
            ExecStart = "${pkgs.wayvnc}/bin/wayvnc ${cfg.vnc.address} ${toString cfg.vnc.port}";
          };
          environment = {
            WAYLAND_DISPLAY = "wayland-1";
          };
        };
      })
    ]);
  };
}
