#!/bin/bash

# ========================
# DevOps Fullstack Setup
# Ubuntu 24.04 LTS
# ========================

set -e

echo "🔧 Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installation des outils de base..."
sudo apt install -y build-essential curl wget git unzip gnupg ca-certificates ssh lsb-release software-properties-common net-tools zsh ufw software-properties-common apt-transport-https tmux zsh neovim nano ufw net-tools lsb-release htop jq

# --- PHP + Laravel ---
echo "🐘 Installation de PHP 8.3 et extensions..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.3 php8.3-cli php8.3-fpm php8.3-common php8.3-mbstring php8.3-xml php8.3-mysql php8.3-curl php8.3-zip php8.3-bcmath php8.3-tokenizer php8.3-gd php8.3-intl

echo "📦 Installation de Composer et Laravel..."
sudo apt install -y composer
composer global require laravel/installer
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc

# --- Java + Spring Boot ---
echo "☕ Installation de Java 21 et Maven..."
sudo apt install -y openjdk-21-jdk openjdk-17-jdk openjdk-11-jdk openjdk-8-jdk maven gradle

# --- Node.js + React ---
echo "⚛️ Installation de Node.js 24, Yarn et Vite..."
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
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
sudo microk8s status --wait-ready
sudo microk8s enable dns registry ingress

# --- Git & GitHub CLI ---
echo "🔧 Installation de Git et GitHub CLI..."
sudo apt install -y git
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh -y

# --- VSCode & Postman ---
echo "💻 Installation de Visual Studio Code et Postman..."
sudo snap install code postman --classic

# --- Pare-feu de base ---
echo "🛡️ Configuration UFW pour environnement fullstack + Docker + Kubernetes..."

# 🔁 Réinitialiser UFW (optionnel)
sudo ufw --force reset

# 🔐 Politique par défaut : bloquer le trafic entrant, autoriser le sortant
sudo ufw default deny incoming
sudo ufw default allow outgoing

# ✅ Autoriser SSH (indispensable si accès distant)
sudo ufw allow OpenSSH

# 🌐 Autoriser accès web local
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# 📦 Frontend live dev (React, Vite, etc.)
sudo ufw allow 3000/tcp
sudo ufw allow 5173/tcp

# 🐳 Autoriser réseau Docker
sudo ufw allow in on docker0
sudo ufw allow out on docker0
sudo ufw allow from 172.17.0.0/16

# ⚙️ Kubernetes : accès API, kubelet, NodePort range (si utilisé)
sudo ufw allow 6443/tcp    # kube-apiserver
sudo ufw allow 10250/tcp   # kubelet
sudo ufw allow 30000:32767/tcp  # NodePort

# 🌐 Kubernetes CNI (Calico, Flannel, etc.)
sudo ufw allow in on cni0
sudo ufw allow out on cni0

# 🔄 Autoriser le trafic routé (bridge et overlay networks)
sudo ufw default allow routed

# 🚀 Activer UFW
sudo ufw --force enable

# ✅ Afficher les règles actives
echo "✅ Règles UFW configurées :"
sudo ufw status numbered

echo "✅ Installation terminée. Redémarre la machine ou reconnecte-toi pour appliquer les changements."
