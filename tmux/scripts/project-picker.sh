#!/usr/bin/env bash
# prefix f: fuzzy-pick a project and switch to its tmux session (created in that folder if new).
# Sources: running tmux sessions + zoxide dirs (via sesh), and every repo in ~/Documents/repos.
pick=$(
  {
    sesh list --icons --hide-duplicates
    fd --type d --max-depth 1 . "$HOME/Documents/repos" 2>/dev/null
  } | fzf --ansi --no-sort --reverse --prompt 'project> ' \
        --header 'enter: switch/create  esc: cancel'
)
[ -n "$pick" ] && sesh connect "$pick"
