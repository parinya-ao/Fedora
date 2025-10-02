#!/usr/bin/env fish
# Fish Shell Setup Script with Starship Prompt
# For DevOps, Backend, Frontend, and All Developers

# Color codes for pretty UI
set RED '\033[0;31m'
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set BLUE '\033[0;34m'
set CYAN '\033[0;36m'
set BOLD '\033[1m'
set NC '\033[0m'

function print_header
    echo -e "\n$CYAN$BOLD╔══════════════════════════════════════════════════════════╗$NC"
    echo -e "$CYAN$BOLD║$NC  $argv"
    echo -e "$CYAN$BOLD╚══════════════════════════════════════════════════════════╝$NC\n"
end

function print_step
    echo -e "$GREEN▶$NC $argv"
end

function print_success
    echo -e "$GREEN✓$NC $argv"
end

# ===============================
#  FISHER PLUGIN MANAGER
# ===============================
print_header "FISHER PLUGIN MANAGER"
print_step "Installing Fisher plugin manager..."
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
print_success "Fisher installed!"

# Disable greeting message
set -U fish_greeting ""

# ===============================
#  ESSENTIAL PLUGINS
# ===============================
print_header "FISH PLUGINS INSTALLATION"

print_step "Installing core development tools..."
fisher install franciscolourenco/done               # Notify when long commands finish
fisher install jorgebucaran/autopair.fish           # Auto-pair brackets/quotes
fisher install PatrickF1/fzf.fish                   # Fuzzy finder integration
fisher install edc/bass                             # Bash script compatibility
fisher install halostatue/fish-direnv              # Directory-based env variables

print_step "Installing version managers..."
fisher install jorgebucaran/nvm.fish               # Node.js version manager
fisher install reitzig/sdkman-for-fish             # Java/Kotlin/Scala SDK manager
curl -sSL https://git.io/g-install | sh -s -- fish # Go version manager

print_step "Installing Git enhancements..."
fisher install jhillyerd/plugin-git                # Git aliases & functions
fisher install joseluisq/gitnow                    # Advanced git workflow

print_step "Installing DevOps & Cloud tools..."
fisher install oh-my-fish/plugin-docker-compose    # Docker Compose completions
fisher install rayx/fish-docker                    # Docker completions
fisher install evanlucas/fish-kubectl-completions  # Kubernetes completions
fisher install lgathy/google-cloud-sdk-fish-completion # GCP completions

print_step "Installing quality of life improvements..."
fisher install kidonng/zoxide.fish                 # Smarter cd command
fisher install gazorby/fish-exa                    # Better ls (exa/eza)

print_success "All plugins installed!"

# ===============================
#  STARSHIP PROMPT
# ===============================
print_header "STARSHIP PROMPT INSTALLATION"
print_step "Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y
print_success "Starship installed!"

# ===============================
#  FISH CONFIG
# ===============================
print_header "CONFIGURING FISH SHELL"
print_step "Creating Fish config..."

mkdir -p ~/.config/fish

# Create fish config with starship and useful settings
tee ~/.config/fish/config.fish > /dev/null << 'EOF'
# Disable greeting
set fish_greeting ""

# Starship prompt
starship init fish | source

# Environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --group-directories-first'
alias cat='bat --style=plain --paging=never'
alias vim='nvim'
alias v='nvim'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dimg='docker images'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'

# System aliases
alias update='sudo dnf update -y && sudo dnf upgrade --refresh -y && flatpak update -y'
alias cleanup='sudo dnf autoremove -y && sudo dnf clean all'

# Zoxide (smarter cd)
if type -q zoxide
    zoxide init fish | source
    alias cd='z'
end

# Load SDKMAN if available
if test -f ~/.sdkman/bin/sdkman-init.sh
    bass source ~/.sdkman/bin/sdkman-init.sh
end

# Cargo (Rust)
if test -f ~/.cargo/env
    source ~/.cargo/env
end

# Go
if test -d ~/.go
    set -gx GOPATH ~/.go
    set -gx GOROOT ~/.go
    set -gx PATH ~/.go/bin $PATH
end

# Android SDK
if test -d ~/Android/Sdk
    set -gx ANDROID_HOME ~/Android/Sdk
    set -gx PATH $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools $PATH
end

# Local binaries
set -gx PATH ~/.local/bin $PATH
set -gx PATH /usr/local/bin $PATH
EOF

print_success "Fish config created!"

# ===============================
#  STARSHIP CONFIG
# ===============================
print_step "Creating Starship config..."

mkdir -p ~/.config

tee ~/.config/starship.toml > /dev/null << 'EOF'
format = """
[┌─](bold cyan)\
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$git_state\
$docker_context\
$kubernetes\
$terraform\
$package\
$nodejs\
$python\
$rust\
$golang\
$java\
$php\
$ruby\
$lua\
$c\
$cmake\
$line_break\
[└─](bold cyan)\
$character"""

# Right prompt for execution time
right_format = """$cmd_duration"""

add_newline = true

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"
vimcmd_symbol = "[⌨](bold yellow)"

[username]
show_always = false
format = "[$user]($style)@"
style_user = "bold yellow"

[hostname]
ssh_only = true
format = "[$hostname]($style) "
style = "bold yellow"

[directory]
truncation_length = 3
truncate_to_repo = true
format = "[$path]($style)[$read_only]($read_only_style) "
style = "bold cyan"
read_only = " 🔒"
home_symbol = "~"

[git_branch]
symbol = " "
format = "on [$symbol$branch]($style) "
style = "bold purple"

[git_status]
format = "([$all_status$ahead_behind]($style) )"
style = "bold red"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
conflicted = "🏳"
untracked = "?"
stashed = "📦"
modified = "!"
staged = "+"
renamed = "»"
deleted = "✘"

[git_state]
format = '\([$state( $progress_current/$progress_total)]($style)\) '
style = "bold yellow"

[cmd_duration]
min_time = 2000
format = "took [$duration](bold yellow)"
show_milliseconds = false

# Docker
[docker_context]
symbol = "🐳 "
format = "via [$symbol$context]($style) "
style = "bold blue"
only_with_files = true

# Kubernetes
[kubernetes]
symbol = "☸ "
format = 'on [$symbol$context( \($namespace\))]($style) '
style = "bold blue"
disabled = false

# Terraform
[terraform]
symbol = "💠 "
format = "via [$symbol$workspace]($style) "
style = "bold purple"

# Package version
[package]
symbol = "📦 "
format = "[$symbol$version]($style) "
style = "bold yellow"
display_private = false

# Languages
[nodejs]
symbol = " "
format = "via [$symbol($version )]($style)"
style = "bold green"

[python]
symbol = "🐍 "
format = 'via [${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
style = "bold yellow"

[rust]
symbol = "🦀 "
format = "via [$symbol($version )]($style)"
style = "bold red"

[golang]
symbol = "🐹 "
format = "via [$symbol($version )]($style)"
style = "bold cyan"

[java]
symbol = "☕ "
format = "via [$symbol($version )]($style)"
style = "bold red"

[php]
symbol = "🐘 "
format = "via [$symbol($version )]($style)"
style = "bold purple"

[ruby]
symbol = "💎 "
format = "via [$symbol($version )]($style)"
style = "bold red"

[lua]
symbol = "🌙 "
format = "via [$symbol($version )]($style)"
style = "bold blue"

[c]
symbol = "C "
format = "via [$symbol($version(-$name) )]($style)"
style = "bold blue"

[cmake]
symbol = "△ "
format = "via [$symbol($version )]($style)"
style = "bold blue"

# Cloud Providers
[aws]
symbol = "☁️ "
format = 'on [$symbol($profile )(\($region\) )]($style)'
style = "bold yellow"

[gcloud]
symbol = "☁️ "
format = 'on [$symbol$account(@$domain)(\($region\))]($style) '
style = "bold blue"

[azure]
symbol = "☁️ "
format = 'on [$symbol($subscription)]($style) '
style = "bold blue"

# Container & Orchestration
[helm]
symbol = "⎈ "
format = "via [$symbol($version )]($style)"
style = "bold white"

[vagrant]
symbol = "⍱ "
format = "via [$symbol($version )]($style)"
style = "bold cyan"

# Databases
[postgres]
symbol = "🐘 "
format = "via [$symbol($version )]($style)"
style = "bold blue"

[redis]
symbol = "🗃 "
format = "via [$symbol($version )]($style)"
style = "bold red"

# System
[memory_usage]
disabled = true
threshold = 75
symbol = "🧠 "
format = "via $symbol[$ram( | $swap)]($style) "
style = "bold dimmed white"

[time]
disabled = true
format = '🕙[\[ $time \]]($style) '
style = "bold white"
EOF

print_success "Starship config created!"

# ===============================
#  INSTALL ADDITIONAL TOOLS
# ===============================
print_header "ADDITIONAL CLI TOOLS"

print_step "Installing bat (better cat)..."
sudo dnf install bat -y 2>/dev/null || echo "bat already installed or not available"

print_step "Installing eza (better ls)..."
sudo dnf install eza -y 2>/dev/null || echo "eza already installed or not available"

print_step "Installing zoxide (smarter cd)..."
sudo dnf install zoxide -y 2>/dev/null || echo "zoxide already installed or not available"

print_step "Installing fzf (fuzzy finder)..."
sudo dnf install fzf -y 2>/dev/null || echo "fzf already installed or not available"

print_step "Installing ripgrep (better grep)..."
sudo dnf install ripgrep -y 2>/dev/null || echo "ripgrep already installed or not available"

print_step "Installing fd (better find)..."
sudo dnf install fd-find -y 2>/dev/null || echo "fd already installed or not available"

print_success "Additional tools installed!"

# ===============================
#  SUMMARY
# ===============================
print_header "INSTALLATION COMPLETE!"
echo -e "$GREEN$BOLD✓ Fish Shell setup completed successfully!$NC\n"
echo -e "$BOLD Installed components:$NC"
echo -e "  • Fisher plugin manager"
echo -e "  • Starship prompt (minimal & beautiful)"
echo -e "  • 15+ Fish plugins"
echo -e "  • Git enhancements"
echo -e "  • Docker/Kubernetes completions"
echo -e "  • Cloud provider support (AWS, GCP, Azure)"
echo -e "  • Language version managers (Node, Go, SDKMAN)"
echo -e "  • Modern CLI tools (bat, eza, zoxide, fzf, ripgrep)"
echo ""
echo -e "$YELLOW$BOLD⚠ IMPORTANT:$NC"
echo -e "$YELLOW  1. Run: $BOLD chsh -s /usr/bin/fish$NC$YELLOW to set Fish as default shell$NC"
echo -e "$YELLOW  2. Restart your terminal or run: $BOLD exec fish$NC"
echo -e "$YELLOW  3. Enjoy your new minimal & powerful terminal!$NC"
echo ""
echo -e "$BLUE ℹ Useful commands:$NC"
echo -e "  • $BOLD fisher list$NC - List installed plugins"
echo -e "  • $BOLD fisher update$NC - Update all plugins"
echo -e "  • $BOLD starship config$NC - Edit Starship config"
echo -e "  • $BOLD z <dir>$NC - Smart directory jump with zoxide"
echo ""
