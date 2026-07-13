#!/bin/bash

WALLPAPER_DIR="/home/oscar/Images/Wallpapers"

if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 0.5
fi


SELECCIONADO=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.gif" \) | shuf -n 1)


TRANSICIONES=("fade" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center")
EFECTO=${TRANSICIONES[$RANDOM % ${#TRANSICIONES[@]}]}


if [ -n "$SELECCIONADO" ]; then
    swww img "$SELECCIONADO" --transition-type "$EFECTO" --transition-fps 60 --transition-duration 1.5
fi
