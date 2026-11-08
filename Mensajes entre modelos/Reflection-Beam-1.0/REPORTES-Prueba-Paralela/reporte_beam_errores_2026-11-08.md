# Reporte de manejo de errores en GDScript — Isla Ancestral

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Scope:** `game/isla-ancestral/scripts/` (1259 archivos `.gd`)

## Resumen ejecutivo

- Total de archivos `.gd` en `scripts/`: **1259**.
- Archivos con al menos un `push_warning`/`push_error`/`assert`: **190** (15,1%).
- Archivos sin ningún manejo de errores: **1069** (84,9%).
- Archivos de producción (sin tests/qa/Obsoletos) con I/O (`FileAccess`/`ResourceLoader`/`DirAccess`/`JSON.parse`/`load(`) y sin manejo: **102**.
- Ocurrencias: `push_warning` = 308, `push_error` = 123, `assert(` = 3, `try:` = 0.
- Patrón dominante: **no hay `try/catch`** (GDScript 4.x no lo soporta); se usa verificación manual de retornos (`null`, `OK`, `Error`) + `push_warning`/`push_error`. Las aserciones (`assert`) son prácticamente inexistentes (solo `save_provider.gd`).

## 1. ¿Cómo se gestionan los errores en el proyecto?

El proyecto usa un estilo **defensivo y explícito**, sin excepciones:

- **Verificación de nulos** antes de usar autoloads/nodos: `get_node_or_null("/root/...")` y retorno temprano si es `null`.
  - Ej.: `bootstrap.gd:78` (`var reg := get_node_or_null("/root/ServiceRegistry")`), `weather_service.gd:53` (`var gt := get_node_or_null("/root/GameTime")`).
- **Verificación de retornos de I/O**: `FileAccess.open(...) == null`, `DirAccess.copy_absolute(...) != OK`, `ResourceLoader.exists(...)`.
  - Ej.: `writer_atomico.gd:39-42` (abrir `.tmp`), `item_database.gd:40-49` (abrir directorio).
- **Señalización**: `push_warning(...)` para condiciones degradables/recuperables y `push_error(...)` para fallos que impiden la operación.
  - Ej.: `data_store.gd:181` `push_error("[M60] Guardado slot %d falló: %s")`, `writer_atomico.gd:41` `push_error("[M60] No se pudo abrir %s")`.
- **Devolución de estado**: funciones críticas devuelven `Error`/`bool`/`Dictionary {ok, error}` para que el llamador decida.
  - Ej.: `writer_atomico.escribir_atomicamente(...) -> Error`, `crash_cache.guardar(...) -> bool`, `data_store.cargar_partida(...) -> Dictionary`.
- **Fallbacks explícitos**: cuando falta un recurso se crea un default o se usa un valor por defecto.
  - Ej.: `weather_service.gd:47-49` (`_config = WeatherConfig.new()`), `bootstrap.gd:92-94` (GameFlowManager ausente → return).
- **Logging centralizado**: `registro.gd` expone `push_warning`/`push_error` con prefijo de módulo; `data_store._log_m60` centraliza en M103.
- Convención de mensajes: prefijo `[Mxx]` con módulo y, a veces, código de error (`err=%d`).

## 2. ¿Hay funciones críticas sin manejo de errores?

Sí. 102 archivos de producción con I/O carecen de cualquier manejo. Ejemplos representativos:

- `main.gd` (escena principal): `_setup_terrain()` asume `VoxelBlockyLibrary`, `VoxelMesherBlocky`, `VoxelGeneratorFlat` sin verificar null ni errores de asignación; no hay `push_error` si `terrain` es null (solo `return` silencioso en `_setup_terrain`/`_setup_camera`).
- `world/mundo_raiz.gd`: autoload de constantes (sin I/O, bajo riesgo) — pero consumidores como `island_generator.gd` (en la lista de críticos sin manejo) cargan recursos sin verificar.
- `data/*.gd` validadores: `validar_catalogo_m159.gd`, `sincronizar_ubicaciones_mapa.gd`, `generar_seeds_islas.gd` usan `FileAccess`/`JSON` sin manejo.
- `crash/crash_cache.gd` sí tiene manejo (buen ejemplo), pero `crash/crash_sender.gd` y `crash/crash_cache` consumers carecen en varios puntos.
- `dlc/dlc_bundle_manager.gd`, `dlc/dlc_uninstaller.gd`, `dlc/sincronizar_dlc.gd`: gestión de archivos sin verificación de apertura/escritura.
- `datos/gestor_slot.gd`, `datos/gestor_backups.gd`: manipulación de slots/backups sin manejo en varios paths.
- `core/game_settings.gd`, `core/build_info.gd`: carga de configuración sin fallback documentado.

**Riesgo principal**: funciones que abren archivos (`FileAccess.open`) o cargan recursos (`load`/`ResourceLoader.load`) sin verificar el resultado, lo que puede producir `null` silencioso y crashes posteriores (ej.: `item` null en `_load_all_items` se ignora sin log en `item_database.gd:55`).

## 3. ¿Hay silenciamiento de errores (push_warning sin acción)?

Sí, se detectaron ~78 casos de `push_warning` seguidos de continuación sin `return`/fallback explícito. Casos notables:

- `core/bootstrap.gd:151` — "EventBus no encontrado como autoload" → registra otros servicios igual; si `_registry()` es null, `_registry().register("service_registry", self)` en línea 154 puede fallar.
- `clima/weather_service.gd:58` — "GameTime no encontrado; clima estático" → aceptable (degradación controlada), pero no hay flag de estado para que consumidores sepan que el clima es estático.
- `core/scene_manager.gd:37` y `:60` — "Escena inexistente" / "Fallo cambio de escena" → continúa sin notificar al llamador (devuelve void).
- `datos/writer_atomico.gd:36` — backup fallido → continúa con la escritura (riesgo de perder el `.bak`, aunque la escritura atómica sigue siendo segura).
- `data/item_database.gd:43` — carpeta inexistente → intenta crearla; si falla, `push_error` y `return` (manejo correcto aquí).
- `core/registro.gd:27` — `push_warning` genérico sin acción (es un logger, esperable).
- `fauna/*_npc.gd` (cangrejo/gaviota/jabali): `push_warning` por pocas piezas animables → solo diagnóstico, sin degradación funcional (aceptable).

**Silenciamiento real (más preocupante)**: funciones que emiten `push_warning` y devuelven `void`/continúan sin exponer el fallo al llamador, impidiendo que la UI o el sistema reaccione. Ej.: `scene_manager.cambiar_escena(...)`, `data_store.guardar_config(...)` (devuelve `Error` pero no siempre se chequea).

## 4. ¿Hay aserciones válidas en puntos críticos?

Prácticamente **no**. Solo 3 `assert(` en todo el árbol, todas en `utils/interfaces/save_provider.gd`:

- `save_provider.gd:23` `assert(false, "ISaveProvider.get_save_data() debe implementarse")`
- `save_provider.gd:29` `assert(false, "ISaveProvider.restore_save_data() debe implementarse")`
- `save_provider.gd:34` `assert(false, "ISaveProvider.get_section_name() debe implementarse")`

Son aserciones de **contrato abstracto** (métodos virtuales no implementados) — válidas pero solo cubren la interfaz de persistencia. No hay aserciones en:
- Invariantes de gameplay (vida >= 0, inventario no negativo, coordenadas dentro de isla).
- Precondiciones de funciones críticas (`slot in 1..N`, `item != null`).
- Postcondiciones de guardado/carga.

En GDScript, `assert()` se desactiva en builds de release, por lo que su uso como validación de producción es limitado; aún así, su ausencia en desarrollo reduce la detección temprana de bugs.

## 5. Sugerencias de mejora (2)

1. **Adoptar un helper de resultado unificado y usarlo en I/O crítico.**
   - Crear `utils/result.gd` (o extender `registro.gd`) con funciones `ok_or_warn(cond, msg)` y `require_not_null(obj, msg) -> bool` que devuelvan `bool` y emitan `push_error`/`push_warning` centralizado.
   - Aplicarlo en los 102 archivos de producción con I/O (especialmente `data_store`, `gestor_slot`, `dlc_*`, `island_generator`, `main`) para que cada `FileAccess.open`/`load` verifique y devuelva error propagable. Meta: que toda función de I/O devuelva `Error`/`Dictionary{ok,error}` y ningún `push_warning` quede sin acción.

2. **Introducir aserciones de desarrollo en invariantes críticos (solo dev).**
   - Añadir `assert(...)` en precondiciones de funciones de dominio: `guardar_partida(slot)` con `assert(slot >= 1 and slot <= SLOT_COUNT)`, `get_item(id)` con `assert(id != "")`, invariantes de vida/inventario.
   - Complementar con validación runtime (no solo assert, porque assert se desactiva en release) usando `push_error` + retorno temprano en los mismos puntos, para que los builds de producción sigan siendo robustos. Documentar en `GUIA-GODOT/06-registro-errores.md`.

## Conclusión final

El proyecto **gestiona errores de forma consciente y consistente en la capa de datos (M60)** — `writer_atomico`, `data_store`, `crash_cache` son buenos ejemplos de manejo fail-closed con retornos propagables y fallbacks. Sin embargo, **la cobertura es desigual**: solo ~15% de los `.gd` tienen algún manejo, y en la capa de gameplay/UI/validadores el manejo es inexistente o se reduce a `push_warning` sin acción (silenciamiento). La ausencia total de `try/catch` (esperable en GDScript) se compensa parcialmente con verificaciones manuales, pero hay ~102 archivos de producción con I/O sin verificación, lo que deja riesgo de `null` silencioso y crashes diferidos. Las aserciones son prácticamente inexistentes (3, todas en la interfaz de save). Recomendación: estandarizar un helper de resultado y aplicarlo progresivamente a los módulos de I/O y gameplay críticos, además de añadir invariantes (assert en dev + push_error en release) en funciones de dominio.
