**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 59: Guardado

## ID del Módulo
- **Código:** M59 (CHECKLIST-GLOBAL: ID 59 — Guardado; plan maestro: sección 58 "GUARDADO")
- **Carpeta:** `DOCUMENTACION/59-Guardado/`
- **Dependencias:** M60 (Datos y Serialización — formatos, schema, migraciones), M07 (EventBus — avisos de guardado). Relaciones: M40 (Infraestructura — servicios base), M14 (Inventario), M17 (Construcción), M19 (NPC), M22/M23 (Misiones), M20 (Amistad), M38 (Economía), M29 (Tiempo), M74 (Eventos), M37 (Colecciones), M55 (Diario), M56 (Fotografía), M61 (Rendimiento), M107 (Backups), M102 (Bug-Tracking)
- **Delegable desde:** M60 (datos/serialización), M40 (infraestructura)

## 1. Problema

Aurora es un mundo persistente: el jugador avanza días (M29), construye (M17), conoce NPC (M19), acumula relaciones (M20), inventario (M14), misiones (M22/M23) y colecciones (M37). Sin un sistema de guardado robusto, cada cierre del juego sería perder el progreso de la sesión. Pero un guardado mal implementado es peor que ninguno: guardados corruptos (apagado a mitad de escritura), saves que no migran entre versiones del juego, backups que se pierden, o un guardado que congela el juego en el peor momento (guardado automático durante una carga pesada). El plan maestro lista 23 exigencias: guardado automático y manual, múltiples slots, copias de seguridad, guardado de mundo/inventario/construcciones/NPC/misiones/relaciones/economía/tiempo/eventos/colecciones/configuración, detección de corrupción, recuperación de backup, versionado, migración, manejo de cambios de estructura, prueba de apagado durante guardado, falta de espacio y múltiples perfiles. El objetivo es que el progreso del jugador esté SIEMPRE a salvo: guardado atómico, automático + manual, con backups, sin congelar el juego y sin corrupción posible.

## 2. Objetivo

Definir el sistema de guardado de la isla: guardado automático (por eventos M07, sin lag) y manual (con confirmación), múltiples slots (3+), copias de seguridad (M107: rotación de backups), guardado de TODOS los sistemas del juego (mundo, inventario, construcciones, NPC, misiones, relaciones, economía, tiempo, eventos, colecciones, diario, fotos, configuración), detección de corrupción con recuperación de backup, versionado de saves con migración entre versiones (M60), y manejo robusto de apagados, falta de espacio y múltiples perfiles. El resultado debe ser un sistema invisible para el jugador: nunca se pierde progreso, nunca se congela el juego y el backup siempre existe.

## 3. Alcance

### 3.1 Dentro del alcance
- Guardado automático: por hitos (día, evento, misión completada, cierre) y temporizado (intervalo configurable); congelación mínima (guardado asíncrono en background thread).
- Guardado manual: botón en pausa (M53) con confirmación y feedback (M44).
- Múltiples slots: 3+ perfiles independientes (M59 maneja los slots; el perfil es del sistema de perfiles M59).
- Copias de seguridad: backup automático del save anterior (rotación M107) + backups manuales.
- Guardado de sistemas: mundo (M09/M10 — islas, POI), inventario (M14), construcciones (M17/M18), NPC (M19), misiones (M22/M23), relaciones (M20), economía (M38), tiempo (M29/M31), eventos (M74), colecciones (M37), diario (M55), fotos (M56), configuración (M90/M91).
- Detección de corrupción: checksum + validación de estructura; si falla → recuperar backup automáticamente con aviso.
- Versionado: schema_version en el save; migración automática (M60).
- Robustez: apagado durante guardado (escritura atómica con archivo temporal + rename), falta de espacio (aviso + no perder el save anterior), múltiples perfiles (carga correcta por slot).
- Validación: `validate_save.gd` (escritura atómica, checksum, migración, perfiles, rendimiento).

### 3.2 Fuera del alcance
- El formato de datos y las migraciones: M60 (aquí se usa lo que define M60).
- El sistema de backups 3-2-1 externo: M107 (aquí solo la rotación local del save anterior).
- Los perfiles de usuario (login, nube): M59 gestiona slots locales; Steam Cloud es M97.
- El sistema de configuración de audio/video: M90/M91 (aquí solo su persistencia).

## 4. Restricciones

- **UI Godot 4 (Control):** sin templates HTML; menú de guardado en M53.
- **Escritura atómica:** nunca escribir sobre el save actual: escribir a `.tmp` y renombrar; ante fallo, conservar el anterior.
- **Sin congelar el juego:** el guardado se escribe en background thread (hilo separado de serialización); la UI solo muestra feedback (M44).
- **Persistencia (M60):** los datos usan el formato definido por M60 (JSON compacto) con schema_version; sin duplicar estructuras.
- **Backups:** rotación de backups (M107) conservando al menos el save anterior; recuperación automática ante corrupción.
- **Configuración:** los saves de configuración se guardan por separado de los de progreso (sin mezclar, M90/M91).
- **Validable:** cada función pasa `validate_save.gd` (sin errores en consola).

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Guardado automático | Por hitos (día, evento, misión, cierre) + intervalo configurable; sin lag perceptible |
| RF2 | Guardado manual | Botón en pausa (M53) con confirmación y feedback (M44) |
| RF3 | Múltiples slots | 3+ slots independientes con selección y borrado con confirmación |
| RF4 | Copias de seguridad | Backup automático del save anterior + backups manuales (rotación M107) |
| RF5 | Guardado de mundo | Islas, POI, estado de exploración (M09/M10/M54) |
| RF6 | Guardado de inventario | Ítems, cantidades, equipamiento (M14) |
| RF7 | Guardado de construcciones | Estado de casas/edificios (M17/M18) |
| RF8 | Guardado de NPC | Posición, estado, diálogos vistos (M19/M21) |
| RF9 | Guardado de misiones | Progreso y estado de misiones (M22/M23) |
| RF10 | Guardado de relaciones | Niveles de amistad (M20) |
| RF11 | Guardado de economía | Dinero, tiendas, stock (M38/M39) |
| RF12 | Guardado de tiempo | Fecha, hora, estación (M29/M31) |
| RF13 | Guardado de eventos | Festivales y eventos pasados/futuros (M74) |
| RF14 | Guardado de colecciones | Museos, bestiario, diario (M37/M55) |
| RF15 | Guardado de configuración | Opciones de juego (M90/M91) por separado |
| RF16 | Detección de corrupción | Checksum + validación; aviso claro y recuperación |
| RF17 | Recuperar backup | Carga del backup automática o manual ante corrupción |
| RF18 | Versionar saves | schema_version por save |
| RF19 | Migrar saves | Migración automática entre versiones (M60) |
| RF20 | Manejar cambios de estructura | Compatibilidad con campos nuevos/faltantes |
| RF21 | Apagado durante guardado | Escritura atómica; nunca un save a medias |
| RF22 | Falta de espacio | Aviso claro; conservar el save anterior |
| RF23 | Múltiples perfiles | Carga correcta por slot; sin cruzamiento de datos |

## 6. Criterios de Aceptación (Verificables)

1. El guardado automático ocurre sin congelar el juego (background thread) y por los hitos definidos.
2. Un apagado durante el guardado nunca deja un save corrupto (escritura atómica).
3. La corrupción detectada recupera el backup y avisa al jugador.
4. Los saves migran automáticamente entre versiones (M60) sin pérdida de datos.
5. Los 3+ slots funcionan sin cruzamiento de datos entre perfiles.
6. Todos los sistemas listados se guardan y cargan correctamente (mundo, inventario, etc.).
7. La falta de espacio no pierde el save anterior y avisa claramente.
8. El guardado manual tiene confirmación y feedback sin bloquear la UI.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M007** — Arquitectura General | Base para arquitectura general |
| **M014** — Inventario | Persistencia de inventario |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M060** — Datos y Serialización | Usado por datos y serialización |
| **M107** — Backups | Usado por backups |
| **M119** — Actualizaciones | Usado por actualizaciones |
| **M137** — Prototipo | Usado por prototipo |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M007** — Arquitectura General | Depende de este módulo |
| **M014** — Inventario | Depende de este módulo |
| **M060** — Datos y Serialización | Este módulo lo necesita |
| **M107** — Backups | Este módulo lo necesita |
| **M119** — Actualizaciones | Este módulo lo necesita |
| **M137** — Prototipo | Este módulo lo necesita |

