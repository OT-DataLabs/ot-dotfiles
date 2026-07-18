#!/bin/bash

# Tu directorio de fondos
WALLPAPER_DIR="/home/oscar/Images/Wallpapers"

# 1. Verificar si el demonio está corriendo (actualizado a awww-daemon)
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    # Le damos un segundo completo para que arranque bien en frío
    sleep 1
fi

# 2. Buscar imágenes ignorando mayúsculas/minúsculas usando -iname
SELECCIONADO=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \) | shuf -n 1)

# 3. Lista de transiciones
TRANSICIONES=("fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center")
EFECTO=${TRANSICIONES[$RANDOM % ${#TRANSICIONES[@]}]}

# 4. Aplicar el fondo o avisar si hay error (actualizado a awww)
if [ -n "$SELECCIONADO" ]; then
    # Te enviará una pequeña notificación con el nombre del archivo
    #  notify-send "Cambiando fondo 󰸉" "$(basename "$SELECCIONADO")"
    awww img "$SELECCIONADO" --transition-type "$EFECTO" --transition-fps 60 --transition-duration 1.5
else
    # Si la variable está vacía, te avisa en pantalla
    notify-send "Error ❌" "No se encontraron imágenes en $WALLPAPER_DIR"
fi
