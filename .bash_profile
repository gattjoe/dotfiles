# .bash_profile

# Claude OTEL
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_EXPORTER_OTLP_ENDPOINT=https://otel.echobase.network
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_LOGS_EXPORTER=otlp
export OTEL_LOG_USER_PROMPTS=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_SERVICE_NAME=claude-code

#Global options {{{
export SHELL_SESSION_HISTORY=0
export HISTCONTROL=ignoredups:ignorespace
shopt -s checkwinsize
shopt -s histappend
HISTSIZE=100000
HISTFILESIZE=200000

#global aliases
alias ls='ls -G'
alias ll='ls -ltrG'
alias la='ls -alG'

# }}}

# OSX specific config {{{
if [ "$(uname)" = "Darwin" ]; then

  # arm64 brew location
  if [ "$(uname -m)" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  export BASH_SILENCE_DEPRECATION_WARNING=1

  # SSH with YubiKey
  export SSH_AUTH_SOCK="$HOME/.ssh/agent"

  # }}}
fi

# NVM (after brew so nvm's node wins on PATH)
# ponytail: default node goes on PATH directly; nvm.sh only loads on first `nvm` call.
# Breaks if alias/default isn't a plain version like "22" (e.g. "lts/*"); then run `nvm use`.
export NVM_DIR="$HOME/.nvm"
_nv=$(ls -d "$NVM_DIR/versions/node/v$(<"$NVM_DIR/alias/default")."* 2>/dev/null | sort -V | tail -1)
[ -n "$_nv" ] && PATH="$_nv/bin:$PATH"
unset _nv
nvm() { unset -f nvm; \. "$NVM_DIR/nvm.sh"; \. "$NVM_DIR/bash_completion"; nvm "$@"; }

# Linux specific config {{{
if [ "$(uname)" = "Linux" ]; then
  shopt -s autocd
  [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

  # enable color support of ls
  if [ -x /usr/bin/dircolors ]; then
      test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
      alias ls='ls --color=auto'
      alias dir='dir --color=auto'
      alias grep='grep --color=auto'
      alias fgrep='fgrep --color=auto'
      alias egrep='egrep --color=auto'
  fi

  # }}}
fi
