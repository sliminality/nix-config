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
    # TODO: Why does this give infinite recursion?
    # name = config.home-manager.users.slim.home.username;
    # home = config.home-manager.users.slim.home.homeDirectory;
    shell = pkgs.fish;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    nix-prefetch
  ];

  # Nix config.
  nixpkgs.system = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.extraOptions = ''
    extra-platforms = aarch64-darwin x86_64-darwin
    experimental-features = nix-command
  '';

  # haskell.nix
  nix.binaryCachePublicKeys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  ];
  nix.binaryCaches = [
    "https://hydra.iohk.io"
  ];
  
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

  # Set default shell to fish.
  # https://shaunsingh.github.io/nix-darwin-dotfiles/#orgb26c90e
  system.activationScripts.postActivation.text = ''
    chsh -s ${lib.getBin pkgs.fish}/bin/fish ${config.users.users.slim.name}
  '';
  
  system.activationScripts.postUserActivation.text = let
    dock = import ./modules/dock.nix {
      dockItems = [
        { path = "${config.users.users.slim.home}/Downloads";
          showas = 2;
          arrangement = 2;
          displayas = 1;
        }
        { path = config.system.defaults.screencapture.location;
          showas = 2;
          arrangement = 2;
          displayas = 1;
        }
        { path = "/Applications";
          showas = 2;
          arrangement = 1;
          displayas = 1;
        }
      ];
      inherit lib config; 
    };
    hotkeys = import ./modules/symbolichotkeys.nix {
      updates = {
        # Disable Cmd+Space for Spotlight.
        "64:enabled" = false;
      };
      clobbers = {
        # Switch screenshot keybindings to prefer clipboard.
        "30" = {
          enabled = true;
          value = {
            parameters = [ 52 21 1441792 ];
            type = "standard";
          };
        };
        "31" = {
          enabled = true;
          value = {
            parameters = [ 52 21 1179648 ];
            type = "standard";
          };
        };
      };
      inherit lib config; 
    };
  in
  # Create screenshots directory.
  # Do so as the user, not root, so that the directory is writeable by macOS.
  # https://github.com/LnL7/nix-darwin/blob/073935fb9994ccfaa30b658ace9feda2f8bbafee/modules/system/activation-scripts.nix
  ''mkdir -p ${config.system.defaults.screencapture.location}

    # TODO: Messages.app configuration.
    defaults write com.apple.messages.text 'Autocapitalization' -int 1;
    defaults write com.apple.messages.text 'EmojiReplacement' -int 1;
    defaults write com.apple.messages.text 'SmartInsertDelete' -int 2;
    defaults write com.apple.messages.text 'SpellChecking' -int 1;

    ${dock}
    ${hotkeys}
  '';

  system.defaults = {
    # Requires the directory to already exist.
    # See system.activationScripts.postUserActivation
    screencapture.location = "${config.users.users.slim.home}/Documents/Screenshots";

    dock = {
      autohide = true;
      showhidden = true; # Make hidden app icons translucent.
      mru-spaces = false; # Don't rearrange spaces automatically.
      show-recents = false;
      launchanim = false; # Don't animate opening applications.
      dashboard-in-overlay = false; 
      tilesize = 60; # Default is 64.
    };

    finder = {
      AppleShowAllExtensions = true; 
      QuitMenuItem = true;
      _FXShowPosixPathInTitle = true;
      AppleShowAllFiles = true; # TODO: PR into nix-darwin.
    };

    NSGlobalDomain = {
      AppleICUForce24HourTime = true; # TODO: PR into nix-darwin.
      AppleInterfaceStyle = "Dark"; 
      "com.apple.sound.beep.feedback" = 1;

      # Trackpad.
      AppleEnableSwipeNavigateWithScrolls = false;

      # Keyboard.
      ApplePressAndHoldEnabled = false; # Disable accent popups.
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    # TODO: PR this into nix-darwin.
    # defaults write com.apple.messages.text 'Autocapitalization' -int 1;
    messages = {
      Autocapitalization = 1;
      EmojiReplacement = 1;
      SmartInsertDelete = 2;
      SpellChecking = 1;
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
      auto_balance = "off";
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
    # https://github.com/koekeishiya/skhd/blob/master/examples/skhdrc
    # https://github.com/koekeishiya/skhd/issues/1
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

      # move to space
      cmd + ctrl - right : yabai -m window --space next ; \
                           yabai -m space  --focus next
      cmd + ctrl - left  : yabai -m window --space prev ; \
                           yabai -m space  --focus prev

      # move to display
      cmd + alt + ctrl - right : yabai -m window --display next
      cmd + alt + ctrl - left  : yabai -m window --display prev

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
      "bartender"
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
      genki = 1555925018;
    };
    extraConfig = ''
      cask "dropbox", args: { require_sha: false }
    '';
  };

  # Import Home Manager configuration.
  home-manager.users.slim = import ./home.nix;
}
