**Modelo:** hy3 (WorkBuddy / Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-02
**Log:** 1183 · **Tarea:** P-58 — BUG-084 Fase 2, M166 Variantes-Y-Perfil-De-Rendimiento (migración bench_recorder.gd a MundoRaiz)
**Rol:** tercer verificador §21.8 (verificador ≠ autor) + fix de módulo propio (M166 asignado a hy3 tras reconciliación de locks de atria-dawn, commit e87d401)

---

## 0. Contexto

- BUG-084 fue diagnosticado en la Fase 1 (Log 1179, 2026-09-30): `scripts/performance/bench_recorder.gd`
  tenía waypoints y el VoxelViewer hardcodeados al mundo viejo 512² (centro 256,256). En el mundo
  real 5120² (centro 2560,2560) el benchmark se sentaba en la esquina vacía y encuadraba ~256u, por lo
  que sus datos de rendimiento no representaban la isla real.
- M166 pasó de 🔵 (mimo-v2.5 inactivo) a 🔵 de hy3 (e87d401, 2026-10-02 07:15). Por regla #2, al ser
  mío, aplico el fix sin restricción. Los otros 4 bugs de la Fase 1 (082/083/085/086) siguen delegados.
- Método: skill `isla-ancestral-qa-gate` (selftest → inyectar valor viejo para probar el gate vivo →
  fix → barrido → commit selectivo). Godot 4.7.2 console headless.

## 1. Diagnóstico (hardcodes 256 confirmados en bench_recorder.gd)

- WAYPOINTS (L17/19/20/21/22): 6 waypoints con `x=256` o `z=256` (centro viejo 256,256).
- `generator.island_radius = 256` (L112) — el mundo real usa 2560 (`MundoRaiz.CENTRO.x`, ver
  `world_generator.gd:8`, `main_island.gd:147`).
- `viewer.view_distance = 256.0` (L117) — el juego real usa 1024 (`main_island.gd:158`).
- `viewer.global_position = Vector3(256,30,256)` (L119).
- `look_at(Vector3(256,12,256))` (L139).

## 2. Método — gate headless mínimo (no existía suite para bench_recorder)

Se creó `scripts/performance/test_bench_recorder_m166.gd` (estilo `test_budget_profile.gd`,
`extends SceneTree`). Preload + instancia `bench_recorder.gd` y valida los valores REALES del script:
- `calcular_waypoints()` → 6 waypoints, ninguno en la esquina vieja 256,256, todos dentro del radio
  real (<= CENTRO.x * 1.05).
- `posicion_viewer()` y `objetivo_look()` → en `MundoRaiz.CENTRO` (2560,2560).
- Imprime `=== TEST M166 BENCH RECORDER (BUG-084): N fallo(s) ===` y `quit(1 if fallos>0 else 0)`.

## 3. Prueba del gate (vivo: verde → rojo → verde)

- **Verde (base):** `0 fallo(s)`, `exit 0`, 0 `SCRIPT ERROR`.
- **Rojo (inyección del defecto viejo):** revertí temporalmente `calcular_waypoints`/`posicion_viewer`/
  `objetivo_look` a coords 256 → **9 FALLO + `exit 1`** (waypoints fuera del mundo real, viewer/look en
  256,256). Esto prueba que el gate NO es ciego (trampa 91 superada).
- **Verde (tras revertir el fix):** `0 fallo(s)`, `exit 0`. Gate confirmado vivo.

## 4. Fix aplicado (bench_recorder.gd)

- Los 6 waypoints se reescriben como `WAYPOINTS_VIEJO` (offsets desde el centro viejo, `y`=altitud) +
  `calcular_waypoints()` que los reubica en `MundoRaiz.CENTRO` (2560,2560) escalados por
  `CENTRO.x / RADIO_VIEJO` (=10) para preservar la dispersión costa/centro del benchmark.
- `RADIO_VIEJO := 256.0` queda como única constante documentada del radio viejo (fuente del escalado).
- `generator.island_radius = 256` → `int(MundoRaiz.CENTRO.x)` (2560).
- `viewer.view_distance = 256.0` → `1024.0` (igual que `main_island.gd:158`).
- `viewer.global_position` y `look_at` → `MundoRaiz.centro_vec3(30/12)`.
- Se expusieron `posicion_viewer()` / `objetivo_look()` para que el gate valide los valores reales.
- Barrido: grep confirma que NO quedan literales `256` en código (solo comentarios históricos y
  `RADIO_VIEJO`). También se corrigieron 3 refs a `WAYPOINTS` en `_process`/`_finalizar` que habrían
  dado `SCRIPT ERROR` (renombrado a `calcular_waypoints()`).

## 5. Commit (selectivo, push NEGATIVO)

- Pathspect explícito (trampa 114/115): SOLO mis archivos. En el working tree hay trabajo ajeno
  (kimi-k3 M70 `interacciones/*`, agnes `ui_root.gd` + `TAREAS-POR-MODELO/kimi-k3/BACKLOG-MASTER.md`,
  M131 `legal/*`, backup de reconciliación de atria) — NINGUNO incluido.
- `CHECKLIST-GLOBAL.md` (fila 166) se editó byte-exact en el working tree (trampa M-06: NUL=1, CRLF=231,
  LF=0, CR=219 preservados) pero se DEJA SIN COMMITEAR para el coordinator (convención del skill).
- Pool: `Logs/NUMEROS_DISPONIBLES.txt` — se consumió 1183 (leído en disco vivo; cabeza ahora 1184) y se
  commite en el mismo changeset que este log.
- **Push NEGATIVO** (el coordinator decide el merge/push).

## 6. Cierre y delegación

- BUG-084: `[x] Resuelto` (ver `11-BUGS.md` §8, firma hy3).
- Los OTROS 4 bugs de la Fase 1 siguen delegados por regla #2 (módulos ajenos 🟡/🔵):
  - BUG-082 (M27, DeepSeek) → delegar
  - BUG-083 (M51, glm-5.3-flash) → delegar
  - BUG-085 (M69, agnes-2.5-flash) → delegar
  - BUG-086 (M50, agnes-2.5-flash) → delegar
- M166: estado 🟡 Liberado (BUG-084 resuelto; H12 `[?]` art pass externo de Blender, dueño mimo-v2.5/Hy4,
  fuera de alcance de código), Agente → —, Última actividad 2026-10-02 04:22.
