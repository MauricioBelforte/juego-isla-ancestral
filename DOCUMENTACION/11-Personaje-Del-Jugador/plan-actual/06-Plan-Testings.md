**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-20
**Log:** 1130

# 06-Plan-Testings.md — Módulo 11: Personaje del Jugador

> Este documento no existía. Se crea en la iteración del Log 1130 porque la metodología
> (fase 7 del ciclo de módulo) lo exige: sin él, la evidencia de la suite queda sólo
> dentro del `.gd` y nadie sabe **qué cubre** ni **qué no**.

## 1. Alcance de la verificación

| Qué | Cómo | Dónde |
|---|---|---|
| Constantes `@export` de la escena (move_speed, gravity, jump_force, edit_distance) | instanciar `Player.tscn` y leer las propiedades | suite, bloque A |
| Hitbox (tipo y dimensiones de la `CollisionShape3D`) | leer `collider.shape` y su clase | suite, bloque B1 |
| Divergencias documentadas (stamina / FSM / interacción / luz ausentes) | `get_method_list()` del nodo instanciado | suite, bloque B6–B9 |
| Movimiento: grupo `player`, velocidad inicial, gravedad, `_equip_speed_mult` | propiedades del nodo instanciado | suite, bloque C |
| Integración M155 (EquipmentManager) | autoload presente, señal `terrain_bonus_updated`, conexión real desde el `_ready()` del jugador | suite, bloque D |
| API nativa de Voxel Tools | `ClassDB.class_exists` / `class_has_method` | suite, bloque E |

**Comando canónico** (el mismo del CI, **sin** `--quit`):

```bash
godot --headless --path game/isla-ancestral --script res://scripts/player/test_player_m11.gd
```

## 2. Qué NO cubre esta suite (y no debe citarse como si lo cubriera)

FSM de 10 estados, stamina/bienestar, interacción contextual, nado/buceo/aire, esporas de luz,
animaciones y audio, selección de personaje y guardado de estado. **Ninguno de esos sistemas
existe en el runtime de M11** (73 ítems `[?]` en `05-Checklist.md`).

## 3. Guardianes anti-falso-verde

Una suite que es la evidencia de los `[x]` del módulo **tiene que poder fallar**. Tres capas,
y las tres se prueban **en rojo con sondas** antes de confiar en ellas:

1. **Marcadores por bloque** — `_fin("A").._fin("E")` + `BLOQUES_ESPERADOS`. Si un bloque no
   cierra (aborto por `SCRIPT ERROR`), se nombra y falla.
2. **Piso `CHECKS_MINIMOS = 30`** — el total **real medido en verde**, no el teórico. Un aborto
   parcial baja el conteo y el piso lo delata.
3. **`_summary()` diferido** — registrado con `call_deferred` en `_init()`, de modo que corre
   **aunque `_run()` aborte**. Sin esto, un aborto se lleva el `quit()`.

### Protocolo de inyección

| Sonda | Qué inyecta | Qué debe pasar |
|---|---|---|
| C | aborto en runtime al inicio de un helper de bloque (vía intermedio **sin tipo**, para que no lo cace el compilador) | el bloque no cierra → `[FALLO] Bloque faltante: C`, EXIT 1 |
| D | aborto dentro de `_run()` | el resumen corre igual → nombra los 5 bloques faltantes + el piso, EXIT 1, **sin colgarse** |

Las sondas son archivos temporales `_probe_*.gd` que se **borran** al terminar la medición.

## 4. Riesgos conocidos de la suite

- **B6–B9 son `[INVERTIBLE]`:** afirman la **ausencia** de stamina/FSM/interacción/luz. El día que
  alguno se implemente van a dar **ROJO**. Eso no es una regresión: es la señal de que hay que
  invertir el check y actualizar el checklist.
- **Depende del `_ready()` síncrono** de `Player.tscn` para leer las constantes (el `_ready()` fija
  `move_speed = 25.0` en modo DEV, pisando el valor serializado 5.0). Si eso cambia a diferido, los
  bloques A y B hay que revisarlos.
- **`--quit` enmascara los abortos.** Por eso el comando canónico es el del CI, sin `--quit`.

## 5. Suite del núcleo aditivo (2026-10-10 — Log 1576, DeepSeek-V4.1-Flash)

Se añade una **suite nueva e independiente** para el núcleo aditivo (§9 de `04-Codigo.md`), **sin tocar** la suite original `test_player_m11.gd`:

- **Script:** `game/isla-ancestral/scripts/player/test_player_core_m11.gd`
- **Comando canónico** (el mismo del CI, **sin** `--quit`):

```bash
godot --headless --path game/isla-ancestral --script res://scripts/player/test_player_core_m11.gd
```

### 5.1 Alcance

| Qué | Cómo | Bloque |
|---|---|---|
| FSM: 11 estados, nombres, permisos, transiciones válidas/inválidas, derivación desde snapshot, umbral de aire 20% | instanciar `PlayerFSM` (vía `preload`) y ejercitar la API | A (33 checks) |
| Energía: correr 1/min, regen 1/min (neto 0/min), fatiga al 30%, auto-descanso, dormir/descanso, sin deuda permanente | instanciar `PlayerEnergy` | B (28) |
| Selección: 6 personajes, ids, stats iguales, seleccionar/existe, serializar/deserializar | instanciar `CharacterSelector` | C (20) |
| Contrato: métodos publicados y callables | `preload` + invocación | D (6) |

### 5.2 Qué NO cubre

No verifica integración con `Player.tscn`, HUD, persistencia ni animación — igual que el núcleo, que es **modelo puro**. **No sustituye** a la suite original: cada una es evidencia de cosas distintas.

### 5.3 Guardianes (mismas 3 capas, probadas en rojo)

`BLOQUES_ESPERADOS = ["A","B","C","D"]`, piso **`CHECKS_MINIMOS = 87`** (medido en verde, no estimado) y `_summary()` diferido con `call_deferred` en `_init()`. Se usa `preload()` (no el `class_name` global) para no depender de la caché de clases en un checkout limpio (**trampa 123**).

### 5.4 Riesgos conocidos

- Los checks de energía afirman **1/min** (D1 **resuelta** por el director, msg 137: gana `01-Requerimientos`). Correr cuesta 1/min y la regen es 1/min siempre → **balance neto 0/min**: la energía no baja por caminar/correr (L70 **estructural**, no clamp). Los checks B14/B15 (correr 100 min → energía `> 0` y `== 100`) fijan el caso extremo.
- El bloque A afirma **11** estados. Si se resuelve **D2** a 9/10, hay que ajustar `BLOQUES_ESPERADOS` y el conteo.
