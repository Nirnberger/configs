#!/usr/bin/env bash
# prefix F: add the current pane's folder (or its git repo root) as a project for prefix f.
# goes into local.toml (per machine, not in the repo); sesh.toml imports it
base="$HOME/.config/sesh/sesh.toml"
conf="$HOME/.config/sesh/local.toml"
touch "$conf"
dir=$1
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) && dir=$root
path=${dir/#$HOME/\~}
name=$(basename "$dir")

if grep -qF "path = \"$path\"" "$base" "$conf" 2>/dev/null; then
  tmux display-message "Already a project: $name"
  exit 0
fi
# same folder name twice (e.g. two "api" repos): prefix the parent folder
grep -qF "name = \"$name\"" "$base" "$conf" 2>/dev/null && name="$(basename "$(dirname "$dir")")-$name"

printf '\n[[session]]\nname = "%s"\npath = "%s"\nstartup_command = "nvim"\nwindows = ["shell"]\n' \
  "$name" "$path" >>"$conf"
tmux display-message "Added project: $name (prefix f)"
