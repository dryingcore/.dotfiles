#!/bin/bash

# Caminho do vídeo (passado como argumento ou padrão)
VIDEO="$1"
WALLPAPER_DIR="$HOME/Downloads"

if [[ -z "$VIDEO" ]]; then
  echo "Uso: setwall.sh nome-do-video.mp4"
  exit 1
fi

FULL_PATH="$WALLPAPER_DIR/$VIDEO"

if [[ ! -f "$FULL_PATH" ]]; then
  echo "Arquivo não encontrado: $FULL_PATH"
  exit 1
fi

# Detecta resolução
RES=$(xrandr | grep '*' | awk '{print $1}')

# Mata instâncias anteriores
pkill xwinwrap

# Espera um pouco pra garantir que fechou
sleep 1

# Inicia o wallpaper animado
xwinwrap -fs -fdt -ni -b -nf -un -ov -g ${RES}+0+0 -- \
mpv -wid WID --loop --no-audio --no-osd-bar --really-quiet --vo=gpu "$FULL_PATH" &
