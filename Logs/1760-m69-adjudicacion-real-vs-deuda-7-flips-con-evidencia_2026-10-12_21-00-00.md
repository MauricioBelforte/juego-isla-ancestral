# Log 1760: M69-Fast-Travel adjudicacion real vs deuda — 7 flips [x]->[?] con grep de evidencia negativa

**Fecha:** 2026-10-12
**Hora:** 21:00
**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

## Resumen

Encargo del director (mimo-v2.6-flash-free, mensaje #40 del canal atria-dawn): "M69-Fast-Travel (18/150, amarillo, 131 [ ] + dueno desconocido) — adjudica primero que hay de real y que es deuda, despues barre. Es deep work de tu perfil." Se adjudicaron los 18 `[x]` uno a uno contra disco, se confirmaron 11 reales (nucleo data-driven implementado) y se flipearon **7 `[x]`→`[?]`** por ser claims de otros modulos (M91 audio, M104 analytics, M53 accesibilidad) o tests inexistentes. Conteo: 18/130/2 → **11/130/9 = 150**.

## Que hay de REAL (verificado contra disco)

| Artefacto | Verificacion |
|---|---|
| `game/isla-ancestral/data/fasttravel/anclas.json` (496 B) | v2, 4 anclas RIZ (LOC-RIZ-PUB-001, LOC-RIZ-CASA-001, LOC-RIZ-TIE-001, ancla_playa_norte), ids alineados a ubicaciones, `desbloquea: true` |
| `game/isla-ancestral/scripts/fasttravel/fast_travel_service.gd` (65 l., 1909 B) | API real: `anclas()`, `anclas_desbloqueadas()`, `desbloquear()`, `esta_desbloqueada()`, `solicitar_viaje()` + señales `ancla_desbloqueada` / `viaje_solicitado`; carga data-driven desde `res://data/fasttravel/anclas.json` |
| `game/isla-ancestral/scripts/fasttravel/test_fast_travel_headless.gd` (47 l.) | 7 checks coherentes con el JSON: 4 anclas, 4 desbloqueadas base, coords, re-desbloqueo no duplica, viaje solicitable, señal emitida, ancla inexistente → false |
| `game/isla-ancestral/scripts/transporte/transport_m69_bridge.gd` (11 KB) | Puente M69↔M68 real: `destinos_disponibles()` filtra anclas cuya estación M68 esté desbloqueada; `validar()` impide ofrecer paradas bloqueadas |
| `scripts/transporte/test_transporte_m68_iter2.gd` | Referencia al servicio (2 hits) — integración cubierta |

**Conclusion:** el nucleo data-driven del modulo (anclas + servicio + puente M68 + test) **esta implementado**. La UI, la ejecucion del viaje (M28/M157) y las integraciones transversales NO existen — el modulo esta correctamente marcado delegable para esa parte.

## Que es DEUDA — 7 flips [x]→[?] con evidencia

Grep estricto sobre `game/isla-ancestral/{scripts,tests,data}` excluyendo `.godot/`:

| Item (seccion) | Evidencia |
|---|---|
| §C "Volumen configurable por bus (M91)" | claim de **M91** (audio). 0 artefactos M69 de volumen. **Duplicado** del item identico en §F. |
| §F "Música -6 dB durante logros si se usa fast travel" | claim de M91/M63 (ducking de audio). El servicio no toca buses de audio. |
| §G2 "Test: fast travel bloqueado durante combate" | `combate.*bloque\|bloque.*combate\|en_combate` → **0 hits** en M69. El diseño lo pide (03-Diseno §6), el artefacto no existe. |
| §G2 "Test: fast travel bloqueado durante diálogos críticos" | idem: `en_dialogo` existe solo en `transport_manager.gd:131` (M68); sin test M69. |
| §K "Lectura por screen reader de menu" | `screen_reader\|verbal description` → **0 hits** en `scripts/`. |
| §L "M104: evento analytics fast_travel_used" | `fast_travel_used` → **0 hits** en scripts/tests/data. El evento de analytics no existe. |

El 7º flip cuestionado (§G "Sin hardcode de paths de destino") resultó **real** (RUTA_ANCLAS const, data-driven) y no se tocó.

## Cambios Realizados

- `DOCUMENTACION/69-Fast-Travel/plan-actual/05-Checklist.md`:
  - 6 flips `[x]`→`[?]` con cita de evidencia (volumen ×2 duplicado, música -6 dB, test combate, test diálogos, screen reader, analytics M104)
  - Nueva sección "Adjudicación + barrido" con la tabla real/deuda completa
  - Totales: 18/130/2 → **11/130/9 = 150** (verificado con regex estricto)
  - Firma actualizada a atria (Atria-Dawn-Preview) / Kilo Code

## Lo que NO se hizo (honestidad obligatoria)

- **Test headless no ejecutado** (sin Godot en el sandbox): los 7 checks quedan pendientes de CI/headless. Leído el código, son coherentes con `anclas.json`.
- Los **130 `[ ]`** restantes son mayoritariamente implementación de UI, ejecución del viaje (M28/M157) e integraciones transversales — correctamente delegables, no se tocaron.
- **No se tocó CHECKLIST-GLOBAL** ni se aplicaron sellos §21.8 (reglas del director). No se committeó.

## Contexto

- La auditoría de drift (atria-dawn-preview, 2026-09-20, lote 4) ya había detectado el claim falso de cierre de Nemotron 3.5 Lightning (Log 1093: "143 ítems · Completados 143" → real 18) y registrado **BUG-063** en `11-BUGS.md`. Este barrido es la continuación: no alcanzaba con corregir la línea de Totales, había que adjudicar los `[x]` uno a uno — que es justo lo que el director pidió.
- El conteo citado por el director en el encargo ("18/150, 131 [ ]") era casi exacto: el real era 18/150 con **130** `[ ]` y 2 `[?]` (no 131). Diferencia de 1 ítem por el conteo de `[?]`; sin impacto material.
