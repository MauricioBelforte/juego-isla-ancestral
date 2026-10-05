# Log 1337: T-D9 (2/4) BUG-069 - baseline del auditor + corte minimo MEDIDO + propuesta a s2

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-05 23:31:00 (UTC)  [local -0300: 20:31]
**Modulo:** M62 (arquitectura de servicios) - frente T-D9
**Tarea:** T-D9 (2/4) "ciclos entre servicios" (L103 / BUG-069)
**Estado:** FASE DE COORDINACION - sin cambios de produccion en este turno

## 1. Que se hizo en este turno

El director aprobo T-D9 (2) con tres condiciones (msg 1332): (1) coordinar con s2 ANTES, (2) auditor
antes/despues, (3) ajustar al alcance que pida s2. Este turno cubre la condicion (1): medir el
baseline, analizar la topologia real del SCC y enviar una propuesta concreta a s2.

**No se toco ni una linea de produccion.** El corte del ciclo toca autoloads de varios modulos
(M59 save, M34 pesca, M53/M58 UI): es cambio no aditivo, y por eso se coordina primero.

## 2. Baseline del auditor (antes)

`scripts/auditar_arquitectura_m62.py` (medido en este turno, worktree = HEAD para los archivos que
importan; no hay cambios sin commitear en los autoloads implicados):

```
autoloads 114 | aristas 229
A1 componentes con ciclo ... 2
   SCC 7: CollectionRegistry, Fishing, GameTime, Inventario, SaveManager, TimeCalendar, Weather  [BUG-069]
   SCC 2: ThemeService, UIManager                                                               [BUG-069]
A2 refs fuera de orden ..... 11 (todas en allowlist)
Grupo B (carga sincrona) ... 0 hallazgos
Grupo C (pureza save) ...... 0 hallazgos
Hallazgos NUEVOS ........... 0
EXIT 0
```

## 3. Hallazgo: el corte minimo es 1 arista y el fix del reporte esta INCOMPLETO

Se analizo la topologia interna del SCC de 7 con una sonda de lectura (scratch, gitignored:
`Obsoletos/raiz-temporales-m62-td9-2026-10-05/_analiza_scc_td9.py`) que **importa las funciones del
propio auditor** (no duplica logica). El SCC de 7 es una **estrella**:

```
Fishing -> {CollectionRegistry, GameTime, Inventario, TimeCalendar, Weather} -> SaveManager -> Fishing
```

- `SaveManager` tiene 1 sola arista interna saliente: `SaveManager -> Fishing`.
- `Fishing` tiene 1 sola arista interna entrante: la misma.

**Simulacion con el Tarjan del auditor** (quitar aristas y recomputar SCC):

| arista quitada | SCCs resultantes |
|---|---|
| `SaveManager -> Fishing` | 1 (solo queda el de 2) |
| `Fishing -> CollectionRegistry` (fix del reporte) | 2 - el SCC sobrevive como 6 nodos |
| `ThemeService -> UIManager` | 1 (solo queda el de 7) |
| `UIManager -> ThemeService` | 1 (solo queda el de 7) |
| `SaveManager->Fishing` + una del par de tema | 0 |

**Conclusion:** el reporte del bug proponia romper `Fishing -> CollectionRegistry` (dentro de
`entrega_museo()`). Eso NO cierra el ciclo: `Fishing -> GameTime -> SaveManager -> Fishing` sigue
vivo. El corte barato real es la arista que va hacia atras: **`SaveManager -> Fishing`**.

Bonus: esa misma arista es **la A2 mas grande** (`SaveManager #9 -> Fishing #46`, delta +37). Una
sola inversion mata A1 (el SCC de 7) **y** la peor A2 a la vez.

### La arista en el codigo

`save_manager.gd:100`, dentro de `_conectar_eventos()` (alcanzable desde `_ready`): SaveManager se
suscribe a `Fishing.sesion_iniciada`/`sesion_terminada` para bloquear el guardado durante el
minijuego de pesca. Inversion natural: Fishing emite esas senales por `EventBus` y SaveManager se
suscribe por el bus. Hoy `Fishing` no tiene aristas salientes fuera del SCC; agregarle
`Fishing -> EventBus` no crea una A2 nueva (EventBus se declara antes que Fishing).

### El SCC de 2 (tema)

`ThemeService <-> UIManager`, corte minimo 1 arista en cualquier direccion:
`theme_service.gd:64` (`_on_window_size_changed` emite `ui_mgr.viewport_resized`) y
`ui_manager.gd:460` (`_on_settings_changed` llama `ts.aplicar_tema_global`).

## 4. Propuesta enviada a s2 (canal 1336)

Mensaje `1336-2026-10-05_20-29-57-deepseek-a-s2-td9-2-ciclos-bug069-corte-minimo-medido.md`.
Pide el alcance: (A) romper los dos SCC = 2 aristas -> A1=0; (B) solo el SCC de 7 = 1 arista -> A1=1;
(C) otro alcance. Pregunta tambien por la inversion por EventBus, por quien borra las entradas de
`PERMITIDOS` obsoletas, y por el timing (antes o despues del wiring de M62 / gdUnit4 de s2).

## 5. Sin cambios de produccion

Ninguno. El corte de ciclos no se ejecuta hasta la respuesta de s2 (condicion 1 del director).

## 6. NO sella 21.8

Este turno no cierra ningun item de checklist ni sella nada. La verificacion 21.8 (verificador !=
autor) es de otro agente, como siempre.

## 7. Numeracion / pool

- Mensaje a s2: **1336** (pool head justo antes: 1336 -> 1337).
- Log: **1337** (pool head justo antes: 1337 -> 1338).
- El pool NO se commitea (es del coordinador).

**Reporte de numeracion ajena (no se toca, solo se reporta):** `reservar_log.py --estado` senala
(1) COLISION 1290 (`1290-m112-export-presets-deuda-obsoleta...` y `1290-th2-bloque1-reverify-21.8...`)
y (2) DOBLE ASIGNADOR 1502 (`1502-hy3-qa21.8-m64-ia-npc_2026-10-05.md` escrito pero aun en el pool).
Ambos son de otros agentes; se reportan, no se corrigen.

## 8. Huella de push (AGENTS sec.4.3)

- **Push principal:** `fcfb8ff..6708281` -> `main` (fast-forward, sin `--force`).
  Fecha/hora: 2026-10-05 ~23:31 UTC. Ejecutante: DeepSeek-V4.1-Flash.
- Commit propio empujado: `6708281` (canal 1336).
- **Catch-up de ajenos:** el rango incluyo 2 commits de Hy3 que estaban por delante de mi
  (`b12011f`, `f36780e` - M64 seal 21.8 Log 1502). No son mios; viajaron en el mismo push
  fast-forward de la rama compartida.

## 9. Huella de push #2 (AGENTS sec.4.3)

- **Push principal:** `6708281..bd6077e` -> `main` (fast-forward, sin `--force`).
  Fecha/hora: 2026-10-05 ~23:40 UTC. Ejecutante: DeepSeek-V4.1-Flash.
- Commit propio empujado: `bd6077e` (este Log 1337 + fila T-D9 (2) del backlog).
- Sin commits ajenos en el rango (1 solo commit, mio).
