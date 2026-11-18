" ==============================================================================
"  my#lsp — dynamic language-server settings
" ==============================================================================

" pyright: analysis options + the project's interpreter (virtualenv aware).
function! my#lsp#pyright_settings() abort
  let l:py = my#run#python()
  let l:settings = { 'python': { 'analysis': {
        \ 'typeCheckingMode': 'basic', 'autoSearchPaths': v:true,
        \ 'useLibraryCodeForTypes': v:true, 'diagnosticMode': 'openFilesOnly' } } }
  if l:py !=# 'python3'
    let l:settings.python.pythonPath = l:py
  endif
  return l:settings
endfunction
