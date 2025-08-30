#!/usr/bin/env bash
set -euo pipefail

### ─────────────────────────────────────────────────────────────────────────────
### Bootstrap de dotfiles – Debian 13 (Trixie)
### - Instala pacotes base (i3, polybar, rofi, zsh, etc.)
### - (Opcional) Instala pacotes listados em pacotes.txt
### - Copia dotfiles deste repositório para $HOME com backup
### - Define Zsh como shell padrão
### ─────────────────────────────────────────────────────────────────────────────

# Configuráveis
BACKUP_SUFFIX=".bak-$(date +%Y%m%d-%H%M%S)"
REPO_DIR="$(pwd)"             # assume que você está dentro do repo
HOME_CFG="$HOME/.config"

echo "→ Iniciando bootstrap (repo: $REPO_DIR)"
sudo true  # aquece sudo

### 0) Sanidade do sistema
if ! command -v apt >/dev/null 2>&1; then
  echo "✗ Este script espera um Debian/derivado com apt."; exit 1
fi

### 1) Base mínima de pacotes (WM/terminal)
echo "→ Instalando pacotes base…"
sudo apt update
sudo apt install -y \
  git curl rsync \
  zsh \
  i3-wm i3status rofi polybar picom feh dunst \
  alacritty tmux neovim ripgrep fd-find bat

# Ajustes de alternativas para fd/bat no Debian
sudo update-alternatives --install /usr/bin/fd fd /usr/bin/fdfind 50 || true
sudo update-alternatives --install /usr/bin/bat batcat /usr/bin/batcat 50 || true

### 2) (Opcional) Instalar pacotes do seu pacotes.txt
if [[ -f "$REPO_DIR/pacotes.txt" ]]; then
  echo "→ pacotes.txt detectado; reinstalando seu stack…"
  # Filtra linhas em branco e comentários, evita erro de xargs se vazio
  grep -E '^[a-zA-Z0-9]' "$REPO_DIR/pacotes.txt" | xargs -r sudo apt install -y
else
  echo "→ Sem pacotes.txt (ok). Pulando reinstalação de lista personalizada."
fi

### 3) Preparar diretórios
mkdir -p "$HOME_CFG"
mkdir -p "$HOME/.local/bin"

### 4) Função helper para copiar com backup
cp_with_backup () {
  local src="$1" dst="$2"
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv -v "$dst" "${dst}${BACKUP_SUFFIX}"
  fi
  # copia preservando estrutura
  rsync -aH --no-perms --no-owner --no-group "$src" "$dst"
}

### 5) Aplicar .config selecionado do repo
if [[ -d "$REPO_DIR/.config" ]]; then
  echo "→ Aplicando .config do repo → $HOME/.config (com backup pontual por item)…"
  # Copia subpastas selecionadas (se existirem no repo)
  for d in i3 polybar rofi picom kitty alacritty neofetch htop dunst superfile; do
    if [[ -d "$REPO_DIR/.config/$d" ]]; then
      cp_with_backup "$REPO_DIR/.config/$d" "$HOME_CFG/"
    fi
  done
  # arquivos soltos em .config (ex.: starship.toml)
  shopt -s nullglob
  for f in "$REPO_DIR/.config/"*.*; do
    base=$(basename "$f")
    cp_with_backup "$f" "$HOME_CFG/$base"
  done
  shopt -u nullglob
else
  echo "→ Não encontrei $REPO_DIR/.config — pulando."
fi

### 6) Dotfiles de raiz (se existirem no repo)
for f in ".zshrc" ".p10k.zsh" ".gitconfig" ".gitignore_global" ".profile" ".fehbg"; do
  if [[ -f "$REPO_DIR/$f" ]]; then
    echo "→ Aplicando $f"
    cp_with_backup "$REPO_DIR/$f" "$HOME/$f"
  fi
done

### 7) Scripts e extras (opcionais)
if [[ -d "$REPO_DIR/scripts" ]]; then
  echo "→ Instalando scripts pessoais em ~/.local/bin"
  rsync -aH --no-perms --no-owner --no-group "$REPO_DIR/scripts/" "$HOME/.local/bin/"
  chmod -R u+x "$HOME/.local/bin" || true
fi

if [[ -d "$REPO_DIR/Wallpapers" ]]; then
  echo "→ Sincronizando Wallpapers/ → ~/Wallpapers (sem sobrescrever os existentes)"
  rsync -aH --ignore-existing --no-perms --no-owner --no-group "$REPO_DIR/Wallpapers/" "$HOME/Wallpapers/"
fi

if [[ -d "$REPO_DIR/xwinwrap" ]]; then
  echo "→ Copiando xwinwrap/ → ~/xwinwrap"
  cp_with_backup "$REPO_DIR/xwinwrap" "$HOME/"
fi

### 8) Shell padrão → Zsh
if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
  echo "→ Trocando shell padrão para zsh (pede senha)…"
  chsh -s /usr/bin/zsh "$USER" || true
fi

### 9) Tentar aplicar wallpaper (se .fehbg estiver presente)
if [[ -f "$HOME/.fehbg" ]]; then
  echo "→ Aplicando wallpaper via ~/.fehbg"
  bash "$HOME/.fehbg" || true
fi

### 10) Mensagem final
echo
echo "✓ Bootstrap concluído."
echo "   • Backups criados com sufixo: ${BACKUP_SUFFIX}"
echo "   • Se estiver em uma sessão i3 já aberta: Mod+Shift+r para recarregar config."
echo "   • Faça logoff/logon para assumir o Zsh (ou abra um novo terminal)."
