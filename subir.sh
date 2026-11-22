#!/bin/bash

GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
YELLOW="$(tput setaf 3)[INFO]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"

echo -e "$YELLOW Subiendo los cambios locales recientes a github"

DOTFILES_DIR="$HOME/ot-dotfiles"
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

cd "$DOTFILES_DIR" || { echo -e "$RED No se pudo acceder a $DOTFILES_DIR"; exit 1; }

echo -e "$YELLOW Actualizando sistema"
sudo pacman -Syu --noconfirm

echo -e "$YELLOW Actualizando paquetes oficiales"
pacman -Qqen > pkglist-oficial.txt 
echo -e "$GREEN Paquetes oficiales actualizados"

if ! command -v yay &> /dev/null; then
    echo -e "$YELLOW 'yay' no detectado. Instalando bootstrap de yay"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
fi

echo -e "$YELLOW Actualizando paquetes de aur"
pacman -Qqem > pkglist-aur.txt 
echo -e "$GREEN Paquetes aur actualizados"


echo -e "$YELLOW Sincronizando configuraciones desde $CONFIG_DIR hacia $DOTFILES_DIR"

for folder in "$DOTFILES_DIR"/*/; do
    [ -d "$folder" ] || continue
    NOMBRE_ACTUAL=$(basename "$folder")

    if [[ "$NOMBRE_ACTUAL" == *.bak || "$NOMBRE_ACTUAL" == "bash" ]]; then
        continue
    fi

    if [ -d "$CONFIG_DIR/$NOMBRE_ACTUAL" ]; then
        echo -e "$YELLOW Copiando $NOMBRE_ACTUAL a $DOTFILES_DIR"
        rm -rf "$DOTFILES_DIR/$NOMBRE_ACTUAL"
        cp -r "$CONFIG_DIR/$NOMBRE_ACTUAL" "$DOTFILES_DIR/"
    else
        echo -e "$RED Advertencia: La carpeta $NOMBRE_ACTUAL no existe en $CONFIG_DIR"
    fi
done

if [ -f "$HOME/.bashrc" ]; then
    echo -e "$YELLOW Copiando .bashrc a $DOTFILES_DIR/bash/"
    mkdir -p "$DOTFILES_DIR/bash"
    cp "$HOME/.bashrc" "$DOTFILES_DIR/bash/.bashrc"
else
    echo -e "$RED Advertencia: No se encontró $HOME/.bashrc"
fi



echo -e "$YELLOW Registrando cambios en Git"
git add .
git commit -m "Actualización automatica de dotfiles"
git push origin main

echo -e "$GREEN Proceso terminado"
