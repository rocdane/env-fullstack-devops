#!/bin/bash

# ========================
# DevOps Fullstack Setup
# Ubuntu 24.04 LTS
# ========================

set -e

echo "🔧 Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installation des outils de base..."
sudo apt install -y build-essential curl wget git unzip gnupg lsb-release software-properties-common net-tools zsh ufw

# --- PHP + Laravel ---
echo "🐘 Installation de PHP 8.3 et extensions..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.3 php8.3-cli php8.3-common php8.3-mbstring php8.3-xml php8.3-mysql php8.3-curl php8.3-zip php8.3-bcmath php8.3-tokenizer

echo "📦 Installation de Composer et Laravel..."
sudo apt install -y composer
composer global require laravel/installer
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc

# --- MySQL ---
echo "🗃️ Installation de MySQL..."
sudo apt install -y mysql-server

# --- Java + Spring Boot ---
echo "☕ Installation de Java 21 et Maven..."
sudo apt install -y openjdk-21-jdk openjdk-17-jdk openjdk-11-jdk openjdk-8-jdk maven

# --- Node.js + React ---
echo "⚛️ Installation de Node.js 20, Yarn et Vite..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g yarn vite create-react-app

# --- Docker & Docker Compose ---
echo "🐳 Installation de Docker et Docker Compose..."
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
sudo systemctl enable docker

# --- MicroK8s (Kubernetes local) ---
echo "☸️ Installation de MicroK8s..."
sudo snap install microk8s --classic
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
microk8s status --wait-ready
microk8s enable dns registry ingress

# --- Git & GitHub CLI ---
echo "🔧 Installation de Git et GitHub CLI..."
sudo apt install -y git
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh -y

# --- VSCode ---
echo "💻 Installation de Visual Studio Code..."
sudo snap install code --classic

# --- Oh My Zsh (optionnel mais recommandé) ---
echo "💡 Installation de Oh My Zsh..."
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# --- Pare-feu de base ---
echo "🛡️ Activation du pare-feu UFW..."
sudo ufw allow OpenSSH
sudo ufw --force enable

# --- Structure des dossiers ---
echo "📁 Création de l’arborescence des projets..."
mkdir -p ~/Projects/{laravel-app,spring-app,react-app,django-app,flask-app}
mkdir -p ~/ci_cd/github-actions
mkdir -p ~/docker/nginx

echo "✅ Installation terminée. Redémarre la VM ou reconnecte-toi pour appliquer les changements."