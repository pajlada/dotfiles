export ZSH=~/.oh-my-zsh

ZSH_THEME="pajlada"

plugins=()

source $ZSH/oh-my-zsh.sh

export EDITOR='vim'

[[ -f ~/.zsh_local ]] && source ~/.zsh_local

alias qreset='tput reset'
pgodeps() {
    go list -f '{{range .Imports}}
{{.}}
{{end}}' $1 | sort | uniq
}

export DOTNET_CLI_TELEMETRY_OPTOUT=1
nvm-init() {
    source /usr/share/nvm/init-nvm.sh
}
