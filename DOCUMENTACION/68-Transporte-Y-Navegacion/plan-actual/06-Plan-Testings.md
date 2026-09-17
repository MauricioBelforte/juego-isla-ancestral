**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Log:** 910

# 06-Plan-Testings.md — Módulo 68: Transporte y Navegación (iter. 2)

## 1. Alcance de esta iteración

Se testea **la mitad verificable headless** del módulo, correspondiente a las
secciones **L, M, N, O, P, Q, V y W** del `05-Checklist.md`:

- **L/M** — planificador de viaje: duración real vs montaje con fade, transición
  cozy < 4 s, orden de fases, carga del destino ANTES de mover al jugador,
  orientación al destino y "nunca perder al jugador".
- **N** — viajes especiales: 5 festivales reales de M74, tour de luna llena (M31)
  y tour panorámico; regla "no aparecer en el grafo normal, sólo programados".
- **O** — viajes narrativos: sin coste, no interrumpibles, diálogos a bordo (M21)
  y avance de hitos/sellos (M22/M23).
- **P** — eventos de ruta: sin peligro, sin clima adverso, en fases seguras,
  con señal (M43/M44).
- **Q** — puente con M69: estaciones compartidas, no duplicar costes/rutas y
  decisión "el fast travel es más caro que el boleto".
- **V** — localización: nombres de paradas y rutas, mensajes de viaje, carteles,
  plurales y formato de hora 12 h/24 h, cobertura completa de claves es/en.
- **W** — `validate_transport.gd` unificado + ciclo completo
  (mapa → elegir → pagar → viajar → llegar) en 3 destinos.

Fuera de alcance (declarado `[?]`, con dueño externo): carteles en el mundo (M46),
capa de mapa (M54), panel (M53), docking y animaciones (M48/M64), contenido de
diálogo (M21), emisión de la flag `festival_activo` (M74/M71), re-anclaje de M69,
tercer idioma (M87).

## 2. Archivos y comandos

```
game/isla-ancestral/scripts/transporte/test_transporte_m68.gd        (iter. 1, 177 checks)
game/isla-ancestral/scripts/transporte/test_transporte_m68_iter2.gd  (iter. 2, 199 checks)
game/isla-ancestral/scripts/transporte/dump_locales_m68.gd           (vuelca el catálogo a JSON)
scripts/aplicar_locales_m68.py                                       (aplica el catálogo a los .po)
```
```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/transporte/test_transporte_m68_iter2.gd
```
**Criterio de verde:** `EXIT 0` **y** `SCRIPT ERROR: 0` en el stdout completo
(verde sin `SCRIPT ERROR: 0` no es verde).

## 3. Bloques del suite iter. 2 (199 checks)

| Bloque | Foco | Checks |
|--------|------|--------|
| **A** | Planner: 3 rutas (corta/media/larga), cozy, orden de fases, cargar antes de mover, orientación, barra M08, aborto sin mover, detección de planes manipulados | 39 |
| **B** | Viajes especiales: 7 viajes, festivales por calendario y por evento M74, luna llena (ciclo 28 d), tour de fin de semana, rutas ocultas | 24 |
| **C** | Viajes narrativos: sin coste, no interrumpible, gating por capítulo/flag, avance de hitos con doble, barrido de 7 capítulos | 24 |
| **D** | Eventos de ruta: 5 eventos seguros, clima adverso bloquea, determinismo por semilla, evento de festival, detección de eventos peligrosos | 15 |
| **E** | M69: precio siempre mayor, 4 anclas reales huérfanas, 3 destinos por proximidad, no duplicación, parada bloqueada | 19 |
| **F** | Localización: 24 h/12 h, plurales, moneda, nombres es/en, carteles, cobertura de claves contra los `.po` reales | 30 |
| **G** | Validador: 8 bloques + medición de costes + 3 ciclos completos + `validar_todo` + detección de registro roto | 29 |
| **H** | Integración en el autoload: accesores, exclusión de rutas programadas, compra bloqueada fuera de ventana, hooks | 16 |
| — | Arranque (autoload + red) y guarda anti-falso-verde | 3 |
| | **Total** | **199** |

## 4. Guarda anti-falso-verde (obligatoria)

El proyecto ya registró (M124) que **un error de script aborta la función en
silencio**: la suite sigue imprimiendo "0 fallos" aunque bloques enteros no se
hayan ejecutado. En esta iteración **se reprodujo en vivo**: un
`Identifier "_resultados" not declared` dejó el bloque G sin ejecutar y el suite
informó `169 checks, 0 fallos`.

Mitigaciones implementadas (las dos):

1. **Marcador `_fin()` por bloque.** Cada bloque registra su letra al terminar.
   `_summary()` **falla** si falta alguna letra (`"los 8 bloques se completaron"`).
2. **Watchdog por temporizador** (90 s): si la suite no termina, imprime el último
   bloque iniciado y hace `quit(1)`.

**Verificación de la guarda (sonda).** Se inyectó un aborto al inicio del bloque C
y la suite pasó a:

```
[FAIL] los 8 bloques se completaron (sin abortos silenciosos) bloques que no terminaron: ["C"]
=== Resumen M68 iter.2: 175 checks, 1 fallos ===
TEST M68 iter.2 FALLÓ — 1 checks fallaron
```

## 5. Casos de prueba (CP)

### CP-L/M — Tiempos y transición

| # | Caso | Esperado |
|---|---|---|
| L1 | `r_aurora_muelle` (5 s) | plan válido, `usa_vehiculo = true`, `modo = tiempo_real`, fundidos a 0 s |
| L2 | `r_aurora_estacion` (6 s) | plan válido, viaje corto |
| L3 | `r_aurora_espejo` (110 s) | plan válido, `usa_vehiculo = false`, `modo = fade` |
| M1 | `duracion_total` en las 3 rutas | `0 < t < 4.0` (cozy) |
| M2 | Orden de fases | exactamente `ORDEN_FASES` (7 fases) |
| M3 | `cargar_destino` vs `mover_jugador` | índice de carga < índice de mover |
| M4 | `orientacion` | vector unitario (XZ) hacia el destino |
| M5 | `puede_perder_jugador` | `false` siempre |
| M6 | `carga_destino_seg = 3.0` | `necesita_barra = true` (M08) |
| M7 | `motivo_aborto = "streaming pesado"` | `ok = false`, sin fases, `reintentos_carga ≥ 1`, no mueve al jugador |
| M8 | Plan manipulado (fases invertidas / orientación nula / `puede_perder_jugador`) | `verificar_plan()` acusa en los 3 casos |

### CP-N — Viajes especiales

| # | Caso | Esperado |
|---|---|---|
| N1 | Registro | 7 viajes (5 festival + 1 luna + 1 tour), `validar()` vacío |
| N2 | Festival de otoño el 15/9 a las 10:00 | disponible |
| N3 | Festival de otoño el 14/9 | bloqueado, motivo contiene `15/9` |
| N4 | Festival de otoño a las 23:00 | bloqueado (ventana 08:00-20:00) |
| N5 | M74 activo + fecha cualquiera | disponible (manda el evento) |
| N6 | M74 con **otro** evento activo | bloqueado, motivo nombra `festival_otono` |
| N7 | Luna llena (día absoluto 14 / 20) | disponible / bloqueado |
| N8 | Tour: sábado / martes | disponible / bloqueado |
| N9 | `rutas_ocultas()` | contiene `r_muelle_festival` y `r_festival_muelle`, no `r_aurora_sur` |
| N10 | Registro roto inyectado | `validar()` detecta ruta inexistente y precio 0 |

### CP-O — Viajes narrativos

| # | Caso | Esperado |
|---|---|---|
| O1 | 3 viajes, `validar(red, Historia)` | vacío (hitos y sellos existen en M22) |
| O2 | `plan_narrativo` | válido, `modo = narrativo`, `precio = 0`, no interrumpible |
| O3 | Capítulo 2 | bloqueado, motivo nombra el capítulo 4 |
| O4 | Capítulo 4 sin flag / con flag | bloqueado / disponible |
| O5 | `avanzar_hitos` con doble de M22 | completa el nodo y marca el sello |
| O6 | `avanzar_hitos(viaje, null)` | no rompe, informa el motivo |
| O7 | Barrido capítulos 1..7 | 7 planes narrativos válidos y gratuitos |

### CP-P — Eventos de ruta

| # | Caso | Esperado |
|---|---|---|
| P1 | 5 eventos, `validar(red, M64)` | vacío (NPC reales) |
| P2 | Ningún evento inseguro / que rompa la transición | 0 y 0 |
| P3 | Clima adverso (3) | no se dispara evento; motivo menciona el clima |
| P4 | Misma semilla dos veces | mismo evento |
| P5 | Evento del muelle | `ev_muelle_mateo`, con señal, en fase segura |
| P6 | Festival sin / con evento activo | no aparece / aparece `ev_festival_catalina` |
| P7 | Evento peligroso en fase crítica inyectado | `validar()` detecta ambos |

### CP-Q — Puente con M69

| # | Caso | Esperado |
|---|---|---|
| Q1 | `precio_m69(80 / 10 / 0)` | `128 / 20 / 10` |
| Q2 | 12 precios del dataset | el fast travel es más caro en **todos** |
| Q3 | 4 anclas reales | 0 compartidas, 4 huérfanas (hallazgo) |
| Q4 | 3 anclas sobre paradas reales | 3 emparejadas por proximidad, 3 ofrecibles |
| Q5 | Ancla sobre `puerto_brisa` (bloqueada) | no ofrecible; sí tras desbloquear |
| Q6 | `validar` con precios | vacío |
| Q7 | Ancla que reusa id / duplicada / con coste propio | 3 errores detectados |

### CP-V — Localización

| # | Caso | Esperado |
|---|---|---|
| V1 | `horario_texto(8, 20, "es" / "en")` | `08:00-20:00` / `8:00 AM-8:00 PM` |
| V2 | `duracion_texto(45 / 60 / 300 / 5400, "es")` | `45 segundos` / `1 minuto` / `5 minutos` / `1 h 30 min` |
| V3 | `duracion_texto(60 / 300, "en")` | `1 minute` / `5 minutes` |
| V4 | `precio_texto(1234, "es" / "en")` | `1.234 AO` / `1,234 AO` |
| V5 | `nombre_parada(puerto_aurora, "en" / "es")` | `Aurora Harbour` / `Puerto de Aurora` |
| V6 | `nombre_ruta(r_aurora_sur, "en")` | contiene `South Island Harbour` y `→` |
| V7 | `mensaje_viaje` / `mensaje_llegada` / `texto_cartel` | textos localizados con placeholders resueltos |
| V8 | `claves_faltantes(["es","en"])` | vacío |
| V9 | `claves_vacias(["es","en"])` | vacío |
| V10 | Catálogo generado vs `.po` aplicado | 0 divergencias |

### CP-W — Validador y ciclo

| # | Caso | Esperado |
|---|---|---|
| W1 | 8 bloques por separado | todos vacíos |
| W2 | `medir_directo_vs_combinar` | 4 cumplen / 6 violan / 10 sin alternativa |
| W3 | `simular_ciclo` ×3 destinos | `ok`, ≥ 4 pasos |
| W4 | `simular_ciclo` sin dinero | falla con motivo |
| W5 | `validar_todo` | `ok`, 9 bloques, 4 pendientes externos, `checks > 20` |
| W6 | `informe()` | contiene `VALIDATE-TRANSPORT OK`, `M46`, `M54` |
| W7 | `validar_todo` con registro roto | falla |

## 6. Reproducibilidad

- Sin azar: la selección de eventos usa semilla explícita; el planner es puro.
- Sin dependencia del reloj/clima/saldo reales: `forzar_contexto`, `forzar_cartera`
  y `forzar_fecha` (nuevo en iter. 2).
- El avance de hitos se prueba con un **doble** de M22, para no mutar la partida.
- Corridas: **×3** exigidas, comprobando `EXIT 0` y `SCRIPT ERROR: 0` en cada una.
