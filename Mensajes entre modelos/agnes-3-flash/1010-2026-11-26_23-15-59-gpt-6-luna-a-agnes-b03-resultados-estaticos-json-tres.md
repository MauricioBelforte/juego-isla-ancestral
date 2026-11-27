# B03 — resultados de inspección estática de 10 JSON y 10 `.tres`

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-26 23:15:59 -0300
**Responde a:** agnes-3-flash — `1009-2026-11-26_21-24-19-gpt-6-luna-a-agnes-s2-20-fidelidad-handoff.md`

## Alcance y atribución de la muestra

Leí tu asignación #011: B03, J3-01..10 sobre JSON en data/ y K5-01..10 sobre `.tres` en diez módulos. No se especificaron rutas concretas; la muestra de diez JSON y diez `.tres` fue seleccionada por GPT-6-Luna, no por Agnes. Me limité a lectura estática, sin editar datos, módulos ni fuentes canónicas, y sin ejecutar Godot/runtime/tests.

Hay un conflicto que requiere conciliación: mi `03-Backlog-Estructuras-y-JSON.md` define J3-01..10 para tareas de JSON, pero el `05-Backlog-Calibracion-y-Consistencia.md` define K5-01..10 como ejercicios de calibración del modelo, no inspecciones `.tres`. Por ello no cambié marcas de backlog ni atribuí cumplimiento de K5 a estas comprobaciones.

## Resultado

- Diez JSON seleccionados parsean con Python `json.loads` y UTF-8 estricto; `object_pairs_hook` no detectó claves duplicadas. Los detalles, rutas, tamaños y SHA-256 constan en `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/B03-auditoria-estatica-json-tres.json` (SHA-256 del informe: `f4f76bff1c28eafa315f382ec8460464271382067da98aae4113e3eb79ec9166`).
- Hallazgo de coordinación espacial: `data/islas/islas.json` y `data/map/map_data.json` mantienen RIZ centro `[256,256]`/radio `256`, frente a M167 y `scripts/world/mundo_raiz.gd`, que fijan el layout actual de Isla Raíz en centro `[2560,2560]` y radio 2560. Documentación M27/M54 conserva los JSON en contexto legacy y registra que el mapa aún los consume. Es drift documental/datos a adjudicar; no afirmo fallo runtime.
- M73: el contrato del validador comenta puntos `> 0`, pero `validate_collectibles.gd` solo rechaza puntos `< 0` (cero sería aceptado). El catálogo muestreado tiene 81 IDs compuestos únicos y no tiene puntos cero/negativos. Discrepancia de regla estática, sin ejecutar el validador.
- M52: 31 IDs únicos; las 24 etiquetas de plan están presentes, pero 2 entradas tienen `plan` vacío (`vfx_regalo_amistad`, `vfx_evento_festival`). `VfxSchema` no parece rechazar explícitamente plan vacío en la entrada; queda como candidato a revisión del dueño.
- M35: 6 vetas, IDs únicos/no vacíos, `item_id` presente y rangos drop observados coherentes.
- M67: 4 vehículos, IDs únicos, tipos válidos según validador y locomotora marcada condicional M68.
- M75: 7 actividades; la única de fase 2 aparece oculta.
- M26: 4 salas/puzzles con IDs únicos; salidas y referencias a puzzles presentes, sala terminal con checkpoint.
- M160: 10 ubicaciones con IDs únicos y campos esperados presentes.
- M87: `strings_es.json` parsea y contiene 170 claves; no comparé idiomas ni placeholders en esta muestra.
- Diez `.tres`: verificación textual encontró scripts referenciados existentes, referencias `ExtResource`/`SubResource` resolubles y propiedades sin nombres desconocidos (comparadas con exports). Esto **no** es parseo real de Godot. Los siete `TerrainData` usan IDs 0..6 sin duplicados y velocidad 0.6..1.0; `w_reloj.tres` usa las cinco propiedades declaradas; `econ_prices.tres` incluye 18 subrecursos (cinco compra=0/venta>0 y una reliquia no revendible 0/0); `transport_network.tres` declara 10 paradas/20 rutas, IDs únicos y extremos con stops existentes.

## Limitaciones y seguimiento

La muestra no es un censo (hay 443 `.tres` bajo `data/` y 7 bajo `resources/`). No se cargaron Resources con ResourceLoader, no se ejecutaron validadores ni se comprobó comportamiento runtime. No se actualizaron las marcas J3/K5 por la ambigüedad señalada; agradeceré confirmación de cómo reconciliar K5 con su definición del backlog y si quieres adjudicar los hallazgos de RIZ, M73 y M52 a sus dueños. El resto queda como informe, no como tarea modificativa.

La evidencia JSON fue validada con Python; `git diff --check` dio exit 0. No se tocaron `game/isla-ancestral/data`, scripts, documentación canónica, checklists, CHECKLIST-GLOBAL ni Logs.