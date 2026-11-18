# vimrc

A modular **Vim 9** configuration that turns classic Vim into a fast, keyboard-first IDE:
file explorer, dashboard, fuzzy search, language servers, Git tools, snippets and a
floating terminal, all styled from one colour palette (Space Vim Dark by default).

It is plain Vimscript for Vim, not Neovim. It was built and tested on Ubuntu 24.04 with
Vim 9.1 in a true-colour terminal; other Linux setups should work but are untested.

```
┌─ explorer ───────────┬─ dashboard / your code ─────────────────────┬─ outline ───────────┐
│ ▾ my-project/        │  ██╗   ██╗██╗███╗   ███╗                     │ ╰─▸ Class           │
│   ▸ src/             │  Vim 9.1 · Space Vim Dark · 39 plugins      │   ╰─▸ Greeter:4     │
│     README.md        │  Recent files · Projects · Sessions · …     │ ╰─▸ Function        │
├──────────────────────┴─────────────────────────────────────────────┴─────────────────────┤
│ ( NORMAL )  main +2 ~1   app.py ●             ✘ 1 ▲ 2   pyright   python  utf-8   12:5   │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

<!-- Screenshots: add images to docs/screenshots/ and link them here. -->

## Features

- **Navigation:** fern explorer sidebar that opens at startup, Startify dashboard with
  recent files, projects and sessions, fzf pickers for files, buffers and history, live
  ripgrep search.
- **Code intelligence:** vim-lsp with completion, go to definition, references, rename,
  hover, code actions, diagnostics, a symbol outline, and VS Code-format snippets.
- **Git:** fugitive status/commit/blame/diff, gitgutter signs with hunk stage, undo and
  preview, a blame pop-up for the current line.
- **Editing:** persistent undo with an undo tree, surround, comments, auto-pairs, tag
  closing, extra text objects, live `:substitute` preview, system clipboard bridge.
- **Running code:** floating terminal, terminal panel, run-file, pytest, coverage and
  `make` keys with quickfix integration.
- **Discoverability:** every custom key is defined in one registry that generates the
  which-key menu, the in-editor help guide and the reference tables in the docs.
- **Self-checking:** `:VimHealth` reports what works and what is missing; a test suite
  (`tools/check.sh`) covers startup, mappings, themes and documentation.

Each module loads inside its own `try`, and a missing plugin, binary or font switches that
feature to a fallback, so Vim always starts.

## Themes

| Theme | Notes | Keys |
|---|---|---|
| Space Vim Dark | default; three background shades | `Space t R` restores it |
| Catppuccin Mocha | dark alternative | `Space t B` cycles |
| Catppuccin Latte | light alternative | `Space t b` toggles dark/light |

`Space t p` previews every installed colour scheme live and restores the original on
`Esc`. Status line, explorer, dashboard, pop-ups and terminal colours follow the theme.
The default is set with `g:my_theme` in `~/.vim/local.vim`.

## Plugins

39 plugins managed by [vim-plug](https://github.com/junegunn/vim-plug), pinned to exact
commits in `plug-snapshot.vim`. Highlights: vim-fern, vim-startify, fzf.vim, vim-lsp with
vim-lsp-settings, asyncomplete, vim-vsnip, vim-fugitive, vim-gitgutter, lightline,
vim-which-key, vista.vim, vim-surround, vim-commentary, lexima, undotree. The full list
with the reason for each is in the [guide](docs/GUIDE.md#d-plugin-guide).

## Language support

| Language | Language server | Formatting |
|---|---|---|
| Python | pyright (uses the project's virtualenv) | ruff, black or autopep8 when installed |
| JavaScript / TypeScript | typescript-language-server (inside a project) | prettier |
| C / C++ | clangd | clangd |
| Go | gopls | gofmt on save |
| Shell | bash-language-server (warnings need shellcheck) | shfmt when installed |
| YAML | yaml-language-server | language server |
| Svelte, HTML, CSS, JSON, Markdown | none configured | prettier |

Servers are installed per user by `tools/bootstrap.sh --lsp` or `:LspInstallServer`.
Haskell and Vim script get indentation settings only.

## AI integration

None is bundled, and the configuration sends nothing to any service. The
[guide](docs/GUIDE.md#ai-assistant) compares the options that work in classic Vim (Claude
Code in a terminal, copilot.vim, vim-ai, vim-ollama, llama.vim) and how to add one without
putting credentials in tracked files.

## Requirements

- Vim 9.0 or newer with `+popupwin`, `+terminal`, `+job` and `+timers` (a "huge" build)
- git and curl
- Recommended: [fzf](https://github.com/junegunn/fzf),
  [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd),
  Node.js (npm-based language servers and prettier), a
  [Nerd Font](https://www.nerdfonts.com/) for icons, `xclip` or `wl-clipboard`

Everything in the recommended list is optional; without it the related feature falls back
to a built-in equivalent or is reported by `:VimHealth`.

## Installation

Back up any existing configuration first.

```bash
[ -e ~/.vim ] && mv ~/.vim ~/.vim.bak
[ -e ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.bak

git clone https://github.com/azimhatami/vimrc.git ~/.vim

~/.vim/tools/bootstrap.sh          # plugins at the pinned commits
~/.vim/tools/bootstrap.sh --all    # also fzf, ripgrep, fd, icon font, language servers
~/.vim/tools/check.sh              # verify: startup, test suite, startup time
```

Vim reads `~/.vim/vimrc` on its own, so no `~/.vimrc` is needed. `bootstrap.sh` needs no
sudo, installs into `~/.local`, pins every download to a version and verifies its SHA-256
checksum. It currently downloads x86-64 Linux binaries.

## Main shortcuts

The leader key is `Space`. Press it and wait to see every group.

| Keys | Action |
|---|---|
| `Space Space` | Find a file in the project |
| `Space /` | Search text in the project |
| `Space e` | Toggle the file explorer |
| `Space b b` | Switch buffer |
| `gd` / `gr` / `K` | Definition / references / documentation |
| `Space c r` / `Space c a` | Rename symbol / code action |
| `Space c c` / `Space c f` | Toggle comment / format |
| `Space g g` | Git status |
| `]h` / `[h` | Next / previous Git hunk |
| `F12` | Floating terminal |
| `Space r r` / `Space r t` | Run file / run the test under the cursor |
| `Space t p` | Preview themes |
| `Space h c` | Help guide and complete cheat sheet |
| `Space h h` | Health check |

The complete reference, generated from the live configuration, is in
[docs/GUIDE.md](docs/GUIDE.md#c-complete-shortcut-reference).

## Customization

Copy `local.vim.example` to `local.vim` (ignored by git) to change the theme, background
shade, icons, dashboard, explorer width, format-on-save and other switches without
touching tracked files. Keys are defined in `config/mappings.vim`, plugins in
`config/plugins.vim`, colours in `autoload/my/ui.vim`. See the
[customization guide](docs/GUIDE.md#e-customization-guide).

## Layout

```
vimrc                 entry point; loads the modules below in order
config/               options, plugins, appearance, navigation, dashboard, editing,
                      git, lsp, languages, mappings, whichkey
autoload/my/          functions loaded on first use (theme, explorer, runners, help, health …)
autoload/plug.vim     vim-plug (vendored)
snippets/             personal snippets (VS Code format)
tools/                bootstrap.sh, check.sh, test.vim
docs/GUIDE.md         the full guide
plug-snapshot.vim     plugin lockfile
```

## License and attribution

[MIT](LICENSE) © Azim Hatami.

- `autoload/plug.vim` is [vim-plug](https://github.com/junegunn/vim-plug) by Junegunn
  Choi, MIT; its licence text is inside the file.
- The colour palettes in `autoload/my/ui.vim` reproduce the colours of
  [space-vim-dark](https://github.com/liuchengxu/space-vim-dark) by Liu-Cheng Xu (MIT) and
  [Catppuccin](https://github.com/catppuccin/vim) (MIT).
- Plugins are downloaded from their own repositories at install time and keep their own
  licences. Some ideas were adapted from [Wim](https://github.com/wolandark/wim); no code
  was copied from it.
