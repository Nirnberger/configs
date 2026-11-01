# Keys

Cheat sheet for this config. Inside nvim, press `<leader>` (Space) and wait: which-key shows
the same groups live. `<leader>?` shows the keys of the current buffer only.

German layout: `[` is `⌥5`, `]` is `⌥6`. Everything below has a `[`-free version.

## Neovim

Leader is `Space`, local leader is `,`.

### Moving around

| Key | What |
| --- | --- |
| `Ctrl h/j/k/l` | Move between splits **and** tmux panes |
| `Ctrl d` / `Ctrl u` | Half page down / up, cursor stays centred |
| `<leader>e` | Show the current file in the tree |
| `<leader>nt` | Toggle the file tree |
| `<leader>ff` | Find file |
| `<leader>fg` | Grep the project |
| `<leader>fb` | Open buffers |
| `<leader>bn` / `bp` / `bd` | Next / previous / close buffer |
| `<leader>sv` / `sh` | Split vertical / horizontal |
| `<leader>se` / `sx` | Equal split sizes / close split |
| `<leader>to` / `tx` / `tn` / `tp` | New / close / next / previous tab |
| `<leader>nh` | Clear search highlight |

### Editing

| Key | What |
| --- | --- |
| `J` / `K` (visual) | Move selected lines down / up |
| `<` / `>` (visual) | Indent and keep the selection |
| `gc` / `gcc` | Toggle comment (selection / line) |
| `<leader>cf` | Format file (also happens on save) |
| `Tab` / `Shift Tab` | Next / previous completion item, or jump inside a snippet |
| `Ctrl j` / `Ctrl k` | Next / previous completion item |
| `Enter` | Accept completion |
| `Ctrl Space` / `Ctrl e` | Open / close completion menu (in tmux press `Ctrl Space` twice, once is the tmux prefix) |

### Code (any language with an LSP)

| Key | What |
| --- | --- |
| `gd` | Go to definition |
| `K` | Docs for the symbol under the cursor |
| `grr` | References (or `<leader>xr` for a list) |
| `gri` | Go to implementation |
| `<leader>rn` | Rename symbol everywhere |
| `<leader>ca` | Code actions (quick fixes, imports, refactors) |
| `gO` | Symbols in this file |
| `Ctrl s` (insert) | Function signature |
| `<leader>ce` | ESLint: fix everything (also on save) |
| `<leader>uh` | Toggle inlay hints (parameter names, types) |
| `<leader>cm` | Mason (installed language servers / tools) |

### Problems (`<leader>x`)

| Key | What |
| --- | --- |
| `<leader>xj` / `xk` | Next / previous error or warning |
| `<leader>xx` | All problems in the project |
| `<leader>xb` | Problems in this file |
| `<leader>xr` | Where the symbol under the cursor is used |
| `<leader>xs` | Outline of the file |
| `<leader>xq` | Quickfix list |
| `<leader>ud` | Diagnostics: full text below the line ↔ short at the end of the line |

### Git (`<leader>g`)

A *hunk* is one block of changed lines; the coloured bar in the left column marks it.

| Key | What |
| --- | --- |
| `<leader>gg` | lazygit |
| `<leader>gj` / `gk` | Next / previous hunk (also `]h` / `[h`) |
| `<leader>gp` | Preview the hunk (what changed) |
| `<leader>gs` / `gr` | Stage / undo the hunk (works on a selection too) |
| `<leader>gS` / `gR` | Stage / undo the whole file |
| `<leader>gb` / `gB` | Blame this line / blame inline for every line |
| `<leader>gd` | Diff against the staged version |
| `<leader>gl` / `gf` | lazygit log / lazygit for this file's repo |

### Debug (`<leader>d`)

Java, TS/JS, Python, Rust/C/C++. Set a breakpoint, then `<leader>dc` and pick what to run.

| Key | What |
| --- | --- |
| `<leader>db` / `dB` | Breakpoint / breakpoint with a condition |
| `<leader>dc` | Start, or continue to the next breakpoint |
| `<leader>dn` / `di` / `do` | Step over / into / out of |
| `<leader>dC` | Run to the cursor |
| `<leader>de` | Value of the expression under the cursor (or selection) |
| `<leader>du` | Show / hide the debug windows |
| `<leader>dr` / `dl` / `dq` | Restart / run last again / stop |

### Tests (`<leader>T`)

Vitest, Jest, pytest. Java uses `<leader>jt` / `jT`.

| Key | What |
| --- | --- |
| `<leader>Tr` | Run the test under the cursor |
| `<leader>Tf` | Run the file |
| `<leader>Tl` | Run the last test again |
| `<leader>Td` | Debug the test under the cursor |
| `<leader>Ts` | Test tree with pass / fail |
| `<leader>To` / `TO` | Output of the test / output panel |
| `<leader>Tw` | Rerun the file on every save |
| `<leader>Tq` | Stop |

### Java (`<leader>j`, only in `.java` files)

| Key | What |
| --- | --- |
| `<leader>jo` | Organize imports |
| `<leader>jv` / `jc` | Extract variable / constant (normal or visual) |
| `<leader>jm` (visual) | Extract method |
| `<leader>jt` / `jT` | Test method / class |
| `<leader>ju` | Reload after editing `pom.xml` / `build.gradle` |

### Toggles, spelling, notes

| Key | What |
| --- | --- |
| `<leader>uw` / `uc` / `us` | Toggle wrap / conceal / spell check |
| `<leader>zz` | Fix spelling mistakes one by one |
| `<leader>zn` / `zp` | Next / previous spelling mistake |
| `<leader>zs` / `zg` / `zw` | Suggestions / add word / mark word wrong |
| `<leader>tt` | Today's note (`~/Documents/jornal`) |
| `,ll` / `,lv` | VimTeX: compile / show PDF in Skim |
| `<leader>v>` / `v<` | Next / previous LaTeX warning |

## tmux

Prefix is `Ctrl Space`: press it, let go, then the key.

| Key | What |
| --- | --- |
| `prefix t` / `g` | Split side by side / top and bottom |
| `prefix c` | New window |
| `prefix 1…9` | Go to window |
| `prefix x` | Close pane |
| `prefix h/j/k/l` | Go to pane (or `Ctrl h/j/k/l` without the prefix) |
| `prefix H/J/K/L` | Resize pane (hold and repeat) |
| `prefix z` | Zoom pane to full size and back |
| `prefix s` | Move pane to its own window |
| `prefix d` | Detach (session keeps running, `tmux a` to return) |
| `prefix r` | Reload `tmux.conf` |
| `prefix I` / `U` | Install / update plugins |
| `prefix Ctrl s` / `Ctrl r` | Save / restore sessions (also automatic every 15 min) |
| Mouse wheel | Scroll back (enters copy mode, `q` leaves) |

## Shell (zsh)

| Command | What |
| --- | --- |
| `z <part of path>` | Jump to a directory you've been to (zoxide) |
| `rhis` | Search history with fzf and run the result |
| `..` / `...` | Up one / two directories |
| `nconf` / `zconf` | Edit nvim config / `.zshrc` |
| `rsource` | Reload `.zshrc` |
| `→` (right arrow) | Accept the grey autosuggestion |

### AWS

The right side of the prompt shows the active profile: `☁ name`, red for prod / admin.
There's no default profile, so commands fail until you pick one.

| Command | What |
| --- | --- |
| `assume <profile>` | Use a profile in this shell (granted) |
| `assume` | Pick a profile from a list |
| `aws sso login --profile <p>` | Log in to an SSO profile |
| `aws sts get-caller-identity` | Who am I right now? |
| `unset AWS_PROFILE` | Back to no profile |
