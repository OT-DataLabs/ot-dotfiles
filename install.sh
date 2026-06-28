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
DOTFILES_DIR="$HOME/dotfiles"
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

# 4. Instalar paquetes de AUR (Asumiendo que usas 'yay')
if [ -f "pkglist-aur.txt" ]; then
    # Verificar si yay está instalado
    if command -v yay &> /dev/null; then
        echo -e "$YELLOW Instalando paquetes de AUR con yay..."
        yay -S --needed --noconfirm - < pkglist-aur.txt
        echo -e "$GREEN Paquetes de AUR instalados."
    else
        echo -e "$RED 'yay' no está instalado. Instálalo primero para cargar los paquetes de AUR."
    fi
else
    echo -e "$RED No se encontró pkglist-aur.txt. Omitiendo..."
fi

# 5. Limpiar configuraciones por defecto y aplicar Stow
echo -e "$YELLOW Aplicando configuraciones con GNU Stow..."

# Lista aquí todas las carpetas que gestionas con Stow (ej. hypr, waybar, kitty)
STOW_FOLDERS=("hypr" "waybar" "kitty" "wpaperd")

for folder in "${STOW_FOLDERS[@]}"; do
    # Eliminar el directorio de configuración existente para evitar conflictos de Stow
    # Ajusta la ruta ~/.config/ si tus dotfiles van a otro lado (como ~/)
    if [ -d "$HOME/.config/$folder" ]; then
        echo -e "$YELLOW Eliminando configuración por defecto de $folder..."
        rm -rf "$HOME/.config/$folder"
    fi
    
    # Aplicar Stow
    stow "$folder"
    echo -e "$GREEN Enlaces de Stow creados para $folder."
done

echo -e "$GREEN ¡Todo listo! Tu sistema debería estar configurado."
