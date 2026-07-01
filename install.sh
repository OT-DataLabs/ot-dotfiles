#!/bin/bash

# =====================================================================
# Script de Instalación de Dotfiles y Paquetes (Arch Linux + Hyprland)
# =====================================================================

# Colores para los mensajes de la terminal
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
YELLOW="$(tput setaf 3)[INFO]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"

echo -e "$YELLOW Iniciando la configuración del sistema..."

# 1. Verificar si estamos en el directorio correcto
DOTFILES_DIR="$HOME/ot-dotfiles"
if [ "$PWD" != "$DOTFILES_DIR" ]; then
    echo -e "$RED Por favor, ejecuta este script desde $DOTFILES_DIR"
    exit 1
fi

# 2. Actualizar el sistema antes de instalar nada
echo -e "$YELLOW Actualizando los repositorios del sistema..."
sudo pacman -Syu --noconfirm

# 3. Instalar paquetes de los repositorios oficiales
if [ -f "pkglist-oficial.txt" ]; then
    echo -e "$YELLOW Instalando paquetes oficiales..."
    sudo pacman -S --needed --noconfirm - < pkglist-oficial.txt
    echo -e "$GREEN Paquetes oficiales instalados."
else
    echo -e "$RED No se encontró pkglist-oficial.txt. Omitiendo..."
fi

# 4. Instalar y/o verificar 'yay', luego instalar paquetes AUR
if [ -f "pkglist-aur.txt" ]; then
    if ! command -v yay &> /dev/null; then
        echo -e "$YELLOW 'yay' no detectado. Instalando bootstrap de yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
    fi

    echo -e "$YELLOW Instalando paquetes de AUR con yay..."
    yay -S --needed --noconfirm - < pkglist-aur.txt
    echo -e "$GREEN Paquetes de AUR instalados."
else
    echo -e "$RED No se encontró pkglist-aur.txt. Omitiendo..."
fi

# 5. Aplicar Stow
echo -e "$YELLOW Aplicando configuraciones con GNU Stow..."

# Asegurar que el directorio base existe
mkdir -p "$HOME/.config"

STOW_FOLDERS=("hypr" "waybar" "kitty" "wpaperd")

for folder in "${STOW_FOLDERS[@]}"; do
    # Aseguramos que la subcarpeta específica exista en ~/.config
    mkdir -p "$HOME/.config/$folder"
    
    # Aplicar Stow direccionando explícitamente a la subcarpeta de la app
    stow -R -t "$HOME/.config/$folder" "$folder"
    echo -e "$GREEN Enlaces de Stow creados para $folder."
done

echo -e "$GREEN ¡Todo listo! Tu sistema se ha configurado correctamente."
