typeset -U path PATH

path=(
  /opt/homebrew/opt/llvm@18/bin   # first: llvm clang wins over Apple clang
  /opt/homebrew/bin
  /opt/homebrew/sbin
  "$HOME/.local/bin"
  "$HOME/.venv/bin"
  /opt/homebrew/opt/john-jumbo/share/john
  /opt/homebrew/opt/ccache/libexec
  /Applications/aspectj/bin
  /usr/local/go/bin
  $path
)

export PATH

# Java: native (arm64) JDK 21 from brew; the one in ~/Library/Java is an x86 build
if [ -d /opt/homebrew/opt/openjdk@21 ]; then
  export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
  path=("$JAVA_HOME/bin" $path)
fi

plugins=(
  git
)

export CLASSPATH=$CLASSPATH:/Applications/aspectj/lib/*

precmd() { vcs_info }

setopt PROMPT_SUBST
autoload -Uz add-zsh-hook vcs_info

# Run the `vcs_info` hook to grab git info before displaying the prompt
add-zsh-hook precmd vcs_info

# Style the vcs_info message
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats '%b%u%c'
# Format when the repo is in an action (merge, rebase, etc)
zstyle ':vcs_info:git*' actionformats '%F{14}⏱ %*%f'
zstyle ':vcs_info:git*' unstagedstr '*'
zstyle ':vcs_info:git*' stagedstr '+'
# This enables %u and %c (unstaged/staged changes) to work,
# but can be slow on large repos
zstyle ':vcs_info:*:*' check-for-changes true

# Set the right prompt to the vcs_info message
RPROMPT='⎇ ${vcs_info_msg_0_}'
PROMPT='%(?.%F{blue}⏺.%F{red}⏺)%f %2~ > '
export HISTSIZE=20000
export HISTFILESIZE=20000

export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
  command nvm "$@"
}
# Load bash-completion only if you actually use completion on nvm
_nvm_completion() {
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \
    . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
zle -N _nvm_completion 2>/dev/null || true


fzf_history() { eval "$(history | fzf +s --tac | sed 's/ *[0-9]* *//')"; }

alias nconf='jumpDir=$(pwd) && cd ~/.config/nvim/ && nvim init.lua && cd $jumpDir && unset jumpDir'
alias rhis="fzf_history"
alias python="python3"
alias zconf="nvim ~/.zshrc"
alias rsource="source ~/.zshrc"
alias ls="eza --group-directories-first"
alias ll="eza -lah --git --group-directories-first"
alias lt="eza --tree -L2"
alias cat="bat --paging=never"
alias pip="pip3"
alias fman='compgen -c | fzf | xargs man'
alias suml='awk "{ sum+=\$1 } END { print sum }"'
alias sshpw="ssh -o PreferredAuthentications=password"
alias ..='cd ..'
alias ...='cd ../..'

[ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" # ghcup-env

# Init scripts of zoxide, fzf and starship are cached: generating them costs ~100 ms each.
# The cache is rebuilt when the tool's binary is newer (e.g. after brew upgrade).
_cached_init() {
  local name=$1; shift
  local bin=${commands[$1]} cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$name.zsh
  [[ -n $bin ]] || return
  if [[ ! -s $cache || $bin -nt $cache ]]; then
    mkdir -p ${cache:h} && "$@" >| $cache
  fi
  source $cache
}

_cached_init zoxide zoxide init zsh

# Slow lookups (~90-180 ms) run once in the shell that starts tmux; every tmux pane inherits them.
[[ -z $DBUS_LAUNCHD_SESSION_BUS_SOCKET ]] &&
  export DBUS_LAUNCHD_SESSION_BUS_SOCKET=$(launchctl getenv DBUS_LAUNCHD_SESSION_BUS_SOCKET)

# Load Angular CLI autocompletion.
# Defer Angular completion; generate once and reuse a file instead of subshell every startup
if [[ ! -f ~/.zsh/completions/_ng ]]; then
  mkdir -p ~/.zsh/completions
  ng completion script > ~/.zsh/completions/_ng 2>/dev/null || true
fi
fpath=(~/.zsh/completions $fpath)


# brew install zsh-autosuggestions (Brewfile); falls back to the old git checkout
for f in /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
         ~/Documents/repos/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [ -f "$f" ] && source "$f" && break
done
unset f

# Machine-local config, not in this repo: work setup (AWS, company tokens), secrets.
# Loaded before tmux starts, so every tmux pane inherits what it exports.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
for f in ~/.zshrc.d/*.zsh(N); do source $f; done
unset f

# persistent tmux session on startup if not open already
# only in the real terminals: shells in IDEs or app panels (Claude, IntelliJ, VS Code) stay plain
if [[ -o interactive ]] && command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" ]] &&
  [[ "$TERM_PROGRAM" == ghostty || -n "$ALACRITTY_WINDOW_ID" ]]; then
  # main already open in a terminal window: a second window would only mirror it,
  # so it gets its own session (prefix w switches between them)
  [[ -n "$(tmux list-clients -t main 2>/dev/null)" ]] && exec tmux new-session
  exec tmux new-session -A -s main
fi

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
# full security check (compaudit) only once a day, otherwise reuse the dump
_zcomp_stale=(~/.zcompdump(N.mh+24))
if (( $#_zcomp_stale )) || [[ ! -s ~/.zcompdump ]]; then
  compinit -d ~/.zcompdump
else
  compinit -C -d ~/.zcompdump
fi
unset _zcomp_stale
# End of Docker CLI completions

export PATH="$HOME/bin:$PATH"

# fzf: fd for file lists (respects .gitignore, shows dotfiles), bat preview, Tokyo Night colors
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=bg+:#292e42,fg+:#c0caf5,hl:#7aa2f7,hl+:#7dcfff,pointer:#ff9e64,prompt:#7aa2f7,info:#565f89'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree -L2 --color=always {}'"
_cached_init fzf fzf --zsh
_cached_init starship starship init zsh


