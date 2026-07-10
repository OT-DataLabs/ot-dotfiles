#!/bin/bash

# Colores para los mensajes de la terminal
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
YELLOW="$(tput setaf 3)[INFO]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"

echo -e "$YELLOW Instalando los archivos de ot-dotfiles a ~/.config"

DOTFILES_DIR="$HOME/ot-dotfiles"
if [ "$PWD" != "$DOTFILES_DIR" ]; then
    echo -e "$RED la carpteta ot-dotfiles debe de estar ubicada en $DOTFILES_DIR"
    exit 1
fi

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
        echo -e "$YELLOW 'yay' no detectado. Instalando bootstrap de yay..."
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

FOLDERS=()

for folder in "$DOTFILES_DIR"/*/; do
    [ -d "$folder" ] || continue  
    DIR_NAME=$(basename "$folder")
    FOLDERS+=("$DIR_NAME")
done

echo -e "Carpetas dentro de $DOTFILES_DIR"
for carpeta in "${FOLDERS[@]}"; do
    echo -e "- $carpeta"
done

i=0
for folder in "$DOTFILES_DIR"/*/; do
    [ -d "$folder" ] || continue
    NOMBRE_ACTUAL=$(basename "$folder")

    if [ "${FOLDERS[i]}" == "$NOMBRE_ACTUAL" ]; then
        echo -e "$YELLOW Copiando carpeta $folder en $CONFIG_DIR"

        if [ -d "$CONFIG_DIR/${FOLDERS[i]}.bak" ]; then
            rm -rf "$CONFIG_DIR/${FOLDERS[i]}.bak"
            mv "$CONFIG_DIR/${FOLDERS[i]}" "$CONFIG_DIR/${FOLDERS[i]}.bak"
            cp -r "$DOTFILES_DIR/${FOLDERS[i]}" "$CONFIG_DIR"

        elif [ -d "$CONFIG_DIR/${FOLDERS[i]}" ]; then
            mv "$CONFIG_DIR/${FOLDERS[i]}" "$CONFIG_DIR/${FOLDERS[i]}.bak"
            cp -r "$DOTFILES_DIR/${FOLDERS[i]}" "$CONFIG_DIR"


        else
            cp -r "$DOTFILES_DIR/${FOLDERS[i]}" "$CONFIG_DIR"
        fi

        ((i++))
    fi
done

echo -e "Instalacion terminada"
