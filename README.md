# data-apoyo

Hoja para el personal del nodo. No es la app del hackathon. No ejecutar `install.sh`.

Motivo: compilar un APK Android e instalarlo por USB. No hace falta Android Studio ni GPU.

Cada comando va solo. Ubuntu 26.04.

## 1. Java 17

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
java -version
```

## 2. Git y utilidades

```bash
sudo apt install -y git unzip wget curl ca-certificates
```

## 3. ADB

```bash
sudo apt install -y adb
adb version
```

## 4. Android SDK 35

```bash
mkdir -p "$HOME/android-sdk/cmdline-tools"
wget -O /tmp/cmdtools.zip https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip
unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools
rm -rf "$HOME/android-sdk/cmdline-tools/latest"
mv /tmp/cmdtools/cmdline-tools "$HOME/android-sdk/cmdline-tools/latest"
```

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
```

El paquete `platform-tools` incluye otro `adb`, el que usa el proyecto.

## 5. Gradle 8.10.2

```bash
mkdir -p "$HOME/.local/gradle"
wget -O /tmp/gradle.zip https://services.gradle.org/distributions/gradle-8.10.2-bin.zip
unzip -q /tmp/gradle.zip -d "$HOME/.local/gradle"
```

## Variables para el participante

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$HOME/.local/gradle/gradle-8.10.2/bin:$PATH"
```
