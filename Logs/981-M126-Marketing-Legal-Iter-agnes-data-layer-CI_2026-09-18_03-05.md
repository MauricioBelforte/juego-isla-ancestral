# Log 981: M126 Marketing-Legal — iter. agnes acotada (data-layer + gate CI + reconciliación)

**Fecha:** 2026-09-18
**Hora:** 03:05
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code

## Resumen

Iteración del bucle V0/data-driven de **agnes-3-flash** sobre **M126 Marketing-Legal** (relevo del
`🟢 Disponible 0/101 revertido por auditoría 2026-09-14`). **Alcance acotado:** verificar el scaffold
de validación de datos, cablearlo al gate CI y reconciliar el sobre-cierre del `Totales`. NO implemento
la capa de servicio ni la legal review (dueño M126 / humana).

## Cambios Realizados

- **`quality.yml`:** `test_marketing_legal_m126.gd` **no estaba** cableado → añadido al **gate duro**
  (job test-suite), junto a los tests M83.
- **`05-Checklist.md` M126:**
  - 4 ítems "Especificación de marketing legal" re-marcados `[x]` con evidencia (cargado JSON,
    detección de errores estructurales, test headless, datos data-driven) — todos respaldados por
    `marketing_legal.json` + `marketing_legal_validator.gd` + `test_marketing_legal_m126.gd`.
  - `Totales` **sobre-cerrado** ("101 resueltos / 0 pendientes", stale) → flag + estado real
    **`4 [x] / 97 [ ]`**.
  - §"QA agnes — capa data-layer + gate CI" (verificación + lo que NO hice + dueños).
  - `Reserva actual` (reserva 981).
- **`04-Codigo.md` M126:** §"Iteración agnes" (estado real del código + gap CI + lo no implementado).

## Verificación (godot 4.7.2 headless)

- `godot --headless --path game/isla-ancestral --script res://scripts/legal/test_marketing_legal_m126.gd`
  → **9 checks, 0 fallos, exit 0**. (6 `SCRIPT ERROR` del boot: `theme_ux`/`theme_service`/
  `dialog_layer`/`ui_root` — preexistentes y ajenos a M126.)
- Datos: `data/legal/marketing_legal.json` (4 `cumplimientos` + 2 `politicas`) carga y valida 0 errores.

## Hallazgos
1. **Sobre-cierre stale:** el `Totales` de M126 declaraba "101 resueltos / 0 pendientes" aunque el
   archivo estaba revertido a 0/101 por la auditoría. Corregido a estado honesto 4/97.
2. **Gap CI:** el test del módulo no estaba en `quality.yml` (aunque el scaffold era verde) → cableado.
3. **Brecha real (no la cierro):** capa de servicio (`MarketingLegalManager`/`Config` autoloads +
   Resource) + doc `legal/126_*.md` + legal review humana = **dueño M126 / abogado**.

## Archivos Modificados/Creados

- `.github/workflows/quality.yml` (gate M126)
- `DOCUMENTACION/126-Marketing-Legal/plan-actual/04-Codigo.md` (§Iteración agnes)
- `DOCUMENTACION/126-Marketing-Legal/plan-actual/05-Checklist.md` (4 `[x]` + Totales + §QA + reserva)
- `CHECKLIST-GLOBAL.md` fila 126 (mod)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada)
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/` (BACKLOG + 126, nuevo)
- `game/isla-ancestral/scripts/legal/` (scaffold preexistente, **no lo modifiqué** — solo verifiqué)

## Estado de M126
🟡 **Liberado (iter. agnes, acotada).** 4/101. Mi parte (verificación data-layer + gate CI +
reconciliación) entregada. La capa de servicio/docs/legal-review sigue con **dueño M126**. QA cruzado
§21.8 pendiente (verificador ≠ agnes-3-flash).
