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



## my\.services\.ollama\.enable



Whether to enable Habilitar servicio de Ollama\.



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



## my\.services\.ollama\.maxVramBytes



Límite máximo de VRAM en bytes\.



*Type:*
string



*Default:*

```nix
"8589934592"
```



## my\.services\.ollama\.parallelRequests



Número de peticiones paralelas de inferencia\.



*Type:*
string



*Default:*

```nix
"1"
```



## my\.services\.zeroclaw\.enable



Whether to enable Habilitar servicio y CLI GLaDOS (Zeroclaw)\.



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



## my\.services\.zeroclaw\.cpuThreads



Número de hilos de CPU asignados\.



*Type:*
string



*Default:*

```nix
"4"
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


