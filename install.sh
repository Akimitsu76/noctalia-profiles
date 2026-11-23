#!/usr/bin/env bash
# Noctalia Profiles — instalador.
# Uso:  bash install.sh [--hook]
#   --hook  instala tambem o hook do pacman (pede sudo)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

echo "==> instalando binarios em $BIN_DIR"
install -Dm755 "$REPO_DIR/bin/noctalia-profile" "$BIN_DIR/noctalia-profile"
install -Dm755 "$REPO_DIR/bin/noctalia-widget-frames" "$BIN_DIR/noctalia-widget-frames"
install -Dm755 "$REPO_DIR/bin/noctalia-profile-persist.sh" "$BIN_DIR/noctalia-profile-persist.sh"

echo "==> instalando servico systemd de usuario"
install -Dm644 "$REPO_DIR/systemd/noctalia-profile-persist.service" \
  "$HOME/.config/systemd/user/noctalia-profile-persist.service"
systemctl --user daemon-reload >/dev/null 2>&1 || true
systemctl --user enable --now noctalia-profile-persist.service >/dev/null 2>&1 || true

echo "==> registrando fonte de plugins"
noctalia msg plugins source add victor-profiles git "file://$REPO_DIR" >/dev/null 2>&1 || true
noctalia msg plugins update victor-profiles >/dev/null 2>&1 || true
sleep 2
noctalia msg plugins enable victor/profiles >/dev/null 2>&1 || true

if [ "${1:-}" = "--hook" ]; then
  echo "==> instalando hook do pacman (sudo)"
  sudo install -Dm755 "$REPO_DIR/bin/noctalia-profile-hook.sh" /usr/local/bin/noctalia-profile-hook.sh
  sudo install -Dm644 "$REPO_DIR/hooks/noctalia-profile.hook" /etc/pacman.d/hooks/noctalia-profile.hook
fi

echo "==> pronto!"
echo "   painel:  noctalia msg panel-toggle victor/profiles:profiles"
echo "   salvar:  noctalia-profile save meu-setup"
