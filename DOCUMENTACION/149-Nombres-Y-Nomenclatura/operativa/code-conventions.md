**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 149-Nombres-Y-Nomenclatura
**Estado:** Implementación operativa (entregable M149)

---

# Convenciones de Código (`code-conventions`) — Módulo 149

> **Autoridad:** las convenciones de GDScript del proyecto son de **M05** y **`07-GUIA-GODOT.md`** (§1.1 y tabla de naming). Este documento las resume como referencia de naming y añade las convenciones de **IDs de datos** y **tags**, que no estaban cubiertas. Si hay conflicto, manda 07-GUIA-GODOT.

## 1. Tabla de naming GDScript (resumen de 07-GUIA-GODOT)

| Elemento | Convención | Ejemplos reales del proyecto |
|---|---|---|
| Clase (`class_name`) | PascalCase | `CameraRig`, `PlayerController` |
| Script (archivo) | snake_case.gd | `camera_rig.gd`, `item_database.gd`, `event_bus.gd` |
| Señal | **snake_case** (corregido: el checklist original decía PascalCase; 07-GUIA-GODOT §1.1 manda snake_case) | `mode_changed`, `settings_changed` |
| Variable | snake_case | `speed`, `current_block` |
| Variable privada | `_snake_case` | `_current_mode`, `_zoom_level` |
| Constante | UPPER_SNAKE_CASE | `MAX_SALDO`, `TICK_SECONDS` |
| Enum | PascalCase (miembros UPPER_SNAKE) | `enum Estado {IDLE, MOVING}` |
| Función | snake_case (+ `_ready`, `_process` de Godot) | `try_extract()`, `avanzar_hasta()` |
| Nodo | PascalCase | `CameraRig`, `VoxelTerrain` |
| Autoload | PascalCase, **sin `class_name`** (07 §9.17) | `Inventario`, `ShopManager`, `TimeCalendar`, `SoftlockGuard` |

Ejemplo correcto vs incorrecto (señales — error real documentado en 07 §9.1):
```gdscript
signal OnPlayerHit()          # ❌ PascalCase
signal on_player_hit(damage: int)  # ✅ snake_case + tipado
```

## 2. Convenciones de archivos y carpetas (verificadas contra el código real 2026-08-28)

| Tipo | Convención | Ejemplos reales |
|---|---|---|
| Scripts | snake_case.gd | `player.gd`, `shop_manager.gd`, `w_reloj.gd` (widget: prefijo `w_`) |
| **Tests** | `test_<tema>.gd/.tscn` | `test_arquitectura.gd`, `validate_save.gd` |
| **Previews** | `preview_<sistema>.gd/.tscn` | `preview_reloj.gd`, `preview_herramientas.tscn` |
| Escenas | **PascalCase.tscn** para entidades; snake_case aceptado en previews/tests y escenas main históricas | `Player.tscn`, `CameraRig.tscn` ✓ · `villager.tscn` ⚠️ (legacy a corregir por M04/M53) |
| Recursos `.tres` | snake_case | `econ_prices.tres`, `copper_ore.tres` |
| Materiales | snake_case.tres | `mat_agua.tres` (propuesto) |
| Shaders | snake_case.gdshader | `agua.gdshader` (propuesto) |
| Datos JSON | snake_case.json | `dialogos_finneas.json` (propuesto, M21) |
| Texturas | snake_case.png | `icono_cora_001.png` (propuesto) |
| Audio | snake_case + sufijo de tipo | `sfx_pop_corto.wav`, `mus_calma_capa1.ogg` (propuesto; patrón M41/M42) |
| Modelos | PascalCase.glb | `CatalinaOso.glb` (propuesto; entidades con mayúscula) |
| Animaciones | PascalCase.anim | `Caminar.anim` (propuesto) |
| Diálogos | snake_case de NPC + tema | `dialogo_finneas_intro.tres` (propuesto; el checklist original sugería PascalCase_Dialogo — se simplifica a snake_case coherente con recursos) |

**Archivos/carpetas (reglas de estructura):**
- Carpetas: minúsculas con `_` (`scripts/saving/`, `scripts/ui/core/`).
- Prohibido dejar **backups con fecha dentro del árbol de scripts**: hallazgo 2026-08-28 — existen `2026-08-26_19-35-00_w_reloj.gd` y `2026-08-26_19-20-00_bootstrap.gd` en `scripts/`; deben migrar a `Obsoletos/` (regla §5 de AGENTS.md). Reportado a M111/M04.
- Un script = una clase; el nombre del archivo = nombre de la clase en snake_case (excepción: autoloads sin class_name, 07 §9.17).

## 3. IDs de datos (nuevo, patrón real M159)

Patrón de ítems (real: `item_obj_pla_001.tres`):
```
item_<cat3>_<sub3>_<NNN>.tres     ej: item_obj_pla_001, item_ore_cop_002
```
- `<cat3>`: 3 letras de categoría (`obj` objetivo, `ore` mineral, `pln` planta, `fsh` pez, `tld` herramienta…).
- `<sub3>`: subtipo/material (3 letras).
- `<NNN>`: correlativo 3 dígitos. **Los IDs son eternos**: nunca se reutilizan ni renumeran; el nombre artístico vive en el `.tres` (propiedad display_name).

POIs (propuesto para M160/M109): `poi_<isla3>_<NNN>` → `poi_aur_014`.
Diálogos (propuesto M21): `dlg_<npc3>_<tema3>_<NNN>`.

## 4. Tags y categorías (grupos de Godot)

- Grupos en snake_case con prefijo de dominio: `npc_`, `player_`, `ui_`, `save_`, `interact_`.
- Ejemplos: `interact_clickable`, `save_provider`, `npc_dialogable`.
- Regla: un nodo pertenece a ≤ 3 grupos; el grupo siempre describe rol, no tipo de script.

## 5. Template de script estándar (cabecera)

```gdscript
class_name MiClase
extends Node3D
## Descripción en una línea. Dueño: módulo M{NN}.

signal accion_realizada(id: int)   # snake_case, tipada

const MAX_INTENTOS := 3

var estado_actual: String = "idle"
var _contador := 0
```

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
