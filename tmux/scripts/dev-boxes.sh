#!/usr/bin/env bash
# prefix D: dev boxes on the home server, one window per box in the "boxes" session.
# Checks first that ~/bin/dev exists and the server answers, so a Mac without dev or
# Tailscale gets a message instead of an empty "boxes" session.
# $1 = the tmux client that pressed the key (popups and messages need it).
client=$1
dev="$HOME/bin/dev"
host="${DEV_HOST:-homeserver}"

say() { tmux display-message -c "$client" -d 6000 "$1"; }

if [ ! -x "$dev" ]; then
  say "~/bin/dev missing. Install: mkdir -p ~/bin && ssh $host cat code/infra/claude-dev/mac/dev > ~/bin/dev && chmod +x ~/bin/dev"
  exit 0
fi

# same shared connection as dev, so this is instant once dev has connected
if ! ssh -o BatchMode=yes -o ConnectTimeout=3 -o ControlMaster=auto \
  -o "ControlPath=$HOME/.ssh/cm-dev-%C" -o ControlPersist=10m "$host" true 2>/dev/null; then
  say "$host not reachable. Tailscale on? (ssh $host must work)"
  exit 0
fi

tmux has-session -t=boxes 2>/dev/null || tmux new-session -d -s boxes -n home
tmux switch-client -c "$client" -t boxes
# dev pick opens the chosen box as a window in the current (= boxes) session
tmux display-popup -c "$client" -E -w 80% -h 70% -b rounded -T ' dev boxes ' "$dev pick"
