#!/usr/bin/env bash
# status bar: "repo:branch" of the active pane's folder, nothing outside a git repo
cd "$1" 2>/dev/null || exit 0
top=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
printf ' %s:%s ' "$(basename "$top")" "$(git branch --show-current 2>/dev/null)"
