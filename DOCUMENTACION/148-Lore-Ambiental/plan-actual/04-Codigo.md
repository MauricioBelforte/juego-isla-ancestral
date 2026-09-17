**Modelo:** deepseek-v4-flash (iter. 1) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 2)
**Plataforma:** Kilo Code (iter. 1) · WorkBuddy (iter. 2)

# 04-Codigo.md — Módulo 148: Lore Ambiental

> ⚠️ **Nota de reescritura (iter. 2, 2026-09-13).** La versión anterior de este
> archivo describía una implementación **Unity/C#** (`Assets/_Project/Scripts/…`,
> `MonoBehaviour`, `IInteractable`, `ScriptableObject`). **Ninguno de esos
> archivos existe**: el proyecto es **Godot 4.7.2** con GDScript (982 `.gd`, 1 `.cs`).
> La sección §1.1/§2 originales se conservan al final como **diseño muerto**
> (referencia de intención). Lo que sigue es el código REAL.

## 1. Archivos reales

### 1.1 Núcleo del módulo (`game/isla-ancestral/scripts/lore/`)

| Archivo | Tipo | Propósito |
|---------|------|-----------|
| `pieza_lore.gd` | `PiezaDeLore extends Resource` | Modelo de una pieza: `id`, `canon_ref`, `tipo` (enum de 14), `isla`, `titulo`, `texto`, `consumidor_id`, `coords`, `temporada` |
| `lore_catalogo.gd` | `LoreCatalogo extends RefCounted` | Catálogo data-driven desde JSON; índices `por_isla`/`por_tipo`; lookup por `id`; registro de consumidores; **detección de IDs duplicados al cargar** |
| `lore_auditor.gd` | `LoreAuditor extends RefCounted` (estático) | Validación: IDs únicos, `canon_ref` no vacío, tipo en rango, título/texto, cobertura ≥ 12/isla, grafo de pistas |
| `terreno_lore_service.gd` | `TerrenoLoreService extends RefCounted` | Secretos por temporada (hook M74): `activar_temporada(t)` |
| `lore_save_provider.gd` | `LoreSaveProvider extends RefCounted` | **iter. 2** — persistencia (contrato `ISaveProvider`, sección `"lore"`), migración y contadores por isla |
| `lore_gate.gd` | `SceneTree` (script headless) | **iter. 2** — puerta de CI: `exit 1` si el catálogo o el grafo no son válidos |
| `test_lore_m148.gd` | `SceneTree` (script headless) | Test: 85 checks con marcadores anti-falso-verde |

### 1.2 Datos (`game/isla-ancestral/data/lore/`)

| Archivo | Contenido |
|---------|-----------|
| `lore.json` | **60 piezas**, 4 islas (raiz 18 · coral 14 · ceniza 14 · aurora 14), 14 tipos |
| `consumidores.json` | **iter. 2** — 18 consumidores válidos del grafo de pistas (`puzzle_*`, `sello_*`, `coleccion_*`, `npc_*`, `altar_*`, `rumor_cancion`) |
| `secretos_temporada.json` | 4 temporadas × 1 ubicación |

### 1.3 Modificados (módulos de terceros)

Ninguno. La persistencia se integra por el **punto de extensión documentado de
M59** (`SaveManager.register_provider`), que es **aditivo por diseño**: no se
tocó `save_schema.gd` ni `save_snapshot.gd`. `_reserved_sections` no incluye
`lore`, y una sección extra es aceptada (los proveedores añaden su clave).

### 1.4 CI

`.github/workflows/quality.yml` → job `test-suite`: se agregaron
`scripts/lore/lore_gate.gd` y `scripts/lore/test_lore_m148.gd` (con `bash -e`,
un `exit 1` del gate rompe el job).

## 2. Funciones clave (GDScript real)

```gdscript
# LoreCatalogo
func cargar() -> void                                  # JSON + consumidores, idempotente
func cargar_desde_texto(texto: String) -> bool         # iter. 2: fixtures sin FS
func obtener_pieza(id: String) -> PiezaDeLore
func por_isla(isla: String) -> Array
func por_tipo(tipo: int) -> Array
func todos_los_ids() -> Array                          # ordenado
func ids_duplicados() -> Array                         # iter. 2: detectados AL CARGAR
func entradas_sin_id() -> int                          # iter. 2
func consumidor_valido(id: String) -> bool             # iter. 2: grafo real
func es_pista_valida(consumidor_id: String) -> bool    # iter. 2: consulta el registro
func pistas() -> Array                                 # iter. 2
static func es_tipo_pista(tipo: int) -> bool           # iter. 2

# LoreAuditor (todo estático)
static func validar(catalogo: LoreCatalogo) -> Array           # Array[String] de errores
static func validar_grafo(catalogo: LoreCatalogo) -> Array     # iter. 2
static func reporte_cobertura(catalogo: LoreCatalogo) -> String # iter. 2
static func reporte(errores: Array) -> String

# TerrenoLoreService
func cargar() -> void
func activar_temporada(temporada: String) -> Array     # devuelve COPIA

# LoreSaveProvider (contrato ISaveProvider por duck-typing, como M59)
func get_section_name() -> String                      # "lore"
func get_save_data() -> Dictionary                     # {version, explorado[], por_isla{}}
func restore_save_data(data: Dictionary) -> void       # tolerante a datos faltantes
static func migrar(data: Variant, desde_version := 0) -> Dictionary  # iter. 2
func ya_explorado(id: String) -> bool
func marcar_explorado(id: String, isla := "") -> bool  # true SOLO si es nueva
func contador_isla(isla: String) -> int
func total_explorado() -> int
func reset() -> void
```

## 3. Datos / config

| Dato | Formato | Sistema |
|------|---------|---------|
| Catálogo de lore | `data/lore/lore.json` → `PiezaDeLore` | `LoreCatalogo` |
| Consumidores del grafo | `data/lore/consumidores.json` | `LoreCatalogo` |
| Secretos por temporada | `data/lore/secretos_temporada.json` | `TerrenoLoreService` |
| Canon (referencia) | keys `biblia:<isla>:<tema>` de M147 | `pieza.canon_ref` |
| Estado de exploración | sección `"lore"` del payload (M59) | `LoreSaveProvider` |

## 4. Tests (headless — Godot 4.7.2, no Unity Test Framework)

| Bloque | Cobertura |
|--------|-----------|
| A | Carga del catálogo, lookup, cobertura por isla ≥ 12, murales ≥ 4, ids estables |
| B | Auditor sobre el catálogo real (0 errores) + reporte de cobertura |
| C | **Adversario**: ID duplicado, `canon_ref` vacío, tipo fuera de rango, texto vacío, cobertura insuficiente, pista sin consumidor, consumidor desconocido, duplicado por la vía real de carga, entrada sin id |
| D | Grafo de pistas: registro cargado, `es_pista_valida`, grafo real consistente, consumidor inexistente detectado |
| E | `TerrenoLoreService`: 4 temporadas, temporada desconocida, devuelve copia |
| F | `LoreSaveProvider`: marcado, no re-notificación, contadores, `get_save_data`/`restore`/`reset` |
| G | Migración: save sin la sección, sección parcial, ids duplicados, datos basura, coerción de tipos |
| H | **30 ciclos** save/load con round-trip JSON real, sin pérdida de lore |
| — | Verificación anti-falso-verde: los 8 marcadores `_fin()` deben existir |

## 5. Notas de integración

- La inspección reutiliza el sistema de interacción existente (M13/M16), sin UI nueva.
- El lore del diario usa la arquitectura de M55 (solo agrega datos).
- Los rumores de NPC (M21) son el puente de descubrimiento (evita lore invisible).
- El **LoreGate** corre en CI (`quality.yml`) y falla ante IDs duplicados, `canon_ref`
  vacío, cobertura < 12 por isla o consumidor de pista inexistente.
- Compatible con M13/M55/M73/M74/M20-M23/M34/M35/M50 — no los modifica estructuralmente.
- ⚠️ **Pendiente de integración (no hecho en iter. 2):** `LoreSaveProvider` está
  implementado y probado, pero **no está registrado** en `SaveManager`. Hoy no
  existe juego de lore que escriba estado (falta `TriggerLore` y la UI del diario),
  así que registrar la sección guardaría siempre un estado vacío. El registro es
  **una línea** en `SaveManager` (junto a `_registrar_provider_player()`), y
  corresponde al paso de integración con el diario (M55/M89), no a la parte de datos.

## 6. Apéndice — diseño original NO implementado (Unity/C#)

Se conserva solo como traza de la intención de diseño. **0 de estos archivos existe.**

| Archivo C# (inexistente) | Equivalente real en GDScript |
|---|---|
| `Assets/_Project/Scripts/World/Lore/PiezaDeLore.cs` _(diseno heredado)_ | `scripts/lore/pieza_lore.gd` |
| `scripts/lore/lore_catalogo.gd` | `scripts/lore/lore_catalogo.gd` |
| `Assets/_Project/Scripts/World/Lore/TriggerLore.cs` _(diseno heredado)_ | *(pendiente — requiere escena/3D)* |
| `scripts/lore/terreno_lore_service.gd` | `scripts/lore/terreno_lore_service.gd` |
| `Assets/_Project/Scripts/UI/DiarioLoreSeccion.cs` _(diseno heredado)_ | *(pendiente — UI M55/M89)* |
| `scripts/lore/lore_auditor.gd` | `scripts/lore/lore_auditor.gd` + `lore_gate.gd` |
| `DiarioManager.cs` _(diseno heredado)_ / `scripts/saving/save_manager.gd` / `ColeccionManager.cs` _(diseno heredado)_ / `NPCAmistad.cs` _(diseno heredado)_ / `CalendarioManager.cs` _(diseno heredado)_ | *(pendiente; M59 vía `LoreSaveProvider`)* |
