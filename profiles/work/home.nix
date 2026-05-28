# Home Manager configuration for my work machine.
# Anything that shouldn't go on every fresh install goes here.

{ config, pkgs, lib, claude-code-nix, ... }:

{
  imports = [
    ../../home.common.nix
  ];

  home.packages = with pkgs; [
    # (import ../../darwin-modules/apps/notion-dev.nix { inherit lib stdenv pkgs; })
    # (import ../../darwin-modules/apps/n.nix { inherit lib stdenv pkgs; })

    claude-code-nix.packages.aarch64-darwin.default

    docker-client # Make sure `docker` CLI is in the PATH
    gh
    rustup

    # tsserverNode shim for work. Used by ALE below.
    (writeShellScriptBin "tsserverNode" ''
      #!/bin/sh
      $HOME/git/notion-next/src/cli/tsserverNode $PWD/node_modules/.bin/tsserver
    '')

    # tsgoNode shim for work. Used by ALE below.
    # Invokes the current worktree's tsgo binary directly, bypassing the
    # notion-next tsgo wrapper (which wraps with a Node metrics proxy that
    # requires brew/yq on PATH and isn't worth running through for LSP use).
    (writeShellScriptBin "tsgoNode" ''
      #!/bin/sh
      exec "$PWD/node_modules/.bin/tsgo" "$@"
    '')
  ];

  home.sessionVariables = {
    NOTION_NO_PRECOMMIT = "true";
    NOTION_NO_PREPUSH = "true";
  };

  home.sessionPath = lib.mkAfter [
    # Include new global install location, set in .npmrc
    "$HOME/.npm-global/bin"
    "$HOME/git/notion-next/src/cli"
    # Pick up extra docker CLI tools, like docker-compose, docker-credential-desktop, docker-credential-ecr-login, docker-credential-osxkeychain
    # We install Docker Desktop itself via Brew, so need this symlink.
    "/Applications/Docker.app/Contents/Resources/bin"
  ];

  programs.git = {
    userEmail = "slim@makenotion.com";
    userName = "Slim Lim";

    extraConfig = {
      rerere.enabled = true;

      # Make `git status` faster.
      core.untrackedCache = true;
      core.fsmonitor = true;
    };
  };

  programs.firefox.profiles.slim = {
    extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
      onepassword-password-manager
    ];

    # bookmarks = [
    #   {
    #     name = "old pulls";
    #     url = "https://github.com/makenotion/notion-next/pulls?q=is%3Apr+author%3Asliminality+is%3Aclosed";
    #   }
    #   {
    #     name = "to review";
    #     url = "https://github.com/makenotion/notion-next/pulls?q=is%3Apr+is%3Aopen+user-review-requested%3A%40me";
    #   }
    # ];
  };

  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-terraform
    ];

    extraConfig = ''
      " Work-specific ALE settings.
      let g:ale_typescript_tsserver_use_global = 1
      let g:ale_typescript_tsserver_executable = 'tsserverNode'"

      " Register tsgo (Go-based TypeScript LSP) as an ALE linter. `tsgoNode`
      " is the shim defined alongside this profile's home.packages.
      function! TsgoProjectRoot(buffer) abort
        let l:tsconfig = ale#path#FindNearestFile(a:buffer, 'tsconfig.json')
        return !empty(l:tsconfig) ? fnamemodify(l:tsconfig, ':h') : '''
      endfunction

      " tsgo requires initializationOptions to be a JSON object. ALE's lua
      " bridge to Neovim's built-in LSP API strips the dict-marker that Vim
      " adds when crossing into Lua, so an empty Vim dict ends up serialized
      " as a JSON array []. Sending a non-empty dict avoids that ambiguity.
      let s:tsgo_init_options = {'hostInfo': 'nvim-ale'}

      call ale#linter#Define('typescript', {
      \   'name': 'tsgo',
      \   'lsp': 'stdio',
      \   'executable': 'tsgoNode',
      \   'command': '%e --lsp --stdio',
      \   'project_root': function('TsgoProjectRoot'),
      \   'initialization_options': s:tsgo_init_options,
      \   'language': 'typescript',
      \ })
      call ale#linter#Define('typescriptreact', {
      \   'name': 'tsgo',
      \   'lsp': 'stdio',
      \   'executable': 'tsgoNode',
      \   'command': '%e --lsp --stdio',
      \   'project_root': function('TsgoProjectRoot'),
      \   'initialization_options': s:tsgo_init_options,
      \   'language': 'typescriptreact',
      \ })

      " For TS files: use tsgo if the project has it, otherwise fall back to
      " tsserver. Decided per-buffer via b:ale_linters, since whether tsgo is
      " installed depends on the worktree/branch (older branches predate it).
      function! s:PickTsLinter() abort
        let l:tsgo = findfile('node_modules/.bin/tsgo', expand('%:p:h') . ';')
        let b:ale_linters = !empty(l:tsgo)
        \   ? ['eslint', 'tsgo']
        \   : ['eslint', 'tsserver']
      endfunction

      augroup AlePickTsLinter
        autocmd!
        autocmd FileType typescript,typescriptreact call s:PickTsLinter()
      augroup END

      " Default linters for filetypes without per-buffer overrides.
      let g:ale_linters = {
      \ 'typescript':      ['eslint', 'tsserver'],
      \ 'typescriptreact': ['eslint', 'tsserver'],
      \ 'python':          ['jedils', 'flake8'],
      \ }

      let g:ale_fixers = {
      \ 'javascript': ['eslint', 'biome'],
      \ 'json': ['prettier'],
      \ 'python': ['black'],
      \ 'rust': ['rustfmt'],
      \ 'typescript': ['eslint', 'biome'],
      \ 'typescriptreact': ['eslint', 'biome'],
      \ }
    '';
  };

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        github.copilot
        esbenp.prettier-vscode
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "ayu";
          publisher = "teabyii";
          version = "1.0.5";
          sha256 = "sha256-+IFqgWliKr+qjBLmQlzF44XNbN7Br5a119v9WAnZOu4=";
        }
        {
          name = "copilot-chat";
          publisher = "GitHub";
          version = "0.9.2023101202";
          sha256 = "sha256-DZnWNwmpNWHYMR3ycGyidyOPWSeJ0OMRFbjjnFj4oNo=";
        }
      ];
      userSettings = {
        workbench.colorTheme = "Ayu Mirage Bordered";
        github.copilot = {
          inlineSuggest.enable = false;
          enable = {
            "*" = true;
            yaml = false;
            plaintext = false;
            markdown = false;
          };
        };
      };
    };
  };
}
