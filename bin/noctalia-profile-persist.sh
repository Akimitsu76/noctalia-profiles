#!/usr/bin/env bash
# Reaplica a persistencia do Noctalia apos atualizacoes / login:
#  - re-materializa a fonte de plugins local (victor-plugins)
#  - reaplica a moldura nos widgets (idempotente)
#  - recarrega o noctalia
set -uo pipefail

export PATH="$HOME/.local/bin:$PATH"

log() { echo "[noctalia-profile-persist] $*"; }

# espera o noctalia subir (ate 20s)
for _ in $(seq 1 20); do
  if pgrep -x noctalia >/dev/null 2>&1; then break; fi
  sleep 1
done

# 1) garante o plugin materializado
if pgrep -x noctalia >/dev/null 2>&1; then
  noctalia msg plugins update victor-plugins >/dev/null 2>&1 && log "plugin atualizado"
  noctalia msg plugins enable victor/profiles >/dev/null 2>&1 || true
fi

# 2) garante a moldura nos widgets (idempotente)
if [ -x "$HOME/.local/bin/noctalia-widget-frames" ]; then
  "$HOME/.local/bin/noctalia-widget-frames" 2>/dev/null && log "moldura aplicada"
fi

# 3) recarrega
if pgrep -x noctalia >/dev/null 2>&1; then
  noctalia msg config-reload >/dev/null 2>&1 && log "config recarregada"
fi

log "ok"
