#!/bin/bash

INSTALL_DIR="$HOME/.local/bin"
COMPOSER_PATH="$INSTALL_DIR/composer"
SETUP_FILE="composer-setup.php"

mkdir -p "$INSTALL_DIR"

# Télécharger le fichier d'installation
echo "Téléchargement de Composer..."
php -r "copy('https://getcomposer.org/installer', '$SETUP_FILE');"

# Télécharger la signature officielle
echo "Téléchargement de la signature..."
EXPECTED_SIGNATURE=$(curl -s https://getcomposer.org/installer.sig)
ACTUAL_SIGNATURE=$(php -r "echo hash_file('sha384', '$SETUP_FILE');")

# Vérification de la signature
if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    echo "❌ ERREUR : Signature invalide !"
    echo "Attendait : $EXPECTED_SIGNATURE"
    echo "Reçu     : $ACTUAL_SIGNATURE"
    rm -f "$SETUP_FILE"
    exit 1
else
    echo "✅ Signature validée"
fi

# Installation locale de Composer
php "$SETUP_FILE" --install-dir="$INSTALL_DIR" --filename=composer
rm -f "$SETUP_FILE"

# Ajouter au PATH si nécessaire
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> ~/.bashrc
    echo "Ajout de $INSTALL_DIR au PATH"
    source ~/.bashrc
fi

# Vérification
echo
"$COMPOSER_PATH" --version
echo
echo "✅ Composer est installé localement : $COMPOSER_PATH"
