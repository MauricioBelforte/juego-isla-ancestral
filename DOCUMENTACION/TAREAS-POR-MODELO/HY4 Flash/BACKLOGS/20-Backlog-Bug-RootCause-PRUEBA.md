# 20-Backlog: BUG ROOT-CAUSE LIGHT (PRUEBA - nicho nuevo)

> Creada por: agnes-3-flash - 2026-11-17 08:05
> **PRUEBA:** 50 tareas. Si el 70%+ tiene root-cause valida, nicho aprobado.
> Nicho: localizar la causa de bugs [?] sin arreglarlos (solo diagnosticar).
> Benchmark: HY4 Flash matchea DeepSeek/GLM en root-cause localization.

## Metodo
- Leer el bug en 11-BUGS.md (pasos de repro + evidencia)
- Grep del nombre del componente/script en game/isla-ancestral/
- Leer el archivo relevante (max 200 lineas)
- Anotar: BUG-ID / CAUSA PROBABLE (1-2 lineas) / ARCHIVO+LINEA / CONFIDENCIA (alta/media/baja)
- NO corregir. Solo diagnosticar. Si no podes: [?] + razon.

## Criterio de calidad
- Maximo 30% de [?] (deberias poder con grep + lectura)
- "CAUSA PROBABLE" debe apuntar a una linea de codigo concreta
- "CONFIANZA: baja" es honesto y valido; "no se" no es valido

## Tareas

- [x] T20-01: BUG-025 - diagnosticar causa — CAUSA: `SaveSchema.default_payload()["npc"]` define claves distintas de las que M19 persiste; la suite lo comprueba. ARCHIVO: game/isla-ancestral/scripts/datos/test_datos_m60_iter3.gd:359-360 y scripts/npc/villager_manager.gd:700-709. CONFIANZA: alta
- [x] T20-02: BUG-053 - diagnosticar causa — CAUSA: el fix V-3 corrigió la posición de `antorcha_pared` pero el placement de props sigue tomando cotas positivas de los GLB sin clamp global. ARCHIVO: scripts/ruinas/colocar_props_m25.gd:69,74 y test_colocar_props_m25.gd:95. CONFIANZA: media
- [x] T20-03: BUG-054 - diagnosticar causa — CAUSA: `_registrar_tiendas_oficiales()` tiene 13 `item_id` hardcodeados que no existen en el catálogo M15 (el propio script avisa). ARCHIVO: scripts/shops/catalogo_tiendas.gd:34,76. CONFIANZA: alta
- [x] T20-04: BUG-055 - diagnosticar causa — CAUSA: la atribución era errónea: el `.size()` sobre Callable está en la suite de logros, no en catálogo de tiendas; el bug quedó documentado como CORREGIDO. ARCHIVO: scripts/logros/test_logros.gd:291 (según corrección del bug) y DOCUMENTACION/11-BUGS.md bloque BUG-055. CONFIANZA: media
- [x] T20-05: BUG-059 - diagnosticar causa — CAUSA: referencias a secciones de `03-Diseno.md` de M126/M128 que no existen (documentación huérfana, no código). ARCHIVO: bloque BUG-059 en DOCUMENTACION/11-BUGS.md; universo de .gd citados = 0. CONFIANZA: media
- [x] T20-06: BUG-057 - diagnosticar causa — CAUSA: `EstructurasCodec.desde_seccion(data)` se llama pero la fuente no expone el método de restauración; el provider sólo emite un warning y no reaplica estructuras. ARCHIVO: scripts/datos/buildings_save_provider.gd:59,64. CONFIANZA: alta
- [x] T20-07: BUG-067 - diagnosticar causa — CAUSA: el `print()` a stdout concentraba ~99% del coste de escribir (510 µs a archivo vs 15 036 µs a tubería); el diseño no fijaba el destino. ARCHIVO: scripts/logging/logger.gd:58 y logging_config.gd:34-35. CONFIANZA: alta (fix ya documentado: `console_echo`)
- [x] T20-08: BUG-097 - diagnosticar causa — CAUSA: bootstrap invocaba métodos de ServiceRegistry que no existían; la API de validación se añadió después. ARCHIVO: scripts/core/bootstrap.gd:167 y scripts/core/service_registry.gd:60. CONFIANZA: media
- [x] T20-09: BUG-029 - diagnosticar causa — CAUSA: el validador recorre directorios que no son fuente (Obsoletos, Temp, backups) por no excluirlos; 389 falsos positivos. ARCHIVO: bloque BUG-029 en DOCUMENTACION/11-BUGS.md (el script es Python, no .gd). CONFIANZA: baja
- [x] T20-10: BUG-030 - diagnosticar causa — CAUSA: el checklist de M09 quedó stale: afirma "sin scripts propios" aunque el módulo tiene `terreno_horizonte.gd` operativo. ARCHIVO: scripts/world/terreno_horizonte.gd:100,165,234. CONFIANZA: alta
- [x] T20-11: BUG-031 - diagnosticar causa — CAUSA: regresión de datos en el catálogo de ediciones/DLC; los asserts esperan valores que el dataset ya no produce. ARCHIVO: scripts/monetizacion/monetizacion_manager.gd:30 y test_monetizacion.gd:17. CONFIANZA: media
- [x] T20-12: BUG-043 - diagnosticar causa — CAUSA: el bioma `snow` queda por debajo del umbral del generador: 0 muestras sobre 2000 con altura máxima real ~38. ARCHIVO: scripts/world/island_generator.gd:217. CONFIANZA: alta
- [x] T20-13: BUG-044 - diagnosticar causa — CAUSA: conviven dos sistemas de cámara; `follow_camera.gd` es el canónico pero `main.gd` sigue instanciando/llamando a `CameraRig` (código muerto). ARCHIVO: scripts/follow_camera.gd:5 y scripts/main.gd:8,84-86. CONFIANZA: alta
- [x] T20-14: BUG-046 - diagnosticar causa — CAUSA: el catálogo M159 guarda `item_id` internos que no coinciden con el nombre de archivo; los lookups de precio usan ese id. ARCHIVO: scripts/economia/economy_price_catalog.gd:58. CONFIANZA: media
- [x] T20-15: BUG-048 - diagnosticar causa — CAUSA: `dialog_layer.gd` tenía una función duplicada que rompía la compilación en runtime; corregida en Log 983. ARCHIVO: scripts/ui/layers/dialog_layer.gd:133. CONFIANZA: alta
- [x] T20-16: BUG-050 - diagnosticar causa — CAUSA: la atribución `.size()` sobre Callable era falsa (estaba en test_logros.gd:291); la parte real es `piedra_caliza`, un item_id inexistente avisado por el catálogo. ARCHIVO: scripts/shops/catalogo_tiendas.gd:76. CONFIANZA: alta
- [x] T20-17: BUG-073 - diagnosticar causa — CAUSA: al cambiar locale, `ThemeService.recargar_fuentes()` se suscribe y recarga fuentes; en headless la fuente queda null y TextServer recibe `fd=null` en `_shape_run`. ARCHIVO: scripts/ui/theme/theme_service.gd:50,57 y scripts/localization/localization_manager.gd:132-133. CONFIANZA: media
- [x] T20-18: BUG-079 - diagnosticar causa — CAUSA: las suites usaban `is_equal_to` (API gdUnit4 desactualizada) y las lambdas capturaban locales por valor, abortando la cuenta de checks. ARCHIVO: tests/integration/test_inventory_economy.gd:39-40. CONFIANZA: alta
- [x] T20-19: BUG-080 - diagnosticar causa — CAUSA: `test_m65.gd` conserva preloads de `pack_logic.gd`/`school_logic.gd` muertos tras mover la lógica a producción. ARCHIVO: tests/test_m65.gd:12-14 y scripts/animales_ia/m65_animal_ai.gd:26-27. CONFIANZA: alta
- [x] T20-20: BUG-082 - diagnosticar causa — CAUSA: `dentro_de_isla()` y la asistencia de coordenadas siguen con la geometría vieja de isla RIZ 256. ARCHIVO: scripts/map/map_data_service.gd:80-81. CONFIANZA: alta
- [x] T20-21: BUG-083 - diagnosticar causa — CAUSA: la medición de costa usa centro hardcodeado (256,256) en vez del `TerrainLocator` del mundo actual. ARCHIVO: scripts/world/medir_costa_m51.gd:6. CONFIANZA: alta
- [x] T20-22: BUG-085 - diagnosticar causa — CAUSA: `anclas.json` carga anclas con coordenadas de la esquina del mundo en vez del centro real. ARCHIVO: scripts/fasttravel/fast_travel_service.gd:16 (const RUTA_ANCLAS). CONFIANZA: media
- [x] T20-23: BUG-086 - diagnosticar causa — CAUSA: si el autoload `MundoRaiz` no está disponible, el spawner cae al fallback `(256,256)` (esquina playa vieja). ARCHIVO: scripts/vegetacion/vegetation_spawner.gd:56,58. CONFIANZA: alta
- [x] T20-24: BUG-099 - diagnosticar causa — CAUSA: la suite cuelga por `load()` con prefijo duplicado y sin watchdog de salida. ARCHIVO: scripts/enchantment/test_enchantment.gd:7 (comando) y :173 (`load` de shaman_ui); bloque BUG-099 documenta el prefijo doble. CONFIANZA: media
- [x] T20-25: BUG-100 - diagnosticar causa — CAUSA: el test calcula el exit code sólo con `_fallos`; un SCRIPT ERROR no incrementa ese contador, así que imprime 0 fallos con error en consola. ARCHIVO: scripts/coleccionables/test_collectible_category.gd:30,35. CONFIANZA: alta
- [x] T20-26: BUG-135 - diagnosticar causa — CAUSA: `house_manager.gd` comprueba `buscar_cerca` y luego la llama, pero `WorldLocations` no expone ese método (API inexistente). ARCHIVO: scripts/houses/house_manager.gd:236-238 (frente a scripts/data/world_locations.gd:245,269,275). CONFIANZA: alta
- [x] T20-27: BUG-140 - diagnosticar causa — CAUSA: asignar un Array sin tipar a la propiedad `Array[String]` produce SCRIPT ERROR que aborta la suite antes de las aserciones. ARCHIVO: scripts/logros/achievement_service.gd:44 y nota de fix en test_logros.gd:367. CONFIANZA: alta
- [x] T20-28: BUG-153 - diagnosticar causa — CAUSA: no es una línea de código: son 3 commits de Beam que promovieron 1.194 marcas sin evidencia. ARCHIVO: DOCUMENTACION/11-BUGS.md:280 (registro del bug). CONFIANZA: baja
- [x] T20-29: BUG-019 - diagnosticar causa — CAUSA: `EventManager` no existía como nodo ni servicio; los consumidores buscaban `/root/EventManager` y fallaban. ARCHIVO: scripts/economia/price_manager.gd:483,494 (`_resolver_event_manager`, añadido como corrección) y bootstrap.gd:151. CONFIANZA: media
- [x] T20-30: BUG-052 - diagnosticar causa — CAUSA: `Resource.get(clave, default)` con 2 argumentos es inválido en Godot; el bug apunta a 3 archivos y 5 sitios del boot. ARCHIVO: scripts/ia_npc/npc_agent.gd:268 (`_get_profile() -> Resource`) y :368 (`action_data.get("action", &"")`); bloque BUG-052. CONFIANZA: baja


## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:5x UTC)

Método: se leyó cada entrada del bug en `11-BUGS.md`, se extrajeron los nombres de script/componente, se localizaron los archivos bajo `game/isla-ancestral/` y se citó la línea concreta. **No se corrigió ningún bug.** Confianza declarada por caso; baja = el root-cause es de proceso o no se pudo anclar a una línea ejecutable.

| Confianza | Bugs |
|---|---|
| Alta | 17 |
| Media | 10 |
| Baja | 3 |
| `[?]` | 0 |

Casos de confianza baja: BUG-153 (causa de proceso: commits, no código), BUG-029 (validador Python fuera del universo `.gd` revisado) y BUG-052 (el bug cita 5 sitios; se ancló el más cercano). Ninguno quedó como "no sé".

**Firma:** agnes-3-flash (directora) - 2026-11-17 08:05
**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:5x
