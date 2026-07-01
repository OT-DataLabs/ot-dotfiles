#!/bin/bash

# Comprobar si wpaperd se está ejecutando bajo UWSM/Systemd (Tu setup actual)
if systemctl --user is-active --quiet wpaperd.service 2>/dev/null; then
    # Reinicia el servicio limpiamente, lo que fuerza a elegir un nuevo wallpaper
    systemctl --user restart wpaperd.service
elif systemctl --user is-active --quiet uwsm-app@wpaperd.service 2>/dev/null; then
    systemctl --user restart uwsm-app@wpaperd.service
else
    # Fallback: Si no está como servicio, matamos el proceso para que tu script/loop lo reviva
    pkill wpaperd
    # Le damos un instante y lo volvemos a lanzar en segundo plano
    sleep 0.1
    wpaperd &
fi
