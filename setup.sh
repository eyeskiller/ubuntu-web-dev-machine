#!/bin/bash

# Ubuntu 24.04 Future-Proof Web Development Setup
# Run this script line by line or save as setup.sh and execute

echo "🚀 Starting Ubuntu 24.04 Web Development Setup..."

# ==========================================
# SYSTEM ESSENTIALS
# ==========================================
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "🔧 Installing essential build tools..."
sudo apt install curl wget git build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release zsh tree htop neofetch -y

# ==========================================
# GIT CONFIGURATION
# ==========================================
echo "🔧 Setting up Git (you'll need to enter your details)..."
echo "Enter your Git username:"
read git_username
echo "Enter your Git email:"
read git_email
git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global init.defaultBranch main

# ==========================================
# NVM (NODE VERSION MANAGER)
# ==========================================
echo "📦 Installing NVM (Node Version Manager)..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

echo "🔄 Reloading shell configuration..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

echo "📦 Installing latest LTS Node.js..."
nvm install --lts
nvm use --lts
nvm alias default node

echo "✅ Enabling Corepack for modern package managers..."
corepack enable

# ==========================================
# PYTHON VERSION MANAGER
# ==========================================
echo "🐍 Installing pyenv (Python Version Manager)..."
curl https://pyenv.run | bash

echo "🔧 Adding pyenv to shell configuration..."
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# ==========================================
# JAVA VERSION MANAGER
# ==========================================
echo "☕ Installing SDKMAN (Java/JVM Version Manager)..."
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# ==========================================
# MODERN TERMINAL SETUP
# ==========================================
echo "⭐ Installing Starship (Modern Terminal Prompt)..."
curl -sS https://starship.rs/install.sh | sh

echo "🔧 Configuring Zsh with Starship..."
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

echo "🐚 Changing default shell to Zsh..."
chsh -s $(which zsh)

# ==========================================
# DOCKER & CONTAINERIZATION
# ==========================================
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

echo "🧹 Cleaning up Docker installation script..."
rm get-docker.sh

# ==========================================
# VISUAL STUDIO CODE
# ==========================================
echo "💻 Installing Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code -y

echo "🧹 Cleaning up VS Code installation files..."
rm packages.microsoft.gpg

# ==========================================
# MODERN BROWSERS
# ==========================================
echo "🌐 Installing Google Chrome..."
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt update
sudo apt install google-chrome-stable -y

echo "🦊 Installing Firefox (latest)..."
sudo snap install firefox

# ==========================================
# NEXT-GEN JAVASCRIPT RUNTIMES
# ==========================================
echo "🥟 Installing Bun (Fast JavaScript Runtime)..."
curl -fsSL https://bun.sh/install | bash

echo "🦕 Installing Deno (Secure TypeScript Runtime)..."
curl -fsSL https://deno.land/install.sh | sh

# ==========================================
# DATABASE SETUP WITH DOCKER
# ==========================================
echo "🗄️ Setting up development databases with Docker..."
mkdir -p ~/dev-databases
cd ~/dev-databases

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  postgres:
    image: postgres:15
    container_name: dev_postgres
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  mysql:
    image: mysql:8
    container_name: dev_mysql
    environment:
      MYSQL_ROOT_PASSWORD: dev
      MYSQL_DATABASE: dev
      MYSQL_USER: dev
      MYSQL_PASSWORD: dev
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped

  redis:
    image: redis:7
    container_name: dev_redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

  mongodb:
    image: mongo:6
    container_name: dev_mongo
    environment:
      MONGO_INITDB_ROOT_USERNAME: dev
      MONGO_INITDB_ROOT_PASSWORD: dev
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
    restart: unless-stopped

volumes:
  postgres_data:
  mysql_data:
  redis_data:
  mongo_data:
EOF

echo "✅ Database Docker Compose file created at ~/dev-databases/"

# ==========================================
# USEFUL DEVELOPMENT TOOLS
# ==========================================
echo "🔧 Installing additional development tools..."
sudo snap install postman
sudo snap install discord
sudo snap install slack

# ==========================================
# DOTFILES SETUP
# ==========================================
echo "📁 Setting up dotfiles repository..."
mkdir -p ~/.dotfiles
cd ~/.dotfiles
git init

echo "🔧 Creating initial dotfiles..."
cat > ~/.dotfiles/.gitconfig << EOF
[user]
	name = $git_username
	email = $git_email
[init]
	defaultBranch = main
[core]
	editor = code --wait
[pull]
	rebase = true
[alias]
	st = status
	co = checkout
	br = branch
	up = !git pull --rebase --prune \$@ && git submodule update --init --recursive
	cob = checkout -b
	cm = !git add -A && git commit -m
	save = !git add -A && git commit -m 'SAVEPOINT'
	wip = !git add -u && git commit -m 'WIP'
	undo = reset HEAD~1 --mixed
	amend = commit -a --amend
	wipe = !git add -A && git commit -qm 'WIPE SAVEPOINT' && git reset HEAD~1 --hard
	bclean = "!f() { git branch --merged \${1-master} | grep -v " \${1-master}\$" | xargs -n 1 git branch -d; }; f"
	bdone = "!f() { git checkout \${1-master} && git up && git bclean \${1-master}; }; f"
EOF

# ==========================================
# SHELL CONFIGURATION FILES
# ==========================================
echo "🐚 Setting up advanced shell configuration..."
cat > ~/.zshrc << 'EOF'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# Docker aliases
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'

# Node/NPM aliases
alias ni='npm install'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nrd='npm run dev'
alias nrb='npm run build'

# Development shortcuts
alias code.='code .'
alias serve='python3 -m http.server'
alias myip='curl ipinfo.io/ip'

# Starship prompt
eval "$(starship init zsh)"
EOF

# ==========================================
# VS CODE EXTENSIONS SETUP
# ==========================================
echo "🧩 Installing essential VS Code extensions..."
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension esbenp.prettier-vscode
code --install-extension ms-vscode.vscode-eslint
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-python.python
code --install-extension ms-vscode.vscode-json
code --install-extension rangav.vscode-thunder-client
code --install-extension ms-vscode.live-server
code --install-extension formulahendry.auto-rename-tag
code --install-extension christian-kohler.path-intellisense
code --install-extension ms-vscode.vscode-gitlens
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-azuretools.vscode-docker
code --install-extension PKief.material-icon-theme
code --install-extension zhuangtongfa.material-theme
code --install-extension aaron-bond.better-comments
code --install-extension usernamehw.errorlens

# ==========================================
# QUICK TEST INSTALLATIONS
# ==========================================
echo "🧪 Testing installations..."
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "Git version: $(git --version)"
echo "Docker version: $(docker --version)"

# ==========================================
# FINAL SETUP INSTRUCTIONS
# ==========================================
echo ""
echo "🎉 Setup Complete! Here's what to do next:"
echo ""
echo "1. RESTART your computer to ensure all changes take effect"
echo "2. Open a new terminal (it should be Zsh with Starship prompt)"
echo "3. Test Node.js: nvm list"
echo "4. Test Docker: docker run hello-world"
echo "5. Start databases when needed: cd ~/dev-databases && docker compose up postgres -d"
echo ""
echo "📚 Useful commands:"
echo "• Switch Node versions: nvm use 18 or nvm use 20"
echo "• Install Python: pyenv install 3.11.0 && pyenv global 3.11.0"
echo "• Install Java: sdk install java 21-tem"
echo "• Use different package managers: npm, yarn, pnpm, or bun"
echo ""
echo "🔧 Database connections (when running):"
echo "• PostgreSQL: localhost:5432, user: dev, password: dev"
echo "• MySQL: localhost:3306, user: dev, password: dev"
echo "• MongoDB: localhost:27017, user: dev, password: dev"
echo "• Redis: localhost:6379"
echo ""
echo "💡 Pro tip: Enable Settings Sync in VS Code to sync across machines!"
echo ""
echo "Happy coding! 🚀"
