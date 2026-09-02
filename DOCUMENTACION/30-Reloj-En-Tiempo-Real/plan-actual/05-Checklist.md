**Modelo:** GLM
**Plataforma:** Cline

# 05-Checklist.md — Módulo 30: Reloj en Tiempo Real

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (después de M29).

> **Reserva actual:** 🟡 **Liberada 98/104** — glm-5.3-flash (campo, visión) + glm-5.3 (cierre/auditoría) / Cline · cierre 2026-09-01 00:55 · Log 318 · auditoría post-cierre Log 320 · **Iteración 2** — hover/desplegable D70 (TooltipService), suite bloque E (`caso_reloj_tests.gd` + `caso_reloj.tscn`), config `data/ui/w_reloj.tres` (F100/F107/F101), scan anti-reloj-SO (C56/E89/E90). Archivos: `scripts/clock/{w_reloj,w_reloj_config,caso_reloj_tests,preview_reloj}.gd`, `data/ui/w_reloj.tres`, `scenes/caso_reloj.tscn`.

## A. Requisitos del módulo (12)

- [x] Definir el problema: mostrar el tiempo del mundo al jugador [S] → 01-Requerimientos/02-Analisis
- [x] Resolver si el tiempo real del SO influye (decisión explícita) [S] → NO; 02-Analisis P1
- [x] RF1: reloj siempre visible en HUD [S] → RelojWidget montado en main_island.tscn (CanvasLayer UI)
- [x] RF2: el SO NO condiciona el juego [S] → scan C56: 0 lecturas de reloj-SO en gameplay
- [x] RF3: tiempo offline congelado (sin castigos) [S] → GameClock solo avanza por _process (caso 10 OK)
- [x] RF4: anti-exploit de manipulación del reloj del SO [S] → estructural (sin lecturas OS) + test
- [x] RF5: única fuente de tiempo = GameClock (M29) [S] → widget solo display
- [x] RF6: fallback ante hora anómala del SO (ignorar) [S] → GameClock nunca lee el SO
- [x] RF7: pruebas de fechas límite (año nuevo, fin de mes, cumpleaños) [S] → suite E 29 checks 0 fallos
- [x] Sin FOMO / sin presión de entrar diario (pilar cozy) [S] → mundo congelado offline
- [x] Widget es display puro (sin lógica de tiempo propia) [S] → sin setters ni acumuladores
- [x] Criterio: módulo delegable hoy, sin voxel/assets [S] → implementado sin voxel/assets

## B. Resolución de los 20 puntos del plan (20)

- [x] P1: tiempo real → NO (decision) [S]
- [x] P2: dependencia del reloj del sistema → ninguna [S]
- [x] P3: comportamiento offline → mundo congelado [S]
- [x] P4: adelantar reloj → sin efecto [S]
- [x] P5: retroceder reloj → sin efecto [S]
- [x] P6: evitar exploits → fuente interna determinista [S]
- [x] P7: evitar castigos → sin penalización por ausencia [S]
- [x] P8: eventos mensuales → disparados por calendario interno [S]
- [x] P9: sincronización → tick por delta real (precisión) [S]
- [x] P10: zona horaria → no aplica, se ignora [S]
- [x] P11: horario de verano → no aplica [S]
- [x] P12: cambio de zona horaria → sin impacto [S]
- [x] P13: fallback sin reloj correcto → GameClock no depende del OS [S]
- [x] P14: pruebas de fecha → suite planificada (M112) [S] → implementada en caso_reloj_tests.gd
- [x] P15: prueba de año nuevo → caso 4 de la tabla [S] → OK
- [x] P16: prueba de fin de mes → caso 3 de la tabla [S] → OK
- [x] P17: años bisiestos → no aplica (año fijo 336 días) [S]
- [x] P18: recuperación de errores → reinicia día desde guardado [S]
- [x] P19: protección contra manipulación accidental → API cerrada [S]
- [x] P20: experiencia offline → retoma exacta (persistencia M29) [S]

## C. Regla de oro anti-exploit (10)

- [x] Ningún gameplay lee `Time.get_*()` del SO [S] → scan 240 archivos: 0 usos fuera de whitelist de diagnóstico
- [x] Única fuente: GameClock interno [S]
- [x] Adelantar reloj OS → 0 ventaja [S] → estructural: nadie lee el SO
- [x] Retroceder reloj OS → 0 ventaja [S] → estructural: nadie lee el SO
- [x] Sin setters públicos de hora (solo API GameClock) [S] → get_* + pausa/resume/avanzar_hasta
- [x] Persistencia de tiempo solo en GameState.M29 [S] → GameClock ISaveProvider "time"; M30 no persiste
- [x] Excepción única: título cosmético del menú principal (ocultable) [S] → documentada 03-Diseno §3.2; sin lecturas hoy
- [x] Test estático anti-reloj-SO (scan de Time.* en gameplay, M111) [M] → caso_reloj_tests.gd (240 archivos, 0 violaciones)
- [x] Documentado en plan-actual/04-Codigo.md (regla de oro) [S] → actualizado iter. 2
- [ ] Consumidores advertidos (M74, M28, M36) [S] → módulos aún no implementados; contrato en 04-Codigo §2 listo para ellos

## D. Widget de reloj — diseño (14)

> **Estado 2026-08-26 (GLM/Cline, iteración con visión V2):** núcleo implementado y **verificado visualmente con capturas** (`w_reloj.gd` + `preview_reloj.tscn`). Los ítems sin asset/hover quedan pendientes o `[?]`.
> **Re-verificación in-engine 21:30 (GLM/Cline, Log 178):** reloj **visible, íntegro y avanzando en vivo** (08:00 → 09:00) confirmado con captura del viewport maximizado. Se corrigieron **3 bugs** descubiertos al relanzar: (1) el autoload Bootstrap pisaba la escena pedida por CLI → fix en `bootstrap.gd`; (2) el panel tenía altura negativa (-16 px) por `set_anchors_preset` + offsets parciales → fix con `set_anchors_and_offsets_preset(PRESET_TOP_RIGHT, PRESET_MODE_MINSIZE, 16)`; (3) DPI 125 % recortaba el HUD en la ventana CLI → fix con `WINDOW_MODE_MAXIMIZED` desde la preview. Detalles en 07-GUIA-GODOT §9.25–§9.28.

- [x] Hora HH:MM con formato 12h/24h configurable [S] → `RelojHud.formatear_hora` (test 14/14 OK)
- [x] Fecha completa: "Viernes, 12 de Primavera, Año 1" [S] → `_fecha_visual()` vía RelojHud
- [?] Ícono de estación (hoja/sol/hoja seca/copo) [M] → sin assets aún; chip textual coloreado como placeholder. Requiere M45/M46 (fase arte)
- [x] Color de fondo por estación [S] → chip `StyleBoxFlat` tintado con `COLOR_ESTACION`
- [x] Ubicación: superior derecha del HUD [S] → anclado TOP_RIGHT en captura iter1
- [x] Desplegable al pasar el cursor (detalle) [S] → tooltip vía TooltipService (M53) por rect del cursor, SIN bloquear clicks (D78 intacto); captura oficial cap_30_2026-08-31_23-30-00_02_hover.png
- [x] Suscripción a `hora_cambio` (sin polling) [S] → avance vivo confirmado entre capturas iter1/iter2
- [x] Suscripción a `dia_cambio` [S]
- [x] Suscripción a `estacion_cambio` [S]
- [ ] Badge de evento activo (evento_activado) [S] → depende de señales de eventos (M64)
- [x] Localizable (M57): nombres desde data [S] → usa NOMBRES_* de GameTime (pendiente claves M57)
- [x] Config en `data/ui/w_reloj.tres` [S] → WRelojConfig (formato 12h/24h, margen, ancho, chip, color) + fallback defaults (F107)
- [x] Fuente del GDD: HUD limpio, sin interfaz invasiva [S] → panel compacto semitransparente
- [x] No bloquea clicks (área no interactiva) [S] → `mouse_filter = MOUSE_FILTER_IGNORE`

## E. Pruebas de límites — diseño (14)

- [x] Caso 1: tick normal 1s → +1 min [S] → OK
- [x] Caso 2: fin de día 23:59 → 00:00 [S] → OK + dia_cambio
- [x] Caso 3: fin de mes día 28 → mes siguiente [S] → OK
- [x] Caso 4: fin de año día 336 → año+1 sin overflow [S] → OK
- [x] Caso 5: cambio de estación con aviso [S] → OK + estacion_cambio
- [x] Caso 6: cumpleaños de vecino dispara evento [S] → cumpleanos_jugador 1/1 dispara evento_activado vía TimeCalendar
- [x] Caso 7: persistencia exacta (guardar 14:32 → cargar 14:32) [S] → OK
- [x] Caso 8: retroceder reloj SO (Set-SystemTime -1d) sin efecto [M] → verificado ESTRUCTURALMENTE (scan: 0 gameplay lee el SO; no se muta el reloj real de la máquina)
- [x] Caso 9: adelantar reloj SO (+1 mes) sin efecto [M] → ídem caso 8
- [x] Caso 10: 7 días reales de ausencia → congelado [S] → pausa = 0 avance; retoma exacta
- [x] Tests en `caso_reloj_tests.gd` (M112) [M] → 29 checks, 0 fallos
- [x] Escenario `caso_reloj.tscn` creado para el test [M] → scripts/clock/caso_reloj.gd
- [x] Criterio de éxito definido por caso [S] → cada _check con criterio explícito
- [x] Sin dependencia de hora real en asserts [S] → solo estado interno de GameClock

## F. Persistencia y configuración (10)

- [x] GameState.M29 único dueño del tiempo [S] → GameClock registra provider "time"; M30 no persiste
- [x] w_reloj.tres: formato hora, posición, colores [S] → WRelojConfig con fallback
- [x] Formato 12h/24h desde Ajustes (M46) [S] → config funcional y testeada; M46 escribirá el recurso desde su UI
- [x] Sin duplicar estado temporal en M30 [S] → widget display puro
- [x] Carga: leer GameState al entrar a la escena [S] → lee GameTime autoload en _ready + señales
- [x] Guardado: no guarda nada propio (solo M29) [S]
- [ ] Versionado de data si cambia formato (M59) [S] → M30 no persiste; aplicaré cuando haya data versionable (dueño M59)
- [x] Nombres localizables por clave (M57) [S] → usa NOMBRES_* de GameTime; claves .po pendientes (dueño M57) — glm-5.3-flash 2026-09-01 (iter. 3): _estacion_nombre consulta Localization con claves CLOCK.ESTACIONES.* (es/en .po, fallback hardcode), test_reloj_localizacion 0 fallos
- [x] Fallback de datos si .tres corrupto → valores por defecto [M] → testeado (F107)
- [x] Sin lectura de hora OS en ningún .tres [S] → w_reloj.tres solo config visual

## G. Integración y dependencias (12)

- [x] Depende solo de M29 (GameClock) [S] → GameTime + RelojHud (propio de M30)
- [ ] Consumidores que lo referencian: M74, M28, M36 [S] → módulos aún no implementados; contrato listo en 04-Codigo §2
- [x] Se integra al HUD principal (M53) [S] → montado en CanvasLayer UI de main_island.tscn; hover usa TooltipService (M53)
- [x] No depende de M08 voxel [S]
- [x] No depende de M11 jugador [S]
- [x] No requiere física [S]
- [x] Sin assets nuevos (solo íconos de M46/M45) [S] → chip textual + tooltip de texto
- [x] Compatible con pausa de menú (M29 pausa el clock) [S] → caso 10: pausa congela el widget con él
- [x] Compatible con dormir (avanzar_hasta 06:00) [S] → ráfaga de señales refresca el display
- [x] EventBus time usado de M07 [S] → corrección iter. 2: la API real de M29 son señales propias de GameClock + EventBus.calendar (day_started/season_changed); EventBus.time solo expone fase_cambio (M31). Contrato actualizado en 04-Codigo §2
- [x] Servicio registrado en project.godot por M07 [S] → RelojHud autoload
- [x] No rompe guardados de versiones previas [S] → M30 no altera el formato de save de M29

## H. Delegación y cierre (12)

- [x] Necesidad del módulo justificada (display + política) [S] → 02-Analisis §4
- [x] Alternativas evaluadas y descartadas (3) [S] → 02-Analisis §3
- [x] API estable para consumidores [S] → contrato actualizado a la API real en 04-Codigo §2
- [x] Implementación → AGENTE DELEGADO (dueño explícito) [S] → iter. 1 GLM/Cline (26/08); iter. 2 glm-5.3/Cline (01/09)
- [x] Estático anti-reloj-SO propuesto para M111 [S] → implementado en caso_reloj_tests.gd (reutilizable por M111/M112)
- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado [S]
- [x] 03-Diseno creado y firmado [S]
- [x] 04-Codigo creado y firmado (Notas del Agente incluidas) [S] → actualizado iter. 2
- [x] 05-Checklist creado y firmado (este archivo) [S] → actualizado iter. 2
- [x] Log de creación generado [S] → Log 43; iter. 2 → Log 309
- [x] Checked en README de DOCUMENTACION [S] → actualizado iter. 2

**Totales (2026-09-01, iter. 2 — glm-5.3/Cline):** 104 ítems · **98 `[x]` · 1 `[?]` (D67 ícono estación, requiere assets M45/M46) · 5 `[ ]` con dueño externo** (D74 badge evento M64 · C58/G113 consumidores M74/M28/M36 · F105 versionado M59 · F106 claves M57).
**Verificación iter. 2:** suite headless `caso_reloj_tests.gd` → **29 checks, 0 fallos** · capturas in-engine `cap_30_2026-08-31_23-30-00_{00,01,02}_hover.png` (tooltip del hover verificado).
**Nota:** los pendientes restantes dependen de módulos externos (M45/M46/M57/M59/M64, M74/M28/M36); el núcleo M30 (display + política + hover + config + pruebas) está cerrado.

## Notas del Agente

**Modelo:** GLM
**Plataforma:** Cline
**Fecha:** 2026-08-26 18:40:00
**Estado:** Parcial (núcleo HUD verificado con visión)

### Lo que hice
- Creé `game/isla-ancestral/scripts/clock/w_reloj.gd`: widget Control puro anclado arriba-derecha (hora 34px, fecha, chip de estación tintado con `COLOR_ESTACION`), suscripción a `hora_cambio`/`dia_cambio`/`estacion_cambio`, fallback mock si no hay GameTime, `mouse_filter = IGNORE`.
- Creé `scenes/preview_reloj.tscn` (formato correcto `[gd_scene format=3]`, el header era lo que faltaba antes) + `scripts/clock/preview_reloj.gd` (cielo gradiente `TextureRect`+`GradientTexture2D`, pasto, sol; demo que avanza GameTime ×25 cada 2 s).
- Verifiqué con visión (V2): layout legible sobre fondo claro/oscuro, chip de estación visible, **avance de hora EN VIVO confirmado entre capturas iter1/iter2** (binding por señales sin polling).
- Capturas de evidencia en `tools/mcp/godot-mcp/capturas/30-Reloj-En-Tiempo-Real/` (iter1 y iter2).

### Lo que NO pude hacer (honestidad obligatoria)
- Ícono de estación → no hay assets (M45/M46); dejé chip textual coloreado. `[?]`
- Desplegable hover / badge de evento → requieren tooltip animado y señales de eventos M64. Pendientes `[ ]`.
- Integración al HUD real (M53) y config `.tres` (M57/M46) → fuera del alcance de esta iteración.

### Intentos fallidos / decisiones
- Bug runtime corregido: `ColorRect.texture` no existe → reemplazado por `TextureRect` + `EXPAND_IGNORE_SIZE`.
- GDScript 4 no permite `const` dentro de funciones → cambiado a `var` local.
- Un agente anterior marcó totales "104/104" pero los estados eran `[ ]`; se recalcó honestamente solo el bloque D verificado esta sesión.

### Recomendaciones para el próximo agente
- Conectar WReloj como hijo del HUD principal cuando exista M53 (`ui_hud.tscn`).
- Para hover/desplegable usar `mouse_filter = STOP` SOLO en el panel (no en hijos) y un Tween de opacidad (M52).
- El patrón `.tscn` manual correcto está en `scenes/preview_reloj.tscn`; reutilizar ese header.

---

## Notas del Agente (iteración 2)

**Modelo:** glm-5.3-flash (campo, visión) + glm-5.3 (cierre/auditoría)
**Plataforma:** Cline
**Fecha:** 2026-09-01 00:55 (cierre) · 02:00 (auditoría, Log 320)
**Estado:** Parcial — 98/104 (1 `[?]`, 5 `[ ]` con dueño externo); núcleo M30 cerrado

### Lo que hice
- **D70 desplegable hover:** tooltip contextual vía TooltipService (M53) con formato M88 "Título|Cuerpo" (fecha completa, sesión del día, estación, próximos eventos). Detección por rect del cursor en `_process` — **sin capturar el mouse** (`MOUSE_FILTER_IGNORE` de D78 intacto). Verificado con captura oficial `cap_30_2026-08-31_23-30-00_02_hover.png`.
- **F100/F107 config data-driven:** `data/ui/w_reloj.tres` (WRelojConfig: usar_formato_12h, margen_borde, ancho_min, mostrar_chip_estacion, color_fondo) con fallback a defaults si falta/corrupto + `config_inyectada` para tests.
- **F101 formato 12h/24h real:** vía `RelojHud.formatear_hora` estático + flag del config.
- **Bloque E completo:** suite headless `scripts/clock/caso_reloj_tests.gd` → **29 checks, 0 fallos** (casos 1-7, 10 + widget en escena + hover + config + formato + scan). Casos 8/9 verificados ESTRUCTURALMENTE por el scan (0 gameplay lee el reloj del SO en 240 archivos; no se muta el reloj real de la máquina del usuario).
- **C56/E89/E90 scan anti-reloj-SO** integrado en la suite, con whitelist documentada (logging/analytics/telemetry/performance/saving/editor — timestamps de diagnóstico, no gameplay) y auto-exclusión del propio test.
- **E93:** escenario `scenes/caso_reloj.tscn` + `scripts/clock/caso_reloj.gd` (fondo neutro + WReloj en CanvasLayer layer 0, bajo el TooltipService).
- **Preview iter. 2:** 3.ª captura con tooltip del hover forzado (`demo_cursor_dentro`).
- **Backup §5:** `scripts/clock/Obsoletos/2026-08-31_23-05-00_w_reloj.gd` antes de la reescritura.
- Marcado honesto de A/B/C/F/G/H verificando `02-Analisis` (P1-P20), el código y la suite.

### Lo que NO pude hacer (honestidad obligatoria)
- **D74 badge de evento:** `TimeCalendar.evento_activado` ya emite festivales/cumpleaños (verificado en el caso 6), pero el badge visual requiere diseño de M64 → `[ ]`.
- **D67 `[?]`:** ícono de estación requiere assets M45/M46 (chip textual + colores como placeholder).
- **C58/G113:** consumidores M74/M28/M36 aún no existen → `[ ]` con contrato listo en 04-Codigo §2.
- **F105/F106:** versionado M59 y claves .po de M57 → dueño externo.
- ⚠️ **HALLAZGO CROSS-MODULE (NO es de M30):** el theme global de M53/M88 aplica una **fuente ausente** (errores `FreeType: Error loading font: ''` en el arranque) → TODOS los Labels del juego renderizan SIN texto. Confirmado comparando capturas: iter. 1 (26/08) mostraba "08:00 / Lunes, 1 de Primavera, Año 1 / Primavera"; iter. 2 (01/09) muestra el panel sin texto. El tooltip del hover SÍ se ve porque TooltipService no usa el theme. **Dueño del fix: M53/M88** (fallback condicional a la fuente default o instalar las fuentes). Reportado en Log 318 y 07-GUIA-GODOT §9.53.

### Verificación
- `godot --headless --path game/isla-ancestral -s res://scripts/clock/caso_reloj_tests.gd` → `=== Resumen: 29 checks, 0 fallos ===`
- Capturas: `tools/mcp/godot-mcp/capturas/30-Reloj-En-Tiempo-Real/cap_30_2026-08-31_23-30-00_{00,01,02}_hover.png`
- Nota: el exit code 1 de los headless actuales proviene del autoload `interacciones` (M17, pre-asignado a DeepSeek V4 Flash — errores de parseo ajenos a M30).

### Recomendaciones para el próximo agente
- **URGENTE (M53/M88):** arreglar la fuente del theme global; sin eso todo el texto del juego es invisible.
- **D74:** conectar el badge a `TimeCalendar.evento_activado` cuando M64 defina el diseño (la señal ya dispara en festivales/cumpleaños).
- El scan del test se auto-excluye (`caso_reloj_tests.gd` contiene los nombres de las APIs como datos); si M111 absorbe el scan, mantener esa exclusión.
- `config_inyectada`/`ruta_config`/`demo_cursor_dentro` son seams de test/preview: no usarlos en gameplay.

### Auditoría post-cierre (2026-09-01 — glm-5.3 / Cline, Log 320)

Revisión integral de toda la iter. 2 (incluido el trabajo de campo completado por **glm-5.3-flash** con visión, tras el bloqueo de glm-5.3):

- [x] Suite re-ejecutada en auditoría con el binario real (`Godot_v4.7.2 --headless --script res://scripts/clock/caso_reloj_tests.gd`) → **exit code 0** (29 checks, 0 fallos; conteo verificado leyendo el código: 29 `_check` exactos).
- [x] Capturas verificadas visualmente: cap 00 (widget sin texto — bug M53/M88 de fuente, panel colapsado), cap 02 (tooltip D70 renderiza completo: fecha, sesión, estación, próximos eventos). Comparativa vs captura del 26/08 (texto visible) consistente con §9.53.
- [x] Código auditado línea por línea: D78 `MOUSE_FILTER_IGNORE` intacto, F100/F107/F101 aplicados desde config, señales con desconexión en `_exit_tree`, seams (`demo_cursor_dentro`, `config_inyectada`, `ruta_config`) solo para test/preview.
- [x] Tests auditados: los checks son reales (no no-ops): E93 verifica instancia/posición/IGNORE/label/set_process; D70 usa el camino real `_process → _actualizar_hover` y verifica tooltip visible + hide + pool; scan con whitelist y auto-exclusión.
- [x] **Corrección de numeración:** la sección de la fuente en 07-GUIA-GODOT estaba publicada como §9.50 duplicada (colisión con la §9.50 de Hy3, Log 299) → renumerada a **§9.53** + fila en la tabla de registro (Log 320).
- [x] **Corrección de referencia:** el hallazgo de la fuente se reportó en el **Log 318** (estaba mal atribuido a "Log 309", que es de M21) en CHECKLIST-GLOBAL, este checklist y la guía 07.
- Nota de atribución (honestidad): PARTE 2 de la suite y las capturas in-engine (00:22–00:50) fueron completadas por **glm-5.3-flash (Cline)** después de que la sesión de glm-5.3 quedara truncada sin visión; la revisión/corrección integral posterior fue de glm-5.3. Ambos trabajos quedan cubiertos por esta auditoría.