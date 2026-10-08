# 06 — Plan de Testings — M24: Templos y Puzzles

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-07
**Estado:** vigente (iter. 5)
**Cierra:** ítems 168, 169, 170, 171 y 172 del `05-Checklist.md`.

Este documento define **cómo se prueba** el framework emisor→receptor de M24. No reemplaza al
`05-Checklist.md`: mientras el checklist declara *qué* falta, este plan declara *con qué evidencia*
se cierra cada pieza. Las cifras reales de ejecución van en `07-Resultados-Testings.md`.

## 1. Unitarias del framework (ítem 168)

Suites headless (Godot 4.7.2, `--headless --path game/isla-ancestral --script <ruta>`), todas
`SceneTree` con resumen y piso medido:

| Suite | Cubre | Contrato anti-falso-verde |
|---|---|---|
| `scripts/templos/test_puzzle_datos.gd` | Intérprete datos-driven (`PuzzleDef`): carga, validación, unicidad, "casi solución", umbral de peso, `a_puzzle_room`. | Bloques A-F nombrados; `CHECKS_MINIMOS` medido; `_summary()` en `call_deferred`; sonda de ambigüedad. |
| `scripts/templos/test_puzzle_multilateral.gd` | Familia multilateral migrada (anillos n=7, final 3 fases) + cruce contra el catálogo real. | Igual + **sonda roja** (mutación de la regla AND → ambigüedad). |
| `scripts/templos/test_puzzle_bloques.gd` | Familia bloques (push/pull): 1 eje, ranuras, límites, puente + capa espacial. | Igual + **sonda roja doble** (eje inválido / límite abierto / ambigüedad). |
| `scripts/templos/test_puzzle_luz.gd` | Familia luz (grafo óptico): espejo 45°, lente, prisma, ocultación, cristal + validación por datos. | Igual + **sonda roja en vivo** (ángulo 30 en el JSON real → 11 fallos nombrados, EXIT 1). |
| `scripts/templos/test_puzzle_espejos.gd` | Familia espejos (rotación discreta): rotar 45°, fijos/móviles, camino verificable, feedback + cadena con luz. | Igual + **sonda roja en vivo** (espejo fijo a 90 en el JSON real → 9 fallos nombrados, EXIT 1). |
| `scripts/templos/test_puzzle_agua.gd` | Familia agua (niveles graduales): fuente/caudal, compuerta por umbral, barca, drenaje gradual + validación por datos. | Igual + **sonda roja** (umbral 0, emisor inexistente, caudal 0, destino == origen, sin fuentes). |
| `scripts/templos/test_puzzle_hielo.gd` | Familia hielo (deslizamiento): deslizar hasta chocar, paredes/huecos, pedazos, simetría. | Igual + **sonda roja** (7 mutaciones: usos 0, pared+hueco, emisor 9, simetría rota, bloque sobre pared, bloque detenido por otro). |
| `scripts/templos/test_puzzle_gravedad.gd` | Familia gravedad (movimiento): burbujas, plataformas sincronizadas, pulsos, cintas, reloj M29. | Igual + **sonda roja** (10 mutaciones) + `RelojFalso` (contrato M29 duck-typed). |
| `scripts/templos/test_puzzle_sonido.gd` | Familia sonido (secuencia): campanas, secuencia 3-5, pista tras 2 intentos, modelo puro (ítem 104). | Igual + **sonda roja** + verificación del ítem 104 por lectura del fuente (0 refs a `AudioServer` en código). |
| `scripts/templos/test_puzzle_pistas.gd` | Familia pistas (ayuda): 3 capas, diferida 90 s, derivadas del grafo, solución tras 3 pistas, sin penalización. | Igual + **sonda roja** + `DiarioFalso` (contrato `diary_service`). |
| `scripts/templos/test_regresion_templos.gd` | **Frente 0 — gate de regresión**: corre las **13 suites** como subprocesos y exige EXIT 0 + 0 `SCRIPT ERROR` + checks ≥ piso. | Piso total MEDIDO (**649**); sonda roja del clasificador (9 casos) + **sonda roja EN VIVO** (JSON de agua mutado → EXIT 1). |
| `scripts/templos/test_puzzles.gd` | Framework base (transiciones, completado, no-arbitrariedad, integración emisor→puerta). | Suite original de Hy3 (0 fallos). |
| `scripts/templos/test_templo_m26.gd` | Salas de M26 (7 anillos, fases). | 92 checks. |
| `scripts/templos/test_templo_headless.gd` | Humo de arranque del templo. | 4 checks. |

**Regla de oro:** ningún `[x]` de implementación se declara sin una suite que lo ejecute en verde
**con el piso medido**. Un "0 fallos" de una suite que aborta antes de sus aserciones es falso verde.

## 2. Playtests externos por familia (ítem 169)

Los playtests externos **no** corren en CI: se ejecutan con personas y se registran en
`07-Resultados-Testings.md`. Plan por familia:

| Familia | Qué se observa | Métrica de éxito |
|---|---|---|
| Presión | ¿Se entiende que hay que pisar a la vez? ¿La placa de peso estático (caja) es descubrible? | ≥ 4/5 resuelven sin pista; 0 bloqueos > 90 s. |
| Multilateral | ¿Se percibe que el estado es de la **sala** y no de un anillo? | ≥ 3/5 resuelven el puzzle final sin guía. |
| Bloques | ¿Se entiende el eje único de cada bloque? ¿El límite de sala se lee como "no se puede"? | ≥ 4/5 no intentan empujar fuera de la sala. |
| (resto) | Pendientes de iter. 4+. | — |

La **telemetría** de M24 (`PuzzleTimer`: tiempo, pistas, abandonos; exportación para playtests
externos) es el instrumento de registro.

## 3. Edge cases (ítem 170)

| Caso | Cómo se prueba | Resultado esperado |
|---|---|---|
| **2+ soluciones (ambigüedad)** | Sonda roja: 2 caminos OR incomparables. | `soluciones_minimas == 2` y `validar_def` falla con "ambiguo". |
| **Regla rota (emisor inexistente)** | Sonda sintética: regla `[0, 99]`. | `validar_def` falla con "emisor inexistente 99". |
| **Regla desconectada (emisor huérfano)** | Sonda sintética. | `validar_def` falla con "huérfano". |
| **Objetivo ≠ solución mínima** | Sonda sintética (regla redundante). | `validar_def` falla con "no es la solución mínima". |
| **Eje inválido (bloques)** | Sonda roja sobre el JSON real. | `validar_espacial` falla con "eje 'z' no permitido". |
| **Límite de sala abierto (bloques)** | Sonda roja. | `validar_espacial` falla con "debe ser false". |
| **Empuje fuera de grilla / celda ocupada** | Simulación real. | `empujar()` devuelve false y la pieza no se mueve. |
| **Ángulo de espejo no múltiplo de 45 (luz)** | Sonda roja sobre el JSON real. | `validar_optica` falla con "no es multiplo de 45". |
| **Desvío de prisma no múltiplo de 90 (luz)** | Sonda sintética. | `validar_optica` falla con "no es multiplo de 90". |
| **Rayo oculto por el jugador (luz)** | Simulación real. | `bloquear(celda)` → el rayo no llega y el receptor queda OFF. |
| **Rotación de espejo fijo (espejos)** | Simulación real. | `rotar()` devuelve false y el ángulo no cambia. |
| **Rotación no múltiplo de 45 (espejos)** | Simulación real. | `rotar()` devuelve false. |
| **Umbral de compuerta 0 / caudal 0 (agua)** | Sonda roja sobre copia del JSON real. | `validar_agua` falla con "umbral 0 invalido" / "caudal 0 invalido". |
| **Barca con destino == origen (agua)** | Sonda roja. | `validar_agua` falla con "destino == posicion inicial". |
| **Sin fuentes (agua)** | Sonda semántica. | El nivel nunca sube y el receptor jamás se activa. |
| **Pedazo con usos 0 (hielo)** | Sonda roja. | `validar_hielo` falla con "usos 0 invalido". |
| **Pared y hueco en la misma celda (hielo)** | Sonda roja. | `validar_hielo` falla con "pared y hueco a la vez". |
| **Simetría rota / eje inválido (hielo)** | Sonda roja. | `validar_simetria` falla con "sin reflejo" / "invalida". |
| **Bloque detenido por otro bloque (hielo)** | Sonda sintética. | El bloque se detiene en la celda previa al otro. |
| **Grupo con periodos distintos (gravedad)** | Sonda roja. | `validar_gravedad` falla con "no estan sincronizadas". |
| **Pulso con duración > periodo (gravedad)** | Sonda roja. | `validar_gravedad` falla con "fuera de (0, periodo]". |
| **Sin burbujas (gravedad)** | Sonda semántica. | `direccion_gravedad` cae al valor por defecto (SUR). |
| **Secuencia de 2 o 6 símbolos (sonido)** | Sonda roja. | `validar_sonido` falla con "se exige entre 3 y 5". |
| **Secuencia usa campana inexistente (sonido)** | Sonda roja. | `validar_sonido` falla con "campana inexistente". |
| **Secuencia equivocada (sonido)** | Sonda semántica. | Nunca resuelve; los fallos se acumulan (alimentan la pista). |
| **Sin familia / sin reglas (pistas)** | Sonda roja. | `validar_pistas` falla con "sin familia declarada" / "sin reglas". |
| **Receptor mutado en los datos (pistas)** | Sonda semántica. | `pista_anclada_a_grafo` cita el receptor nuevo (deriva de datos, no texto suelto). |
| **0 pistas usadas (pistas)** | Sonda semántica. | `solucion_paso_a_paso()` devuelve `[]` (no regala la solución). |

## 4. Rendimiento (ítem 171)

**Umbral: ≤ 1 ms por tick de sala.** Un "tick" = actualizar el estado de un emisor + recalcular
receptores + distancia al objetivo (`set_emisor` + `recalcular` + `distancia_objetivo`).

- Se mide con `Time.get_ticks_usec()` promediando 2000 ticks sobre una sala real.
- El coste de la **herramienta de autoría** (`PuzzleDef.validar_def`, fuerza bruta 2^n) **no** es un
  tick: se mide aparte y solo se exige que sea usable en el Editor (< 10 ms para n=2).
- Los valores medidos van en `07-Resultados-Testings.md` (nunca estimados).
- Las familias luz y espejos miden su **re-trazado** (la operación del tick del rayo): `PuzzleLuz.trazar()` (luz) y `rotar + trazado` (espejos) sobre las salas 01/02. Valores en `07-Resultados-Testings.md`.
- Las familias iter. 5 miden su operación de tick: `PuzzleAgua.tick()`, `PuzzleGravedad.tick()`, `PuzzleHielo.deslizar()`, `PuzzleSonido.tocar_secuencia()`, `PuzzlePistas` (derivar 2 pistas). Valores en `07-Resultados-Testings.md`.

## 5. Criterio de éxito (ítem 172)

Una iteración de M24 se considera **cerrada con evidencia** solo si, en el mismo commit:

1. Todas las suites de M24 corren **EXIT 0 con 0 `SCRIPT ERROR`**, y cada una reporta un número de
   checks **≥ su piso `CHECKS_MINIMOS` medido**.
2. Cada sonda roja produce **fallos nombrados** (no un simple "fallo") y **EXIT 1**.
3. Los datos mutados durante una sonda se **restauran byte-exactos** (sha256 antes == después).
4. Las cifras del `07-Resultados-Testings.md` son **medidas**, no copiadas de una corrida anterior.
5. El `05-Checklist.md` marca `[x]` **solo** los ítems con la evidencia anterior; el resto queda `[ ]`.

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1438 (iter. 5).
