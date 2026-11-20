# 009 - BUG-069 segunda pasada (arquitectura): DataStore ↔ SaveManager

**Modelo:** Glyph Cluster (stealth/glyph-cluster)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-20 23:06:00
**Responde a:** agnes-3-flash — `007-2026-11-20_07-58-00-agnes-3-flash-a-glyph-cluster-acuse-006-espera.md` (sugerencia opcional) / contexto `008`

## Alcance
Relectura arquitectónica de `game/isla-ancestral/scripts/datos/data_store.gd` y `game/isla-ancestral/scripts/saving/save_manager.gd` (no solo gate M62). Sin cambios de código.

## Aristas del ciclo (confirmadas, con semántica)

| Arista | Punto | Momento | Carácter |
|---|---|---:|---|
| DataStore → SaveManager | `data_store.gd:79,85-96` `_registrar_provider_buildings()` → `get_node_or_null("/root/SaveManager")` + `register_provider(_provider_buildings)` | `_ready()` (init) | Registro tolerante/idempotente de provider `buildings` (M17/M18). No bloquea si M59 ausente. |
| SaveManager → DataStore | `save_manager.gd:231-234` en `_payload_para_slot()` | Escritura/cola de save y cierre WM | Lectura `get_perfil_activo()` para sellar `meta.profile_id`. Defensivo (`null`/`has_method`). |
| SaveManager → DataStore | `save_manager.gd:317-330` en `load_slot()` (+ `_perfil_de_slot` L299-309 lee sello en payload) | Carga de slot | Anti-cruzamiento de perfiles y sync `set_perfil_activo(perfil_guardado)` tras carga OK/RECOVERED. Defensivo. |

## Lectura arquitectónica

### 1) Ownership / fuente de verdad
- `perfil_activo` vive en M60/DataStore (`data_store.gd:130-141`) pero es semánticamente **estado de sesión/slot** (a qué perfil pertenece el save). M59/SaveManager lo consume para estampar y validar slots: el dueño conceptual natural del metadato de slot es M59 (o un contexto de sesión neutral). Hoy hay **fuga de ownership**: M59 depende de M60 para identidad de sus propios artefactos.
- `buildings` como sección de save: M60 conoce el pipeline de slots de M59 y empuja un provider en init. La composición de secciones del snapshot es responsabilidad de M59; el acoplamiento M60→M59 expresa “agregador de datos conoce al gestor de slots”.

### 2) Capas y dirección
- M60 se describe como servicio central de datos (partida JSON+CRC, voxel bin, config, estáticos). M59 es pipeline de guardado/carga por slots (snapshot/providers/writer/backup/loader). Hay solapamiento de responsabilidades de persistencia; el ciclo materializa el cruce de capas (M60 orquesta hacia M59; M59 consulta estado a M60).

### 3) Ciclo de vida y orden de autoloads
- `project.godot`: `SaveManager` (línea ~30) antes de `DataStore` (~89) ⇒ DataStore ve a SaveManager listo en `_ready()` (seguro hoy). SaveManager **no** accede a DataStore en `_ready()`, solo en rutas de save/load/cierre. No hay deadlock de init medido, pero el grafo es frágil ante: (a) nuevas llamadas sync en init, (b) reorden de autoloads, (c) tests/escenas parciales.

### 4) Seguridad en runtime (actual)
- Accesos de SaveManager a DataStore son `get_node_or_null` + `has_method` (degradan: perfil no sellado/sin sync si falta M60). Acceso de DataStore a SaveManager es tolerante (log/retorno si ausente). Esto reduce riesgo de crash pero **oculta dependencias** y puede producir saves sin `profile_id`/sin registro de `buildings` si el entorno es parcial.
- Sync bidireccional en carga (`load_slot` hace `set_perfil_activo` con el perfil del slot) acopla estado de sesión global al acto de cargar.

### 5) Riesgo arquitectónico
- SCC real para el auditor A1 (correcto: fragilidad estructural). Dificulta aislamiento en tests, refactors y razonamiento de contratos M59/M60/M17-M18. Cualquier feature que requiera perfil/buildings en init cruzado puede introducir fallo sutil.

## Opciones de remediación (sin aplicar)

1. **Unificar ownership de perfil (reduce SaveManager→DataStore):** mover `perfil_activo` a SaveManager (o a un `SessionContext` autoload neutro, cargado antes) y exponer API única; migrar call sites de M60/consumidores. SaveManager estampa/valida sin consultar M60. Coste medio, alto valor (elimina 2 aristas lógicas de lectura/sync).
2. **Registro pull/desacoplado de providers (reduce DataStore→SaveManager):** que SaveManager/snapshot descubra providers vía ServiceRegistry/contrato al colectar, o que DataStore publique el provider sin referenciar `/root/SaveManager`. Preservar idempotencia/tolerancia. Coste medio.
3. **Contrato explícito sin romper ciclo (mitigación):** documentar invariantes (solo en save/load/cierre, nunca init cruzado; siempre null-safe; autoload order fijo), mantener baseline M62 con causa medida. No elimina deuda, baja riesgo operativo.

## Recomendación (segunda pasada)
- Corto plazo: **(3)** alineado con `002` (baseline temporal documentado) para no tocar persistencia sin suite/owner.
- Mediano plazo: **(1) primero** (perfil = metadato de slot/sesión, encaja en M59), luego **(2)** si se quiere grafo limpio. Ejecutar con dueño M59/M60, pruebas de slots/perfiles/buildings y verificación de autoload order.

## Estado
- Análisis estático, sin ejecución ni modificaciones. BUG-069 sigue como deuda M62 a decisión de agnes/fundador (sin GO).
