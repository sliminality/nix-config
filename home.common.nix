# Common Home Manager config.
# Everything in here should go on all new machines.
# ~/.config/nixpkgs/home.nix
# lib.fakeSha256

{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "slim";
  home.homeDirectory = "/Users/slim";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config = {
    # PROPRIETARY SOFTWARE
    allowUnfree = true;

    packageOverrides = pkgs: {
      # For Firefox extensions.
      nur = import (builtins.fetchTarball {
        url = "https://github.com/nix-community/NUR/archive/ee7ba7bc1e6ac987a4de9a910fbd9ce5a98f6b63.tar.gz";
        sha256 = "sha256:0xcwyg8l4swrz9h9xmfkg5gr6h79ay23l709iwv1ipp30zgi0vnb";
      }) {
        inherit pkgs;
      };

      # [24.05] Pin fishPlugins.pure to the commit before it starts referencing
      # $fish_prompt_pwd_dir_length, which is undefined for some reason.
      # https://github.com/pure-fish/pure/commit/a4a0cdfe3d296aa60cd31e426adeab4526ab1d60
      fishPlugins = pkgs.fishPlugins // {
        pure = pkgs.fishPlugins.pure.overrideAttrs (oldAttrs: {
          doCheck = false;
          src = pkgs.fetchFromGitHub {
            owner = "pure-fish";
            repo = "pure";
            rev = "f37bb2898490d0e48661e3cf6a13d5a879135697";
            sha256 = "sha256-wYCQfTDo/OTetX2x19O0JTdwia8DfX4uPCD47szyhns=";
          };
        });
      };
    };
  };

  home.packages = with pkgs; [
    # Shell
    fishPlugins.pure
    pam-reattach

    # CLI utilities
    fasd
    htop
    ijq
    imagemagick
    jq
    ripgrep
    tree

    # Document preparation
    pandoc

    # C
    llvmPackages_13.llvm

    # Nix
    niv
  ];

  # Environment variables.
  home.sessionVariables = {
    EDITOR = "nvim";
    NIX_SHELL_PRESERVE_PROMPT = 1;
  };

  home.sessionPath = [];

  programs.fish = {
    enable = true;
    plugins = [
      # Need this to source ~/.nix-profile/bin when using fish as default macOS shell
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
      {
        name = "fasd.fish";
        src = pkgs.fetchFromGitHub {
          owner = "fishgretel";
          repo = "fasd";
          rev = "9a16eddffbec405f06ac206256b0f7e3112b0e2c";
          sha256 = "sha256-pylSe8UPvOfYhQIdD0O/X2xi0DiJ4Xy/JqWV6jTe7pY=";
        };
      }
    ];

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      # List files with -F decorative endings.
      ls = "ls -F"; 
      # List files with -F decorative endings, including hidden files.
      lsa = "ls -Fa"; 
      # List files long, with human-readable sizes.
      lsl = "ls -hlF";
      # List files long, with human-readable sizes, including hidden files.
      lsla = "ls -halF";
    };
    
    shellAbbrs = {
      g = "git";
      gs = "git status";
      ga = "git add";
      gb = "git branch";
      go = "git checkout";
      gc = "git commit";
      gcm = "git commit -m";
      gcamend = "git commit --amend";
      gd = "git diff";
      gr = "git rebase";
      grc = "git rebase --continue";
      gra = "git rebase --abort";
    };

    functions = {
      cs = {
        # https://github.com/fish-shell/fish-shell/issues/583
        description = "Automatically list directory contents when navigating";
        onVariable = "PWD";
        body = "ls";
      };
      bind_bang = {
        # https://superuser.com/questions/719531/what-is-the-equivalent-of-bashs-and-in-the-fish-shell
        description = "Bring back !! from bash";
        body = ''
          switch (commandline -t)[-1]
            case "!"
              commandline -t $history[1]; commandline -f repaint
            case "*"
              commandline -i !
          end
        '';
      };
    };

    interactiveShellInit = ''
      # Explicitly source the event listener. https://github.com/fish-shell/fish-shell/issues/845
      cs

      # Add a line to my prompt?
      # https://github.com/pure-fish/pure/blob/master/conf.d/_pure_init.fish
      functions --query _pure_prompt_new_line

      function fish_user_key_bindings
        bind ! bind_bang
      end

      if not set -q TMUX
        tmux attach -t TMUX || tmux new -s TMUX
      end
    '';
  };

  programs.git = {
    enable = true;
    ignores = lib.splitString "\n" (builtins.readFile ./config/git/gitignore_global);
    extraConfig = { 
      init.defaultBranch = "main";
      pull.rebase = true;
      pull.ff = "only";
      push.autoSetupRemote = true;
      pager.diff = true;
      core.commentchar = "!";
      merge.conflictstyle = "diff3";
    };
  };

  programs.alacritty = {
    enable = true;
    # Install via Homebrew Cask for icon and better indexing behavior.
    # package = pkgs.runCommand "alacritty-0.0.0" {} "mkdir $out";
    # package = pkgs.alacritty.overrideAttrs (old: {
    # #   # https://github.com/NixOS/nixpkgs/issues/153304#issuecomment-1014422591
    #   doCheck = false;
    # });
    package = pkgs.alacritty;
    settings = {
      general.live_config_reload = true;

      # Window.
      window = {
        dynamic_title = true;
        padding = {
          x = 0;
          y = 0;
        };
        decorations = "Buttonless";
      };

      # Fonts.
      font = {
        size = 15.0; 
        offset.y = 2;
        normal = {
          family = "FiraCode Nerd Font";
          style = "Retina";
        };
        bold = {
          family = "FiraCode Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font";
          style = "Italic";
        };
      };

      # Colors.
      colors = {
        draw_bold_text_with_bright_colors = true;

        primary = {
          background = "0x1c1f22";
          foreground = "0xd1d8e0";
        };

        cursor = {
          text = "0xd1d8e0";
          cursor = "0xf9f9f3";
        };

        normal = {
          black   = "0x2d3135";
          red     = "0xc8233b";
          green   = "0xbfd269";
          yellow  = "0xf48a81";
          blue    = "0xffc850";
          magenta = "0x4ac0cf";
          cyan    = "0xfb8562";
          white   = "0xdde3e8";
        };

        bright = {
          black   = "0x494f54";
          red     = "0xed3855";
          green   = "0xdde7b3";
          yellow  = "0xfbd7d4";
          blue    = "0xffe5b4";
          magenta = "0x9cdae3";
          cyan    = "0xfdccbf";
          white   = "0xf7f7f9";
        };
      };

      # Need the full path to tmux to work when Alacritty is launched from the Dock
      # or Spotlight, rather than via the alacritty binary.
      keyboard.bindings = let tmux = "${lib.getBin pkgs.tmux}/bin/tmux"; in [
        # Alt+Left and Right to skip words.
        { key = "Right"; mods = "Alt"; chars = "\\u001bf"; }
        { key = "Left";  mods = "Alt"; chars = "\\u001bb"; }

        # tmux
        # As of Alacritty v13.0, the shift key must be incorporated into the `key`
        # as well as the `mods`, making `LBracket` into `{`.
        { key = "{"; mods = "Command|Shift"; 
          command = { program = tmux; args = ["previous-window"]; }; 
        }
        { key = "}"; mods = "Command|Shift";
          command = { program = tmux; args = ["next-window"]; }; 
        }
        { key = "LBracket"; mods = "Command"; 
          command = { program = tmux; args = ["select-pane" "-L"]; }; 
        }
        { key = "RBracket"; mods = "Command";
          command = { program = tmux; args = ["select-pane" "-R"]; }; 
        }
        { key = "T"; mods = "Command";
          command = { program = tmux; args = ["new-window"]; }; 
        }
        { key = "Return"; mods = "Command|Shift";
          command = { program = tmux; args = ["resize-pane" "-Z"]; }; 
        }
      ];
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--border"
      "--bind=alt-j:down,alt-k:up"
      "--ansi"
    ];
    defaultCommand = "rg --files --hidden --pretty --column --smart-case --glob '!^(Caches|\.git|\.npm)/*'";
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    mouse = true;
    terminal = "screen-256color"; # Terminal colors!
    escapeTime = 1; # Fix Vim escape latency.
    historyLimit = 10000;
    clock24 = true;
    keyMode = "vi";
    aggressiveResize = true; # Only downsize if a smaller client is looking at the same window. https://mutelight.org/practical-tmux#section-5
    extraConfig = ''
      # [24.11] Needed to fix a bug in tmux-sensible that clobbers the shell with /bin/sh.
      # https://github.com/nix-community/home-manager/issues/5952#issuecomment-2409056750
      set -gu default-command
      set -g default-shell "$SHELL"
    '';
  };

  programs.neovim = let 
    rainglow-vim = pkgs.vimUtils.buildVimPlugin {
      name = "rainglow-vim";
      src = pkgs.fetchFromGitHub {
        owner = "sliminality";
        repo = "rainglow-vim";
        rev = "2402956186b8e53355b88043b4c6e50213cb5ede";
        sha256 = "sha256-HOHlcrrUQp+0S4jOV/JknF2LM4KJO1vTrb5NI4FOp5g";
      };
    };
    everforest-vim = pkgs.vimUtils.buildVimPlugin {
      name = "everforest-vim";
      src = pkgs.fetchFromGitHub {
        owner = "sainnhe";
        repo = "everforest";
        rev = "fa0643b4b76acdaa2c320395575fc86daad7e712";
        sha256 = "sha256-aRgjHCoe0q1sZ2k0ge+vPkRMctLjzT0uhSALYoFWsgY=";
      };
    };
  in 
  {
    enable = true; 
    package = pkgs.neovim-unwrapped;
    withNodeJs = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      # Themes.
      ayu-vim
      everforest-vim
      rainglow-vim

      # Plugins.
      { plugin = ale;
        config = ''
          " Putting this up here so it gets inserted before plugin bindings.
          let mapleader=" "

          let g:ale_fix_on_save = 1
          let g:ale_completion_enabled = 1

          let g:ale_linters = {
          \ 'typescript': ['eslint', 'tsserver'],
          \ 'python': ['jedils', 'flake8'],
          \ }

          let g:ale_fixers = {
          \ 'javascript': ['eslint', 'prettier'],
          \ 'json': ['prettier'],
          \ 'python': ['black'],
          \ 'rust': ['rustfmt'],
          \ 'typescript': ['eslint', 'prettier'],
          \ 'typescriptreact': ['eslint', 'prettier'],
          \ }

          nmap <silent> [e   <Plug>(ale_previous_wrap)
          nmap <silent> ]e   <Plug>(ale_next_wrap)

          " These get remapped for FileTypes that don't have good ALE support.
          map <Leader>] <Plug>(ale_go_to_definition)
          map <Leader>[ <Plug>(ale_hover)
          map <Leader>[] :ALEFindReferences -relative<CR>

          " Language-specific settings
          let g:ale_python_flake8_options = '--max-line-length=88'
        '';
      }
      { plugin = auto-pairs;
        config = ''
          augroup AutoPairs
              autocmd!
              autocmd FileType latex,pandoc let b:AutoPairs = extend(g:AutoPairs, {'$': '$'})
              " Don't pair single quotes.
              autocmd FileType rust,racket,scheme,ocaml let b:AutoPairs = {
                  \ '(':')', 
                  \ '[':']',
                  \ '{':'}',
                  \ '"':'"',
                  \ '`':'`',
                  \ }
          augroup END
        '';
      }
      {
        plugin = cosco-vim;
        config = ''
          augroup AppendSemicolon
              autocmd!
              autocmd FileType rust,d,c,cpp,css nmap <silent> <Leader>; <Plug>(cosco-commaOrSemiColon)
              autocmd FileType rust,d,c,cpp,css imap <silent> <Leader>; <c-o><Plug>(cosco-commaOrSemiColon)
          augroup END
        '';
      }
      { plugin = fzf-vim;
        config = ''
          " Apply defaults to fzf#vim#grep. 
          command! -bang -nargs=* Rg
            \ call fzf#vim#grep(
            \   'rg --column --vimgrep --multiline --color=always '.shellescape(<q-args>), 1,
            \   fzf#vim#with_preview('right:40%'),
            \   <bang>0)

          let g:fzf_preview_window = ['right:40%']

          " Search files in current repo
          nnoremap <leader>p :GFiles<cr>
          " Search files in cwd
          nnoremap <leader>o :Files<cr>
          nnoremap <leader>c :Commands<cr>
          nnoremap <leader>bl :Buffers<CR>
        '';
      }
      fzfWrapper
      lightline-bufferline
      { plugin = lightline-vim;
        config = ''
          set showtabline=2  " Show buffers

          let g:lightline#bufferline#show_number = 1
          let g:lightline#bufferline#shorten_path = 1
          let g:lightline#bufferline#unnamed = '[No Name]'
          let g:lightline = {
                      \ 'colorscheme': 'powerline',
                      \ 'tabline': { 'left': [['buffers']], 'right': [['close']] },
                      \ 'component_expand': {'buffers': 'lightline#bufferline#buffers'},
                      \ 'component_type': {'buffers': 'tabsel'},
                      \ 'separator': { 'left': '', 'right': '' },
                      \ 'subseparator': { 'left': '', 'right': '' }
                      \ }
        '';
      }
      { plugin = nerdtree;
        config = ''
          let g:NERDTreeIgnore=[
              \ '\.DS_Store',
              \ '\.py[cd]$',
              \ '\~$', '\.swo$',
              \ '\.swp$',
              \ '^\.git$',
              \ '^\.hg$',
              \ '^\.svn$',
              \ '\.bzr$',
              \ 'node_modules',
              \ 'perseus\/\.\+\.css$'
              \ ]

          let g:NERDTreeShowHidden = 1
          let g:NERDTreeMouseMode = 2  " Single click to open directories
          let g:NERDTreeChDirMode = 2  " cwd when NERDTree root changes
          let g:NERDTreeQuitOnOpen = 1
          let g:NERDTreeWinSize = 30

          nnoremap <leader>e :NERDTreeToggle<CR>
        '';
      }
      { plugin = vim-commentary;
        config = ''
          augroup CommentStrings
              autocmd!
              autocmd FileType ocaml setlocal commentstring=(*\ %s\ *)
              autocmd FileType sql setlocal commentstring=--\ %s

              " Uncomment this when I figure out how to contextually change between
              " JSX and regular JS comments.
              autocmd FileType javascript.jsx setlocal commentstring={/*\ %s\ */}
          augroup END
        '';
      }
      vim-devicons
      {
        plugin = vim-dispatch;
        config = ''
          nnoremap <leader>b :Dispatch!<cr>
        '';
      }
      vim-fugitive
      { plugin = vim-gitgutter;
        config = ''
          let g:gitgutter_override_sign_column_highlight = 0
        '';
      } 
      vim-prettier
      { plugin = vim-surround;
        config = ''
          let g:surround_33 = "```\r```"
        '';
      }
      vim-rhubarb
      vim-tmux-navigator

      # Language support.
      { plugin = haskell-vim;
        config = ''
          let g:haskell_indent_where = 2
          let g:haskell_indent_guard = 2
        '';
      }
      rust-vim
      typescript-vim
      vim-javascript
      vim-jsx-typescript
      { plugin = vim-json;
        config = ''
          let g:vim_json_syntax_conceal = 0
        '';
      }
      vim-nix
      vim-pandoc
      vimtex
    ];
    extraConfig = builtins.readFile ./config/nvim/init.vim;
  };

  programs.firefox = {
    enable = true; 
    # Fake package, because it's managed by Homebrew.
    # https://shaunsingh.github.io/nix-darwin-dotfiles/#orgbdbe5e2
    package = pkgs.runCommand "firefox-0.0.0" {} "mkdir $out";
    profiles.slim = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        facebook-container
        darkreader
        react-devtools
        reddit-enhancement-suite
        reduxdevtools
        ublock-origin
        vimium
        notion-web-clipper
        remove-youtube-s-suggestions
        (buildFirefoxXpiAddon {
          pname = "mhct-mousehunt-helper";
          version = "22.12.8";
          addonId = "{801e5516-3311-4ee7-8185-7da12ffab807}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4040870/mhct_mousehunt_helper-22.12.8.xpi";
          sha256 = "sha256-nfbDvWwNZ+2gia7zwGN2VjxKCTny1dbIy5JMliM1uog=";
          meta = {};
        })
      ];
      id = 0;
      isDefault = true;

      # Leave commented unless it's a new install.
      # bookmarks = [
      #   {
      #     name = "toolbar";
      #     toolbar = true;
      #     bookmarks = [
      #       {
      #         name = "Notion";
      #         bookmarks = [
      #           {
      #             name = "Get current user";
      #             url = "javascript:(function() {console.log(__console.AppStore.state.currentUserStore.getValue())})()";
      #           }
      #           {
      #             name = "Get current space";
      #             url = "javascript:(function() {console.log(__console.AppStore.state.currentSpaceStore.getValue())})()";
      #           }
      #           {
      #             name = "Get collection schema";
      #             url = "javascript:(async function() { const parent = __console.AppStore.state.currentBlockStore.getParentCollectionStore(); console.log(parent.getValue().schema) })()";
      #           }
      #           {
      #             name = "Get selected text";
      #             url = "javascript:(function() {console.log(__console.SelectionStore.state.stores[0].getTitleValue())})()";
      #           }
      #           {
      #             name = "Get selected block";
      #             url = "javascript:(function() {console.log(__console.SelectionStore.state.stores[0].getValue())})()";
      #           }
      #           {
      #             name = "Get current page";
      #             url = "javascript:(function() {console.log(__console.AppStore.state.currentBlockStore.getValue())})()";
      #           }
      #         ];
      #       }
      #       {
      #         name = "Pencil";
      #         url = "javascript:(function()%7Bconst%20getStore%20%3D%20()%20%3D%3E%20%7Bconst%20root%20%3D%20__REACT_DEVTOOLS_GLOBAL_HOOK__%3F.getFiberRoots(1)%3F.values().next().value%3F.current%3Bif%20(!root)%20%7Bthrow%20new%20Error(%22Couldn't%20get%20React%20root%22)%3B%7Dconst%20go%20%3D%20node%20%3D%3E%20%7Bif%20(node.memoizedProps%3F.store%3F.dispatch)%20%7Breturn%20node.memoizedProps.store%3B%7D%20else%20if%20(node.child)%20%7Breturn%20go(node.child)%3B%7D%20else%20%7Bthrow%20new%20Error(%22No%20children%20remaining%2C%20either%20no%20store%20or%20need%20to%20search%20siblings%22)%3B%7D%7D%3Breturn%20go(root)%3B%7D%3Bconst%20handleKeyDown%20%3D%20store%20%3D%3E%20e%20%3D%3E%20%7Bconst%20shouldHandle%20%3D%20e.key%20%3D%3D%3D%20%22p%22%20%26%26%20e.ctrlKey%3Bconsole.log(%22handling%22)%3Bif%20(!shouldHandle)%20%7Breturn%3B%7D%20else%20%7Bstore.dispatch(%7Btype%3A%20%22crossword%2Ftoolbar%2FTOGGLE_PENCIL_MODE%22%2C%7D)%3B%7D%7D%3Btry%20%7Bif%20(window.__HAS_PENCIL_MODE_LISTENER__)%20%7Bconsole.log(%22Listener%20already%20bound%2C%20no-op%22)%7D%20else%20%7Bconst%20store%20%3D%20getStore()%3Bconst%20handler%20%3D%20handleKeyDown(store)%3Bdocument.addEventListener(%22keydown%22%2C%20handler)%3Bwindow.__HAS_PENCIL_MODE_LISTENER__%20%3D%20true%3Bconsole.log(%22Press%20Ctrl%2BP%20to%20toggle%20pencil%20mode%22)%3B%7D%7D%20catch%20(error)%20%7Bconsole.error(error)%3Bwindow.alert(error)%3B%7D%7D)()";
      #       }
      #     ];
      #   }
      # ];

      search = {
        force = true;
        default = "DuckDuckGo";
        engines = {
          "Amazon.com".metaData.hidden = true;
          "Bing".metaData.hidden = true;
          "DuckDuckGo".metaData.hidden = false;
          "eBay".metaData.hidden = true;
          "Google".metaData.hidden = true;
          "Wikipedia (en)".metaData.hidden = true;
        };
      };

      settings = {
        "browser.startup.page" = 3; # Open previous tabs.
        "extensions.activeThemeID" = "default-theme@mozilla.org"; # Used to be: "firefox-compact-dark@mozilla.org"

        # New tab page.
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false; # Pocket.
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false; # Recent activity.
        "browser.newtabpage.activity-stream.feeds.topsites" = false; # Shortcuts.
        "browser.newtabpage.activity-stream.showSearch" = false;

        # Clean up search bar.
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.shortcuts.bookmarks" = false;
        "browser.urlbar.shortcuts.history" = false;
        "browser.urlbar.shortcuts.tabs" = false;

        # Browser defaults.
        "browser.aboutConfig.showWarning" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.warnOnQuitShortcut" = false;
        "browser.uiCustomization.state" = builtins.toJSON {
          "placements" = {
            "widget-overflow-fixed-list" = [
              "_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action" # Vimium
              "_801e5516-3311-4ee7-8185-7da12ffab807_-browser-action" # MHCT
              "_contain-facebook-browser-action" # Facebook Container
              "ublock0_raymondhill_net-browser-action" # uBlock Origin
            ];
            "nav-bar" = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "urlbar-container"
              "downloads-button"
              # TODO: Switch this out depending on profile.
              "onepassword4_agilebits_com-browser-action"
              "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action" # 1Password Classic
              "_4b547b2c-e114-4344-9b70-09b2fe0785f3_-browser-action" # Notion Web Clipper
            ];
            "TabsToolbar" = [
              "tabbrowser-tabs"
              "new-tab-button"
            ];
            "PersonalToolbar" = ["personal-bookmarks"];
          };
          "seen" = [
            "save-to-pocket-button"
            "developer-button"
            "_react-devtools-browser-action"
            "_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action" # Vimium
            "_contain-facebook-browser-action"
            "ublock0_raymondhill_net-browser-action"
            "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action" # 1Password Classic
            "onepassword4_agilebits_com-browser-action" # 1Password
            "_21f1ba12-47e1-4a9b-ad4e-3a0260bbeb26_-browser-action" # Remove YouTube Suggestions
            "_801e5516-3311-4ee7-8185-7da12ffab807_-browser-action" # MHCT
            "_4b547b2c-e114-4344-9b70-09b2fe0785f3_-browser-action" # Notion Web Clipper
          ];
          "dirtyAreaCache" = [
            "nav-bar"
            "PersonalToolbar"
            "TabsToolbar"
            "widget-overflow-fixed-list"
          ];
          "currentVersion" = 17;
          "newElementCount" = 4;
        };

        # Privacy.
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "network.cookie.cookieBehavior" = 5;
        "browser.contentblocking.category" = "custom";
        "browser.contentblocking.fingerprinting.preferences.ui.enabled" = true;
        "browser.contentblocking.cryptomining.preferences.ui.enabled" = true;

        # Autofill.
        "signon.rememberSignons" = false;
      };
    };
  };

  # Additional dotfiles.
  home.file = {
    # https://github.com/gpakosz/.tmux
    tmux = {
      source = ./config/tmux/tmux.conf; 
      target = ".tmux.conf";
      recursive = true;
    };
    tmuxlocal = {
      source = ./config/tmux/tmux.conf.local; 
      target = ".tmux.conf.local";
      recursive = true;
    };
    pandocSimple = {
      source = ./config/pandoc/simple.latex;
      target = ".pandoc/templates/simple.latex";
      recursive = false;
    };
    npmrc = {
      source = ./config/npm/.npmrc;
      target = ".npmrc";
      recursive = false;
    };
    "Applications/home-manager".source = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in lib.mkIf pkgs.stdenv.targetPlatform.isDarwin "${apps}/Applications";
  };
}
