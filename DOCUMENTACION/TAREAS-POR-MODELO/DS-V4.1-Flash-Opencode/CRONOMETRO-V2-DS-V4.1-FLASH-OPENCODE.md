# CRONÓMETRO V2 — DS-V4.1-Flash-Opencode — estado: ACTIVO

**Modelo:** DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
**Plataforma:** OpenCode
**Fecha:** 2026-10-17 04:18
**Fuente:** directiva del fundador 2026-10-17 (nueva metodología V2): *"activa el cronometro cada 5 minutos, primero lees el mensaje del director y haces lo que te pide; si no hay mensajes vas a tu backlog master a buscar tareas para hacer, elegís una y se lo reportás al director cuando la termines."*

## Estado actual

- **ACTIVO** desde 2026-10-17 04:18 (esta sesión OpenCode). Cadencia: **cada 5 minutos** (cada vuelta/turno de sesión).
- Sin mensajes del director pendientes al activar (canal procesado completo hasta 038).
- Marcador de posición: `Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt` = 38 (número más alto del canal ya procesado).

## El ciclo V2 (3 pasos EN ORDEN — nunca cortar)

1. **EL DIRECTOR PRIMERO (primera instancia, SIEMPRE):** leer `.ultima-revision-ds.txt` → ojear el canal `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` por archivos `NN` > marcador dirigidos a mí (`*a-ds-v4.1-flash-opencode*`). Si hay mensaje del director: leerlo COMPLETO, ejecutar lo que pide, responder con mensaje propio (numeración último + 1, borrar SOLO ese número del pool) y actualizar el marcador. Regla T-19: si el mensaje aparece con la plantilla vacía, esperar 5 minutos y releer.
2. **SIN MENSAJES → BACKLOG:** ir a `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md`, sección **(A) COLA ACTIVA** → elegir la próxima tarea `[ ]` según mi nicho (CI/build/testing/economía/verificación con evidencia) → trabajar la tanda (leer `plan-actual/` del módulo, verificar contra disco, correr suites headless).
3. **CIERRE DE TANDA — REPORTE AL DIRECTOR (REGLA CERO):** al terminar: (a) informe en mi canal (mensaje nuevo, numeración último + 1 del pool, con evidencia: archivos/rutas/tests); (b) marcas `[x]` honestas en el BACKLOG-MASTER (solo con evidencia real, jamás "por hacer"); (c) Log en `Logs/` (número del pool global) cuando la tanda lo amerite; (d) actualizar el marcador. El director actualiza la fila de `CHECKLIST-GLOBAL.md` y responde.

**Regla de oro:** si no hay mensajes, SIEMPRE hay backlog — JAMÁS quedarse sin producir ni reportar "sin mensajes" en vacío.

## El prompt del cronómetro (copiar/pegar para reactivar en otra sesión)

```text
[CICLO-5min DS-Opencode]
(1) Leer Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt (número más alto procesado).
(2) Ojear el canal por mensajes NN > marcador dirigidos a mí (*a-ds-v4.1-flash-opencode*). Si hay:
    leerlo completo, ejecutar lo que pide el director, responder con mensaje propio (último + 1,
    borrar SOLO ese número del pool) y actualizar el marcador. T-19: plantilla vacía → esperar 5 min y releer.
(3) Si NO hay mensajes: ir al BACKLOG-MASTER (DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/
    BACKLOG-MASTER.md), sección (A) COLA ACTIVA, elegir UNA tarea [ ] de mi nicho y trabajarla con
    evidencia (disco + suites headless).
(4) Cierre: reporte al director en mi canal (REGLA CERO) + marcas [x] honestas en el backlog + Log si
    amerita; actualizar marcador. El director actualiza la fila de CHECKLIST-GLOBAL.md y responde.
(5) No quedarme nunca sin producir. Si no hay mensajes del director, SIEMPRE hay backlog.
Reglas fijas: UTF-8 §28 · firma DS-V4.1-Flash-Opencode/OpenCode · NO commits ni push (los maneja el
director) · no editar backlog/canales/checklists de otros modelos · independencia QA §21.8/§21.23 · no
auto-sellos (los flips los aplica el director) · no trabajar módulos 🔵 ajenos · quality.yml solo con
autorización del fundador.
```

## Notas de plataforma (OpenCode)

- El cronómetro **no es un proceso de fondo** en OpenCode: cada vuelta se ejecuta en un turno de sesión (el fundador/lanzador dispara la vuelta cada ~5 min). El estado persistente es: este archivo + `.ultima-revision-ds.txt` + `BACKLOG-MASTER.md`.
- Identidad por **carpeta/canal**: `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` — si un `IDENTITY.md` compartido dice otra cosa, gana la carpeta (AGENTS.md §7).

## Archivos clave

| Archivo | Rol |
|---|---|
| `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` | Mi canal (director ↔ yo) |
| `Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt` | Marcador (número más alto procesado) |
| `Mensajes entre modelos/DS-V4.1-Flash-Opencode/NUMEROS_DISPONIBLES.txt` | Pool de números de mensajes (gitignoreado) |
| `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md` | Mi backlog unificado V2 — (A) COLA ACTIVA |
| `Logs/NUMEROS_DISPONIBLES.txt` | Pool global de números de log |
| `CHECKLIST-GLOBAL.md` | Tablero de módulos (lo actualiza el director) |

## Registro de vueltas

| Vuelta | Fecha/hora | Director | Producción | Resultado |
|---|---|---|---|---|
| 1 | 2026-10-17 04:18 | sin mensajes nuevos (>38; canal hasta 038) | Activación del cronómetro V2 + primera tarea V2: M15 catálogo de recursos (ítem 18 de la cola) | ✅ T9 cerrada: M15 (6+6 defs, 51 checks/0 fallos, out/tanda9/); ítems 18+64 [x]; Log 1920 |

**Firma:** DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash) / OpenCode — 2026-10-17.

| 2 | 04:29 | **Director 039** (acuse T7-8 + decisiones: BUG-031 rojo a propósito; fix pergaminos AUTORIZADO; QA M62 nunca mío) | Fix BUG-136 (T10: rc=0, 7/7; out/tanda10/) + BUG-136 Resuelto en 11-BUGS + reporte msg 040 + Log 1921 | ✅ |
| 3 | 04:49 | Director 041 (acuse vuelta 2: su premisa "14" corregida por mi medición 12; pool 41-150) — respondido en 042 | M40 — los 5 servicios core verificados (ítem 22): boot runtime 5/5 exactos + 5 suites rc=0 (96 checks, 0 fallos) — out/tanda11 | OK |
| 4 | 04:52 | sin mensajes nuevos (>042) | M62 budget_registry verificado (ítem 19): media 2000 MB (baja 1500/alta 2500) + 2 suites rc=0 (160 checks, 0 fallos) — out/tanda12 (Log 1923) | OK |
| 5 | 04:55 | sin mensajes nuevos (>043) | M62 texture_memory verificado (ítem 20): iter5 rc=0 (60 checks, bloque F atlas-con-log) + iter3 bloque I (133 checks) — out/tanda13 (Log 1924) | OK |
| 6 | 04:59 | sin mensajes nuevos (>044) | M62 global_pool: shadowing conversions L67/110/176 (limite→tope) ítem 21 verificado — pool_iter2 25/0 + enforcement 47/0 + base 27/0 rc=0 — out/tanda14 (Log 1925) | OK |
| 7 | 05:04 | acuse 046 (vueltas 3-6: M40/M62 OK; shadowing aceptado; frags reconocidos) | M106 4 políticas verificadas ítem 23 — 8 suites rc=0, 237 checks 0 fallos — out/tanda15 (Log 1926, msg 047) | OK |
| 8 | 05:06 | sin mensajes nuevos (>047) | M122 session id creación única ítem 24 — crash_reporter.gd L22 único sitio; suites rc=0 13/0+168/0 (181 checks); ids distintos en 2 corridas — out/tanda16 (Log 1927) | OK |
| 9 | 05:09 | sin mensajes nuevos (>048) | M48 FSM 11 estados ítem 25 — enum player_fsm L25-37 (11) + boot M48; suites rc=0 87/0+12/0+8/0 (107 checks) — out/tanda17 (Log 1928) | OK |
| 10 | 05:20 | sin mensajes nuevos (>049) | M32 2[?] revisadas (ítem 26): greps negativos frescos + 3 suites rc=0 (29/0+20/0+0 fallos); [?] legítimos → pedido ruteo RF8. INCIDENCIA: BACKLOG truncado por bug de script de cierre y RESTAURADO (HEAD+marcas T9-T18, diff exacto 17 líneas) — out/tanda18 (Log 1929, msg 050) | OK |
| 11 | 05:41 | Director 052 (política blanket de dups AUTORIZADA con 3 condiciones; BOM de punteros normalizado) | Tanda 19: ítem 27 farm front verificado (montado + 3 suites; m33_lote 41/2 fallos: advance_day 407-434 ms → dato M61; tiles 400 vs 395 residuo del test) + nota RF8 diferido en M32 05 | OK msg 053 / Log 1930 |
| 12 | 16:12 | Director 054 (vuelta 11 aceptada; deudas M33 formalizadas; seguir M67/M75) | Tanda 20: ítem 28 M67-VehicleManager 3 presets verificados (vehicles.json + boot 182 logs + test_vehiculos 40/0 rc0) | OK msg 055 / Log 1931 |
| 13 | 16:19 | sin mensajes nuevos (>055, beat 16:17) | Tanda 21: ítem 29 M75-Postgame 7 actividades verificadas (actividades.json + boot 183 logs + test_postgame 40/0 rc0). Concurrencia: log 1932 tomado por DeepSeek-WB → salí con 1933 | OK msg 056 / Log 1933 |
| 14 | 16:26 | Director 057 (acuse 12-13 OK; orden: ítem 30 adelante) | Tanda 22: ítem 30 M94-Motivación 7 objetivos verificados (objetivos.json + boot 184 logs + test_motivacion_m94 38/0 rc0) | OK msg 058 / Log 1935 |
| 15 | 17:23 | Director 059 (acuse v14 OK; orden: ítem 31 adelante) | Tanda 23: ítem 31 M73-Coleccionables verificado (catalog.json 15 items/4 categorías + boot 185 logs + test_coleccionables rc0) | OK msg 60 / Log 1938 |
| 16 | 17:33 | (sin mensajes nuevos — cola propia) | Tanda 24: ítem 32 M46-Arte-2D 13 flips Lote 1 verificados (91/110 [x], evidencia ART_STYLE_2D §1-4 real, READ-ONLY sobre 🔵 de agnes) | OK msg 61 / Log 1939 |
| 17 | 18:56 | Director 062/063 (consulta padding auto-resuelta + acuse vueltas 15-16 OK; orden: vuelta 17) | Tanda 25: ítem 33 M36-Fauna — 7 especies verificadas (catalog.json 7 entradas + boot en 186 logs + test_fauna 58/0 rc=0; out/tanda25) | OK |
| 18 | 19:29 | Director 065 (acuse vuelta 17 OK; orden: vuelta 18) | Tanda 26: íten 34 M65-Manadas PackLogic/SchoolLogic verificadas (scripts + boot x6 out/ incl. CI + test_m65 0 fallo/s 30 OK; cap presupuesto = WARNING esperado; out/tanda26) | OK |
| 19 | 20:01 | sin mensajes nuevos (beat 30min; solo mi 66) | Tanda 27: ítem 35 M36-SPAWNER verificado EN VIVO (mount main_island.tscn + constantes 24/3/15s + boot rc=0 12 individuos en 3 zonas pradera/playa/humedal; out/tanda27) | OK |
| 20 | 20:33 | Director 067 (acuse vuelta 19 OK; orden: vuelta 20) | Tanda 28: ítem 36 M115-HardwareManager 3 perfiles verificados (JSON 624b baja/media/alta + boot x189 + test_hardware_m115 17/0 rc=0; out/tanda28) | OK |
| 21 | 21:07 | Director 070 (acuse vuelta 20 OK; orden: vuelta 21) | Tanda 29: ítem 37 M158-ToolTierSystem verificado (JSON 4 tiers/6 gates/4 forjas/4 cursos + boot x189 + test_tiers 0 fallos rc=0 con forjados T1-T4; out/tanda29) | OK |
| 22 | 21:39 | Director 073 (acuse vuelta 21 OK; orden: vuelta 22 M160) | Tanda 30: ítem 38 M160-Ubicaciones verificado (39 catálogo / 48 ubicaciones / 10 conexiones en boot x287 + test_ubicaciones_m160 17/0 rc=0; out/tanda30) | OK |
| 23 | 22:12 | Director 074 (acuse vuelta 21 OK; specs 149/150 en cola) | Tanda 31: ítem 39 = M148-Lore-Ambiental verificado (60 piezas/4 islas, LoreGate 16 pistas, test_lore_m148 85 checks 0 fallos rc=0; out/tanda31) | OK |
| 24 | 22:43 | Director 075 (acuse vuelta 23 OK; orden: vuelta 24) | Tanda 32: ítem 40 M127-M52 verificados sin drift (13/0 + 76/0 rc=0; boot copyright_register + VfxDirector 30 eventos; out/tanda32) | OK |
| 25 | 23:15 | Director 078 (acuse vuelta 24 OK; orden: vuelta 25) | Tanda 33: ítem 41 M129-Merch verificado (merchandising.json v2 = 10 productos + boot x289 + test_merch_m129 24/0 rc=0; out/tanda33) | OK |
| 26 | 23:48 | Director 081 (acuse vuelta 25 OK; orden: vuelta 26) | Tanda 34: ítem 42 M147-WorldBible canon 1.0.0 verificado (6 personajes/8 lugares, boot x291, test_world_m147 23/0 rc=0; ES/EN ok, PT ausente observado; out/tanda34) | OK |
| 27 | 00:21 | Director 084 (acuse vuelta 26 OK; PT ruteado a Ling; orden: vuelta 27) | Tanda 35: ítem 43 M147 strings 6 personajes (canon 6/6 verificado; i18n por personaje = deuda módulo; out/tanda35) | OK |
| 28 | 01:05 | Director 086 (acuse vuelta 27 OK; orden: vuelta 28 = item 44 vocabulary canon8) | Tanda 36: item 44/90 vocabulary canon8 verificado (4 simbolos + 4 capas = 8/8; 8 lugares 8/8; test_world_m147 23/0 rc=0; boot fresco; deudas: i18n canon ausente en strings_es/en/pt + drift 03-Diseno vs data; Log 1965; msg 88; out/tanda36) | OK |
| 29 | 01:40 | Director 086 (sin mensajes nuevos; cola propia) | Tanda 37: item 45 M100-Community verificado (5 canales + 4 eventos + 4 KPIs; boot [M100] CommunityManager; test_community_m100 8/0 rc=0; modulo 220/0/0; nota steam_forums sin evento; Log 1967; msg 90; out/tanda37) | OK |
| 30 | 02:18 | Director 091 (acuse vuelta 29 OK; orden: vuelta 30 M121) | Tanda 38: item 46 M121-Support verificado (15 FAQ/3 canales/11 categorias/SLA; suites 15/0 + 70/0 rc=0; boot [M121]; modulo 211/0/0; drift menor L14; Log 1969; msg 92; out/tanda38) | OK |
| 31 | 02:28 | Director 091 (sin mensajes nuevos; cola propia) | Tanda 39: item 47 M123-Modding verificado (2 mods + schema/limites + manager/validator/sandbox; suite 69/0 rc=0 11 bloques; boot [M123]; modulo 106/0/2 con deudas previas; Log 1970; msg 93; out/tanda39) | OK |
| 32 | 02:34 | Director 093 (acuse vuelta 30 OK; sin mensajes nuevos; cola propia) | Tanda 40: item 48 M36-SPAWNER verificado (3 grupos/3 zonas = 11 individuos conejo 2/gaviota 4/cangrejo 5 + [M65] PackLogic/SchoolLogic; suite test_fauna 58/0 rc=0; modulo 227/1/0 (anti-stuck M65 abierta); cierra Bloque W; Log 1971; msg 96; out/tanda40) | OK |
| 33 | 02:35 | Director 093 (acuse v30 OK; sin mensajes nuevos; cola propia) | Tanda 41: item 49 M160-Ubicaciones re-verificado (39 catalogo + 48 cargadas + 10 conexiones; suite 17/0 rc=0; modulo 145/2/8 con deudas propias; mismo frente verde que Tanda 30; Log 1973; msg 97; out/tanda41) | OK |
