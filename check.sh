#!/usr/bin/env bash
# Chequeo de solo lectura. No instala nada.
set -u

fail=0

ok() { printf 'OK    %s\n' "$1"; }
miss() { printf 'FALTA %s\n' "$1"; fail=1; }

echo "=== JAVA ==="
if command -v java >/dev/null 2>&1; then
  java -version 2>&1 | head -3
  if java -version 2>&1 | grep -Eq '"17\.'; then
    ok "Java 17"
  else
    echo "AVISO Java existe, pero no es 17. Hace falta OpenJDK 17."
    fail=1
  fi
else
  miss "java (OpenJDK 17)"
fi

echo "=== GIT ==="
if command -v git >/dev/null 2>&1; then
  ok "$(git --version)"
else
  miss "git"
fi

echo "=== BINARIOS ==="
for c in adb sdkmanager unzip wget curl; do
  if command -v "$c" >/dev/null 2>&1; then
    ok "$c -> $(command -v "$c")"
  else
    miss "$c"
  fi
done

if command -v gradle >/dev/null 2>&1; then
  ok "gradle -> $(command -v gradle)"
else
  echo "AVISO no hay gradle en PATH. El wrapper del proyecto puede bastar después."
fi

if command -v code >/dev/null 2>&1 || command -v nano >/dev/null 2>&1 || command -v vim >/dev/null 2>&1; then
  ok "hay editor (code, nano o vim)"
else
  echo "AVISO no hay editor conocido"
fi

echo "=== SDK ==="
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [ -z "$SDK" ]; then
  for cand in "$HOME/android-sdk" /opt/android-sdk /usr/lib/android-sdk; do
    if [ -d "$cand" ]; then
      SDK="$cand"
      break
    fi
  done
fi

if [ -n "${SDK}" ] && [ -d "$SDK" ]; then
  echo "SDK=$SDK"
  for p in platform-tools platforms/android-35 build-tools/35.0.0 cmdline-tools/latest/bin; do
    if [ -e "$SDK/$p" ]; then
      ok "$p"
    else
      miss "$p"
    fi
  done
else
  miss "Android SDK (ANDROID_HOME o ~/android-sdk)"
fi

echo "=== ADB ==="
if command -v adb >/dev/null 2>&1; then
  adb devices -l || true
else
  echo "adb no responde porque no está instalado"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "PLAN A: listo (Java 17 + adb + android-35)."
  exit 0
fi

echo "PLAN A: incompleto. Falta lo marcado arriba."
echo "Con autorización del nodo: bash install.sh"
exit 1
