# Multi-Architecture Infrastructure Flake

This repository contains a unified Nix Flake to manage configurations across multiple architectures and operating systems. It supports macOS (nix-darwin),
standard Linux x86_64 servers (NixOS), and ARM-based single-board computers like the Raspberry Pi 5 and Raspberry Pi Zero 2.
 
<!-- mtoc-start -->

* [1. Installation Prerequisites](#1-installation-prerequisites)
* [2. Deploying to macOS (nix-darwin)](#2-deploying-to-macos-nix-darwin)
* [3. Remote Provisioning with nixos-anywhere](#3-remote-provisioning-with-nixos-anywhere)
* [4. Building Raspberry Pi SD Images](#4-building-raspberry-pi-sd-images)

<!-- mtoc-end -->

## 1. Installation Prerequisites

Before deploying, ensure the Nix package manager is installed on your controlling machine:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L [https://install.determinate.systems/nix](https://install.determinate.systems/nix) | sh -s -- install
```


## 2. Deploying to macOS (nix-darwin)

To apply the configuration to a macOS machine (e.g., mac-work or mac-home), clone this repository and run the darwin switch command:

```bash
nix run nix-darwin -- switch --flake .#mac-work
```

## 3. Remote Provisioning with nixos-anywhere

For the standard Linux servers, you can perform a remote, unattended installation using nixos-anywhere. The target machine must be booted into a NixOS live ISO and accessible via SSH as the root user.

```bash
# Provision linux-server1
nix run github:nix-community/nixos-anywhere -- --flake .#linux-server1 root@<target-ip>

# Provision linux-server2
nix run github:nix-community/nixos-anywhere -- --flake .#linux-server2 root@<target-ip>
```

>[!NOTE] Ensure the target machines have their specific hardware-configuration.nix properly referenced inside their respective hosts/<hostname>/configuration.nix files. 

## 4. Building Raspberry Pi SD Images

You can generate ready-to-flash SD card images for the Raspberry Pi boards directly from this flake. These images include the fully baked OS, users, and dotfiles.

Build the image for the Raspberry Pi 5:

```bash
nix build .#packages.aarch64-linux.image-rpi5
```

Build the image for the Raspberry Pi Zero 2:

```bash
nix build .#packages.aarch64-linux.image-rpi02
```

The build process will output a compressed .img.zst file located in the result/sd-image/ directory.

Flashing the Image
Decompress and write the image to your SD card (replace /dev/sdX with your actual block device):

```bash
zstdcat result/sd-image/nixos-sd-image-*.img.zst | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
```
