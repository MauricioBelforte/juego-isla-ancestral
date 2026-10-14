# step-5-kilocode — Sugerencias de delegación

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Última actualización:** 2026-10-12 02:15

---

## Encargo actual

**M49 pool de luces** (msg 171). Cuando libere → M72.

## Siguiente: M72-Sistema-De-Logros

**Estado:** 11/185 (174 `[ ]`, 3 `[?]` con dueño), cx 2, liberado, sin dueño. Es el 2º módulo con
más pendientes del proyecto.

**Núcleo que ya existe (verificado en disco):** `scripts/logros/` con
`achievement_service.gd`, `test_logros.gd`, `test_logros_m72_statids.gd` vivos.
`data/logros/logros.json` con 7 logros cozy. **No arranca de cero.**

### Lote: secciones B + E (~27 `[ ]`)

**Sección B — 14 `[ ]`** (RF1 campos + RF14 validaciones):
- RF1: `nombre_i18n`/`descripcion_i18n`, `icono` (Texture2D obligatorio), `categoria`
  (agricultura, pesca, mineria, amistad, colecciones, progresion, economia, exploracion),
  `oculto` (ya en logros.json + testeado), `condicion` (vocabulario M71 §3.6),
  `logro_steam_id` (M97), `orden` de presentación
- RF14 validaciones editor: ids no duplicados (`validar_catalogo()` existe), icono asignado,
  condición no nula, categorías con vocabulario conocido, mapeo Steam sin duplicados
- CAT: catálogo base cozy por categoría, sin números abusivos ni contrarreloj

**Sección E — 13 `[ ]`:** persistencia de logros desbloqueados integrando M59 (`save_writer`
existe, ya usado por M37), integridad del guardado, migración de versión.

**Fuera del lote (segundo lote):** D/F (UI, M53), I (integraciones M37/M71/M97), J/K/L/M.

### Encargo listo para reenviar

> **Encargo: M72-Logros, lote secciones B+E (~27 `[ ]`).** Lee
> `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md` secciones B y E. Núcleo existe:
> `scripts/logros/achievement_service.gd`, `test_logros.gd`, `test_logros_m72_statids.gd`, y
> `data/logros/logros.json` con 7 logros cozy. Amplía, no recrees. Sección B: completar campos
> RF1 + validaciones RF14 (algunas ya implementadas por agnes — leer las anotaciones al final de
> cada ítem). Sección E: persistencia integrando M59. Test headless con
> `C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral -s`.
> No toques CHECKLIST-GLOBAL, no commit, UTF-8. Reporta en tu canal.

---

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
