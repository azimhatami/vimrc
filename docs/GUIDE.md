# Vim — a quiet, fast, keyboard-first IDE: the full guide

> This is the complete reference for the configuration (short overview:
> [`README.md`](../README.md)). Inside Vim, `Space h r` opens this file and `Space h c`
> opens the built-in help guide.

A modular **Vim 9** configuration, developed and tested on Ubuntu 24.04 in a true-colour
terminal. It aims to feel like a premium editor while keeping Vim's speed: on the
development machine plain `vim` draws the full workspace (explorer, dashboard, status
line) in about 170 ms (about 80 ms before the UI). It uses one colour palette everywhere (**Space Vim Dark** by default), and every
key is grouped, discoverable and documented.

```
┌─ explorer (30 cols) ─┬─ dashboard / your code ─────────────────────┬─ outline (Space l o) ┐
│ ▾ my-project/        │  ██╗   ██╗██╗███╗   ███╗                     │ ╰─▸ Class            │
│   ▸ src/      [ -]   │  Vim 9.1 · Space Vim Dark · ready in 170 ms │   ╰─▸ Greeter:4      │
│     README.md [??]   │  Recent in this project · Projects · …      │ ╰─▸ Function         │
├──────────────────────┴─────────────────────────────────────────────┴──────────────────────┤
│ ( NORMAL )  main +2 ~1   app.py ●             ✘ 1 ▲ 2   pyright   python  utf-8   12:5    │
└───────────────────────────────────────────────────────────────────────────────────────────┘
```

> **Leader key = `Space`.** Press `Space` and pause: a menu shows every group.
> `Space h c` opens the help guide (topics, cheat sheet, themes, languages, AI status) inside
> Vim, and `Space h h` runs a health check.

---

## Contents

- [A. Overview](#a-overview)
- [B. Installation & requirements](#b-installation--requirements)
- [C. Complete shortcut reference](#c-complete-shortcut-reference)
- [D. Plugin guide](#d-plugin-guide)
- [E. Customization guide](#e-customization-guide)
- [F. Maintenance guide](#f-maintenance-guide)
- [G. Troubleshooting](#g-troubleshooting)
- [AI assistant](#ai-assistant)

---

## A. Overview

### Philosophy

- **One idea per key group.** `Space f` finds, `Space g` is git, `Space l` is the
  language server. Native Vim keys keep their meaning unless there is a strong reason;
  every override is listed in section C.
- **Built-ins first.** Indent guides are drawn with `listchars` (no plugin, no conceal).
  The clipboard bridge, sessions, blame pop-up, zoom, terminal panel and large-file mode
  are small pieces of Vimscript, not extra plugins.
- **Fail soft.** Each module loads inside its own `try`. A missing plugin, binary or
  font switches that feature to a fallback; it never stops Vim from starting.
  The configuration also starts with *no* plugins and *no* fzf/ripgrep installed.
- **Documentation is generated.** Every mapping is defined through a registry
  (`my#keys#map`), and the which-key menu, `:Cheatsheet` and the tables in section C are
  produced from it. The test suite fails if this guide drifts from the real mappings.

### Main features

| Area | What you get |
|---|---|
| Look | **Space Vim Dark** (default) or Catppuccin **Mocha** / **Latte**, with ~120 palette-driven highlight overrides shared by the status line, explorer, dashboard, fzf, pop-ups, git signs and diagnostics |
| Status line | lightline: mode pill · branch + hunk counts · file icon + path · diagnostics · active LSP · filetype · encoding · position |
| Buffer line | numbered buffers (`Space 1…9`), modified dots, working directory, tab counter |
| Navigation | fzf pop-ups (files, live grep, buffers, history, symbols, commits), an always-visible fern project sidebar (opens by itself at startup) with git badges and icons, a start screen with recent files/projects/sessions, and an LSP symbol outline sidebar |
| Code intelligence | vim-lsp: completion, go to definition/declaration/implementation/type, references, hover, rename, code actions, diagnostics, formatting, signature help, symbol outline; VS Code-style snippets (vim-vsnip) that also expand LSP snippet completions |
| Git | fugitive status/commit/blame/diff, gitgutter signs, hunk stage/undo/preview/text objects, a blame pop-up for the current line |
| Editing | auto-pairs, auto-closing HTML/Svelte/JSX tags, surround, comments, better text objects, live `:s` preview, undo tree, persistent undo, system clipboard, trailing-whitespace highlight, yank flash, file commands (`:Rename`, `:Chmod`…) |
| Workflow | terminal panel + floating terminal (`F12`), run/test/build keys (pytest under the cursor using the project's virtualenv, coverage, make, Makefile target picker, re-run last, make flash with confirmation), per-directory sessions, zen mode |

### Startup experience

Like an IDE, the file tree opens **by itself
on the left every time Vim starts**, showing the directory you launched Vim from. The
cursor stays in the editor, so you can start typing straight away. When you start Vim
**without files**, the editor side shows a **dashboard** instead of an empty buffer.

```
┌───────────── 30 cols ┬──────────────────────────────────────────────┐
│ ▾ my-project/        │ `vim`       → dashboard (recent files, …)    │
│   ▸ src/             │ `vim file`  → the file                       │
│     README.md        │  ← the cursor is here after startup          │
└──────────────────────┴──────────────────────────────────────────────┘
```

| You run | You get |
|---|---|
| `vim` | sidebar on the current directory + the dashboard |
| `vim src/app.py` | sidebar on the current directory, the file on the right, its tree node revealed |
| `vim a.py b.py`, `vim -O a.py b.py`, `vim +42 a.py` | the same; splits stay to the right of the sidebar |
| `vim ~/code/other-project/` (or `vim .`) | Vim `cd`s into that directory (it becomes the project, like `code dir`), sidebar on it, empty editor on the right |
| `vim -S session.vim`, `Space q l` | the saved layout, with the sidebar back on the left |

**Keys:** `Space e` (or `Ctrl-n`) hides/shows it; showing it moves the cursor
into the tree. `Space E` opens it with the cursor on the current file. Inside the tree,
`q` hides it and `?` lists every action (full list under *Explorer (fern)* in section C).
`Ctrl-h` / `Ctrl-l` hop between the tree and the code.

**When it stays closed** (so special sessions are not disturbed). `Space e` still opens it
by hand in any of these:

- batch / Ex mode: `vim -e`, `-es`, `-Es`, or output/input that is not a terminal
- `… | vim -` (reading stdin), `vim -d` / `vimdiff`, `vim -b`, `vim -s script`, `vim -y`
- git commit messages, rebase todo lists, tag messages and any file inside `.git/`
  (`gitcommit`, `gitrebase`, `hgcommit`, `svn`, `mail`, `crontab`, `sudoers`, `man`… file types)
- temp files handed over by other programs (`crontab -e`, `sudoedit`, bash `Ctrl-X Ctrl-E`,
  `kubectl edit`, mutt…): a file under `/tmp`, `/var/tmp`, `/dev/shm`, `/run/user` or
  `$TMPDIR` that is *outside* your current directory
- remote files (`vim scp://…`), tool windows started from the command line (`vim +PlugUpdate`)
- terminals narrower than 80 columns (30 for the tree + 50 for code)

`:echo g:my_explorer_autostart_skipped` tells you why it did not open (empty = it opened).

**Closing never surprises you.**

- `:q`, `:wq`, `:x` or `ZZ` in the last editor window closes the sidebar along with it,
  so Vim (or that tab) closes exactly as if there were no sidebar. No `:qa` needed.
- If that quit is refused (unsaved changes `E37`, more files to edit `E173`), Vim stays
  and the sidebar comes back.
- Closing *only* the explorer (`q`, `Space e`, `:q` inside it) never quits Vim.
- Closing the editor some other way (`:bd`, `Space b d`, `:close`, `Ctrl-w c`, `:only`
  inside the tree) never leaves a lone tree: an empty editor opens on the right instead.

**Never twice.** Only one sidebar per tab: startup, `Space e`, `Space E`, sessions and a
failed quit all reuse an existing one.

**Sessions.** `Space q s` (`:SessionSave`) leaves the sidebar out of the session file
(tree buffers can't be restored) and puts it straight back. Loading a session
(`vim -S`, `Space q l`) restores your splits and then re-adds the sidebar in the current
tab, using the session's directory. Sessions made with plain `:mksession` work too.

**Settings** (in `~/.vim/local.vim`, see [feature switches](#feature-switches-vimlocalvim)):
`let g:my_explorer_autostart = 0` turns auto-opening off (the keys keep working), and
`let g:my_explorer_width = 35` changes the width. For a single run:
`vim --cmd 'let g:my_explorer_autostart = 0' file`.

How it works: `my#fern#autostart()` runs on `VimEnter`, `my#fern#quit_pre()` on
`QuitPre`, `my#fern#session_loaded()` on `SessionLoadPost`, all in
`~/.vim/autoload/my/fern.vim` and wired up in `~/.vim/config/navigation.vim`. It uses
fern (`Fern . -drawer -stay`).

### Dashboard (start screen)

Shown only for a plain `vim` (no file or directory arguments), on the right of the
explorer. It is a [vim-startify](https://github.com/mhinz/vim-startify) buffer filled by
this config (`config/dashboard.vim`, `autoload/my/dashboard.vim`):

| Section | Content | Keys |
|---|---|---|
| Header | logo · Vim version · theme · plugin count · measured startup time · project path + git branch | — |
| Recent in this project | files you edited under the current directory | `0`–`9` |
| Recent files elsewhere | the rest of your history (temp files, `.git/`, help files skipped) | numbered |
| Projects | git roots of recently edited files: picking one `cd`s there, re-roots the explorer and refreshes the dashboard | `a d m o …` |
| Sessions | sessions saved with `Space q s`, newest first | numbered |
| Commands | `f` find file · `g` grep · `r` recent (fzf) · `l` restore this directory's session · `c` edit config · `h` help guide | letters |

Opening anything replaces the dashboard **in place**; the explorer stays. `e` gives an
empty buffer, `q` quits, `Space b h` brings the dashboard back later. It never opens for
`vim file`, `vim dir/`, `vim -`, `vim -S`, `vim -d`, `-c`/`+cmd`, Ex/batch mode or git
messages. `:echo g:my_dashboard_skipped` says why it did not show; turn it off with
`let g:my_dashboard = 0` in `~/.vim/local.vim`.

### Colour scheme

**Space Vim Dark** ([liuchengxu/space-vim-dark](https://github.com/liuchengxu/space-vim-dark),
MIT) is the default: the spacemacs-dark look with
blue keywords, magenta functions, green strings and **teal italic comments** on a
purple-grey background. The plugin itself is unmodified. This config adds a *palette*
of its colours (`s:palettes.space` in `~/.vim/autoload/my/ui.vim`), and
`my#ui#overrides()` uses that palette to restyle the UI chrome the 2023 scheme doesn't know
about. Syntax colours stay the scheme's own.

- floating windows, completion menu (kind/match colours), fzf, which-key, dashboard,
  Vista outline and the floating terminal: one panel colour (`#34323e`), selection `#5e5079`
- the scheme's darker cursor line, purple selection and magenta current-line number
- undercurled LSP errors/warnings with coloured signs and tinted inline messages
- thin `▎` git bars in the theme's green/yellow/red, `│` indent guides, search tinted with
  spacemacs green instead of the original's loud full-green block
- status line, buffer line and terminal colours generated from the same palette

Catppuccin ([catppuccin/vim](https://github.com/catppuccin/vim), MIT) is installed as the
alternative: **Mocha** (dark) and **Latte** (light). `Space t b` toggles dark ↔ light,
`Space t B` cycles Space Vim Dark → Mocha → Latte. Everything restyles live.

*Why Space Vim Dark?* It works in
true colour and 256 colours and has a matching spacemacs identity. Its gaps (no light
variant, no highlight groups for modern pop-ups, LSP or fzf, and an in-scheme
`g:space_vim_dark_background = 233` that is *lighter* than 234 in true colour) are all
covered by the palette layer instead of a fork. Tradeoff: there is no Space light theme,
so light mode uses Catppuccin Latte.

#### Theme inventory

| Theme | Installed | Working | Appearance | Shortcut |
|---|---|---|---|---|
| **Space Vim Dark** (default) | ✔ plugin | ✔ fully styled | purple-grey `#292b2e`, magenta/purple accents, blue keywords, teal italic comments | `Space t R` (restore default) · `:Theme space` |
| Space Vim Dark · darker / darkest | ✔ built into this config | ✔ fully styled | same colours on `#212026` / `#1a191f` | `Space t p` · `g:my_space_background` |
| Catppuccin Mocha | ✔ plugin | ✔ fully styled | soft pastel on dark blue-grey `#1e1e2e` | `Space t B` (cycle) · `:Theme dark` |
| Catppuccin Latte | ✔ plugin | ✔ fully styled | pastel on light `#eff1f5` | `Space t b` (dark ↔ light) · `:Theme light` |
| Catppuccin Frappé / Macchiato | ✔ plugin | ◐ syntax colours only (no palette for status line, pop-ups, dashboard) | mid-dark `#303446` / `#24273a` | `Space t p` · `:colorscheme catppuccin_frappe` |
| 25 schemes shipped with Vim (`habamax`, `sorbet`, `slate`, `retrobox`, `desert`, …) | ✔ Vim runtime | ◐ load fine; status line and custom panels keep the previous palette | varies | `Space t p` · `:colorscheme <name>` |

"Fully styled" means status line, buffer line, explorer, dashboard, pop-ups, completion
menu, which-key, git signs, LSP diagnostics and the terminal palette all follow the theme.

**Preview safely:** `Space t p` (`:ThemePreview`) lists every scheme; the colours change as
you move with `j`/`k`, `Enter` keeps the choice for this session and `Esc` puts back what
you had. It never writes a file, so your default cannot change by accident. `Space t R`
(`:Theme`) returns to the default at any time. To change the default, set `g:my_theme` in
`~/.vim/local.vim` (section E).

### Status line

`lightline.vim` with a custom colour scheme generated from the active palette
(`~/.vim/autoload/lightline/colorscheme/my_palette.vim`). It shows hunk counts,
diagnostics and the active language server at no measurable cost:

```
( NORMAL )  main +2 ~1   inventory/service.py ●        python  utf-8 · unix   pyright  ✘ 1  42% ( 18:10 )
```

The mode pill changes colour per mode. With Space Vim Dark: magenta normal, green insert,
gold visual, rose replace, blue command, teal terminal. Tool windows show a label instead
(EXPLORER, DASHBOARD, OUTLINE, GIT, HELP, LIST, TERMINAL…). Segments hide themselves in
narrow windows.

### Plugin manager

**vim-plug**. Exact plugin commits are
recorded in `~/.vim/plug-snapshot.vim`, the **lockfile**. Dated copies are kept in
`~/.vim/snapshots/`.

### Supported Vim and terminal

| Requirement | Needed for | Without it |
|---|---|---|
| Vim ≥ 9.0 with `+terminal +popupwin +job +timers +textprop` (a "huge" build) | everything | the configuration refuses to load below Vim 9.0 |
| `+termguicolors` and `COLORTERM=truecolor` | true colour | 256-colour approximation |
| `+clipboard` | nothing — the clipboard is bridged through `wl-copy`, `xclip`, `xsel` or OSC 52 | — |
| A Nerd Font (or the Symbols Nerd Font as a fallback font) | icons | plain Unicode symbols (auto-detected) |
| Undercurl support in the terminal (VTE, kitty, WezTerm, foot, alacritty) | diagnostic squiggles | plain underline |

### Directory structure

```text
~/.vim/                          (this repository; ~/.vimrc is an optional symlink to ~/.vim/vimrc)
├── vimrc                        entry point: leader, feature switches, loads modules
├── config/                      ── modules, loaded in this order ──
│   ├── options.vim              core options, undo/swap dirs, cursor shapes, built-in packages
│   ├── plugins.vim              vim-plug manifest (39 plugins, 6 loaded on demand)
│   ├── appearance.vim           theme, lightline layout, visual autocommands
│   ├── navigation.vim           fzf + ripgrep + fd, fern explorer, startup autocommand
│   ├── dashboard.vim            start screen (Startify lists, header, behaviour)
│   ├── editing.vim              pairs, :s preview, file commands, undo tree, clipboard, large files
│   ├── git.vim                  gitgutter + fugitive settings
│   ├── lsp.vim                  vim-lsp, servers, diagnostics, completion, snippets, outline
│   ├── languages.vim            per-language settings, prettier, Python/C workflow
│   ├── mappings.vim             EVERY custom key (defined + documented here)
│   └── whichkey.vim             which-key menu (generated) + helper commands
├── autoload/my/                 functions, loaded only when first used
│   ├── core.vim  ui.vim  statusline.vim  keys.vim  find.vim  fern.vim  edit.vim
│   ├── clip.vim  git.vim  complete.vim  run.vim  term.vim  session.vim  health.vim
│   ├── dashboard.vim  lsp.vim  keydocs.vim  help.vim (:Guide)
├── autoload/lightline/colorscheme/my_palette.vim   status-line colours from the palette
├── snippets/                    personal snippets: python.json sh.json c.json (Space c s)
├── autoload/plug.vim            vim-plug
├── plugged/                     installed plugins (managed by vim-plug, not in git)
├── plug-snapshot.vim            lockfile: exact plugin commits
├── snapshots/                   dated lockfiles (created by :ConfigSnapshot / Space h u, not in git)
├── state/                       undo/ swap/ backup/ sessions/  (not in git; keeps project folders clean)
├── tools/
│   ├── check.sh                 health check: startup + test suite + timing
│   ├── test.vim                 automated checks
│   └── bootstrap.sh             reproduce on another machine (pinned + checksummed)
├── local.vim.example            template for machine-specific overrides (→ local.vim, git-ignored)
├── docs/GUIDE.md                this file
└── README.md  LICENSE  .gitignore
```

---

## B. Installation & requirements

### Required

| Software | Notes |
|---|---|
| Vim 9.0+ | `vim --version` must show `+terminal +popupwin +job +timers` |
| git | vim-plug, fugitive, gitgutter |
| curl | bootstrap downloads |

### Optional tools

`tools/bootstrap.sh --tools --font` installs the first four into `~/.local` (pinned
versions, SHA-256 verified, no sudo).

| Tool | Pinned version | Used for | Without it |
|---|---|---|---|
| fzf | 0.74.5 | every fuzzy finder | `:find`, `:browse oldfiles`, `:ls` fallbacks |
| ripgrep | 15.2.0 | live grep, `:grep` | `git grep` |
| fd | 10.5.0 | fast file lists | `rg --files` |
| Symbols Nerd Font | 3.5.1 | icons | Unicode symbols |
| xclip or wl-clipboard | system package | system clipboard | `xsel` or OSC 52 |
| node / npm | 18 or newer | npm language servers, prettier | those servers unavailable |
| go | recent | building gopls | gopls unavailable |

### Language servers (`~/.local/share/vim-lsp-settings/servers/`)

Installed by `tools/bootstrap.sh --lsp`, or one at a time with `:LspInstallServer`.

| Language | Server | Installed with |
|---|---|---|
| Python | pyright | npm (`--ignore-scripts`, release-date cut-off) |
| JavaScript / TypeScript | typescript-language-server + typescript | npm |
| Bash / sh | bash-language-server | npm |
| YAML | yaml-language-server | npm |
| Go | gopls | `go install` (Go checksum database) |
| C / C++ | clangd | official standalone release, SHA-256 verified |

### Language support

What each language gets. *Format* is
`Space c f` (and on-save where noted, toggle `Space t f`). The format chain is: prettier
(web files) → a dedicated formatter (project virtualenv first, then `$PATH`) → the
language server, if it can format → Vim's `=` indent.

| Language | Indent | Language server | Format | Lint / diagnostics | Run · test · build | Extras |
|---|---|---|---|---|---|---|
| **Python** | 4 spaces, `tw=79`, PEP 8 hanging indents | pyright, pointed at the project's `.venv`/`venv`/`env` or `$VIRTUAL_ENV` interpreter | ruff → black → autopep8, whichever is found (see below); trailing whitespace trimmed on save | pyright (basic type checking) | `Space r r` run with the venv python · `Space r t/f/T` pytest test/file/project via `python -m pytest` · `Space r v/V` coverage · `Space r c/C` coverage highlights · `Space r b` Cython build_ext · F7–F10 | snippets `main`, `test`, `fixture`, `param`, `raises`, `#!` |
| **C / C++** | 4 spaces, `cindent`, `//` comments | clangd (`--clang-tidy`, background index) | clangd (clang-format rules, `.clang-format` honoured) | clangd + clang-tidy | `Space r m` make → quickfix · `Space r k` pick a Makefile target · `Space r M` make flash (asks first) · `Space r r` gcc/g++ quick run | snippets `main`, `guard` |
| **Shell** (sh/bash) | 2 spaces | bash-language-server | shfmt, when installed | bash-language-server (reports warnings only when shellcheck is installed) | `Space r r` bash | `#!` snippet with strict mode; new files with a shebang become executable on save (eunuch) |
| **YAML** | 2 spaces | yaml-language-server (SchemaStore schemas) | LSP | schema validation | — | docker-compose / k8s snippets |
| **JavaScript / TypeScript** | 2 spaces | typescript-language-server — **starts only inside a project** (a `package.json`, `tsconfig.json`, `jsconfig.json` or `node_modules/` above the file); a lone `.ts` file gets syntax highlighting only | prettier (on save only in projects with a prettier config) | tsserver | `Space r r` node / tsx (`npx tsx` when tsx isn't installed) | friendly-snippets |
| **Svelte** | 2 spaces (vim-svelte) | — (svelte-language-server not installed; `Space l I` in a `.svelte` file installs it) | prettier (project needs `prettier-plugin-svelte`) | — | — | tag auto-close, html/js/ts/css snippets |
| **HTML / CSS / SCSS** | 2 spaces | — (installable with `Space l I`) | prettier | — | — | tag auto-close (HTML) |
| **Go** | tabs | gopls | gofmt via gopls, on save | gopls | `Space r r` go run | — |
| **Markdown** | 2 spaces, soft wrap | — | prettier | — | — | fenced code highlighted (python, sh, js, ts, json, yaml, go, c, vim, html, css, diff) |
| **Vim script** | 2 spaces | — | `=` | — | `Space r r` sources the file | — |
| **Make** | tabs (required) | — | — | — | `Space r m`, `Space r k` | — |
| Haskell | 2 spaces | — | — | — | — | — |

**Not installed by this configuration (optional):** `ruff` or `black` for Python
formatting (`pipx install ruff`, or add it to a project's virtualenv and it is picked up
automatically; without one, `Space c f` only re-indents), `pytest` (each project's
virtualenv is used), `shellcheck` and `shfmt` (shell linting and formatting),
`svelte-language-server`, `vscode-langservers-extracted` (HTML/CSS/JSON). `ctags` is not
needed: the outline uses the language server. `:VimHealth` shows which of these are present.

### Installed plugins

See the [plugin guide](#d-plugin-guide). Exact commits: `~/.vim/plug-snapshot.vim`.

### Reproduce this setup on another machine

```bash
# 1. get the configuration (plugins and state are not in the repository)
[ -e ~/.vim ] && mv ~/.vim ~/.vim.old; [ -e ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.old
git clone https://github.com/azimhatami/vimrc.git ~/.vim     # Vim reads ~/.vim/vimrc by itself

# 2. plugins at the exact snapshot commits
~/.vim/tools/bootstrap.sh            # plugins only
~/.vim/tools/bootstrap.sh --all      # + fzf/rg/fd, icon font, language servers

# 3. verify
~/.vim/tools/check.sh
```

`bootstrap.sh` is idempotent, needs no sudo, never overwrites existing binaries and
checks every download's SHA-256. The binaries it downloads are for x86-64 Linux. The
icon plugins are skipped automatically where no Nerd Font exists.

---

## C. Complete shortcut reference

### Notation

| Written as | Press |
|---|---|
| `<Space>ff` | `Space`, then `f`, then `f` (one after another, not together) |
| `<C-h>` | `Ctrl` + `h` |
| `<S-Tab>` | `Shift` + `Tab` |
| `<CR>` / `<Esc>` / `<BS>` | Enter / Escape / Backspace |
| `<leader>` | `Space` (the *leader* key). `<localleader>` is `\` (unused, free for you) |
| `{motion}` / `{char}` | any motion (`w`, `ip`, `$`…) / any character |

**Modes:** *Normal* (moving around), *Insert* (typing), *Visual* (selection),
*Operator* (after `d`, `c`, `y`… waiting for a motion or text object), *Terminal*
(inside `:terminal` or an fzf pop-up), *Cmdline* (after `:`).

**Discovering keys inside Vim:** press `Space` and wait (which-key menu) · `Space h c`, then `2`
cheat sheet · `Space h k` fuzzy-search *all* mappings, including plugin ones ·
`:verbose nmap <key>` shows where a key is defined.

### Beginner cheat sheet: the 30 keys worth learning first

| Find & move | | Edit | | Code & git | |
|---|---|---|---|---|---|
| `Space Space` | find file | `Ctrl-s` | save | `gd` | go to definition |
| `Space /` | grep project | `Space c c` | toggle comment | `K` | documentation |
| `Space f r` | recent files | `ysiw"` | surround word | `gr` | references |
| `Space e` | file tree | `cs"'` | change quotes | `Space c r` | rename symbol |
| `Space b b` | switch buffer | `Space u` | undo tree | `Space c a` | code action |
| `Space 1…9` | buffer by number | `Space s r` | replace word | `Space c f` | format |
| `Ctrl-h/j/k/l` | move between splits | `Q` | replay macro `q` | `]d` / `[d` | next/prev problem |
| `Space w v` | vertical split | `Space y` (visual) | copy to clipboard | `Space g g` | git status |
| `Space w m` | zoom split | `Space p` | paste from clipboard | `Space g s` | stage hunk |
| `]q` / `[q` | next/prev result | `.` | repeat last change | `]h` / `[h` | next/prev change |

### Practical workflows

- **Open a file you know part of the name of:** `Space Space`, type fragments
  (`authsvc`), `Enter`. `Ctrl-v` opens it in a vertical split instead.
- **Search and replace across the project:** `Space /`, type the pattern, `Tab` to
  mark hits (or `Alt-a` for all), `Ctrl-q` to send them to quickfix, then
  `:cdo s/old/new/gc | update`.
- **Rename a function everywhere:** cursor on it, `Space c r`, type the new name.
- **Review before committing:** `Space g m` (changed files) → `]h` through hunks →
  `Space g h` to preview, `Space g s` to stage, `Space g u` to discard → `Space g g`,
  then `cc` to commit.
- **Iterate on one failing test:** cursor inside `def test_…`, `Space r t`; the output
  stays in a bottom split. Fix, then run `Space r t` again.
- **Build and jump to errors:** `Space r m` (`:make` → quickfix), then `]q` / `[q`.
- **Park your layout for tomorrow:** `Space q s`; next day in the same directory
  `Space q l`.
- **Start the day:** `cd` into a project, `vim`. The dashboard lists that project's
  recent files (`0`–`5`), other projects and saved sessions; `l` restores the session.
- **Understand a big file:** `Space l o` opens the outline on the right; `Ctrl-l` into
  it, `Enter` jumps.
- **Write a test fast:** in a Python file type `test` + `Ctrl-j`, type the name, `Ctrl-j`
  to the body. `fixture`, `param`, `raises` and `main` work the same way.
- **Quick shell without changing the layout:** `F12`, run it, `F12` again (the shell keeps
  running hidden).
- **Run a Makefile target:** `Space r k`, pick it; `Space r l` repeats the last run.
- **Explore the tree, then get it out of the way:** the sidebar is already open after
  `vim`; `Ctrl-h` jumps into it, `Enter` opens a file on the right, `Space e` hides it
  while you focus and shows it again later.

### Reference tables (generated from the live configuration)

Every table row below is produced by `:KeymapMarkdown` from the mapping registry in
`~/.vim/config/mappings.vim`. *Scope* notes mark keys that only exist in certain buffers
(LSP-attached, explorer, Python…). *Needs* notes mark keys whose feature depends on a
tool or server. Rows in **Plugin defaults** are plugin behaviour documented for you,
not remapped by this config.

<!-- KEYMAP:BEGIN (generated by :KeymapMarkdown — do not edit by hand) -->

#### Quick access

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space><Space>` | Find project files | Git repo: tracked + untracked files; elsewhere: every file. Fuzzy, with preview. _needs fzf_ | Space Space, type "authsrv" → src/auth/service.ts |
| Normal | `<Space>/` | Live grep project | ripgrep re-runs as you type (regex, smart-case); preview on the right. _needs fzf + ripgrep_ | Find every "TODO(auth)" in the repo; `<C-q>` sends hits to quickfix |
| Normal | `<Space>e` | Explorer (toggle) | Hide/show the project sidebar on the left (it opens by itself when Vim starts). Opening moves the cursor into it. | Hide the tree for more room, bring it back to browse; press ? inside for keys |
| Normal | `<Space>E` | Explorer: reveal file | Open/focus the sidebar with the cursor on the current file. | Where does this file live? |
| Normal | `<Space>u` | Undo tree | Visual undo history with diffs (history persists across restarts). | Recover the version from 20 minutes ago |
| Normal | `<Space>z` | Toggle fold | Open/close the fold under the cursor. Native z-commands still work. | Collapse a long function |
| Visual | `<Space>y` | Copy to system clipboard | Explicit copy, even when yank-sync (`<Space>tc`) is off. | Copy a snippet into the browser |
| Normal | `<Space>p` | Paste system clipboard after | Reads the desktop clipboard (xclip/wl-paste). | Paste a URL copied in the browser |
| Normal | `<Space>P` | Paste system clipboard before | Like `<Space>p`, but puts the clipboard text before the cursor / above the line. | Insert a copied line above the current one |
| Normal | `<Space>1` … `<Space>9` | Go to buffer 1…9 | Numbers are shown as superscripts in the buffer line (top). | `<Space>3` → third buffer |

#### Find & search — `<Space>f`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>ff` | Files (all) | Every file under the working directory (respects .gitignore). _needs fzf_ | Open a file that is not tracked by git yet |
| Normal | `<Space>fg` | Git-tracked files | Only files in the git index. _needs fzf_ | Ignore build output and untracked scratch files |
| Normal | `<Space>fr` | Recent files | Most recently opened files (open buffers first). _needs fzf_ | Jump back to yesterday's file |
| Normal | `<Space>fb` | Open buffers | Fuzzy list of open buffers, most recent first, with preview. _needs fzf_ | Return to a file you opened earlier |
| Normal | `<Space>fd` | Files next to this one | Files in the current file's directory. _needs fzf_ | Open the sibling test file |
| Normal | `<Space>fw` | Grep word under cursor | Whole-word, literal match across the project. _needs fzf_ | Find all call sites of a function |
| Visual | `<Space>fw` | Grep selection | Literal search for the selected text. _needs fzf_ | Select a phrase like "user_id =" and find every occurrence |
| Normal | `<Space>fs` | Search in this file | Fuzzy search the lines of the current buffer. _needs fzf_ | Jump to a line you half remember |
| Normal | `<Space>fl` | Search in open buffers | Fuzzy search across the lines of every open buffer. _needs fzf_ | Find where a name appears among the files you have open |
| Normal | `<Space>fc` | Command palette | Fuzzy-pick any Ex command. _needs fzf_ | Run a :Git subcommand without remembering it |
| Normal | `<Space>f:` | Command history | Fuzzy list of previous : commands; Enter runs one again. _needs fzf_ | Re-run a long :s or :g command |
| Normal | `<Space>f/` | Search history | Fuzzy list of previous / searches. _needs fzf_ | Repeat a complicated regex search |
| Normal | `<Space>fm` | Marks | Fuzzy list of marks (a–z in file, A–Z across files). _needs fzf_ | Jump back to a spot you marked with mA |
| Normal | `<Space>fj` | Jump list | Fuzzy view of the jump list (`<C-o>`/`<C-i>` history). _needs fzf_ | Go back to where you were before a long jump |
| Normal | `<Space>ft` | Set filetype | Pick a filetype for the current buffer. _needs fzf_ | Highlight an extension-less script as bash |

#### Buffers — `<Space>b`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>bb` | Switch buffer | Fuzzy list of open buffers. | Hop between 10 open files |
| Normal | `<Space>bn` | Next buffer | Next buffer in the buffer line (also ]b). | Cycle through a handful of open files |
| Normal | `<Space>bp` | Previous buffer | Previous buffer in the buffer line (also [b). | Step back through open files |
| Normal | `<Space>ba` | Alternate buffer | Toggle between the two most recent buffers (same as `<C-^>`). | Flip between a test and its implementation |
| Normal | `<Space>bd` | Close buffer | Deletes the buffer but keeps your window layout. | Close a file without collapsing the split |
| Normal | `<Space>bD` | Close buffer (discard changes) | Closes the buffer even with unsaved changes (they are lost), keeping the layout. | Throw away a scratch edit |
| Normal | `<Space>bo` | Close other buffers | Keeps the current buffer and anything unsaved. | Clean up after a long exploration session |
| Normal | `<Space>bN` | New empty buffer | Scratch space; :w name to save it. | Paste and tidy some JSON temporarily |
| Normal | `<Space>by` | Copy relative path | To the system clipboard. | Paste the path into a PR comment |
| Normal | `<Space>bY` | Copy absolute path | Copies the full /home/… path of the file to the system clipboard. | Paste the path into another program |
| Normal | `<Space>bh` | Dashboard (start screen) | Recent files, projects, sessions and commands; opening anything replaces it. _needs vim-startify_ | Jump back to a project you worked on yesterday |

#### Navigation

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `]b` | Next buffer | Next buffer (unimpaired-style bracket pair). | Quickly flip forward through open files |
| Normal | `[b` | Previous buffer | Previous buffer. | Quickly flip backward through open files |
| Normal | `<C-h>` | Window left | Move to the window on the left. | Hop from code to the explorer on the left |
| Normal | `<C-j>` | Window down | Move to the window below. | Hop into the terminal panel or quickfix list |
| Normal | `<C-k>` | Window up | Move to the window above. | Back from the terminal panel to code |
| Normal | `<C-l>` | Window right | Move to the window to the right. | From the explorer into the code |
| Normal | `<C-Up>` | Taller window | Needs a terminal that sends Ctrl+arrows (GNOME Terminal does). | Give the terminal panel more room |
| Normal | `<C-Down>` | Shorter window | Shrinks the window by 3 lines. | Make a quickfix list smaller |
| Normal | `<C-Left>` | Narrower window | Narrows the window by 4 columns. | Shrink the explorer |
| Normal | `<C-Right>` | Wider window | Widens the window by 4 columns. | Show long lines in a vertical split |
| Normal | `]h` | Next git hunk | Jumps to the next changed hunk (git signs). | Step through your edits before committing |
| Normal | `[h` | Previous git hunk | Jumps to the previous changed hunk. | Go back to the change above |
| Normal | `]q` | Next quickfix item | Next quickfix entry, centered. | Step through grep hits or compiler errors |
| Normal | `[q` | Previous quickfix item | Previous quickfix entry, centered. | Go back one hit |
| Normal | `]l` | Next location item | Next location-list entry (LSP references/diagnostics). | Step through references |
| Normal | `[l` | Previous location item | Previous location-list entry. | Go back one reference |
| Normal | `<C-n>` | Explorer (toggle) | The familiar NERDTree-style toggle key; same as `<Space>e`. | Muscle memory from NERDTree |
| Normal | `<C-p>` | Find project files | IDE-style alias of `<Space><Space>`. | VS Code habit |

#### Windows & tabs — `<Space>w`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>wv` | Split vertically | Splits the window side by side (new window on the right). | Code on the left, its test on the right |
| Normal | `<Space>ws` | Split horizontally | Splits the window top/bottom (new window below). | Compare two parts of a long file |
| Normal | `<Space>wc` | Close window | Closes the current window (the buffer stays open). | Done with a split |
| Normal | `<Space>wo` | Close other windows | Keeps only the current window (others close; buffers stay open). | Reset a cluttered layout |
| Normal | `<Space>w=` | Equalize sizes | Makes all windows the same size. | After resizing the terminal or zooming |
| Normal | `<Space>wm` | Maximize / restore | Zoom the window; press again to restore the layout. | Focus on one split temporarily |
| Normal | `<Space>wx` | Swap with next window | Exchanges the current window with the next one. | Put the file you are editing on the left |
| Normal | `<Space>wr` | Rotate windows | Rotates windows in the current row/column. | Re-order three vertical splits |
| Normal | `<Space>ww` | Previous window | Jumps to the previously focused window. | Toggle between explorer and code |
| Normal | `<Space>wH` | Move window far left | Moves the window to the far left, full height. | Turn a bottom split into a side panel |
| Normal | `<Space>wJ` | Move window to bottom | Moves the window to the bottom, full width. | Turn a side split into a bottom panel |
| Normal | `<Space>wK` | Move window to top | Moves the window to the top, full width. | Put a reference file above |
| Normal | `<Space>wL` | Move window far right | Moves the window to the far right, full height. | Turn a bottom split into a side panel |
| Normal | `<Space>wt` | New tab | Opens a new tab page; gt / gT switch between tabs. | A separate workspace for an unrelated task; gt / gT switch tabs |
| Normal | `<Space>wT` | Close tab | Closes the current tab page. | Close a finished side task |

#### Git — `<Space>g`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>gg` | Status (fugitive) | Stage with s, unstage u, diff =, commit cc, help g?. | Review and stage before committing |
| Normal | `<Space>gc` | Commit | Opens a commit message buffer for staged changes; write + close to commit. | Commit after staging hunks with `<Space>gs` |
| Normal | `<Space>gC` | Amend last commit | Amends the last commit (message buffer opens pre-filled). | Add a forgotten file to the previous commit |
| Normal | `<Space>gp` | Push | git push for the current branch (output in a split). | Publish your commits |
| Normal | `<Space>gP` | Pull (rebase) | git pull --rebase (keeps history linear). | Update the branch before pushing |
| Normal | `<Space>gd` | Diff this file | Side-by-side against the index; :diffget/:diffput to move hunks. | See exactly what changed in this file |
| Normal | `<Space>gD` | Diff whole repo | Full git diff of the working tree in a buffer. | Read every change before committing |
| Normal | `<Space>gb` | Blame (window) | Full-file blame; Enter on a line opens that commit. | Find when a whole block of code was introduced |
| Normal | `<Space>gB` | Blame this line | Pop-up: commit · author · age · summary. | Who wrote this and why? |
| Normal | `<Space>gl` | Log (repo) | Fuzzy commit browser with diff preview. | Browse recent history with diffs |
| Normal | `<Space>gL` | Log (this file) | Commits that touched the current file, with diff preview. | See how this file evolved |
| Normal | `<Space>gm` | Modified files | Fuzzy list of changed/untracked files. | Jump to any file you touched |
| Normal | `<Space>gs` | Stage hunk | Stages the hunk under the cursor (git add -p, one hunk). | Commit only part of a file |
| Normal | `<Space>gu` | Undo hunk | Revert the hunk under the cursor to the index version (undoable with u). | Throw away an experiment in one hunk |
| Normal | `<Space>gh` | Preview hunk | Shows the hunk's diff in a pop-up next to the cursor. | Check what you changed before staging |
| Normal | `<Space>gS` | Stage file | Stages the whole file (:Gwrite). | Stage everything in this file at once |
| Normal | `<Space>gR` | Reset buffer to index | Replaces buffer text with the staged version (undoable; not written until you save). | Abandon all unstaged edits in this file |
| Normal | `<Space>gq` | Hunks → quickfix | All changed hunks in the repo as a list. | Walk through every change in the repo with ]q |
| Normal | `<Space>gz` | Fold unchanged lines | Show only what changed; run again to unfold. | Review a large file's changes without scrolling |

#### Text objects

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Operator, Visual | `ih` | Inside hunk (text object) | Selects the lines of the git hunk under the cursor (operator or visual). | dih deletes the change; vih selects it |
| Operator, Visual | `ah` | Around hunk (text object) | Like ih, plus trailing blank lines. | yah copies a hunk with its spacing |
| Operator | `ie` | Entire buffer (text object) | The whole buffer as a text object. | yie copies the whole file; =ie re-indents it |
| Visual | `ie` | Select entire buffer | Selects the whole buffer. | vie then `<Space>y` copies the file to the clipboard |

#### Code — `<Space>c`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>cc` | Toggle comment (line) | Works with a count: 5`<Space>cc`. Operator form: gc{motion}. | Comment out a debug print |
| Visual | `<Space>cc` | Toggle comment (selection) | Comments or uncomments every selected line. | Disable a block of code temporarily |
| Normal | `<Space>ca` | Code action | Quick fixes / refactors offered by the language server. _needs LSP server_ | Add a missing import |
| Visual | `<Space>ca` | Code action (range) | Code actions limited to the selected range. _needs LSP server_ | Extract the selection into a function (if the server offers it) |
| Normal | `<Space>cr` | Rename symbol | Project-wide, semantic rename. _needs LSP server_ | Rename a function everywhere |
| Normal | `<Space>cf` | Format buffer | prettier (web files) → language server → autopep8 (python) → Vim = indent. | Tidy a file before committing |
| Visual | `<Space>cf` | Format selection | Formats only the selected lines (prettier range / LSP range / =). | Tidy one function without touching the rest |
| Normal | `<Space>co` | Organize imports | Asks the server to sort and remove unused imports. _needs LSP server (pyright / tsserver / gopls)_ | Clean up imports before committing |
| Normal | `<Space>cs` | Edit snippets (this filetype) | Your own snippets: ~/.vim/snippets/`<filetype>`.json (VS Code format). Expand with `<C-j>` in insert mode. | Add a "logger" snippet for Python |

#### LSP & diagnostics — `<Space>l`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>ld` | Go to definition | Also gd and `<C-]>` in LSP buffers. _needs LSP server_ | Open the class a name refers to |
| Normal | `<Space>lD` | Go to declaration | Jumps to the declaration (mainly C/C++ headers). _needs LSP server_ | Go from a .c call to its .h prototype |
| Normal | `<Space>lr` | Find references | Into the location list. _needs LSP server_ | Who calls this method? |
| Normal | `<Space>li` | Go to implementation | Jumps to implementations of an interface/abstract method. _needs LSP server_ | Find concrete subclasses of an ABC |
| Normal | `<Space>ly` | Go to type definition | Jumps to the definition of the symbol's type. _needs LSP server_ | From a variable to its dataclass |
| Normal | `<Space>lh` | Hover documentation | Also K. `<C-f>`/`<C-b>` scroll the pop-up. _needs LSP server_ | Read a function's signature and docstring |
| Normal | `<Space>ls` | Symbols in file | Outline: functions, classes, … _needs LSP server_ | Jump to a method by name |
| Normal | `<Space>lS` | Symbols in workspace | Fuzzy search symbols across the whole project. _needs LSP server_ | Jump to a class without knowing its file |
| Normal | `<Space>lo` | Symbol outline (sidebar) | Classes, functions, … of this file on the right, from the language server. Cursor stays in the code; `<C-l>` enters the outline, `<CR>` jumps, q closes. Loads on first use. _needs LSP server_ | Get an overview of a 2000-line module |
| Normal | `<Space>le` | Diagnostics list | All errors/warnings of this file in the location list. _needs LSP server_ | Fix all problems in a file one by one with ]l |
| Normal | `<Space>ln` | Next diagnostic | Also ]d. _needs LSP server_ | Walk through errors |
| Normal | `<Space>lp` | Previous diagnostic | Also [d. _needs LSP server_ | Walk back through errors |
| Normal | `<Space>lc` | Incoming calls | Tree of functions that call the symbol under the cursor. _needs LSP server_ | Understand impact before changing a signature |
| Normal | `<Space>lx` | Server status | Which servers are running for this buffer. | Troubleshoot "LSP does not start" |
| Normal | `<Space>lI` | Install server for filetype | User-local install via vim-lsp-settings. | Add Rust or Lua support later |
| Normal | `<Space>lM` | Manage servers | Install / update / uninstall servers (vim-lsp-settings UI). | Update pyright |

#### Run & test — `<Space>r`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>rr` | Run this file | python3 / bash / node / go run / gcc in a bottom terminal; :source for Vim files. | Run a script and keep its output visible |
| Normal | `<Space>rt` | pytest: test under cursor | Finds the enclosing def test_* (and its class) and runs only that test. | Iterate on one failing test |
| Normal | `<Space>rf` | pytest: this file | pytest -vvv on the current file (also F8 in Python buffers). | Run all tests in the file you are editing |
| Normal | `<Space>rT` | pytest: whole project | python -m pytest -q with the project virtualenv (.venv / venv / $VIRTUAL_ENV) when there is one. | Full test run before pushing |
| Normal | `<Space>rv` | Coverage run (project) | pytest --cov=<dir name> tests  (also F7 in Python buffers). | See project coverage, then `<Space>rc` to highlight |
| Normal | `<Space>rV` | Coverage run (this file) | pytest --cov on the current file (also F10 in Python buffers). | Coverage for the module you are working on |
| Normal | `<Space>rc` | Show coverage highlights | Marks uncovered lines from .coverage. _needs python buffer_ | Find untested branches |
| Normal | `<Space>rC` | Hide coverage highlights | Removes the coverage marks. _needs python buffer_ | Back to normal colours |
| Normal | `<Space>rm` | make → quickfix | Errors become a jumpable list. | Build, then ]q through compiler errors |
| Normal | `<Space>rM` | make flash | Asks first, then runs in a terminal split. Never runs automatically. | Flash firmware after a successful build |
| Normal | `<Space>rk` | make: pick a target | Fuzzy list of the Makefile's targets; flash/install/deploy-like targets ask before running. | make test / make lint without typing |
| Normal | `<Space>rl` | Re-run last command | Repeats the last run/test/build command (saves the file first). | Edit, Space r l, edit, Space r l … |
| Normal | `<Space>rb` | Cython build_ext | python3 setup.py build_ext --inplace --define=CYTHON_TRACE. | Rebuild a Cython extension |

#### Lists (quickfix) — `<Space>x`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>xq` | Toggle quickfix list | Opens or closes the quickfix list (grep results, build errors, hunks). | Review grep results or build errors |
| Normal | `<Space>xl` | Toggle location list | LSP references/diagnostics land here. | Show the references found by `<Space>lr` |

#### Save & substitute — `<Space>s`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>ss` | Save | Writes only if changed. | Save without leaving the home row |
| Normal | `<Space>sa` | Save all | Writes every modified buffer. | Before running tests that read several files |
| Normal | `<Space>sn` | Save without formatting | Skips format-on-save and whitespace trimming for this write. | Commit a file exactly as-is |
| Normal | `<Space>sr` | Replace word in file | Pre-fills `:%s/\<word\>/word/gc`: edit the replacement, press Enter, confirm each match with `y`/`n`. | Rename a local variable |
| Visual | `<Space>sr` | Replace selection in file | Pre-fills a confirmed :%s for the selected (literal) text. | Replace a repeated string literal |
| Normal | `<Space>sc` | Clear search highlight | Hides the highlight of the last search until the next search. | Remove leftover search highlighting |
| Normal | `<Space>st` | Trim trailing whitespace | Deletes trailing spaces/tabs in the whole buffer (cursor stays). | Clean a file that the red highlight flags |

#### Editing

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal, Insert, Visual | `<C-s>` | Save | Works in Normal, Insert and Visual mode. | Muscle memory from other editors |
| Normal | `Y` | Yank to end of line | Consistent with D and C. | Y then p duplicates the rest of a line |
| Normal | `n` | Next match (centered) | Next search match, scrolled to the middle of the screen and unfolded. | Keep your eyes in one place while stepping through matches |
| Normal | `N` | Previous match (centered) | Previous search match, centered. | Step back through matches |
| Normal | `J` | Join lines (cursor stays) | Joins the next line to this one without moving the cursor. | Merge a wrapped argument list |
| Normal | `Q` | Replay macro q | Record with qq … q, replay with Q (Ex mode is still :visual / gQ). | Apply the same edit to 20 lines: 20Q |
| Normal | `]<Space>` | Blank line below | Adds blank line(s) below without entering Insert mode. Count-aware, repeatable. | 3]`<Space>` adds three blank lines below |
| Normal | `[<Space>` | Blank line above | Adds blank line(s) above without entering Insert mode. | Space out a new function |
| Visual | `<` | Outdent (keep selection) | Outdents the selection and keeps it selected (press again to repeat). | Outdent a block several levels |
| Visual | `>` | Indent (keep selection) | Indents the selection and keeps it selected. | Indent a block several levels |
| Visual | `J` | Move selection down | Moves the selected lines down one line, re-indenting them. | Reorder lines without cut/paste |
| Visual | `K` | Move selection up | Moves the selected lines up one line, re-indenting them. | Reorder imports |
| Visual | `p` | Paste without losing register | The yanked text stays in the register, so it can be pasted over many selections. | Replace several words with the same yanked word |
| Visual | `*` | Search selection forward | Searches forward for the exact selected text. | Find the next occurrence of "foo.bar(" |
| Visual | `#` | Search selection backward | Searches backward for the exact selected text. | Find the previous occurrence |
| Normal | `<F1>` | Disabled (no accidental help) | F1 sits next to Esc; it acts as Esc instead of opening help. | No more help window from a missed Esc |
| Insert | `<F1>` | Disabled (no accidental help) | Leaves Insert mode instead of opening help. | Same, in Insert mode |

#### Toggles & theme — `<Space>t`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>tt` | Terminal panel | Bottom shell that keeps running while hidden. `<Esc><Esc>` → Normal mode. | Run git/npm without leaving Vim |
| Normal | `<Space>tb` | Dark / light theme | Your dark theme (Space Vim Dark by default) ↔ Catppuccin Latte; status line follows. | Switch to light in a sunny room |
| Normal | `<Space>tB` | Cycle theme | Space Vim Dark → Catppuccin Mocha → Catppuccin Latte. Status line, explorer, pop-ups follow. | Compare themes in daylight |
| Normal | `<Space>tp` | Preview themes | Pop-up list of every installed colour scheme; colours change as you move. Enter keeps the choice for this session, Esc restores. Never changes your default. | Try Catppuccin Mocha or a darker background without editing any file |
| Normal | `<Space>tR` | Restore default theme | Back to the theme Vim started with (g:my_theme in ~/.vim/local.vim, else Space Vim Dark). | Undo any amount of theme cycling |
| Normal | `<Space>tF` | Floating terminal | Centred pop-up shell that survives hiding (also F12). F12 inside hides it. | Quick git/npm command without changing the layout |
| Normal | `<Space>tz` | Zen mode | Centered, distraction-free writing (Goyo). | Write docs or a long commit message |
| Normal | `<Space>tn` | Line numbers | Shows/hides line numbers (absolute + relative together). | Copy text with the mouse without numbers |
| Normal | `<Space>tr` | Relative numbers | Relative numbers on/off for this window. | Pair-programming when others call out line numbers |
| Normal | `<Space>tw` | Soft wrap | Soft-wraps long lines (display only; the file is not changed). | Read prose or long log lines |
| Normal | `<Space>ts` | Spell check | Spell checking (en_us) for this buffer; ]s / [s jump, z= suggests. | Proof-read a README |
| Normal | `<Space>tl` | Invisible characters | Shows/hides tabs, trailing spaces and indent guides. | Inspect mixed tabs/spaces |
| Normal | `<Space>ti` | Indent guides | Indent guides on/off in all windows. | Hide guides in deeply nested HTML |
| Normal | `<Space>tg` | Git signs | Git change signs on/off. | Cleaner gutter for screenshots |
| Normal | `<Space>tf` | Format on save | prettier (projects with a prettier config), gofmt, whitespace trim for C/Python. | Edit a repo with different style rules |
| Normal | `<Space>tc` | Clipboard sync | When on, every yank (y) is also copied to the desktop clipboard. | Turn off while yanking lots of temporary text |
| Normal | `<Space>td` | Inline diagnostics | Show/hide the messages at the end of lines (signs stay). _needs LSP server_ | Read a crowded file without inline messages |
| Normal | `<Space>th` | Search highlighting | Turns search-match highlighting on/off. | Keep matches visible while editing |
| Normal | `<Space>tm` | Mouse | Off → the terminal handles mouse selection/copy directly. | Select text with the mouse to copy it |
| Normal | `<Space>tC` | Column guide | Line at textwidth+1 (column 80 for most of your filetypes). | Check line length while writing |

#### Terminal

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<F12>` | Floating terminal | Same as Space t F. | F12, run a command, F12 to hide |
| Terminal | `<F12>` | Hide floating terminal | The shell keeps running; F12 brings it back. | Hide a long build while you keep editing |
| Terminal | `<Esc><Esc>` | Terminal → Normal mode | Single `<Esc>` still reaches the shell / fzf. _terminal panel (<Space>tt) and floating terminal (F12)_ | Scroll back through command output with normal keys |
| Terminal | `<C-w>N  or  <C-\><C-n>` | Terminal → Normal mode (any terminal) | Built-in way to reach Terminal-Normal mode in any terminal window. _Vim built-in_ | Copy text out of a run output split |
| Terminal | `<C-w>h/j/k/l` | Leave terminal to another window | Built-in: move from a terminal window to another window. _Vim built-in_ | Back to code without closing the terminal |

#### Quit & sessions — `<Space>q`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>qq` | Quit all | Asks about unsaved buffers. | End the day |
| Normal | `<Space>qQ` | Quit all (discard changes) | Quits immediately; unsaved changes are lost. | Abandon everything after a failed experiment |
| Normal | `<Space>qw` | Save all and quit | Writes every modified buffer, then quits. | Save and leave in one step |
| Normal | `<Space>qs` | Save session | Per-directory session in ~/.vim/state/sessions. | Park a multi-split layout for tomorrow |
| Normal | `<Space>ql` | Load session | Restores the session saved for the current directory. | Resume yesterday's layout |
| Normal | `<Space>qd` | Delete session | Deletes this directory's saved session (asks first). | Start fresh next time |

#### Help & health — `<Space>h`

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<Space>hc` | Help guide & cheat sheet | Topic menu: start here, all shortcuts (press 2), features, workflows, themes, languages, plugins, AI, Vim essentials, health. - goes back, q closes. :Cheatsheet still opens the key list directly. | Look up a key you forgot |
| Normal | `<Space>hk` | Search all mappings | Every active mapping (incl. plugins), fuzzy-searchable. | Find what a key does or which keys are free |
| Normal | `<Space>ht` | Search help tags | Fuzzy search Vim and plugin help topics. | Look up an option like 'scrolloff' |
| Normal | `<Space>hh` | Health check | Versions, tools, clipboard, colours, LSP servers, plugins. | First stop when something misbehaves |
| Normal | `<Space>hm` | Messages | Shows recent messages and warnings. | Read an error that flashed by |
| Normal | `<Space>hr` | Open the full guide | Opens docs/GUIDE.md (the full guide) in a read-only split. | Read the docs inside Vim |
| Normal | `<Space>hp` | Plugin status | vim-plug status of every plugin (installed, commit, errors). | Check whether a plugin is missing |
| Normal | `<Space>hu` | Update plugins (with snapshot) | Saves a restore snapshot first, then :PlugUpdate. | Monthly plugin refresh |

#### Insert & completion

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Insert | `<Tab>` | Next completion / Tab | Selects the next completion item when the menu is open; inserts a tab/indent otherwise. | Type pri, Tab → print |
| Insert | `<S-Tab>` | Previous completion | Selects the previous completion item. | Went one item too far |
| Insert | `<C-Space>` | Trigger completion | Some terminals send `<C-@>` for Ctrl+Space; both are mapped. | Ask for completions on an empty prefix (after a dot) |
| Insert | `<C-@>` | Trigger completion (terminal code) | The byte many terminals send for Ctrl+Space. | Same as `<C-Space>` |
| Insert | `<C-u>` | Delete to line start (undoable) | Deletes to the start of the line; undo restores it separately. | Retype a line from scratch |
| Insert | `<C-w>` | Delete word (undoable) | Deletes the previous word; undo restores it separately. | Fix the last word you typed |
| Insert, Select | `<C-j>` | Snippet: expand / next field | Expands the snippet name before the cursor, then jumps through its fields. Plain `<C-j>` elsewhere. | main`<C-j>` in a .py file → main() + __main__ guard |
| Insert, Select | `<C-k>` | Snippet: previous field | Only inside an active snippet; otherwise `<C-k>` still enters digraphs. | Go back to fix the first argument |
| Insert | `<CR>` | Accept completion / smart newline | Selected item → accept; menu open but nothing selected → close + newline; between {} → indented block. _set at VimEnter_ | Type {, Enter → an indented block with the } below |

#### Command line

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Cmdline | `%%` | Insert current file's directory | Expands to the current file's directory while typing a : command. | :e %%new_file.py |
| Cmdline | `:W  /  :Wa` | Typo guard → :w / :wa | Holding Shift too long still saves. _command-line abbreviation_ | :W Enter just writes the file |

#### LSP buffers

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `gd` | Go to definition | Also `<C-]>` (tagfunc) _only when a server is attached_ | Follow a function call into its definition; `<C-o>` comes back |
| Normal | `gD` | Go to declaration | Jumps to the declaration. _only when a server is attached_ | From a C call to its prototype |
| Normal | `gr` | Find references | Lists every reference in the location list. _only when a server is attached_ | Who uses this variable? |
| Normal | `gI` | Go to implementation | gi (insert at last insert) stays native _only when a server is attached_ | Jump to the concrete implementation |
| Normal | `gy` | Go to type definition | Jumps to the type's definition. _only when a server is attached_ | From an instance to its class |
| Normal | `K` | Hover documentation | Shows type info and documentation in a pop-up. _only when a server is attached_ | Check a parameter's type |
| Normal | `[d` | Previous diagnostic | Jumps to the previous diagnostic and shows its message. _only when a server is attached_ | Go back to the last error |
| Normal | `]d` | Next diagnostic | Jumps to the next diagnostic and shows its message. _only when a server is attached_ | Work through warnings top to bottom |
| Normal | `<C-f> / <C-b>` | Scroll hover pop-up | Normal paging when no pop-up is open _only when a server is attached_ | Read a long docstring |

#### Python buffers

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<F7>` | pytest --cov (project) | pytest --cov=<dir name> tests in a bottom terminal (same as `<Space>rv`). _python filetype_ | Coverage for the whole package |
| Normal | `<F8>` | pytest this file | pytest -vvv on the current file (same as `<Space>rf`). _python filetype_ | Run this file's tests |
| Normal | `<F9>` | Run with python3 | Runs the file with python3 (same as `<Space>rr`). _python filetype_ | Quick script run |
| Normal | `<F10>` | pytest --cov (this file) | pytest --cov on the current file (same as `<Space>rV`). _python filetype_ | Coverage for one module |

#### Explorer (fern)

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<CR> / l / o` | Open file / expand folder | Opens a file in the previous window, or expands/collapses a folder. _explorer window_ | Browse into src/ and open a file |
| Normal | `h` | Collapse folder | Collapses the folder under the cursor (or its parent). _explorer window_ | Tidy the tree |
| Normal | `s / v / t` | Open in split / vsplit / tab | Opens the file in a horizontal split, vertical split or new tab. _explorer window_ | Open a test next to its module |
| Normal | `- / <BS>` | Go up to parent directory | Moves the tree root up one directory. _explorer window_ | Look outside the project folder |
| Normal | `=` | Make folder the root | Makes the folder under the cursor the tree root. _explorer window_ | Focus on one package |
| Normal | `a` | New file (end with / for a folder) | Prompts for a path; a trailing / creates a folder, nested paths are created. _explorer window_ | a → tests/unit/test_api.py |
| Normal | `r` | Rename | Renames the file/folder under the cursor (or the marked ones in a buffer). _explorer window_ | Fix a typo in a filename |
| Normal | `c / m` | Copy / move | Copies / moves the node (or marked nodes) to a path you type. _explorer window_ | Duplicate a template file |
| Normal | `d` | Move to trash | Moves to the desktop trash (recoverable), after confirmation. _explorer window_ | Remove a file safely |
| Normal | `D` | Delete permanently (asks) | Deletes permanently after confirmation. _explorer window_ | Remove build artefacts |
| Normal | `y` | Copy path (Vim register) | Yanks the node's path into Vim's register (synced to the clipboard). _explorer window_ | Paste a path into a shell command |
| Normal | `x` | Mark (for batch operations) | Marks/unmarks a node and moves down; operations then apply to all marked. _explorer window_ | Mark three files, then d to trash them |
| Normal | `!` | Show/hide dotfiles | Shows/hides dotfiles. _explorer window_ | Edit .gitignore or .env |
| Normal | `I` | Toggle ignore filter (build/, dist/, …) | Turns the ignore list (build/, dist/, __pycache__ …) on/off. _explorer window_ | Look inside build/ |
| Normal | `R` | Reload | Re-reads the tree from disk. _explorer window_ | After files changed outside Vim |
| Normal | `gc` | cd (tab) to folder | Changes the tab's working directory to the folder (finders follow). _explorer window_ | Scope `<Space>ff` to a sub-project |
| Normal | `X` | Open with system app | Opens with the desktop's default application (xdg-open). _explorer window_ | Open an image or PDF |
| Normal | `?` | All fern actions | Lists every fern action, including unmapped ones. _explorer window_ | Discover more operations |
| Normal | `q` | Close the drawer | Closes the sidebar (never quits Vim; `<Space>e` brings it back). _explorer window_ | More room for code |

#### Dashboard

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `0-9 / a d m …` | Open the numbered entry | Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays. _start screen (vim with no files, or Space b h)_ | Press 0 to reopen the last file of this project |
| Normal | `<CR>` | Open entry under cursor | Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays. _start screen (vim with no files, or Space b h)_ | j j `<CR>` opens the third entry |
| Normal | `f / g / r` | Find file / grep / recent files (fzf) | Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays. _start screen (vim with no files, or Space b h)_ | g, type TODO → every TODO in the project |
| Normal | `l` | Restore this directory's session | Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays. _start screen (vim with no files, or Space b h)_ | Get yesterday's splits back |
| Normal | `c` | Edit configuration | Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays. _start screen (vim with no files, or Space b h)_ | Opens ~/.vim/vimrc, explorer shows ~/.vim |
| Normal | `h` | Help guide & shortcuts | Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays. _start screen (vim with no files, or Space b h)_ | Look up a key you forgot |
| Normal | `b / s / v / t` | Mark entry: open in buffer / split / vsplit / tab | Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays. _start screen (vim with no files, or Space b h)_ | v on two files, then `<CR>` → side by side |
| Normal | `e` | Empty buffer | Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays. _start screen (vim with no files, or Space b h)_ | Scratch notes |
| Normal | `q` | Quit | Startify key, active only on the start screen; the file opens in place of the dashboard and the explorer stays. _start screen (vim with no files, or Space b h)_ | Leave Vim from the start screen |

#### Symbol outline (Vista)

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `<CR>` | Jump to the symbol | Vista key inside the outline; symbols come from the language server and refresh as you type. _outline window (Space l o)_ | Jump to class Greeter |
| Normal | `p` | Preview the symbol | Vista key inside the outline; symbols come from the language server and refresh as you type. _outline window (Space l o)_ | Peek at a function without leaving the outline |
| Normal | `s` | Sort alphabetically / by position | Vista key inside the outline; symbols come from the language server and refresh as you type. _outline window (Space l o)_ | Find a method by name in a long class |
| Normal | `/` | Filter (fzf) | Vista key inside the outline; symbols come from the language server and refresh as you type. _outline window (Space l o)_ | / hel → hello() |
| Normal | `q` | Close the outline | Vista key inside the outline; symbols come from the language server and refresh as you type. _outline window (Space l o)_ | Same as Space l o |

#### Plugin defaults

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `ys{motion}{char}` | Add surrounding | Wraps the text covered by a motion in a pair. _vim-surround_ | ysiw" → "word" |
| Normal | `yss{char}` | Surround whole line | Wraps the whole line. _vim-surround_ | yss) → (line) |
| Normal | `cs{old}{new}` | Change surrounding | Replaces the surrounding pair. _vim-surround_ | cs"' → 'word' |
| Normal | `ds{char}` | Delete surrounding | Removes the surrounding pair. _vim-surround_ | ds( removes parentheses |
| Visual | `S{char}` | Surround selection | Wraps the selection; S`<div>` wraps in a tag. _vim-surround_ | viwS] → [word] |
| Normal, Visual | `gc{motion}` | Comment operator | Toggles comments over a motion/selection. _vim-commentary_ | gcap comments a paragraph |
| Normal | `gcc` | Comment line | Toggles the comment on the current line. _vim-commentary_ | 3gcc comments 3 lines |
| Operator | `gc` | Comment block (text object) | A contiguous comment block as a text object. _vim-commentary_ | dgc deletes a comment block |
| Operator | `ia / aa` | Argument (inside / around) | One function argument, with or without the comma. _targets.vim_ | cia changes one function argument |
| Operator | `in( / il(` | Next / last pair | Works on the next / last pair on the line without moving there first. _targets.vim_ | cin" edits the next string on the line |
| Operator | `i, / a,` | Between separators | Text between separators (, . ; : + - = ~ _ * # / \| \ & $). _targets.vim_ | ci, changes a CSV field |
| Insert | `( [ { " ' `` | Auto-close pairs | Typing an opener inserts the closer; typing the closer skips over it. _lexima.vim_ | Type ( → (\|); `<BS>` deletes both |
| Normal | `.` | Repeat (also plugin maps) | Repeats the last change, including surround, commentary and gitgutter actions. _vim-repeat_ | Repeats ys/cs/ds and gitgutter actions |
| Normal | `%` | Jump between matching pairs | Jumps between matching keywords and tags, not just brackets. _matchit (built-in)_ | if ↔ endif, `<div>` ↔ </div> |

#### Git status window (fugitive)

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Normal | `s / u / -` | Stage / unstage / toggle file or hunk | On a file or hunk line in :Git status. _inside <Space>gg_ | Stage two files, unstage one |
| Normal | `=` | Inline diff | Expands the diff of the file under the cursor in place. _inside <Space>gg_ | Review before staging |
| Normal | `cc / ca` | Commit / amend | Commit staged changes / amend the last commit. _inside <Space>gg_ | Commit straight from the status window |
| Normal | `dv` | Vertical diff of file | Opens a side-by-side diff of the file. _inside <Space>gg_ | Stage only part of a hunk with :diffput |
| Normal | `X` | Discard change (asks) | Discards the change under the cursor (asks; not undoable). _inside <Space>gg_ | Throw away an unwanted file change |
| Normal | `<CR>` | Open file | Opens the file under the cursor. _inside <Space>gg_ | Jump from status to the file |
| Normal | `g?` | All fugitive keys | Fugitive's full key list. _inside <Space>gg_ | Rebase, stash and more |

#### Inside fzf pop-ups

| Mode | Shortcut | Action | Description | Example / when to use |
|---|---|---|---|---|
| Terminal | `<CR>` | Open selection | Opens the highlighted (or marked) entries. _fzf window_ | Open the top match |
| Terminal | `<C-s> / <C-v> / <C-t>` | Open in split / vsplit / tab | Open the selection in a split, vertical split or tab. _fzf window_ | Open a file next to the current one |
| Terminal | `<Tab> / <S-Tab>` | Mark / unmark (multi-select) | Marks entries for multi-select. _fzf window_ | Open three files at once |
| Terminal | `<C-q>` | Send marked items to quickfix | Sends marked entries to the quickfix list (then :cdo / :cfdo). _fzf window_ | Project-wide replace on grep hits |
| Terminal | `alt-a / alt-d` | Select / deselect all | Marks / unmarks every entry. _fzf window_ | Send all grep hits to quickfix |
| Terminal | `<C-/>` | Toggle preview | Shows/hides the preview pane. _fzf window_ | More room for long paths |
| Terminal | `<C-u> / <C-d>` | Half page up / down | Scrolls the list half a page. _fzf window_ | Long result lists |
| Terminal | `<Esc>` | Cancel | Closes the pop-up without opening anything. _fzf window_ | Changed your mind |

<!-- KEYMAP:END -->

---

## D. Plugin guide

Every plugin was checked for maintenance (last commit shown), Vim 9.1 compatibility, licence
and overlap with the others. **39 plugins: 33 load at startup, 6 on demand.** All are MIT or
Vim-licensed and were installed from GitHub with plain `git clone` (no install hooks run,
except vim-prettier's `npm install --ignore-scripts`). Exact commits:
`~/.vim/plug-snapshot.vim`.

| Plugin (repository) | Last commit | Purpose | Loaded | Keys | Config | Depends on |
|---|---|---|---|---|---|--- |
| [liuchengxu/space-vim-dark](https://github.com/liuchengxu/space-vim-dark) | 2023-11 | Default colour scheme (spacemacs-dark look) | startup | `Space t b`, `Space t B` | `appearance.vim`, `autoload/my/ui.vim` | true colour (256-colour fallback) |
| [catppuccin/vim](https://github.com/catppuccin/vim) | 2026-10 | Alternative schemes: Mocha (dark) / Latte (light) | startup (colours load on switch) | `Space t b`, `Space t B` | `autoload/my/ui.vim` | — |
| [itchyny/lightline.vim](https://github.com/itchyny/lightline.vim) | 2026-10 | Status line + tabline engine | startup | — | `appearance.vim`, `autoload/my/statusline.vim`, `autoload/lightline/colorscheme/my_palette.vim` | — |
| [mengelbrecht/lightline-bufferline](https://github.com/mengelbrecht/lightline-bufferline) | 2023-11 | Numbered buffer list in the tabline | startup | `Space 1…9`, `[b` `]b` | `appearance.vim` | lightline |
| [lambdalisue/vim-nerdfont](https://github.com/lambdalisue/vim-nerdfont) | 2026-06 | File-type icons (status line, buffer line, explorer, dashboard) | startup, only when a Nerd Font is found | — | auto | a Nerd Font |
| [lambdalisue/vim-glyph-palette](https://github.com/lambdalisue/vim-glyph-palette) | 2025-04 | Colours the icons by file type | startup (with icons) | — | `autoload/my/fern.vim` | vim-nerdfont |
| [junegunn/goyo.vim](https://github.com/junegunn/goyo.vim) | 2025-12 | Distraction-free mode | on demand (`:Goyo`) | `Space t z` | `appearance.vim` | — |
| [mhinz/vim-startify](https://github.com/mhinz/vim-startify) | 2023-09 | Start screen beside the explorer | startup (renders only for plain `vim`) | dashboard keys, `Space b h` | `dashboard.vim`, `autoload/my/dashboard.vim` | — |
| [junegunn/fzf](https://github.com/junegunn/fzf) (v0.74.5) | 2026-10 | fzf Vim glue, pinned to the binary's tag | startup | — | `plugins.vim` | fzf binary |
| [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) | 2026-09 | Fuzzy finders: files, grep, buffers, history, commits… | startup | `Space Space`, `Space /`, `Space f…` | `navigation.vim` | fzf, rg, fd |
| [lambdalisue/vim-fern](https://github.com/lambdalisue/vim-fern) | 2026-10 | Asynchronous file explorer (the always-on sidebar) | startup | `Space e`, `Space E`, `Ctrl-n`, tree keys | `navigation.vim`, `autoload/my/fern.vim` | — |
| [lambdalisue/vim-fern-git-status](https://github.com/lambdalisue/vim-fern-git-status) | 2021-07 | Git badges in the tree | startup | — | `navigation.vim` | fern, git |
| [lambdalisue/vim-fern-hijack](https://github.com/lambdalisue/vim-fern-hijack) | 2023-09 | `vim some/dir` opens fern instead of netrw | startup | — | — | fern |
| [lambdalisue/vim-fern-renderer-nerdfont](https://github.com/lambdalisue/vim-fern-renderer-nerdfont) | 2024-07 | Icons in the tree | startup (with icons) | — | `navigation.vim` | fern, vim-nerdfont |
| [liuchengxu/vista.vim](https://github.com/liuchengxu/vista.vim) | 2024-12 | Symbol outline sidebar fed by the language server | on demand (`:Vista`) | `Space l o`, outline keys | `lsp.vim` | vim-lsp + a server (no ctags needed) |
| [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) | 2026-03 | Git porcelain: status, stage, commit, blame, diff, log | startup | `Space g…` | `git.vim` | git |
| [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter) | 2026-07 | Git signs, hunk stage/undo/preview/text objects | startup | `Space g s/u/h/q/z`, `]h` `[h`, `ih` `ah` | `git.vim` | git |
| [prabirshrestha/vim-lsp](https://github.com/prabirshrestha/vim-lsp) | 2026-10 | LSP client (Vim 9 native channel) | startup; servers start per filetype | `Space l…`, `Space c a/r/o`, `gd gD gr gI gy K [d ]d` | `lsp.vim`, `autoload/my/lsp.vim` | language servers |
| [mattn/vim-lsp-settings](https://github.com/mattn/vim-lsp-settings) | 2026-11 | Server registry + user-local installer | startup | `Space l I`, `Space l M` | `lsp.vim` | npm/go for installs |
| [prabirshrestha/asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim) | 2025-10 | Async completion engine | startup | `Tab` `S-Tab` `CR` `C-Space` | `lsp.vim`, `autoload/my/complete.vim` | — |
| [prabirshrestha/asyncomplete-lsp.vim](https://github.com/prabirshrestha/asyncomplete-lsp.vim) | 2026-08 | Completion source: LSP | startup | — | `lsp.vim` | asyncomplete |
| [prabirshrestha/asyncomplete-buffer.vim](https://github.com/prabirshrestha/asyncomplete-buffer.vim) | 2023-12 | Completion source: words in open buffers | startup | — | `lsp.vim` | asyncomplete |
| [prabirshrestha/asyncomplete-file.vim](https://github.com/prabirshrestha/asyncomplete-file.vim) | 2022-07 | Completion source: file paths | startup | — | `lsp.vim` | asyncomplete |
| [hrsh7th/vim-vsnip](https://github.com/hrsh7th/vim-vsnip) | 2025-10 | Snippet engine (VS Code / LSP snippet format, pure Vimscript) | startup | `Ctrl-j` / `Ctrl-k` (insert, select), `Space c s` | `lsp.vim`, `~/.vim/snippets/` | — |
| [hrsh7th/vim-vsnip-integ](https://github.com/hrsh7th/vim-vsnip-integ) | 2025-09 | Snippets in the completion menu + expansion of LSP snippet items | startup | — | `lsp.vim` | vim-vsnip, asyncomplete, vim-lsp |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | 2026-11 | Community snippet collection (JSON data, no code) | read when a filetype is first used | — | — | vim-vsnip |
| [tpope/vim-surround](https://github.com/tpope/vim-surround) | 2022-10 | `ys` / `cs` / `ds` surroundings | startup | `ys` `cs` `ds` `S` | defaults | vim-repeat |
| [tpope/vim-commentary](https://github.com/tpope/vim-commentary) | 2024-10 | Comment toggling | startup | `gc`, `gcc`, `Space c c` | defaults | — |
| [tpope/vim-repeat](https://github.com/tpope/vim-repeat) | 2024-07 | `.` repeats plugin actions | startup | `.` | — | — |
| [tpope/vim-eunuch](https://github.com/tpope/vim-eunuch) | 2026-08 | File commands: `:Rename` `:Move` `:Copy` `:Delete` `:Remove` `:Chmod` `:Mkdir` `:SudoWrite`; new scripts with a shebang become executable | startup | commands only (its insert `<CR>` hook is disabled) | `editing.vim` | — |
| [markonm/traces.vim](https://github.com/markonm/traces.vim) | 2025-01 | Live preview of `:s/…/…/`, `:g`, ranges as you type | startup (idle until `:`) | — | `editing.vim` | — |
| [cohama/lexima.vim](https://github.com/cohama/lexima.vim) | 2026-07 | Dot-repeatable auto-pairs + endwise | startup | automatic | `editing.vim`, `autoload/my/complete.vim` | — |
| [wellle/targets.vim](https://github.com/wellle/targets.vim) | 2024-07 | More text objects (arguments, next/last pairs, separators) | startup | see *Plugin defaults* | `editing.vim` | — |
| [mbbill/undotree](https://github.com/mbbill/undotree) | 2026-03 | Undo history tree | on demand (`:UndotreeToggle`) | `Space u` | `editing.vim` | — |
| [liuchengxu/vim-which-key](https://github.com/liuchengxu/vim-which-key) | 2026-03 | Key discovery menu (generated from the registry) | startup | `Space` (pause) | `whichkey.vim` | — |
| [evanleck/vim-svelte](https://github.com/evanleck/vim-svelte) | 2025-05 | Svelte syntax + indent | on demand (`svelte` files) | — | `languages.vim` | — |
| [prettier/vim-prettier](https://github.com/prettier/vim-prettier) | 2026-06 | Prettier formatting (bundled prettier) | on demand (web filetypes) | `Space c f`, on save in prettier projects | `languages.vim` | node |
| [mgedmin/coverage-highlight.vim](https://github.com/mgedmin/coverage-highlight.vim) | 2025-02 | Coverage highlighting from `.coverage` | on demand (`python` files) | `Space r c`, `Space r C` | `mappings.vim` | a `.coverage` file |
| [alvan/vim-closetag](https://github.com/alvan/vim-closetag) | 2022-05 | Auto-close HTML/XML/Svelte/Vue/JSX tags | on demand (those filetypes) | type `>` | `languages.vim` | — |

**Built-in packages enabled:** `matchit` (`%` on if/else/tags), `editorconfig` (honours
`.editorconfig`), `cfilter` (`:Cfilter /pat/` to narrow quickfix lists).

**Built-in instead of a plugin:** the floating terminal (`F12`, Vim's pop-up terminal), indent guides (`listchars`), yank flash, blame pop-up,
sessions, zoom, clipboard bridge, Makefile target picker.

**Disabled built-in runtime plugins** (obsolete): getscript, vimball,
logiPat, rrhelper. gzip/tar/zip, netrw (fern fallback) and `:TOhtml` stay available.

---

## E. Customization guide

### Change the theme, background and colours

- **Switch now:** `Space t b` dark ↔ light, `Space t B` cycles
  Space Vim Dark → Catppuccin Mocha → Catppuccin Latte.
- **Default theme:** in `~/.vim/local.vim`: `let g:my_theme = 'space'` (default),
  `'dark'` (Mocha) or `'light'` (Latte).
- **Space Vim Dark background:** `let g:my_space_background = 'darker'` (`#212026`) or
  `'darkest'` (`#1a191f`); default `#292b2e`.
- **Grey comments instead of teal** (the variant suggested in space-vim-dark's README):
  in `~/.vim/autoload/my/ui.vim`, set `'comment': '#5C6370'` in the `space` palette.
- **Any other UI colour:** edit the palette entry (`s:palettes` in `autoload/my/ui.vim`);
  every consumer (overrides, status line, fzf, dashboard, terminal) follows. One-off
  tweaks for a single group can go in `local.vim`:
  `autocmd ColorScheme space-vim-dark highlight Visual guibg=#5d4d7a`.
- **A different scheme entirely:** add the `Plug` line in `plugins.vim`, add a palette
  with the same role names to `s:palettes`, map it in `my#ui#flavor()` /
  `my#ui#apply_theme()`, and add its name to the `ColorScheme` autocommand in
  `appearance.vim`. Schemes without a palette get only minimal fallbacks.
- **Transparent background:** `let g:my_transparent = 1` in `local.vim`.

### Change the dashboard, status line, icons, sidebar

| Want | Where |
|---|---|
| No dashboard | `local.vim`: `let g:my_dashboard = 0` |
| Different dashboard sections / order / commands | `config/dashboard.vim`: `g:startify_lists`, `g:startify_commands` |
| More/fewer files per list | `config/dashboard.vim`: `g:startify_files_number` (default 6) |
| Different logo or footer | `autoload/my/dashboard.vim`: `s:logo`, `my#dashboard#footer()` |
| Status-line segments | `config/appearance.vim`: `g:lightline.active` (components live in `autoload/my/statusline.vim`) |
| Status-line colours | the palette (`autoload/my/ui.vim`), incl. `mode_*` entries for the mode pill |
| Icons off / forced on | `local.vim`: `let g:my_icons = 0` / `1` |
| Sidebar width | `local.vim`: `let g:my_explorer_width = 35` |
| Outline width / side | `config/lsp.vim`: `g:vista_sidebar_width`, `g:vista_sidebar_position` |
| Your own snippets | `Space c s` (opens `~/.vim/snippets/<filetype>.json`, VS Code format) |

### Change the leader key

In `~/.vim/vimrc`: `let g:mapleader = "\<Space>"` → e.g. `","`. Also update the two
`<leader>` lines at the bottom of `config/whichkey.vim` (they register the menu for
`'<Space>'`; use `','`), then run `:KeymapMarkdown` to refresh this guide.

### Add a shortcut

Add one line to `config/mappings.vim`, in the right group:

```vim
call s:map('n', '<leader>fy', ':Filetypes<CR>', 'Pick filetype',
      \ {'info': 'Longer description for the README', 'ex': 'When it is useful'})
```

It appears in the which-key menu, `:Cheatsheet` and (after `:KeymapMarkdown`) here.
Modes are letters: `n` normal, `x` visual, `i` insert, `o` operator, `t` terminal,
`c` cmdline; `'nx'` defines both. Options: `remap` (for `<Plug>` targets), `expr`,
`silent` (default on), `cond` (documents a requirement).
Run `~/.vim/tools/check.sh` afterwards: it fails on duplicates and on keys that would
make Vim wait.

### Remove a shortcut

Delete or comment its `s:map(…)` line and run `:KeymapMarkdown`. To restore a native key,
removing the line is enough. (Want native `Y` back? Delete the `'Y'` line.)

### Add or remove a plugin

1. Add/remove the `Plug '…'` line in `config/plugins.vim` (use `{'on': 'Cmd'}` or
   `{'for': 'filetype'}` to lazy-load).
2. Restart Vim, then `:PlugInstall` (add) or `:PlugClean` (remove; it asks before
   deleting directories).
3. Put its settings in the matching module, guarded with
   `if my#core#has('plugin-name')`.
4. `:ConfigSnapshot` to update the lockfile.

### Configure language servers

- **Add a language:** open a file of that type and press `Space l I`
  (`:LspInstallServer`), or `Space l M` for the server manager. To pin which server a
  filetype uses, add `let g:lsp_settings_filetype_<ft> = ['<server>']` in `lsp.vim`.
- **Server settings:** the `g:lsp_settings` dictionary in `lsp.vim` (for example
  pyright's `typeCheckingMode`, `'basic'` today; use `'strict'` for more checks).
- **Project-specific Python:** pyright reads `pyrightconfig.json` /
  `[tool.pyright]` in `pyproject.toml` (for example `venvPath = "."`, `venv = ".venv"`).
- **Inline diagnostics on/off:** `Space t d`. **Inlay hints:**
  `:let g:lsp_inlay_hints_enabled = 1` before opening files.
- **Disable LSP for a filetype:** `let g:lsp_settings_filetype_<ft> = []`.

### Change editor behaviour

| Want | Where |
|---|---|
| Different tab width for a language | `config/languages.vim` (FileType lines) or a project `.editorconfig` |
| Wrap long lines by default | `config/options.vim`: `set nowrap` → `set wrap` |
| No relative numbers | `config/options.vim`: remove `relativenumber`; `Space t r` toggles per window |
| Different text width | `languages.vim`: `tw=79` (the column guide follows: `colorcolumn=+1`) |
| Fold differently | `options.vim`: `foldmethod=indent` (try `syntax` or `marker`) |
| Bigger/smaller explorer | `~/.vim/local.vim`: `let g:my_explorer_width = 35` (default 30) |
| Explorer not opening at startup | `~/.vim/local.vim`: `let g:my_explorer_autostart = 0` |
| fzf window size | `navigation.vim`: `g:fzf_layout` |

### Feature switches (`~/.vim/local.vim`)

Copy `~/.vim/local.vim.example` to `~/.vim/local.vim`. It is loaded *before* the modules
and is never touched by the shared config.

| Variable | Default | Effect |
|---|---|---|
| `g:my_theme` | `'space'` | `'dark'` = Catppuccin Mocha, `'light'` = Catppuccin Latte |
| `g:my_space_background` | `'default'` | `'darker'` / `'darkest'` Space Vim Dark background |
| `g:my_dashboard` | `1` | start screen for plain `vim` ([details](#dashboard-start-screen)) |
| `g:my_icons` | auto | `0` = Unicode symbols only, `1` = force Nerd Font glyphs |
| `g:my_format_on_save` | `1` | prettier (projects with a prettier config), gofmt, whitespace trim for C/Python (`Space t f`) |
| `g:my_clipboard_sync` | `1` | copy every yank to the desktop clipboard (`Space t c`) |
| `g:my_largefile_mb` | `2` | lean-mode threshold |
| `g:my_transparent` | `0` | terminal background shows through |
| `g:my_indent_guides` | `1` | indent guides (`Space t i`) |
| `g:my_explorer_autostart` | `1` | open the explorer sidebar at startup ([details](#startup-experience)) |
| `g:my_explorer_width` | `30` | sidebar width in columns |

---

## F. Maintenance guide

| Task | How |
|---|---|
| **Update plugins** | `Space h u` (or `:ConfigUpdate`): saves a dated snapshot first, then `:PlugUpdate`. Review the log; `D` in the vim-plug window shows what changed |
| **Roll back plugins** | `vim -S ~/.vim/snapshots/plug-<date>.vim` (any snapshot) or `vim -S ~/.vim/plug-snapshot.vim` (the lockfile) |
| **Refresh the lockfile** | `:ConfigSnapshot` |
| **Check health** | `Space h h` inside Vim, or `~/.vim/tools/check.sh` in a shell (startup, test suite, timing) |
| **Measure startup** | `vim --startuptime /tmp/st.log +qa && sort -k2 -nr /tmp/st.log \| head` |
| **Troubleshoot startup** | `vim -Nu ~/.vim/vimrc -V1 -es +qa` prints errors; `:messages` after start; `vim -u NONE` for a clean Vim |
| **Bisect a problem** | Comment out a module name in the list in `~/.vim/vimrc`, restart, repeat |
| **Find a mapping conflict** | `:verbose nmap <key>` shows the definer; `check.sh` reports prefix conflicts |
| **Update language servers** | `Space l M` (vim-lsp-settings manager) or `:LspUninstallServer x` then `:LspInstallServer x` |
| **Reinstall from scratch** | Move `~/.vim/plugged` aside, then `~/.vim/tools/bootstrap.sh` |
| **Recover from a broken plugin** | `vim -S ~/.vim/plug-snapshot.vim` restores known-good commits; or remove its `Plug` line (the config keeps working without it) |
| **Repair one plugin** | `:PlugClean` then `:PlugInstall`, or delete `~/.vim/plugged/<name>` and `:PlugInstall` |

---

## G. Troubleshooting

**Colours look wrong or washed out.**
Check `:echo &termguicolors $COLORTERM`. True colour is turned on when the terminal
announces it (`COLORTERM=truecolor`, VTE ≥ 0.36, kitty, WezTerm, alacritty, foot). Inside
tmux add `set -ga terminal-overrides ",*256col*:Tc"` to `~/.tmux.conf`. On an old
terminal Vim uses computed 256-colour approximations, and with 8/16 colours it uses Vim's
default scheme.

**Icons show as boxes or blanks.**
Icons are on when a Nerd Font exists in `~/.local/share/fonts`. Over SSH the *client's*
fonts matter. Install the symbols font there, or set `let g:my_icons = 0` in
`~/.vim/local.vim`. Verify with `fc-list | grep -i "Symbols Nerd"`.

**Clipboard doesn't work.**
This Vim has no `+clipboard`, so `"+y` won't work. Use plain `y` (synced automatically
while `Space t c` is on), `Space y` in Visual mode, and `Space p` / `Space P` to paste.
`Space h h` shows the active provider (xclip here). Over SSH, OSC 52 copy needs a
terminal that supports it, and pasting uses your terminal's paste (`Ctrl+Shift+V`).
`Space t m` turns the mouse off so the terminal handles selection itself. Alternatively,
`Shift`+drag selects with the mouse on.

**LSP doesn't start.**
`Space l x` shows server status. `Space h h` lists the installed servers. Is the
filetype right (`:set ft?`)? Servers start per project root (git root or the
`pyproject.toml`/`package.json` folder). Logs: `:let g:lsp_log_file = '/tmp/lsp.log'`
before opening a file. Python virtualenvs named `.venv`, `venv` or `env` (or an active `$VIRTUAL_ENV`) are
picked up automatically; others need `pyrightconfig.json`.

**Completion doesn't pop up.**
It needs 2 typed characters (`g:asyncomplete_min_chars`). `Ctrl-Space` forces it.
It is off in explorer, fzf and commit buffers by design, and in files over 2 MB.

**Plugins fail to load.**
`:PlugStatus` shows missing ones. `:PlugInstall`, then restart. Startup errors are
collected and shown once as `[config] …` messages. The rest of the config keeps working.

**Fuzzy finder unavailable.**
`Space h h` must show fzf. With `~/.local/bin` missing from `$PATH`, Vim can't find
`fzf`, `rg` or `fd`. Your `~/.profile` and `~/.bashrc` already add it (both checked), so open a new terminal if it's missing in an old one.
Without fzf, the keys use built-in fallbacks.

**Git integration is broken.**
Signs appear only in files inside a git work tree. `:GitGutterAll` refreshes.
`:Git` must work in the file's directory. Check `git status` there.

**Startup is slow.**
`~/.vim/tools/check.sh` reports the median (~75–85 ms here before the UI; ~170 ms to a
fully drawn explorer + dashboard). Use
`vim --startuptime /tmp/st.log` and sort by the second column to find the cause.
A large `~/.viminfo` or a network filesystem working directory are common culprits.

**Ctrl+arrow (resize) or other key combos do nothing.**
GNOME Terminal (VTE) sends them correctly. Some terminals bind `Ctrl+arrows` to tabs or
workspaces, or need `TERM=xterm-256color`. Use `:resize +3` / `Space w =` as
alternatives. If `Ctrl-s` freezes the terminal *outside* Vim, that is shell flow
control (`stty -ixon`). Inside Vim it is safe.

**The explorer sidebar did not open at startup.**
`:echo g:my_explorer_autostart_skipped` prints the reason (git commit message, temp file,
terminal under 80 columns, `vim -d`…; see [the list](#startup-experience)). Empty
means it opened. `Space e` opens it by hand. Check that `~/.vim/local.vim` doesn't set
`g:my_explorer_autostart = 0`.

**The dashboard did not appear.**
`:echo g:my_dashboard_skipped` prints the reason: files on the command line, `vim -`,
`-S`, `-c`/`+cmd`, diff/batch mode, or `g:my_dashboard = 0`. `Space b h` opens it any time.

**The outline (`Space l o`) is empty.**
It needs a running language server for the file (`Space l x`). Wait for the server to
start (a second or two for pyright) and toggle again. Files with no server have no outline.

**A snippet does not expand.**
`Ctrl-j` expands only when the word before the cursor is a snippet prefix for this
filetype (or a global one). Check what exists with `:echo map(vsnip#get_complete_items(bufnr()), 'v:val.word')`.
Snippets also show in the completion menu; `Enter` on one expands it.

**`vim -S <session>` says E499.**
Only for sessions saved by the first version of this config (named with `%`). Load
those with `Space q l`, or re-save with `Space q s`: new session files use `+` and work
with `vim -S`.

**The floating terminal swallowed my keys.**
It is a real shell in Terminal mode: `F12` hides it, `Esc Esc` (or `Ctrl-w N`) switches
to Normal mode for scrolling and copying, `i` goes back.

**`vim -es` scripts exit silently after `:undo`.**
A Vim quirk in Ex/batch mode combined with `'lazyredraw'` (set by this config): `:undo`
then waits for input and Vim exits on end-of-input. Interactive Vim is unaffected. In
scripts run `set nolazyredraw` first (the test suite does).

**"E716 … fzf#vim#buffers" or "E216 fzf_swap" in `:echo v:errmsg`.**
These are harmless and never shown. fzf.vim cleans up buffers it never tracked under
`silent!`. They don't appear in `:messages`.

---

## AI assistant

**Status: nothing is installed.** No AI plugin is loaded, no account or API key is
configured, and no code is sent anywhere. The options below were evaluated in
November 2026 for Vim 9.1 with `+python3` and Node.js on a machine without a GPU.

| Solution | Inline completion | Chat | Code editing | Local models | Cost |
|---|---|---|---|---|---|
| [Claude Code](https://claude.com/claude-code) CLI in a Vim terminal | no | yes | yes — each edit is shown as a diff and needs approval | no | existing Claude subscription |
| [github/copilot.vim](https://github.com/github/copilot.vim) | yes (ghost text) | no (not offered for Vim) | no | no | Copilot Free: 2,000 completions/month; paid plans above that |
| [madox2/vim-ai](https://github.com/madox2/vim-ai) | no | yes (`:AIChat`) | yes (`:AIEdit`, replaces in place, review with undo) | via an OpenAI-compatible local server | pay per use (API key) |
| [gergap/vim-ollama](https://github.com/gergap/vim-ollama) | yes | yes | yes | yes (Ollama) | free; model downloads of 1–5 GB |
| [ggml-org/llama.vim](https://github.com/ggml-org/llama.vim) | yes | no | no | yes (llama.cpp) | free; model download of about 1 GB |
| windsurf.vim (Codeium), augment.vim, Supermaven, vim_codex | — | — | — | — | archived, completion withdrawn, or Neovim-only: not recommended |

**Recommendation**

1. **Claude Code in a terminal inside Vim** for questions about the code, explanations,
   reviews, bug hunting, tests, documentation and refactoring. Where the `claude` CLI is
   installed it needs no plugin: press `F12` (floating terminal) and run `claude`. It reads
   the project, proposes edits as diffs you accept or reject, and Vim reloads changed files
   (`autoread`). Code is sent to Anthropic only for what you ask about.
2. **Add copilot.vim only for suggestions while you type.** It is the only maintained
   option with good inline completion on a machine without a GPU. It needs a GitHub
   sign-in (`:Copilot setup`) and continuously sends the code around the cursor to GitHub.
   Use `let g:copilot_no_tab_map = v:true` with
   `imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")`, so `Tab` (completion menu)
   and `Ctrl-j`/`Ctrl-k` (snippets) keep working.
3. **Local models** keep everything on the machine, but on CPU only a 1.5–3 B-parameter
   model takes one to several seconds per suggestion and is clearly weaker; 7 B models are
   too slow for typing. vim-ollama's automatic setup also needs `python3-venv`.

The two recommended tools do different jobs (conversation and edits versus inline
completion), so they do not compete. Do not install two inline-completion plugins.

**Rules for any AI setup in this configuration:** credentials never go into tracked files
(use the plugin's own login, an environment variable, or the git-ignored
`~/.vim/local.vim`); no plugin gets unattended write or shell access; large models are not
downloaded automatically; generated changes must be reviewable before they are applied.
