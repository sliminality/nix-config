# ~/.config/nixpkgs/home.nix

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

  # Allow unfree packages.
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.packages = with pkgs; [
    # Shell
    fishPlugins.pure

    # CLI utilities
    fasd
    ripgrep

    # Document preparation
    pandoc

    # Haskell
    haskellPackages.ghcup
    # haskellPackages.haskell-language-server

    # Rust
    rust-analyzer
    rustup
  ];

  # Environment variables.
  home.sessionVariables = {
    EDITOR = "vim";
  };

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
    };

    interactiveShellInit = ''
      # Explicitly source the event listener. https://github.com/fish-shell/fish-shell/issues/845
      cs

      if not set -q TMUX
        tmux attach -t TMUX || tmux new -s TMUX
      end
    '';
  };

  programs.git = {
    enable = true;
    userEmail = "slim@sarahlim.com";
    userName = "Slim Lim";
    extraConfig = { 
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty.overrideAttrs (old: {
      # https://github.com/NixOS/nixpkgs/issues/153304#issuecomment-1014422591
      doCheck = false;
    });
    settings = {
      live_config_reload = true;

      # Window.
      dynamic_title = true;
      window.padding = {
        x = 0;
        y = 0;
      };

      # Fonts.
      font = {
        size = 15.0; 
        offset.y = 2;
        normal = {
          family = "FuraCode Nerd Font";
          style = "Retina";
        };
        bold = {
          family = "FuraCode Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "FuraCode Nerd Font";
          style = "Italic";
        };
      };
      draw_bold_text_with_bright_colors = true;

      # Colors.
      colors = {
        primary = {
          background = "0x1c1f22";
          foreground = "0xd1d8e0";
        };

        cursor = {
          text = "0xd1d8e0";
          cursor = "0xf9f9f3";
          style = "Block";
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

      key_bindings = [
        # Alt+Left and Right to skip words.
        { key = "Right"; mods = "Alt"; chars = "\\x1bf"; }
        { key = "Left";  mods = "Alt"; chars = "\\x1bb"; }

        # tmux
        { key = "LBracket"; mods = "Command|Shift"; command = { program = "tmux"; args = ["previous-window"]; }; }
        { key = "RBracket"; mods = "Command|Shift"; command = { program = "tmux"; args = ["next-window"]; }; }
        { key = "T"; mods = "Command"; command = { program = "tmux"; args = ["new-window"]; }; }
        { key = "Return"; mods = "Command|Shift"; command = { program = "tmux"; args = ["resize-pane" "-Z"]; }; }
      ];
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--border"
      "--bind=alt-j:down,alt-k:up"
    ];
    defaultCommand = "rg --files --hidden --pretty --column --smart-case --glob '!.git/*' --glob '!^(Caches|\.npm)/*'";
  };

  programs.zsh = {
    enable = true;
    enableSyntaxHighlighting = true;
    enableCompletion = true;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    terminal = "screen-256color"; # Terminal colors!
    escapeTime = 1; # Fix Vim escape latency.
    historyLimit = 10000;
    clock24 = true;
  };

  programs.neovim = let rainglow-vim = pkgs.vimUtils.buildVimPlugin {
    name = "rainglow-vim";
    src = pkgs.fetchFromGitHub {
      owner = "sliminality";
      repo = "rainglow-vim";
      rev = "2402956186b8e53355b88043b4c6e50213cb5ede";
      sha256 = "sha256-HOHlcrrUQp+0S4jOV/JknF2LM4KJO1vTrb5NI4FOp5g";
    };
  }; in 
  {
    enable = true; 
    package = pkgs.neovim-unwrapped;
    withNodeJs = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      # Themes.
      ayu-vim
      rainglow-vim

      # Plugins.
      { plugin = ale;
        config = ''
          let g:ale_fix_on_save = 1
          let g:ale_completion_enabled = 1
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
      { plugin = fzf-vim;
        config = ''
          " Apply defaults to fzf#vim#grep. 
          command! -bang -nargs=* Rg
            \ call fzf#vim#grep(
            \   'rg --column --vimgrep --color=always '.shellescape(<q-args>), 1,
            \   fzf#vim#with_preview('right:40%'),
            \   <bang>0)

          nnoremap <leader>p :GFiles<cr>   " Search files in current repo
          nnoremap <leader>o :Files<cr>    " Search files in cwd
          nnoremap <leader>c :Commands<cr> " Search commands
          nnoremap <leader>bl :Buffers<CR> " Search open buffers and their status
        '';
      }
      { plugin = haskell-vim;
        config = ''
          let g:haskell_indent_where = 2
          let g:haskell_indent_guard = 2
        '';
      }
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
        '';
      }
      rust-vim
      typescript-vim
      vim-fugitive
      { plugin = vim-gitgutter;
        config = ''
          let g:gitgutter_override_sign_column_highlight = 0
        '';
      } 
      vim-tmux-navigator
      { plugin = vim-surround;
        config = ''
          let g:surround_33 = "```\r```"
        '';
      }
      { plugin = vim-commentary;
        config = ''
          augroup CommentStrings
              autocmd!
              autocmd FileType ocaml setlocal commentstring=(*\ %s\ *)
              autocmd FileType javascript.jsx setlocal commentstring={/*\ %s\ */}
              autocmd FileType sql setlocal commentstring=--\ %s
          augroup END
        '';
      }
      vim-javascript
      vim-jsx-typescript
      vim-json
      vim-nix
      vim-prettier
    ];
    extraConfig = ''
      """ Formatting

      set number          " Enable line numbers
      set wrap            " Wrap lines
      set nojoinspaces    " No double spaces after punctuation on join
      set autoindent      " Auto indent
      set expandtab       " Use spaces instead of tabs
      set smarttab        " Be smart when using tabs
      set shiftwidth=4    " 1 tab == 4 spaces
      set softtabstop=4
      set tabstop=4

      filetype plugin indent on   " Auto detect filetypes

      """ UI

      syntax enable       " Enable syntax highlighting
      set lazyredraw      " Make rendering performance better
      set nospell         " Disable spellcheck
      set incsearch       " Find as you type search
      set hlsearch        " Highlight found search results
      set ignorecase      " Case insensitive search
      set smartcase       " Case sensitive when uc present
      set wildmenu        " Show list instead of just completing

      set mouse=a         " Automatically enable mouse usage
      set mousehide       " Hide the mouse cursor while typing

      " Stop automatically inserting new comment leaders.
      augroup commentgroup
          autocmd!
          autocmd FileType * set fo-=r fo-=c fo-=o
      augroup END
      
      set splitbelow        " Open new splits to the right and below
      set splitright
      set fillchars+=vert:\ " Remove | char from vertical splits

      " Make matched parens visually distinct from cursor
      highlight MatchParen gui=underline guifg=NONE guibg=NONE  

      color rainbow-contrast

      set termguicolors      " Nice colors

      " Force true colors on, so Vim can detect within tmux.
      " let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum""]"
      " let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum""]"
      " set t_Co=256
      " set t_ut=

      """ Editing

      set autoread                     " Autoread when a file is changed externally
      set backspace=indent,eol,start   " Backspace for dummies
      set scrolljump=5                 " Lines to scroll when cursor leaves screen
      set scrolloff=10                 " Minimum lines to keep above and below cursor

      set iskeyword-=.                 " '.' delimits words
      set iskeyword-=#                 " '#' delimits words
      set iskeyword-=-                 " '-' delimits words

      " Command <Tab> completion, list matches, then longest common part, then all.
      set wildmode=list:longest,full

      " Enable persistent undo across buffers and sessions
      try
          set undodir=~/.vim_runtime/temp_dirs/undodir
          set undofile
          set undolevels=1000
          set undoreload=10000
      catch
      endtry

      " Return to last edit position when opening files
      augroup SaveEditPosition
          autocmd!
          autocmd BufReadPost *
               \ if line("'\"") > 0 && line("'\"") <= line("$") |
               \   exe "normal! g`\"" |
               \ endif
      augroup END

      """ Mapping

      let mapleader=" "   " Leader key to space

      noremap j gj        " Navigate wrapped lines
      noremap k gk

      " Move lines around easily
      nnoremap <leader>k :m-2<cr>==
      nnoremap <leader>j :m+<cr>==
      xnoremap <leader>k :m-2<cr>gv=gv
      xnoremap <leader>j :m'>+<cr>gv=gv

      " Find merge conflict markers
      noremap <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

      vnoremap < <gv             " Shift without exiting Visual mode
      vnoremap > >gv
      vnoremap . :normal .<CR>   " Repeat visual selections http://stackoverflow.com/a/8064607/127816
      xnoremap p "_dP            " Re-select and re-yank text pasted in visual mode.  https://stackoverflow.com/a/5093286
      
      nmap <leader>T :enew<CR>           " Open new empty buffer
      nmap <leader>l :bnext<CR>          " Next buffer
      nmap <leader>h :bprevious<CR>      " Previous buffer
      nmap <leader>w :bp <BAR> bd #<CR>  " Close buffer
      nmap <leader>W :bdelete!<CR>       " Really close buffer

      vnoremap <C-c> "*y                 " Copy to system clipboard
      command! Path let @* = expand("%") " Pull path into system clipboard

      " List syntax highlight groups under cursor
      nnoremap <leader>sp :call <SID>SynStack()<CR>
      function! <SID>SynStack()
        if !exists("*synstack")
          return
        endif
        echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
      endfunc

    '';
  };

  programs.firefox = {
    enable = true; 
    # Fake package, because it's managed by Homebrew.
    # https://shaunsingh.github.io/nix-darwin-dotfiles/#orgbdbe5e2
    package = pkgs.runCommand "firefox-0.0.0" {} "mkdir $out";
    profiles.slim = {
      isDefault = true;
      settings = {
        "browser.startup.page" = 3; # Open previous tabs.
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

        # New tab page.
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false; # Pocket.
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false; # Recent activity.
        "browser.newtabpage.activity-stream.feeds.topsites" = false; # Shortcuts.
        "browser.newtabpage.activity-stream.showSearch" = false;

        # Clean up search bar.
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.search.hiddenOneOffs" = "Amazon.com,Bing,DuckDuckGo,eBay,Google,Wikipedia (en)";
        "browser.urlbar.shortcuts.bookmarks" = false;
        "browser.urlbar.shortcuts.history" = false;
        "browser.urlbar.shortcuts.tabs" = false;

        # Browser defaults.
        "browser.aboutConfig.showWarning" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.warnOnQuitShortcut" = false;
        "browser.uiCustomization.state" = builtins.toJSON {
          "placements" = {
            "widget-overflow-fixed-list" = [];
            "nav-bar" = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "urlbar-container"
              "downloads-button"
              "fxa-toolbar-menu-button"
            ];
            "TabsToolbar" = [
              "tabbrowser-tabs"
              "new-tab-button"
              "alltabs-button"
            ];
            "PersonalToolbar" = ["personal-bookmarks"];
          };
          "seen" = [
            "save-to-pocket-button"
            "developer-button"
          ];
          "dirtyAreaCache" = [
            "nav-bar"
            "PersonalToolbar"
            "TabsToolbar"
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
      source = ./tmux/tmux.conf; 
      target = ".tmux.conf";
      recursive = true;
    };
    tmuxlocal = {
      source = ./tmux/tmux.conf.local; 
      target = ".tmux.conf.local";
      recursive = true;
    };
  };
}
