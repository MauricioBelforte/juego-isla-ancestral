**Modelo:** deepseek-v4-flash (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 (implementación iter. 1 núcleo; diseño original por Deepseek V4 Flash / OpenCode 2026-08-19)

# 04-Codigo.md — Módulo 147: World Building

## 1. Archivos involucrados (REAL — Godot 4.7 / GDScript)

### 1.1 Nuevos
| Archivo | Tipo | Propósito |
|---------|------|-----------|
| `data/world_data.json` | Datos | Canon data-driven: 6 personajes, 8 lugares, 4 sellos, 4 capas_por_sello, 5 épocas timeline, canon_version 1.0.0 |
| `scripts/world/world_bible.gd` | Autoload `WorldBible` | Acceso runtime solo lectura al canon: get_personaje/get_lugar/get_simbolo/get_capa_minima/linea_tiempo/version |
| `scripts/world/validate_world.gd` | `ValidateWorld` (static) | Consistencia: IDs únicos, canonRef de capas, sellos definidos, timeline ordenada, canon_version |
| `scripts/world/test_world_m147.gd` | Test headless | 23/0 OK |

### 1.2 Modificado
| Archivo | Cambio |
|---------|--------|
| `project.godot` | Autoload `WorldBible="*res://scripts/world/world_bible.gd"` |

### 1.3 Diferencias vs diseño original
- `sync_world_data.gd` (MD→JSON) NO implementado: el JSON se escribió manualmente con contenido canónico de ejemplo (6 personajes, 8 lugares); el sync automático desde `world_bible/*.md` queda pendiente.
- `world.gd` del diseño → `world_bible.gd` (autoload `WorldBible`, nombre más descriptivo).
- `tests/world/test_world.gd` → `test_world_m147.gd` (patrón headless del proyecto).

## 2. API pública

### 2.1 `world_bible.gd` — autoload WorldBible
```gdscript
signal canon_changed(version: String)
var canon_version: String = "1.0.0"

cargar_canon()
get_personaje(id) -> Dictionary
get_lugar(id) -> Dictionary
get_simbolo(id) -> Dictionary
get_capa_minima(ids: Array) -> int      # 0..4 según Sellos
linea_tiempo() -> Array
version() -> String
```

### 2.2 `validate_world.gd` — ValidateWorld (static)
```gdscript
validar(data: Dictionary) -> Array[String]   # errores (vacío = OK)
reporte(errores) -> String
```

## 3. Canon data-driven (world_data.json)
- **personajes**: finneas, lia, bruno, nilo, vera, orion (rol + isla + bio).
- **lugares**: 8 (faro, 4 templos, laguna, volcán, cúpula).
- **simbolos**: 4 sellos (marea, profundidades, llama, aurora).
- **capas_por_sello**: orden 1-4, cada sello revela personajes/lugares de su isla.
- **linea_tiempo**: 5 épocas (fundación → presente) con orden.

## 4. Verificación
- Test M147: `Godot --headless --path game/isla-ancestral --script res://scripts/world/test_world_m147.gd` → **23 checks, 0 fallos**.
- Regresión M60: **66/0 OK**.

## 5. Pendientes honestos (115 ítems de checklist)
- `sync_world_data.gd` (MD → JSON) + hash MD↔JSON (W).
- Contenido narrativo completo: biblia MD por sección (01-20), biografías detalladas, timeline completa, religiones, lenguaje, economía, catástrofes, leyendas.
- CHANGELOG de canon, gate CI por PR a `world_bible/` (M118).
- Consumo por M21 (diálogos), M25 (ruinas), M24/M26 (templos), M73 (coleccionables).

## Notas del Agente

**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Núcleo implementado (iter. 1), 🟡 liberado

### Lo que hice
- Canon data-driven en world_data.json con estructura completa (personajes/lugares/símbolos/capas/timeline).
- WorldBible autoload (solo lectura, canon_version, getters, capas por Sello).
- ValidateWorld con detección de errores (IDs, canonRef, sellos, timeline, versión).
- Test headless 23/0 OK + regresión M60 66/0 OK.

### Lo que NO pude hacer (honestidad obligatoria)
- [M] sync_world_data.gd (MD→JSON): el contenido de la biblia MD aún no existe en volumen; el JSON de ejemplo es la estructura canónica.
- [C] Contenido narrativo completo (20 secciones de biblia, biografías, leyendas): es contenido de escritura, no código.
- [M] Consumo por M21/M25/M24/M26/M73: hooks listos, dependen de esos módulos.

### Recomendaciones para el próximo agente
- Usar validate_world.gd como gate CI: fallar si `validar()` no está vacío al tocar world_data.json.
- Cuando M21 (diálogos) consuma el canon, usar get_capa_minima para que los NPC solo conozcan sus capas.
- El sync_world_data.gd debe regenerar el JSON desde los MD con hash MD↔JSON para detectar desincronización.