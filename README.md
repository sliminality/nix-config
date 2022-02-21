# nix-config

This is my [Nix](https://nixos.org/guides/how-nix-works.html) configuration for my M1 MacBook Pro running macOS Monterey 12.0.1.

I am using the following abstractions on top of the nixpkgs manager:

- [Home Manager](https://github.com/nix-community/home-manager) to replace my dotfiles and declaratively manage packages without writing `nix-env` commands
- [nix-darwin](https://github.com/LnL7/nix-darwin) to manage my operating system and a few OS-specific dotfiles ([yabai](https://github.com/koekeishiya/yabai), [skhd](https://github.com/koekeishiya/skhd), Homebrew, etc.)

These files are public in the hopes that they can be useful to others troubleshooting their Nix configurations. They are not designed to be used directly by others; there's a lot of custom configuration you probably don't want.

I am not using [flakes](https://nixos.wiki/wiki/Flakes) because I don't understand them yet.

## Some notable components

This repository includes my configurations for the following tools (non-exhaustive list):

- fish shell
- Neovim
- Alacritty
- tmux + [config](https://github.com/gpakosz/.tmux) by @gpakosz
- yabai + skhd
- Firefox
- ripgrep
- fzf
- fasd

## macOS configuration

In addition to using many of the modules provided by nix-darwin, I have written my own scripts to configure the following aspects of macOS Monterey:

- Add folders to the Dock for quick access to apps, screenshots, downloads
- Disable spellcheck and autocorrect in Messages.app
- Swap the keyboard shortcuts for screenshotting to clipboard vs. disk
