# HoloApp

## Axel Joshep Ibarra Grimaldo
## Programacion movil

HoloApp es una aplicacion hecha en Flutter para explorar contenido de talentos de Hololive, ver transmisiones en vivo, revisar canales, abrir videos en YouTube y guardar un historial local de reproducciones.

## Descripcion general

El proyecto fue desarrollado como parte de la materia de Programacion movil. La app combina interfaz movil, consumo de datos desde servicios externos y almacenamiento local para ofrecer una experiencia completa dentro del dispositivo.

Al iniciar, la aplicacion muestra una pantalla de login donde el usuario puede registrarse o entrar con credenciales locales. Despues del acceso, se abre la pantalla principal con componentes interactivos de Flutter y accesos a las distintas secciones de la app.

## Funcionalidades principales

- Inicio de sesion local con usuario y contraseña.
- Registro de nuevos usuarios dentro de la aplicacion.
- Pantalla inicial con imagenes, sliders, switch, botones y radios para practicar widgets de Flutter.
- Lista de talentos de Hololive cargada desde servicios de datos.
- Buscador para filtrar talentos por nombre.
- Vista de streams en vivo y transmisiones programadas.
- Pantalla de detalle por canal con informacion general y videos recientes.
- Apertura de videos en YouTube desde la app.
- Guardado automatico del historial de visualizacion en almacenamiento local.
- Visualizacion y limpieza del historial desde una pantalla dedicada.
- Notificaciones cuando hay transmisiones en vivo.

## Flujo de la aplicacion

1. El usuario abre la app y ve la pantalla de login.
2. Puede registrarse o iniciar sesion con una cuenta local.
3. Al entrar, se muestra la pantalla principal con contenido interactivo.
4. Desde ahi puede navegar a la seccion de talentos de Hololive.
5. Cada canal tiene su propia vista con videos recientes.
6. Al tocar un video, la app guarda el evento en el historial y abre YouTube.
7. El historial puede consultarse y limpiarse en cualquier momento.

## Almacenamiento local

La aplicacion guarda el historial de reproduccion en un archivo local llamado `historial.txt` dentro del directorio de documentos de la app. Cada registro incluye:

- Fecha y hora.
- Titulo del video.
- Nombre del canal.

Este historial se puede leer despues, mostrar en pantalla y borrar desde la propia aplicacion.

## Tecnologias utilizadas

- Flutter
- Dart
- Path Provider
- URL Launcher
- Shared Preferences
- SQLite
- Flutter Local Notifications

## Estructura general

- `lib/main.dart`: punto de entrada y pantallas de login/terminos.
- `lib/registro.dart`: registro de usuarios.
- `lib/inicio.dart`: pantalla principal con widgets y acceso a otras secciones.
- `lib/hololive_page.dart`: listado de talentos, streams y busqueda.
- `lib/channel_detail_page.dart`: detalle de canal y videos.
- `lib/historial_page.dart`: historial de reproduccion.
- `lib/services/local_storage_service.dart`: lectura y escritura del historial local.
- `lib/services/holodex_service.dart`: acceso a datos de canales y videos.
- `lib/services/notification_service.dart`: notificaciones de streams en vivo.

## Requisitos para ejecutar

- Flutter instalado.
- Un emulador o dispositivo fisico.
- Conexion a internet para cargar contenido remoto y abrir videos.

## Como ejecutar el proyecto

```bash
flutter pub get
flutter run
```

## Autor

Axel Joshep Ibarra Grimaldo
