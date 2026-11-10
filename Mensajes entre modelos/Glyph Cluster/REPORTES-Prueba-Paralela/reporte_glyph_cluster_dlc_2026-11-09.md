# Reporte de análisis: Monetización, DLC, compras y Store
**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-09  
**Alcance:** `game/isla-ancestral/scripts/monetizacion/`, `game/isla-ancestral/scripts/dlc/`, `game/isla-ancestral/scripts/store/` y datos asociados en `game/isla-ancestral/data/`.

## Archivos analizados

| Área | Archivo | Líneas | Rol principal |
|---|---|---:|---|
| Monetización | `game/isla-ancestral/scripts/monetizacion/monetizacion_manager.gd` | 134 | Autoload M95: catálogo data-driven, compras locales, P2W e impuestos. |
| Monetización | `game/isla-ancestral/scripts/monetizacion/dlc_catalogo.gd` | 47 | Catálogo/roadmap de DLC (M95). |
| Monetización | `game/isla-ancestral/scripts/monetizacion/edicion_catalogo.gd` | 44 | Catálogo de ediciones (M95). |
| Monetización | `game/isla-ancestral/scripts/monetizacion/scanner_antip2w.gd` | 34 | Escáner anti pay-to-win. |
| Monetización | `game/isla-ancestral/scripts/monetizacion/scanner_antilootbox.gd` | 37 | Escáner anti loot boxes. |
| Monetización | `game/isla-ancestral/scripts/monetizacion/test_monetizacion.gd` | 57 | Test headless del autoload M95. |
| Monetización | `game/isla-ancestral/scripts/monetizacion/test_monetizacion_m95.gd` | 107 | Test headless de catálogos y escáneres M95. |
| DLC | `game/isla-ancestral/scripts/dlc/dlc_manager.gd` | 343 | Autoload M120: activación, propiedad, compatibilidad, persistencia y carga de contenido. |
| DLC | `game/isla-ancestral/scripts/dlc/dlc_compatibility_checker.gd` | 136 | Verificación semántica de versión base y dependencias. |
| DLC | `game/isla-ancestral/scripts/dlc/sincronizar_dlc.gd` | 36 | Coherencia manifest (M120) ↔ monetización (M95). |
| DLC | `game/isla-ancestral/scripts/dlc/dlc_uninstaller.gd` | 185 | Desinstalación, marcado de saves incompletos y borrado local. |
| DLC | `game/isla-ancestral/scripts/dlc/dlc_bundle_manager.gd` | 163 | Bundles, precios y descuento calculado/declarado. |
| DLC | `game/isla-ancestral/scripts/dlc/test_dlc_m120.gd` | 74 | Test headless M120 (manifest/compatibilidad/bundles). |
| DLC | `game/isla-ancestral/scripts/dlc/test_dlc_servicios_m120.gd` | 257 | Test headless de servicios M120 (checker/bundles/uninstaller/loaders). |
| Store | `game/isla-ancestral/scripts/store/store_page_validator.gd` | 64 | Validador data-driven de la página de tienda (M97). |
| Store | `game/isla-ancestral/scripts/store/test_store_m97.gd` | 74 | Test headless M97. |
| Datos | `game/isla-ancestral/data/monetizacion/monetizacion.json` | 18 | Ediciones, DLC, impuestos; flags `p2w:false`. |
| Datos | `game/isla-ancestral/data/dlc/dlc_manifest.json` | 27 | Manifest de DLC: versión requerida, precio, dependencias, contenido. |
| Datos | `game/isla-ancestral/data/dlc/bundles.json` | 8 | Bundles y descuentos. |

Autoloads registrados en `game/isla-ancestral/project.godot`: `MonetizacionManager` (línea 93) y `DlcManager` (línea 120).

## 1) ¿Cómo se gestionan las compras y DLC?

### Compras (M95 — `MonetizacionManager`)
- Carga el catálogo desde `res://data/monetizacion/monetizacion.json` (`RUTA_DATOS`, líneas 19, 35-42).
- Mantiene compras locales en `user://monetizacion_compras.json` (`RUTA_COMPRAS`, líneas 20, 44-56, 126-134).
- `esta_comprado(id)` verifica por presencia en `_compras` (líneas 58-60).
- `comprar_edicion()` valida existencia, evita recompras, guarda precio/tipo, persiste y emite señal (líneas 64-75).
- `comprar_dlc()` aplica el mismo patrón para DLC (líneas 78-90).
- `calcular_impuesto()` aplica porcentajes por plataforma con default Steam 30% (líneas 109-113). Los valores vienen de datos (`impuestos` en JSON: Steam 30%, EGS 12%, GOG 30%, itch.io 10%).

**Naturaleza:** es un gestor **local/data-driven** de estado de compra y catálogo. No hay integración visible en estos scripts con una API de tienda real (Steam/EGS/GOG), recibos, transacciones, reembolsos efectivos ni verificación de servidor.

### DLC (M120 — `DlcManager`)
- Carga `res://data/dlc/dlc_manifest.json` y `res://data/dlc/bundles.json` (líneas 32-33, 99-115).
- Expone metadatos (`dlc()`, `bundle()`, `bundles_que_contienen()`, `dlcs_ids()`; líneas 131-213).
- Gestiona activación/desactivación (`activar`, `desactivar`, `esta_activo`; líneas 178-196).
- Implementa compatibilidad semántica de versiones base (`es_compatible`, `comparar_versiones`, `version_base_actual`; líneas 137-176) — corrige el bug previo de comparación léxica.
- Persiste estado DLC como `ISaveProvider` (sección `dlc`): activos y versión base guardada (`get_section_name`, `get_save_data`, `restore_save_data`; líneas 215-265). Reconcilia DLC faltantes y detecta saves de versión superior.
- Registra contenido cargado por tipo (`cargar_contenido`, `load_island/biome/npc/historia/ruin/music`; líneas 299-343). El cargado real queda delegado a módulos externos.
- Instancia servicios perezosos: `DLCCompatibilityChecker`, `DLCUninstaller`, `DLCBundleManager` (líneas 267-297).

### Servicios auxiliares DLC
- **Compatibilidad:** `DLCCompatibilityChecker` normaliza dos esquemas (`dlc_compatibility` o `version_requerida`/`dependencias`) y valida versión + DLC requeridos cargados (líneas 50-136).
- **Desinstalación:** `DLCUninstaller` marca saves con `dlc_content[dlc_id]="incomplete"`, desactiva el DLC y borra `user://dlc/<id>/` (líneas 37-116). Usa rutas inyectables para pruebas; directorio de saves real `user://saves`.
- **Bundles:** `DLCBundleManager` normaliza bundles, calcula descuento cuando hay precios completos o usa el declarado; obtiene precios de referencia desde el manifest (líneas 40-163).
- **Coherencia:** `sincronizar_dlc.gd` compara IDs entre manifest M120 y catálogo de monetización M95 y falla con exit code 1 si hay desajustes (líneas 16-36).

### Store (M97)
- `StorePageValidator` valida datos de página de tienda: descripción corta ES/EN y límite, mínimo 5 secciones About con bullets, keywords/tags (máx. 20), requisitos y assets con dimensión (líneas 14-64). Es validación editorial/configurable, no lógica de compra.

## 2) ¿Hay validación de estado de DLC?

**Sí, en `DlcManager` hay validación técnica y de propiedad**, con varios controles relevantes:

- **Existencia en manifest:** `dlc(id)` devuelve `{}` si no existe; `activar()` falla si el DLC no está en manifest (líneas 131-183).
- **Compatibilidad de versión base:** `es_compatible()` usa comparación semántica (`comparar_versiones`), no lexicográfica (líneas 137-172). `DLCCompatibilityChecker` amplía con dependencias y banderas (líneas 50-126 del checker).
- **Estado activo:** `esta_activo()` consulta `_activos` (líneas 195-196).
- **Propiedad/entitlement:** `posee()` revisa propiedad local, bundles comprados y proveedor externo opcional (líneas 57-68). `activar()` exige `posee()` y cuenta bloqueos (líneas 180-190). `cargar_contenido()` rechaza contenido de un DLC del manifest que no esté activo (líneas 302-310).
- **Persistencia segura al restaurar save:** `restore_save_data()` no activa DLC ausentes ni DLC instalados sin propiedad; los mueve a `_faltantes` y registra bloqueos/warnings (líneas 229-254). También conserva `_version_guardada` y detecta saves de versión superior (líneas 256-265).
- **Coherencia de catálogos:** `sincronizar_dlc.gd` verifica que IDs de manifest y monetización coincidan.

**Limitaciones observadas:**
- `posee()` depende de `_propietarios` local y/o callback opcional; no hay proveedor real integrado en estos archivos. El gate es fuerte en diseño, pero su fiabilidad depende de quién llama `registrar_propiedad()`/`set_proveedor_propiedad()`.
- `MonetizacionManager` mantiene su propio estado `esta_comprado()` en `user://monetizacion_compras.json` (M95) y **no se observa conexión directa** con `DlcManager.registrar_propiedad()`/`posee()`. Son dos fuentes de verdad separadas.
- El test `test_dlc_m120.gd` activa `isla_hielo` sin registrar propiedad previa (líneas 52-56). Esto sugiere que el test puede estar desactualizado respecto al gate cerrado por defecto introducido en `dlc_manager.gd` (2026-11-08), o que la propiedad se establece por otra vía no visible en ese test.

## 3) ¿Hay problemas de acceso a contenido bloqueado?

### Controles positivos (mitigan acceso bloqueado)
- **Activación protegida por propiedad:** `DlcManager.activar()` rechaza sin `posee()` (`_bloqueos += 1`, warning; líneas 184-190).
- **Carga de contenido protegida por activación:** si el ID es un DLC del manifest y no está activo, `cargar_contenido()` rechaza y cuenta bloqueo (líneas 305-310).
- **Restauración de save no otorga entitlement:** DLC referenciados sin propiedad no se activan y quedan en `_faltantes` (líneas 242-250).

### Riesgos / huecos detectados
1. **Doble sistema de compras/propiedad sin puente explícito.**  
   - M95 registra compras DLC en `MonetizacionManager._compras` (`comprar_dlc`, líneas 78-90; `esta_comprado`, 58-60).  
   - M120 exige propiedad en `DlcManager._propietarios`/proveedor (`posee`, 57-68; `activar`, 180-190).  
   - No se encontró uso de `registrar_propiedad()` fuera de `dlc_manager.gd`. Esto puede causar estados inconsistentes: comprado en M95 pero no activable en M120, o necesidad de cableado manual no visible.
2. **Registro de contenido no impide acceso real del gameplay.**  
   - `cargar_contenido()` solo registra IDs por tipo en `_contenido` (líneas 311-325). El comentario indica que el cargado real lo hacen módulos externos (M27/M09/M19/M22/M25/M41; líneas 299-301). Si esos módulos cargan assets/escenas sin consultar `DlcManager.esta_activo()`/`posee()`, el bloqueo sería solo lógico/registral.
3. **`cargar_contenido()` solo aplica gate a IDs que son DLC del manifest.**  
   - La condición es `if not dlc(id).is_empty() and not esta_activo(id):` (línea 307). IDs que no existan en manifest se registran sin gate. Esto es flexible, pero reduce la capacidad de bloqueo para contenido ad-hoc o mal identificado.
4. **Posible desincronización de pruebas con el gate actual.**  
   - `test_dlc_m120.gd` espera activar `isla_hielo` directamente (línea 52). Con el gate actual, debería fallar a menos que haya propiedad pre-registrada/proveedor. Esto no es un exploit en runtime por sí mismo, pero indica riesgo de regresión no detectada.

## 4) ¿Hay gate de propiedad al activar contenido?

**Sí, hay gate de propiedad explícito en `DlcManager` (M120).** Es el componente más robusto del área analizada:

- `activar(id)`: **requiere** `posee(id)`; si falla, incrementa `_bloqueos`, emite warning y devuelve `false` (líneas 178-190).
- `posee(id)`: acepta propiedad directa, propiedad por bundle contenedor o proveedor externo inyectable (líneas 57-68).
- `registrar_propiedad(id)` / `revocar_propiedad(id)` / `set_proveedor_propiedad(cb)`: API para declarar entitlement (líneas 51-83).
- `cargar_contenido()` añade gate de **activación** para DLC del manifest (líneas 305-310). Dado que `activar()` ya depende de propiedad, el camino normal queda: propiedad → activar → cargar.
- `restore_save_data()` añade gate al rehidratar: no activa sin propiedad, aunque el save lo solicite (líneas 242-250).

**Conclusión del gate:** el diseño actual es “cerrado por defecto” para activación/carga en M120, lo cual es correcto. El punto débil no es la ausencia del gate, sino su **integración incompleta** con el flujo de compra M95 y con los sistemas que efectivamente instancian/cargan contenido DLC.

## 5) Sugerencias de mejora (2)

1. **Unificar la fuente de verdad de propiedad entre M95 y M120 (puente de entitlement).**  
   - Problema: `MonetizacionManager.comprar_dlc()` persiste compras en `user://monetizacion_compras.json`, mientras `DlcManager.activar()/posee()` usa `_propietarios`/proveedor. No hay conexión visible.  
   - Mejora concreta: al completar una compra válida de DLC/edición/bundle en M95, invocar `DlcManager.registrar_propiedad(id)` (o configurar `set_proveedor_propiedad()` para consultar compras M95/tienda). También considerar sincronizar al cargar: si M95 tiene un DLC comprado, reflejarlo en M120.  
   - Impacto: elimina estados inconsistentes, hace efectivo el gate de M120 en el flujo real de compra y reduce riesgo de contenido comprado pero inaccesible, o accesible por rutas paralelas.

2. **Hacer el gate verificable en runtime por los consumidores de contenido (no solo en `DlcManager`).**  
   - Problema: `cargar_contenido()` registra metadatos, pero el cargado real está delegado a otros módulos; además los tests de M120 parecen no cubrir el caso “activar sin propiedad rechaza”.  
   - Mejora concreta: (a) actualizar/agregar tests headless que validen `activar()` sin propiedad → `false` y con `registrar_propiedad()` → `true`; (b) exponer/usar un helper central (`puede_cargar_dlc(id)` = existe + compatible + posee + activo) y exigir su uso en puntos de integración (islas, NPCs, música, historia); (c) añadir telemetría/log estructurado cuando un módulo intente cargar contenido DLC sin pasar el gate.  
   - Impacto: convierte el gate en una barrera aplicada extremo a extremo, no solo en el autoload, y detecta regresiones antes de publicación.

## Conclusión final

El subsistema de DLC/M120 (`DlcManager` + servicios) muestra una base técnica sólida para la gestión de DLC: catálogo data-driven, compatibilidad semántica de versiones, persistencia como proveedor de guardado, reconciliación de DLC faltantes y, sobre todo, **un gate de propiedad/activación cerrado por defecto** incorporado tras el hallazgo crítico de 2026-11-08 (`activar`, `restore_save_data` y `cargar_contenido` rechazan sin entitlement/activación). Los escáneres anti-P2W y anti-lootbox (M95) y la validación de store (M97) aportan controles de política/configuración.

Las brechas principales no están en la ausencia de controles, sino en la **integración**: (1) `MonetizacionManager` (compras locales) y `DlcManager` (propiedad/activación) funcionan como sistemas paralelos sin puente explícito; (2) el bloqueo efectivo del contenido depende de que los módulos de gameplay consulten el estado de M120, porque `cargar_contenido()` solo registra IDs; (3) el test histórico `test_dlc_m120.gd` parece no reflejar el gate de propiedad actual, lo que reduce la confianza en la regresión. Priorizar la unificación M95↔M120 y la verificación extremo a extremo del gate resolvería los riesgos más relevantes de acceso a contenido bloqueado.

---
*Reporte generado por Glyph Cluster (Kilo Code) el 2026-11-09 mediante análisis estático de scripts y datos del repositorio.*