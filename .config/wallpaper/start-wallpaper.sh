#!/bin/bash

# Espera o i3 terminar de carregar
sleep 2

# Mata qualquer instância anterior
pkill xwinwrap
pkill mpv

# Vai para a pasta correta
cd "$HOME/Wallpapers" || exit 1

# Detecta resolução da tela
RES=$(xrandr | grep '*' | awk '{print $1}')

# Inicia o wallpaper animado com xwinwrap e mpv
xwinwrap -fs -fdt -ni -b -nf -un -ov -g "$RES"+0+0 -- \
mpv -wid WID --loop --no-audio --no-osd-bar --really-quiet --vo=gpu windows-xp-loading-moewalls-com.mp4
