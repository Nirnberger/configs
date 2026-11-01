# configs

Lives directly in `~/.config`. `.gitignore` ignores everything except the folders listed in it,
so the other apps' config dirs never get committed.

| Folder | What |
| --- | --- |
| `nvim/` | Neovim (lazy.nvim, plugins pinned in `lazy-lock.json`) |
| `tmux/` | tmux, plugins via TPM (installed, not committed) |
| `alacritty/` | Alacritty terminal |
| `zsh/` | `.zshrc`, symlinked to `~/.zshrc` by `install.sh` |

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
- Open nvim once: Mason installs the language servers and formatters, treesitter compiles parsers.
- tmux installs its plugins on first start. Later, `prefix + I` re-installs and `prefix + U` updates them. The prefix is `Ctrl+Space`.

## Keeping it in sync

- New brew package you want everywhere: add it to `Brewfile`.
- After `:Lazy update`, commit `nvim/lazy-lock.json` so the other machine gets the same versions.
