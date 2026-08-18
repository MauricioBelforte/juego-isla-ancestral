**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 60: Datos y Serialización

## ID del Módulo
- **Código:** M60 (plan maestro: sección 60 — Datos y Serialización)
- **Carpeta:** `DOCUMENTACION/60-Datos-Y-Serializacion/`
- **Dependencias:** M59 (Guardado, puede estar sin documentar: se referencia sin bloquear), M08 (Mundo Voxel), M15 (Recursos), M16 (Crafting), M33 (Agricultura), M58 (Accesibilidad), M62 (Memoria), M63 (Cargas y Streaming), M90 (Configuración Gráfica), M91 (Configuración de Audio), M103 (Logging), M107 (Backups)
- **Motor:** Godot 4.x + Voxel Tools | **Lenguaje:** GDScript
- **Delegable desde:** hoy (no requiere mundo voxel funcional para implementar el DataStore y los serializadores)

## 1. Problema

Isla Aurora genera y modifica muchísimos datos: el mundo voxel (M08), el inventario (M14), la progresión (M71), los cultivos (M33), las construcciones (M17), la configuración (M58/90/91) y el progreso narrativo (M22/M23). Sin una capa única de datos, cada sistema guardaría con su propio formato: saves corruptos, incompatibilidad entre versiones, tiempos de carga largos y datos inestables al actualizar el juego. El módulo 60 centraliza **qué se guarda, cómo se codifica, cómo se versiona y cómo se migra** con guardados pequeños, carga rápida y estabilidad entre versiones.

## 2. Objetivo

Definir e implementar la capa de datos del juego: un **DataStore** central (autoload en Godot) que unifique la lectura/escritura de datos estáticos (Resources `.tres`), datos de configuración (ConfigFile) y datos de partida (JSON/binario en `user://`), con versionado de esquema, migraciones automáticas y validación de integridad.

## 3. Alcance

### 3.1 Dentro del alcance
- Serialización de datos de partida (jugador, mundo voxel, inventario, progresión, tiempo, clima).
- Datos estáticos del juego en Resources de Godot (`.tres`/`.res`): items (M15), recetas (M16), cultivos (M33).
- Configuración persistente del juego (M58/90/91) mediante `ConfigFile`.
- Versionado de esquema de saves (entero `version` + changelog de migraciones).
- Migraciones automáticas de datos viejos a nuevos formatos.
- Validación de integridad (checksum CRC32, campos obligatorios, tipos).
- Backup previo al guardado (cooperación con M107).
- Guardado/carga asincrónica para no bloquear el frame (M62/M63).

### 3.2 Fuera del alcance
- La mecánica de cuándo autoguardar (decisiones puntuales del módulo 59).
- La UI de slots de guardado (pertenece a M53/UI; el módulo 60 expone la API).
- La compresión/streaming del territorio procedural en runtime (M63).
- Networking/sincronización multijugador (no aplica a este proyecto).

## 4. Restricciones

- Motor **Godot 4.x**, lenguaje **GDScript** (nada de C#/Unity).
- Escritura únicamente sobre `user://` (jamás sobre `res://`, que es de solo lectura en exportación).
- Guardados pequeños (objetivo < 1 MB por slot, mundo voxel comprimido/parcial).
- Carga rápida: escena de mundo lista en < 2 s desde el menú de títulos (objetivo M63).
- Datos estables entre versiones: un save de la v1 debe cargarse en la v2 (migración ascendente).
- Sin time-gates de contenido por migración: el guardado nunca se pierde por cambiar de versión.

## 5. Requisitos Funcionales (RF)

| # | Requisito | Detalle |
|---|---|---|
| RF1 | DataStore central | Autoload `DataStore` que unifica acceso a todos los datos (estáticos, config, partida) |
| RF2 | Datos estáticos en Resources | Items (M15), recetas (M16), cultivos (M33), configs de mundo en `.tres` mediante `load()` |
| RF3 | Serialización de partida | Jugador, inventario (M14), progresión (M71), tiempo (M29), clima (M32), fauna (M36), construcciones (M17) |
| RF4 | Serialización del mundo voxel | Modificaciones del terreno y edits del jugador sobre el mundo voxel (M08), no el mundo completo procedural |
| RF5 | Configuración persistente | ConfigFile para accesibilidad (M58), gráficos (M90) y audio (M91). Lee al arranque, escribe al cambiar |
| RF6 | Versionado de esquema | Cada save lleva `version` entera; se define `VERSION_ACTUAL` como constante |
| RF7 | Migración automática | Al cargar un save con `version < VERSION_ACTUAL`, aplicar migraciones en orden estricto ascenso |
| RF8 | Validación de integridad | Checksum, campos obligatorios y tipos; save corrupto detectado y manejado (no crash) |
| RF9 | Backup de guardado | Copia `.bak` del save previo antes de sobreescribir (coopera con M107) |
| RF10 | Guardado asincrónico | Serialización fuera del hilo principal; `await` con progreso visible (regla UX M08) |
| RF11 | Estabilidad entre versiones | Nunca romper saves por cambios de esquema: solo migraciones aditivas/salvables |
| RF12 | Logs de operaciones | Registrar cada guardado/carga/migración en el sistema de logging (M103) |

## 6. Requisitos No Funcionales (RN)

- **RN1 — Rendimiento:** guardar < 300 ms en hilo secundario; cargar y validar < 1 s en hilo principal (objetivo menor al presupuesto de M63).
- **RN2 — Tamaño:** save completo objetivo < 1 MB por slot (JSON comprimido o binario para voxel).
- **RN3 — Fiabilidad:** escritura atómica (archivo temporal `*.tmp` + `rename`); ante fallo, el save anterior queda intacto.
- **RN4 — Compatibilidad:** todo campo nuevo en esquema debe tener default o migración; nunca campos requeridos sin migración.
- **RN5 — Portabilidad:** rutas relativas a `user://`; sin rutas absolutas ni dependencias de plataforma.
- **RN6 — Codificación:** UTF-8 sin BOM en JSON; binario con `store_32` lengths explícitos; sin caracteres raros.
- **RN7 — Modularidad:** la capa de datos es un servicio (autoload) sin acoplamiento a UI; la UI solo llama la API expuesta (M09/M53).
- **RN8 — Seguridad:** ningún dato sensible en el save (contraseñas, tokens); logs sin datos de jugador.
- **RN9 — Determinismo:** el orden de los campos del JSON es estable; los IDs de items son strings estables (jamás índices de array).
- **RN10 — Backup:** el `.bak` anterior debe poder restaurarse manualmente desde cualquier versión futura sin crash.

## 7. Criterios de Aceptación

1. `DataStore` (autoload) operativo en Godot 4.x, consumible por cualquier módulo vía ServiceLocator (M07).
2. Save de partida completo en JSON con `version`, checksum y todos los bloques (jugador, mundo, inventario, tiempo, progresión).
3. Mundo voxel (M08) serializado/deserializado correctamente (edits del jugador).
4. Migración v1 → vN probada: un save de una versión vieja (provista por test) carga y migra sin pérdida.
5. Save corrupto (bit flips de prueba) detectado por checksum, sin crash y con mensaje de recuperación (backup).
6. ConfigFile de M58/90/91 leído al arranque y escrito al cambiar opciones.
7. Tiempos de guardado/carga dentro de los objetivos RN1/RN2 medidos con `Time.get_ticks_msec()` en test.