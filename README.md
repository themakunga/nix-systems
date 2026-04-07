# Sistemas y Usuarios

este proyecto es para poder tener un mantenimiento, repoductividad y vision de
las aplicaciones que utilizo, en distintos sistemas linux y darwin, por lo que
esta fuertemente relacionada con mis ambientes de trabajo


<!-- mtoc-start -->

* [Estructura de archivos](#estructura-de-archivos)
* [Sistemas](#sistemas)
  * [Linux](#linux)
  * [Darwin](#darwin)
* [Aplicaciones](#aplicaciones)
* [Usuarios](#usuarios)
* [Desarrollo](#desarrollo)

<!-- mtoc-end -->


## Estructura de archivos

```bash
    applications # Aplicaciones con configuraciones especificas
        - ...
    builders # nixos image builders
        - ... 
    hosts # hosts de sistema separados por darwin/linux con sus configs
        - Darwin
        - Linix
    lib # refactorizacion y helpers de flakes.nix
        - ...
    modules # modulos reutilizables muti host
        - ...
    packages # paqueter de apps personalizadas o builds
        - ...
    users # usuarios segmentados por tipo
        - ... 
    .editorconfig
    .gitignore
    .pre-commit-config.yaml
    .prettierrc.yaml
    flakes.nix
    README.md #
```

##  Sistemas

### Linux

### Darwin

## Aplicaciones

## Usuarios

## Desarrollo

