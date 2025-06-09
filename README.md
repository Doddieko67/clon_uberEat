---

# 🚀 Guía de Inicio: Proyecto Campus Eats

¡Bienvenido al proyecto! Esta guía te llevará paso a paso a través del proceso de configuración para que puedas tener la aplicación funcionando en tu entorno de desarrollo local.

## 📋 Prerrequisitos

Antes de empezar, asegúrate de tener instalado lo siguiente en tu sistema:

-   **Flutter SDK**: [Guía de instalación oficial](https://flutter.dev/docs/get-started/install)
-   **Git**: Para clonar el repositorio.
-   **Un editor de código**: Recomendamos [Visual Studio Code](https://code.visualstudio.com/) con la extensión de Flutter.

---

## ⚙️ Pasos para la Configuración

Sigue estos pasos en orden para evitar problemas.

### 1. Clonar el Repositorio

Primero, obtén el código fuente desde GitHub y navega hasta el directorio del proyecto.

```bash
git clone https://github.com/Doddieko67/clon_uberEat
cd clon_uberEat
```

### 2. Configuración de Firebase

Este proyecto utiliza Firebase como backend. Para conectar la aplicación a tu propia instancia de Firebase, sigue estos pasos:

1.  **Instala la CLI de Firebase y FlutterFire**:
    ```bash
    # Si no los tienes instalados globalmente
    dart pub global activate flutterfire_cli
    ```

2.  **Configura el proyecto**:
    Ejecuta el siguiente comando en la raíz de tu proyecto. Se te guiará para que selecciones un proyecto de Firebase existente o crees uno nuevo.
    ```bash
    flutterfire configure
    ```

> **⚠️ ¡Atención!**
> El comando anterior creará o actualizará el archivo `lib/firebase_options.dart`. Este archivo contiene las claves de tu proyecto de Firebase.
>
> -   **Si eres un nuevo colaborador**: Es **esencial** que ejecutes este paso para conectar la app a **tu propia instancia de Firebase** para el desarrollo.
> -   **Si trabajas en un equipo**: Consulta si debes usar una configuración de Firebase compartida para desarrollo. **No sobrescribas la configuración existente sin consultarlo antes.**

### 3. Variables de Entorno (Opcional, pero recomendado)

Si el proyecto utiliza claves API u otros secretos, probablemente se gestionen a través de un archivo `env.json`.

1.  Busca un archivo llamado `env.template.json` o similar en el proyecto.
2.  Crea una copia de este archivo y renómbrala a `env.json`.
3.  Rellena `env.json` con tus propias claves (API Keys, etc.).

> **Nota**: El archivo `env.json` debe estar en la raíz del proyecto y NUNCA debe ser subido al repositorio Git (debería estar incluido en el archivo `.gitignore`).

### 4. Instalar Dependencias

Una vez que el entorno está configurado, descarga todas las dependencias del proyecto definidas en `pubspec.yaml`.

```bash
flutter pub get
```

### 5. Ejecutar la Aplicación

¡Ya casi estás! Ahora, ejecuta la aplicación.

```bash
flutter run
```

Este comando compilará y ejecutará la aplicación en el emulador o dispositivo conectado. La opción `--dart-define-from-file` inyecta de forma segura las variables de tu archivo `env.json` en la aplicación en tiempo de compilación.

---

## ✅ ¡Y listo!

Si has seguido todos los pasos, la aplicación Campus Eats debería estar ejecutándose en tu dispositivo. Si encuentras algún problema, revisa lo siguiente:

-   Ejecuta `flutter doctor` para asegurarte de que tu entorno no tiene problemas.
-   Verifica que la configuración de Firebase (`firebase_options.dart`) es correcta.
-   Confirma que tu archivo `env.json` (si lo usas) está bien formado y contiene las claves correctas.
