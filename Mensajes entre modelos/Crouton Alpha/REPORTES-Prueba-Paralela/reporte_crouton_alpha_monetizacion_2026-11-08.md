# Reporte: Monetización, DLC y Store — Isla Ancestral

**Modelo:** Crouton Alpha
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scripts/monetizacion/`, `scripts/dlc/`, `scripts/store/` + datos JSON asociados.

## Archivos analizados

- `game/isla-ancestral/scripts/monetizacion/monetizacion_manager.gd` (134 líneas, M95, autoload)
- `game/isla-ancestral/scripts/monetizacion/dlc_catalogo.gd` (47 líneas, M95)
- `game/isla-ancestral/scripts/monetizacion/edicion_catalogo.gd` (44 líneas, M95)
- `game/isla-ancestral/scripts/monetizacion/scanner_antip2w.gd`, `scanner_antilootbox.gd`
- `game/isla-ancestral/scripts/dlc/dlc_manager.gd` (263 líneas, M120, autoload)
- `game/isla-ancestral/scripts/dlc/dlc_bundle_manager.gd` (163 líneas, M120)
- `game/isla-ancestral/scripts/dlc/dlc_compatibility_checker.gd` (136 líneas, M120)
- `game/isla-ancestral/scripts/dlc/dlc_uninstaller.gd` (185 líneas, M120)
- `game/isla-ancestral/scripts/dlc/sincronizar_dlc.gd` (36 líneas, verificador M95/M120)
- `game/isla-ancestral/scripts/store/store_page_validator.gd` (64 líneas, M97)
- Datos: `data/monetizacion/monetizacion.json`, `data/dlc/dlc_manifest.json`, `data/dlc/bundles.json`, `data/dlc/dlc_manifest.json`, `data/store/store_page.json`

## 1. ¿Cómo se gestionan las compras y DLC?

- **MonetizacionManager** (`monetizacion_manager.gd:63-90`) es autoload central: `comprar_edicion(edicion_id)` y `comprar_dlc(dlc_id)` verifican existencia en catálogo, rechazan duplicados vía `esta_comprado(id)` (`línea 59-60`), registran `{tipo, precio}` en `_compras` y persisten en `user://monetizacion_compras.json` (`guardar_compras()`, líneas 52-55 y 127-130). Emite señal `compra_realizada(edicion, precio)`.
- Catálogo data-driven desde `res://data/monetizacion/monetizacion.json`: 3 ediciones (standard $24.99, deluxe $34.99, coleccionista $69.99) y 2 DLC (`isla_hielo` expansión $14.99, `pack_aurora` cosmético $4.99), ambos `p2w: false`. Impuestos por plataforma (`steam 30%`, `egs 12%`) en `calcular_impuesto()` (`línea 110-113`).
- **DlcManager** (`dlc_manager.gd:117-129`) gestiona activación: `activar(id)` / `desactivar(id)` / `esta_activo(id)` sobre lista `_activos`. **No valida compra**: activar no consulta `MonetizacionManager.esta_comprado()`. Contenido por tipo se registra vía `load_island/biome/npc/historia/ruin/music` (líneas 247-263) solo como registro consultable (`_contenido`), sin cargar assets reales.
- **Bundles**: `dlc_bundle_manager.gd:83-94` calcula descuento; `bundles.json` define 4 bundles (season pass, completo, islas, deluxe). No hay compra de bundles en `MonetizacionManager` (solo ediciones y DLC individuales).
- Coherencia catálogos: `sincronizar_dlc.gd:17-35` verifica que IDs de `dlc_manifest.json` ↔ `dlc.json` coincidan.

## 2. ¿Hay validación de estado de DLC?

Sí, parcial y bien diseñada en M120, pero desconectada de M95:

- `dlc_manager.gd:79-86` `es_compatible()` con comparación **semántica** `comparar_versiones()` (líneas 90-99) — corrige bug histórico de comparación lexicográfica.
- `dlc_compatibility_checker.gd:104-117` `check_compatibility()` valida versión base + dependencias (`dependencias`/`other_dlc`) vía `esta_activo()`.
- Saves: `DlcManager` implementa `ISaveProvider` (sección `dlc`, líneas 153-160), persiste `_activos` + `version_base`, y al restaurar detecta DLCs referenciados no instalados → `_faltantes` (`restore_save_data`, líneas 162-176, `dlcs_faltantes()` línea 179) y downgrade (`save_de_version_superior()`, líneas 188-191).
- `dlc_uninstaller.gd:39-58` desinstala: marca saves `dlc_content[id]="incomplete"`, desactiva y borra `user://dlc/<id>/`.
- **Hueco**: ninguna de estas validaciones consulta la compra (`esta_comprado`). `activar()` no exige ownership.

## 3. ¿Hay problemas de acceso a contenido bloqueado?

- **Acceso sin compra (fuga principal)**: `dlc_manager.gd:117-123` `activar(id)` solo verifica que el ID exista en el manifest. Cualquier DLC puede activarse sin pasar por `MonetizacionManager.comprar_dlc()`. No hay gate compra→activación (grep en `scripts/` no muestra `esta_comprado` consumido por `DlcManager` ni loaders).
- **Bundles huérfanos**: `bundles.json` referencia `isla_volcan` e `isla_bosque` que **no existen** en `dlc_manifest.json` ni en `monetizacion.json` (solo 2 DLC reales). El cálculo de descuento cae al `descuento` declarado (línea 94 `dlc_bundle_manager.gd`) porque `get_dlc_price()` devuelve 0.0 para IDs inexistentes.
- **Precios duplicados y divergentes**: precio vive en 3 fuentes: `monetizacion.json`, `dlc_manifest.json`, `bundles.json` (`dlc_bundle_manager.gd:18-19` lo declara). Si divergen, manda M95 pero nada lo verifica en runtime (solo `sincronizar_dlc.gd` para IDs, no precios).
- **Estado planificado vs activable**: manifest marca ambos DLC `"estado": "planificado"` pero `activar()` no respeta ese campo → contenido futuro accesible prematuramente.
- **Sin gating de gameplay**: `load_island()` etc. (líneas 247-263) registran por tipo sin verificar ni ownership ni compatibilidad; los sistemas consumidores (islas M27, biomas M09…) son los que deberían filtrar, pero no hay capa común de bloqueo.
- **Prevención player-facing bien hecha**: `edicion_catalogo.gd:36-38` exige `historia_completa` en todas las ediciones; `auditar_p2w()` (`monetizacion_manager.gd:95-106`) detecta P2W; scanners anti-P2W/anti-lootbox refuerzan. Eso sí está sólido.

## 4. Dos mejoras propuestas

1. **Puente de ownership compra → activación (cerrar la fuga)**:
   - En `dlc_manager.gd:activar()`, exigir `MonetizacionManager.esta_comprado(id)` (o `bundle_manager` cubriendo el ID) antes de agregar a `_activos`; si no comprado → `return false` + señal `dlc_bloqueado(id, motivo)`. Registrar en `_faltantes` cuando un save referencia DLC no comprado. Esto alinea M95 (compras) con M120 (activación) y hace efectivo el gate de contenido bloqueado.
   - Criterio de aceptación: `activar("isla_hielo")` sin compra previa devuelve `false`; tras `comprar_dlc("isla_hielo")` devuelve `true`. Extender `tests/unit/dlc/test_dlc_manager.gd`.

2. **Validador de integridad de catálogos en arranque (anti-drift)**:
   - Extender `sincronizar_dlc.gd` (hoy solo IDs) a una validación asertiva invocada en `_ready` de ambos autoloads: (a) todo bundle referencia solo DLC existentes, (b) precios `monetizacion.json` == `dlc_manifest.json` == suma de bundle con tolerancia de descuento, (c) ningún DLC `estado="planificado"` es activable. Fallo → `push_error` + señal para UI M53 ("contenido no disponible"). Evita bundles rotos (`isla_volcan`/`isla_bosque`) y divergencia de precios silenciosa.
   - Criterio de aceptación: headless CI falla si un bundle referencia IDs inexistentes o precios difieren >$0.01.

## Conclusión final

El sistema combina dos capas maduras pero **desacopladas**: M95 (compras, precios, anti-P2W) y M120 (activación, compatibilidad, saves faltantes, uninstall). La validación de estado de DLC existe y es correcta en lo técnico (versiones semánticas, reconciliación de saves, uninstall con marcado incomplete). El problema material es la **falta de gate**: activar un DLC no requiere haberlo comprado, los bundles referencian contenido inexistente y el precio vive en tres fuentes sin verificación runtime. Con el puente de ownership y el validador de integridad propuestos, el acceso a contenido bloqueado quedaría cerrado sin reescribir los managers existentes. Verificación recomendada: `Godot --headless --path game/isla-ancestral --script res://scripts/monetizacion/test_monetizacion.gd` y suite M120.
