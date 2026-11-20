# Applications and services / Aplicaciones y servicios

[README](../README.md)

[English](#english) | [Español](#español)

## English

### Accessibility apps

| Application | Hosts | Option | Guide |
| --- | --- | --- | --- |
| Point Reader | `kanagawa`, `outer-heaven` | `my.apps.point-reader.enable` | [Reading and permissions](accessibility.md) |
| Handy | Both Macs and `aperture-science` | `my.apps.handy.enable` | [Dictation](accessibility.md#stt-dictate-with-handy) |

### Umami on Motherbase

The Motherbase-only `applicationModules.umami` module declares a Compose project at
`/opt/umami`, managed by `compose-umami.service` through the existing Podman Docker API.
It serves `http://motherbase.local:8989`, bound to the current LAN address
`192.168.5.153`; firewall access is limited to `enp2s0` and `192.168.4.0/22`.
Update both the Compose binding and firewall rule if the LAN address changes.

Umami 3.5.0 runs with PostgreSQL 15 on an internal database network. PostgreSQL has no
published port, and its data persists in the `umami_umami-db-data` volume. Never use
`docker compose down -v` unless intentionally deleting the analytics database.
Back up that database before upgrading either image.

SOPS renders a root-only environment file from the encrypted secrets input; no
credentials belong in the Compose file or Nix store. The service waits for SOPS
and `podman.socket`, independently of the ingress/demo stack. SOPS normally renders
secrets during system activation; an explicit dependency on `sops-install-secrets.service`
is added only when `sops.useSystemdActivation` enables that unit.

Check both SOPS activation modes without starting containers or switching the host:

```sh
nix eval --impure --json --file scripts/check-umami-systemd.nix
```

This declaration requires host activation before the URL is available. After activation,
check `systemctl status compose-umami` and `curl --fail http://motherbase.local:8989/api/heartbeat`.
The first login is `admin` / `umami`; replace the default password immediately.
The requested LAN endpoint uses HTTP. Trackers embedded in public HTTPS websites
need a separately configured HTTPS endpoint reachable by their visitors.

### Related guides

- [Mac App Store and audio devices](darwin.md)
- [iPad keyboard and touchpad](ipad-touchpad.md)
- [AI agent integration](agents.md)

## Español

Consulta [Accesibilidad](accessibility.md#español) para Point Reader, VoiceOver y Handy; [Darwin](darwin.md#español) para MAS y audio; y [Agentes](agents.md#español) para la integración del vault.

Las instrucciones de Umami en Motherbase están en la sección anterior. Para controlar Hyprland desde Safari, consulta [iPad como teclado y touchpad](ipad-touchpad.md).
