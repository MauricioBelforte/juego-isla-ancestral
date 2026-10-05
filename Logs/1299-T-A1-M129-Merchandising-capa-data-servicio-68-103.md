# Log 1299: T-A1 M129-Merchandising — capa data+servicio, 68→103/108

**Fecha:** 2026-10-04
**Hora:** 22:53
**Modelo:** agnes-3.0-flash
**Plataforma:** Kilo Code

## Resumen

T-A1 (canal `agnes-3-flash` arch. 28/30) avance del módulo **M129-Merchandising** de
`68/108 → 103/108` (40 `[ ]` resueltos: **35 `[x]` + 5 `[?]`** con dueño externo). Cerré la
brecha que Hy3 marcó en su QA ("capa de servicio/docs NO"): implementé la **capa de datos
data-driven + la capa de servicio** y la **doc de catálogo**, todo verificable headless.

## Cambios Realizados

### 1. Capa de datos — `data/legal/merchandising.json` (v1 → v2)
- 4 productos esqueléticos → **10 productos** con specs estructuradas: `materiales`,
  `tamanos`, `colores`, `precio_usd [min,max]`, `margen [min,max]`, `produccion`,
  `calidad []`, `seguridad []` (juguetes), `formatos []`, `paginas []`.
- `politicas` enriquecido: `margen_objetivo [0.40,0.50]`, `requisito_seguridad_juguetes`
  (CE, ASTM-F963), `margen_por_tipo` (textil/cerámica/impreso/audio/juguete/coleccionable/físico).
- Los valores de spec (materiales, tallas, colores, precios, márgenes) son los **ya declarados
  en el propio checklist** — los codifiqué como datos; no inventé decisiones de diseño.

### 2. Capa de servicio — `scripts/legal/merch_manager.gd` (nuevo)
- `MerchManager` (autoload) carga el catálogo en `_ready()`, expone
  `get_productos / get_product(id) / get_product_ids / get_margen(id) / get_precio_usd(id) /
  get_politicas / validar / esta_cargado`.
- Se registra en `ServiceRegistry` como contrato `"merch"` (patrón de `DataStore`, con guard
  si el registro no está disponible). `cargar()` público para tests headless (`-s`, donde los
  autoloads no se instancian).
- Cableado en `project.godot [autoload]` (`MerchManager="*res://scripts/legal/merch_manager.gd"`).

### 3. Validador v2 — `scripts/legal/merch_validator.gd`
- Validado data-driven: tipo (enum de 7 tipos), `precio_usd` (min>0, min<=max), `margen` en
  [0,1] y min<=max, listas de spec no vacías. Backward-compatible (campiones opcionales).
- Corregido el **warning-tras-error** del proyecto: `:=` infería Variant (`.get()`) → tipo
  explícito `: Variant` + casts `as Dictionary`.

### 4. Test headless — `scripts/legal/test_merch_m129.gd` (8 → 24 checks)
- Cubre datos v2 (version=2, 10 productos, politicas), validator (0 errores real + errores
  detectados), rangos margen/precio, y MerchManager (cargar/get_product/get_margen/
  get_precio_usd/validar/esta_cargado/get_politicas). **24/0, EXIT 0** binario Godot 4.7.2 real.
- Carga full-scene headless (`--quit-after 5000`): `MerchManager listo (10 productos)` +
  `registrado como 'merch'`, 0 SCRIPT ERROR → **sin regresión de arranque**.

### 5. Doc — `DOCUMENTACION/129-Merchandising/plan-actual/merch_catalog.md` (nuevo)
- Fuente de verdad legible: tabla del catálogo (10 productos), criterios de calidad por
  producto, seguridad de juguetes (CE/ASTM), packaging/logística/optimización, guía de
  cuidado, y delegación de diseño artístico (M45/M46), música (M41) y tienda web (M53).

### 6. Checklist + GLOBAL
- `05-Checklist.md`: 35 items spec/quality/safety/optimization → `[x]` (con evidencia
  data-driven); 5 items de diseño artístico/música/web → `[?]` (dueño externo). Totales →
  `103/108 · 5 [?]`.
- `CHECKLIST-GLOBAL` fila 129: `68/108 → 103/108`, Última actividad 2026-10-05 01:45, nota T-A1
  en Notas (fila sigue a 11 celdas; estructura T-A3 intacta).

## Archivos Modificados/Creados
- `game/isla-ancestral/data/legal/merchandising.json` (v2)
- `game/isla-ancestral/scripts/legal/merch_manager.gd` (nuevo)
- `game/isla-ancestral/scripts/legal/merch_validator.gd` (v2)
- `game/isla-ancestral/scripts/legal/test_merch_m129.gd` (24 checks)
- `game/isla-ancestral/project.godot` (+1 autoload)
- `DOCUMENTACION/129-Merchandising/plan-actual/merch_catalog.md` (nuevo)
- `DOCUMENTACION/129-Merchandising/plan-actual/05-Checklist.md` (35 [x] + 5 [?] + Totales)
- `DOCUMENTACION/129-Merchandising/plan-actual/04-Codigo.md` (Notas del Agente §6 T-A1)
- `CHECKLIST-GLOBAL.md` (fila 129)
- `Logs/NUMEROS_DISPONIBLES.txt` (consumido 1299)

## Trampas / notas
- `class_name MerchManager` **chocó con el autoload homónimo** (warning → error): se eliminó el
  `class_name`; el autoload ya provee el global.
- JSON de Godot parsea números como **float** (30 → 30.0): el test compara rangos con float.
- El `-s` (SceneTree) no resuelve `class_name` ni instancia autoloads → `MerchManager` se prueba
  con `preload(...).new()` + `cargar()`.

## Verificación
- `godot --headless -s test_merch_m129.gd` → **24 checks, 0 fallos, EXIT 0**.
- `godot --headless --quit-after 5000` → arranque limpio, MerchManager registrado, 0 errores.
- GLOBAL estructural: `t_a3_fix2.py` → 0 filas por tocar, 167/167 = 11 celdas.
