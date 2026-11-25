# BACKLOG-MASTER — DeepSeek-V4.1-Flash-DeepAI (ÍNDICE)

**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI
**Canal:** `Mensajes entre modelos/DeepSeek-V4.1-Flash-DeepAI/`
**Nicho:** CI/CD/build · economía · testing · cross-verificación de métricas · gate-1
**Origen:** herencia íntegra de `DS-V4.1-Flash-Opencode` (directiva del fundador, 2026-11-25)
**Log de apertura:** `Logs/2443-canal-deepseek-v4-1-flash-deepai-apertura-herencia_2026-11-25_09-45-00.md`

## CICLO

1. **Primera instancia:** leer el último mensaje del canal. Si la directora escribió, responder primero con un mensaje propio (NN = último + 1).
2. **Segunda instancia:** tomar el próximo `[ ]` de la COLA VIVA, por prioridad (CI antes que módulos).
3. **Medir antes de tocar:** el estado heredado es del 2026-11-18; re-medir contra disco.
4. **Cierre:** reporte en el canal + marcas `[x]` en este backlog, en el `05-Checklist.md` del módulo y en `CHECKLIST-GLOBAL.md`.

## COLA VIVA

### Bloque 1 — CI rojo (bloquea el repo, va primero)

| # | Job | Módulo | Estado | Evidencia (2026-11-25) |
|---|---|---|---|---|
| C1 | GDScript Lint/Format | M169 (`crucero_manager` / `eventos.gd`) | [x] | 3 SCRIPT ERROR → 0. `TimeCalendar`/`TransportManager` por `get_node_or_null` (patrón BUG-128/T-108). Colector: 1366 preloads, 0 errores |
| C2 | Architecture Guard | M62 — BUG-069 | [x] | Arista `A1|DataStore,SaveManager` declarada en `PERMITIDOS` con justificación; auditoría exit 0 |
| C3 | Test Suite | M112 | [x] | 3 suites rojas eran aserciones obsoletas (idiomas `es/en/pt` y clave `max_copias_por_categoria`). Re-corrida: **101 suites, 0 fallidas** |
| C4 | Legal Tooling | M127 | [x] | 84 `.glb` sin copyright (techo 418 excedido) + 2 archivos con EOL mixto y cabecera desactualizada. Ahora 0 hallazgos nuevos |

### Bloque 2 — Críticos Nemotron (12) — ✅ cerrado 2026-11-25 10:31

Los 12 ya estaban implementados en el código heredado; esta tanda los **verificó** con archivo:línea
y una suite con conteo real (detalle completo en `02-Backlog-Criticos-12.md` y Log 2448).

1. [x] VfxDirector `_process`/`_exit_tree` — `vfx_director.gd:108/111`; suite 76/0
2. [x] HealthComponent `NaN`/negativo — `health_component.gd:126/138/151/157`; suite 46/0
3. [x] Logging fuga de RAM — `logger.gd:16`; suite 14/0
4. [x] Save pre-validación — `save_manager.gd:159/253`; suite 25/0
5. [x] DLC manager — gate de propiedad; **test `test_dlc_m120` corregido** (19/0)
6. [x] Economía retiro cero + tope — `economy_manager.gd`; 11/0 + 6/0 + 7/0
7. [x] M17 lote 1 circulación + apoyo — `test_m17_circulacion` 36/0
8. [x] M129 stock + numeración — `test_merch_m129` 58/0
9. [x] M129 boot B-17/B-12-06 — `test_merch_boot_m129` 11/0
10. [x] M17 tests — 44/0 + 17/0 (7 suites de `scripts/construccion/`)
11. [x] Regresión M21/M162 — 24 suites de `scripts/dialogos/`, 0 fallidas
12. [x] Verificación global — 18000 frames headless, exit 0, 0 SCRIPT ERROR

### Bloque 3 — Post-críticos (abierto)

- [~] M17: **NO es mío** — reclamado por minimax-m3-1-flash el 2026-11-25 (`ESTADO-PARALELO`,
  tanda P4 almacenamiento + HUD de categorías). Quedan 31 `[ ]` pero pasan a su cola (§21.4).
  Mi trabajo ahí es cross-QA: verificado hoy 33/0 almacenamiento, 40/0 reglas, 23/0
  persistencia, 36/0 circulación, 44/0 validación, 24/0 categorías, 22/0 HUD categorías.
- [x] M129: los "54 ítems" eran el conteo previo al cierre v3 del 2026-11-06; el
  `05-Checklist.md` de M129 hoy tiene **0 pendientes** (1 `[?]` de render 3D, dueño Hy4).

### Bloque 4 — Cola 1-181 (heredada)

- 101 ítems `[x]` (cerrados; ver `01-Backlog-Cola-Activa.md`)
- [x] **102 — BUG-069**: medido y documentado el 2026-11-25 → `BACKLOGS/evidencias/BUG-069-estado-2026-11-25.md`
  (117 autoloads, 254 aristas, 1 SCC `DataStore`↔`SaveManager`, 10 refs A2, 0 hallazgos nuevos).
  Retirada la entrada obsoleta `A1|ThemeService,UIManager` de `PERMITIDOS` → auditor exit 0.
  [ ] queda el mediador de guardado (ruta de perfil, necesita prueba de runtime con 2 perfiles).

## REGISTRO DE TANDAS

### Tanda 2026-11-25 09:45 — apertura del canal

- Canal creado, herencia copiada (270 archivos), backlog vivo, puntero en el canal OC, entrada en `ESTADO-PARALELO`.
- **Log creado: 2443** (`Logs/2443-canal-deepseek-v4-1-flash-deepai-apertura-herencia_2026-11-25_09-45-00.md`).

### Tanda 2026-11-25 09:58 — CI rojo (bloque 1)

- C2 Architecture Guard: declarada la arista `A1|DataStore,SaveManager` (ciclo funcional, ambas direcciones con `get_node_or_null`); refactor a mediador pendiente.
- C4 Legal Tooling: nuevo `tools/legal/inject_glb_copyright.py` (+ autotest) e inyección de `asset.copyright` en los **84 `.glb`** que excedían el techo; `generate_item_attribution.py` y su test normalizados (EOL) y con cabecera canónica (`--apply`). Validadores: 0 hallazgos nuevos, techo 418/418.
- C1 Lint/Format: M169 resuelve sus autoloads por nodo (2 archivos); gate de parseo 0 errores sobre 1366 scripts.
- C3 Test Suite: 3 aserciones caducadas corregidas contra la fuente de verdad (catálogos en
  disco y policy `max_copias_por_categoria`); además se cableó esa clave en `BackupManager`
  (antes era decorativa: se caía en el default 5). 101 suites, 0 fallidas.
- **Log creado: 2445** (`Logs/2445-arreglos-ci-cuatro-jobs-verde_2026-11-25_10-16-00.md`). El
  2444 lo consumió otro agente mientras corría la tanda.
- Reporte al director: mensaje `002` del canal.

### Tanda 2026-11-25 10:31 — 12 críticos Nemotron (bloque 2)

- 12/12 verificados contra disco con evidencia de código + suite. Único cambio de código:
  `test_dlc_m120.gd` estaba desactualizado respecto del gate de propiedad de su propio manager
  (2 fallos de 16 → 19/0).
- Regresión M21/M162: 24 suites, 0 fallidas. Verificación global: 18000 frames headless, exit 0,
  0 SCRIPT ERROR (8 ruidos de RID/renderer propios de `--headless`).
- **Log creado: 2448** (`Logs/2448-verificacion-doce-criticos-nemotron_2026-11-25_10-31-00.md`).
  El 2447 lo consumió otro agente mientras corría la tanda.
- Reporte al director: mensaje `003` del canal.

### Tanda 2026-11-25 11:11 — cobertura del gate

- Medido: **524** suites en disco, **101** en `quality.yml`, **427** fuera. Herramienta nueva
  `tools/quality/auditar_cobertura_suites.py` (report + `--check` de rutas rotas del workflow).
- Barrido de 40 suites de `tests/` fuera de CI: **0 rojas, 0 timeouts** (timeout 120 s por suite).
  El único rojo de la zona, `tests/test_m17_categorias.gd` (24/3), era de M17 y minimax-m3-1-flash
  lo cerró honestamente en la misma hora implementando `filas_categorias` → 24/0 a las 11:10.
  Cross-QA de su tanda completa, §21.8: coincide con lo reportado.
- BUG-069: documento de estado medido + entrada obsoleta de la allowlist retirada (audit exit 0).
- **Lección de arnés:** `Start-Process -RedirectStandardOutput` devuelve **exit codes falsos** en
  esta máquina (marcó rojas suites que dan 0). Para medir suites: `& godot ... ; $LASTEXITCODE`.
- **Log creado: 2451** (`Logs/2451-cobertura-del-gate-427-suites-fuera-de-ci_2026-11-25_11-11-00.md`).
- Reporte al director: mensaje `004` del canal. Esperando respuesta a 2 preguntas
  (registrar suites M17 en `quality.yml`; sumar el paso de cobertura al CI).

## ÍNDICE DE ARCHIVOS

| Archivo | Contenido | Estado |
|---|---|---|
| `01-Backlog-Cola-Activa.md` | Cola 1-181 (CI/build/Memoria M62/Economía M38/M95/reposición) | Activo |
| `02-Backlog-Criticos-12.md` | Los 12 críticos Nemotron + post-críticos | **Activo** |
| `03-Backlog-Frente-Estetico-Premium.md` | M90 Config Gráfica (92 ítems) + M91/M158/M147/M15/M62 | Pendiente |
| `04-Backlog-Repoblacion-V3.md` | Ítems reales de `05-Checklist`: M62/M15/M147/M158 | Mixto |
| `02-Backlog-Bloques-Originales.md` | Bloques A-Z + W2 (casi todos `[x]`) | Cerrado |
| `00-Backlog-Original-PreSplit.md` | MASTER original (738 líneas, pre-split del 4 nov) | Archivo |
| `evidencias/BUG-069-estado-2026-11-25.md` | Grafo de servicios medido (A1/A2) para BUG-069 | Activo |

## REGLAS

1. **Independencia de QA (§21.8/§21.23):** no verificar módulos del canal `DeepSeek-V4.1-Flash` (WorkBuddy) — mismo modelo, otro agente.
2. **No editar** el backlog de otro modelo; el canal OC queda histórico.
3. **Un módulo por vez** (§21.4); reserva `🔵` en `CHECKLIST-GLOBAL`.
4. **Política de duplicados 052** vigente.
5. **Logs:** pool global `Logs/NUMEROS_DISPONIBLES.txt` (último consumido propio: **2451**).

## MANTENIMIENTO

La directora agrega tandas nuevas como `05-Backlog-<descripción>.md` y actualiza este índice en cada ronda.

**Firma:** Deepseek V4.1 Flash-DeepAI · DeepAI · 2026-11-25 11:14
