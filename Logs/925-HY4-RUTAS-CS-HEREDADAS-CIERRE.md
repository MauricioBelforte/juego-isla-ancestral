# Log 925: Cierre de las rutas `.cs` heredadas de Unity + commit 2/2 del BOM

**Fecha:** 2026-09-16
**Modelo:** Hy4 / WorkBuddy
**Plataforma:** WorkBuddy
**Módulo:** transversal (doc).
**Reserva:** `Logs/reservas/925-HY4.txt`
**Encaje:** Opción B del backlog HY4 — "parchar huecos".

---

## 0. Resumen

Dos cierres en esta sesión:

1. **BOM (§28), commit 2/2** → `b929ba0`. Plan acordado con el usuario:
   "los 502, en dos commits". Commit 1 (`eb98614`) = 83 archivos vivos;
   commit 2 = 361 logs históricos. **509 → 3 archivos con BOM.**
2. **Rutas `.cs` heredadas** → `5df6e55`. Otro agente ya había hecho el grueso
   en `53edd1b` (34 reemplazos + 175 marcas en 44 archivos). Audité su trabajo
   y **cerré las 61 menciones que dejó pendientes** en 12 archivos.

---

## 1. BOM — commit 2/2 (`b929ba0`)

| Dato | Valor |
|---|---|
| Archivos | 361 ficheros de `Logs/` |
| numstat | 361 / 361 inserciones / 361 borrados (1 línea por fichero) |
| Muestreo del index | 25 blobs al azar → **0 con BOM** |
| Método | `git add` por lotes (verificado antes: **0 de 361** tenían ediciones sin commitear, así que el `add` directo es equivalente al método blob) |

**Estado final del BOM en el repo:**

| Antes | Ahora |
|---|---|
| 509 archivos con BOM | **3** |

Los 3 restantes están bajo `.gitignore` o son artefactos de runtime y **no son
commiteables**:

- `game/isla-ancestral/Godot/app_userdata/isla-ancestral/m87_val_bom.po` —
  `user://` regenerado por tests.
- `game/isla-ancestral/_probe_col.gd` — sonda temporal.
- `scripts/backups/CHECKLIST-GLOBAL_20260901_235922.md` — copia de respaldo.

Además se limpiaron **5 archivos nuevos (untracked)** que agentes estaban
escribiendo con BOM en ese mismo momento: 3 de `DOCUMENTACION/GUIA-GODOT/`,
1 log y 1 test `.gd`. **El BOM se sigue regenerando**: conviene que el
verificador entre en CI en algún momento.

---

## 2. Rutas `.cs` — auditoría del commit ajeno y cierre (`5df6e55`)

### 2.1 Hecho base (verificado por bytes, no por nombre)

| Comprobación | Resultado |
|---|---|
| `.cs` propios del proyecto | **0** |
| Único `.cs` del repo | `addons/gdUnit4/src/dotnet/GdUnit4CSharpApi.cs` (addon de tests) |
| `.csproj` / `.sln` / `.unity` / `.prefab` / `.meta` | **0** |
| `Packages/manifest.json` | no existe |
| Scripts `.gd` del proyecto | **800** en `game/isla-ancestral/` |

Las rutas `.cs` de los planes son **diseño heredado de la etapa Unity**, no
archivos existentes.

### 2.2 Lo que ya estaba hecho

`53edd1b` (otro agente, 2026-09-15 03:22) reemplazó 34 rutas y marcó 175 con
`_ (diseno heredado) _`. Su propio mensaje excluyó 3 archivos por tener
ediciones de otros agentes entrelazadas.

### 2.3 Lo que quedaba y se cerró

Contador de menciones `.cs` en `plan-actual`: **205**, de las cuales
**144 marcadas** y **61 sin marcar** en 12 archivos.

| Acción | Cantidad |
|---|---|
| Rutas CON `.gd` real → reemplazadas por la ruta Godot | **6** |
| Rutas SIN `.gd` real → marcadas `_ (diseno heredado) _` | **55** |
| Archivos | **12** |

Reemplazos reales aplicados:

| Nombre en el plan | Ruta real |
|---|---|
| `StressRunner` | `scripts/stress/stress_runner.gd` |
| `StressScenario` | `scripts/stress/stress_scenario.gd` |
| `InventoryStress` | `scripts/stress/escenarios/inventory_stress.gd` |
| `SaveLoadStress` | `scripts/stress/escenarios/save_load_stress.gd` |
| `BuildInfo` ×2 | `scripts/core/build_info.gd` |

### 2.4 Método (y por qué)

- 9 archivos **limpios** → editados en disco + `git add`.
- 3 archivos con **ediciones ajenas sin commitear** (`26-…/04-Codigo.md`,
  `118-…/05-Checklist.md`, `81-…/05-Checklist.md`) → cambiados **por blob**
  (`git update-index --cacheinfo`), de modo que el trabajo en curso de los
  otros agentes queda intacto en el worktree.

Verificación: `numstat` 1:1 en los 12 archivos (solo las líneas tocadas).
Tras el commit, el contador de disco baja a 7 pendientes, y esas 7 son
exactamente las de los 3 archivos por-blob (el contador lee el disco, no el
index).

### 2.5 Error propio corregido antes de commitear

Escribí un regex con el prefijo de carpeta opcional **sin exigir la barra**:

```python
PAT = re.compile(r'(?:[A-Za-z0-9_./\-]*/)?([A-Za-z0-9_]+)\.cs\b')   # MAL
```

La clase incluye `_` y alfanuméricos, así que el prefijo se comía el nombre y
el grupo capturaba **solo la última letra** (`EventBus.cs` → grupo `s`).
Resultado: 205 "reemplazos" con rutas inventadas. **Lo detecté por una guarda
de cordura** y revertí el index con `git reset -q HEAD -- <los 36 paths>`
(0 archivos staged, worktree intacto). Segundo intento con el prefijo
anclado a `/` y con asserts: `nombres > 150`, `20 <= con_gd <= 40` y
`os.path.isfile()` de cada ruta destino.

**Lección:** en sustituciones masivas sobre docs, siempre una guarda que
falle fuerte antes de escribir. Un `re.subn` exitoso no prueba nada.

### 2.6 Aviso para el siguiente agente

- `RF1` de M05 dice "GDScript + C# **opcional** (.NET)". Sigue vigente como
  opción, pero hoy **no hay una sola línea de C#**. No asumir que existe.
- Duplicidad real encontrada y **no** mergeada (requiere dueño): hay **dos**
  autoloads de localización en `project.godot` —
  `Localization` → `res://scripts/localization/localization_manager.gd` (14,6 KB)
  y `LocalizationManager` → `res://scripts/localizacion/localization_manager.gd`
  (2,7 KB). Conocida como H-1.

---

## 3. Commits de esta sesión

| SHA | Contenido |
|---|---|
| `eb98614` | BOM 1/2 — 83 archivos vivos |
| `b929ba0` | BOM 2/2 — 361 logs |
| `5df6e55` | 61 rutas `.cs` (6 reemplazos + 55 marcas) en 12 archivos |

## 4. Lo que NO hice

- No toqué `plan-inicial` (doc histórica): el otro agente ya la cubrió en
  `53edd1b`.
- No mergeé los dos `LocalizationManager`.
- No metí `scripts/verificar_bom.py` en CI (tarea B4, sigue pendiente).
- No emití ningún sello §21.8: esto es documentación, no cierre de módulo.
