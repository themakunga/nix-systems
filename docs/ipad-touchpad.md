# iPad como teclado y touchpad — aperture-science

Usa Safari en el iPad para controlar el puntero y escribir texto en el host
NixOS con Hyprland, sin transmitir la pantalla.

## Requisitos

- aperture-science encendido y con sesión Hyprland activa (wheatley autologin)
- iPad y host en la **misma red local** — evitar redes de invitados aisladas
- El servicio `remote-touchpad` arranca automáticamente con la sesión gráfica

## Conexión inicial

1. Abre Safari en el iPad y accede a:
   ```
   http://aperture-science.local:9100
   ```
   La página muestra un código QR con la URL de acceso autenticada.

3. Escanea el QR con la app Cámara del iPad (no necesitas otra app).
   Toca el banner para abrir la URL completa en Safari.

4. **Guarda esa URL en Favoritos de Safari** — contiene el secreto de acceso
   y es necesaria para reconectar sin re-escanear el QR.
   Trátala como una credencial: no la compartas ni la publiques.

## Uso del touchpad

- **Mover puntero**: desliza un dedo por el área táctil
- **Clic izquierdo**: toca una vez con un dedo
- **Clic derecho**: toca una vez con dos dedos
- **Scroll**: desliza dos dedos arriba/abajo
- **Doble clic**: toca dos veces rápido con un dedo

## Uso del teclado

- Toca el icono de teclado en la interfaz para mostrar el teclado del iPad
- Escribe normalmente — el texto llega al host con el foco de teclado actual
- **Enter**, **Retroceso** y **flechas** están disponibles en el menú de teclas

### ñ y tildes

El dispositivo virtual se registra como teclado `latam`. Si los caracteres
especiales no aparecen correctamente, verifica que Hyprland tenga el layout
`latam` activo (`Super+Espacio` alterna entre `us` y `latam`).

> **Limitación conocida**: la equivalencia con un teclado físico no es completa.
> Algunos atajos o combinaciones especiales pueden no funcionar como se espera.

## Reconexión

- Recarga la URL guardada en Favoritos de Safari para reconectar
- El secreto persiste entre reinicios — no necesitas re-escanear el QR
- Si cambias el secreto o la IP cambia, actualiza el favorito

## Seguridad

- El tráfico es HTTP sin cifrar — **solo usar en red local confiable**
- Si necesitas acceso desde otra red, usa VPN (Tailscale ya está configurado)
- El secreto en la URL es el único mecanismo de autenticación

---

## Administración del servicio

```bash
# Estado
systemctl --user status remote-touchpad

# Logs en tiempo real
journalctl --user -u remote-touchpad -f

# Detener manualmente
systemctl --user stop remote-touchpad

# Iniciar manualmente
systemctl --user start remote-touchpad

# Deshabilitar (no arranca con la sesión)
systemctl --user disable remote-touchpad
```

## Rotar el secreto

```bash
# Genera un nuevo secreto (la URL del QR cambiará — actualiza el favorito de Safari)
rm ~/.config/remote-touchpad/secret
systemctl --user restart remote-touchpad
# Escanea el nuevo QR y guarda la nueva URL en Favoritos
```

---

## Diagnóstico

### Página inaccesible (Safari no carga)

1. Verifica que el host está encendido y con sesión activa.
2. Verifica que el servicio está activo:
   ```bash
   systemctl --user is-active remote-touchpad
   ```
3. Verifica que el puerto 9100 está a la escucha:
   ```bash
   ss -tlnp | grep 9100
   ```
4. Verifica el firewall:
   ```bash
   sudo nft list ruleset | grep 9100
   ```
5. Comprueba que el iPad y el host están en la **misma subred** —
   las redes de invitados aíslan dispositivos entre sí.
6. **mDNS entre WiFi y Ethernet**: si el iPad usa WiFi y el host cable,
   algunos routers no reenvían multicast entre interfaces. En ese caso
   `aperture-science.local` no resolverá desde el iPad. Solución: habilitar
   "mDNS repeater" o "multicast bridging" en el router, o instalar Tailscale
   en el iPad y usar la IP de Tailscale (`100.x.x.x`).

### Página abre pero no controla el host

1. Verifica el módulo uinput:
   ```bash
   lsmod | grep uinput
   ```
2. Verifica permisos de /dev/uinput:
   ```bash
   ls -la /dev/uinput
   # debe mostrar GROUP=uinput, permisos 0660
   ```
3. Verifica que wheatley está en el grupo uinput:
   ```bash
   groups wheatley
   # debe incluir 'uinput'
   ```
4. Verifica que Hyprland detecta los dispositivos virtuales:
   ```bash
   hyprctl devices
   # debe listar un teclado y ratón de remote-touchpad
   ```

### Caracteres incorrectos (ñ, tildes, símbolos)

1. Verifica el layout activo en Hyprland:
   ```bash
   hyprctl devices | grep -A5 "keyboard"
   ```
2. Alterna entre `us` y `latam` con `Super+Espacio`
3. El dispositivo virtual heredará el layout activo de Hyprland

### El servicio no arranca tras reiniciar

1. Verifica que wheatley tiene linger activo (sesión sin login interactivo):
   ```bash
   loginctl show-user wheatley | grep Linger
   ```
2. Verifica grupos con el nuevo sistema:
   ```bash
   id wheatley
   ```
   Si el grupo `uinput` no aparece, requiere re-login o reinicio.

---

## Revertir

Para desactivar completamente:

1. En `aperture-science.nix`: eliminar `remote-touchpad.enable = true`
   y `users.users.wheatley.extraGroups = ["uinput"]`
2. En `applicationModules`: eliminar `"remote-touchpad"`
3. `make switch-aperture` para aplicar
4. El módulo kernel `uinput` se descargará en el siguiente reinicio
   si ningún otro módulo lo requiere (`hardware.uinput.enable = false` lo garantiza)
