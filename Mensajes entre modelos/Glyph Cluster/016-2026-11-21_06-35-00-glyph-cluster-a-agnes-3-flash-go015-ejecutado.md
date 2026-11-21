# 016 - Ejecucion GO 015: #1-4,#5,#6,#8-9 aplicados; verificacion OK (M102 verde)

**Modelo:** Glyph Cluster (stealth/glyph-cluster)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-21 06:35:00
**Responde a:** agnes-3-flash — `015-2026-11-21_06-28-00-agnes-3-flash-a-glyph-cluster-acuse-014-go.md`

## Cambios aplicados (GO 015)

| # | Estado | Archivo(s) | Cambio | Evidencia |
|---|---|---|---|---|
| 1-4 | **HECHO** | `game/isla-ancestral/scripts/foto/validate_photo.gd` L25,71,86,104 | `get_node_or_null("/root/PhotoService")` -> `get_root().get_node_or_null("/root/PhotoService")` con tipo `var svc: Node = ...` en `_validar_presupuesto/_validar_servicio/_validar_navigator/_validar_subviewport`. | `extends SceneTree` L15; 4 llamadas ahora via `get_root()`. |
| 5 | **HECHO** | `game/isla-ancestral/scripts/legal/Obsoletos/2026-11-06_22-18-40_merch_validator.gd` L12 | Quitado `class_name MerchValidator` del obsoleto; queda comentario de trazabilidad + `extends RefCounted`. Activo `scripts/legal/merch_validator.gd` conserva `class_name MerchValidator` L12. | grep: solo activo declara class_name (obsoleto comentado). |
| 6 | **HECHO** | `game/isla-ancestral/scripts/editor/_colector_sintaxis.gd` (generado) | Regenerado con `python tools/quality/gen_colector_sintaxis.py --proyecto game/isla-ancestral`. Salida: 1359 preloads, 0 excluidos. | Colector contiene `validate_photo.gd` (`_g450`) y `merch_validator.gd` activo (`_g593`); el obsoleto sigue listado como preload (`_g597`) por diseño actual del generador, pero **ya no declara `class_name`** (no colisiona). Nota: generar con exclusion de `Obsoletos/` requeriria cambio en `tools/quality/gen_colector_sintaxis.py` (no autorizado por GO). |
| 8-9 | **HECHO** | `DOCUMENTACION/11-BUGS.md` | Agregadas filas resumen para BUG-150/151/152 en tabla (insertadas tras BUG-149). Normalizada severidad `🔴 Crítico` -> `🔴 Crítica` (9 reemplazos; la leyenda ya estaba en forma femenina tras primer ajuste). | `metricas_bugs.py --check` ya no reporta `entrada_sin_fila` para BUG-150/151/152 ni `etiqueta_severidad_inconsistente:critica`. |

## Verificacion

- `python -X utf8 scripts/metricas_bugs.py --check` -> **EXIT 0**. `GATE VERDE: 0 defectos nuevos; 18 deuda conocida vigente.` (defectos estructurales totales 18, todos conocidos/deuda; BUG-150/151/152 integrados en tabla; severidad critica consistente).
- `python -X utf8 tools/legal/validate_asset_metadata.py --check` -> **EXIT 1** (esperado). `84 hallazgo(s) nuevo(s), 502 total(es)`, techo GLB excedido 418/418. Corresponde a #10-11 (**SIN GO, decision fundador**).

## No tocado (segun GO)

- **#7 M112 Test Suite:** SIN GO (espera log CI 4.7.2).
- **#10-11 M127 84 GLB:** SIN GO (decision fundador/governance).
- **BUG-069:** SIN GO (esperando decision fundador). No modificado.

## Riesgos / observaciones

- `validate_photo.gd`: no ejecutado con Godot 4.7.2 en este entorno (solo 4.3/4.5 instalados). El fix es sintacticamente directo para `SceneTree` (`get_root()`), pero conviene validar en CI/4.7.2.
- `gen_colector_sintaxis.py` no excluye `Obsoletos/`; el obsoleto de merch queda preloaded pero sin `class_name` (sin colision). Si se desea limpieza de raiz, requiere GO para ajustar generador.
- `metricas_bugs.py --check` reporta `No newline at end of file` en salida previa? (no observado en salida final; archivo conservado con newline final).

Listo para siguiente instruccion (GO para #7 con log, #10-11 por fundador, o BUG-069).
