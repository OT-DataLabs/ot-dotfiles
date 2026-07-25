#!/bin/bash

echo "🎙️ Iniciando EasyEffects y QPWGraph..."
easyeffects --gapplication-service &
qpwgraph &

echo "🎥 Abriendo OBS y grabando automáticamente..."
# Inicia OBS, empieza a grabar y se minimiza para no estorbar en tu video
obs --startrecording --minimize-to-tray

echo "🛑 OBS cerrado. Limpiando el entorno..."
killall qpwgraph
killall easyeffects

echo "✅ Grabación guardada y entorno terminado."
