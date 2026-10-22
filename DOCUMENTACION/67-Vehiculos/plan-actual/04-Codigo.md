**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 67: Vehículos

## 1. Archivos Involucrados

| Archivo | Ruta | Rol |
|---|---|---|
| `vehicle_preset.gd` | `Assets/_Project/Vehicles/data/` | Modelo: tipo, física, capacidades, mejoras |
| `vehicles_catalog.tres` | `Assets/_Project/Vehicles/data/` | Catálogo: barco, dirigible, submarino, locomotora-plantilla |
| `vehicle_manager.gd` | `Assets/_Project/Vehicles/service/` | Autoload: estado, vehículo activo, entrada/salida, dock |
| `vehicle_controller.gd` | `Assets/_Project/Vehicles/service/` | Física acotada: velocidad/giro/frenado/altitud |
| `vehicle_streaming.gd` | `Assets/_Project/Vehicles/service/` | chunk_target del vehículo, LOD por altitud (M10/M61) |
| `vehicle_cargo.gd` | `Assets/_Project/Vehicles/service/` | Baúl (M14), mejoras, personalización, persistencia (M59) |
| `vehicle_dock.gd` | `Assets/_Project/Vehicles/service/` | Docking con magnetismo suave (M28) |
| `vehicle_hud.gd` | `Assets/_Project/Vehicles/ui/` | HUD del vehículo en M53: velocidad, dirección, baúl |
| `vehicle_customize.gd` | `Assets/_Project/Vehicles/ui/` | Pintura, banderas, nombre (M46/M87) |
| `validate_vehicles.gd` | `Assets/_Project/Vehicles/validators/` | Física, streaming, colisiones, presupuestos |

## 2. Funciones Clave y Logs Relacionados

### 2.1 `vehicle_manager.gd` (autoload)
```gdscript
func enter(vehicle: Vehicle) -> void:
    if not _can_enter(vehicle): return  # docked y superficie (barco)
    _active = vehicle
    VehicleController.enable(vehicle.preset)
    VehicleStreaming.set_target(vehicle)  # M10/M61: chunk_target
    VehicleHud.show(vehicle)
    CameraRig.enter_vehicle(vehicle.preset)  # 3ª persona, M57
    Audio.play(vehicle.preset.sounds)  # M43 con LOD
    VehicleEvents.enter.emit(vehicle)
    LOGS.vehicle("VEH-ENTER", {"id": vehicle.id})

func exit() -> void:
    VehicleController.disable()
    VehicleStreaming.set_target(Global.player)  # volver al jugador
    VehicleHud.hide(); CameraRig.exit_vehicle()
    Audio.stop_all_vehicle()  # M43: sin fugas
    LOGS.vehicle("VEH-EXIT", {})
```

### 2.2 `vehicle_controller.gd` (física acotada)
```gdscript
func _physics_process(delta: float) -> void:
    var p: VehiclePreset = _preset
    _speed = move_toward(_speed, _input_throttle() * p.max_speed, p.accel * delta)
    _yaw += _input_steer() * p.turn_rate * delta
    if _preset.type == PRESET_SUBMARINE:
        _depth += _input_dive() * p.dive_rate * delta  # límite −40 m
    elif _preset.type == PRESET_AIRSHIP:
        _alt = clamp(_alt + _input_climb() * p.climb_rate * delta, 0.0, p.max_alt)
    var surface_y: float = Water.surface_y(_pos)  # M51: solo lectura visual
    _pos += _dir * _speed * delta
    _clamp_to_bounds()  # no atravesar islas/rocas (M50)
    VehicleStreaming.notify_position(_pos)  # M10/M61
```

### 2.3 `vehicle_dock.gd` (magnetismo suave)
```gdscript
func try_dock(mooring: Mooring) -> bool:
    var angle_diff := _angle_to(mooring.global_rotation)
    if angle_diff > MAX_DOCK_ANGLE: return false  # permitir reintento
    _active.global_position = mooring.dock_position
    _active.global_rotation = mooring.dock_rotation
    VehicleEvents.docked.emit(mooring)
    LOGS.vehicle("VEH-DOCK", {"mooring": mooring.id})
    return true
```

## 3. Contratos de Integración (Eventos del EventBus M07)

| Evento | Emisor | → Vehículos |
|---|---|---|
| `VEHICLE_ENTERED` | vehicle_manager | M53 HUD, M57 cámara, M43 audio |
| `VEHICLE_EXITED` | vehicle_manager | M53/M57 restauración, M43 stop |
| `VEHICLE_DOCKED` | vehicle_dock | M28 viajes, M59 persistencia |
| `VEHICLE_UPGRADED` | vehicle_cargo | M14 baúl, persistencia M59 |
| `PHOTO_POSE_REQUEST` | M56 | Pasajeros posan si aplica (foto del barco) |

## 4. Logs Relacionados (Sistema de Logs del Proyecto)

El módulo usa el sistema central de logs de consola (M118): prefijo `[VEH]` en desarrollo y canal depurado en builds (sección 18 de AGENTS.md); rotación automática fuera de `Assets/`.

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Parcial (con dudas)

### Lo que hice
- Documenté el módulo 67 completo (diseño técnico de Godot 4): presets de 3 vehículos + plantilla locomotora condicional, física acotada sin fluidos, streaming con chunk_target y LOD por altitud, docking con magnetismo suave, baúl (M14) y mejoras persistentes (M59), personalización cozy, audio/animaciones con LOD y validación.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Verificar en runtime: no hay editor Godot ni build en este entorno; los `.gd` de esta documentación son prototipos de diseño que se escribirán en la fase de implementación.
- `[?]` Confirmar si la locomotora existe: el plan maestro la marca "si existe" — depende de que M68 (Transporte y Navegación) defina el ferrocarril; por eso está como plantilla condicional.
- `[?]` Confirmar la interacción exacta con la superficie del agua (M51): el diseño asume lectura visual de la superficie, sin simulación de olas sobre el casco.

### Intentos fallidos / decisiones
- Decidí NO usar simulación de fluidos (costo alto); el barco lee la superficie de M51.
- Decidí que el vehículo es el chunk_target del loader (M10/M61): es la única forma de que el dirigible no rompa el streaming.
- Decidí sin combustible (cozy) y con reparaciones opcionales (M15) — alineado con la filosofía del proyecto.

### Recomendaciones para el próximo agente
- Al implementar: coordinar con M68 el contrato de la locomotora (si el ferrocarril existe) y con M51 la API de la superficie del agua.
- Probar a fondo: dirigible a 60 m sobre terreno no generado (LOD), barco contra rompeolas, submarino en cuevas subacuáticas (M25).
- Probar la cámara con Reduce Motion (M58) — el mareo es el riesgo #1 de los vehículos.

## 6. Estadio real del codigo (medido 2026-10-21, Step-5-WorkBuddy)

> Las secciones 1-5 documentan prototipos de diseno (2026-08-17) con rutas Unity
> (`Assets/_Project/Vehicles/`). El codigo REAL vive en el proyecto Godot y se midio
> en disco el 2026-10-21:

| Archivo real | Ruta real | Rol |
|---|---|---|
| `vehicle_manager.gd` | `game/isla-ancestral/scripts/vehiculos/` | Autoload "Vehiculos" (`project.godot:81`): estado, vehiculo activo, enter/exit, dock |
| `vehicle_preset.gd` | `game/isla-ancestral/scripts/vehiculos/` | Resource con `class_name`: tipo, fisica, capacidades, condicional |
| `vehicle_controller.gd` | `game/isla-ancestral/scripts/vehiculos/` | RefCounted puro: fisica acotada (velocidad/giro/frenado/reversa) |
| `vehicles.json` | `game/isla-ancestral/data/vehiculos/` | Catalogo data-driven (4 entradas; locomotora condicional) |
| `test_vehiculos.gd` | `game/isla-ancestral/scripts/vehiculos/` | Suite headless con guardia anti-falso-verde de 3 capas |

### 6.1 Presets reales (vehicles.json, medido 2026-10-21)

| id | tipo | vel_max / crucero (m/s) | giro (rad/s) | frenado | altitud/profundidad max (m) | baul (slots) | reversa | condicional |
|---|---|---|---|---|---|---|---|---|
| barco | agua | 12 / 6 | 1.6 | 4.0 | - | 12 | si | - |
| dirigible | aire | 15 / 8 | 1.0 | 3.0 | 60 | 8 | si | - |
| submarino | subagua | 8 / 4 | 1.2 | 3.5 | -40 | 10 | si | - |
| locomotora | riel | 20 / 20 | 0.0 | 6.0 | - | 16 | no | "M68" |

### 6.2 API real de VehicleManager (medido 2026-10-21)

- Estado: `preset_activo`, `controller`, `vehicle_id_activo`, `docked`.
- Catalogo: `presets_count()`, `get_preset(id)`.
- Ciclo: `enter(vehicle_id)` / `exit()` / `atracar(dock)` / `zarpar()` / `avisar(mensaje)` - todos devuelven `{ok, motivo}`.
- Conduccion (tests/integradores): `tick_conduccion(delta, acelerar, girar, frenar)` -> `{ok, velocidad, rumbo}`.
- Controller (RefCounted puro): `aplicar(delta, acelerar, girar, frenar)`, `desplazamiento(delta) -> Vector3`, `velocidad_crucero()`.
- Persistencia (M59): `get_section_name()` = "vehiculos", `get_save_data()`, `restore_save_data(data)` (cozy: restaura docked y a 0).
- Eventos (EventBus.vehicle): `vehicle_entered`, `vehicle_exited`, `vehicle_docked`, `vehicle_aviso`.
- Logs: `[VEH-ENTER]`, `[VEH-EXIT]`, `[VEH-DOCK]`, `[M67][AVISO]`.

### 6.3 Flujo de streaming (chunk_target) - estadio real

- Diseno (03-Diseno.md sec. 3.2): chunk_target = vehiculo al conducir; LOD por altitud; islas cercanas antes que terreno lejano.
- Real (iter. 1): `vehicle_controller.gd` expone `aplicar()` / `desplazamiento()` como CONTRATO para que el integrador de nodos 3D mueva el Node3D. El chunk_target real con M10/M61 y el LOD por altitud quedan para la iter. 2 (V1/V2, dueno visual).
- Medido: `vehicle_streaming.gd`, `vehicle_cargo.gd`, `vehicle_dock.gd` y `vehicle_hud.gd` NO existen en disco (find = 0).

### 6.4 Condicion de la locomotora (real, testeado)

- `vehicles.json` trae la entrada `locomotora` con `"condicional": "M68"`.
- `_cargar_catalogo()` borra la locomotora del catalogo activo si no existe el autoload `/root/Transporte` (M68). Medido: no hay autoload Transporte en project.godot.
- Verificado en la suite de hoy: `presets_count() == 3` (locomotora omitida; M68 ausente).

### 6.5 Suite (medido 2026-10-21, binario real Godot 4.7.2 headless)

- `test_vehiculos.gd`: **40 checks / 0 fallos / EXIT 0** (0 SCRIPT ERROR propios; los 2 del boot son ajenos: `pause_layer.gd:79` -> `ui_root.gd:50`).
- Guardia anti-falso-verde de 3 capas: `CHECKS_MINIMOS = 40` medido, 8 bloques con `_fin()`, `_summary()` en `call_deferred` aparte (no cuelga).
- Fix aplicado en esta tanda: L146 tenia un `%` literal dentro del string de formato ("40% vel max") que rompia el `%.2f` (`ERROR: String formatting error: unsupported format character`). El check corria igual (error no fatal) pero el mensaje de fallo salia roto. Escapado a `40%%`; verificado pos-fix: el error desaparece y la suite sigue 40/0.

#### 6.5.1 Tanda 2 Step-5-WorkBuddy (2026-10-21, Log 2089) — suite endurecida y validador

- `test_vehiculos.gd` tras la tanda 2: **53 checks / 0 fallos / EXIT 0 x3** (piso `CHECKS_MINIMOS` actualizado de 40 a **53 MEDIDO**). Bloques nuevos:
  - `_test_delta_frameindependiente` (6 checks, checklist G4): 2 s simulados a 30 FPS (60 ticks de 1/30 s) vs 60 FPS (120 ticks de 1/60 s) -> misma velocidad **6.000000** en ambas (medido por sonda temporal borrada); desplazamiento acumulado 6.100000 vs 6.050001 m (valor analitico 6 m; la diferencia es discretizacion Euler, no bug); `delta <= 0` es no-op; `rumbo` con `wrapf` en [0, TAU) tras 20 s de giro.
  - `_test_salida_velocidad` (5 checks, checklist S2): `exit()` rechaza salir sin dockear a 12 m/s con motivo nombrado, conserva el vehiculo activo y permite salir tras frenar.
  - `_test_dock_zarpar` (+2 checks): se agrego el camino real `enter -> zarpar -> atracar` porque el `atracar(null)` previo salia por el early return "ya docked" y **el log `[VEH-DOCK]` nunca se ejercitaba**.
- **Guardián probado EN ROJO** (inyeccion de aborto de runtime en una copia-sonda, borrada en la misma operacion): EXIT 1 con "solo 47 checks ejecutados (minimo 53)". **Hallazgo de la guarda (Godot 4.7.2):** el `SCRIPT ERROR` mata SOLO la funcion del bloque; `_run()` sigue y llama `_fin()` igual, asi que la capa de bloques NO nombra el bloque abortado — lo detecta el **piso medido** (47 < 53). La capa `_fin` sirve para abortos de `_run()` mismo. Documentado para no sobre-stimar la capa de bloques en otras suites.
- **Validador nuevo** `scripts/vehiculos/validate_vehicles.gd` (diseno §1 "validators/validate_vehicles.gd"): **40 checks / 0 fallos / EXIT 0 x3**. Cubre catalogo (esquema/ids/tipos/condicional M68), presets contra la tabla 03-Diseno §3.1 (12/6/12 slots, 15/60/8, 8/-40/10, 20/giro 0/16) e invariantes de fisica del controller. **Probado en rojo por tamper** del catalogo (12.0 -> 13.0): EXIT 1 con `[FAIL] barco vel max 12 (§3.1)`; restaurado y verificado por sha256. El validador **reporta sus PENDIENTES** (streaming, colisiones, HUD, camara, audio, mejoras, personalizacion, baul real) en vez de validarlos: el item V1 del checklist queda `[ ]` con nota de entregable parcial.
- Logs VEH-* de la corrida real: `[VEH-ENTER]` x14, `[VEH-EXIT]` x14, `[VEH-DOCK]` x1; unico ERROR del boot ajeno (singleton `AnimationService`).

## 7. Notas del Agente (Step-5-WorkBuddy, 2026-10-21)

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21
**Estado:** tanda 2 sobre la iter. 1 (nucleo V0): suite endurecida (+13 checks, 2 bloques nuevos) + validador del modulo; 3 flips con cita. M67 = 28 [x] / 103 [ ] / 0 [?] = 131.

### Lo que hice en la tanda 2 (Log 2089)
- Endureci `test_vehiculos.gd`: bloques `_test_delta_frameindependiente` (G4) y `_test_salida_velocidad` (S2) + el camino real de `atracar()` en `_test_dock_zarpar` (el log `[VEH-DOCK]` no se ejercitaba). Piso 40 -> **53 MEDIDO** en verde (3x).
- Guardián en rojo por inyeccion de aborto de runtime: EXIT 1, "solo 47 checks (minimo 53)". Hallazgo: en 4.7.2 el aborto mata solo la funcion del bloque y `_run()` sigue llamando `_fin()`, asi que detecta el **piso**, no la capa de bloques.
- Cree `validate_vehicles.gd` (40 checks, EXIT 0 x3; probado en rojo por tamper del catalogo con restauracion por sha256). Reporta sus areas PENDIENTES en vez de validarlas.
- 3 flips con cita: G4 (L78), S2 (L171), V4/logs (L198). 4 notas honestas en `[ ]` que siguen: D2/I3 (techo de altitud, sin fisica vertical), J2 (entrada "en superficie"), T5 (avisos sin localizar).
- Sonda temporal de valores (v30/v60/desplazamiento) borrada en la misma operacion: 0 probes en el arbol.

### Lo que NO esta resuelto (honestidad)
- Los 103 `[ ]` restantes son verbos de implementacion (navegar, volar, sumergir, colisiones, HUD, camara, audio, mejoras, personalizacion, baul real) con duenos externos (M51/M50/M32/M49/M52/M43/M53/M14/M59/M57/M12/M70). Sin corrida no se flippean.
- No hay nodos 3D de vehiculos en el repo: la iter. 2 (V1/V2) sigue pendiente con dueno visual. El controller sigue siendo logico puro (plano XZ, sin altitud/profundidad).
- V1 (`validate_vehicles.gd`) quedo `[ ]` a proposito: el archivo existe y valida fisica + catalogo + presupuestos, pero streaming y colisiones no se pueden validar hasta la iter. 2. Entregable parcial documentado, no inflado.
- No toque `achievement_service.gd` (M72): otro agente lo esta editando en el worktree compartido (mtime 15:13 de hoy, +31/-14 sin commitear) y quedo con Python-ismos `False`/`True` que rompen el autoload al boot. Reportado al director.

## 8. Notas del Agente — tanda 3 (Step-5-WorkBuddy, 2026-10-21, Log 2098)

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21
**Estado:** tanda 3 sobre las areas V1 pendientes (GO del director, msg 157): ciclo barco end-to-end + validador ampliado + medicion de dependencias. M67 = 29 [x] / 102 [ ] / 0 [?] = 131.

### Lo que hice en la tanda 3 (Log 2098)
- Bloque NUEVO `_test_ciclo_barco` en `test_vehiculos.gd` (10 checks, va al final de `_run()` para no alterar la premisa de los bloques previos — trampa M23): a pie/docked -> enter -> zarpar -> 2 s acelerando (crucero 6 m/s, desplazamiento medido por Vector3) -> atracar camino real `[VEH-DOCK]` -> salir -> controller liberado. Suite 53 -> **63 checks / 0 fallos / EXIT 0 x3**; piso 53 -> **63 MEDIDO**.
- Guardián en rojo por inyeccion de RUNTIME (variable `Variant = null`, no parse error): "solo 53 checks (minimo 63)", EXIT 1. Reconfirma el hallazgo de t2: el aborto intra-funcion no lo nombra `_fin`, lo detecta el piso. Sonda borrada en la misma operacion (0 probes en el arbol).
- `validate_vehicles.gd` +bloque `_validar_ciclo_barco` (6 checks): 40 -> **46 checks / 0 fallos / EXIT 0 x3**.
- Regresiones medidas HOY (no heredadas): M28 `test_viajes.gd` EXIT 0 / 0 SCRIPT ERROR; M71 `test_progresion.gd` 83/0/EXIT 0.
- Flip V2 (L195) con cita real. Notas medidas en L52 (streaming), L53 (colisiones), L194 (validador), V3/V4 (eje vertical ausente).

### Medicion de dependencias de las areas V1 (hoy)
- `chunk_target`: 0 archivos fuera de `validate_vehicles.gd` -> M10/M61 NO exponen la API. `vehicle_streaming.gd`: no existe. Streaming queda con dueno externo M10/M61.
- Colisiones de vegetacion: `grep colision` en `scripts/` solo da camera/construccion/animales_ia; ninguno es colision de terreno para vehiculos. Dueno externo M50.
- Sin nodos 3D de vehiculos: el controller sigue plano XZ. Despegar/aterrizar/sumergir/emerger (V3/V4) requieren iter. 2 visual.

### Lo que NO esta resuelto (honestidad)
- V1 sigue `[ ]` por decision explicita del director (msg 157): el validador existe (46 checks) pero reporta PENDIENTES (streaming, colisiones, HUD, camara, audio, animaciones, mejoras, personalizacion, baul real, controles) y eso no consume el item.
- Los 102 `[ ]` restantes siguen con duenos externos; sin corrida no se flippean.
- 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados. Flip ofrecido a revertir.

### Tanda 4 (Step-5-WorkBuddy, 2026-10-22, Log 2112) - mejoras por nivel data-driven

- **Alcance:** opcion 1 del ruteo del director (msg 165, tras cola activa vacia):
  "M67 #4 (areas V1 pendientes...): implementacion de las areas con los datos de
  configuracion". Se implementaron las areas que dependen SOLO de datos de
  configuracion; las que exigen duenos externos (M10/M61 streaming, M50
  colisiones, M49 faroles, M53 HUD) siguen `[ ]` con nota medida.
- **`vehicle_preset.gd`:** campos nuevos `mejoras: Dictionary` (nivel_max,
  por_nivel, topes) y `nivel: int`; API `velocidad_max_efectiva()`,
  `giro_efectivo()`, `baul_slots_efectivo()`, `altitud_max_efectiva()`,
  `subir_nivel()`, `bajar_nivel()`. Nivel 0 = valores base (comportamiento
  historico intacto, verificado por las 3 corridas verdes de la suite).
- **`vehicle_controller.gd`:** `aplicar()` consume los valores EFECTIVOS
  (mejoras incluidas) y agrega `rapida: bool` (default TRUE = comportamiento
  historico hasta vel_max; false = techo velocidad_crucero, checklist C2).
  TRAMPA evitada: la 1ra version puso `rapida=false` por default, lo que
  cambiaba el techo historico de vel_max a crucero y rompia los checks de
  clamp existentes; se invirtio la semantica antes de correr nada.
- **`vehicles.json`:** bloque `mejoras` por vehiculo con topes que coinciden con
  la columna Mejoras de 03-Diseno §3.1 (dirigible altitud 90, submarino baul 16).
  Nivel 3 medido: barco vel 15 (tope) / giro 2.2 / baul 18; dirigible vel 18
  (tope) / altitud 90 (tope §3.1); submarino vel 10 (tope) / baul 16 (tope
  §3.1); locomotora vel 26 (tope) con giro SIEMPRE 0 (riel).
- **Suite `test_vehiculos.gd`:** bloque nuevo `_test_mejoras` (36 checks) al
  final de `_run()` (no altera la premisa de los bloques previos, leccion M23):
  carga del JSON real por `FileAccess`, nivel 0 = base, subir/bajar con topes,
  techos §3.1, locomotora directo del JSON (riel sin giro con mejoras),
  controller clampeando a 15 con mejoras, modo crucero a 6, reversa a 40% del
  efectivo. Piso 63 -> **99 MEDIDO en verde** (99/0/EXIT 0 x3, binario real).
  Guardian EN ROJO por inyeccion de RUNTIME (`Variant = null`, no parse error):
  "solo 63 checks (minimo 99)", EXIT 1; sonda borrada y sha256 restaurado.
- **Validador `validate_vehicles.gd`:** `_validar_mejoras()` (44 checks):
  niveles 0..3 de cada clave declarada contra la formula base+inc*nivel con
  tope, topes §3.1 como evidencia externa, locomotora sin giro. 46 -> **90
  checks / 0 fallos / EXIT 0**.
- **Regresiones medidas HOY (no heredadas):** M28 test_viajes 0 fallos/EXIT 0;
  M71 test_progresion 83/0/EXIT 0.
- **Flips con cita:** L43 (crucero/rapida/timon/reversa) y L123 (mejoras de
  velocidad/giro por nivel) -> `[x]`. L124 NO flippeada (compuesta: baúl sí,
  faroles = M49 dueno externo). M67 = **32 [x] / 0 [?] / 99 [ ] = 131**
  (prefijo de linea; cabecera y Totales sincronizados; LF puro preservado).
