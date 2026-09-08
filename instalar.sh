#!/bin/bash

GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
YELLOW="$(tput setaf 3)[INFO]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"

echo -e "$YELLOW Instalando los archivos de ot-dotfiles a ~/.config"

DOTFILES_DIR="$HOME/ot-dotfiles"

cd "$DOTFILES_DIR" || { echo -e "$RED No se pudo acceder a $DOTFILES_DIR"; exit 1; }

echo -e "$YELLOW Actualizando repositorios de el sistema"
sudo pacman -Syu --noconfirm

if [ -f "pkglist-oficial.txt" ]; then
    echo -e "$YELLOW Instalando paquetes oficiales"
    sudo pacman -S --needed --noconfirm - < pkglist-oficial.txt
    echo -e "$GREEN Paquetes oficiales instalados"
else
    echo -e "$RED No se encontro el archivo llamado pkglist-oficial.txt"
fi

if [ -f "pkglist-aur.txt" ]; then
    if ! command -v yay &> /dev/null; then
        echo -e "$YELLOW 'yay' no detectado. Instalando bootstrap de yay"
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
    fi

    echo -e "$YELLOW Instalando paquetes de aur con yay"
    yay -S --needed --noconfirm - < pkglist-aur.txt
    echo -e "$GREEN Paquetes aur instalados"
else
    echo -e "$RED No se encontro pkglist-aur.txt"
fi

CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

echo -e "Carpetas dentro de $DOTFILES_DIR"

for folder in "$DOTFILES_DIR"/*/; do
    [ -d "$folder" ] || continue  
    DIR_NAME=$(basename "$folder")
    
    if [[ "$DIR_NAME" == ".git" ]]; then continue; fi

    echo -e "- $DIR_NAME"
    echo -e "$YELLOW Copiando carpeta $DIR_NAME en $CONFIG_DIR"

    if [ -d "$CONFIG_DIR/$DIR_NAME" ]; then
        rm -rf "$CONFIG_DIR/$DIR_NAME.bak"
        mv "$CONFIG_DIR/$DIR_NAME" "$CONFIG_DIR/$DIR_NAME.bak"
    fi

    cp -r "$folder" "$CONFIG_DIR"
done

echo -e "$GREEN Instalacion terminada"
