**Modelo:** deepseek-v4-flash (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 (implementación iter. 1 núcleo; diseño original Unity/C# por Deepseek V4 Flash / OpenCode 2026-08-20)

# 04-Codigo.md — Módulo 96: Plataformas

## 1. Archivos involucrados (REAL — Godot 4.7 / GDScript)

### 1.1 Nuevos (`game/isla-ancestral/scripts/plataformas/`)
| Archivo | Propósito |
|---------|-----------|
| `iplatform_bridge.gd` | `IPlatformBridge` (base): interfaz común — desbloquear_logro, cloud_disponible, guardar/cargar_cloud, mostrar_overlay, guardar/cargar_save_cloud (cross-save) |
| `null_bridge.gd` | `NullBridge`: fallback de desarrollo (sin cloud, sin logros, no-op) |
| `steam_bridge.gd` | `SteamBridge` (MOCK): contrato Steamworks con cloud simulada en disco, logros stub (SDK real pendiente M149) |
| `platform_manager.gd` | Autoload `PlatformManager`: selecciona el bridge activo, expone servicios unificados, carga matriz data-driven |
| `test_plataformas_m96.gd` | Test headless (23/0 OK) |
| `data/plataformas/plataformas.json` | Matriz data-driven: 10 plataformas × 20 puntos (prioridad, orden, tienda, logros, cloud, overlay, controller, cross_save, deck_verified, coste_devkit, fee, nota) |

### 1.2 Modificado
| Archivo | Cambio |
|---------|--------|
| `project.godot` | Autoload `PlatformManager="*res://scripts/plataformas/platform_manager.gd"` |

### 1.3 Diferencias vs diseño original (Unity/C#)
- `IPlatformBridge.cs` → `iplatform_bridge.gd` (RefCounted base, métodos virtuales)
- `NullBridge.cs` / `SteamBridge.cs` → `null_bridge.gd` / `steam_bridge.gd` (GDScript)
- `PlatformManager.cs` → `platform_manager.gd` (autoload, sin class_name §9.17)
- `plataformas.json` de M96 → implementado como data-driven en `data/plataformas/`
- `steamdeck_check.py`, `build_targets.ps1` → pendientes (CI, M149)

## 2. API pública

### 2.1 `platform_manager.gd` — autoload
```gdscript
bridge: IPlatformBridge          # bridge activo (NullBridge en dev)
matriz: Dictionary               # data-driven desde JSON

desbloquear_logro(id)
cloud_disponible() -> bool
guardar_save_cloud(ruta_local) -> bool
cargar_save_cloud(ruta_local) -> bool
mostrar_overlay()
obtener_plataforma(id) -> Dictionary
plataformas_por_prioridad(p) -> Array    # ordenado por lanzamiento
ids_plataformas() -> Array
```

### 2.2 `iplatform_bridge.gd` — IPlatformBridge (base)
```gdscript
var nombre: String
desbloquear_logro(id)          # mapeo M59
cloud_disponible() -> bool
guardar_cloud(data) -> bool
cargar_cloud() -> PackedByteArray
mostrar_overlay()
guardar_save_cloud(ruta) -> bool   # cross-save (RF13)
cargar_save_cloud(ruta) -> bool
```

## 3. Verificación
- Test M96: `Godot --headless --path game/isla-ancestral --script res://scripts/plataformas/test_plataformas_m96.gd` → **23 checks, 0 fallos**.
- Regresión M60: **66/0 OK**.

## 4. Pendientes honestos (92 ítems de checklist)
- Bridges EOS/GOG/consolas (PlayStation/Xbox/Switch) — pendientes de SDKs reales (M149).
- SDK Steamworks real (el SteamBridge es MOCK con cloud simulada; SDK real en M149).
- CI multi-target (`build_targets.ps1`), steamdeck_check.py (800p + gamepad).
- Certificación por plataforma (M142), precios por tienda (M149).
- Detectores de plataforma real en runtime (OS.get_name + defines de build).

## Notas del Agente

**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Núcleo implementado (iter. 1), 🟡 liberado

### Lo que hice
- IPlatformBridge interfaz común (sin hardcode de SDKs en el core).
- NullBridge fallback dev + SteamBridge mock con cloud simulada y cross-save.
- PlatformManager autoload con API unificada (logros/cloud/overlay/cross-save).
- Matriz data-driven (10 plataformas × 20 pts, prioridades P0-P3).
- Test headless 23/0 OK + regresión M60 66/0 OK.

### Lo que NO pude hacer (honestidad obligatoria)
- [M] SDKs reales (Steamworks/EOS/GOG/consolas): requieren M149 (tiendas) y las APIs oficiales; SteamBridge es MOCK.
- [M] CI multi-target y steamdeck_check.py: requieren el pipeline CI (M112) y builds reales.
- [M] Certificación M142 y precios por tienda M149.

### Recomendaciones para el próximo agente
- Cuando M149 defina las tiendas, reemplazar el mock de SteamBridge por Steamworks real (mantener la interfaz).
- Conectar el cross-save de M60: en DataStore, al guardar llamar `PlatformManager.guardar_save_cloud(ruta)` si `cloud_disponible()`.
- Ejecutar `plataformas_por_prioridad("P0")` para el menú de lanzamiento (Steam + Deck primero).