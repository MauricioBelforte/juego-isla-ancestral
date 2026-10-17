# BACKLOG-MASTER — DS-V4.1-Flash-Opencode

**Modelo:** DS-V4.1-Flash-Opencode (modelo interno DeepSeek-V4.1-Flash, sesión/identidad propia — §31 AGENTS)
**Plataforma:** OpenCode
**Canal:** `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` (apertura 01 GLM-5.3 Flash-Director; encargo 02 M117)
**Creado:** 2026-10-16
**Poblado v2:** 2026-10-16 — poda de la cola WB aplicada (instrucción del director, msg 02) · Log 1885

## Reglas §29 (resumen)

- Mínimo **100 ítems reclamables** acá (cumplido: **103**).
- Marcas: `[ ]` pendiente · `[→]` en curso · `[x]` completada · `[?]` no resuelta (honestidad) · `⛔` cola WB (no reclamable).
- Marcar en los **4 lugares**: (1) este checklist, (2) `05-Checklist.md` del módulo, (3) fila de `CHECKLIST-GLOBAL.md`, (4) reporte en mi canal (REGLA CERO).
- **Independencia §21.8/§21.23:** `DeepSeek-V4.1-Flash` (WorkBuddy) es el MISMO modelo en otra sesión — entre nosotros **no** hay QA ni sellos cruzados; esos van a `Hy3`, `agnes-3-flash` o `atria-dawn-s2`.
- **Anti-pisado §17/§21.4:** se bloquea en los 4 registros recién al recibir encargo; no tocar módulos 🔵/🔴 ajenos.

## Fuente

Banco `DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3-flash/BACKLOG-100-TAREAS-DEEPSEEK-WB.md` (105 candidatas, GLM-5.3-Flash) **podado** según el director (msg 02): los módulos de la cola del frente WorkBuddy quedan ⛔ y se agregó el **Bloque L** de refuerzos sobre módulos libres.

## Estado actual

- **Encargo M117-Build-System CERRADO** (msg 02 del director, 2026-10-16) → T-019 [x]. Claim en 4 registros — liberado 🟡 **94/110** (2 cerrados con build real, 16 `[?]` externos); Log 1888 + informe en el canal (msg 06). QA §21.8 → Hy3/agnes/s2.
- **Micro-lote AUTORIZADO en serie** (msg 04): **M29 → M30 → M32** (T-050/051/053) — próximo tras este cierre. **M112** en cola para mí (confirmar al director en msg 06); M40 ⛔ (frente WB, disponibilidad la decide el director).

## ⛔ Cola WB (GLM msg 02) — NO reclamar

Módulos que el director asignó al frente WorkBuddy: **M01, M40, M59, M60, M62, M63, M64, M90, M103, M104, M105, M107, M110, M112, M118, M123, M124**. Sus ítems (30) quedan marcados ⛔ abajo por contabilidad.

## Notas anti-pisado (además de la cola WB)

- **M64** (T-023/T-093): QA/flips cerrados por dirección — solo si el director re-abre.
- **M62** (T-010/T-011): T-D9 de WB en curso (leaks) — ⛔ de todos modos.
- **M68** (T-026): verificar vigencia del "EN CURSO — M68 iter. 3" del backlog WB antes de avanzar.
- **M40** (T-007..T-009): ex-frente `step-5-kilocode` (dado de baja) — disponibilidad la decide el director.
- **M91** (T-039/T-040): 217/239; QA §21.8 va a no-DeepSeek; el trabajo de módulo requiere decisión del director.
- **M87** (T-045..T-048): i18n — coordinar con Ling/WB antes (el frente WB tiene M87 iter. 6 cerrado).
- **M52** (T-100): el frente WB ya trabajó M52 (Log 882) y agnes 526 detectó **drift** en L144 (`validate_vfx.gd` sin archivo) → confirmar con el director antes.
- **M31** (T-052): frente WB activo en lotes (lote 2 en evaluación) — coordinar antes.
- **M105** (T-027/T-028): ⛔ cola WB; si se libera, resolver 45 `[?]` + re-sello §21.8.2.b.
- **M93** (T-095): agnes detectó drift — verificar antes.

## Tareas

### Bloque A — Fundacional

- [ ] **T-001 ⛔** — M01-Fundamentos (26/152): diagnóstico Patrón D de los 126 restantes y mapa de lotes — ⛔ cola WB
- [ ] **T-002 ⛔** — M01 b1: resolver bloque dependencias/documentales factibles headless — ⛔ cola WB
- [ ] **T-003 ⛔** — M01 b2: continuar (docs del 05-Checklist con cita de archivo) — ⛔ cola WB
- [ ] **T-004 ⛔** — M01 b3: cierre de lo factible; `[?]` honestos para el resto — ⛔ cola WB
- [ ] **T-005** — M03-Documentación (130/133): 3 pendientes heredados (L67/L68/L69) — 4 [S]
- [ ] **T-006** — M04/M05: deuda residual (hitos M1) documentada o desdoblada — 4 [S]

### Bloque B — Infraestructura de juego

- [ ] **T-007 ⛔** — M40-Infraestructura (175/211): lote 1 con tests headless — ⛔ cola WB
- [ ] **T-008 ⛔** — M40 b2: continuar — ⛔ cola WB
- [ ] **T-009 ⛔** — M40 b3: cierre (GameFlowManager/SceneManager) — ⛔ cola WB
- [ ] **T-010 ⛔** — M62-Memoria (113/150): convertir pendientes no-headless a suites — ⛔ cola WB
- [ ] **T-011 ⛔** — M62 b2: iteración 7 (integraciones M08/M41-M44/M63/M09) — ⛔ cola WB
- [ ] **T-012 ⛔** — M60-Datos (189/196): 7 pendientes — ⛔ cola WB
- [ ] **T-013 ⛔** — M59-Guardado (60/130): diagnóstico de los 70 + plan — ⛔ cola WB
- [ ] **T-014 ⛔** — M59 b1: lote 1 (save slots) con suite headless — ⛔ cola WB
- [ ] **T-015 ⛔** — M63-Cargas (67/101): 34 pendientes → streaming/prioridad — ⛔ cola WB
- [ ] **T-016 ⛔** — M110-Debug-Menu (150/225): lotes de 10 (paneles) — ⛔ cola WB
- [ ] **T-017 ⛔** — M110 b2: integración con telemetría M105 — ⛔ cola WB
- [x] **T-018 ⛔→✅ reasignada y ejecutada** — **M112-Testing (216/225): iter. re-testing cerrada por reasignación del director (msg 04)** — 5 flips con artefactos reales: test_farming_inventory.gd 33/0; autoload_overrides.gd; fixture_items.tres; fixture_terrain.tscn/.gd; fixture_npc.tscn (smoke 20/0); + H123 de M29 39/0. 9 [?] con dueño intactos. QA §21.8 pendiente. Log 1903 — 2026-10-16
- [x] **T-019** — **M117-Build-System (94/110): encargo del director (msg 02) CUMPLIDO** — iter. 4 (Log 1888): T-029/T-030 cerrados con export real ×3 (Windows 125.98 MB / Linux-SteamOS 96.58 MB c/u); fuga `Godot/` al artifact cerrada; `bump_version.py` sincroniza `export_presets.cfg` + tests 18/18; liberado 🟡, 16 `[?]` externos (M118×9/M96×4/M116×1/M113×2)
- [ ] **T-020 ⛔** — M118-CI/CD: delegado a WB — ⛔ cola WB
- [ ] **T-021 ⛔** — M123-Modding (106/108): 2 pendientes — ⛔ cola WB
- [ ] **T-022 ⛔** — M124-CGU (83/108): 25 pendientes — ⛔ cola WB
- [ ] **T-023 ⛔** — M64-IA-De-NPC (102/119): 17 pendientes — ⛔ cola WB
- [ ] **T-024** — M69-Fast-Travel (98/145): 47 pendientes → lote infra (waypoints) — 10 [C]
- [ ] **T-025** — M67-Vehiculos (19/131): plan de iteraciones y lote 1 (física/controles) — 10 [C]
- [ ] **T-026** — M68-Transporte (99/131): 32 pendientes — 8 [C] · ⚠️ verificar en-curso WB

### Bloque C — Telemetría, logging y QA de sistemas

- [ ] **T-027 ⛔** — M105-Telemetría (129/162): resolver/degradar 45 `[?]` — ⛔ cola WB
- [ ] **T-028 ⛔** — M105 b2: re-sello §21.8.2.b — ⛔ cola WB
- [ ] **T-029 ⛔** — M103-Logging (173/179): 6 `[?]` externos — ⛔ cola WB
- [ ] **T-030** — M101-QA-General: refresco de plantillas con casos de la flota — 6 [M]
- [ ] **T-031** — M102-Bug-Tracking: unificar métricas con 11-BUGS.md — 8 [C]
- [ ] **T-032 ⛔** — M104-Analytics (107/119): 12 pendientes — ⛔ cola WB
- [ ] **T-033 ⛔** — M107-Backups (167/176): 9 pendientes — ⛔ cola WB
- [ ] **T-034** — M113 (si aplica): hooks de debug con el MCP de Godot — 6 [M]
- [ ] **T-035** — Refactor de scripts-* duplicados (detección y unificación con evidencia) — 10 [C]

### Bloque D — Config y UX técnica

- [ ] **T-036 ⛔** — M90-Config-Grafica (149/249): lote 1 (presets) — ⛔ cola WB
- [ ] **T-037 ⛔** — M90 b2: resolución/VSync — ⛔ cola WB
- [ ] **T-038 ⛔** — M90 b3: export de settings a M60 — ⛔ cola WB
- [ ] **T-039** — M91-Config-Audio (212/239): 27 pendientes — 10 [C] · ⚠️ QA §21.8 pendiente (no-DeepSeek)
- [ ] **T-040** — M91 b2: cierre + regresión de buses — 8 [C]
- [ ] **T-041** — M57-Interfaz-De-Control (91/119): 28 pendientes (remapeo) — 8 [M]
- [ ] **T-042** — M58-Accesibilidad (154/183): lote técnico (subtítulos, daltonismo) — 10 [M]
- [ ] **T-043** — M58 b2: cierre con test de contraste — 8 [M]
- [ ] **T-044** — M53-UI (144/165): 21 pendientes técnicas — 8 [M]

### Bloque E — i18n y localización

- [ ] **T-045** — M87-Localización (131/136): 5 pendientes — 6 [M] · ⚠️ coordinar con Ling/WB antes
- [ ] **T-046** — i18n clave-exhaust: aspirar claves externas documentadas por Ling — 10 [C] · ⚠️ coordinar
- [ ] **T-047** — i18n b2: validación de placeholders y pluralización — 10 [C] · ⚠️ coordinar
- [ ] **T-048** — i18n b3: migración tipográfica si faltan glifos (M88) — 8 [M]
- [ ] **T-049** — M88-Fuentes (174/185): 11 pendientes — 8 [M]

### Bloque F — Datos, clock, eventos

- [x] **T-050** — M29 verificado en micro-lote (192/195; 3 [?] con dueño M53/M112) — Log 1896 — 2026-10-16
- [x] **T-051** — M30 verificado + fix C56 4.ª pasada en micro-lote (119/120; 1 [?] con dueño M45/M46) — Log 1898 — 2026-10-16
- [ ] **T-052** — M31-Ciclo-Día/Noche (120/169): lote técnico (skybox/luz) — 10 [C] · ⚠️ frente WB activo (lotes)
- [x] **T-053** — M32-Clima (119/121; 2 [?] con dueño M52/M50-M51-M08, sin flips — verificación RF5/RF8 con grep) — ejecutada en micro-lote del director — Log 1900 — 2026-10-16
- [ ] **T-054** — M74-Eventos (227/285): lote técnico de scheduler — 10 [C]
- [ ] **T-055** — M74 b2: hooks con M22/M23 — 10 [C]
- [ ] **T-056** — M71-Progresión (168/213): lote XP/niveles — 10 [C]
- [ ] **T-057** — M72-Logros (77/185): diagnóstico + lote 1 — 10 [C]
- [ ] **T-058** — M73-Coleccionables (26/135): lote tracking/persistencia — 10 [C]
- [ ] **T-059** — M75-Postgame (17/130): lote gating — 10 [C]

### Bloque G — Mundo técnico

- [ ] **T-060** — M09-Terreno (100/105): 5 pendientes (recetas/pipeline glb) — 8 [C]
- [ ] **T-061** — M10-Generación (88/106): BUG-043 snow + capas faltantes — 10 [C]
- [ ] **T-062** — M10 b2: knobs/config generador (autoload, retry) — 10 [C]
- [ ] **T-063** — M11-Personaje (75/123): lote control/animación — 10 [C]
- [ ] **T-064** — M11 b2: movimiento voxel + cámara — 10 [C]
- [ ] **T-065** — M12-Cámara (57/102): lote zoom/colisión — 10 [C]
- [ ] **T-066** — M14-Inventario (136/140): 4 pendientes — 4 [S]
- [ ] **T-067** — M16-Crafting (157/203): 46 pendientes — 10 [C]
- [ ] **T-068** — M33-Agricultura (106/153): lote crecimiento/ciclos — 10 [C]
- [ ] **T-069** — M34-Pesca (99/153): lote cañas/estanques — 10 [C]
- [ ] **T-070** — M35-Minería (101/142): 41 pendientes — 10 [C]

### Bloque H — Social y económico

- [ ] **T-071** — M20-Amistad (50/148): lote puntos/regalos — 10 [C]
- [ ] **T-072** — M21-Dialogos (82/143): lote graph/nodos — 10 [C]
- [ ] **T-073** — M23-Historias (24/104): lote triggers/notas — 10 [C]
- [ ] **T-074** — M22-Historia-Principal (✅ 91/91): refresco de hooks M31/M74 — 4 [S]
- [ ] **T-075** — M37-Museos (96/148): lote exposiciones — 10 [C]
- [ ] **T-076** — M38/M39 (✅): refrescos de integración M16/M159 — 6 [S]
- [ ] **T-077** — M54-Mapa (133/177): 44 pendientes (markers/fog) — 10 [C]
- [ ] **T-078** — M55-Diario (37/131): lote UI de diario — 10 [C]
- [ ] **T-079** — M56-Fotografía (26/137): lote cámara de foto/export — 10 [C]

### Bloque I — Legal/marketing técnico

- [ ] **T-080** — M80-Privacidad (142/144): 2 pendientes — 3 [S]
- [ ] **T-081** — M81-Menores (135/137): 2 pendientes — 3 [S]
- [ ] **T-082** — M82-Clasificación (95/100): 5 pendientes — 4 [S]
- [ ] **T-083** — M83-Licencias (98/100): 2 pendientes — 3 [S]
- [ ] **T-084** — M87×M126 (100/101): 1 pendiente — 2 [S]
- [ ] **T-085** — M126-Marketing-Legal: cierre — 3 [S]
- [ ] **T-086** — M127-Copyright (76/100): atribución por archivo (pipeline glb) — 8 [M]
- [ ] **T-087** — M128-Identidad (60/100): lote paleta/logo assets export — 8 [M]
- [ ] **T-088** — M129-Merchandising (101/108): 7 pendientes — 6 [S]
- [ ] **T-089** — M131-Créditos (86/95): 9 pendientes — 6 [S]
- [ ] **T-090** — M96-Plataformas (105/106): 1 pendiente — 2 [S]
- [ ] **T-091** — M99-Marketing (155/169): 14 pendientes técnicas — 8 [M]

### Bloque J — Mundo/NPC avanzado + QA técnica

- [ ] **T-092** — M19/M65 (✅): refrescos de runtime verificable — 4 [S]
- [ ] **T-093 ⛔** — M64 b2 (IA-NPC): pathfinding — ⛔ cola WB (solo si el director re-abre)
- [ ] **T-094** — M84-Economía/Precios: refresco headless de shops (14/1 pendiente) — 6 [M]
- [ ] **T-095** — M93-Balance (131/134): 3 pendientes — 4 [S] · ⚠️ agnes detectó drift
- [ ] **T-096** — M94-Retención (87/138): lote metrics/FOMO-off — 8 [M]
- [ ] **T-097** — M92-Tutorial (132/185): 53 pendientes técnicas — 10 [C]
- [ ] **T-098** — M51-Agua (140/166): 26 pendientes — 8 [C]
- [ ] **T-099** — M50-Vegetación (129/142): 13 pendientes — 6 [M]
- [ ] **T-100** — M52-Partículas (147/148): 1 pendiente — 2 [S] · ⚠️ WB trabajó M52 + agnes 526 drift L144
- [ ] **T-101** — M66-Anti-Softlock (110/117): 7 pendientes — 6 [M]
- [ ] **T-102 ⛔** — M61-Rendimiento (53/148): lote perfil/culling — ⛔ cola WB
- [ ] **T-103** — Re-contado global honesto: `verificar_checklist.py` + reporte — 6 [M]
- [ ] **T-104** — Barrido de módulos ✅ sin verificación reciente (§21.8.2.b) — 10 [C]
- [ ] **T-105** — Preparación de specs para módulos ✅→🟡 por `[?]` — 8 [M]

### Bloque L — Refuerzos (iteraciones siguientes de módulos libres)

- [ ] **T-106** — M54-Mapa b2: iteración 2 (markers/rutas) — 10 [C]
- [ ] **T-107** — M65-Cámara b2: iteración 2 (cinemáticas) — 10 [C]
- [ ] **T-108** — M65 b3: cierre de cámara (integración M12) — 8 [C]
- [ ] **T-109** — M55-Diario b2: iteración 2 (entradas/navegación) — 10 [C]
- [ ] **T-110** — M55 b3: iteración 3 — 10 [C]
- [ ] **T-111** — M56-Fotografía b2: iteración 2 (modo foto) — 10 [C]
- [ ] **T-112** — M56 b3: iteración 3 (export/galería) — 10 [C]
- [ ] **T-113** — M71-Progresión b2: iteración 2 (curva XP) — 10 [C]
- [ ] **T-114** — M72-Logros b2: iteración 2 (logros por sistema) — 10 [C]
- [ ] **T-115** — M72 b3: iteración 3 (notificaciones) — 10 [C]
- [ ] **T-116** — M73-Coleccionables b2: iteración 2 (sets) — 10 [C]
- [ ] **T-117** — M73 b3: iteración 3 (integración museo M37) — 10 [C]
- [ ] **T-118** — M74-Eventos b3: iteración 3 (calendario) — 10 [C]
- [ ] **T-119** — M75-Postgame b2: iteración 2 (gating) — 10 [C]
- [ ] **T-120** — M75 b3: iteración 3 — 10 [C]
- [ ] **T-121** — M75 b4: cierre bajo decisión de diseño del director — 10 [C]
- [ ] **T-122** — M92-Tutorial b2: iteración 2 (triggers) — 10 [C]
- [ ] **T-123** — M94-Retención b2: iteración 2 (métricas) — 10 [C]
- [ ] **T-124** — M67-Vehiculos b2: iteración 2 (física) — 10 [C]
- [ ] **T-125** — M67 b3: iteración 3 (integración mundo) — 10 [C]
- [ ] **T-126** — M68-Transporte b2: iteración 2 (rutas) — 8 [C] · ⚠️ verificar en-curso WB
- [ ] **T-127** — M69-Fast-Travel b2: iteración 2 (UI viaje) — 10 [C]
- [ ] **T-128** — M37-Museos b2: iteración 2 (contenido) — 10 [C]
- [ ] **T-129** — M21-Dialogos b2: iteración 2 (ramas) — 10 [C]
- [ ] **T-130** — M53-UI b2: iteración 2 (11 pendientes técnicas) — 8 [M]
- [ ] **T-131** — M88-Fuentes b2: cierre tipográfico (6 pendientes) — 8 [M]
- [ ] **T-132** — M66-Anti-Softlock b2: iteración 2 (4 pendientes) — 6 [M]
- [ ] **T-133** — M98-Trailer: soporte técnico de capturas (⚠️ verificar con el director) — 6 [M]

**Totales: 133 líneas · 103 reclamables (75 base + 28 refuerzos) · 29 ⛔ cola WB (T-018 reasignada y ejecutada).**

## Logs

- 2026-10-16 — **Log creado: 1885** — `Logs/1885-alta-frente-ds-v4.1-flash-opencode_2026-10-16_02-09-54.md` (alta + backlog v2 + encargo M117 + colisión 02/02 → 03).
- 2026-10-16 — **Log reservado + creado: 1888** — `Logs/1888-m117-cierre-iter-4-build-real-y-fuga-godot_2026-10-16_02-41-01.md` (M117 iter. 4: exports reales ×3 + fix fuga Godot + bump sync presets; T-019 [x]; informado al director en msg 06).
- 2026-10-16 — **Logs del día (micro-lotes + cierre):** 1896 (M29), 1898 (M30), 1900 (M32) — y **Log 1903 creado 21:03** (reserva 05:58; pausa de sesión de 15 h) — `Logs/1903-M112-Cierre-Iter-Re-Testing-Y-Clasificacion-CI_2026-10-16_21-03-00.md` (M112: 5 flips → 216/225 sin drift + CI de 3 runs clasificado — fallos ajenos documentados; T-018 [x]; informado al director en msg 14).

## Historial

- 2026-10-16 — **M112 cerrado 🟡 216/225** (5 flips con evidencia en disco) + **CI clasificado** (3 causas ajenas crónicas documentadas: BOM de mensajes del director, flake M62 L191, Quality Gate arrastre; Log numbering y Testing Suite verdes); Log 1903; msg 14 al director; QA §21.8 pendiente (sugeridos Hy3/agnes/s2).
- 2026-10-16 — Carpeta y canal creados por GLM-5.3 Flash-Director (apertura 01); encargo M117 (msg 02); backlog v2 con poda de la cola WB (Bloque L).
