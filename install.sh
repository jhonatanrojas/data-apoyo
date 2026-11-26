#!/usr/bin/env bash
# Instala el mínimo para compilar un APK en Ubuntu, sin Android Studio.
# Pide sudo solo para apt. El SDK y Gradle quedan en el home del usuario.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "No lo corras como root. Entra con el usuario del puesto y ejecuta: bash install.sh"
  exit 1
fi

CMDLINE_URL="https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip"
GRADLE_URL="https://services.gradle.org/distributions/gradle-8.10.2-bin.zip"
SDK="${ANDROID_HOME:-$HOME/android-sdk}"
GRADLE_DIR="$HOME/.local/gradle"
GRADLE_VERSION="8.10.2"

echo "Esto instala OpenJDK 17, git, unzip, wget, curl, Android SDK 35 y Gradle ${GRADLE_VERSION}."
echo "SDK: $SDK"
echo "Hace falta autorización del nodo y sudo para apt."
printf 'Continuar? [s/N] '
read -r answer
case "$answer" in
  s|S|si|SI|sí|Sí) ;;
  *) echo "Cancelado."; exit 1 ;;
esac

sudo apt-get update
sudo apt-get install -y openjdk-17-jdk git unzip wget curl ca-certificates

if [ -d /usr/lib/jvm/java-17-openjdk-amd64 ]; then
  JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
elif [ -d /usr/lib/jvm/java-17-openjdk-arm64 ]; then
  JAVA_HOME="/usr/lib/jvm/java-17-openjdk-arm64"
else
  JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
fi
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"

mkdir -p "$SDK/cmdline-tools" "$GRADLE_DIR"
if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  echo "Descargando Android command-line tools..."
  wget -O "$tmp/cmdtools.zip" "$CMDLINE_URL"
  unzip -q "$tmp/cmdtools.zip" -d "$tmp"
  rm -rf "$SDK/cmdline-tools/latest"
  mv "$tmp/cmdline-tools" "$SDK/cmdline-tools/latest"
  rm -rf "$tmp"
  trap - EXIT
fi

export ANDROID_HOME="$SDK"
export ANDROID_SDK_ROOT="$SDK"
export PATH="$SDK/cmdline-tools/latest/bin:$SDK/platform-tools:$PATH"

echo "Aceptando licencias e instalando solo 3 paquetes del SDK..."
yes | sdkmanager --licenses >/dev/null || true
sdkmanager --install "platform-tools" "platforms;android-35" "build-tools;35.0.0"

if [ ! -x "$GRADLE_DIR/gradle-${GRADLE_VERSION}/bin/gradle" ]; then
  tmp="$(mktemp -d)"
  echo "Descargando Gradle ${GRADLE_VERSION}..."
  wget -O "$tmp/gradle.zip" "$GRADLE_URL"
  unzip -q "$tmp/gradle.zip" -d "$GRADLE_DIR"
  rm -rf "$tmp"
fi

ENV_FILE="$HOME/.android-dev-env.sh"
cat > "$ENV_FILE" <<EOF
export JAVA_HOME="$JAVA_HOME"
export ANDROID_HOME="$SDK"
export ANDROID_SDK_ROOT="$SDK"
export PATH="\$JAVA_HOME/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:$GRADLE_DIR/gradle-${GRADLE_VERSION}/bin:\$PATH"
EOF

marker="# data-apoyo android env"
if ! grep -q "$marker" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n%s\n[ -f "$HOME/.android-dev-env.sh" ] && . "$HOME/.android-dev-env.sh"\n' "$marker" >> "$HOME/.bashrc"
fi

# shellcheck disable=SC1090
. "$ENV_FILE"
echo
echo "Instalación terminada. Variables en $ENV_FILE"
bash "$(cd "$(dirname "$0")" && pwd)/check.sh" || true
echo
echo "En esta misma terminal corre: source \"$ENV_FILE\""
