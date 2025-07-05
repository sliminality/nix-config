# ~/.nixpkgs/darwin-configuration.nix
# https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled

{ config, pkgs, lib, ... }:

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
  
  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # Note that `nix.nixPath` takes precedence: https://github.com/LnL7/nix-darwin/issues/137#issuecomment-488049683
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";
  environment.darwinConfig = "/Users/slim/.nixpkgs/darwin-configuration.nix";

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # 25.05 did some stuff.
  system.primaryUser = "slim";

  # Set default shell to fish.
  # https://shaunsingh.github.io/nix-darwin-dotfiles/#orgb26c90e
  system.activationScripts.postActivation.text = ''
    chsh -s ${lib.getBin pkgs.fish}/bin/fish ${config.users.users.slim.name}
  '';
  
  # Use Touch ID for sudo.
  # 24.11
  # security.pam.enableSudoTouchIdAuth = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  # [24.11] https://github.com/NixOS/nixpkgs/issues/294208#issue-2175237014
  environment.etc."pam.d/sudo_local".text = ''
    # nix-darwin
    auth optional ${pkgs.pam-reattach}/lib/pam/pam_reattach.so
    auth sufficient pam_tid.so
  '';

  system.activationScripts.activateSettings.text = let
    dock = import ./darwin-modules/dock.nix {
      dockItems = [
        { tile-data = {
            file-data = {
              _CFURLString = "file://${config.users.users.slim.home}/Downloads";
              _CFURLStringType = 15;
            };
            showas = 2;
            arrangement = 2;
            displayas = 1;
          };
          tile-type = "directory-tile";
        }
        # TODO: Update this to use the persistent-others attr, once it supports configuring layout/sort.
        {
          tile-data = {
            RawQuery = "(InRange(kMDItemContentCreationDate,\\$time.today(-30d),\\$time.today(+1d)) &amp;&amp; (_kMDItemGroupId = 13))";
            RawQueryDict = {
              SearchScopes = [
                "/System/Volumes/Data${config.system.defaults.screencapture.location}"
              ];
            };
            filelocation = "file://${config.users.users.slim.home}/Library/Saved Searches/Recent Screenshots.savedSearch";
            FinderFilesOnly = 1;
            UserFilesOnly = 1;
            arrangement = 4;
            displayas = 1;
            viewas = 2; # TODO: What is this?
            label = "Recent Screenshots";
          };
          tile-type = "smartfolder-tile";
        }
        { tile-data = {
            file-data = {
              _CFURLString = "file:///Applications";
              _CFURLStringType = 15;
            };
            showas = 2;
            arrangement = 1;
            displayas = 1;
          };
          tile-type = "directory-tile"; # or "smartfolder-tile"
        }
      ];
      inherit lib config; 
    };
    hotkeys = import ./darwin-modules/symbolichotkeys.nix {
      updates = {
        # Disable Cmd+Space for Spotlight.
        # TODO: Figure out how to make this work on a fresh install, when entry 64:enabled doesn't exist.
        # Can add this to `clobbers` as a workaround:
        # "64" = {
        #   enabled = false;
        # };
        "64:enabled" = false;
      };
      clobbers = {
        # Switch screenshot keybindings to prefer clipboard.
        # NOTE: Need to log out and back in to apply these.
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
  ''sudo -u slim mkdir -p ${config.system.defaults.screencapture.location}
    # Launch BTT on startup.
    defaults write com.hegenberg.BetterTouchTool launchOnStartup -bool true

    ${dock}
    ${hotkeys}

    # Following line should allow us to avoid a logout/login cycle:
    # https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
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
      wvous-br-corner = 1; # Disable Notes hot corner.
    };

    finder = {
      AppleShowAllExtensions = true; 
      QuitMenuItem = true;
      _FXShowPosixPathInTitle = true;
      AppleShowAllFiles = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; 
      "com.apple.sound.beep.feedback" = 1;

      # TODO: Figure out how to change terminal theme automatically.
      # https://arslan.io/2021/02/15/automatic-dark-mode-for-terminal-applications/
      # defaults write -g AppleInterfaceStyleSwitchesAutomatically -bool true
      AppleInterfaceStyleSwitchesAutomatically = true;

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
      "com.apple.keyboard.fnState" = true; # Use F1, F2, etc. as function keys.
    };

    loginwindow = {
      GuestEnabled = false; 
      SHOWFULLNAME = true; # Display name and password field instead of userlist.
    };

    # https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
    CustomUserPreferences = {
      "com.apple.messages.text" = {
        Autocapitalization = 1;
        EmojiReplacement = 1;
        SmartDashes = 1;
        SmartInsertDelete = 2;
        SmartQuotes = 1;
        SpellChecking = 1;
      };

      "com.apple.finder" = {
        _FXSortFoldersFirst = true;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
      };

      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };

      "at.obdev.LaunchBar" = {
        ClipboardHistoryCapacity = 100;
        ShowDockIcon = 0;
      };
    };
  };

  # Modifier keys.
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # Enable font management and install configured fonts to /Library/Fonts.
  # NOTE: Removes any manually-added fonts.
  # fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    iosevka
    (nerd-fonts.fira-code)
    (import ./darwin-modules/fonts/sf-mono { inherit lib stdenv pkgs; })
    (import ./darwin-modules/fonts/sf-pro { inherit lib stdenv pkgs; })
  ];
  
  # Services.
  services.yabai = {
    enable = true; 
    enableScriptingAddition = true;
    package = pkgs.yabai;
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
        # yabai -m rule --add app="^1Password" manage=off
        # yabai -m rule --add app="^1Password 6" manage=off
        # yabai -m rule --add app="^App Store$" manage=off
        # yabai -m rule --add label="df" app="^dwarfort.exe$" manage=off

        yabai -m rule --add app="^Fantastical" manage=off sticky=on
        yabai -m rule --add label="licecap" app="^licecap$" manage=off sticky=on
        # yabai -m rule --add app="^System Settings$" manage=off sticky=on
        yabai -m rule --add app="TunnelBear" manage=off sticky=on

        # Disable focus follows mouse
        yabai -m signal --add event=application_activated app="^(licecap|zoom.us)$" action="yabai -m config focus_follows_mouse off"
        yabai -m signal --add event=application_deactivated app="^(licecap|zoom.us)$" action="yabai -m config focus_follows_mouse autofocus"
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
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
    };
    global = {
      brewfile = true;
      lockfiles = false;
    };
    taps = [
      # "homebrew/cask"
      # "homebrew/cask-versions"
    ];
    casks = [
      "bartender"
      "bettertouchtool"
      "fantastical"
      "firefox"
      "launchbar"
      "licecap"
      "maestral"
      "skim"
      "sublime-text"
      "tableplus"
      "vivid"
    ];
    masApps = {
    };
    extraConfig = ''
      # cask "dropbox", args: { require_sha: false }
    '';
  };
}
