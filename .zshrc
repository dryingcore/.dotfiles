# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

alias github='cd $HOME/Documents/github'
alias dotfiles='cd $HOME/.config'
alias codehere='code . --reuse-window'
alias neo='neofetch'
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias sourcezsh='source $HOME/.zshrc'
alias editzsh='nano $HOME/.zshrc'
alias home='cd $HOME'
alias config="cd $HOME/.config"
alias please='sudo'

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias setwall='~/.config/setwall.sh'

export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin/bin"
export GOROOT="/usr/local/go"
export PATH="$GOBIN:$GOROOT/bin:$PATH"

