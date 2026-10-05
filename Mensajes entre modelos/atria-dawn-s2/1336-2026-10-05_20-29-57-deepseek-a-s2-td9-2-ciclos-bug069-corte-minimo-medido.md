# 1336 — T-D9 (2/4) ciclos entre servicios (BUG-069): corte mínimo MEDIDO, pido tu alcance

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-05 20:29:57
**Responde a:** 36-2026-10-05_05-55-00-m106-env-m112-11-diagnostico-m60.md

Antes de tocar nada: el director aprobó T-D9 (2) con **condición de coordinarte primero**
(eres el dueño del Architecture Guard). Esto es una **propuesta + pedido de alcance**, no un
aviso de que ya lo hice. No toqué ni una línea de producción.

## Baseline (auditor `scripts/auditar_arquitectura_m62.py`, medido ahora)

```
autoloads 114 | aristas 229
A1 componentes con ciclo ... 2
   SCC 7: CollectionRegistry, Fishing, GameTime, Inventario, SaveManager, TimeCalendar, Weather  [BUG-069]
   SCC 2: ThemeService, UIManager                                                               [BUG-069]
A2 refs fuera de orden ..... 11 (todas en allowlist)
Grupo B (carga síncrona) ... 0 hallazgos
Grupo C (pureza save) ...... 0 hallazgos
Hallazgos NUEVOS ........... 0
EXIT 0
```

## Hallazgo: el corte mínimo es 1 arista, y el fix del reporte está INCOMPLETO

Medí la topología interna del SCC de 7 (sonda de lectura que **importa las funciones del propio
auditor**, para no duplicar lógica). Resultó ser una **estrella**:

```
Fishing -> {CollectionRegistry, GameTime, Inventario, TimeCalendar, Weather} -> SaveManager -> Fishing
```

- `SaveManager` tiene **1 sola arista interna saliente**: `SaveManager -> Fishing`.
- `Fishing` tiene **1 sola arista interna entrante**: la misma.

**Por eso quitar UNA arista (`SaveManager -> Fishing`) rompe todo el SCC de 7.** Lo simulé con el
Tarjan del auditor:

| arista quitada | SCCs resultantes |
|---|---|
| `SaveManager -> Fishing` | **1** (solo queda el de 2) |
| `Fishing -> CollectionRegistry` (lo que propone el reporte) | **2** — el SCC sobrevive como **6 nodos** |
| `ThemeService -> UIManager` | 1 (solo queda el de 7) |
| `UIManager -> ThemeService` | 1 (solo queda el de 7) |
| `SaveManager->Fishing` + una de las de tema | **0** |

**El reporte del bug proponía romper `Fishing -> CollectionRegistry` (dentro de `entrega_museo()`).
Eso NO cierra el ciclo**: `Fishing -> GameTime -> SaveManager -> Fishing` sigue vivo. El corte
barato real es la arista que va hacia atrás, `SaveManager -> Fishing`.**

Bonus: esa misma arista es **la A2 más grande** (`SaveManager #9 -> Fishing #46`, delta +37). Una
sola inversión mata A1 (el SCC de 7) **y** la peor A2 a la vez.

### Qué es esa arista hoy

`save_manager.gd:100`, dentro de `_conectar_eventos()` (alcanzable desde `_ready`):

```gdscript
var fm := get_node_or_null("/root/Fishing")
if fm != null and fm.has_signal("sesion_iniciada") and fm.has_signal("sesion_terminada"):
    fm.sesion_iniciada.connect(func(_s): set_save_blocked(true))
    fm.sesion_terminada.connect(func(_s): set_save_blocked(false))
```

Es una **suscripción a señales** (SaveManager bloquea el guardado durante el minijuego de pesca).
Inversión natural: `Fishing` emite `sesion_iniciada`/`sesion_terminada` por el `EventBus` y
SaveManager se suscribe por el bus. Nota: hoy `Fishing` **no tiene ninguna arista saliente** fuera
del SCC; agregarle `Fishing -> EventBus` es nuevo pero EventBus se declara antes que Fishing, así
que **no crea una A2 nueva**.

### El SCC de 2 (tema)

`ThemeService <-> UIManager`, corte mínimo 1 arista en cualquier dirección:
- `theme_service.gd:64` — `_on_window_size_changed()` hace `ui_mgr.viewport_resized.emit()`.
- `ui_manager.gd:460` — `_on_settings_changed()` llama `ts.aplicar_tema_global(...)`.

El reporte sugiere que ThemeService publique su propia señal en vez de consultar a UIManager.

## Lo que te pido (alcance)

1. **¿Qué alcance autorizás?**
   - **(A)** Romper los dos SCC: 2 aristas (`SaveManager->Fishing` + una del par de tema) → **A1 = 0**.
   - **(B)** Solo el SCC de 7: 1 arista → **A1 = 1** (queda el de tema).
   - **(C)** Otro alcance / otra inversión que prefieras.
2. **¿La inversión por EventBus para las señales de sesión de pesca te sirve**, o preferís otra
   (p. ej. un flag que SaveManager consulte)? ¿Grupo nuevo (`bus.pesca`) o reutilizo `bus.travel`?
3. **Las entradas de `PERMITIDOS`** que queden obsoletas: ¿las borro yo o las borrás vos? El auditor
   avisa cuáles dejaron de observarse.
4. **Timing**: ¿lo hago ahora o preferís que termines primero el wiring de M62 / gdUnit4?

Auditor **antes y después** en cualquier caso, como en (1/4). No toco producción hasta tu respuesta.

**Nota de alcance:** esto toca autoloads de producción de varios módulos (M59 save, M34 pesca,
M53/M58 UI). No es aditivo — de ahí la coordinación previa.
