# Reporte de revisión — Monetización / DLC (Glyph Cluster)

**Fecha:** 2026-11-07  
**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Agent Manager)  
**Alcance:** `game/isla-ancestral/scripts/monetizacion/`, `game/isla-ancestral/scripts/dlc/`, `game/isla-ancestral/scripts/store/` (referencia) y `game/isla-ancestral/scripts/shops/` (contexto: tienda in-game, no monetización real).

## Archivos analizados
- `game/isla-ancestral/scripts/dlc/dlc_manager.gd` (autoload M120, L1-263)
- `game/isla-ancestral/scripts/dlc/dlc_compatibility_checker.gd` (M120, L1-136)
- `game/isla-ancestral/scripts/monetizacion/monetizacion_manager.gd` (autoload M95, L1-134)
- `game/isla-ancestral/scripts/monetizacion/dlc_catalogo.gd` (M95, L1-47)
- `game/isla-ancestral/scripts/store/store_page_validator.gd` (M97, L1-64) — solo validación de metadatos de store page
- `game/isla-ancestral/scripts/shops/shop_manager.gd` (M39, L1-346) — economía interna/NPC, no compra real

Otros archivos presentes (no leídos en detalle): `scripts/dlc/dlc_uninstaller.gd`, `scripts/dlc/dlc_bundle_manager.gd`, `scripts/dlc/sincronizar_dlc.gd`, `scripts/monetizacion/test_monetizacion*.gd`.

## 1) Gestión de compras / DLC

### Compras locales (M95)
- **Catálogo data-driven:** `MonetizacionManager` carga `res://data/monetizacion/monetizacion.json` (`RUTA_DATOS`, L19; `_cargar_catalogo`, L35-42).
- **Persistencia local de compras:** guarda en `user://monetizacion_compras.json` (`RUTA_COMPRAS`, L20; `_cargar_compras` L44-50; `_guardar_compras`/`guardar_compras` L52-55, L126-131).
- **API de compra:** `comprar_edicion(edicion_id)` (L64-75) y `comprar_dlc(dlc_id)` (L79-90) verifican existencia y duplicado (`esta_comprado`, L59-60, L68-69, L83-84), registran `{tipo, precio}` en `_compras`, persisten y emiten `compra_realizada`.
- **Auditorías/auxiliares:** `auditar_p2w()` detecta ítems con `p2w=true` y emite `p2w_detectado` (L95-106); `calcular_impuesto(precio, plataforma)` lee porcentajes desde el catálogo con default 30% (L110-113).

### Runtime de DLC (M120)
- **Manifiestos:** `DlcManager` carga `res://data/dlc/dlc_manifest.json` y `res://data/dlc/bundles.json` (L20-21, L31-54).
- **Estado activo:** mantiene `_activos` y expone `activar(id)`, `desactivar(id)`, `esta_activo(id)` (L117-129). `activar()` solo añade IDs presentes en el manifiesto (L118-123).
- **Registro/carga de contenido:** `cargar_contenido(tipo, id)` registra IDs por tipo en `_contenido` (L228-236); métodos de conveniencia `load_island/load_biome/load_npc/load_historia/load_ruin/load_music` delegan en él (L247-263). El comentario indica que el cargado real depende de otros módulos (M27/M09/M19/M22/M25/M41).
- **Servicios auxiliares:** instanciación perezosa de `DLCCompatibilityChecker`, uninstaller y bundle manager (L200-223), evitando autoloads adicionales.

### Catálogo/roadmap (M95, separado)
- `DlcCatalogo` lee `res://data/monetizacion/dlc.json`, expone `roadmap()` ordenado y `es_cosmetico()` (L13-47). Es un modelo distinto del manifiesto operativo de M120.

### Persistencia de estado DLC
- `DlcManager` actúa como `ISaveProvider` (sección `"dlc"`, L153-160) y se registra en `SaveManager` por duck-typing (L64-68). Guarda `activos` + `version_base` (L156-160).

## 2) Validación de estado de DLC

- **Estado activo/inactivo:** sí. `esta_activo(id)` consulta `_activos` (L128-129).
- **Compatibilidad con versión base:** sí. `DlcManager.es_compatible()` compara versiones **semánticamente** (`comparar_versiones`, L77-111), corrigiendo el bug lexicográfico mencionado en cabecera (L11-13). `DLCCompatibilityChecker` aplica semántica similar y acepta esquemas `dlc_compatibility` o `version_requerida`/`dependencias` (L50-117). También detecta downgrade de save con `save_de_version_superior()` (L188-191).
- **Compatibilidad entre DLC:** sí. `DLCCompatibilityChecker.check_compatibility()` exige versión base compatible y que DLC requeridos estén cargados/activos (`_dlc_cargado` → `esta_activo`/`is_dlc_loaded`, L103-136).
- **Reconciliación al cargar save:** sí. `restore_save_data()` limpia estado, restaura activos solo si el DLC existe en manifiesto; si el save referencia un DLC no instalado, lo añade a `_faltantes` en vez de activarlo (L162-180). `dlcs_faltantes()` lo expone (L178-180).
- **Validación de compra/entitlement real:** **no implementada** en estos scripts. `esta_comprado()` (M95 L59-60) es estado local en `user://`; no hay integración con plataforma (Steam/EGS), recibos, firma ni verificación remota. No hay puente visible que obligue a propiedad antes de `DlcManager.activar()`.

## 3) Problemas de acceso a contenido bloqueado

1. **Sin gate al registrar/cargar contenido DLC (riesgo alto).**  
   `cargar_contenido()` (L228-236) y los wrappers `load_*` (L247-263) solo validan `tipo/id` no vacíos y registran el ID. **No comprueban** `esta_activo(id)`, propiedad/compra, compatibilidad ni dependencias. Si otro sistema invoca estos métodos, puede registrar/cargar contenido asociado a un DLC no activo.

2. **Activación sin verificación de propiedad (riesgo alto).**  
   `DlcManager.activar(id)` (L117-123) valida únicamente que el DLC exista en el manifiesto. No consulta `MonetizacionManager.esta_comprado()` ni un entitlement de plataforma, por lo que un flujo interno podría activar DLC conocidos sin compra.

3. **Dos fuentes de verdad desconectadas (riesgo medio).**  
   M95 guarda compras en `user://monetizacion_compras.json`; M120 guarda activos/versionado en la sección `dlc` del save (`get_save_data`/`restore_save_data`, L156-176). No hay sincronización observable entre “comprado” y “activo”, lo que permite inconsistencias (comprado no activo, activo sin compra, divergencia entre slots/saves).

4. **Compras fuera del sistema de guardado global (riesgo medio).**  
   `MonetizacionManager` usa archivo propio `user://` y no implementa `ISaveProvider` (L126-131), a diferencia de `DlcManager` (L153-160). Esto complica coherencia por slot, backup/restore y portabilidad del estado de compra.

5. **Metadatos de store ≠ control de acceso.**  
   `StorePageValidator` valida configuración de página (descripciones, keywords/tags, requisitos, assets; L14-56), pero no participa en autorización de compras ni desbloqueo de contenido.

## 4) Mejoras sugeridas

1. **Gate central de entitlement/autorización en `DlcManager`.**  
   - Antes de `activar()` y `cargar_contenido()/load_*`, exigir: DLC existente en manifiesto, `es_compatible(id, version_base_actual())`, propiedad válida (`MonetizacionManager.esta_comprado(id)` o servicio de plataforma) y dependencias satisfechas (`DLCCompatibilityChecker`).  
   - Ejemplo de política: rechazar `cargar_contenido` si `not esta_activo(id)`; hacer que `activar()` retorne `false` sin entitlement.  
   - Centralizar esto en M120 evita que cada módulo (islas/biomas/NPCs/música) reimplemente controles y reduce accesos a contenido bloqueado.

2. **Unificar compra ↔ activación y endurecer persistencia/verificación.**  
   - Crear un flujo único: `comprar_dlc` (M95, L79-90) confirma transacción → activa en M120 solo tras validación; al cargar save, reconciliar `_compras` con `_activos`/`_faltantes`.  
   - Integrar compras al guardado global (`ISaveProvider`/SaveManager) o versionar/proteger `user://monetizacion_compras.json`; registrar metadatos (plataforma, timestamp, versión).  
   - Preparar hooks para verificación de recibo/plataforma (hoy solo existe cálculo de impuestos, M95 L110-113). Esto reduce inconsistencias entre slots y dependencia de estado local no verificado.
