# Reporte de Auditoria de Contadores — Coleccionables (M73)

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-13
**Alcance:** `game/isla-ancestral/scripts/coleccionables/` (catalog, manager, item, category, validator). Excluye reportes previos (contadores 07-nov, economia/progresion 13-nov).

## Resumen ejecutivo

Se detectaron 8 hallazgos nuevos en los contadores de coleccionables, incluyendo un bug de desincronizacion critico en la restauracion de partida (claves String vs StringName) y un contador que se incrementa para ids inexistentes. Se proponen 2 mejoras de diseno con codigo.

## Hallazgos

### H1 (Alta) — `registrar()` infla `_categoria_collected` para ids inexistentes y categorias fantasma

`coleccionables_manager.gd:60-78`: tras el check de idempotencia, `_collected[id_global] = true` y `_categoria_collected[cat] += 1` se ejecutan sin validar que `id_global` exista en el catalogo. Ademas, `cat` se deriva con `id_global.split("_")[0]` (`coleccionables_manager.gd:70`), que asume categoria de una sola palabra y rompe para `objetos_historia_004` (cat = `"objetos"` en lugar de `"objetos_historia"`), creando una categoria fantasma y no incrementando la real.

### H2 (Critica) — `restore_save_data()` desincroniza por tipo de clave (String vs StringName)

`coleccionables_manager.gd:156-168`: `_collected` se restaura con conversion `StringName(k)` (linea 162, correcto), pero `_categoria_collected` se restaura con `k` tal cual viene del JSON (String) (linea 167), mientras que las claves en memoria son StringName (inicializadas en `_ready`, linea 42-43). Como `collected_count()` consulta con StringName (`coleccionables_manager.gd:107-108`), despues de cargar partida devuelve 0 para todas las categorias aunque `_collected` tenga items. Progreso/UI quedan en 0 tras cargar.

### H3 (Alta) — `restore_save_data()` no limpia `_categoria_collected` antes de restaurar

`coleccionables_manager.gd:159-167`: se limpia `_collected` pero no `_categoria_collected`. Las claves StringName previas (valor 0) conviven con las claves String nuevas; ademas categorias eliminadas del catalogo conservan conteo stale. No hay reconciliacion.

### H4 (Media) — `porcentaje_categoria()` y `porcentaje_total()` sin clamp; pueden superar 1.0

`coleccionables_manager.gd:115-119` y `122-130`: si `_categoria_collected` se infla (H1/H2), el porcentaje supera 1.0. `porcentaje_total()` ademas solo itera `_categoria_total.keys()` (`coleccionables_manager.gd:125`), ignorando conteos de categorias fantasma, generando totales inconsistentes con `collected_count()`.

### H5 (Media) — señal `categoria_progress_changed` declarada pero nunca emitida

`coleccionables_manager.gd:23`: la senal existe pero no se emite en ninguna parte del archivo (verificado por grep). Suscriptores de progreso de categoria nunca reciben actualizaciones en tiempo real.

### H6 (Media) — `validate_collectibles.validar()` cuenta entradas invalidas en `total`

`validate_collectibles.gd:44-90`: `total += 1` se ejecuta para cada entrada antes de validar campos. Si hubiera items invalidos, el total del validador superaria `catalog.cantidad_total()` (que solo cuenta validos en `coleccionables_catalog.gd:24-33`). Drift entre validador y runtime.

### H7 (Baja) — `CollectibleCategory.esta_completa()` retorna true con collected > total

`collectible_category.gd:52-56`: `collected_count >= total_esperado` es true aunque collected supere el total, enmascarando inflacion de contador. El test `test_collectible_category.gd` lo afirma explicitamente (`esta_completa(10) == true` con total 5).

### H8 (Baja) — `_on_especie_avistada()` mapea varias especies al mismo slot sin documentar

`coleccionables_manager.gd:175-183`: `lechuza_bosque`, `nutria_ribera` y `halcon_montana` mapean a `"003"`; `cangrejo_humedal` mapea a `"001"` (slot de conejo). Atribucion incorrecta de coleccionables; puede alterar el conteo de especies "vistas" vs "coleccionadas".

## Verificacion cruzada ausente

No existe funcion para recalcular `_categoria_collected` desde `_collected` consultando el catalogo. La unica fuente de verdad (`_collected`) no se usa para derivar los contadores agregados; por eso el drift es indetectable en runtime.

## Mejoras de diseno (con codigo)

### Mejora 1 — Reconciliacion automatica en restore y en `_ready`

```gdscript
func _reconciliar_contadores() -> void:
    _categoria_collected.clear()
    for cat in _categoria_total.keys():
        _categoria_collected[cat] = 0
    for id in _collected.keys():
        var it = catalog.obtener(id) if catalog != null else null
        var cat: StringName = (it.categoria if it != null else _categoria_de_id(id))
        if not _categoria_total.has(cat):
            _categoria_total[cat] = 0  # categoria desconocida, no inflar total
        if _categoria_collected.has(cat):
            _categoria_collected[cat] = int(_categoria_collected[cat]) + 1
    # clamp defensivo
    for cat in _categoria_collected.keys():
        if _categoria_total.has(cat) and int(_categoria_collected[cat]) > int(_categoria_total[cat]):
            _categoria_collected[cat] = int(_categoria_total[cat])

func _categoria_de_id(id_global: StringName) -> StringName:
    # soporta categorias multi-palabra (objetos_historia)
    var s := String(id_global)
    var idx := s.rfind("_")
    return StringName(s.substr(0, idx)) if idx > 0 else StringName(s)

func restore_save_data(data: Dictionary) -> void:
    if int(data.get("version", 0)) < VERSION:
        return
    _collected.clear()
    for k in data.get("collected", {}).keys():
        _collected[StringName(k)] = true
    _reconciliar_contadores()

func _ready() -> void:
    catalog = CatalogRef.new()
    catalog.cargar()
    for cat in catalog.todas_las_categorias():
        _categoria_total[cat] = catalog.cantidad_por_categoria(cat)
        _categoria_collected[cat] = 0
    _reconciliar_contadores()  # idempotente en arranque
```

### Mejora 2 — Validacion de entrada en `registrar()` + emision de progreso

```gdscript
func registrar(id_global: StringName) -> bool:
    if id_global == &"":
        return false
    if _collected.has(id_global):
        return false
    # validar contra catalogo para evitar contadores fantasma
    var it: Resource = null
    if catalog != null:
        it = catalog.obtener(id_global)
    if it == null:
        push_warning("[M73] registrar id desconocido ignorado: %s" % String(id_global))
        return false
    _collected[id_global] = true
    var cat: StringName = it.categoria
    if not _categoria_total.has(cat):
        _categoria_total[cat] = 0
    var nuevo := int(_categoria_collected.get(cat, 0)) + 1
    if _categoria_total.has(cat) and _categoria_total[cat] > 0:
        nuevo = mini(nuevo, int(_categoria_total[cat]))
    _categoria_collected[cat] = nuevo
    item_collected.emit(id_global, it)
    categoria_progress_changed.emit(cat, nuevo, int(_categoria_total.get(cat, 0)))
    if _categoria_completa(cat):
        _on_categoria_completa(cat)
    return true
```

## Conclusion

Los contadores de coleccionables presentan drift por tipo de clave en persistencia (critico), inflacion por ids no validados y categorias fantasma por split de una palabra. La reconciliacion desde `_collected` y la validacion de entrada en `registrar()` eliminan la clase de bugs. Se recomienda tambien emitir `categoria_progress_changed` en cada registro para mantener la UI sincronizada.
