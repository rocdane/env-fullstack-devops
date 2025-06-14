#!/bin/bash

# === Répertoire NVM ===
export NVM_DIR="$HOME/.nvm"

# === Étape 1 : Installer NVM ===
echo "📦 Téléchargement de nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# === Étape 2 : Charger nvm pour l'utiliser immédiatement ===
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# === Étape 3 : Installer la dernière version STABLE de Node.js ===
echo "⚙️ Installation de la dernière version stable de Node.js..."
nvm install node  # "node" = dernière version stable

# === Étape 4 : Utiliser automatiquement cette version à chaque session ===
nvm alias default node
echo "✅ Node $(node -v) installé avec npm $(npm -v)"

# === Étape 5 : Configurer le shell pour charger nvm à chaque démarrage ===
if [[ -n "$BASH_VERSION" ]]; then
  SHELL_FILE="$HOME/.bashrc"
elif [[ -n "$ZSH_VERSION" ]]; then
  SHELL_FILE="$HOME/.zshrc"
else
  SHELL_FILE="$HOME/.profile"
fi

# === Ajouter NVM au fichier de configuration si non présent ===
if ! grep -q 'nvm.sh' "$SHELL_FILE"; then
  echo -e "\n# Chargement de NVM\nexport NVM_DIR=\"$HOME/.nvm\"\n[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"" >> "$SHELL_FILE"
  echo "🔧 Ajout de NVM au fichier : $SHELL_FILE"
fi

# === Fin ===
echo -e "\n🎉 Installation terminée ! Ouvre un nouveau terminal ou fais : source $SHELL_FILE"
