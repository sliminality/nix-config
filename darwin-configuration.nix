# ~/.nixpkgs/darwin-configuration.nix
# https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled

{ config, pkgs, lib, ... }:

let yabai = pkgs.yabai.overrideAttrs (old: rec {
  src = builtins.fetchTarball {
    url = https://github.com/koekeishiya/yabai/files/7915231/yabai-v4.0.0.tar.gz;
    sha256 = "sha256:0rs6ibygqqzwsx4mfdx8h1dqmpkrsfig8hi37rdmlcx46i3hv74k";
  };
}); in
{
  imports = [
    <home-manager/nix-darwin>  
  ];

  users.users.slim = {
    name = "slim";
    home = "/Users/slim";
    shell = pkgs.fish;
  };

  # Set default shell to fish.
  # https://shaunsingh.github.io/nix-darwin-dotfiles/#orgb26c90e
  system.activationScripts.postActivation.text = ''
    chsh -s ${lib.getBin pkgs.fish}/bin/fish ${config.users.users.slim.name}
  '';
  
  # Create screenshots directory.
  # Do so as the user, not root, so that the directory is writeable by macOS.
  # https://github.com/LnL7/nix-darwin/blob/073935fb9994ccfaa30b658ace9feda2f8bbafee/modules/system/activation-scripts.nix
  system.activationScripts.postUserActivation.text = ''
    mkdir -p ${config.system.defaults.screencapture.location}
  '';

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages = [ ];

  # Nix config.
  nixpkgs.system = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.extraOptions = ''
    extra-platforms = aarch64-darwin x86_64-darwin
    experimental-features = nix-command
  '';
  
  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # System preferences.
  networking.hostName = "hypoaeolian";

  system.defaults = {
    # Requires the directory to already exist.
    # See system.activationScripts.postUserActivation
    screencapture.location = "${config.home-manager.users.slim.home.homeDirectory}/Documents/Screenshots";

    dock = {
      autohide = true;
      showhidden = true; # Make hidden app icons translucent.
      mru-spaces = false; # Don't rearrange spaces automatically.
      show-recents = false;
      launchanim = false; # Don't animate opening applications.
      dashboard-in-overlay = false; 
      tilesize = 50; # Default is 64.
    };

    finder = {
      AppleShowAllExtensions = true; 
      QuitMenuItem = true;
      _FXShowPosixPathInTitle = true;
      # TODO: defaults write com.apple.finder AppleShowAllFiles 1
    };

    # TODO: trackpad disable swipe between pages

    # TODO: Please enable Full Disk Access for your terminal under System Preferences → Security & Privacy → Privacy → Full Disk Access.

    NSGlobalDomain = {
      # TODO: NSGlobalDomain AppleICUForce24HourTime 1
      AppleInterfaceStyle = "Dark"; 
      "com.apple.sound.beep.feedback" = 1;

      # Keyboard.
      ApplePressAndHoldEnabled = false; # Disable accent popups.
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      # TODO: Disable Cmd+Space for spotlight.
      # https://superuser.com/questions/1211108/remove-osx-spotlight-keyboard-shortcut-from-command-line
      # /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist -c "Set :AppleSymbolicHotKeys:64:enabled bool false"
      # TODO: Set default screenshot to buffer.
    };

    loginwindow = {
      GuestEnabled = false; 
      SHOWFULLNAME = true; # Display name and password field instead of userlist.
    };
  };
  
  # Enable font management and install configured fonts to /Library/Fonts.
  # NOTE: Removes any manually-added fonts.
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = ["FiraCode" ]; })
  ];
  
  # Services.
  services.yabai = {
    enable = true; 
    enableScriptingAddition = true;
    package = yabai;
    config = {
      focus_follows_mouse = "autofocus";
      layout = "bsp";
      split_ratio = 0.5;
      auto_balance = "on";
      top_padding = 5;
      bottom_padding = 5;
      left_padding = 5;
      right_padding = 5;
      window_gap = 5;
      window_placement = "second_child";
      extraConfig = ''
        yabai -m rule --add label="licecap" app="^licecap$" manage=off sticky=on
        yabai -m signal --add event=application_activated app="^(licecap|zoom.us)$" action="yabai -m config focus_follows_mouse off"
        yabai -m signal --add event=application_deactivated app="^(licecap|zoom.us)$" action="yabai -m config focus_follows_mouse autofocus"

        # Sticky floating windows
        yabai -m rule --add label="preferences" app="^(System Preferences|Fantastical 2)$" manage=off sticky=on
      '';
    };
  };

  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    skhdConfig = ''
      # move focused window
      cmd + ctrl - h : yabai -m window --warp west
      cmd + ctrl - j : yabai -m window --warp south
      cmd + ctrl - k : yabai -m window --warp north
      cmd + ctrl - l : yabai -m window --warp east

      # toggle window properties
      cmd + ctrl - o : yabai -m window --toggle zoom-fullscreen
      cmd + ctrl - f : yabai -m window --toggle float

      # flip axes
      cmd + ctrl - y : yabai -m space --mirror y-axis
      cmd + ctrl - x : yabai -m space --mirror x-axis

      # resize
      cmd + ctrl + shift - space : yabai -m space --balance
      cmd + ctrl + shift - j : yabai -m window --resize top:0:100 ; \
                               yabai -m window --resize bottom:0:100
      cmd + ctrl + shift - k : yabai -m window --resize bottom:0:-100 ; \
                               yabai -m window --resize top:0:-100
      cmd + ctrl + shift - h : yabai -m window --resize left:-250:0 ; \
                               yabai -m window --resize right:-250:0
      cmd + ctrl + shift - l : yabai -m window --resize right:250:0 ; \
                               yabai -m window --resize left:250:0

      # fix accidental three-column layout, revert to BSP
      # https://github.com/koekeishiya/yabai/issues/658
      cmd + ctrl - p : yabai -m window --toggle split
    '';
  };

  # Homebrew casks.
  # https://github.com/LnL7/nix-darwin/blob/master/modules/homebrew.nix
  homebrew = {
    enable = true;
    autoUpdate = false;
    cleanup = "zap";
    global = {
      brewfile = true;
      noLock = true;
    };
    taps = [
      "homebrew/cask"
      "homebrew/cask-versions"
    ];
    casks = [
      "firefox"
      "notion"
      "bettertouchtool"
      "1password6"
      "fantastical"
      "slack"
      "discord"
      "signal"
      "dropbox"
      "launchbar"
      "licecap"
      "papers3"
      "skim"
      "the-unarchiver"
      "zoom"
    ];
    masApps = {
      bear = 1091189122;
      deliveries = 290986013;
    };
    extraConfig = ''
      cask "dropbox", args: { require_sha: false }
    '';
  };

  # Import Home Manager configuration.
  home-manager.users.slim = import ./home.nix;
}
