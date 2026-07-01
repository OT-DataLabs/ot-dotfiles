#!/bin/bash

# =====================================================================
# Script para Actualizar Listas de Paquetes y Sincronizar con GitHub
# =====================================================================

# Colores para los mensajes de la terminal
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
YELLOW="$(tput setaf 3)[INFO]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"

DOTFILES_DIR="$HOME/dotfiles"

# 1. Verificar si estamos en el directorio correcto
if [ "$PWD" != "$DOTFILES_DIR" ]; then
    echo -e "$RED Por favor, ejecuta este script desde $DOTFILES_DIR"
    exit 1
fi

# 2. Actualizar las listas de paquetes del sistema
echo -e "$YELLOW Generando listas de paquetes actualizadas..."

# Paquetes oficiales (nativos de los repositorios de Arch)
pacman -Qqen > pkglist-oficial.txt

# Paquetes de AUR (instalados mediante yay/foreign)
pacman -Qqem > pkglist-aur.txt

echo -e "$GREEN Listas de paquetes actualizadas correctamente."

# 3. Verificar si hay cambios reales en los dotfiles o en las listas
if [ -z "$(git status --porcelain)" ]; then
    echo -e "$GREEN No hay cambios nuevos que guardar. Tu repositorio ya está al día."
    exit 0
fi

# Mostrar al usuario qué archivos han cambiado antes de continuar
echo -e "\n$YELLOW Cambios detectados:"
git status -s

# 4. Proceso de Git
echo -e "\n$YELLOW Preparando archivos para Git..."
git add .

# Solicitar el mensaje del commit por teclado
echo -e "$YELLOW Introduce el mensaje para el commit (ej. 'style(waybar): retocar CSS'): "
read -r commit_message

# Si el usuario presiona Enter sin escribir nada, poner un mensaje por defecto
if [ -z "$commit_message" ]; then
    commit_message="update: actualización automática de dotfiles y paquetes"
fi

# Hacer el commit
git commit -m "$commit_message"

# Enviar los cambios a GitHub
echo -e "$YELLOW Subiendo cambios a GitHub..."
if git push origin main; then
    echo -e "$GREEN ¡Repositorio actualizado en GitHub con éxito!"
else
    # Fallback por si tu rama principal todavía se llama master
    echo -e "$YELLOW Intentando con la rama 'master'..."
    if git push origin master; then
        echo -e "$GREEN ¡Repositorio actualizado en GitHub con éxito!"
    else
        echo -e "$RED Error al subir los cambios. Revisa tu conexión o credenciales de GitHub."
    fi
fi
