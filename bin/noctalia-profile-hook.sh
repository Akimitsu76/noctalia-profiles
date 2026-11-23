#!/usr/bin/env bash
# Hook do pacman: roda como root apos instalar/atualizar `noctalia`.
# Reaplica a moldura e re-materializa o plugin victor/profiles para o usuario
# que esta rodando o noctalia.
set -uo pipefail

uid=$(pgrep -x noctalia 2>/dev/null | head -1 | xargs -r -I{} stat -c %u /proc/{} 2>/dev/null)
[ -z "${uid:-}" ] && exit 0
user=$(getent passwd "$uid" | cut -d: -f1)
home=$(getent passwd "$uid" | cut -d: -f6)
[ -z "${user:-}" ] && exit 0

run_as() {
  runuser -u "$user" -- env HOME="$home" PATH="$home/.local/bin:/usr/local/bin:/usr/bin:/bin" "$@"
}

# espera o noctalia (re)subir
for _ in $(seq 1 15); do
  pgrep -x noctalia >/dev/null 2>&1 && break
  sleep 1
done

run_as noctalia msg plugins update victor-plugins >/dev/null 2>&1 || true
run_as noctalia msg plugins enable victor/profiles >/dev/null 2>&1 || true
[ -x "$home/.local/bin/noctalia-widget-frames" ] && run_as "$home/.local/bin/noctalia-widget-frames" >/dev/null 2>&1 || true
run_as noctalia msg config-reload >/dev/null 2>&1 || true
exit 0
