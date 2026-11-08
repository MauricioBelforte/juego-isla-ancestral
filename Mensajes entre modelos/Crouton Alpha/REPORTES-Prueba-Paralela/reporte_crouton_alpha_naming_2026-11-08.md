# Reporte de Nomenclatura y Convenciones — `game/isla-ancestral/scripts/`

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance:** 1.260 archivos `.gd` bajo `game/isla-ancestral/scripts/`

**Conclusión final (resumen):** el proyecto tiene una base mayoritariamente consistente en `snake_case` para funciones/variables y `PascalCase` para `class_name`, pero con contaminación real y medible: (1) mezcla de español/inglés sin criterio único (carpetas, archivos, funciones), (2) nombres cortos/crípticos masivos (`v`, `d`, `n`, `tmp`, `data`) que obligan a leer contexto, y (3) archivos genéricos/ambiguos que no reflejan su contenido de dominio. No es un desastre —es un proyecto grande con múltiples autores—, pero sí hay deuda de nomenclatura que dificulta mantenimiento. Ver detalle y evidencia abajo.

---

## 1. ¿Hay variables, funciones, clases con nombres inconsistentes (snake_case vs PascalCase)?

**Veredicto: sí, pero minoritario en funciones/clases; mayoritario en estilo correcto.**

Regla Godot/GDScript esperada (y declarada en `AGENTS.md` §24): `PascalCase` para clases, `snake_case` para funciones/variables. La mayoría la cumple. Las excepciones detectadas son puntuales y de alto impacto porque quedan como-API:

| Archivo | Línea | Hallazgo |
|---|---|---|
| `game/isla-ancestral/scripts/eventos/event_manager.gd` | 856 | `func Ocupar_npcs_para_evento(...)` — función pública en `PascalCase` con `_` dentro; rompe `snake_case`. Es la única función pública en PascalCase en 500+ archivos muestreados. |
| `game/isla-ancestral/scripts/inventario/inventario_service.gd` | 318 | `func use_toolDurability(...)` — `camelCase` en función pública (`use_tool` + `Durability`). La mayoría del archivo usa `snake_case` español. |
| `game/isla-ancestral/scripts/core/event_bus.gd` | 2 | `class_name EventBus_` — `PascalCase` con sufijo `_` (raro; parece workaround de colisión con otro `EventBus`). |
| `game/isla-ancestral/scripts/ui/services/notification_service.gd` | 2 | `class_name NotificationService_` — mismo sufijo `_`. |
| `game/isla-ancestral/scripts/ui/services/tooltip_service.gd` | 2 | `class_name TooltipService_` — idem. |
| `game/isla-ancestral/scripts/interacciones/test_mock_interactable.gd` | 10 | `class_name _MockInteractable` — `_` inicial en clase (convención reservada a privados de instancia). |
| `game/isla-ancestral/scripts/interacciones/test_interacciones.gd` | 236 | variable `asInteractable` en `camelCase`. |
| `game/isla-ancestral/scripts/mineria/test_mineria.gd` | 258 | variable `rA` en `camelCase` de 2 letras (ver §3). |

**Doble `state_machine.gd`:** existe `scripts/utils/state_machine.gd` (`class_name StateMachine`, patrón genérico M111) y otro `state_machine.gd` bajo `ia_npc` (`class_name NPCStateMachine`, FSM de NPC M64). Mismo nombre de archivo, `class_name` distintos — funciona, pero `state_machine.gd` genérico no refleja dominio y colisiona en búsqueda.

**Conclusión §1:** inconsistencia baja en frecuencia, alta en visibilidad. Los 3 `*_` y las 2 funciones mal estiladas conviene normalizarlas (ver §5).

---

## 2. ¿Hay nombres en inglés y español mezclados sin criterio?

**Veredicto: sí, es el hallazgo más estructural. Patrón: carpetas y conceptos antiguos en español, código nuevo en inglés, sin migración.**

### 2.1 Carpetas bilingües sin equivalencia

Listado real de `scripts/` (extracto): `accesibilidad`, `animacion`, `animales_ia`, `arte2d`, `arte3d`, `clima`, `coleccionables`, `construccion`, `dialogos`, `diario`, `economia`, `eventos`, `inventario`, `islas`, `localizacion` **junto a** `localization`, `map` **junto a** `mapa`, `monetizacion`, `monumentos`?, `museum`, `npc`, `player`, `terrain` **junto a** `terreno`/`terrenos`, `time`, `utils`, `vegetacion`, `vehiculos`, `viajes`, `world`, `validadores`, `shops`, `store`, `saving`, `settings`, `security`, ` rendimiento` + `performance`.

Casos concretos:

- `scripts/localizacion/` vs `scripts/localization/` — dos carpetas para el mismo concepto.
- `scripts/map/` vs `scripts/mapa/` — idem.
- `scripts/terrain/` vs `scripts/terreno/` vs `scripts/terrenos/` — tres variantes para "terreno".
- `scripts/datos/` vs `scripts/data/` — idem.
- `scripts/validadores/` (español) convive con `scripts/utils/` donde viven `validation_utils.gd`, `validate_*.gd`.

### 2.2 Archivos mezclados en el mismo nombre

| Archivo | Problema |
|---|---|
| `accesibilidad/accesibilidad_manager.gd` | español + `manager` inglés |
| `accesibilidad/test_accesibilidad_headless.gd` | `test_` (en) + español + `headless` (en) |
| `coleccionables/coleccionables_manager.gd` | español + `manager` |
| `world/test_generacion_m10_atria.gd` | `test_` + `generacion` + autor |
| `viajes/travel_reserva.gd` | `travel` (en) + `reserva` (es); `class_name TravelReserva` |
| `viajes/travel_layer.gd` vs `viajes/travel_service.gd` | todo inglés en carpeta española |
| `inventario/inventario_service.gd` | `inventario` + `service` |
| `vehiculos/vehicle_manager.gd`, `vehicle_controller.gd` | carpeta es, archivos en |

Conteo orientativo sobre 1.260 archivos: ~38 archivos con raíz claramente española, ~648 con raíz inglesa (`manager/service/generator/test/qa/validate/player/data/utils/component/system/controller/preset/widget`), y decenas de híbridos (`*_manager`, `test_*`, `*_service` en carpetas españolas). No hay un criterio declarado de "carpetas en español, código en inglés" aplicado con constancia: hay carpetas en inglés (`world`, `utils`, `combat`) con archivos en español (`mundo_raiz.gd`, `agua_animada.gd` bajo `world/`).

### 2.3 Funciones: `_get_*` en inglés vs `_actualizar_*` en español

- Funciones en español (dominio): `_actualizar`, `_actualizar_botones`, `_altura`, `_altura_suelo_en`, `_calcular_centro`, `_posicionar_sobre_terreno` (`core/terrain_locator.gd:56`).
- Funciones en inglés (infra): `_get_amistad`, `_get_animal_ai`, `_get_camara_del_mundo` (híbrido), `_get_clima`, `_get_estado`, `restore_save_data`, `from_dict`.

Ejemplo directo de mezcla en un mismo archivo: `core/terrain_locator.gd` tiene `get_height(x, z)` (línea 45, inglés) y `posicionar_sobre_terreno(nodo, x, z)` (línea 56, español), ambas públicas y en la misma clase. Un lector tiene que saber ambos idiomas para autocompletar.

**Conclusión §2:** no es "bilingüe por diseño", es deuda por crecimiento multiagente. La regla práctica derivada de la evidencia es: **infra/genérico en inglés, dominio en español**, pero no está escrita ni se cumple siempre (ver §4).

---

## 3. ¿Hay nombres muy cortos o crípticos (x, y, z, tmp, data) sin contexto?

**Veredicto: sí, masivo. Es el hallazgo de mayor volumen.**

### 3.1 `x`, `y`, `z` — mayormente justificadas

`get_height(x: int, z: int)` (`core/terrain_locator.gd:45`) y `posicionar_sobre_terreno(nodo, x, z)` (línea 56) usan `x/z` como coordenadas de grid — idiomático en Godot (coordenadas = `x/z`, `y` = altura). Mismo patrón en `construccion/construccion_mundo.gd:92 altura(x, z)`, `fauna/fauna_spawner.gd:165 _altura_superficie(x, z)`, `enchantment/incense_spawner.gd:160 _altura(x, z)`. **No es defecto** cuando el docstring dice "en (x, z)"; el autoload `TerrainLocator` lo documenta bien.

### 3.2 `tmp`, `data`, `v`, `d`, `n`, `t`, `e`, `c`, `a`, `b` — crípticos reales

| Archivo | Líneas | Ejemplo | Contexto real |
|---|---|---|---|
| `audio/shuffle_sampler.gd` | 26, 45, 50 | `var tmp = _barajada[i]` | swap de Fisher-Yates; `tmp` es el elemento temporal del intercambio. Aceptable en algoritmo clásico, pero `elemento` sería autdocumentado. |
| `audio/sfx_manager.gd` | 120–122 | `var d: Dictionary = sec` / `var v: Variant = d.get(clave, -1)` | `d` = sección del catálogo, `v` = valor de variación. Requiere leer 5 líneas para entenderlo. |
| `audio/sfx_manager.gd` | 153, 155, 161, 163 | `var n := 0` / `var v: Variant = _voces[i]` | `n` = contador, `v` = voz. En bucle corto es tolerable; repetido 6+ veces en la misma función, no. |
| `accesibilidad/accesibilidad_manager.gd` | 130, 259, 273, 396 | `var v: float = snap_escala_ui(valor)` / `var d:` | `v` = valor saneado (línea 130 es claro por el nombre de la función llamada); `d` (línea 396) es opaco sin leer el bloque. |
| `animales_ia/m65_animal_ai.gd` | 105, 235, 249... | `var data: Dictionary = _individuos[id]` | `data` = datos del individuo (nodo + estado). Muy genérico; `individuo` o `estado_individuo` evitaría confusión con "datos de guardado". También `func _procesar_individuo(id, data, ...)` (línea 137) y `restore_save_data(data)` (línea 342) — aquí `data` sí es el payload de guardado y es estándar del proyecto. |
| `audio/test_audio_config.gd` | 115, 327 | `var data:` | payload de test; genérico pero habitual en tests. |
| `animacion/test_validacion_m48.gd` | 66, 70, 78, 79 | `var a:`, `var t:`, `var v =`, `var d =` | en suite de validación: `a`/`t`/`v`/`d` sin docstrings. Es el peor caso: código de test que también debe auditarse. |
| `animales_ia/test_m65.gd` | 55, 99, 156 | `var n :`, `var a =`, `var data:` | idem. |

**`restore_save_data(data)`** aparece como firma canónica en **decenas** de archivos (`weather_service.gd:215`, `economy_manager.gd:176`, `farm_service.gd:503`, `fishing_manager.gd:489`, `event_manager.gd:755`, `combat_island_system.gd:195`, etc.). Ahí `data` es **convención del proyecto** (payload de guardado) y es defendible: quien conoce el proyecto lo entiende al instante. El problema no es `data` en esa firma, sino `data`/`d`/`v` usado como "cualquier diccionario" en lógica de dominio.

**Conclusión §3:** `x/z` está bien; `data` en firmas de guardado es convención; el resto (`v`, `d`, `n`, `a`, `t`, `e`, `c`) es abreviatura sin glosario. Con 1.260 archivos, cada lector paga el costo de re-`adivinar` cada `v`.

---

## 4. ¿Hay archivos .gd con nombres que no reflejan su contenido?

**Veredicto: sí, tres familias.**

### 4.1 Genéricos de patrones (M111) que no dicen qué dominio usan

- `scripts/utils/strategy.gd` — `class_name Strategy`, `extends RefCounted`, solo `execute(context)`. Nombre = patrón, no dominio. Igual `factory.gd` (`class_name Factory`), `command.gd` (`class_name Command`), `state_machine.gd` genérico (`class_name StateMachine`). Son bases deliberadas de M111 "Código de Calidad", pero un `glob` por nombre no dice dónde se usan ni para qué sistema. Al menos el header lo aclara ("Patrón Strategy base (M111)"), así que es ambigüedad tolerable, no error.

### 4.2 `debug_curve.gd` y utilidades de un solo uso bajo `world/`

- `scripts/world/debug_curve.gd` — `extends SceneTree`, carga `res://data/light/day_curve.tres` y hace `print`. Es un script de depuración de curvas de luz, no lógica de mundo. Debería vivir en `scripts/debug/` o `scripts/tools/` (ambas carpetas existen). Su nombre dice "curva de depuración" pero su ubicación (`world/`) sugiere que es parte del generador de mundo.
- `scripts/world/flat_ground_generator.gd` — sí refleja su contenido (generador de suelo plano con colinas), pero convive con `island_generator.gd` y `world_generator.gd` sin que el nombre explique cuándo se usa uno u otro.

### 4.3 Duplicados exactos de nombre en carpetas distintas

14 nombres repetidos (muestra): `item_data.gd`, `state_machine.gd`, `localization_manager.gd`, `terrain_data.gd`, `terrain_detector.gd`, `terrain_modifiers.gd`, `clock_widget.gd`, `hotbar_widget.gd`, `minimap_widget.gd`, `status_bar.gd`, `action_prompt_overlay.gd`, etc. En Godot el `class_name` es global, así que el archivo duplicado es el que está en riesgo de colisión/ambigüedad al buscar "¿qué `clock_widget.gd` se carga?". La ruta completa resuelve, pero el nombre corto no.

### 4.4 `w_reloj.gd` (abreviatura de un carácter)

`scripts/clock/w_reloj.gd` — prefijo `w_` sin explicación en el nombre (el contenido es "Widget de Reloj HUD", M30.2). Probablemente `w_` = "widget", pero en el árbol se lee como typo. Con `clock_widget.gd` existiendo en `ui/widgets/` (duplicado, ver 4.3), hay dos archivos para "widget de reloj".

**Conclusión §4:** no hay archivos con nombre totalmente engañoso, pero sí genéricos ambiguos, duplicados y al menos un archivo de depuración mal ubicado.

---

## 5. Dos mejoras de nomenclatura sugeridas

### Mejora 1 — Unificar idioma por capa y renombrar lo híbrido (elimina §2)

- **Regla:** carpetas y `class_name` en español para dominio (`inventario/`, `viajes/`, `construccion/`), en inglés para infra genérica (`utils/`, `core/`). Archivos dentro de una carpeta de dominio siguen el idioma de la carpeta: `viajes/travel_reserva.gd` → `viajes/reserva_viajes.gd` o `viajes/travel_reserva.gd` con `class_name` coherente único; `inventario/inventario_service.gd` → decidir `inventario_servicio.gd` o aceptar `service` como sufijo fijo del proyecto y aplicarlo en todas partes.
- **Cierre de duplicados:** `localizacion/` + `localization/`, `map/` + `mapa/`, `terrain/` + `terreno/` + `terrenos/`, `data/` + `datos/` deben fusionarse en una sola carpeta cada uno (con redirect o `preload` actualizado). Es el cambio con mayor retorno: elimina la duda "¿dónde busco esto?" en cada tarea nueva.
- **Alcance seguro:** empezar por renombrar plantillas nuevas (no tocar 1.260 archivos de golpe); cada módulo, al tocarse, migra su carpeta a la regla.

### Mejora 2 — Prohibir abreviaturas de 1 letra en lógica no-trivial y renombrar los 3 `class_name _/` + 2 funciones mal estiladas (elimina §1 y §3)

- **Regla:** en funciones >10 líneas o fuera de bucles de 3 líneas, `var` de 1 letra prohibido; `data`/`d`/`v` solo permitido en firmas `restore_save_data(data)` y en tests. En algoritmo clásico (swap de `shuffle_sampler.gd:26`) se admite `tmp` si hay comentario de una línea.
- **Renombres inmediatos de alto impacto:**
  - `event_manager.gd:856 func Ocupar_npcs_para_evento` → `ocupar_npcs_para_evento`
  - `inventario_service.gd:318 func use_toolDurability` → `usar_durabilidad_herramienta` (o `use_tool_durability` si se elige inglés)
  - `EventBus_`, `NotificationService_`, `TooltipService_` → quitar sufijo `_` resolviendo la colisión original (mover clase, renombrar el otro `EventBus` si existe) o dejar constancia en comentario de por qué el `_`.
  - `sfx_manager.gd` líneas 120–122, 153–163: `d` → `seccion`, `v` → `variacion`/`voz`, `n` → `cantidad`.
- **Efecto:** quien lea el archivo sin leer el docstring entiende qué es cada variable sin ejecutar mentalmente el bucle.

---

## Anexo — Método

- Recorrido completo de `game/isla-ancestral/scripts/**/*.gd` (1.260 archivos) con scripts de análisis de texto (regex sobre `func`, `class_name`, `var/const`), más lectura manual de los archivos citados para contexto.
- Falsos positivos descartados por contexto: `class_name "de"`/`"nuevos"`/`"global"` en `sfx_manager.gd`, `w_reloj.gd`, `test_validacion_m48.gd` — son palabras en comentarios, no declaraciones; las tres clases con sufijo `_` sí son reales.
- `x/z` en firmas de terreno se consideran idiomáticas (coordenadas Godot), no defectos.
