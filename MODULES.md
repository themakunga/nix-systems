## _module\.args

Additional arguments passed to each module in addition to ones
like ` lib `, ` config `,
and ` pkgs `, ` modulesPath `\.

This option is also available to all submodules\. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules\. The sole exception to
this is the argument ` name ` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute\.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:

 - ` lib `: The nixpkgs library\.

 - ` config `: The results of all options after merging the values from all modules together\.

 - ` options `: The options declared in all modules\.

 - ` specialArgs `: The ` specialArgs ` argument passed to ` evalModules `\.

 - All attributes of ` specialArgs `
   
   Whereas option values can generally depend on other option values
   thanks to laziness, this does not apply to ` imports `, which
   must be computed statically before anything else\.
   
   For this reason, callers of the module system can provide ` specialArgs `
   which are available during import resolution\.
   
   For NixOS, ` specialArgs ` includes
   ` modulesPath `, which allows you to import
   extra modules from the nixpkgs package tree without having to
   somehow make the module aware of the location of the
   ` nixpkgs ` or NixOS directories\.
   
   ```
   { modulesPath, ... }: {
     imports = [
       (modulesPath + "/profiles/minimal.nix")
     ];
   }
   ```

For NixOS, the default value for this option includes at least this argument:

 - ` pkgs `: The nixpkgs package set according to
   the ` nixpkgs.pkgs ` option\.



*Type:*
lazy attribute set of raw value



*Default:*

```nix
{ }
```

*Declared by:*
 - [\<nixpkgs/lib/modules\.nix>](https://github.com/NixOS/nixpkgs/blob//lib/modules.nix)



## my\.caddy-main\.enable



Whether to enable Caddt Main Server\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## my\.caddy-main\.email



Email for SSL Cert



*Type:*
string



## my\.caddy-main\.proxies



Domain IPs/Brigeds



*Type:*
attribute set of string



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  "pihole.domain.com" = "125.0.0.1:80";
}
```



## my\.caddy-node\.enable



Whether to enable Caddy node\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## my\.kvm\.enable



Whether to enable PiKVM uStreamer service\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## my\.kvm\.device



This option has no description\.



*Type:*
string



*Default:*

```nix
"/dev/video0"
```



## my\.kvm\.port



This option has no description\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8080
```



## my\.kvm\.resolution



This option has no description\.



*Type:*
string



*Default:*

```nix
"1920x1080"
```



## my\.ollama\.enable



Whether to enable Servidor LLM local con Ollama\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## my\.ollama\.host



Dirección de escucha de la API REST\.
Linux default: 0\.0\.0\.0 (red local + Tailscale)\.
Darwin: sobreescribir a “127\.0\.0\.1” en el host config\.



*Type:*
string



*Default:*

```nix
"0.0.0.0"
```



## my\.ollama\.models



Modelos a descargar automáticamente tras levantar el servicio\.
Idempotente: solo hace pull si el modelo no existe\.
Los modelos persisten en ~/\.ollama/models (macOS) o
/var/lib/ollama/models (Linux)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "qwen2.5-coder:7b"
  "llama3.2:3b"
]
```



## my\.ollama\.openFirewall



Abrir el puerto en el firewall (solo NixOS, ignorado en Darwin)\.



*Type:*
boolean



*Default:*

```nix
true
```



## my\.ollama\.port



Puerto de la API REST de Ollama\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
11434
```



## my\.openconnect\.enable



Whether to enable OpenConnect and GlobalProtect clients\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## my\.pihole\.enable



Whether to enable Main config pihole\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## my\.services\.container-stack\.portainer\.enable



Whether to enable Portainer web UI via OCI container\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## my\.services\.samba-share\.user



Admin server username



*Type:*
string



*Default:*

```nix
"nicolas"
```



## my\.services\.traefik\.acmeEmail



Email for Let’s Encrypt certification



*Type:*
string



*Default:*

```nix
""
```



## my\.services\.traefik\.useCloudflare



Whether to enable Usar Cloudflare DNS Challenge\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```



## my\.tofu-dns\.enable



Whether to enable OpenTofu DNS deployment\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```


