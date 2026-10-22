# Log 2098 - M67 tanda 3: ciclo barco end-to-end + validador ampliado (Step-5-WorkBuddy)

**Agente:** Step-5-WorkBuddy
**Modulo:** M67 - Vehiculos
**Fecha:** 2026-10-21 21:19 (GMT-3)
**GO:** director, msg 157 (ratificacion t2 + GO proxima tanda M67 #3 areas V1 pendientes)

## Contexto

- Msg 157 del director: M67 t2 RATIFICADA (3 flips G4/S2/V4 visto bueno; V1 queda [ ]
  por decision suya: "un validador que reporta areas pendientes NO consume el item");
  fila 67 del GLOBAL sincronizada a 28/131; GO para tanda M67 #3 (areas V1) o alternar M23.
- Acuse con msg 158 (verificado en disco: fila 67 = 28/131 con nota sync 23:12; worktree
  limpio en mis paths tras el CRON C). Pool canal: 158 consumido (head 158 = ultimo+1),
  quedan 94 numeros (159..252).

## Trabajo de la tanda

### 1. Ciclo barco end-to-end (checklist V2, L195) -> FLIP con cita real

- Bloque NUEVO `_test_ciclo_barco` en `game/isla-ancestral/scripts/vehiculos/test_vehiculos.gd`
  (10 checks). Va al FINAL de `_run()` para no alterar la premisa de los bloques previos
  (trampa M23 Log 2082: cambiar un bloque puede invalidar la premisa de otro).
- Secuencia: a pie/docked -> enter("barco") -> zarpar() -> 20 ticks de 0.1 s acelerando
  (crucero 6 m/s; desplazamiento acumulado por Vector3) -> atracar(null) (camino real,
  log [VEH-DOCK]) -> exit() -> controller liberado (null).
- Suite: 53 -> **63 checks / 0 fallos / EXIT 0 x3** (binario real Godot 4.7.2 console,
  headless, --path game/isla-ancestral). Piso 53 -> **63 MEDIDO** en verde.
- Regresiones medidas HOY (no heredadas): M28 test_viajes.gd EXIT 0 / 0 SCRIPT ERROR;
  M71 test_progresion.gd 83/0/EXIT 0.

### 2. Guardian anti-falso-verde probado EN ROJO

- Inyeccion de RUNTIME en `_test_ciclo_barco` (variable `Variant = null` + `get_name()`),
  sonda temporal `scripts/vehiculos/_probe_ciclo.gd`:
  SCRIPT ERROR "Invalid call. Nonexistent function 'get_name' in base 'Nil'" ->
  "[FAIL] solo 53 checks ejecutados (minimo 63)" -> EXIT 1.
- Reconfirma hallazgo t2 (Log 2089): el aborto intra-funcion NO lo nombra `_fin`
  (`_run()` sigue y llama `_fin()` de todos los bloques); lo detecta el PISO MEDIDO.
- Primer intento con `null.get_name()` directo fue PARSE ERROR estatico (no prueba el
  guardian - familia trampa 27); rehecho con la variable Variant.
- Sonda borrada en la misma operacion: 0 probes en el arbol (verificado con ls + git status).

### 3. Validador ampliado

- `validate_vehicles.gd` +bloque `_validar_ciclo_barco` (6 checks): 40 -> **46 checks /
  0 fallos / EXIT 0 x3**. Sigue reportando PENDIENTES (streaming, colisiones, HUD,
  camara, audio, animaciones, mejoras, personalizacion, baul real, controles) en vez
  de validarlos.

### 4. Medicion de dependencias de las areas V1 (hoy)

- `chunk_target`: 0 archivos fuera de validate_vehicles.gd -> M10/M61 NO exponen la API.
- `vehicle_streaming.gd`: no existe.
- Colisiones de vegetacion: `grep colision` en scripts/ solo da camera/construccion/
  animales_ia; ninguno es colision de terreno para vehiculos.
- Sin nodos 3D de vehiculos: controller plano XZ; despegar/aterrizar/sumergir/emerger
  (V3/V4) requieren iter. 2 visual.

## Marcas en 05-Checklist (CRLF preservado, sin BOM, 0 FFFD)

- **FLIP L195 (V2) -> [x]** con cita real (bloque ciclo + suite 63/0 + validador 46/0).
- Notas medidas (sin flip): L52 streaming (dueno M10/M61), L53 colisiones (dueno M50),
  L194 validador (decision del director msg 157), L196/L197 ciclos dirigible/submarino
  (eje vertical ausente).
- Totales y cabecera sincronizados: M67 = **29 [x] / 0 [?] / 102 [ ] = 131**
  (prefijo de linea; verificado por bytes: 285 CRLF, diff 8/8 lineas).

## Limites

- 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md,
  quality.yml, AGENTS.md, project.godot ni 05-Checklist ajenos. Flip ofrecido a revertir.
