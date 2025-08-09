if status is-interactive

end

set -g fish_greeting
set -g fish_emoji_width 2

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx BROWSER brave

fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/go/bin
fish_add_path ~/.deno/bin
fish_add_path ~/.bun/bin
fish_add_path /opt/homebrew/bin
fish_add_path ~/.pyenv/bin
fish_add_path ~/.rbenv/bin
fish_add_path ~/.tfenv/bin
fish_add_path ~/.krew/bin

set -gx GOPATH ~/go
set -gx GOROOT /usr/local/go
set -gx RUSTUP_HOME ~/.rustup
set -gx CARGO_HOME ~/.cargo
set -gx PYENV_ROOT ~/.pyenv
set -gx RBENV_ROOT ~/.rbenv
set -gx NVM_DIR ~/.nvm
set -gx DENO_INSTALL ~/.deno
set -gx BUN_INSTALL ~/.bun

set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_DEFAULT_OPTS '--height 50% --layout=reverse --border --inline-info --preview="bat --color=always --style=header,grid --line-range :300 {}"'

set -gx DOCKER_BUILDKIT 1
set -gx COMPOSE_DOCKER_CLI_BUILD 1

set -gx KUBECONFIG ~/.kube/config

if command -v pyenv >/dev/null
    pyenv init - | source
end

if command -v rbenv >/dev/null
    rbenv init - | source
end

if command -v zoxide >/dev/null
    zoxide init fish | source
end

if command -v direnv >/dev/null
    direnv hook fish | source
end

if command -v starship >/dev/null
    starship init fish | source
end
