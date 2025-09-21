curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

set fish_greeting ""

// plugin
curl -sSL https://git.io/g-install | sh -s -- fish
fisher install franciscolourenco/done
fisher install jorgebucaran/autopair.fish
fisher install jorgebucaran/nvm.fish
fisher install reitzig/sdkman-for-fish
fisher install kidonng/zoxide.fish
fisher install PatrickF1/fzf.fish
fisher install edc/bass
fisher install jhillyerd/plugin-git
fisher install oh-my-fish/plugin-docker-compose
fisher install evanlucas/fish-kubectl-completions
fisher install halostatue/fish-direnv
fisher install joseluisq/gitnow
fisher install gazorby/fish-exa
fisher install rayx/fish-docker
fisher install lgathy/google-cloud-sdk-fish-completion

curl -sS https://starship.rs/install.sh | sh
tee ~/.config/fish/config.fish << "EOF"
starship init fish | source
EOF

tee ~/.config/starship.toml << "EOF"
add_newline = false

format = """
$directory\
$git_branch\
$git_status\
$cmd_duration\
$python\
$nodejs\
$rust\
$c\
$cxx\
$line_break\
$character"""

[character]
success_symbol = "[➜](bold green) "
error_symbol = "[✗](bold red) "

[directory]
truncation_length = 3
style = "cyan"
read_only = " "

[git_branch]
symbol = "🌱 "
style = "purple"
format = "[$symbol$branch]($style) "

[git_status]
style = "red"
staged = "[+](green)"
modified = "[~](yellow)"
untracked = "[?](red)"
ahead = "⇡"
behind = "⇣"

[cmd_duration]
min_time = 2000
format = "took [$duration](yellow) "

[python]
symbol = "🐍 "
style = "yellow bold"
format = "via [$symbol$version]($style) "

[nodejs]
symbol = "⬢ "
style = "green bold"
format = "via [$symbol$version]($style) "

[rust]
symbol = "🦀 "
style = "red bold"
format = "via [$symbol$version]($style) "

EOF
