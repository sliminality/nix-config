" Work-specific ALE settings.
let g:ale_typescript_tsserver_use_global = 1
let g:ale_typescript_tsserver_executable = 'tsserverNode'"

" Register tsgo (Go-based TypeScript LSP) as an ALE linter. `tsgoNode`
" is the shim defined alongside this profile's home.packages.
function! TsgoProjectRoot(buffer) abort
  let l:tsconfig = ale#path#FindNearestFile(a:buffer, 'tsconfig.json')
  return !empty(l:tsconfig) ? fnamemodify(l:tsconfig, ':h') : ''
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
  let l:relpath = substitute(l:file, '^' . escape(l:root, '\') . '/', '', '')

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
