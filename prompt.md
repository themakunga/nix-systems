*"Actia como un ingeniero en software senior con experiemcia en NIX y
Nix-Darwin, crea la estructura completa de github con actions y los archivos
basicos de .gitignore, ademas de sus .editorconfig, .pre-commit prettier y
.releaserc*

Requisitos:

deben crearse los siiguiente ambientes y usuarios:

-   nombre: agent
    sistema operativo: NixOS
    tipo de computador: Raspberry pi 5
    usuario:
        nombre: GlaDOS
        correo: GlaDOS@aperture.cl
        sudo: true
    paquetes:
        ollama
        openclaw
        nodejs_22
    extras:
        el sistema debe ser copiado a un SSD NVME de 256Gb

-   nombre: pihole
    sistema operativo: NixOS
    tipo de computador: Raspberry Pi Zero 2
    usuario:
        nombre: pihole
        correo: pihole@aperture.cl
        sudo: true
    paquetes:
        pihole
    extras:
        
-   nombre: lab-42devs
    sistema operativo: nixos
    tipo computador: lenovo thinkcenter 
    usuario:
        nombre: admin
        correo: admin@42devs.cl
        sudo: true
    paquetes:
        coolify
        docker

-   nombre: mediacenter
    sistema operativo: ZimaOS
    tipo computador: HP pro desk 
    userio:
        name: Nicolas
        correo: home@aperture.cl
        sudo: true
    packags:
        docker


-   nombre: Kanagawa
    sistema operativo: OsX
    tipo de computador: Macbook Pro M1
    usuario:
        nombre: nicolas
        correo: nmartinezv@icloud.com
        sudo: true
    paquetes:
        nvim-bob
        fzf
        colima
        awscli2
        cargo
        cyberduck
        gh
        gitflow
        go
        google-cloud-sdk
        groovy
        jdk25_headless
        jre25_headless
        kubectl
        lazygit
        lazysql
        libpg
        luarocks
        maven
        nil
        nixfmt
        opam
        opentofu
        pipx
        uv
        pnpm
        posting
        pre-commit
        python3
        ruby
        rustc
        vim
        wezterm
        k9s
        zed-editor
        pandoc
        typora
        nmap
        fd
        neofetch
        tmux
        oh-my-posh
        bash
        zsh
        ripgrep
        sops
        age
        ssh-to-age
        fzf
        stow
        glab
        qmk
        btop
        ctop
        htop
        halloy
        slack
        irssi
        nchat
-   nombre: outer-heaven
    sistema operativo: macosx
    tipo de computador: macbook pro m4
    usuario:
        nombre nicolas
        correo: nicolas.villarroel@thoughtowrks.com
        sudo: true
    paquetes:
    extras:

tambien debe tener un dev shell solo para los equipos macbook y para la
rapsberry pi 5 con los paquetes listados en kanagawa que son de tertminal para
desarrollo de aplicaciones

todo debe ser refactorizado siguiendo los principios DRY y KISS


