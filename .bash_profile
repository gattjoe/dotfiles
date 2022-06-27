# .bash_profile

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
  alias ls='ls -G'
  alias ll='ls -ltrG'
  alias la='ls -alG'
  alias config='/opt/homebrew/bin/git --git-dir=$HOME/.mydotfiles/ --work-tree=$HOME'

  #eval $(/opt/homebrew/bin/brew shellenv)
  eval "$(starship init bash)"

  # SSH with YubiKey
  # https://aditsachde.com/posts/yubikey-ssh/
  export SSH_AUTH_SOCK="~/.ssh/agent"
  eval $(ssh-agent) > /dev/null
 
  # }}}
fi
