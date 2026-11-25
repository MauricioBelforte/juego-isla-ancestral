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
| C3 | Test Suite | M112 | [~] | 100 suites del workflow ejecutadas: ver sección REGISTRO DE TANDAS |
| C4 | Legal Tooling | M127 | [x] | 84 `.glb` sin copyright (techo 418 excedido) + 2 archivos con EOL mixto y cabecera desactualizada. Ahora 0 hallazgos nuevos |

### Bloque 2 — Críticos Nemotron (12)

1. [ ] VfxDirector: agregar `_process`/`_exit_tree` (fuga de RAM)
2. [ ] HealthComponent: validar `NaN`/negativo
3. [ ] Logging: fuga de RAM
4. [ ] Save: pre-validación del payload
5. [ ] DLC: manager
6. [ ] Economía: retiro cero + tope de saldo
7. [ ] M17 lote 1: circulación + apoyo alternativo
8. [ ] M129: stock + numeración
9. [ ] M129: boot B-17 / B-12-06
10. [ ] M17: tests (`test_m17_construccion_validacion`, `test_m17_suites_integracion`)
11. [ ] Regresión M21/M162 (Hy3 524)
12. [ ] Verificación global (300 s headless)

### Bloque 3 — Post-críticos (se abren cuando cierren los 12)

- [ ] M17: 33 `[ ]` restantes (UI/arte/audio/navmesh/cross-module)
- [ ] M129: 54 ítems (merch/numeración/boot)

### Bloque 4 — Cola 1-181 (heredada)

- 101 ítems `[x]` (cerrados; ver `01-Backlog-Cola-Activa.md`)
- [ ] **102 — BUG-069**: verificar refs de los 8 módulos ajenos (GO parcial en el 263)

## REGISTRO DE TANDAS

### Tanda 2026-11-25 09:45 — apertura del canal

- Canal creado, herencia copiada (270 archivos), backlog vivo, puntero en el canal OC, entrada en `ESTADO-PARALELO`.
- **Log creado: 2443** (`Logs/2443-canal-deepseek-v4-1-flash-deepai-apertura-herencia_2026-11-25_09-45-00.md`).

### Tanda 2026-11-25 09:58 — CI rojo (bloque 1)

- C2 Architecture Guard: declarada la arista `A1|DataStore,SaveManager` (ciclo funcional, ambas direcciones con `get_node_or_null`); refactor a mediador pendiente.
- C4 Legal Tooling: nuevo `tools/legal/inject_glb_copyright.py` (+ autotest) e inyección de `asset.copyright` en los **84 `.glb`** que excedían el techo; `generate_item_attribution.py` y su test normalizados (EOL) y con cabecera canónica (`--apply`). Validadores: 0 hallazgos nuevos, techo 418/418.
- C1 Lint/Format: M169 resuelve sus autoloads por nodo (2 archivos); gate de parseo 0 errores sobre 1366 scripts.
- **Log reservado: 2445** (el 2444 lo consumió otro agente mientras corría la tanda).

## ÍNDICE DE ARCHIVOS

| Archivo | Contenido | Estado |
|---|---|---|
| `01-Backlog-Cola-Activa.md` | Cola 1-181 (CI/build/Memoria M62/Economía M38/M95/reposición) | Activo |
| `02-Backlog-Criticos-12.md` | Los 12 críticos Nemotron + post-críticos | **Activo** |
| `03-Backlog-Frente-Estetico-Premium.md` | M90 Config Gráfica (92 ítems) + M91/M158/M147/M15/M62 | Pendiente |
| `04-Backlog-Repoblacion-V3.md` | Ítems reales de `05-Checklist`: M62/M15/M147/M158 | Mixto |
| `02-Backlog-Bloques-Originales.md` | Bloques A-Z + W2 (casi todos `[x]`) | Cerrado |
| `00-Backlog-Original-PreSplit.md` | MASTER original (738 líneas, pre-split del 4 nov) | Archivo |

## REGLAS

1. **Independencia de QA (§21.8/§21.23):** no verificar módulos del canal `DeepSeek-V4.1-Flash` (WorkBuddy) — mismo modelo, otro agente.
2. **No editar** el backlog de otro modelo; el canal OC queda histórico.
3. **Un módulo por vez** (§21.4); reserva `🔵` en `CHECKLIST-GLOBAL`.
4. **Política de duplicados 052** vigente.
5. **Logs:** pool global `Logs/NUMEROS_DISPONIBLES.txt` (último reservado: **2443**).

## MANTENIMIENTO

La directora agrega tandas nuevas como `05-Backlog-<descripción>.md` y actualiza este índice en cada ronda.

**Firma:** Deepseek V4.1 Flash-DeepAI · DeepAI · 2026-11-25 09:45
