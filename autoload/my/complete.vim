" ==============================================================================
"  my#complete — insert-mode keys shared by completion and auto-pairs
" ==============================================================================

" <CR>:  item selected in the menu → accept it
"        menu open, nothing selected → close menu AND insert a newline
"        otherwise → lexima's newline (expands {|} into an indented block)
function! my#complete#cr() abort
  if pumvisible()
    if complete_info(['selected']).selected != -1
      return "\<C-y>"
    endif
    return "\<C-e>" . s:newline()
  endif
  return s:newline()
endfunction

function! s:newline() abort
  return exists('*lexima#expand') ? lexima#expand('<CR>', 'i') : "\<CR>"
endfunction

function! my#complete#map_cr() abort
  inoremap <silent><expr> <CR> my#complete#cr()
endfunction

" Code formatting: prettier for web languages (when prettier is available),
" the language server when it supports formatting, otherwise Vim's = operator.
function! s:lsp_can_format() abort
  for l:srv in lsp#get_allowed_servers()
    if lsp#capabilities#has_document_formatting_provider(l:srv) | return 1 | endif
  endfor
  return 0
endfunction

function! my#complete#format(visual) abort
  let l:prettier_ft = ['javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'css',
        \ 'scss', 'less', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html']
  if index(l:prettier_ft, &filetype) >= 0 && exists(':Prettier') == 2
    execute (a:visual ? "'<,'>" : '') . 'Prettier'
    return
  endif
  " Dedicated formatters first (the project's virtualenv, then $PATH):
  " Python → ruff / black / autopep8, shell → shfmt. pyright cannot format.
  let l:tw = &textwidth ? &textwidth : 79
  let l:tools = {
        \ 'python': [['ruff', 'format --quiet --line-length ' . l:tw . ' -'], ['black', '--quiet --line-length ' . l:tw . ' -'],
        \             ['autopep8', '--max-line-length ' . l:tw . ' -']],
        \ 'sh': [['shfmt', '-i ' . shiftwidth() . ' -ci']], 'bash': [['shfmt', '-i ' . shiftwidth() . ' -ci']] }
  for [l:exe, l:args] in get(l:tools, &filetype, [])
    let l:bin = &filetype ==# 'python' ? fnamemodify(my#run#python(), ':h') . '/' . l:exe : ''
    let l:bin = executable(l:bin) ? l:bin : exepath(l:exe)
    if empty(l:bin) | continue | endif
    let l:view = winsaveview()
    let [l:first, l:last] = a:visual ? [line("'<"), line("'>")] : [1, line('$')]
    let l:out = systemlist(shellescape(l:bin) . ' ' . l:args, getline(l:first, l:last))
    if v:shell_error
      echohl WarningMsg | echo l:exe . ' failed: ' . get(l:out, 0, '') | echohl None
    elseif l:out !=# getline(l:first, l:last)
      " Replace only the formatted lines (one undo step, marks elsewhere kept).
      silent execute l:first . ',' . l:last . 'delete _'
      call append(l:first - 1, l:out)
      echo 'Formatted with ' . l:exe
    else
      echo 'Already formatted (' . l:exe . ')'
    endif
    call winrestview(l:view)
    return
  endfor
  if get(b:, 'my_lsp_attached', 0) && s:lsp_can_format()
    execute a:visual ? "'<,'>LspDocumentRangeFormatSync" : 'LspDocumentFormatSync'
    return
  endif
  let l:view = winsaveview()
  execute 'normal! ' . (a:visual ? 'gv=' : 'gg=G')
  call winrestview(l:view)
  echo 'Formatted with Vim indent rules (no formatter for ' . (empty(&filetype) ? 'this buffer' : &filetype) . ')'
endfunction

" Scroll an LSP hover/signature pop-up if one is visible, else pass the key.
function! my#complete#scroll(count, key) abort
  let l:visible = filter(popup_list(), {_, id -> get(popup_getpos(id), 'visible', 0)})
  return empty(l:visible) || !exists('*lsp#scroll') ? a:key : lsp#scroll(a:count)
endfunction

function! my#complete#toggle_virtual_text() abort
  let g:lsp_diagnostics_virtual_text_enabled = !g:lsp_diagnostics_virtual_text_enabled
  if g:lsp_diagnostics_virtual_text_enabled
    call lsp#internal#diagnostics#virtual_text#_enable()
  else
    call lsp#internal#diagnostics#virtual_text#_disable()
  endif
  echo 'Inline diagnostics: ' . (g:lsp_diagnostics_virtual_text_enabled ? 'on' : 'off')
endfunction

" asyncomplete preprocessor: same fuzzy matching as the default, plus
"   • language-server items first, then file paths, then buffer words
"   • drop candidates identical to what you already typed (buffer echo)
let s:rank = {'file': 1, 'buffer': 2}
function! my#complete#preprocess(options, matches) abort
  let l:groups = []
  let l:startcols = []
  for [l:source, l:m] in items(a:matches)
    let l:startcol = l:m['startcol']
    let l:base = a:options['typed'][l:startcol - 1 :]
    let l:cands = empty(l:base) ? l:m['items']
          \ : exists('*matchfuzzypos') ? matchfuzzypos(l:m['items'], l:base, {'key': 'word'})[0]
          \ : filter(copy(l:m['items']), 'stridx(v:val.word, l:base) == 0')
    call filter(l:cands, 'v:val.word !=# l:base')
    if !empty(l:cands)
      call add(l:groups, [get(s:rank, l:source, 0), l:cands])
      call add(l:startcols, l:startcol)
    endif
  endfor
  let l:items = []
  for [l:_, l:cands] in sort(l:groups, {a, b -> a[0] - b[0]})
    call extend(l:items, l:cands)
  endfor
  let a:options['startcol'] = empty(l:startcols) ? col('.') : min(l:startcols)
  call asyncomplete#preprocess_complete(a:options, l:items)
endfunction
