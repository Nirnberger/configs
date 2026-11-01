#!/usr/bin/env bash
# prefix D: dev boxes on the home server, one window per box in the "boxes" session.
# Checks first that ~/bin/dev exists and the server answers, so a Mac without dev or
# Tailscale gets a message instead of an empty "boxes" session.
# $1 = the tmux client that pressed the key (popups and messages need it).
client=$1
dev="$HOME/bin/dev"
# tmux runs this with /bin/sh's environment, which lacks DEV_HOST from ~/.zshenv: ask zsh
host="${DEV_HOST:-$(zsh -c 'print -r -- $DEV_HOST' 2>/dev/null)}"
host="${host:-homeserver}"

say() { tmux display-message -c "$client" -d 6000 "$1"; }

if [ ! -x "$dev" ]; then
  say "~/bin/dev missing. Install: mkdir -p ~/bin && ssh $host cat code/infra/claude-dev/mac/dev > ~/bin/dev && chmod +x ~/bin/dev"
  exit 0
fi

# Only checks that the server's ssh port answers (no login, so no key or passphrase involved);
# hostname and port come from ~/.ssh/config
addr=$(ssh -G "$host" 2>/dev/null | awk '/^hostname /{print $2}')
port=$(ssh -G "$host" 2>/dev/null | awk '/^port /{print $2}')
if ! nc -z -G 3 "$addr" "${port:-22}" >/dev/null 2>&1; then
  say "$host ($addr) not reachable. Tailscale on?"
  exit 0
fi

tmux has-session -t=boxes 2>/dev/null || tmux new-session -d -s boxes -n home
tmux switch-client -c "$client" -t boxes
# dev pick opens the chosen box as a window in the current (= boxes) session
tmux display-popup -c "$client" -E -w 80% -h 70% -b rounded -T ' dev boxes ' "$dev pick"
