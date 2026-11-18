#!/usr/bin/env bash
# ==============================================================================
#  check.sh — health check for the Vim configuration
#    1. headless startup must be error-free
#    2. the automated test suite (tools/test.vim)
#    3. startup time (median of 7 runs, real pseudo-terminal when python3 exists)
# ==============================================================================
set -uo pipefail
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
fail=0

printf '\033[1m1. Startup\033[0m\n'
vim -Nu "$HOME/.vim/vimrc" -i NONE -es -c "call writefile(g:my_errors, '$TMP/err')" -c 'qa!' >/dev/null 2>&1
if [ -s "$TMP/err" ]; then echo "   ✘ startup errors:"; sed 's/^/     /' "$TMP/err"; fail=1; else echo "   ✔ no startup errors"; fi

printf '\033[1m2. Test suite\033[0m\n'
timeout 300 vim -Nu "$HOME/.vim/vimrc" -es --cmd "let g:my_test_out='$TMP/tests' | let g:my_test_progress='$TMP/progress'" -S "$HOME/.vim/tools/test.vim" >"$TMP/tests.log" 2>&1
if [ ! -s "$TMP/tests" ]; then
  echo "   ✘ the test suite stopped early after $(wc -l < "$TMP/progress" 2>/dev/null || echo 0) checks; last: $(tail -1 "$TMP/progress" 2>/dev/null)"; sed "s/^/     /" "$TMP/tests.log" | tail -15; fail=1
else
  grep -v '^PASS' "$TMP/tests" | sed 's/^/   /'
  grep -q '^FAIL' "$TMP/tests" && fail=1
  echo "   ($(grep -c '^PASS' "$TMP/tests") passed)"
fi

printf '\033[1m3. Startup time\033[0m\n'
times=()
for _ in 1 2 3 4 5 6 7; do
  rm -f "$TMP/st"
  if command -v python3 >/dev/null; then
    python3 -I -c '
import os, pty, sys, time
pid, fd = pty.fork()
if pid == 0:
    os.execvp("vim", ["vim", "-Nu", os.path.expanduser("~/.vim/vimrc"), "--startuptime", sys.argv[1], "-c", "qa!"])
end = time.time() + 15
while time.time() < end:
    try: os.read(fd, 65536)
    except OSError: break
os.waitpid(pid, 0)' "$TMP/st" 2>/dev/null
  else
    vim -Nu "$HOME/.vim/vimrc" --startuptime "$TMP/st" -c 'qa!' </dev/null >/dev/null 2>&1
  fi
  times+=("$(tail -1 "$TMP/st" | awk '{print $1}')")
done
median=$(printf '%s\n' "${times[@]}" | sort -n | sed -n 4p)
echo "   median ${median} ms   (runs: $(printf '%s\n' "${times[@]}" | sort -n | tr '\n' ' '))"

[ $fail = 0 ] && printf '\033[32mAll checks passed.\033[0m\n' || printf '\033[31mSome checks failed.\033[0m\n'
exit $fail
