# Log 1729: M49-Iluminacion - LightPool implementado y verificado (44 checks)

**Fecha:** 2026-10-12
**Hora:** 05:10
**Modelo:** stepfun-step-5-Preview
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 171): implementar el pool de luces dinámicas de M49. El diseño ya estaba
documentado en `03-Diseno.md` §1/§3.2 (y los ítems E41/E42/E43 estaban `[x]` desde el barrido), así
que esta vuelta lo convirtió en **código real y verificado**. **M49: 65 -> 66 `[x]` / 143 (+1)** — el
único `[?`] del bloque era el descarte por distancia (E44), ahora implementado.

## Implementado

`game/isla-ancestral/scripts/world/light_pool.gd` (nuevo, 6.8 KB, sin `class_name` por ser
autoload-style; pitfall GUIA-GODOT/09 §9.17):

| Requisito (§3.2) | Implementación |
|---|---|
| Tope total 20 | `MAX_DINAMICAS = 20`; al llenarse `obtener()` devuelve `null` y cuenta el rechazo — **nunca roba una luz activa** |
| Tope sombra 6 | `MAX_CONT_SOMBRA = 6`; al llenarse la luz nueva se crea **sin sombra** (degrada, no bloquea) |
| Descarte 30 m | `RADIO_DESCARTE = 30.0`; `desactivar_lejanas(centro, radio)` |
| Flicker determinista | fase desde `hash(semilla, tipo, posición)`; `flicker()` acotado a `[1-amp, 1+amp]` |
| Anti-oscuridad | si **todas** las luces quedarían fuera de radio, no apaga ninguna |

Decisiones de diseño tomadas y documentadas:
- El tope de sombra **degrada en lugar de rechazar**: es mejor una farola sin sombra que ninguna.
- El tope total **rechaza** en lugar de robar: el jugador nunca pierde la luz que ya tiene.

Catálogo: `luz_farol` (0.9 Hz / 10 %), `luz_fuego` (1.7 Hz / 14 %), `luz_cristal` (0.5 Hz / 6 %,
sin sombra), `linterna` (sin flicker, con sombra). `catalogo_valido()` valida contra
`FLICKER_HZ_MAX = 2.0` y `FLICKER_AMPLITUD_MAX = 0.15`.

## Verificación

`scripts/world/test_light_pool_m49.gd` — **44 checks, 0 fallos, RESULTADO: PASS** (6 bloques:
límites, reutilización, topes, descarte, flicker, catálogo).

## ⚠️ Lección propia: casi reporto un fallo ajeno que no existía

Las primeras corridas se colgaban sin ejecutar el script y culpé al bootstrap del proyecto
(`BlockType` sin parsear, `get_height` sobre `Nil` en fauna — todo real y de otros agentes).
Verifiqué por cinco vías... pero la causa era **mi propio archivo de test dañado**: ediciones
sucesivas lo dejaron con un `_summary()` que usaba `await` dentro de un `call_deferred` y un
`_run()` truncado que no llamaba a los bloques. Reescrito con el patrón simple
(`call_deferred("_run")` único, sin `await`), quedó verde al primer intento.

**Regla que me llevo:** antes de atribuir un fallo a un agente externo, verificar que el archivo
propio no esté corrupto.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/world/light_pool.gd` (nuevo, 6.8 KB)
- `game/isla-ancestral/scripts/world/test_light_pool_m49.gd` (nueva, 44 checks)
- `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md` (1 flip + nota)
- `DOCUMENTACION/49-Iluminacion/plan-actual/04-Codigo.md` (Notas del Agente)
