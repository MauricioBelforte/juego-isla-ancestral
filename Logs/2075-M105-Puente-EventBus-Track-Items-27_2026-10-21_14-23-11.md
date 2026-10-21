# Log 2075 - M105 Telemetria - Puente EventBus -> track_* (item 27)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 14:23 (GMT-3)
**Modulo:** M105-Telemetria-De-Gameplay
**Item del backlog:** 27 - "M105-Telemetria (129/162): resolver/degradar los 45 [?] con
justificacion o fix" (RAMA 1: el director ordeno "Segui COLA V3" en el msg 348).
**Log reservado:** 2075 (pool medido justo antes: cabeza 2075 -> 2076).
**Reporte al director:** 349 (pool de canal medido justo antes: cabeza 349 = ultimo 348 + 1).

---

## 1. Medicion previa (antes de escribir cualquier cifra)

| Dato | Valor medido | Como |
|---|---|---|
| Items del checklist | 162 | conteo por PREFIJO de linea |
| `[x]` / `[?]` / `[ ]` | 129 / 33 / 0 | `^- \[x\]`, `^- \[\?\]`, `^- \[ \]` |
| `[?]` segun el backlog | "45" | CIFRA VENCIDA: el real es 33 |
| Codificacion del checklist | UTF-8 sin BOM, LF puro, 29.483 B | conteo de bytes |

Conclusion: el universo a resolver/degradar es **33**, no 45.

## 2. Hallazgo principal: 13 track_* con 0 llamadores de produccion

Medido con `grep -rn "\.<track_X>(" --include=*.gd scripts/` excluyendo `test_*`:

```
track_tutorial_first_completed             prod=0   test=4
track_resource_first_collected             prod=0   test=3
track_house_first_built                    prod=0   test=3
track_npc_first_interaction                prod=0   test=1
track_puzzle_first_completed               prod=0   test=3
track_seal_first_obtained                  prod=0   test=3
track_travel_first_completed               prod=0   test=3
track_island_first_discovered              prod=0   test=1
track_museum_first_visited                 prod=0   test=1
track_festival_first_participated          prod=0   test=1
track_community_project_first_completed    prod=0   test=1
track_chapter_completed                    prod=0   test=5
track_difficulty_perceived                 prod=0   test=2
```

Se descartaron patrones alternativos de llamada antes de afirmarlo: `grep -rn "track_"` sobre
`scripts/` sin el director ni tests da **17** apariciones y NINGUNA es un tracker (son
`track_id` de audio/DLC). La unica emision de produccion era `session_started`/`session_ended`,
que sale del propio director.

**Consecuencia:** el item que afirma "M105 ya emite los 11 eventos 'first'" era un FALSO VERDE.
Las 11 funciones `track_*_first_*` SI existen (esa parte de la cita era correcta): lo que
faltaba era el consumidor. En una partida real no se emitia ningun evento "first".

## 3. Premisa vencida del item 228 (integracion M22)

El item decia: "requiere senyal prereq_met -> m105; disenio documentado, implementacion requiere
M22 iteracion adicional". **Falso por medicion:**

- `EventBus.quest.prereq_met(seal_id: String)` EXISTE (`scripts/core/event_bus.gd`).
- `scripts/historia/story_manager.gd:187` YA lo emite en produccion, dentro de `marcar_sello()`,
  con comentario propio: "Emite EventBus.quest.prereq_met (M07) para M21/M71/M38".
- M105 no figuraba entre los consumidores. Lo que faltaba era **este lado**, no una iteracion de M22.

## 4. Emisores de produccion por senal candidata (la tabla que decide el mapeo)

Medido con `.X.emit(` sobre `scripts/`, excluyendo `test_*`:

| Senal | Emisores prod. | Decision |
|---|---|---|
| `quest.prereq_met` | 1 (`story_manager.gd:187`) | MAPEADA a `track_seal_first_obtained` |
| `quest.quest_completed` | 1 (`secondary_stories_service.gd`) | NO: es mision secundaria (M23), no capitulo; mapearla inventaria ids |
| `diary.entrada_nueva` | 2 (`diary_service`, `museum/donation_service`) | NO: el tracker espera `museo_id`, no una entrada |
| `progresion.categoria_completa` | 1 (`diary_service`) | NO: sin tracker equivalente |
| `item_added` | 0 | NO: arista muerta en runtime |
| `island_loaded` | 0 | NO: arista muerta en runtime |
| `travel_started` | 0 | NO: arista muerta en runtime |
| `dialog_finished` | 0 | NO: arista muerta en runtime |
| `purchase_done` | 0 | NO: arista muerta en runtime |

De 13 trackers, hoy **1** tiene productor real medible. El resto sigue sin fuente de datos: eso
es lo que hay que decidir, no cablear a ciegas.

## 5. Entregado (codigo, no solo diseno)

1. **`game/isla-ancestral/scripts/telemetry/telemetry_bridge.gd`** (NUEVO, 7.930 B, 204 lineas,
   `RefCounted`, UTF-8 sin BOM, LF):
   - Tabla declarativa `ENTRADAS` con 1 fila verificada.
   - `conectar(director, bus)`: solo conecta si AMBOS extremos existen (senal en el bus + metodo
     en el director). Fail-closed con motivo explicito.
   - Idempotente (guarda el `Callable` por clave) + `desconectar()` simetrico.
   - `verificar(director, bus)`: auditoria de la tabla sin conectar (la suite prueba que no se
     podra en silencio).
   - `cobertura()`: declaradas / conectadas / claves / despachos / descartes / motivos.
   - SIN `class_name` a proposito (trampa 123: un class_name nuevo no existe para `--script`
     hasta regenerar la cache). Se instancia con `load(...).new()`.
   - No saltea la privacidad: llama a `track_*`, que filtran por `opt_in`.
2. **`telemetry_director.gd`** (+34 lineas): `_ready()` agrega `call_deferred("_conectar_bridge")`;
   se agregan `_conectar_bridge()` (idempotente, nunca lanza) y `bridge_cobertura()`.
   **0 archivos de M22 ni del EventBus tocados** (dependencia M105 -> M22).
3. **`test_telemetry_bridge_m105.gd`** (NUEVO, 14.181 B, 335 lineas, 9 bloques).
4. **`04-Codigo.md`** de M105: seccion "Notas del Agente - iter. 9" (+6.681 B; 395 CRLF, 0 LF
   sueltos, sin BOM, 0 U+FFFD).

## 6. Verificacion medida

### Suite nueva

```
corrida 1: EXIT=0 SCRIPT_ERROR=0  === TEST TELEMETRIA M105 ITER9: 0 fallo(s) de 38 cheque(s) ===
corrida 2: EXIT=0 SCRIPT_ERROR=0  === TEST TELEMETRIA M105 ITER9: 0 fallo(s) de 38 cheque(s) ===
corrida 3: EXIT=0 SCRIPT_ERROR=0  === TEST TELEMETRIA M105 ITER9: 0 fallo(s) de 38 cheque(s) ===
```

Piso `CHECKS_MINIMOS = 38` **MEDIDO**, no estimado: la primera version puso 40 de memoria y el
propio piso la delato con 38 reales. El piso funciono antes de que yo lo supiera.

### Guardian probado EN ROJO (3 inyecciones, sondas borradas, 0 residuales)

```
sonda A (aborto de RUNTIME en un helper): EXIT=1  motivos=['despacho', 'minimo 38']  OK
sonda B (se suprime el _fin que CIERRA):  EXIT=1  motivos=['despacho']              OK
sonda C (piso a 99):                      EXIT=1  motivos=['minimo 99']             OK
```

Las 3 **terminan** (no se cuelgan): el resumen vive en un `call_deferred` SEPARADO del de
`_ejecutar` (trampa 61 / hallazgo 2066).

### Regresion del modulo (5 suites, se toco telemetry_director.gd)

| Suite | Resultado |
|---|---|
| `test_telemetry` | 16 checks, 0 fallos, EXIT 0 |
| `test_telemetria_iter5` | 10 checks, 0 fallos, EXIT 0 |
| `test_telemetria_iter6` | 11 checks, 0 fallos, EXIT 0 |
| `test_telemetria_iter7` | 27 checks, 0 fallos, EXIT 0 |
| `test_telemetria_iter8` | 17 checks, 0 fallos, EXIT 0 |
| **Total** | **81 checks / 0 fallos / 0 SCRIPT ERROR** |

## 7. Dos defectos PROPIOS corregidos en la iteracion (no eran bugs ajenos)

1. **Dos aserciones mias estaban mal; el contrato era otro.** `track_seal_first_obtained` usa la
   clave de tracker `&"sello"`, NO el id: el evento es "el PRIMER sello" y se emite UNA vez por
   sesion, sea cual sea el id. Yo habia asertado "un sello distinto si emite", es decir lo
   contrario del diseno (familia de la trampa 88: dos errores que se cancelan dan verde). Se
   corrigio **la asercion**, no el codigo, y ahora se afirma el contrato real (1 evento + el
   puente despachando en cada emit).
2. **La sonda B original era un Parse Error.** El `replace` usaba un solo tab y el archivo tiene
   DOS apariciones de `_fin("despacho")` con DOS tabs: comio un tab y dejo
   `Expected statement, found "Indent"`. Un rojo por parseo NO prueba el guardian (trampa
   27/62). Se rehizo quitando la aparicion **de cierre** (`rfind`) y entonces si nombro el bloque.

## 8. Propuestas de marca (NO aplicadas: los flips los aplica el director)

- **Item 228 (M22 notificar a M105):** `[?]` -> `[x]` con cita a este Log. La senal existia y ya
  se emitia; el consumidor ya esta implementado y verificado.
- **Item 227 / 229 (integracion M22 / registrar progreso de historia):** `[?]` -> `[x]` por la
  misma razon (mismo puente).
- **Item 198 ("M105 ya emite los 11 eventos first"):** la nota debe corregirse: la API existe
  (11 funciones) pero **no tenia consumidor**; sigue `[?]` porque 10 de los 11 siguen sin fuente
  de datos medible. NO proponer `[x]`.
- **Items 196 / 197 / 199 (analisis de datos):** `[?]` correcto: requieren datos reales
  post-release. Sin cambio.
- **Items 189/191/193/293/295/296 (M53), 204/205 (M91), 209/215/216/217/245/250/299-302 (M104),
  220/221/224 (M71), 233 (M102), 210 (legal):** `[?]` correcto por dueno externo. Sin cambio.
- **Items 322 / 323 (rutas `res://telemetry/*.gd`):** la premisa esta verificada en disco
  (`game/isla-ancestral/telemetry/` NO existe; el archivo real es
  `scripts/telemetry/telemetry_director.gd`, autoload `TelemetryDirector` en `project.godot`).
  Se propone `[x]` como "plan-inicial descartado, decision documentada y verificada".

## 9. Limites

- **0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.**
- **NO se toco** `05-Checklist.md` (lista NO TOCAR), `CHECKLIST-GLOBAL.md`, `quality.yml`,
  `AGENTS.md`, `project.godot`, ni archivos de M22/M23/M37/M53/M71/M91/M102/M104.
- **NO se cableo la suite a `quality.yml`** (es del director).
- **NO se invento** contenido, ids ni texto de encuesta para las 12 senales sin productor.
- Sondas temporales: **0 residuales** en `scripts/telemetry/` (verificado con glob).

## 10. Trampas nuevas para el skill

1. **Un tracker "primero de X" deduplica por CLAVE, no por id.** `_track_first(&"sello", ...)`
   emite UNA vez por sesion aunque lleguen ids distintos. Un test que espere un evento por id
   fija lo contrario del diseno; hay que leer la clave antes de asertar.
2. **`str.replace` con un solo tab de indentacion puede comerse medio archivo y producir un
   Parse Error.** Con 2 tabs, el patron `\t_fin(...)` matchea los ultimos 2 caracteres de la
   linea y deja un `\t` colgando. Sintoma: el "rojo" es `Expected statement, found "Indent"`.
   Usar `rfind` sobre el ancla sin indentacion, o anclar con `\t\t`.
3. **Un heredoc de bash convierte `\n` en `/n` dentro de `python -c`/`python -`** (reincidencia
   de la trampa 35). Escribir el `.py` con la herramienta de archivos y ejecutarlo evita la
   clase entera.
