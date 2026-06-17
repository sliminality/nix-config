# Home Manager configuration for my work machine.
# Anything that shouldn't go on every fresh install goes here.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../home.common.nix
  ];

  home.packages = with pkgs; [
    # (import ../../darwin-modules/apps/notion-dev.nix { inherit lib stdenv pkgs; })
    # (import ../../darwin-modules/apps/n.nix { inherit lib stdenv pkgs; })

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

      " For TS files: use tsgo if the project has it, else fall back to
      " tsserver. Each buffer checks this via b:ale_linters.
      "
      " Can set g:force_tsserver = 1 (or run :Tsserver) to skip tsgo when it
      " segfaults too much lol
      if !exists('g:force_tsserver')
        let g:force_tsserver = 0
      endif

      function! s:PickTsLinter() abort
        if g:force_tsserver
          let b:ale_linters = ['eslint', 'tsserver']
          return
        endif
        let l:tsgo = findfile('node_modules/.bin/tsgo', expand('%:p:h') . ';')
        let b:ale_linters = !empty(l:tsgo)
        \   ? ['eslint', 'tsgo']
        \   : ['eslint', 'tsserver']
      endfunction

      augroup AlePickTsLinter
        autocmd!
        autocmd FileType typescript,typescriptreact call s:PickTsLinter()
      augroup END

      " :Tsserver / :Tsgo toggles LSP choice mid-session.
      " Set global flag, stop any running LSPs, re-apply picker to the current buffer.
      function! s:SwitchTsLSP(use_tsserver) abort
        let g:force_tsserver = a:use_tsserver
        if exists(':ALEStopAllLSPs')
          ALEStopAllLSPs
        endif
        call s:PickTsLinter()
        " Re-run linting so the new server picks the buffer up.
        ALELint
        echo a:use_tsserver ? 'TS LSP: tsserver' : 'TS LSP: tsgo (when available)'
      endfunction
      command! Tsserver call s:SwitchTsLSP(1)
      command! Tsgo     call s:SwitchTsLSP(0)

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

      " :Gh — copy a GitHub permalink for the current file:line to the clipboard.
      " Resolves the current file's blob SHA via `git ls-tree HEAD`, so the link
      " pins to the exact content. Falls back to an error if the file isn't tracked
      " or any git lookup fails.
      command! Gh call s:GhPermalink()

      function! s:GhPermalink() abort
        let l:file = expand('%:p')
        if empty(l:file) || !filereadable(l:file)
          echohl ErrorMsg | echo 'Gh: no file in current buffer' | echohl None
          return
        endif

        " Resolve the repo root and the file's path relative to it.
        let l:root = trim(system('git -C ' . shellescape(fnamemodify(l:file, ':h')) . ' rev-parse --show-toplevel'))
        if v:shell_error || empty(l:root)
          echohl ErrorMsg | echo 'Gh: not a git repository' | echohl None
          return
        endif
        let l:relpath = substitute(l:file, '^' . escape(l:root, '\') . '/', ''', ''')

        " Get the commit SHA where this file was last touched on origin/main.
        " Using log -1 ensures we pin to a commit that's actually on main and
        " contains this file, rather than the current local HEAD.
        let l:sha = trim(system('git -C ' . shellescape(l:root) . ' log -1 --format=%H origin/main -- ' . shellescape(l:relpath)))
        if v:shell_error || empty(l:sha)
          echohl ErrorMsg | echo 'Gh: file not found on origin/main (or main not fetched)' | echohl None
          return
        endif

        " Sanity check: file exists at that commit.
        call system('git -C ' . shellescape(l:root) . ' cat-file -e ' . l:sha . ':' . l:relpath)
        if v:shell_error
          echohl ErrorMsg | echo 'Gh: file no longer present at resolved commit' | echohl None
          return
        endif

        let l:line = line('.')
        let l:url = 'https://github.com/makenotion/notion-next/blob/' . l:sha . '/' . l:relpath . '#L' . l:line

        let @* = l:url
        let @+ = l:url
        echo 'Gh: ' . l:url
      endfunction
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
