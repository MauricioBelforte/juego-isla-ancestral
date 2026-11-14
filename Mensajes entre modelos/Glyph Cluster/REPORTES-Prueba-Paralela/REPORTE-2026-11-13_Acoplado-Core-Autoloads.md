# Reporte de auditoria de acoplamiento fuerte y dependencias circulares
# Autoloads de scripts/core/ (mas alla de EventBus / ServiceRegistry)
# Proyecto: Isla Ancestral (Godot 4.7)

**Modelo:** Glyph Cluster (modelo de arquitectura de sistemas Godot)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-13
**Alcance:** scripts/core/ de game/isla-ancestral/ + autoloads declarados en project.godot
**Regla aplicada:** no se escribio codigo del juego; solo supervision y validacion estatica de dependencias.

---

## Resumen ejecutivo

Se revisaron todos los autoloads declarados en project.godot que residen en scripts/core/, asi como los archivos de soporte preload/referenciados por ellos (invariantes, recovery, contratos, reglas). 

**Resultado clave: NO se detectaron dependencias circulares (ciclos A->B->...->A) entre los autoloads de scripts/core/.** El grafo de dependencias es un DAG que converge en nodos hoja (EventBus, ServiceRegistry), todos accedidos mediante rutas de string (`get_node_or_null("/root/...")`), sin referencias de clase directa de vuelta.

Los hallazgos relevantes son de **acoplamiento fuerte** (dependencia directa de clases/implementaciones concretas en lugar de interfaces/contratos), no de cyclicalidad. Se detallan a continuación con archivo:linea, severidad y accionable.

---

## Metodo de revision

1. Lectura de `[autoload]` en project.godot (lineas 19-137) para identificar autoloads de scripts/core/.
2. Lectura completa de cada archivo .gd en scripts/core/.
3. Busqueda de referencias entre autoloads (`get_node_or_null("/root/...")`, `class_name`, `preload`, accesos a señales/propiedades cruzadas).
4. Busqueda de referencias de regreso hacia SoftlockGuard / SoftlockRules en todo scripts/ (grep) para descartar ciclos.
5. Lectura de scripts/core/invariants/*.gd y scripts/core/recovery/*.gd (preloads de softlock_guard.gd).

Autoloads de scripts/core/ declarados en project.godot:
- EventBus (event_bus.gd) — hoja
- GameSettings (game_settings.gd) — hoja
- ServiceRegistry (service_registry.gd) — hoja
- SoftlockGuard (softlock_guard.gd)
- Bootstrap (bootstrap.gd)
- TerrainLocator (terrain_locator.gd)
- EscalasGlobales (escalas_globales.gd)
- GameFlowManager (game_flow_manager.gd)
- SceneManager (scene_manager.gd)

Archivos de scripts/core/ NO declarados como autoload (usados via class_name o preload):
- Registro (registro.gd) — utilidad estatica, sin autoload
- SesionMaster (sesion_master.gd) — definido, NO activado como autoload
- Contratos (contratos.gd) — constantes de string, sin autoload
- BuildInfo (build_info.gd) — sin autoload
- SoftlockRules (softlock_rules.gd) — `class_name` pero NO autoload en project.godot
- verificar_arquitectura.gd — script de verificacion (--script), no autoload de runtime

---

## Hallazgos

### H-01 — Acoplamiento fuerte a clase de configuracion concreta no autoload
**archivo:linea:** scripts/core/softlock_guard.gd:92, scripts/core/softlock_guard.gd:151, scripts/core/softlock_guard.gd:169, scripts/core/softlock_guard.gd:173
**Severidad:** Alto
**Accionable:** Si
**Descripcion:** SoftlockGuard depende directamente de la clase concreta `SoftlockRules` (constantes `DETECTOR_TICK_SEGUNDOS`, `VENTANA_MULTIPLES_FALLOS`, `TOAST_ACTIVO`, `TOAST_COOLDOWN`) a travez del namespace global de `class_name`. `softlock_rules.gd:9` declara `class_name SoftlockRules` pero **NO** esta registrado como autoload en project.godot, por lo que su disponibilidad depende unicamente del mecanismo global de `class_name` (pitfall documentado en GUIA-GODOT/09-godot4-migracion.md §9.17). Si se elimina `class_name` o se renombra la clase, SoftlockGuard rompe en tiempo de ejecucion sin error de compilacion. Es acoplamiento a implementacion concreta, no a una interfaz de configuracion (IConfigurable/ISoftlockConfig).
**Evidencia:** softlock_guard.gd:92 `if _timer >= SoftlockRules.DETECTOR_TICK_SEGUNDOS:`, :151 `SoftlockRules.VENTANA_MULTIPLES_FALLOS`, :169 `SoftlockRules.TOAST_ACTIVO`, :173 `SoftlockRules.TOAST_COOLDOWN`.

### H-02 — Acoplamiento fuerte a implementacion concreta de terreno/generador
**archivo:linea:** scripts/core/terrain_locator.gd:14, scripts/core/terrain_locator.gd:49
**Severidad:** Alto
**Accionable:** Si
**Descripcion:** TerrainLocator tipa su campo interno a la clase concreta `VoxelTerrain` (`var _terrain: VoxelTerrain = null`, linea 14) y llama al metodo semiprivado del generador `gen._get_island_gen()` (linea 49). Esto acopla el servicio central de posicionamiento a una implementacion concreta de terreno en lugar de a una interfaz (p. ej. `ITerrainHeightProvider` con `get_height(x,z)`). Cualquier cambio en el generador de terreno rompe TerrainLocator y todos los sistemas que lo usen para posicionar (NPCs, spawn, estructuras), que es precisamente el problema de flotamiento que M167/M168 buscaba eliminar.
**Evidencia:** terrain_locator.gd:14 `var _terrain: VoxelTerrain = null`, :49 `var gen = _terrain.generator ... gen._get_island_gen().get_height(x, z)`.

### H-03 — Acoplamiento fuerte a clases concretas de invariantes y recuperacion
**archivo:linea:** scripts/core/softlock_guard.gd:13-22, scripts/core/softlock_guard.gd:81-86, scripts/core/softlock_guard.gd:113-115, scripts/core/softlock_guard.gd:125-127
**Severidad:** Medio
**Accionable:** Si
**Descripcion:** SoftlockGuard preload e instancia directamente clases concretas de invariantes (`_JugadorInvariant`, `_MisionInvariant`, `_NpcInvariant`, `_ObjetoClaveInvariant`, `_VehiculoInvariant`, `_PuzzleInvariant`) y de recuperacion (`_CofreRecuperacion`, `_CheckpointManager`). Aunque `registrar_handler` acepta el contrato `IRecoverable` (buena pratica), la lista interna de invariantes y la delegacion a `_ObjetoClaveInvariant`/`_MisionInvariant` usan comprobacion de tipo `inv is _ObjetoClaveInvariant` y casteo `(inv as _ObjetoClaveInvariant)`, que es acoplamiento a implementacion concreta. No hay fabrica ni registro de invariantes por contrato.
**Evidencia:** softlock_guard.gd:13-22 (preloads de clases concretas), :81-86 (`_invariantes.append(_JugadorInvariant.new())` etc.), :113-115 (`if inv is _ObjetoClaveInvariant: (inv as _ObjetoClaveInvariant)...`), :125-127 (`if inv is _MisionInvariant: (inv as _MisionInvariant)...`).

### H-04 — Acoplamiento fuerte y dinamico a la forma concreta de EventBus.infra
**archivo:linea:** scripts/core/game_flow_manager.gd:67-73, scripts/core/scene_manager.gd:81-88, scripts/core/bootstrap.gd:129-132
**Severidad:** Medio
**Accionable:** Si
**Descripcion:** GameFlowManager, SceneManager y Bootstrap acceden a `bus.get("infra")` (Variant dinamico) y emiten señales sobre el objeto resultante (`infra.game_flow_changed.emit`, `infra[evento].emit`, `infra.boot_completado.emit`). Esto acopla cada llamador a la forma concreta/interna de `EventBus.infra` (debe ser un objeto con la señal esperada). Si EventBus reestructura el dominio `infra` o renombra la señal, todos los llamadores rompen en tiempo de ejecucion sin aviso del compilador. Es acoplamiento a una estructura dinamica, no a un contrato tipado de seniales.
**Evidencia:** game_flow_manager.gd:67 `var bus := get_node_or_null("/root/EventBus")`, :70 `var infra: Variant = bus.get("infra")`, :71 `infra.game_flow_changed.emit`; scene_manager.gd:82 `bus.get("infra")`, :86 `infra[evento].emit(ruta)`; bootstrap.gd:129 `var infra: Variant = bus.get("infra")`, :130 `infra.has_signal("boot_completado")`, :132 `infra.boot_completado.emit()`.

### H-05 — Acoplamiento fuerte a la forma concreta del enum Estado de GameFlowManager
**archivo:linea:** scripts/core/scene_manager.gd:102-109, scripts/core/bootstrap.gd:101-103, scripts/core/bootstrap.gd:110-111
**Severidad:** Medio
**Accionable:** Si
**Descripcion:** SceneManager y Bootstrap leen el enum `Estado` de GameFlowManager mediante acceso dinamico a diccionario (`gfm.get("Estado")`) y Bootstrap llama directamente al metodo concreto `gfm.cambiar_estado(objetivo)`. Esto acopla a la estructura concreta del enum (clave "Estado", valores con nombres "MUNDO"/"CARGANDO"/"ERROR") y a la API concreta de GameFlowManager. Es el patron del "3 magico" que M40 intento eliminar, pero sigue presente por acceso dinamico en lugar de por contrato tipado.
**Evidencia:** scene_manager.gd:106 `var valores: Variant = gfm.get("Estado")`, :107 `valores.has(nombre)`, :109 `int(valores[nombre])`; bootstrap.gd:101 `var valores = gfm.get("Estado")`, :102 `valores.has("MUNDO")`, :103 `objetivo = int(valores["MUNDO"])`, :111 `gfm.cambiar_estado(objetivo)`.

### H-06 — SoftlockRules expuesto via class_name global sin ser autoload
**archivo:linea:** scripts/core/softlock_rules.gd:9
**Severidad:** Medio
**Accionable:** Si
**Descripcion:** `SoftlockRules` declara `class_name` (linea 9) pero no figura en `[autoload]` de project.godot. Se consume globalmente desde softlock_guard.gd y desde tests (test_anti_softlock_m66.gd:150-152). Esto es inconsistente con la convencion del proyecto (autoload + `get_node_or_null("/root/...")`, ver bootstrap.gd:136-139 y comentarios de game_flow_manager.gd:66). Hace el acoplamiento de H-01 mas fragil y poco evidente para nuevos agentes.
**Evidencia:** softlock_rules.gd:9 `class_name SoftlockRules`; project.godot lineas 19-137 (no hay entrada SoftlockRules).

### H-07 — Referencias cruzadas de editor/colector (no runtime, sin ciclo)
**archivo:linea:** scripts/editor/_colector_sintaxis.gd:154-155
**Severidad:** Ruido
**Accionable:** No
**Descripcion:** `editor/_colector_sintaxis.gd` hace `preload` de `softlock_guard.gd` y `softlock_rules.gd`. Es una herramienta de editor, no participa en el grafo de autoloads de runtime, y no crea ciclo (ninguna de esas dos clases hace preload de vuelta al colector). Se cita solo para completar el mapa de referencias.

---

## Analisis de dependencias circulares (ciclos)

No se encontro ningun ciclo entre autoloads de scripts/core/. El grafo de dependencias entre ellos es:

```
Bootstrap  -> ServiceRegistry, EventBus, GameFlowManager, SceneManager
GameFlowManager -> EventBus (dominio infra)
SceneManager -> EventBus, GameFlowManager
SoftlockGuard -> EventBus, SaveManager (fuera de core), SoftlockRules, invariantes (preload)
EventBus -> (ningun autoload; hoja, solo define tipos de senial)
ServiceRegistry -> (ningun autoload; hoja, diccionario de contratos)
GameSettings -> (ningun autoload; hoja)
TerrainLocator -> (ningun autoload; hoja, usa VoxelTerrain del escenario)
EscalasGlobales -> (ningun autoload; hoja, lee JSON)
```

Todos los nodos apuntan hacia EventBus/ServiceRegistry (hojas) o hacia clases concretas fuera de scripts/core/. No hay arista de regreso hacia Bootstrap, GameFlowManager, SceneManager ni SoftlockGuard desde ninguno de ellos. Se verifico con grep que ningun script de produccion (fuera de tests y editor) referencia a SoftlockGuard de vuelta.

**Veredicto de cyclicalidad:** LIMPIO. Ausencia de dependencias circulares.

---

## Conclusiones

1. **No hay dependencias circulares** entre los autoloads de scripts/core/. El diseno cumple la regla de dependencia unidireccional hacia EventBus/ServiceRegistry (hojas).
2. **El principal riesgo arquitectonico es acoplamiento fuerte a clases concretas** (SoftlockRules, VoxelTerrain/_get_island_gen, invariantes concretas, forma dinamica de EventBus.infra y del enum Estado de GameFlowManager).
3. EventBus y ServiceRegistry están bien desacoplados (no importan dominios, solo definen tipos/diccionario), como senalan sus propios comentarios (event_bus.gd:8 "EventBus NO importa ningún dominio").

---

## Mejoras concretas (recomendaciones)

1. **Introducir una interfaz de configuracion para SoftlockRules** y registrar SoftlockRules como autoload en project.godot (o inyectar la configuracion via constructor/propiedad en lugar de leer `class_name` global). SoftlockGuard dependiria de `ISoftlockConfig` (tick, ventana, cooldown, toast activo) en lugar de de la clase concreta `SoftlockRules`. Esto elimina H-01 y H-02 (fragilidad de `class_name` no autoload) y permite sustituir la configuracion en tests sin tocar el guard.

2. **Definir una interfaz de proveedor de altura del terreno** (`ITerrainHeightProvider.get_height(x: int, z: int) -> int`) y que TerrainLocator dependa de ella en lugar de de la clase concreta `VoxelTerrain` y del metodo `_get_island_gen()`. El generador real se adapta a la interfaz. Esto elimina H-02 y protege el posicionamiento central (M167/M168) de cambios en la implementacion del terreno, evitando regresiones de flotamiento de NPCs/estructuras.

---

**Fin del reporte.**
