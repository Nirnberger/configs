#!/usr/bin/env bash
# prefix f: switch to a project's tmux session (created with its layout if not running).
# Lists running sessions + projects from ~/.config/sesh/sesh.toml and local.toml (prefix F adds one there).
# Typing a folder that isn't listed still works: sesh looks it up in zoxide.
touch ~/.config/sesh/local.toml # sesh.toml imports it; sesh fails if it's missing
projects='sesh list --icons --hide-duplicates --tmux --config'

out=$(
  $projects | fzf --ansi --no-sort --reverse --print-query --prompt 'project> ' \
    --header 'enter: open   ctrl-a: all folders   ctrl-d: close session   ctrl-e: edit projects' \
    --bind 'ctrl-a:reload(sesh list --icons --hide-duplicates)' \
    --bind "ctrl-d:execute-silent(tmux kill-session -t {2..})+reload($projects)" \
    --bind "ctrl-e:execute(nvim ~/.config/sesh/local.toml)+reload($projects)"
)
[ $? -eq 130 ] && exit 0 # esc

query=$(sed -n 1p <<<"$out")
pick=$(sed -n 2p <<<"$out")
target=${pick:-$query}
[ -n "$target" ] && sesh connect "$target"
