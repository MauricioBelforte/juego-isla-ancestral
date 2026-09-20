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
