**Modelo:** hy3 (WorkBuddy / Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-30
**Log:** 1179 · **Tarea:** Auditoría Fase 1 — reductos (256,...) del centro viejo (M167 post-P-39)
**Rol:** tercer verificador §21.8 (verificador ≠ autor) + auditoría estática de código ajeno (solo lectura/clasificación)

---

## 0. Contexto

- P-39 (Log 1153, commit `969479f`) terminó la migración M167 opción A: `main_island.gd` (spawn/océano/
  disco) y `validador_isla_raiz.gd` ya usan `MundoRaiz` (mundo 5120², centro (2560,2560)).
- El coordinador pidió auditar los **26 hits restantes** de `(256,...)` en `game/` para decidir si son
  fixtures legítimos o bugs latentes. Fase 1 = DIAGNÓSTICO PURO: leer + clasificar, **NO tocar
  código ajeno**.
- Pool: leí `Logs/NUMEROS_DISPONIBLES.txt` en disco; próximo libre = **1179** (mimo ya reservó 1178
  para BUG-081 y está `[→]`). Reservé 1179 (borré la línea; en mi backlog).

## 1. Exclusiones explícitas (NO tocar — son la protección o documentación)

- `scripts/terreno/validador_isla_raiz.gd:79-87` — strings anti-regresión dentro de `_check()` que
  verifican que NO exista `Vector3(256, 16, 256)`. Tocarlos rompe el gate (P-39).
- `scripts/main_island.gd:184/209/298` — comentarios que documentan el valor viejo (los dejé así en P-39).

## 2. Metodología

Auditoría estática: leí cada línea listada + su contexto, y cuando hizo falta el archivo dueño
(`map_data_service.gd`, `fast_travel_service.gd`, `anclas.json`, `medir_costa_m51.gd`). Clasifiqué
cada hit como **(a)** fixture legítimo de test, **(b)** bug latente, o **(c)** fallback cuestionable.
Sin ningún edit.

## 3. Clasificación por archivo

| Archivo:Línea | Hit | Clasif. | Justificación |
|---|---|---|---|
| fasttravel/test_fast_travel_headless.gd:29 | `anclas()[0].get("x")==256 and .get("z")==256` | **(a)** fixture | Test data-driven: verifica que el servicio devuelve lo que dice `anclas.json`. El test es correcto, pero PINCHA el bug de datos BUG-085. |
| map/test_map_service_headless.gd:34 | `dentro_de_isla(256,256)` == true | **(a)** fixture | Test de `dentro_de_isla`. Válido tal como está el servicio, pero PINCHA el bug BUG-082 (servicio en geometría 256). |
| performance/bench_recorder.gd:17,20,22 | WAYPOINTS `Vector3(256,…)` | **(b)** bug | Cámara del benchmark clavada en el mundo viejo 256; en 5120² encuadra una esquina. BUG-084. |
| performance/bench_recorder.gd:119 | `viewer.global_position = Vector3(256,30,256)` | **(b)** bug | VoxelViewer en la esquina; debería estar en `MundoRaiz.CENTRO`. BUG-084. |
| performance/bench_recorder.gd:139 | `look_at(Vector3(256,12,256))` | **(b)** bug | Mira a la esquina. BUG-084. |
| vegetacion/test_distribucion.gd:16 | `generar_plan(Vector2(256,256),256.0,42)` | **(a)** fixture | `generar_plan(center,radius,seed)` es puro; (256,256)+256 es solo input de prueba. El spawner real usa el centro real. |
| vegetacion/test_vegetation_headless.gd:34,35,37 | `posiciones("playa",Vector2(256,256),100.0,42)` | **(a)** fixture | Inputs de planner puro (test de determinismo/semilla). No son coords de mundo. |
| vegetacion/test_vegetation_plan_headless.gd:26,28 | `generar_plan(Vector2(256,256),256.0,42)` | **(a)** fixture | Ídem test_distribucion. |
| vegetacion/test_vegetation_spawner_headless.gd:27 | `generar_plan(Vector2(256,256),256.0,42)` | **(a)** fixture | Ídem; el spawner real (vegetation_spawner.gd) ya usa `MundoRaiz`. |
| vegetacion/vegetation_spawner.gd:36 | `else Vector2(256,256)` | **(c)** fallback | Si `MundoRaiz` ausente (headless sin autoload) cae a la esquina. En juego usa `SPAWN_CONTENIDO` (3860,3860). BUG-086. |
| world/medir_costa_m51.gd:6 (+33-34) | comentario "centro (256,256)" + `256.0 + dir*r` | **(b)** bug | Código hardcodea centro 256.0; NO lee `MundoRaiz`. Mide la costa vieja, no la isla 5120². BUG-083. |

## 4. Hallazgos delegables (módulos de otros agentes → coordinator delega)

- **BUG-082** `map_data_service.gd` `dentro_de_isla` / "isla RIZ 256" no migrado (mapa/islas, 🟠 Mayor).
- **BUG-083** `medir_costa_m51.gd` centro hardcodeado 256.0 (M51, 🟠 Mayor).
- **BUG-084** `bench_recorder.gd` waypoints/viewer en mundo viejo (performance/stress M113/M166, 🟡 Menor).
- **BUG-085** `anclas.json` fast-travel en esquina (M69, 🟠 Mayor — teletransporta a la esquina del mundo).
- **BUG-086** `vegetation_spawner.gd:36` fallback a (256,256) (M50, 🟡 Menor — solo degrada en headless).

## 5. Conclusión Fase 1

- 4 bugs latentes **(b)** + 1 fallback cuestionable **(c)** en módulos ajenos → entradas BUG-082…086 en
  `11-BUGS.md` (sección 8, firmadas hy3), estado `[?] Delegado`.
- 4 archivos de test de vegetación = fixtures legítimos **(a)**: no requieren cambio; el planner es puro.
- Los tests de fast-travel (L29) y map (L34) son fixtures **(a)** pero REVELAN bugs en data/servicio
  (BUG-085 / BUG-082): el test pasa porque el dato/servicio sigue en 256; al migrar el dato habrá que
  actualizar el valor esperado del test.
- **NO se modificó ningún módulo ajeno.** Pool 1179 reservado y sin commitear.

## 6. Entrega y pendientes

- `DOCUMENTACION/11-BUGS.md` (BUG-082…086) y este log: **sin commitear** (fase 1 = documentación
  pura; el coordinator cierra en su merge junto con GLOBAL/pool).
- Pendiente fase 2 (si el coordinator autoriza y el módulo está 🟢/✅ libre): migrar BUG-082/083/084/
  085/086 a `MundoRaiz`, con el gate del skill `isla-ancestral-qa-gate` (selftest → rojo → barrido →
  commit selectivo) y verificación runtime donde aplique.
- TRAMPAS respetadas: 113 (lock git — no hubo commit), 114 (índice compartido — mimo activo con 1178,
  NO `git add .`; solo edité 11-BUGS.md + pool + este log), 117 (path exacto, no "falso limpio"),
  118 (sin mojibake: verifiqué con lector UTF-8, no por la impresión del shell).

## 7. Matriz de dueños (regla #2) — cierre de la Fase 1

Lectura de `CHECKLIST-GLOBAL.md` (HEAD del repo en movimiento; fila tomada hoy). La regla #2 dice:
> si el módulo está 🔵/🔴 de otro agente, lo reportás y el coordinator delega; si está 🟢/✅ libre,
> el coordinator autoriza el fix en fase 2.

| Bug | Archivo afectado | Módulo dueño | Estado CHECKLIST | Dueño actual | Elegible fix Fase 2 (sin autorización)? |
|-----|------------------|--------------|------------------|--------------|------------------------------------------|
| BUG-082 | `map/map_data_service.gd:81` | M27 Islas-Del-Mundo | 🟡 Liberado (iter.2 ✅) | DeepSeek-V4.1-Flash | NO — delegar a DeepSeek |
| BUG-083 | `world/medir_costa_m51.gd:33-34` | M51 Agua | 🟡 Liberado (iter.5 shore-fade) | glm-5.3-flash | NO — delegar a glm |
| BUG-084 | `performance/bench_recorder.gd` | M166 Variantes-Y-Perfil | 🔵 En curso (111/112) | mimo-v2.5 | NO — delegar a mimo |
| BUG-085 | `data/fasttravel/anclas.json` | M69 Fast-Travel | 🟡 Con dudas | agnes-2.5-flash | NO — delegar a agnes-2.5 |
| BUG-086 | `vegetacion/vegetation_spawner.gd:36` | M50 Vegetación | 🟡 Liberado (iter.3 LOD deferred) | agnes-2.5-flash | NO — delegar a agnes-2.5 |
| (fixture) | `test_fast_travel_headless.gd:29` | M112 Testing-Automático | ✅ Completado (208/208) | ox-alpha (Cline) | NO toca código: el test SOLO cambia su valor esperado al migrar BUG-085 |
| (fixture) | `test_map_service_headless.gd:34` | M112 Testing-Automático | ✅ Completado | ox-alpha (Cline) | NO toca código: el test SOLO cambia su valor esperado al migrar BUG-082 |
| (fixtures) | `test_vegetation_*.gd` (4 archivos) | M112 Testing-Automático / M50 | ✅ / 🟡 | ox-alpha / agnes-2.5 | NO: planners puros, sin cambio |

**Veredicto de la regla #2:** de los 8 módulos implicados, **solo M112 está ✅**, y es el harness de
test (no contiene el bug; sus tests *revelan* bugs en M27/M69). Los 7 módulos donde vive el bug real
(M09, M27, M50, M51, M69, M113, M166) están **todos 🟡/🔵**, reclamados por agnes-2.5-flash,
glm-5.3-flash, DeepSeek-V4.1-Flash, mimo-v2.5 o agnes-3-flash. **Conclusión: NINGUNO es 🟢/✅ libre
para que hy3 lo fixee en Fase 2 sin delegación explícita del coordinator.** Se deja BUG-082…086 en
`[?] Delegado` y este informe de dueños para que el coordinator reparta los fixes.

**Nota de seguridad del índice (trampa 114/115):** al hacer `git status` hoy aparecieron 3 archivos de
`scripts/logging/` modificados y SIN staging (`logger.gd`, `logging_config.gd`, `test_m103_frame_budget.gd`)
que **NO son de esta auditoría** — son la recepción de BUG-067 por DeepSeek (Log 1109). No los incluyo
en ningún commit ni los toco. Mis artefactos de Fase 1 (`11-BUGS.md`, `NUMEROS_DISPONIBLES.txt`, este
log) quedan sin commitear para el merge del coordinator, igual que en P-39.
