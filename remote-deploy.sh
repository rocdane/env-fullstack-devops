#!/bin/bash
set -euo pipefail
set -x

# === Configuration globale ===
USER=""
HOST=""
PORT=""
SSH_KEY="$HOME/.ssh/"
REMOTE_HOST=""
REMOTE_DIR=""
LOCAL_DIR=""

# === Étape 1 : Synchronisation des fichiers Laravel avec lftp ===
lftp -e "set sftp:connect-program 'ssh -a -x -i ${SSH_KEY} -p ${PORT}'" -u ${USER} sftp://${HOST} <<EOF
lcd $LOCAL_DIR
cd $REMOTE_DIR
mirror --reverse --verbose \
  --exclude-glob .git/ \
  --exclude-glob vendor/ \
  --exclude-glob node_modules/ \
  --exclude-glob storage/logs/* \
  --exclude-glob storage/framework/sessions/* \
  --exclude-glob tests/ \
  --exclude-glob deploy.sh
bye
EOF

# === Étape 2 : Déploiement Laravel via SSH ===
ssh -i "$SSH_KEY" -p "$PORT" "$USER@$REMOTE_HOST" bash <<'EOSSH'

set -e

cd $REMOTE_DIR

### === 1. Installer Node.js localement via NVM ===
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  echo "📦 Téléchargement de NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Charger NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Installer dernière version stable
nvm install node
nvm alias default node

echo "✅ Node $(node -v), npm $(npm -v)"

### === 2. Installer Composer localement ===
INSTALL_DIR="$HOME/.local/bin"
COMPOSER="$INSTALL_DIR/composer"
SETUP_FILE="composer-setup.php"
mkdir -p "$INSTALL_DIR"

if [ ! -f "$COMPOSER" ]; then
  echo "📦 Téléchargement de Composer..."
  php -r "copy('https://getcomposer.org/installer', '$SETUP_FILE');"
  EXPECTED_SIGNATURE=$(curl -s https://getcomposer.org/installer.sig)
  ACTUAL_SIGNATURE=$(php -r "echo hash_file('sha384', '$SETUP_FILE');")

  if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    echo "❌ Signature Composer invalide !"
    rm -f "$SETUP_FILE"
    exit 1
  fi

  php "$SETUP_FILE" --install-dir="$INSTALL_DIR" --filename=composer
  rm -f "$SETUP_FILE"
fi

export PATH="$INSTALL_DIR:$PATH"

echo "✅ Composer installé : $(composer --version)"

### === 3. Déploiement Laravel ===

echo "📦 Installation des dépendances PHP (production)"
composer install --no-dev --optimize-autoloader

if [ -f package.json ]; then
  echo "⚙️ Installation des dépendances JS"
  npm install
  npm run build
else
  echo "⚠️ Aucun frontend à compiler (pas de package.json)"
fi

echo "🔧 Cache Laravel"
php artisan config:cache
php artisan route:cache

echo "📂 Migration DB"
php artisan migrate --force

echo "✅ Déploiement Laravel terminé"
EOSSH
