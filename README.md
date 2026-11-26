# data-apoyo

Scripts de apoyo para un puesto **Ubuntu** del Nodo S3. Sirven para ver qué falta y pedir o instalar el mínimo para compilar un APK por línea de comandos.

No es la entrega del hackathon. No trae código de la app, modelo ni arquitectura del reto.

## 1. Ver qué falta

Si ya tienes `git`:

```bash
git clone https://github.com/jhonatanrojas/data-apoyo.git
cd data-apoyo
bash check.sh
```

Si todavía no hay `git`:

```bash
curl -fsSL -o check.sh https://raw.githubusercontent.com/jhonatanrojas/data-apoyo/main/check.sh
bash check.sh
```

Plan A solo si el chequeo marca Java 17, `adb` y `platforms/android-35`.

## 2. Instalar el mínimo

Solo después de que el personal del nodo autorice la instalación:

```bash
bash install.sh
source "$HOME/.android-dev-env.sh"
bash check.sh
```

`install.sh` instala:

- OpenJDK 17, git, unzip, wget, curl (vía `apt`, pide `sudo`)
- Android command-line tools en `$HOME/android-sdk`
- Solo estos paquetes del SDK: `platform-tools`, `platforms;android-35`, `build-tools;35.0.0`
- Gradle 8.10.2 en `$HOME/.local/gradle`

No instala Android Studio, Python ni CUDA. Este puesto no tiene GPU NVIDIA; el entrenamiento no va aquí.

## Qué decir al levantar la mano

Pedir autorización para instalar:

1. `openjdk-17-jdk`
2. `git` `unzip` `wget` `curl`
3. Android SDK de línea de comandos, solo `platform-tools`, `platforms;android-35` y `build-tools;35.0.0`
4. Gradle 8.10.2

El script `install.sh` hace exactamente eso.
