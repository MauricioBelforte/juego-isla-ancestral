# Log 1730: M83 barrido — núcleo de licencias ampliado (encargo director msg 78), test 37/0 EXIT 0

**Fecha:** 2026-10-12
**Hora:** 02:35
**Modelo:** Ling 3.1 Flash
**Plataforma:** Kilo Code

## Resumen

Encargo del director (mimo, msg 78): "M83-Licencias barrido — Lee
`DOCUMENTACION/83-Licencias-De-Software/plan-actual/05-Checklist.md`. Núcleo
existe: `scripts/licensing/license_scanner.gd`, `license_validator.gd`,
`license_policy.gd`. Amplía, no recrees. Test headless. No toques
CHECKLIST-GLOBAL, no commit, UTF-8. Reporta en tu canal."

Se amplió el núcleo existente (`license_scanner.gd`) con los ítems pendientes
factibles de la capa de licencias; no se recreó nada.

## Cambios Realizados

### Nuevas funciones en `scripts/licensing/license_scanner.gd`
- `verificar_uso_comercial(inventario)` (B.9): alertas para CC_BY_NC y
  `commercial_use=false`.
- `detectar_dual(texto)` (B.14): marcadores exclusivos → 0/1/2+ tipos;
  evita falso dual CC BY vs CC BY-NC (marcador "cc by " con espacio).
- `verificar_integridad(inventario)` (G.9): license_file ausente,
  inexistente o vacío.
- `include_in_build(inventario, build_dir)` (C.5).
- `generate_notice(inventario, build_version)` (C.6): versión del build en
  el header (param opcional, backward-compatible).
- `save_notices(inventario, output_dir, build_version, formato)` (C.4/G.6):
  copias individuales con el TEXTO ORIGINAL de la licencia (no solo el
  tipo) + formatos txt/md/json + `_notices_md()`.

### Ítems verificados (existían, marcados stale → `[x]`)
B.4/B.7/B.8 (`verificar_contra_politica`), B.11/B.12/B.13
(`check_compatibility`, `requires_source_offer`, tabla COMPAT direccional),
C.2/C.8/C.9 (`generate_notice`).

### Nuevo test `scripts/licensing/test_m83_barrido.gd`
37 checks: uso comercial (4), dual (6), integridad (3), notices ampliados
(11), policies (8), compatibilidad (5).

### Checklist del módulo (`DOCUMENTACION/83-Licencias-De-Software/plan-actual/05-Checklist.md`)
- 19 ítems `[ ]` → `[x]` con nota iter5.
- **Totales corregido**: estaba stale (decía 32, real 34) → **53 [x] / 47 [ ]
  / 0 [?] = 100** (conteo regex verificado en disco).
- "Reserva actual" actualizada (Log 1730) + sección "Iteración 5 — barrido"
  con detalle y honestidad (§21.4.8).

### Encoding
- UTF-8 sin BOM verificado en los 3 archivos tocados; se removió un BOM que
  tenía `license_scanner.gd` (§28).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/licensing/license_scanner.gd` (ampliado)
- `game/isla-ancestral/scripts/licensing/test_m83_barrido.gd` (nuevo)
- `DOCUMENTACION/83-Licencias-De-Software/plan-actual/05-Checklist.md`
- `Mensajes entre modelos/Ling-3.1-Flash/80-...-m83-barrido-iter5-ampliado-37-0-verde.md`

## Verificación
- `C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral -s
  res://scripts/licensing/test_m83_barrido.gd` → **37 checks, 0 fallos,
  EXIT 0** (re-verificado tras quitar BOM).
- Regresión `test_license_scanner_m83.gd` (agnes): **24/0 EXIT 0**.
- Regresión `test_licenses_m83.gd` (validator): **17/0 EXIT 0**.

## Notas
- Cumplimiento del encargo: CHECKLIST-GLOBAL **no tocado**, **sin commit**.
- Lo que NO se hizo (honestidad): §D (build pipeline M72/M117), §E
  (dependencias M55), §F (assets M71), G.1-G.5/G.10 (`build_licenses.py`,
  CI/CD, verbose/silent, compare), H.9/H.10 (tests de integración build
  pipeline y dependencia circular), §I (docs) — fuera del alcance de la capa
  de licencias o requieren sus módulos dueños.
- Errores de boot en headless (fishing_manager typed arrays, AnimationService)
  son preexistentes y ajenos a M83.
