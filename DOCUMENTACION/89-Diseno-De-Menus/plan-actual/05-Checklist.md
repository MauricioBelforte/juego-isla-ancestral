**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 89: Diseño de Menús (110 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## Reserva actual

- **Agente:** mimo-v2.6-flash-free (opencode) — **T-M3** (cierre, mensaje 35 del director;
  reclamado 2026-10-06 17:05, fila 89 🔵).
- **Alcance:** cerrar los 93 `[ ]` con sustento (01/03/04 + nuevo §9 del 03) y resolver los
  2 `[?]` inflados de T-M2 (Navigator-21, perfiles/slots). Misma regla de oro que M88.
- **Restricciones:** NO reescribir M53 (zona s2 `ui_manager.gd`), sin M154, sin push,
  staging quirúrgico. P12 (mapa) zona DeepSeek — no tocar.
- **Al cerrar:** actualizar este bloque · Totales · CG fila 89 · ESTADO · backlog · log ·
  mensaje de informe propio.

## 1. Shell y arquitectura (RF1/RF12)

- [x] Definir ShellManager como singleton central de pantallas [M]
- [x] Definir 21 pantallas identificadas por enum IdPantalla [M] — sustento: 01 §3 (21 pantallas) + 03 §2 (enum IdPantalla)
- [x] Definir grafo de navegación por pantalla (áreas/adyacencias) [M] — sustento: 03 §4 (grafo de areas/adyacencias)
- [x] Definir reutilización de la arquitectura UGUI/Canvas de M53 [S]
- [x] Definir principio MVC: Views solo llaman managers (AGENTS.md §9) [S]
- [x] Definir reapertura de la última pantalla tras pausa [M] — sustento: 03 §6 + §3.3 (ultima pantalla en memoria tras pausa)
- [x] Definir pantallas con plantilla Header/Cuerpo/Footer común [M] — sustento: 03 §5 (Header/Cuerpo/Footer)
- [x] Definir sin lógica de gameplay dentro de scripts de UI [S]
- [x] Definir boot que engancha ShellManager al inicio [M]
- [x] Definir cierre limpio de la app desde el shell [S] — sustento: 03 §9.7 (salida limpia, flush y quit)

## 2. Menú principal (P1)

- [x] Definir portada con identidad visual del juego (M147) [M] — sustento: 01 §3.1 (portada M147)
- [x] Definir botones: Continuar, Nueva, Cargar, Ajustes, Créditos, Salir [S] — sustento: 03 §1 (Pantallas Shell: 6 accesos)
- [x] Definir Continuar activo solo con save reciente [S] — sustento: 03 §3.1 + §9.2 (Continuar activo con save reciente)
- [x] Definir música del menú (M41) con volumen respetuoso [S] — sustento: 03 §9.1 (musica M41 -12 dB)
- [x] Definir créditos de transición de pantalla sin atascos [S] — sustento: 03 §9.1 (fade <=300 ms anti-softlock)
- [x] Definir versión del juego visible discreta [S] — sustento: 03 §9.1 (version micro M88)

## 3. Continuar (P2)

- [x] Definir reanudación del último save válido del perfil [M] — sustento: 01 RF4 + 03 §3.2 (UltimoSaveValido)
- [x] Definir manejo de múltiples perfiles (primero el selector) [M] — sustento: 03 §3.2 (selector de perfil primero)
- [x] Definir mensaje de "sin partida" si no hay saves [S] — sustento: 03 §9.2 (tooltip 'No hay partidas guardadas')
- [x] Definir validación de integridad del save antes de cargar (M59/M66) [M] — sustento: 03 §9.2 (checksum + backup M59/M66)
- [x] Definir reintento guiado ante save corrupto (backup M66) [M]

## 4. Nueva partida (P3)

- [x] Definir flujo de creación con selección de perfil/slot [M] — sustento: 03 §3.2 + §9.3 (flujo con perfil/slot)
- [x] Definir protección anti-pisada de slot ocupado [M] — sustento: 03 §3.2 (no pisa slot ocupado)
- [x] Definir confirmación explícita antes de sobreescribir [S] — sustento: 03 §9.3 (dialogo 'Sobreescribir slot N?')
- [x] Definir arranque con tutorial (M139) [S] — sustento: 03 §3.2 (tutorial M139)
- [x] Definir creación de perfil si no existe [M] — sustento: 03 §9.3 + §9.8 (creacion de perfil)
- [x] Definir nombre editable del perfil (validación de caracteres) [S] — sustento: 03 §9.3 (1-16 caracteres, trim, vacio)

## 5. Cargar partida (P4)

- [x] Definir lista de slots con resumen (isla, horas, sellos, temporada) [M] — sustento: 01 RF3 + 03 §3.2 (lista slots con resumen)
- [x] Definir slots borrables con confirmación [M] — sustento: 03 §9.4 (borrar con confirmacion)
- [x] Definir orden de slots (recién usado primero) [S] — sustento: 03 §9.4 (recien usado primero, vacios al final)
- [x] Definir navegación gamepad en la lista [M] — sustento: 03 §9.4 (D-pad wrap + A/B)
- [x] Definir carga directa sin pantalla intermedia (o minimapa de carga) [S] — sustento: 03 §3.2 (carga directa UltimoSaveValido)

## 6. Ajustes (P5/P17)

- [x] Definir acceso a ajustes desde menú principal y pausa [S]
- [x] Definir categorías: Controles, Accesibilidad, Audio, Gráfica [M] — sustento: 03 §3.4 (4 categorias)
- [x] Definir persistencia local `settings.json` (fuera del save) [M]
- [x] Definir aplicación en vivo de cambios [M] — sustento: 03 §3.4 (aplicacion en vivo)
- [x] Definir botón "Restablecer por defecto" por categoría [S] — sustento: 03 §9.5 (restablecer por categoria + dialogo)
- [x] Definir indicación de cambios no guardados [S] — sustento: 03 §9.5 (dirty-flag en Header)

## 7. Créditos (P6)

- [x] Definir pantalla de créditos con scroll [M]
- [x] Definir ralentización al final del scroll [S] — sustento: 03 §5 (ralentizacion al final)
- [x] Definir volver al menú desde créditos [S]
- [x] Definir créditos accesibles con gamepad (scroll continuo) [S] — sustento: 03 §9.6 (A acelera, B sale, stick scroll)
- [x] Definir créditos con estética del juego (M06/M49) [S]

## 8. Salir (P7)

- [x] Definir confirmación de salida [S] — sustento: 01 RF11 + 03 §9.7 (confirmacion)
- [x] Definir guardado previo si hay sesión activa [M] — sustento: 01 RF11 + 03 §9.7 ('Guardar y salir' M59)
- [x] Definir cancelación sin efectos [S] — sustento: 03 §9.7 (cancelar cierra solo el dialogo)
- [x] Definir salida limpia (procesos, cloud flush M60) [M] — sustento: 03 §9.7 (flush M60, buses, quit)

## 9. Selección de perfil (P8)

- [x] Definir perfiles 1-3 por instalación [M] — sustento: 01 §3.8 + 03 §1 (ProfileManager 1-3)
- [x] Definir tarjetas de perfil con avatar/nombre/estadística [M] — sustento: 03 §9.8 (avatar/nombre/estadistica)
- [x] Definir creación y eliminación de perfiles con confirmación [M] — sustento: 03 §9.8 (borrar con nombre y conteo; perfil activo protegido)
- [x] Definir persistencia de perfiles en M59 [M] — sustento: 03 §1 + 04 §1.2 (ProfileManager en M59)
- [x] Definir selector recordado (último perfil activo) [S] — sustento: 03 §9.8 (ultimo perfil en settings.json)

## 10. Selección de slot (P9)

- [x] Definir slots 3-6 por perfil [M] — sustento: 01 §3.9 + 03 §1 (slots 3-6 por perfil)
- [x] Definir vista de slots con datos resumen [M] — sustento: 01 RF3 (datos resumen por slot)
- [x] Definir auto-selección del último usado [S] — sustento: 03 §9.9 (foco en ultimo usado)
- [x] Definir slots bloqueados (sin save) mostrados grises [S] — sustento: 03 §9.9 (grises 50%, no enfocables, 'Vacio')
- [x] Definir orden estable (no reordena al jugar) [S] — sustento: 03 §9.9 (posiciones fijas 1..N)

## 11. Pantalla de pausa (P10)

- [x] Definir apertura con Input de pausa (Start/Esc) [M] — sustento: 03 §3.3 (Input Pausa Start/Esc)
- [x] Definir Pausar() del mundo (M07/M29) [M]
- [x] Definir opciones: Reanudar/Inventario/Mapa/Diario/Colección/Habilidades/Relación/Ajustes/Guardar/Salir al título [M] — sustento: 03 §3.3 (las 10 opciones listadas)
- [x] Definir reanudación sin saltos de tiempo [M]
- [x] Definir cierre con estado de última pantalla [S]
- [x] Definir inmunidad a inputs de gameplay en pausa [M] — sustento: 03 §9.10 (bloqueo de gameplay, solo UI)

## 12. Pantalla de inventario (P11/M16)

- [x] Definir grid paginado de ítems (12-20 por página) [M] — sustento: 03 §3.5 (grid paginado 12-20)
- [x] Definir pestañas: Items, Herramientas, Recetas [M] — hoy en código: Items/Herramientas/Construcción
- [x] Definir detalle del ítem (descripción, stack, lore opcional) [M] — sustento: 03 §9.20 (panel lateral: stack, lore)
- [x] Definir uso/equipar con confirmación cuando aplica [M]
- [x] Definir sin lógica de inventario en la View (manager M16) [S]

## 13. Pantalla de mapa (P12/M28)

- [x] Definir mapa por isla con nodos de viaje [M] — sustento: 03 §3.5 (TravelManager, mapa por isla)
- [x] Definir marcadores de progreso (sellos, colecciones por zona) [M] — sustento: 03 §3.5 (marcadores de progreso)
- [x] Definir viaje rápido desde el mapa (confirmación) [M] — sustento: 03 §9.11 (dialogo '¿Viajar a X?' + fade)
- [x] Definir leyenda de símbolos del mapa [S] — sustento: 03 §9.11 (leyenda de simbolos)
- [x] Definir datos del mapa desde TravelManager [S]

## 14. Pantalla de diario (P13/M55)

- [x] Definir pestañas: Misiones, Lore Ambiental (M148), Sellos, Estación [M] — sustento: 03 §3.5 (misiones/lore/sellos/estacion)
- [x] Definir misiones activas con objetivo y estado [M] — sustento: 03 §9.20 (objetivo y estado)
- [x] Definir lore con contador por isla (M148) [M] — sustento: 03 §9.20 (contador X/Y por isla M148)
- [x] Definir sellos con prerequisitos visibles [M]
- [x] Definir info de estación/clima (M32/M74) [S] — sustento: 03 §9.20 (clima/estacion M32/M74)

## 15. Pantalla de colección (P14/M73)

- [x] Definir pestañas: Peces, Flora, Fauna, Minerales [M] — sustento: 03 §3.5 (peces/flora/fauna/minerales)
- [x] Definir fichas con arte, descripción y lore (M148) [M] — sustento: 03 §3.5 (fichas con lore M148)
- [x] Definir contadores x/y por categoría [S] — sustento: 03 §9.12 (X/Y por categoria + global)
- [x] Definir filtros: totales, faltantes, nuevos [M] — sustento: 03 §9.12 (chips Totales/Faltantes/Nuevos)
- [x] Definir descubrimiento nuevo con notificación [S] — sustento: 03 §9.12 (distintivo 'Nuevo' hasta reabrir)

## 16. Pantalla de habilidades (P15/M71)

- [x] Definir lista/árbol de habilidades con coste y efecto [M] — sustento: 03 §3.5 (arbol/lista coste y efecto M71)
- [x] Definir desbloqueo desde la pantalla (XP/viento disponible) [M] — sustento: 03 §9.13 (coste XP/viento + 'Desbloquear')
- [x] Definir visual de nivel por habilidad [S] — sustento: 03 §9.13 (badge 0..N)
- [x] Definir sin lógica en View (ProgressionManager) [S]

## 17. Pantalla de relación (P16/M20)

- [x] Definir lista de NPC con nivel de amistad [M] — sustento: 03 §3.5 (lista NPC con nivel)
- [x] Definir regalo del día sugerido por NPC [M] — sustento: 03 §3.5 (regalo del dia)
- [x] Definir hitos de amistad visibles [M] — sustento: 03 §3.5 (hitos)
- [x] Definir avatar/retrato de cada NPC [S] — sustento: 03 §9.14 (avatar o iniciales)
- [x] Definir sin lógica en View (FriendManager) [S]

## 18. Pantalla de configuración (P17)

- [x] Definir sub-pantalla general con idioma, región, unidad [M] — sustento: 03 §9.15 (idioma/region/unidad)
- [x] Definir idioma aplicado en vivo (M87) [M] — sustento: 03 §9.15 (re-etiquetado en vivo M87)
- [x] Definir tiempo: formato 12/24 h [S] — sustento: 03 §9.15 (toggle 12/24 h)
- [x] Definir guardar al salir de configuración [S]

## 19. Pantalla de controles (P18/M58)

- [x] Definir lista de acciones remapeables [M] — sustento: 03 §9.16 (tabla InputMap agrupada)
- [x] Definir captura de teclas/ejes con escucha [M] — sustento: 03 §9.16 (escucha de un input event)
- [x] Definir restablecer por defecto [S] — sustento: 03 §9.16 (por accion o global + confirmacion)
- [x] Definir conflictos de bindings detectados [M] — sustento: 03 §9.16 (marca roja + 'Mover aqui')
- [x] Definir compatibilidad teclado + gamepad [M] — sustento: 03 §9.16 (focos/atajos de §4 en teclado y gamepad)

## 20. Pantalla de accesibilidad (P19/M58)

- [x] Definir modos de color alternativos [M] — sustento: 01 §3.19 + 03 §2 (modo color)
- [x] Definir reduce motion / flashing [M] — sustento: 03 §2 (motion) + §9 (accesibilidad)
- [x] Definir tamaño de texto 100-150% [M] — sustento: 01 DoD.7 + 03 §5 (texto escalable 150%)
- [x] Definir subtítulos configurables [M]
- [x] Definir retraso de diálogos [S] — sustento: 03 §9.17 (0-5000 ms)
- [x] Definir visor de foco (anillo) configurable [S]

## 21. Pantalla de audio (P20/M41-M44)

- [x] Definir buses: Master, Música, SFX, Ambient, Voces [M] — sustento: 01 §3.20 + 03 §2 (5 buses)
- [x] Definir slider con prueba de sonido [S] — sustento: 03 §9.18 (muestra 2 s + preview 300 ms)
- [x] Definir config de subtítulos de voces [S]
- [x] Definir mono/estéreo para accesibilidad auditiva [M] — sustento: 03 §9.18 (toggle mono en Master, en vivo)

## 22. Pantalla gráfica (P21)

- [x] Definir resolución (lista + custom) [M] — sustento: 01 §3.21 + 03 §2 (resolucion + custom)
- [x] Definir calidad (baja/media/alta/personalizada) [M] — sustento: 01 §3.21 (baja/media/alta/pers.)
- [x] Definir vsync y límite de fps [S] — sustento: 03 §9.19 (VSync on/off + FPS cap)
- [x] Definir fullscreen/windowed/borderless [S]
- [x] Definir escala de UI [S]
- [x] Definir aplicar con opción de revertir (10 s) [M] — sustento: 03 §9.19 (cuenta regresiva 10 s)

## 23. Tests y calidad (RF2/RF8/M112)

- [x] Definir suite Navigator: recorre 21 pantallas sin atascos [M] — INFLADO: no existe; T-M2 solo valida foco en 2 capas (test_m89_menus C1-C7) — resuelto T-M3: 04 §4 (NavigatorTests: 21 pantallas, 0 atascos) — diseño cumplido; implementación parcial documentada: test_m89_menus C1-C7 (foco 2 capas) y 04 §6/03 §8 (suite 21 no existe en Godot, dueño: implementación futura del grafo §4)
- [x] Definir suite de perfiles/slots 30 ciclos [M] — slots: hay `test_slots_m59` + 100 ciclos de `test_stress_m113`; perfiles NO existen (sin suite posible) — resuelto T-M3: 04 §4 (ProfileSlotTests: 30 ciclos) — diseño cumplido; slots verificados reales (test_slots_m59 + test_stress_m113 100 ciclos); perfiles sin suite posible: RF3 no implementado (gap 6 §8, dueño M59)
- [x] Definir suite de pausa: congelar/reanudar [M] — verificada hoy: casos E91/C10 (`caso_reloj_tests.gd`) + grupo F de `test_m89_menus.gd`
- [x] Definir suite de settings ida y vuelta [M] — `test_settings_audio_roundtrip.gd` (51 checks / 0 fallos)
- [x] Definir metric de apertura < 300 ms sin picos de memoria [M] — sustento: 04 §4 (PerfUITests: apertura <300 ms)
- [x] Definir foco visible en todas las pantallas (M58) [S] — sustento: 01 DoD.7 + 03 §4 (foco visible)
- [x] Definir playtest de 5 usuarios en continuar/nueva/cargar [M] — sustento: 01 DoD.3 (playtest 5 usuarios, 0 desvios)

## Auditoría contra disco (T-M2 — 2026-10-05)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-05 04:15

Método (idéntico a T-M1): lectura completa del plan-actual, contraste ítem por ítem contra los archivos reales del repo Godot, y suite headless nueva `scripts/ui/test_m89_menus.gd`. Resultado detallado en `07-Resultados-Testings.md`; plan en `06-Plan-Testings.md`.

### Suite nueva: `test_m89_menus.gd` (grupo A-H)

- **Verde final:** 48 checks / 0 fallos / `exit=0` (2026-10-05 03:55).
- **Sonda rojo (honestidad):** constante `ESPERA_BOTONES_MENUS` 5→6 → `FALLO: A5 5 botones (esperados 6)` / 1 fallo / `exit=1`; constante restaurada y verde reejecutado.
- **Regresión:** `test_ui_framework.gd` 0 fallos / `exit=0`; `test_diario_ui.gd` 89 checks / 0 fallos / `exit=0`.

### Flips aplicados (8 `[ ]`→`[x]`, 2 `[x]`→`[?]`)

| Ítem | Antes→Después | Evidencia |
|------|---------------|-----------|
| §6 acceso a ajustes desde menú y pausa | [ ]→[x] | `ui_root.gd:194-199` conecta `ajustes_pedido` de MenusLayer y PauseLayer; suite E7-E8 |
| §7 pantalla de créditos con scroll | [ ]→[x] | `credits_layer.gd:342` avance por `VELOCIDADES`; 3 velocidades (D5) |
| §7 volver al menú desde créditos | [ ]→[x] | `credits_layer.cerrar()` → `close_top()` (D4) |
| §7 créditos con estética del juego (M06) | [ ]→[x] | paleta ThemeUx (COLOR_BG_ARENA, ocre) en todo el layer |
| §11 Pausar() del mundo (M07/M29) | [ ]→[x] | `ui_manager.gd:82-92`; suite F: logs `mundo PAUSADO`/`REANUDADO` |
| §11 reanudación sin saltos de tiempo | [ ]→[x] | `game_clock.gd` `_pausado` + casos E91/C10 (`caso_reloj_tests.gd`) |
| §11 cierre con estado de última pantalla | [ ]→[x] | T-053-066 deep-linking pausa↔ajustes (`pause_layer.gd:88-100`) + semántica de pila |
| §12 pestañas inventario | [ ]→[x] | `inventory_layer.gd:21` (hoy: Items/Herramientas/Construcción; "Recetas" renombrado) |
| §23 suite Navigator 21 pantallas | [x]→[?] | INFLADO: no existe; hoy solo foco verificado en 2 capas (C1-C7) |
| §23 suite perfiles/slots 30 ciclos | [x]→[?] | INFLADO en perfiles: no existen perfiles; slots sí (`test_slots_m59`, 100 ciclos en `test_stress_m113`) |

### Gaps de la auditoría (integran los 93 `[ ]` restantes)

1. RF1 incompleto: **5/6 botones** del menú principal (falta "Cargar"; botones hoy: Jugar/Continuar/Ajustes/Créditos/Salir).
2. **Nadie llama `menus_layer.open()`** → el título no se muestra al arrancar.
3. RF11: `salir_pedido` → `get_tree().quit()` **sin confirmación** de salida.
4. RF11/RF5: Esc/Start en juego **solo cierra capas**; abrir PauseLayer es solo vía RF18 (M58).
5. Ajustes = **solo Audio** (`SettingsAudioLayer`); faltan pantallas de Controles/Accesibilidad/Gráfica.
6. **Perfiles 1-3 no existen** en M59 (solo slots).
7. Inventario con **scroll, no grid paginado** (§12 ítem íntegro).
8. Sin portada M147, sin versión visible, sin 21 pantallas/enum IdPantalla (docs = diseño heredado Unity).

## Totales

**Total de ítems:** 125
**Completados [x]:** 124
**No resueltos [?]:** 1 (M154 caído — dueño M154 visión)
**Pendientes [ ]:** 0

> Cierre T-M3 por mimo-v2.6-flash-free 2026-10-06: 93 `[ ]` → `[x]` con
> sustento (01-Requerimientos, 03-Diseno §1-9 — §9 NUEVO con ~35 definiciones
> de cierre — 04-Codigo §4); 2 `[?]` inflados de T-M2 resueltos con 04 §4
> (diseño de suites cumplido; implementación parcial documentada en notas);
> 1 `[x]` falso heredado (M154 «operativo») bajado a `[?]`. Ver notas abajo.

## Dependencia: Visión del Agente (M154)

- [?] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S] → KnownIssue: M154 CAIDO (ninguna via operativa al cierre); dueño: M154 visión
**Totales:** 125 ítems · Completados: 124 · Pendientes: 0 · No resueltos: 1.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 24 [x] / 101 [ ] / 0 [?].
> Las marcas no se tocaron.
## Notas del Agente — T-M3 (cierre, mensaje 35)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** OpenCode
**Fecha:** 2026-10-06 17:25
**Estado:** Cerrado — **124 [x] / 1 [?] / 0 [ ] = 125** — candidato a ✅ pendiente QA §21.8

### Qué se hizo

- **93 `[ ]` → `[x]`** con sustento ítem por ítem (cita al lado de cada marca):
  - 01-Requerimientos §3 (21 pantallas), §4 (RF1-RF12), §5 (DoD).
  - 03-Diseno §1-8 (arquitectura, enum, flujos, navegación, estética, estados).
  - **03-Diseno §9 NUEVO** (redactado en esta iteración): ~35 definiciones que faltaban —
    música M41/versión/transiciones (§9.1), sin partida/integridad (§9.2), sobreescribir/
    nombre (§9.3), orden/borrado/gamepad de slots (§9.4), restablecer/dirty-flag (§9.5),
    gamepad créditos (§9.6), salida limpia M60 (§9.7), tarjetas/perfil recordado (§9.8),
    slots auto/grises/estables (§9.9), inmunidad pausa (§9.10), viaje rápido/leyenda (§9.11),
    filtros/contadores/notificación (§9.12), XP/nivel habilidades (§9.13), retratos (§9.14),
    idioma/12-24h (§9.15), remapeo/conflictos (§9.16), retraso diálogos (§9.17), sliders/
    mono (§9.18), revertir 10 s/VSync-FPS (§9.19), detalles de contenido (§9.20).
  - 04-Codigo §4 (diseño de las 7 suites Unity).
- **2 `[?]` inflados de T-M2 resueltos** (mismo criterio: el ítem es «Definir», no «ejecutar»):
  - NavigatorTests y ProfileSlotTests **están diseñados en 04 §4** → `[x]` con la
    advertencia de implementación conservada en la cita (Navigator: solo foco en 2 capas
    en `test_m89_menus` C1-C7, grafo §4 inexistente; perfiles: RF3 no implementado,
    gap 6 de §8 con dueño M59 — sin suite posible mientras no existan perfiles).
- **1 `[x]` falso heredado corregido:** ítem de dependencia M154 («verificar operativo»)
  → `[?]` con dueño M154 — está caído (ninguna vía operativa), el `[x]` de la auditoría
  de drift (2026-09-20) no era veraz.

### Evidencia (Godot 4.7.2 headless, 2026-10-06)

- `scripts/ui/test_m89_menus.gd` → **48 checks / 0 fallos / exit 0**.
- `scripts/ui/test_settings_audio_roundtrip.gd` → **51 checks / 0 fallos / exit 0**.
- **Sonda roja validada:** `ESPERA_BOTONES_MENUS` 5→6 → `FALLO: A5 5 botones (esperados 6)`,
  1 fallo, **exit 1**; restaurado (git, byte-exact) y verde confirmado.

### Lo que NO se hizo (honestidad)

- Sin M154, sin push, sin tocar M53 (`ui_manager.gd` zona s2) ni el mapa (zona DeepSeek).
- NO se implementó código nuevo: el alcance fue documental («Definir» = diseño) + §9.
- Los **gaps de implementación siguen abiertos** (03 §8 / 04 §6, sin dueño nuevo):
  P4 Cargar sin pantalla, P8 perfiles, ajustes 1/4, P7 quit sin confirmación, 5/6 botones,
  enum IdPantalla inexistente, Navigator grafo → `menu_navigator.gd` parcial. Son
  **implementación futura**, no pendiente de este cierre documental; por eso el módulo
  queda 🟡 y no ✅ (más QA §21.8 pendiente).

### Recomendaciones

- QA §21.8: re-correr las 2 suites + sonda; muestrear citas del §9 nuevo.
- Si algún equipo implementa P8 perfiles, actualizar el `[x]` de ProfileSlotTests a
  «suite ejecutada» y quitar el matiz de la cita.
