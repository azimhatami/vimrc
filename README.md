## vimrc – DevOps and Backend Profiles

This repository contains a personal Vim configuration optimized for two main workflows:

- **DevOps**: working with Kubernetes, Docker, Terraform, Ansible and infrastructure code.
- **Backend**: working with backend application code (Python, web stacks, tests, etc.).

The setup is split into:

- `vimrc` – core shared configuration (UI, navigation, base plugins).
- `vimrc.devops` – DevOps-focused profile that extends the core config.
- `vimrc.backend` – Backend-focused profile that extends the core config.

You can choose which profile to load per-shell using an environment variable, or source the profile files directly.

---

## Installation

1. **Clone the repo**

```bash
git clone https://github.com/<your-username>/vimrc.git ~/.vimrc.d
cd ~/.vimrc.d
```

2. **Use `vimrc` as your main config**

In your home directory, create a minimal `~/.vimrc` that forwards to this repo:

```vim
execute 'source' fnameescape('~/.vimrc.d/vimrc')
```

3. **Install plugins with vim-plug**

Open Vim and run:

```vim
:PlugInstall
```

This will install all plugins declared in `vimrc` (NERDTree, python-mode, markdown/svelte/prettier theme, etc.).

---

## Core configuration (`vimrc`)

The core config is meant to be shared across all workflows. Highlights:

- **UI and navigation**
  - Line numbers with `relativenumber`.
  - `hlsearch`, `ignorecase`, `smartcase` for better search.
  - Splits open below/right, easy window movement with `<C-h/j/k/l>`.
  - Folding by indent, toggle fold with `<Space>`.
  - `cursorline`, colorcolumn at 79, lazy redraw for smoother scrolling.

- **Editing behavior**
  - Sensible defaults for `tabstop`, `shiftwidth`, `textwidth`.
  - Filetype‑specific indentation rules for Python, C, YAML, shell, web (js/ts/html/css/svelte), Haskell, and more via `autocmd`.
  - Trim trailing whitespace on write for C, headers and Python.

- **Plugins**
  - `nerdtree` + `nerdtree-git-plugin` for file tree with git status.
  - `space-vim-dark` colorscheme with custom highlights.
  - Python tooling: `python-mode`, `ropevim`, `autopep8`, `coverage-highlight`.
  - Web tooling: `vim-svelte`, `vim-prettier`.
  - Extra language support for Odin and (optionally) Haskell.

The core file is guarded by `g:loaded_custom_vimrc` so it is safe to source from other profile files without double-loading.

---

## DevOps profile (`vimrc.devops`)

The DevOps profile starts by sourcing the core config:

```vim
if !exists('g:loaded_custom_vimrc')
  execute 'source' fnameescape(expand('<sfile>:p:h') . '/vimrc')
endif
```

On top of that, it adds DevOps‑oriented key mappings and suggested plugins.

### Suggested plugins (optional)

Uncomment/add these in your core `vimrc` if you want them globally:

- `tpope/vim-fugitive` – powerful Git integration.
- `airblade/vim-gitgutter` – git diff signs in the sign column.
- `ekalinin/Dockerfile.vim` – Dockerfile syntax.
- `pearofducks/ansible-vim` – Ansible YAML + Jinja2.
- `hashivim/vim-terraform` – Terraform syntax and tools.

### DevOps key mappings

The profile includes examples such as:

- `\<leader>kd` – `kubectl describe -f %`
- `\<leader>ka` – `kubectl apply -f %`
- `\<leader>tf` – `terraform fmt %`
- `\<leader>tp` – `terraform plan`

Feel free to adapt these mappings to match your own kube contexts, Terraform workflows or Ansible playbook commands.

---

## Backend profile (`vimrc.backend`)

The Backend profile also starts from the core config:

```vim
if !exists('g:loaded_custom_vimrc')
  execute 'source' fnameescape(expand('<sfile>:p:h') . '/vimrc')
endif
```

On top of that, it focuses on backend developer ergonomics, especially for Python:

- Filetype‑local mappings for running code and tests:
  - `<F9>` – save and run current Python file with `python3`.
  - `<F8>` – save and run `pytest -vvv` for the current file.

You can extend this file with:

- Additional test runner integrations (e.g. `vim-test`).
- Snippets (e.g. `UltiSnips` profiles for Python, Django, FastAPI, etc.).
- LSP/completion configuration if you use tools like `coc.nvim`.

---

## Using profiles via environment variable

The recommended way to select a profile is via an environment variable and shell aliases.

1. In your shell config (`~/.bashrc`, `~/.zshrc`, etc.) add:

```bash
export VIM_PROFILE=backend  # or devops by default

alias vbackend='VIM_PROFILE=backend vim'
alias vdevops='VIM_PROFILE=devops vim'
```

2. In your main `~/.vimrc` (or in `vimrc` in this repo if you prefer), add logic like:

```vim
if !empty($VIM_PROFILE)
  if $VIM_PROFILE ==# 'devops'
    execute 'source' fnameescape('~/.vimrc.d/vimrc.devops')
  elseif $VIM_PROFILE ==# 'backend'
    execute 'source' fnameescape('~/.vimrc.d/vimrc.backend')
  endif
endif
```

With this setup:

- `vdevops` opens Vim with the DevOps profile loaded.
- `vbackend` opens Vim with the Backend profile loaded.
- Running plain `vim` will just use the core config (unless you set a default in your shell).

---

## Local, per‑project configuration (optional)

If you want extra tweaks per project (for example a special Kubernetes repo or a specific backend service), you can enable local vimrc files:

1. In your core `vimrc`:

```vim
set exrc
set secure
```

2. In a project root, create a `.vimrc` with any project‑specific settings or mappings.

Vim will automatically pick it up when you open files inside that project directory. `set secure` ensures unsafe commands are restricted, but you should still only trust local vimrc files in repositories you control.

---

## Committing and pushing

Once you are happy with your changes:

1. Stage and commit from inside the repo:

```bash
git status
git add vimrc vimrc.devops vimrc.backend README.md
git commit -m "Refine vimrc and add DevOps/Backend profiles"
```

2. Then push from your terminal:

```bash
git push origin main
```

Adjust the branch name if you are using something other than `main`.

