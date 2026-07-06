#!/bin/bash

GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
YELLOW="$(tput setaf 3)[INFO]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"

echo -e "$YELLOW Subiendo los cambios locales recientes a github"

DOTFILES_DIR="$HOME/ot-dotfiles"
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

if [ "$PWD" != "$DOTFILES_DIR" ]; then
    echo -e "$RED la carpeta ot-dotfiles debe de estar ubicada en $DOTFILES_DIR"
    exit 1
fi

echo -e "$YELLOW Actualizando sistema"
sudo pacman -Syu --noconfirm

if [ -f "pkglist-oficial.txt" ]; then
    echo -e "$YELLOW Actualizando paquetes oficiales"
    pacman -Qqen > pkglist-oficial.txt 
    echo -e "$GREEN Paquetes oficiales actualizados"
else
    echo -e "$RED No se encontro el archivo llamado pkglist-oficial.txt"
fi

if [ -f "pkglist-aur.txt" ]; then
    if ! command -v yay &> /dev/null; then
        echo -e "$YELLOW 'yay' no detectado. Instalando bootstrap de yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
    fi

    echo -e "$YELLOW Actualizando paquetes de aur"
    pacman -Qqem > pkglist-aur.txt 
    echo -e "$GREEN Paquetes aur actualizados"
else
    echo -e "$RED No se encontro pkglist-aur.txt"
fi

echo -e "$YELLOW Sincronizando configuraciones desde $CONFIG_DIR hacia $DOTFILES_DIR"

for folder in "$DOTFILES_DIR"/*/; do
    [ -d "$folder" ] || continue
    NOMBRE_ACTUAL=$(basename "$folder")

    if [[ "$NOMBRE_ACTUAL" == *.bak ]]; then
        echo -e "$YELLOW Carpeta .bak ignorada: $NOMBRE_ACTUAL"
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

echo -e "$YELLOW Registrando cambios en Git..."
git add .
git commit -m "Actualización automática de dotfiles"
git push origin main

echo -e "$GREEN ¡Proceso terminado!"
