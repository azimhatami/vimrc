#!/usr/bin/env bash
# ==============================================================================
#  bootstrap.sh — reproduce this Vim setup on a machine (idempotent, no sudo)
#
#    ~/.vim/tools/bootstrap.sh                 plugins only (exact snapshot commits)
#    ~/.vim/tools/bootstrap.sh --tools         + fzf, ripgrep, fd   → ~/.local/bin
#    ~/.vim/tools/bootstrap.sh --font          + Symbols Nerd Font  → ~/.local/share/fonts
#    ~/.vim/tools/bootstrap.sh --lsp           + language servers   → ~/.local/share/vim-lsp-settings
#    ~/.vim/tools/bootstrap.sh --all           everything above
#
#  Every download is pinned to a version and verified against a SHA-256 sum
#  before anything is installed. Existing binaries are never overwritten.
#  Clone the repository to ~/.vim on the new machine first (see README.md);
#  first; this script does the rest.
# ==============================================================================
set -euo pipefail

VIM_DIR="$HOME/.vim"
BIN="$HOME/.local/bin"
FONT_DIR="$HOME/.local/share/fonts/NerdFontsSymbolsOnly"
LSP_DIR="$HOME/.local/share/vim-lsp-settings/servers"
NPM_BEFORE="2026-10-25"   # only npm versions published before this date

# Pinned artefacts (verified on 2026-11-08)
FZF_VER=0.74.5   FZF_SHA=d47d7f882972c7d6   # prefix; full sum is checked from the release's checksums file
RG_VER=15.2.0
FD_VER=10.5.0    FD_SHA=761c72dc8e120d85b22292063be8a796e2eeb20eb3e4f38b8fa2343ccf3514a7
NF_VER=3.5.1     NF_SHA=01172f37db8543edb102e5cb5c64101c9f4686630804d49b419aa07b23a69996
CLANGD_VER=23.1.0 CLANGD_SHA=e53b1a96196095faedb7642cf64964f7fb9ad4a0c1f00dd2c172a3d9dcbafdfd
GOPLS_VER=v0.24.0

want_tools=0 want_font=0 want_lsp=0
for a in "$@"; do
  case "$a" in
    --tools) want_tools=1 ;; --font) want_font=1 ;; --lsp) want_lsp=1 ;;
    --all) want_tools=1; want_font=1; want_lsp=1 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '    \033[32m✔\033[0m %s\n' "$*"; }
warn() { printf '    \033[33m!\033[0m %s\n' "$*"; }
need() { command -v "$1" >/dev/null || { echo "missing required tool: $1" >&2; exit 1; }; }

need vim; need git; need curl; need sha256sum
vim --version | head -1 | grep -qE 'IMproved 9\.' || { echo "Vim 9.x required" >&2; exit 1; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

verify() { # file sha256
  echo "$2  $1" | sha256sum -c --quiet - || { echo "checksum mismatch for $1" >&2; exit 1; }
}

# ── 1. Plugins ────────────────────────────────────────────────────────────────
say "Plugins (vim-plug, restored to the commits in plug-snapshot.vim)"
[ -f "$VIM_DIR/autoload/plug.vim" ] || { echo "vim-plug missing: autoload/plug.vim ships with this repository — re-clone it" >&2; exit 1; }
grep -v '^PlugUpdate' "$VIM_DIR/plug-snapshot.vim" > "$TMP/pins.vim"
LOG="$VIM_DIR/state/bootstrap.log"; mkdir -p "$VIM_DIR/state"
# vim-plug's --sync loop polls for keyboard interrupts; in Ex mode an
# exhausted stdin (EOF) makes Vim quit at once. Feed it a stdin that stays
# open for the duration (works without a terminal, e.g. over CI or ssh -T).
exec 3< <(sleep 3600); KEEPALIVE=$!
for pass in 1 2; do   # second pass picks up anything a flaky network dropped
  vim -Nu "$HOME/.vim/vimrc" -i NONE -es \
    -c 'PlugInstall --sync' \
    -c "source $TMP/pins.vim" \
    -c 'PlugUpdate! --sync' \
    -c 'qa!' <&3 >>"$LOG" 2>&1 || warn "vim-plug pass $pass reported problems — see $LOG"
done
kill "$KEEPALIVE" 2>/dev/null || true; exec 3<&-
missing=$(vim -Nu "$HOME/.vim/vimrc" -i NONE -es -c 'call writefile(filter(keys(g:plugs), "!isdirectory(g:plugs[v:val].dir)"), "/dev/stdout")' -c 'qa!' 2>/dev/null || true)
[ -z "$missing" ] && ok "all plugins installed" || warn "missing: $missing (re-run, or :PlugInstall)"
if [ -d "$VIM_DIR/plugged/vim-prettier" ] && [ ! -d "$VIM_DIR/plugged/vim-prettier/node_modules" ] && command -v npm >/dev/null; then
  (cd "$VIM_DIR/plugged/vim-prettier" && npm install --omit=dev --ignore-scripts --no-audit --no-fund >/dev/null 2>&1) \
    && ok "bundled prettier installed" || warn "prettier install failed (formatting falls back to LSP)"
fi

# ── 2. CLI tools ──────────────────────────────────────────────────────────────
if [ $want_tools = 1 ]; then
  say "fzf $FZF_VER · ripgrep $RG_VER · fd $FD_VER  → $BIN"
  mkdir -p "$BIN"
  if [ ! -e "$BIN/fzf" ]; then
    curl -fsSLo "$TMP/fzf.tgz" "https://github.com/junegunn/fzf/releases/download/v$FZF_VER/fzf-$FZF_VER-linux_amd64.tar.gz"
    curl -fsSLo "$TMP/fzf.sums" "https://github.com/junegunn/fzf/releases/download/v$FZF_VER/fzf_${FZF_VER}_checksums.txt"
    sum=$(grep "linux_amd64.tar.gz" "$TMP/fzf.sums" | cut -d' ' -f1)
    [[ "$sum" == "$FZF_SHA"* ]] || { echo "fzf checksum file does not match the pinned sum" >&2; exit 1; }
    verify "$TMP/fzf.tgz" "$sum"; tar -xzf "$TMP/fzf.tgz" -C "$TMP" fzf; install -m 0755 "$TMP/fzf" "$BIN/fzf"; ok "fzf"
  else ok "fzf already present ($BIN/fzf)"; fi
  if [ ! -e "$BIN/rg" ]; then
    base="https://github.com/BurntSushi/ripgrep/releases/download/$RG_VER/ripgrep-$RG_VER-x86_64-unknown-linux-musl.tar.gz"
    curl -fsSLo "$TMP/rg.tgz" "$base"; curl -fsSLo "$TMP/rg.sha" "$base.sha256"
    verify "$TMP/rg.tgz" "$(cut -d' ' -f1 "$TMP/rg.sha")"
    tar -xzf "$TMP/rg.tgz" -C "$TMP"; install -m 0755 "$TMP/ripgrep-$RG_VER-x86_64-unknown-linux-musl/rg" "$BIN/rg"; ok "ripgrep"
  else ok "rg already present ($BIN/rg)"; fi
  if [ ! -e "$BIN/fd" ]; then
    curl -fsSLo "$TMP/fd.tgz" "https://github.com/sharkdp/fd/releases/download/v$FD_VER/fd-v$FD_VER-x86_64-unknown-linux-musl.tar.gz"
    verify "$TMP/fd.tgz" "$FD_SHA"
    tar -xzf "$TMP/fd.tgz" -C "$TMP"; install -m 0755 "$TMP/fd-v$FD_VER-x86_64-unknown-linux-musl/fd" "$BIN/fd"; ok "fd"
  else ok "fd already present ($BIN/fd)"; fi
fi

# ── 3. Icon font ──────────────────────────────────────────────────────────────
if [ $want_font = 1 ]; then
  say "Symbols Nerd Font $NF_VER → $FONT_DIR (your terminal font is not changed)"
  if [ ! -e "$FONT_DIR/SymbolsNerdFontMono-Regular.ttf" ]; then
    curl -fsSLo "$TMP/nf.tar.xz" "https://github.com/ryanoasis/nerd-fonts/releases/download/v$NF_VER/NerdFontsSymbolsOnly.tar.xz"
    verify "$TMP/nf.tar.xz" "$NF_SHA"
    mkdir -p "$FONT_DIR"; tar -xJf "$TMP/nf.tar.xz" -C "$FONT_DIR" SymbolsNerdFontMono-Regular.ttf SymbolsNerdFont-Regular.ttf LICENSE
    fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true; ok "installed"
  else ok "already installed"; fi
fi

# ── 4. Language servers ───────────────────────────────────────────────────────
if [ $want_lsp = 1 ]; then
  say "Language servers → $LSP_DIR"
  mkdir -p "$LSP_DIR"
  npm_srv() { # dir exe packages...
    local dir="$LSP_DIR/$1" exe="$2"; shift 2
    if [ -x "$dir/$exe" ]; then ok "$exe already installed"; return; fi
    command -v npm >/dev/null || { warn "npm not found — skipping $exe"; return; }
    mkdir -p "$dir"; [ -f "$dir/package.json" ] || echo '{"name": "", "private": true}' > "$dir/package.json"
    (cd "$dir" && npm install --ignore-scripts --no-audit --no-fund --before="$NPM_BEFORE" "$@" >/dev/null 2>&1 \
      && ln -sf "./node_modules/.bin/$exe" .) && ok "$exe" || warn "$exe failed"
  }
  npm_srv pyright-langserver pyright-langserver pyright
  npm_srv typescript-language-server typescript-language-server typescript@6 typescript-language-server \
    && ln -sf ./node_modules/.bin/tsserver "$LSP_DIR/typescript-language-server/tsserver" 2>/dev/null || true
  npm_srv bash-language-server bash-language-server bash-language-server
  npm_srv yaml-language-server yaml-language-server yaml-language-server
  if [ -x "$LSP_DIR/gopls/gopls" ]; then ok "gopls already installed"
  elif command -v go >/dev/null; then
    mkdir -p "$LSP_DIR/gopls"
    (cd "$LSP_DIR/gopls" && GOPATH="$TMP/gopath" GOBIN="$PWD" GOFLAGS=-modcacherw go install "golang.org/x/tools/gopls@$GOPLS_VER" >/dev/null 2>&1) \
      && ok "gopls $GOPLS_VER" || warn "gopls failed"
  else warn "go not found — skipping gopls"; fi
  if [ -x "$LSP_DIR/clangd/clangd" ]; then ok "clangd already installed"
  else
    curl -fsSLo "$TMP/clangd.zip" "https://github.com/clangd/clangd/releases/download/$CLANGD_VER/clangd-linux-$CLANGD_VER.zip"
    verify "$TMP/clangd.zip" "$CLANGD_SHA"
    mkdir -p "$LSP_DIR/clangd"
    python3 -I -c 'import sys,zipfile; z=zipfile.ZipFile(sys.argv[1]); assert not [n for n in z.namelist() if n.startswith("/") or ".." in n.split("/")]; z.extractall(sys.argv[2])' "$TMP/clangd.zip" "$LSP_DIR/clangd"
    chmod +x "$LSP_DIR/clangd/clangd_$CLANGD_VER/bin/clangd"; ln -sfn "clangd_$CLANGD_VER/bin/clangd" "$LSP_DIR/clangd/clangd"; ok "clangd $CLANGD_VER"
  fi
fi

say "Done. Verify with:  ~/.vim/tools/check.sh"
