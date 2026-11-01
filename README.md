# configs

Lives directly in `~/.config`. `.gitignore` ignores everything except the folders listed in it,
so the other apps' config dirs never get committed.

| Folder | What |
| --- | --- |
| `nvim/` | Neovim (lazy.nvim, plugins pinned in `lazy-lock.json`) |
| `tmux/` | tmux, plugins via TPM (installed, not committed) |
| `alacritty/` | Alacritty terminal |
| `zsh/` | `.zshrc`, symlinked to `~/.zshrc` by `install.sh` |

All key bindings: [KEYS.md](KEYS.md).

## New Mac

```bash
mkdir -p ~/.config && cd ~/.config
git init -b main
git remote add origin https://github.com/Nirnberger/configs.git
git fetch origin
git checkout -f main
./install.sh
```

Uses HTTPS since the new Mac has no SSH key yet. After adding one:
`git remote set-url origin git@github.com:Nirnberger/configs.git`.

Then:

- Install Alacritty by hand (see the note in `Brewfile`).
- `install.sh` already installs the nvim plugins and every Mason package (language servers,
  formatters, debuggers). Treesitter compiles its parsers the first time you open a file.
- Dev boxes (`prefix D` in tmux) need Tailscale, `Host homeserver` (or `DEV_HOST` in `~/.zshenv`)
  in `~/.ssh/config`, and `~/bin/dev` from the server, which isn't in this repo. `install.sh`
  fetches it when the server is reachable; otherwise set those up and run it again. Until then
  `prefix D` only shows what's missing.
- tmux installs its plugins on first start. Later, `prefix + I` re-installs and `prefix + U` updates them. The prefix is `Ctrl+Space`.

## Keeping it in sync

- New brew package you want everywhere: add it to `Brewfile`.
- After `:Lazy update`, commit `nvim/lazy-lock.json` so the other machine gets the same versions.
