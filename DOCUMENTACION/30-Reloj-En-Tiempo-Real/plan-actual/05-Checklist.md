**Modelo:** GLM
**Plataforma:** Cline

# 05-Checklist.md — Módulo 30: Reloj en Tiempo Real

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (después de M29).

## A. Requisitos del módulo (12)

- [ ] Definir el problema: mostrar el tiempo del mundo al jugador [S]
- [ ] Resolver si el tiempo real del SO influye (decisión explícita) [S]
- [ ] RF1: reloj siempre visible en HUD [S]
- [ ] RF2: el SO NO condiciona el juego [S]
- [ ] RF3: tiempo offline congelado (sin castigos) [S]
- [ ] RF4: anti-exploit de manipulación del reloj del SO [S]
- [ ] RF5: única fuente de tiempo = GameClock (M29) [S]
- [ ] RF6: fallback ante hora anómala del SO (ignorar) [S]
- [ ] RF7: pruebas de fechas límite (año nuevo, fin de mes, cumpleaños) [S]
- [ ] Sin FOMO / sin presión de entrar diario (pilar cozy) [S]
- [ ] Widget es display puro (sin lógica de tiempo propia) [S]
- [ ] Criterio: módulo delegable hoy, sin voxel/assets [S]

## B. Resolución de los 20 puntos del plan (20)

- [ ] P1: tiempo real → NO (decision) [S]
- [ ] P2: dependencia del reloj del sistema → ninguna [S]
- [ ] P3: comportamiento offline → mundo congelado [S]
- [ ] P4: adelantar reloj → sin efecto [S]
- [ ] P5: retroceder reloj → sin efecto [S]
- [ ] P6: evitar exploits → fuente interna determinista [S]
- [ ] P7: evitar castigos → sin penalización por ausencia [S]
- [ ] P8: eventos mensuales → disparados por calendario interno [S]
- [ ] P9: sincronización → tick por delta real (precisión) [S]
- [ ] P10: zona horaria → no aplica, se ignora [S]
- [ ] P11: horario de verano → no aplica [S]
- [ ] P12: cambio de zona horaria → sin impacto [S]
- [ ] P13: fallback sin reloj correcto → GameClock no depende del OS [S]
- [ ] P14: pruebas de fecha → suite planificada (M112) [S]
- [ ] P15: prueba de año nuevo → caso 4 de la tabla [S]
- [ ] P16: prueba de fin de mes → caso 3 de la tabla [S]
- [ ] P17: años bisiestos → no aplica (año fijo 336 días) [S]
- [ ] P18: recuperación de errores → reinicia día desde guardado [S]
- [ ] P19: protección contra manipulación accidental → API cerrada [S]
- [ ] P20: experiencia offline → retoma exacta (persistencia M29) [S]

## C. Regla de oro anti-exploit (10)

- [ ] Ningún gameplay lee `Time.get_*()` del SO [S]
- [ ] Única fuente: GameClock interno [S]
- [ ] Adelantar reloj OS → 0 ventaja [S]
- [ ] Retroceder reloj OS → 0 ventaja [S]
- [ ] Sin setters públicos de hora (solo API GameClock) [S]
- [ ] Persistencia de tiempo solo en GameState.M29 [S]
- [ ] Excepción única: título cosmético del menú principal (ocultable) [S]
- [ ] Test estático anti-reloj-SO (scan de Time.* en gameplay, M111) [M]
- [ ] Documentado en plan-actual/04-Codigo.md (regla de oro) [S]
- [ ] Consumidores advertidos (M74, M28, M36) [S]

## D. Widget de reloj — diseño (14)

> **Estado 2026-08-26 (GLM/Cline, iteración con visión V2):** núcleo implementado y **verificado visualmente con capturas** (`w_reloj.gd` + `preview_reloj.tscn`). Los ítems sin asset/hover quedan pendientes o `[?]`.
> **Re-verificación in-engine 21:30 (GLM/Cline, Log 178):** reloj **visible, íntegro y avanzando en vivo** (08:00 → 09:00) confirmado con captura del viewport maximizado. Se corrigieron **3 bugs** descubiertos al relanzar: (1) el autoload Bootstrap pisaba la escena pedida por CLI → fix en `bootstrap.gd`; (2) el panel tenía altura negativa (-16 px) por `set_anchors_preset` + offsets parciales → fix con `set_anchors_and_offsets_preset(PRESET_TOP_RIGHT, PRESET_MODE_MINSIZE, 16)`; (3) DPI 125 % recortaba el HUD en la ventana CLI → fix con `WINDOW_MODE_MAXIMIZED` desde la preview. Detalles en 07-GUIA-GODOT §9.25–§9.28.

- [x] Hora HH:MM con formato 12h/24h configurable [S] → `RelojHud.formatear_hora` (test 14/14 OK)
- [x] Fecha completa: "Viernes, 12 de Primavera, Año 1" [S] → `_fecha_visual()` vía RelojHud
- [?] Ícono de estación (hoja/sol/hoja seca/copo) [M] → sin assets aún; chip textual coloreado como placeholder. Requiere M45/M46 (fase arte)
- [x] Color de fondo por estación [S] → chip `StyleBoxFlat` tintado con `COLOR_ESTACION`
- [x] Ubicación: superior derecha del HUD [S] → anclado TOP_RIGHT en captura iter1
- [ ] Desplegable al pasar el cursor (detalle) [S] → pendiente (animación tooltip)
- [x] Suscripción a `hora_cambio` (sin polling) [S] → avance vivo confirmado entre capturas iter1/iter2
- [x] Suscripción a `dia_cambio` [S]
- [x] Suscripción a `estacion_cambio` [S]
- [ ] Badge de evento activo (evento_activado) [S] → depende de señales de eventos (M64)
- [x] Localizable (M57): nombres desde data [S] → usa NOMBRES_* de GameTime (pendiente claves M57)
- [ ] Config en `data/ui/w_reloj.tres` [S] → valores hardcodeados aceptables por ahora
- [x] Fuente del GDD: HUD limpio, sin interfaz invasiva [S] → panel compacto semitransparente
- [x] No bloquea clicks (área no interactiva) [S] → `mouse_filter = MOUSE_FILTER_IGNORE`

## E. Pruebas de límites — diseño (14)

- [ ] Caso 1: tick normal 1s → +1 min [S]
- [ ] Caso 2: fin de día 23:59 → 00:00 [S]
- [ ] Caso 3: fin de mes día 28 → mes siguiente [S]
- [ ] Caso 4: fin de año día 336 → año+1 sin overflow [S]
- [ ] Caso 5: cambio de estación con aviso [S]
- [ ] Caso 6: cumpleaños de vecino dispara evento [S]
- [ ] Caso 7: persistencia exacta (guardar 14:32 → cargar 14:32) [S]
- [ ] Caso 8: retroceder reloj SO (Set-SystemTime -1d) sin efecto [M]
- [ ] Caso 9: adelantar reloj SO (+1 mes) sin efecto [M]
- [ ] Caso 10: 7 días reales de ausencia → congelado [S]
- [ ] Tests en `caso_reloj_tests.gd` (M112) [M]
- [ ] Escenario `caso_reloj.tscn` creado para el test [M]
- [ ] Criterio de éxito definido por caso [S]
- [ ] Sin dependencia de hora real en asserts [S]

## F. Persistencia y configuración (10)

- [ ] GameState.M29 único dueño del tiempo [S]
- [ ] w_reloj.tres: formato hora, posición, colores [S]
- [ ] Formato 12h/24h desde Ajustes (M46) [S]
- [ ] Sin duplicar estado temporal en M30 [S]
- [ ] Carga: leer GameState al entrar a la escena [S]
- [ ] Guardado: no guarda nada propio (solo M29) [S]
- [ ] Versionado de data si cambia formato (M59) [S]
- [ ] Nombres localizables por clave (M57) [S]
- [ ] Fallback de datos si .tres corrupto → valores por defecto [M]
- [ ] Sin lectura de hora OS en ningún .tres [S]

## G. Integración y dependencias (12)

- [ ] Depende solo de M29 (GameClock) [S]
- [ ] Consumidores que lo referencian: M74, M28, M36 [S]
- [ ] Se integra al HUD principal (M53) [S]
- [ ] No depende de M08 voxel [S]
- [ ] No depende de M11 jugador [S]
- [ ] No requiere física [S]
- [ ] Sin assets nuevos (solo íconos de M46/M45) [S]
- [ ] Compatible con pausa de menú (M29 pausa el clock) [S]
- [ ] Compatible con dormir (avanzar_hasta 06:00) [S]
- [ ] EventBus time usado de M07 [S]
- [ ] Servicio registrado en project.godot por M07 [S]
- [ ] No rompe guardados de versiones previas [S]

## H. Delegación y cierre (12)

- [ ] Necesidad del módulo justificada (display + política) [S]
- [ ] Alternativas evaluadas y descartadas (3) [S]
- [ ] API estable para consumidores [S]
- [ ] Implementación → AGENTE DELEGADO (dueño explícito) [S]
- [ ] Estático anti-reloj-SO propuesto para M111 [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente incluidas) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]
- [ ] Log de creación generado [S]
- [ ] Checked en README de DOCUMENTACION [S]

**Totales:** 104 ítems · Diseño (A,B,C,H): cerrado por Deepseek V4 Flash · Bloque D (widget): **10/14 completados, 1 `[?]`, 3 pendientes** · E/F/G: runtime parcial, dependen de M46/M53/M57/M64.
**Nota:** los ítems de implementación (D-F en runtime) quedan para el agente delegado; diseño y decisión anti-tiempo-real cierran aquí.

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