# .bash_profile

#Global options {{{
export SHELL_SESSION_HISTORY=0
export HISTCONTROL=ignoredups:ignorespace
shopt -s checkwinsize
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

#global aliases
alias ls='ls -G'
alias ll='ls -ltrG'
alias la='ls -alG'

# }}}

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# OSX specific config {{{
if [ $(uname) == "Darwin" ]; then
  
  # arm64 brew location
  if [ $(uname -m) == "arm64" ]; then
    eval $(/opt/homebrew/bin/brew shellenv)
  fi

  export TERM=xterm-256color
  export BASH_SILENCE_DEPRECATION_WARNING=1
  export PATH="/usr/local/bin:$PATH"
  # Created by `pipx`
  export PATH="$PATH:$HOME/.local/bin"

  #aliases {{{
  alias config='/opt/homebrew/bin/git --git-dir=$HOME/.mydotfiles/ --work-tree=$HOME'

  #eval $(/opt/homebrew/bin/brew shellenv)
  eval "$(starship init bash)"

  # SSH with YubiKey
  # https://aditsachde.com/posts/yubikey-ssh/
  export SSH_AUTH_SOCK="~/.ssh/agent"
  eval $(ssh-agent) > /dev/null
 
  # }}}
fi

# Linux specific config {{{
if [ $(uname) == "Linux" ]; then
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