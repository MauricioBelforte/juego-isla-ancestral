"""Backlog 20: volcar diagnosticos de root-cause (sin arreglar nada)."""
from pathlib import Path
import re

BP = Path('DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/BACKLOGS/20-Backlog-Bug-RootCause-PRUEBA.md')

D = {
'025':'CAUSA: `SaveSchema.default_payload()["npc"]` define claves distintas de las que M19 persiste; la suite lo comprueba. ARCHIVO: game/isla-ancestral/scripts/datos/test_datos_m60_iter3.gd:359-360 y scripts/npc/villager_manager.gd:700-709. CONFIANZA: alta',
'053':'CAUSA: el fix V-3 corrigió la posición de `antorcha_pared` pero el placement de props sigue tomando cotas positivas de los GLB sin clamp global. ARCHIVO: scripts/ruinas/colocar_props_m25.gd:69,74 y test_colocar_props_m25.gd:95. CONFIANZA: media',
'054':'CAUSA: `_registrar_tiendas_oficiales()` tiene 13 `item_id` hardcodeados que no existen en el catálogo M15 (el propio script avisa). ARCHIVO: scripts/shops/catalogo_tiendas.gd:34,76. CONFIANZA: alta',
'055':'CAUSA: la atribución era errónea: el `.size()` sobre Callable está en la suite de logros, no en catálogo de tiendas; el bug quedó documentado como CORREGIDO. ARCHIVO: scripts/logros/test_logros.gd:291 (según corrección del bug) y DOCUMENTACION/11-BUGS.md bloque BUG-055. CONFIANZA: media',
'059':'CAUSA: referencias a secciones de `03-Diseno.md` de M126/M128 que no existen (documentación huérfana, no código). ARCHIVO: bloque BUG-059 en DOCUMENTACION/11-BUGS.md; universo de .gd citados = 0. CONFIANZA: media',
'057':'CAUSA: `EstructurasCodec.desde_seccion(data)` se llama pero la fuente no expone el método de restauración; el provider sólo emite un warning y no reaplica estructuras. ARCHIVO: scripts/datos/buildings_save_provider.gd:59,64. CONFIANZA: alta',
'067':'CAUSA: el `print()` a stdout concentraba ~99% del coste de escribir (510 µs a archivo vs 15 036 µs a tubería); el diseño no fijaba el destino. ARCHIVO: scripts/logging/logger.gd:58 y logging_config.gd:34-35. CONFIANZA: alta (fix ya documentado: `console_echo`)',
'097':'CAUSA: bootstrap invocaba métodos de ServiceRegistry que no existían; la API de validación se añadió después. ARCHIVO: scripts/core/bootstrap.gd:167 y scripts/core/service_registry.gd:60. CONFIANZA: media',
'029':'CAUSA: el validador recorre directorios que no son fuente (Obsoletos, Temp, backups) por no excluirlos; 389 falsos positivos. ARCHIVO: bloque BUG-029 en DOCUMENTACION/11-BUGS.md (el script es Python, no .gd). CONFIANZA: baja',
'030':'CAUSA: el checklist de M09 quedó stale: afirma "sin scripts propios" aunque el módulo tiene `terreno_horizonte.gd` operativo. ARCHIVO: scripts/world/terreno_horizonte.gd:100,165,234. CONFIANZA: alta',
'031':'CAUSA: regresión de datos en el catálogo de ediciones/DLC; los asserts esperan valores que el dataset ya no produce. ARCHIVO: scripts/monetizacion/monetizacion_manager.gd:30 y test_monetizacion.gd:17. CONFIANZA: media',
'043':'CAUSA: el bioma `snow` queda por debajo del umbral del generador: 0 muestras sobre 2000 con altura máxima real ~38. ARCHIVO: scripts/world/island_generator.gd:217. CONFIANZA: alta',
'044':'CAUSA: conviven dos sistemas de cámara; `follow_camera.gd` es el canónico pero `main.gd` sigue instanciando/llamando a `CameraRig` (código muerto). ARCHIVO: scripts/follow_camera.gd:5 y scripts/main.gd:8,84-86. CONFIANZA: alta',
'046':'CAUSA: el catálogo M159 guarda `item_id` internos que no coinciden con el nombre de archivo; los lookups de precio usan ese id. ARCHIVO: scripts/economia/economy_price_catalog.gd:58. CONFIANZA: media',
'048':'CAUSA: `dialog_layer.gd` tenía una función duplicada que rompía la compilación en runtime; corregida en Log 983. ARCHIVO: scripts/ui/layers/dialog_layer.gd:133. CONFIANZA: alta',
'050':'CAUSA: la atribución `.size()` sobre Callable era falsa (estaba en test_logros.gd:291); la parte real es `piedra_caliza`, un item_id inexistente avisado por el catálogo. ARCHIVO: scripts/shops/catalogo_tiendas.gd:76. CONFIANZA: alta',
'073':'CAUSA: al cambiar locale, `ThemeService.recargar_fuentes()` se suscribe y recarga fuentes; en headless la fuente queda null y TextServer recibe `fd=null` en `_shape_run`. ARCHIVO: scripts/ui/theme/theme_service.gd:50,57 y scripts/localization/localization_manager.gd:132-133. CONFIANZA: media',
'079':'CAUSA: las suites usaban `is_equal_to` (API gdUnit4 desactualizada) y las lambdas capturaban locales por valor, abortando la cuenta de checks. ARCHIVO: tests/integration/test_inventory_economy.gd:39-40. CONFIANZA: alta',
'080':'CAUSA: `test_m65.gd` conserva preloads de `pack_logic.gd`/`school_logic.gd` muertos tras mover la lógica a producción. ARCHIVO: tests/test_m65.gd:12-14 y scripts/animales_ia/m65_animal_ai.gd:26-27. CONFIANZA: alta',
'082':'CAUSA: `dentro_de_isla()` y la asistencia de coordenadas siguen con la geometría vieja de isla RIZ 256. ARCHIVO: scripts/map/map_data_service.gd:80-81. CONFIANZA: alta',
'083':'CAUSA: la medición de costa usa centro hardcodeado (256,256) en vez del `TerrainLocator` del mundo actual. ARCHIVO: scripts/world/medir_costa_m51.gd:6. CONFIANZA: alta',
'085':'CAUSA: `anclas.json` carga anclas con coordenadas de la esquina del mundo en vez del centro real. ARCHIVO: scripts/fasttravel/fast_travel_service.gd:16 (const RUTA_ANCLAS). CONFIANZA: media',
'086':'CAUSA: si el autoload `MundoRaiz` no está disponible, el spawner cae al fallback `(256,256)` (esquina playa vieja). ARCHIVO: scripts/vegetacion/vegetation_spawner.gd:56,58. CONFIANZA: alta',
'099':'CAUSA: la suite cuelga por `load()` con prefijo duplicado y sin watchdog de salida. ARCHIVO: scripts/enchantment/test_enchantment.gd:7 (comando) y :173 (`load` de shaman_ui); bloque BUG-099 documenta el prefijo doble. CONFIANZA: media',
'100':'CAUSA: el test calcula el exit code sólo con `_fallos`; un SCRIPT ERROR no incrementa ese contador, así que imprime 0 fallos con error en consola. ARCHIVO: scripts/coleccionables/test_collectible_category.gd:30,35. CONFIANZA: alta',
'135':'CAUSA: `house_manager.gd` comprueba `buscar_cerca` y luego la llama, pero `WorldLocations` no expone ese método (API inexistente). ARCHIVO: scripts/houses/house_manager.gd:236-238 (frente a scripts/data/world_locations.gd:245,269,275). CONFIANZA: alta',
'140':'CAUSA: asignar un Array sin tipar a la propiedad `Array[String]` produce SCRIPT ERROR que aborta la suite antes de las aserciones. ARCHIVO: scripts/logros/achievement_service.gd:44 y nota de fix en test_logros.gd:367. CONFIANZA: alta',
'153':'CAUSA: no es una línea de código: son 3 commits de Beam que promovieron 1.194 marcas sin evidencia. ARCHIVO: DOCUMENTACION/11-BUGS.md:280 (registro del bug). CONFIANZA: baja',
'019':'CAUSA: `EventManager` no existía como nodo ni servicio; los consumidores buscaban `/root/EventManager` y fallaban. ARCHIVO: scripts/economia/price_manager.gd:483,494 (`_resolver_event_manager`, añadido como corrección) y bootstrap.gd:151. CONFIANZA: media',
'052':'CAUSA: `Resource.get(clave, default)` con 2 argumentos es inválido en Godot; el bug apunta a 3 archivos y 5 sitios del boot. ARCHIVO: scripts/ia_npc/npc_agent.gd:268 (`_get_profile() -> Resource`) y :368 (`action_data.get("action", &"")`); bloque BUG-052. CONFIANZA: baja',
}

txt = BP.read_text(encoding='utf-8')
if '\n## Evidencia de la tanda' in txt:
    txt = txt.split('\n## Evidencia de la tanda')[0] + '\n'
lineas = txt.splitlines(keepends=True)
n = 0
for i, raw in enumerate(lineas):
    l = raw.rstrip('\n')
    m = re.match(r'^- \[ \] (T20-\d+): BUG-(\d+) - diagnosticar causa(?: —.*)?$', l)
    if not m:
        continue
    base = re.sub(r' — .*$', '', l)
    lineas[i] = '- [x] ' + base[6:] + ' — ' + D[m.group(2)] + '\n'
    n += 1

ev = ['\n## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:5x UTC)\n\n']
ev.append('Método: se leyó cada entrada del bug en `11-BUGS.md`, se extrajeron los nombres de script/componente, se localizaron los archivos bajo `game/isla-ancestral/` '
          'y se citó la línea concreta. **No se corrigió ningún bug.** Confianza declarada por caso; baja = el root-cause es de proceso o no se pudo anclar a una línea ejecutable.\n\n')
ev.append('| Confianza | Bugs |\n|---|---|\n')
alta = sum(1 for v in D.values() if 'CONFIANZA: alta' in v)
media = sum(1 for v in D.values() if 'CONFIANZA: media' in v)
baja = sum(1 for v in D.values() if 'CONFIANZA: baja' in v)
ev.append('| Alta | %d |\n| Media | %d |\n| Baja | %d |\n| `[?]` | 0 |\n\n' % (alta, media, baja))
ev.append('Casos de confianza baja: BUG-153 (causa de proceso: commits, no código), BUG-029 (validador Python fuera del universo `.gd` revisado) y BUG-052 (el bug cita 5 sitios; se ancló el más cercano). '
          'Ninguno quedó como "no sé".\n\n')
ev.append('**Firma:** agnes-3-flash (directora) - 2026-11-17 08:05\n'
          '**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:5x\n')

BP.write_text(''.join(lineas) + ''.join(ev), encoding='utf-8', newline='\n')
print('tareas marcadas:', n, '| alta/media/baja:', alta, media, baja)
