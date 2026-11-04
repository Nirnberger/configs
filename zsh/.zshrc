#export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
#export BROWSER="firefox"
#export PATH=$PATH:~/.local/bin/
#export PATH=$PATH:/opt/homebrew/Cellar/john-jumbo/1.9.0_1/share/john
#export PATH=$PATH:/opt/homebrew/opt/ccache/libexec
#export PATH=$PATH:/Applications/aspectj/bin/
#export PATH=$PATH:~/.local/bin
#export PATH=$PATH:~/.venv/bin/
#export GOPATH=/usr/local/go
#export PATH=$PATH:/usr/local/go/bin
#export JAVA_HOME="/Users/deluxe/Library/Java/JavaVirtualMachines/openjdk-21/Contents/Home"
#export LANG="en_US.UTF-8"

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
#PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '
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
alias ls="ls --color"
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
# python env with pacages
#source ~/.venv/bin/activate

# Start tmux
#if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#  exec tmux
#fi

# persitent tmux session on startup if not open already
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
#
# AWS: no default profile, so nothing deploys as admin by accident.
# Pick one per shell: `assume <profile>` (granted) or `export AWS_PROFILE=<profile>`.
# SSO profiles: `aws sso login --profile <profile>` once per session.
alias assume="source assume" # granted needs to run in this shell to set the env
#
# End of Docker CLI completions
export PATH="$HOME/bin:$PATH"
