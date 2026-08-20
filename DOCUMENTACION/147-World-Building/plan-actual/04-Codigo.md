**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 147: World Building

## 1. Archivos Involucrados

| Archivo | Tipo | Propósito |
|---|---|---|
| `world_bible/00-indice.md` | Datos | Índice y reglas de la biblia |
| `world_bible/01-linea-de-tiempo.md` | Datos | Cronología canónica (RF) |
| `world_bible/02-aurora.md` | Datos | Historia de Aurora (RF2) |
| `world_bible/03-islas.md` | Datos | Historias por isla (RF3) |
| `world_bible/04-arquitectos-del-alba.md` | Datos | Civilización constructora (RF4) |
| `world_bible/05-primeros-jardineros.md` | Datos | Civilización botánica (RF5) |
| `world_bible/06-la-resonancia.md` | Datos | Fenómeno central (RF6) |
| `world_bible/07-elisia.md` | Datos | Misterio con capas (RF7) |
| `world_bible/08-personajes/{finneas,lia,bruno,nilo,vera,...}.md` | Datos | Biografías (RF8-RF13) |
| `world_bible/09..20-*.md` | Datos | Religiones, costumbres, arquitectura, símbolos, lenguaje, calendario, tecnología, economía, mapas, catástrofes, migraciones, leyendas (RF14-RF25) |
| `world_bible/CHANGELOG.md` | Datos | Registro de cambios de canon |
| `world_data.json` | Datos | JSON técnico generado (RF26) |
| `scripts/world/sync_world_data.gd` | Tool | MD `DATA:` → JSON |
| `scripts/world/validate_world.gd` | Tool | Consistencia y referencias |
| `scripts/world/world.gd` | Autoload | Acceso runtime solo lectura |
| `tests/world/test_world.gd` | Test | Suite de tests del canon |

## 2. Funciones Clave

### 2.1 `world.gd` (autoload)

```gdscript
extends Node
## Acceso al canon del mundo. Carga única, solo lectura.

signal canon_changed(version: String)

var _data: Dictionary = {}
var canon_version: String = "0.0.0"

func _ready() -> void:
    load_canon()

func load_canon() -> void:
    var f := FileAccess.open("res://data/world_data.json", FileAccess.READ)
    if f == null:
        push_error("World: no se pudo cargar world_data.json")
        return
    _data = JSON.parse_string(f.get_as_text())
    canon_version = _data.get("canon_version", "0.0.0")

func get_personaje(id: String) -> Dictionary:
    return _data.get("personajes", {}).get(id, {})

func get_lugar(id: String) -> Dictionary:
    return _data.get("lugares", {}).get(id, {})

func get_simbolo(id: String) -> Dictionary:
    return _data.get("simbolos", {}).get(id, {})

func get_capa_minima(ids: Array) -> int:
    ## Mayor capa requerida por los ids pedidos (para filtrar contenido).
    var max_capa: int = 0
    for id in ids:
        for grupo in ["personajes", "lugares", "eventos", "leyendas"]:
            var e: Dictionary = _data[grupo].get(id, {})
            max_capa = max(max_capa, int(e.get("capa", 0)))
    return max_capa
```

### 2.2 `validate_world.gd` (reglas clave)

```gdscript
extends RefCounted
## Valida consistencia del canon.

static func check_all(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    errors.append_array(check_ids(data))
    errors.append_array(check_linea_tiempo(data))
    errors.append_array(check_capas(data))
    errors.append_array(check_modulos(data))
    return errors

static func check_ids(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    var todos: Dictionary = {}
    for grupo in ["personajes", "lugares", "simbolos", "eventos", "leyendas"]:
        for id: String in data.get(grupo, {}):
            if todos.has(id):
                errors.append("ID duplicado: %s (grupos %s y %s)" % [id, todos[id], grupo])
            todos[id] = grupo
    return errors

static func check_linea_tiempo(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    var eventos: Array = data.get("linea_tiempo", [])
    var prev_anio: int = -999999
    for e in eventos:
        var anio: int = int(e.get("anio_antiguo", e.get("anio_actual", -999999)))
        if anio < prev_anio:
            errors.append("LÍNEA DE TIEMPO fuera de orden: %s" % e.get("evento"))
        prev_anio = anio
    return errors

static func check_capas(data: Dictionary) -> Array[String]:
    ## Capa 4 (Elysia/verdad) solo consumida por M153 (Sellos).
    var errors: Array[String] = []
    for grupo in ["personajes", "lugares", "eventos", "leyendas"]:
        for id: String in data.get(grupo, {}):
            var e: Dictionary = data[grupo][id]
            if int(e.get("capa", 0)) >= 4:
                var consumidores: Array = e.get("consumido_por", [])
                if not consumidores.has("M153") and not consumidores.has("M148"):
                    errors.append("CAPA 4 %s.%s sin consumidor M153/M148: %s" % [grupo, id, consumidores])
    return errors
```

### 2.3 `sync_world_data.gd` (esqueleto)

```gdscript
extends SceneTree
## Regenera world_data.json desde world_bible/*.md (bloques DATA:).
## Uso: godot --headless -s scripts/world/sync_world_data.gd

func _init() -> void:
    var canon: Dictionary = {}
    var dir := DirAccess.open("res://world_bible/")
    for file: String in dir.get_files():
        if not file.ends_with(".md"):
            continue
        var texto: String = FileAccess.get_file_as_string("res://world_bible/" + file)
        for m in RegEx.create_from_string(r"## DATA \{([^}]*)\}").search_all(texto):
            var raw: Dictionary = JSON.parse_string("{" + m.get_string(1) + "}")
            canon = _merge_entry(canon, raw)
    var out := FileAccess.open("res://data/world_data.json", FileAccess.WRITE)
    out.store_string(JSON.stringify(canon, "\t"))
    print("WORLD sync OK")
    quit(0)
```

## 3. Logs Relacionados

| Mensaje | Nivel | Cuándo |
|---|---|---|
| `WORLD canon vX.Y.Z cargado (N personajes, M lugares)` | info | Carga única |
| `WORLD referencia rota: {id}` | error | Validación |
| `WORLD capa 4 expuesta por {modulo}` | warning | Debug (evita spoilers) |
| `WORLD validate falló: {N} errores` | error | CI/editor |
| `WORLD canon desincronizado: {doc}` | error | MD vs JSON (sync) |

## 4. Cambios de Canon (Ejemplos)

| Cambio | Archivo(s) | Validación |
|---|---|---|
| Renombrar un NPC (M149) | `08-personajes/*.md` + referencias | validate (ids rotos) |
| Añadir una leyenda | `20-leyendas.md` | validate (verdad_parcial) + sync |
| Mover el Sello del Alba a capa 4 | `07-elisia.md` | validate (consumidores M153) |
| Nueva isla en el roadmap (M136) | `03-islas.md` | validate + M27 |
| Ajustar fecha de la Gran Calma | `01-linea-de-tiempo.md` | validate (orden cronológico) |

## 5. Tests (M112)

- `test_world.gd`: carga del JSON, ids únicos, orden cronológico, capas correctas, sincronía MD↔JSON, nombres propios duplicados.
- Ejecución: `godot --headless -s res://tests/world/run_tests.gd`.

## 6. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-19 04:23
**Estado:** Documentación completa

### Lo que hice
- Documenté el módulo World Building completo (5 archivos, plan-inicial y plan-actual idénticos al inicio).
- Checklist de 130 ítems verificables, derivados de la sección 146 del plan maestro (24 ítems) + pensamiento propio alineado a M22/M153/M148/M152.
- Diseñé la biblia dual (MD editorial + JSON técnico sincronizado), modelo de capas de revelación y validador de consistencia.

### Lo que NO pude hacer
- Ningún ítem quedó `[?]`: la documentación es diseño a implementar; los textos narrativos finales corresponden a la biblia del usuario (GDD) y a M149/M21.

### Recomendaciones para el próximo agente
- Antes de implementar, consolidar con el usuario el canon de los nombres (M149) para no trabajar con ids provisionales.
- M148 (Lore Ambiental) debe consumir `world_data.json` para sus murales/texturas.
- El gate CI (M118) debe correr `validate_world.gd` en cada PR que toque `world_bible/`.