export ZSH=~/.oh-my-zsh

ZSH_THEME="pajlada"

plugins=()

source $ZSH/oh-my-zsh.sh

export EDITOR='vim'
export DOTNET_CLI_TELEMETRY_OPTOUT=1

[[ -f ~/.zsh_local ]] && source ~/.zsh_local

alias qreset='tput reset'
pgodeps() {
    go list -f '{{range .Imports}}
{{.}}
{{end}}' $1 | sort | uniq
}

nvm-init() {
    source /usr/share/nvm/init-nvm.sh
}

tag-release() {
    local _version="$1"
    if [ -z "$_version" ]; then
        echo "Missing version. usage: $0 version (e.g. $0 v0.7.3)"
        return 1
    fi
    if [ "$(echo $_version | head -c 1)" != "v" ]; then
        _version="v$_version"
    fi
    echo "Making an annotated git tag '$_version'"
    git tag $_version -am "$_version"
}

branch-release() {
    local _version="$1"
    if [ -z "$_version" ]; then
        echo "Missing version. usage: $0 version (e.g. $0 v0.7.3)"
        return 1
    fi
    if [ "$(echo $_version | head -c 1)" = "v" ]; then
        _version="${_version:1}"
    fi
    export _branch_name="release/$_version"
    echo "Making an git release branch '$_version'"
    git checkout -b "$_branch_name"
}

full-release() {
    local _version="$1"
    if [ -z "$_version" ]; then
        echo "Missing version. usage: $0 version (e.g. $0 v0.7.3)"
        return 1
    fi
    tag-release "$_version"
    git push --follow-tags
    branch-release "$_version"
    git push -u origin "$_branch_name"
}
