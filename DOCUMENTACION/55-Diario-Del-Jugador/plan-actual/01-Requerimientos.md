**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 55: Diario del Jugador

## ID del Módulo
- **Código:** M55 (CHECKLIST-GLOBAL: ID 55 — Diario del Jugador; plan maestro: sección 54 "DIARIO DEL JUGADOR")
- **Carpeta:** `DOCUMENTACION/55-Diario-Del-Jugador/`
- **Dependencias:** M53 (UI/UX — pantallas y navegación), M14 (Inventario — recetas/objetos), M60 (Datos y Serialización — persistencia). Relaciones: M16 (Crafting — recetas), M19 (NPC — personajes), M22/M23 (Historia — misiones/pistas), M24/M25/M26 (Puzzles/Ruinas/Templo — Sellos y pistas), M36 (Fauna), M09/M10 (Lugares), M50 (Plantas), M35 (Minerales), M56 (Fotografía), M74 (Eventos), M87 (Localización), M59 (Guardado)
- **Delegable desde:** M53 (UI/UX), M60 (datos), M14 (inventario)

## 1. Problema

Aurora es un mundo rico en personajes, lugares, criaturas, plantas, minerales, recetas, pistas, Sellos, ruinas, cartas, descubrimientos, misiones, eventos y fotografías. Sin un diario del jugador, el proyecto degeneraría en: información dispersa (el jugador olvida dónde continuar la historia o qué pista leyó), contenido recolectable sin registro (Sellos y descubrimientos invisibles al progreso), recetas no consultables, o una UI caótica con spoilers (el diario adelantaría contenido no descubierto). El plan maestro lista 24 exigencias: diseño del diario, registro de 13 tipos de contenido, filtros, categorías, porcentaje de completado, contenido secreto, releer pistas, favoritos, guardar progreso, localización y anti-spoilers. El objetivo del módulo es que el jugador tenga UN lugar central, organizado y sin spoilers, que refleje su progreso y ayude a continuar la aventura.

## 2. Objetivo

Definir el sistema de diario del jugador de la isla: registro de 13+ categorías de contenido (personajes, lugares, criaturas, plantas, minerales, recetas, pistas, Sellos, ruinas, cartas, descubrimientos, misiones, eventos, fotografías), estructura de UI con filtros y categorías, porcentaje de completado (coleccionable por categoría), contenido secreto (desbloqueable, sin spoilers), pistas releíbles, favoritos, persistencia (M59/M60), localización completa (M87) y reglas anti-spoilers (nunca mostrar contenido no descubierto). El resultado debe ser un diario cozy, útil y completo, integrado con el inventario, el mapa (M54) y la fotografía (M56).

## 3. Alcance

### 3.1 Dentro del alcance
- Diseño del diario: pantalla principal con pestañas/categorías y navegación (M53).
- Registro automático de contenido: personajes (M19), lugares (M09/M10), criaturas (M36/M65), plantas (M50), minerales (M35), recetas (M16), pistas (M24/M26), Sellos (M22/M26), ruinas (M25), cartas (M74), descubrimientos (M71), misiones (M22/M23), eventos (M74).
- Fotografías: integración con M56 (galería en el diario).
- Filtros y categorías: por tipo, bioma, estado (visto/no visto, favorito).
- Porcentaje de completado: por categoría y global (guarda relación con logros M72).
- Contenido secreto: entradas ocultas que se desbloquean por acciones (sin spoilers).
- Releer pistas: historial de pistas leídas (M21 diálogos, M24 puzzles).
- Favoritos: marcado manual con estrella; filtro rápido.
- Persistencia: progreso del diario guardado (M59/M60) versionado.
- Localización: textos localizables (M87/M88).
- Anti-spoilers: las entradas no descubiertas JAMÁS se muestran (ni atenuadas); el contenido secreto solo al desbloquear.
- Validación: `validate_diary.gd` verifica mapeo de registros, localización y persistencia.

### 3.2 Fuera del alcance
- El diseño de la UI general (estilos, componentes): M53.
- El sistema de misiones en sí (progresión): M22/M23/M71.
- La cámara/modo fotografía: M56 (aquí solo la galería).
- El sistema de guardado/serialización: M59/M60.
- El sistema de logros: M72 (el diario informa progreso, no lo define).

## 4. Restricciones

- **UI Godot 4 (Control/Tree/Grid):** sin templates HTML; pantallas nativas de M53.
- **Sin spoilers:** una entrada no descubierta NO existe visualmente (no se muestra ni atenuada ni en recuento).
- **Desempeño:** el diario carga contenido perezosamente (LazyLoad) y cierra sin lag (M61); persistencia liviana (M60).
- **Persistencia:** el progreso del diario se guarda en GameState (M59/M60), versionado y migrable.
- **Localización (M87):** todos los textos por claves i18n; sin texto embebido.
- **Cozy:** navegación simple (2 clics para cualquier sección), sin pantallas abrumadoras.
- **Validable:** cada entrada registrada pasa validación de mapeo/persistencia.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Pantalla principal del diario | Pestañas por categoría, navegación 2 clics, scroll suave (M53) |
| RF2 | Registro de personajes | Entrada por NPC conocido (M19): nombre, retrato (M46), relación (M20), gustos, último diálogo |
| RF3 | Registro de lugares | Por POI visitado (M09/M54): nombre, bioma, descripción, estado de exploración |
| RF4 | Registro de criaturas | Por especie encontrada (M36/M65): descripción, hábitat, fotografía (M56) |
| RF5 | Registro de plantas | Por especie recolectada/vista (M50/M33): descripción, estación, usos (M16) |
| RF6 | Registro de minerales | Por mineral descubierto (M35): descripción, ubicación, usos |
| RF7 | Registro de recetas | Por receta desbloqueada (M16): ingredientes, resultado, nivel |
| RF8 | Registro de pistas | Pistas leídas de puzzles/templos (M24/M26): releíbles, con estado resuelto |
| RF9 | Registro de Sellos | Por Sello obtenido (M22/M26): historia, visual, orden |
| RF10 | Registro de ruinas | Por ruina visitada (M25): estado (4 estados), recompensas |
| RF11 | Registro de cartas | Cartas del festival (M74) y del correo: mensajes, remitentes |
| RF12 | Registro de descubrimientos | Descubrimientos de mundo (M71): desbloqueables por acciones |
| RF13 | Registro de misiones | Misiones activas/completadas (M22/M23): objetivo, progreso, estado |
| RF14 | Registro de eventos | Eventos pasados/futuros (M74): fechas del calendario (M29) |
| RF15 | Registro de fotografías | Galería de M56: fotos tomadas, asociadas a entradas |
| RF16 | Filtros y categorías | Por tipo, bioma, estado (nuevo/visto/favorito), búsqueda |
| RF17 | Porcentaje de completado | Por categoría y global; feed al logro (M72) |
| RF18 | Contenido secreto | Entradas ocultas desbloqueables (Sellos ocultos, lore), sin spoilers |
| RF19 | Releer pistas | Historial de pistas con opción de "volver a leer" |
| RF20 | Favoritos | Estrella por entrada; filtro "favoritos" |
| RF21 | Persistencia | Progreso del diario en GameState (M59/M60), versionado |
| RF22 | Localización | Todos los textos i18n (M87/M88), plurales y nombres propios |
| RF23 | Anti-spoilers | Entradas no descubiertas invisibles (ni atenuadas); secreto solo al desbloquear |
| RF24 | Validación | `validate_diary.gd`: mapeo de registros, persistencia, localización, rendimiento |

## 6. Criterios de Aceptación (Verificables)

1. Los 14 tipos de contenido del plan maestro se registran automáticamente al descubrirse.
2. Una entrada no descubierta NO aparece en la UI (ni atenuada ni en recuento).
3. El porcentaje de completado por categoría coincide con el recuento real de entradas.
4. Las pistas se pueden releer y marcar como resueltas.
5. El diario guarda/recupera su progreso entre sesiones (M59/M60) sin duplicados.
6. Todos los textos del diario se localizan (M87) sin cadenas embebidas.
7. La galería de fotografías (M56) se abre desde el diario sin recargar la escena.
8. El diario abre/cierra sin lag y navega con 2 clics (M53/M61).