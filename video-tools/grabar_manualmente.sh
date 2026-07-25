#!/bin/bash

OUTPUT_DIR="$HOME/Videos"
mkdir -p "$OUTPUT_DIR"
FILENAME="$OUTPUT_DIR/gameplay_$(date +%Y-%m-%d_%H-%M-%S).mp4"

echo "Presiona CTRL+C en esta terminal para detener."

wf-recorder -c h264_vaapi -d /dev/dri/renderD128 -C default -f "$FILENAME"
