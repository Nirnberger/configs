#!/usr/bin/env bash
# prefix D: dev boxes on the home server, one window per box in the "boxes" session.
# Checks first that ~/bin/dev exists and the server answers, so a Mac without dev or
# Tailscale gets a message instead of an empty "boxes" session.
# $1 = the tmux client that pressed the key (popups and messages need it).
client=$1
if [ "$client" = --pick ]; then pick_mode=1; client=$2; fi
dev="$HOME/bin/dev"
# tmux runs this with /bin/sh's environment, which lacks DEV_HOST from ~/.zshenv: ask zsh
host="${DEV_HOST:-$(zsh -c 'print -r -- $DEV_HOST' 2>/dev/null)}"
host="${host:-homeserver}"

# --pick (inside the popup): make "boxes" the current session for dev's tmux commands,
# so the box window is created there, then switch the client over if something was picked
if [ -n "${pick_mode:-}" ]; then
  boxes_id=$(tmux display -p -t boxes '#{session_id}')
  export TMUX="${TMUX%,*},${boxes_id#\$}"
  unset TMUX_PANE
  before=$(tmux display -p -t boxes '#{window_id}')
  "$HOME/bin/dev" pick
  if [ "$(tmux display -p -t boxes '#{window_id}')" != "$before" ]; then
    tmux switch-client -c "$client" -t boxes
  fi
  exit 0
fi

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
popup() { tmux display-popup -c "$client" -E -w 80% -h 70% -b rounded -T ' dev boxes ' "$1"; }

# Already in boxes: dev pick opens/selects the box right here
# (display -c would report the newest session, not the client's, so ask list-clients)
current=$(tmux list-clients -F '#{client_name} #{session_name}' | awk -v c="$client" '$1 == c {print $2}')
if [ "$current" = boxes ]; then
  popup "$dev pick"
  exit 0
fi

# Elsewhere: stay put while picking, switch to boxes only once a box was chosen (Esc = no switch).
# "home" is the resting window, so any pick shows up as a different active window.
tmux list-windows -t boxes -F '#W' | grep -qx home || tmux new-window -d -t boxes: -n home
tmux select-window -t boxes:home
popup "$(printf '%q' "$0") --pick $(printf '%q' "$client")"
