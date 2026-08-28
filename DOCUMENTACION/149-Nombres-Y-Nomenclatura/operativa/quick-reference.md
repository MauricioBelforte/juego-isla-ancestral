**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 149-Nombres-Y-Nomenclatura
**Estado:** Implementación operativa (entregable M149)

---

# Referencia Rápida (`quick-reference`) — Módulo 149

> Cheatsheet de 1 página (versionado, imprimible desde aquí). Detalles en `code-conventions.md`, `npc-names.md`, `place-names.md`.

## 1. Tabla visual de convenciones

| Qué | Convención | Ejemplo |
|---|---|---|
| Clase | `PascalCase` | `class_name CameraRig` |
| Archivo .gd | `snake_case.gd` | `camera_rig.gd` |
| Señal | `snake_case` | `signal mode_changed()` |
| Var privada | `_snake_case` | `_zoom_level` |
| Constante | `UPPER_SNAKE` | `MAX_SALDO` |
| Autoload | `PascalCase` sin class_name | `Inventario` |
| Escena entidad | `PascalCase.tscn` | `Player.tscn` |
| Test / preview | `test_*` / `preview_*` | `test_arquitectura.tscn` |
| Recurso/datos | `snake_case.tres` | `econ_prices.tres` |
| Ítem (ID) | `item_<cat3>_<sub3>_<NNN>` | `item_ore_cop_002` |
| NPC (nombre) | `Nombre + Epíteto` | `Catalina Oso` |
| Lugar | 2-4 palabras evocadoras | `Templo de la Brisa` |

## 2. Ejemplos copiables

```gdscript
class_name VillagerProfile
extends Resource
## Perfil de vecino. Dueño: M19.

signal mood_changed(new_mood: int)

const MAX_AMISTAD := 5

var nombre_artístico := "Catalina Oso"   # nunca se traduce
var _mood_interno := 0
```

```
data/items/item_ore_cop_002.tres
scenes/Player.tscn
scripts/saving/save_writer.gd
```

## 3. Checklist del developer (antes de commitear)

- [ ] ¿El archivo sigue su convención (.gd snake, .tscn Pascal para entidades)?
- [ ] ¿Las señales son snake_case?
- [ ] ¿Ningún backup con fecha quedó dentro de scripts/scenes?
- [ ] ¿Los IDs nuevos siguen el patrón y no reutilizan números?
- [ ] ¿Los nombres artísticos (NPC/lugares) están adoptados en el canon (M147/M161/M160)?
- [ ] ¿Pasó el validador? → `python DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/validar_nombres.py`

## 4. NO hacer (top 5)

1. ❌ `signal PlayerHit()` → ✅ `signal player_hit()`
2. ❌ `class_name` en un autoload (rompe Godot 4.x — 07 §9.17)
3. ❌ Renombrar IDs de ítems ya usados en saves (son eternos)
4. ❌ Backups con fecha dentro de `scripts/`/`scenes/` → usar `Obsoletos/`
5. ❌ Inventar nombres artísticos de NPC/lugares sin registrarlos en el canon

## 5. Integración con M111 (Código de Calidad)

- Este módulo aporta las **reglas**; M111 (en curso) las integra en su linter/pre-commit.
- El validador de naming de este módulo (`validar_nombres.py`) es ejecutable por consola y puede ser invocado por el CodeQualityCheck de M111 cuando exista.

## 5. Templates de escena y recurso

**Escena de entidad (PascalCase.tscn):**
```
Player.tscn
└── Player (CharacterBody3D)          # raíz = nombre PascalCase
    ├── CollisionShape3D
    ├── Visual (Node3D)               # modelos/animaciones
    └── CameraRig (instanciada)
```

**Recurso de datos (.tres):**
```
[gd_resource type="ItemData" format=3]
[resource]
id = "item_ore_cop_002"        # ID eterno, patrón M159
display_name = "Mineral de Cobre"   # nombre artístico traducible
categoria = 2
```

## 6. Snippets para IDE

Guardar como `gdscript-naming.code-snippets` (VS Code/Cursor):
```json
{
  "Señal cozy": { "prefix": "sig", "body": "signal ${1:evento_ocurrido}(${2:valor: int})" },
  "Constante": { "prefix": "const", "body": "const ${1:MAX_VALOR} := ${2:10}" },
  "Var privada": { "prefix": "pvar", "body": "var _${1:estado_interno}: ${2:int} = ${3:0}" }
}
```

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
