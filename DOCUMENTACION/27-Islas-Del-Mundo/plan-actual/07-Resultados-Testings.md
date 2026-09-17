# 07 — Resultados de Testings — M27: Islas del Mundo

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Iteración:** 4 (edge cases K1–K9 + catálogo de la §26)
**Log:** `Logs/912-Islas-Del-Mundo-Iter2_2026-09-15.md`

## Comando ejecutado

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/islas/test_islas_m27_iter2.gd
```

## Resultado

| Corrida | Checks | Fallos | EXIT | `SCRIPT ERROR` | Bloques |
|---|---|---|---|---|---|
| 1 | 238 | 0 | 0 | 0 | 8/8 |
| 2 | 238 | 0 | 0 | 0 | 8/8 |
| 3 | 238 | 0 | 0 | 0 | 8/8 |
| 4 (conteo por bloque) | 238 | 0 | 0 | 0 | 8/8 |

Salida real (corrida limpia):

```
=== [M27] Test Islas del Mundo (iter. 2) ===
-- A. IslandOps
-- B. K1 precarga sin congelar + K2 viaje con descarga en curso
-- C. K3 náufrago + K8 respawn cozy
-- D. K4 destino + K5 punto seguro
-- E. K6 cancelación limpia + K7 guardado
-- F. K9 descarga forzada por presión de memoria
-- G. Catálogo de diseño (§26 del plan maestro)
-- H. Integración con el autoload IslandRegistry real
  [OK] los 8 bloques se completaron (sin abortos silenciosos)
-- checks por bloque: { "A": 46, "B": 30, "C": 28, "D": 28, "E": 22, "F": 25, "G": 27, "H": 29 }
=== Resumen M27 iter.2: 238 checks, 0 fallos ===
TEST M27 iter.2 OK — todos los checks pasaron
```

## Checks por bloque

| Bloque | Alcance | Checks |
|---|---|---|
| A | `IslandOps` | 46 |
| B | K1 + K2 | 30 |
| C | K3 + K8 | 28 |
| D | K4 + K5 | 28 |
| E | K6 + K7 | 22 |
| F | K9 | 25 |
| G | `IslandDesignCatalog` (§26) | 27 |
| H | Integración con el registry real | 29 |
| — | Dataset/vista (previos) + guardián de bloques | 3 |
| | **Total** | **238** |

## El guardián anti-falso-verde, probado en vivo

No se dio por bueno: se inyectó un aborto silencioso
(`var nulo: Node = null` + `nulo.get_name()`) al abrir el bloque D.

| Corrida | Checks | Fallos | EXIT | Salida del guardián |
|---|---|---|---|---|
| Con la sonda | 210 | **1** | **1** | `[FALLO] los 8 bloques se completaron (sin abortos silenciosos) — bloques que no terminaron: ["D"]` |

Los **28 checks del bloque D desaparecieron** (238 → 210) y **nada más se quejó**:
sin el guardián, esta corrida habría reportado "0 fallos" con un bloque entero sin
ejecutar. Es exactamente el falso verde que el mecanismo existe para atrapar.
Sonda retirada; la suite volvió a 238/0.

## Fallos encontrados durante la iteración (y su resolución)

La primera corrida dio **228 checks / 5 fallos**. Los 5 eran expectativas mal
escritas, no bugs de producción — salvo uno, que **destapó un hueco real**:

| # | Síntoma | Diagnóstico | Resolución |
|---|---|---|---|
| 1 | `Parse Error: Invalid cast. Cannot convert from "bool" to "Array[String]"` | `as` liga más flojo que `==`: se casteaba el **resultado** de la comparación | quitar el cast (un `Array[String]` compara bien con `== ["coral"]`) |
| 2 | `iniciar() arranca la primera` fallaba | orden de evaluación: `iniciar()` saca la op de `pendientes()` y la segunda lectura ya ve **otra** | capturar la esperada **antes** de llamar |
| 3 | `respawn cozy: devuelve la isla más cercana` fallaba | el punto de prueba (0,0,9000) tenía **empate** entre `nieve` y `volcanica` a 5636 m; el más cercano real era `nieve`, no `coral` | usar un punto inequívoco (0,0,2400 → `coral` a 1300 m) y documentar la aritmética |
| 4 | `K6 reporta las operaciones que quedan vivas` fallaba | `limpio` es **por destino** (semántica correcta); el test asumía "sin operaciones en absoluto" | asertar `limpio(coral) == true` **y** `ops_vivas` incluye `verde` |
| 5 | `K9 snapshot_estado conserva descubrimiento/visitas` fallaba | **hueco real**: `registro_desde_definicion()` fijaba `descubierta/visitada` en `false` y `vista_desde_registry()` no leía el registry → la guardia **nunca** conocía el estado de partida, así que la promesa de K9 era inverificable | la vista lee el estado de M59 (duck-typed) + nuevo `sincronizar_estado_partida()`; el test prueba el camino completo M59 → guardia |

Tras las correcciones: **238 / 0**, estable en 3 corridas.

## Regresiones

| Suite | Resultado |
|---|---|
| `test_islas_m27.gd` (iter. 1) | **171 checks / 0 fallos**, `EXIT 0` |
| `test_islas_headless.gd` (legacy) | **5 checks / 0 fallos**, `EXIT 0` |
| `sincronizar_islas_mapa.gd` | 4/4 islas coherentes + 9/9 POIs, `EXIT 0` |

## Hallazgos que exceden la suite

1. **La guardia no podía cumplir su propia promesa.** Ver fallo #5: corregido.
   Ahora `vista_desde_registry()` refleja el estado real y
   `sincronizar_estado_partida()` lo refresca sin tocar la caché de carga.
2. **El checklist decía 24 puntos y el plan tiene 26.** Medido sobre
   `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` líneas 796–821. El
   catálogo codifica 26 y `validar()`/`informe()` **exponen el desajuste**
   (`plan_dice` vs `plan_tiene`) en vez de aceptarlo en silencio.
3. **Sin M10 no hay anclas reales** (medido: 13/13 islas del registry real sin
   ancla). La guardia **no crashea**: reporta `ancla_pendiente` con
   `espera_coherente: true` y el viaje "espera" en vez de "bloquear". Verificado
   en el bloque H.
4. **Asimetría en M59**: `esta_descubierta(&"aurora")` devuelve `true` por
   definición (`or id == ISLA_PRINCIPAL_ID`) pero `islas_descubiertas()` **no la
   lista**. Dueño: M59/M54. Cualquier consumidor que compare ambas fuentes ve un
   desajuste. Anotado en `04-Codigo.md` y en el checklist.

## Cobertura: qué NO cubre esta suite

- `IslandLoading` (streaming real, 19 ítems `[?]`) — dueño M63/M61.
- Anclas reales (M10) y muelles físicos (M17/M40).
- El cableado al juego: nadie llama todavía a `IslandOps`/`IslandTravelGuard`.
  Se prueban como lógica pura; su efecto en runtime llega con M63 (streaming) y
  M28 (barco).
- Aprobación visual: **no** es de este agente (§15.3).
