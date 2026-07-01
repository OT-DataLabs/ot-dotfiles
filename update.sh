#!/bin/bash

# =====================================================================
# Script para Sincronizar Configuraciones Locales y Subir a GitHub
# =====================================================================

# Colores para los mensajes de la terminal
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
YELLOW="$(tput setaf 3)[INFO]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"

DOTFILES_DIR="$HOME/ot-dotfiles"

# 1. Verificar si estamos en el directorio correcto
if [ "$PWD" != "$DOTFILES_DIR" ]; then
    echo -e "$RED Por favor, ejecuta este script desde $DOTFILES_DIR"
    exit 1
fi

# 2. Sincronizar y actualizar las configuraciones locales con GNU Stow
echo -e "$YELLOW Actualizando enlaces de configuración locales..."

# Asegurar que el directorio base existe
mkdir -p "$HOME/.config"

STOW_FOLDERS=("hypr" "waybar" "kitty" "wpaperd")

for folder in "${STOW_FOLDERS[@]}"; do
    # Si por algún motivo se creó una carpeta real bloqueando el enlace, la respaldamos
    if [ -d "$HOME/.config/$folder" ] && [ ! -L "$HOME/.config/$folder" ]; then
        echo -e "$YELLOW Respaldando carpeta física encontrada en ~/.config/$folder..."
        mv "$HOME/.config/$folder" "$HOME/.config/${folder}.bak"
    fi
    
    # Refrescar los enlaces de Stow (el parámetro -R elimina enlaces viejos y crea los nuevos)
    stow -R -t "$HOME/.config" "$folder"
done
echo -e "$GREEN Configuraciones locales actualizadas y enlazadas con éxito."

# 3. Actualizar las listas de paquetes del sistema
echo -e "$YELLOW Generando listas de paquetes actualizadas..."
pacman -Qqen > pkglist-oficial.txt
pacman -Qqem > pkglist-aur.txt
echo -e "$GREEN Listas de paquetes sincronizadas."

# 4. Verificar si hay cambios reales para enviar a GitHub
if [ -z "$(git status --porcelain)" ]; then
    echo -e "$GREEN No hay cambios nuevos que guardar. Tus dotfiles locales y el repo están al día."
    exit 0
fi

# Mostrar al usuario qué archivos han cambiado
echo -e "\n$YELLOW Cambios detectados para subir a GitHub:"
git status -s

# 5. Proceso de Git (Add, Commit y Push)
echo -e "\n$YELLOW Preparando archivos para Git..."
git add .

# Solicitar el mensaje del commit por teclado
echo -e "$YELLOW Introduce el mensaje para el commit (ej. 'fix(hypr): cambiar atajos'): "
read -r commit_message

if [ -z "$commit_message" ]; then
    commit_message="update: actualización automática de dotfiles y paquetes"
fi

git commit -m "$commit_message"

echo -e "$YELLOW Subiendo cambios a GitHub..."
if git push origin main; then
    echo -e "$GREEN ¡Repositorio actualizado en GitHub con éxito!"
else
    echo -e "$YELLOW Intentando con la rama 'master'..."
    if git push origin master; then
        echo -e "$GREEN ¡Repositorio actualizado en GitHub con éxito!"
    else
        echo -e "$RED Error al subir los cambios. Revisa tus credenciales o conexión."
    fi
fi
