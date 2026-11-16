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

# AWS profile in the right prompt, red when it looks dangerous
aws_prompt() {
  local p="${AWS_PROFILE:-$AWS_VAULT}"
  [[ -z "$p" ]] && return
  if [[ "$p" == *(prod|admin)* ]]; then
    print -n "%F{red}☁ $p%f "
  else
    print -n "%F{yellow}☁ $p%f "
  fi
}

# Set the right prompt to the vcs_info message
RPROMPT='$(aws_prompt)⎇ ${vcs_info_msg_0_}'
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

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

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

# persistent tmux session on startup if not open already
if [[ -o interactive ]] && command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" ]]; then
  # main already open in a terminal window: a second window would only mirror it,
  # so it gets its own session (prefix w switches between them)
  [[ -n "$(tmux list-clients -t main 2>/dev/null)" ]] && exec tmux new-session
  exec tmux new-session -A -s main
fi

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
compinit -d ~/.zcompdump
# End of Docker CLI completions

# AWS: no default profile, so nothing deploys as admin by accident.
# Pick one per shell: `assume <profile>` (granted) or `export AWS_PROFILE=<profile>`.
# SSO profiles: `aws sso login --profile <profile>` once per session.
alias assume="source assume" # granted needs to run in this shell to set the env

export PATH="$HOME/bin:$PATH"

# fzf: fd for file lists (respects .gitignore, shows dotfiles), bat preview, Tokyo Night colors
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=bg+:#292e42,fg+:#c0caf5,hl:#7aa2f7,hl+:#7dcfff,pointer:#ff9e64,prompt:#7aa2f7,info:#565f89'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree -L2 --color=always {}'"
source <(fzf --zsh)
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

export GH_PACKAGES_TOKEN="$(gh auth token)"
export AWS_REGION=eu-central-1

# machine-local secrets (not in the repo), e.g. MCP_API_KEY
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
