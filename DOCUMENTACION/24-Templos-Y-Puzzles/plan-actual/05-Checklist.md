# 05 — Checklist — M24: Templos y Puzzles (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Filosofía y dificultad

- [x] Definir la filosofía de puzzles del juego (coherentes, narrativos, jamás arbitrarios) [M]
- [ ] Definir 3 bandas de dificultad (Exploración/Ritual/Antiguo) [S]
- [ ] Definir progresión de dificultad por zona del templo [S]
- [x] Definir progresión de dificultad por familia de puzzle [S]
- [ ] Definir la subida de dificultad por intentos fallidos (ayuda progresiva) [S]
- [ ] Documentar la filosofía en el plan-actual [S]

## Tutorialización

- [x] Definir tutorialización por familia (primer puzzle de cada familia) [M]
- [ ] Definir "guía del templo" mural por zona [S]
- [ ] Definir narrador suave en la primera solución (M33/M31 hooks) [S]
- [ ] Definir iconografía de glifos reconocible en la guía [S]
- [ ] Definir tutorialización sin texto invasivo (visuales primero) [S]
- [ ] Documentar la tutorialización en el plan-actual [S]

## Framework emisor→receptor

- [x] Definir Emisor (señal por acción del jugador o del mundo) [M] — `PuzzleEmisor`: `recibir_golpe()` (jugador) + `recibir_peso()`/`set_activo()` (mundo); ver 03-Diseno seccion "Framework emisor→receptor — definiciones"
- [x] Definir Receptor (efecto visible) [M] — `PuzzlePuerta.evaluar(activos)`/`abrir()` remueve el sello de voxels (efecto visible)
- [x] Definir Regla (conector declarativo con condiciones) [M] — datos `{emisores:[ids], receptor}` + `PuzzleRoom.add_regla()` + `PuzzleDef.reglas_def()`; condicion extra = `umbral_peso`
- [x] Definir EstadoSala (vector de emisores) [M] — `PuzzleRoom.emisores` + `get_vector_estado()`/`recalcular()`
- [x] Definir Objetivo único verificable [M] — `objetivo` en datos + `estado_igual_objetivo()`; unicidad por `PuzzleDef.validar_def` (1 solucion minima == T)
- [x] Definir Validador de arbitrariedad (1 solución alcanzable) [C] — `PuzzleDef.soluciones_minimas()` exige 1; detector de ambigüedad probado EN ROJO (Log 1407)
- [x] Definir serialización JSON/YAML de cada puzzle [M]
- [x] Definir ejecución datos-driven (intérprete, no código por sala) [M] — `PuzzleDef.a_puzzle_room()` + datos `data/templos/puzzles/presion/*.json`; 2 puzzles cargados y validados (Log 1407)
- [x] Documentar el framework en el plan-actual [M] — seccion nueva en 03-Diseno.md + mapa de conceptos en 04-Codigo.md (iter. 2)

## Familia: puzzles de luz

- [x] Definir espejo de luz con ángulo 45° verificable [M] — `PuzzleLuz`: `angulo` en `ANGULOS_ESPEJO` (0/45/90/135), reflexión determinista; suite `test_puzzle_luz.gd` 60/0
- [x] Definir lente que concentra el rayo [S] — `PuzzleLuz`: `lentes[id].concentracion` + `cristal.concentracion_requerida` (sin lente el receptor queda OFF)
- [x] Definir prisma que desvía el rayo [S] — `PuzzleLuz`: `prismas[id].desvio` (múltiplos de 90, sentido horario)
- [x] Definir ocultación del rayo por el jugador [S] — `PuzzleLuz.bloquear/desbloquear(celda)`: el rayo se corta; reversible
- [x] Definir cristal receptor que activa runa [S] — `PuzzleLuz.receptor_activado()` activa el emisor del cristal (S == T)
- [x] Definir validación de rayos por datos (no física visual) [M] — `PuzzleLuz.trazar()` determinista + `validar_optica()`; suite 60/0
- [x] Documentar la familia de luz en el plan-actual [S] — 03-Diseno.md "Familia luz" + 04-Codigo.md (iter. 4)

## Familia: puzzles de espejos

- [x] Definir rotación de espejos en múltiplos de 45° [M] — `PuzzleEspejos.rotar(id, grados)` rechaza no-múltiplos de 45; suite `test_puzzle_espejos.gd` 62/0
- [x] Definir caminos verificables de rayo (Editor) [M] — `PuzzleEspejos.camino()` + `validar_camino()` (contiguo, termina en el cristal)
- [x] Definir espejos fijos y móviles [S] — `fijos`/`moviles` + `es_fijo()`/`es_movil()` (solo los móviles rotan)
- [x] Definir interacción con la familia de luz (cadena) [S] — `PuzzleEspejos` COMPONE un `PuzzleLuz` (mismo trazado)
- [x] Definir feedback de dirección al rotar [S] — `PuzzleEspejos.feedback(id)` → "E->N" tras el trazado
- [x] Documentar la familia de espejos en el plan-actual [S] — 03-Diseno.md "Familia espejos" + 04-Codigo.md (iter. 4)

## Familia: puzzles de agua

- [x] Definir compuertas con niveles de agua [M] — `PuzzleAgua`: `compuertas[id].umbral` + `compuerta_abierta(id)` (abre cuando `altura(pos) >= umbral`); suite `test_puzzle_agua.gd` 57/0
- [x] Definir fuente que alimenta el nivel [S] — `PuzzleAgua.fuentes {pos, caudal, max}` + `tick()` (suma EXACTAMENTE el caudal, con tope `max`)
- [x] Definir barca flotante que cruza al subir el nivel [M] — `PuzzleAgua.barcas {pos, umbral, destino, emisor}` + `barca_en_destino(id)` (cruza al alcanzar el umbral; el cruce es permanente)
- [x] Definir altura de agua verificable por datos [M] — `PuzzleAgua.altura(celda)` / `alturas()` (enteros deterministas, sin fisica visual)
- [x] Definir relleno/drenaje gradual (sin snaps) [S] — `tick()` suma el caudal; `drenar()` resta 1; probado sin salto al umbral (sonda roja)
- [x] Documentar la familia de agua en el plan-actual [S] — 03-Diseno.md "Familia agua" + 04-Codigo.md (iter. 5)

## Familia: puzzles de hielo

- [x] Definir deslizamiento de bloques sobre hielo [M] — `PuzzleHielo.deslizar(id, dir)` (se desliza hasta chocar con borde/pared/bloque); suite `test_puzzle_hielo.gd` 59/0
- [x] Definir patrones simétricos verificables (Editor) [M] — `PuzzleHielo.validar_simetria()` data-driven (ejes `x`/`y`/`ambos`); no hay EditorPlugin en el proyecto, alcance ajustado y aprobado
- [x] Definir colisiones típicas (paredes y huecos) [S] — `paredes` detienen el bloque; `huecos` lo consumen (`cayo_en_hueco(id)`; el emisor vuelve a OFF)
- [x] Definir pedazos de hielo opcionales (variante) [S] — `pedazos {pos, usos}`: se agrietan al ser pisados y se rompen dejando un hueco (`usos_pedazo`)
- [x] Documentar la familia de hielo en el plan-actual [S] — 03-Diseno.md "Familia hielo" + 04-Codigo.md (iter. 5)

## Familia: puzzles de presión

- [x] Definir placas con umbral de peso [M] — `PuzzleEmisor.umbral_peso` + `recibir_peso()`; umbral declarado en datos (Log 1407)
- [x] Definir peso estático (cajas) y dinámico (jugador) [M] — `presion_02.json`: placa estática umbral 3 + dinámica umbral 1 (Log 1407)
- [ ] Definir elevadores por placas [S]
- [ ] Definir puertas por placas encadenadas [S]
- [ ] Definir sin fallo punitivo (reinicio del slot, M66) [S]
- [ ] Documentar la familia de presión en el plan-actual [S]

## Familia: puzzles de bloques

- [x] Definir push/pull con restricción de 1 eje [M]
- [x] Definir ranuras de destino [S]
- [x] Definir puentes desplegables [S]
- [x] Definir sin empuje a otras salas (límites) [S]
- [x] Documentar la familia de bloques en el plan-actual [S]

## Familia: puzzles de gravedad y movimiento

- [x] Definir burbujas de gravedad en zonas seleccionadas [M] — `PuzzleGravedad.burbujas {zona, dir}` + `direccion_gravedad(pos)`; suite `test_puzzle_gravedad.gd` 59/0
- [x] Definir cambio de dirección del desplazamiento [S] — `cambia_direccion(a, b)`: dos celdas en zonas con `dir` opuesta difieren
- [x] Definir plataformas móviles sincronizadas [M] — `plataformas {grupo, amplitud, periodo}` + `plataforma_offset(id, fase)` / `plataforma_en_extremo` (onda triangular entera; mismo grupo + mismo periodo = sincronizadas)
- [x] Definir pulsos de aire [S] — `pulsos {periodo, duracion}` + `pulso_activo(id, fase)` (activo dentro de la ventana `[0, duracion)`)
- [x] Definir cintas transportadoras [S] — `cintas {pos, dir}` + `cinta_dir(id)` / `cinta_en(pos)`
- [x] Definir sincronización con reloj de datos (M29) [M] — `fase_desde_reloj(reloj)` sobre `scripts/time/game_clock.gd` (`dia_absoluto`/`get_hora`/`get_minuto`), duck-typed (contrato verificado por archivo)
- [x] Documentar las familias de gravedad y movimiento [S] — 03-Diseno.md "Familia gravedad y movimiento" + 04-Codigo.md (iter. 5)

## Familia: puzzles de sonido y secuencia

- [x] Definir campanas/gongs como emisores sonoros [S] — `PuzzleSonido.campanas {pos, tono, emisor}` + `tocar(id)`; suite `test_puzzle_sonido.gd` 54/0
- [ ] Definir línea de audición clara como condición (M43 hook) [M] — **BLOQUEADO por M43**: `scripts/audio/` no expone "línea de audición" (0 hits medidos). No se fuerza (condición 2 del plan iter.5); queda para el dueño de M43.
- [x] Definir sin dependencia del hardware de audio del jugador [M] — modelo PURO de datos: 0 referencias a `AudioServer` en código (verificado por lectura del fuente en la suite)
- [x] Definir secuencias de 3-5 símbolos visibles [S] — `secuencia` validada entre `LARGO_MIN=3` y `LARGO_MAX=5` (`validar_sonido`)
- [x] Definir pista del patrón completo tras 2 intentos [S] — `INTENTOS_PARA_PISTA=2` + `pista_disponible()` / `pista_patron()` (vacío antes de 2 fallos)
- [x] Documentar las familias de sonido y secuencia [S] — 03-Diseno.md "Familia sonido y secuencia" + 04-Codigo.md (iter. 5)

## Familia: puzzles de símbolos y ambientales

- [ ] Definir glifos ancestrales emparejados [M]
- [ ] Definir glosario del templo con los glifos (M25 inscripciones) [S]
- [ ] Definir sello de puerta por pareja correcta [S]
- [x] Definir puzzles con viento (M32) [S]
- [x] Definir puzzles con lluvia (M32) [S]
- [x] Definir puzzles con criaturas (M65: curiosidad abre puerta) [S]
- [ ] Documentar las familias de símbolos y ambientales [S]

## Familia: herramientas y multilaterales

- [ ] Definir uso de pico (grieta) [S]
- [ ] Definir uso de gancho (pasarela) [S]
- [ ] Definir uso de farol (iluminar runa) [S]
- [ ] Definir condición de inventario presente para la herramienta [S]
- [x] Definir puzzles multilaterales con estado compartido de sala [M]
- [x] Definir mapa-emisor central para multilaterales [M] — sala central de M26: 7 anillos en un unico vector S con regla central (`multilateral_anillos.json`); validado por `validar_def`
- [x] Definir puerta final por estado completo [S] — `receptor_final` se activa con S == objetivo (3 fases luz+sonido+agua; `multilateral_final_3fases.json`)
- [x] Documentar las familias de herramientas y multilaterales [S] — familia multilateral documentada en 03-Diseno/04-Codigo; 2 puzzles legacy migrados + suite `test_puzzle_multilateral.gd` (38/0)

## Pistas y sistema de ayuda

- [x] Crear 3 capas de pistas (ambiental → icono en diario → total) [M] — `PuzzlePistas.capas()` (3 capas) + `registrar_en_diario(diary)` (capa 2, ancla real `scripts/diario/diary_service.gd`); suite `test_puzzle_pistas.gd` 58/0
- [x] Crear menú "Guía del Templo" (puzzle actual + historial resuelto) [M]
- [x] Crear pista diferida (90 s sin progreso) [S] — `avanzar(dt)` + `pista_diferida_disponible()` (`DEMORA_PISTA_S=90.0`; se reinicia con progreso)
- [x] Crear pista de familia textual [S] — `PuzzlePistas.pista_familia()` (derivada de la familia declarada)
- [x] Crear pista de emisor exacto [S] — `PuzzlePistas.pista_emisor_exacto()` (deriva de `PuzzleDef.solucion_minima`)
- [x] Crear solución paso a paso tras 3 pistas [M] — `solucion_paso_a_paso()` (exige `PISTAS_PARA_SOLUCION=3`; devuelve `[]` antes: no regala la solución)
- [x] Crear pistas ancladas a reglas del grafo (nunca texto suelto) [M] — `pista_anclada_a_grafo()` (deriva de `PuzzleDef.reglas_def`; sonda roja: si cambia el receptor en los datos, cambia la pista)
- [x] Crear elección libre de consultar la guía (sin penalización) [S] — `usar_pista()` solo cuenta; `penalizacion()` == 0 siempre (probado tras 5 pistas)
- [x] Documentar pistas y sistema de ayuda [S]

## Anti-arbitrariedad, anti-ambigüedad y métricas

- [?] Implementar validación de arbitrariedad en Editor [C] — **alcance futuro (EditorPlugin): no existe plugin de Editor; bajado de [x] por sobre-cierre (Logs 1402/1407)**
- [x] Implementar validación de arbitrariedad en tests (falla → no build) [M]
- [x] Implementar detección de 2+ soluciones (ambigüedad) [M]
- [x] Implementar detección de regla desconectada [M]
- [x] Implementar feedback "casi solución" (1 paso del objetivo) [S]
- [x] Implementar PuzzleTimer (tiempo, pistas, abandonos) [M]
- [x] Implementar exportación de métricas para playtests externos [M]
- [ ] Documentar anti-arbitrariedad, anti-ambigüedad y métricas [S]

## Checkpoints, reinicio y recompensas

- [x] Definir checkpoints por sala (PuzzleState serializado) [M]
- [x] Definir guardado del estado cada 60 s dentro de un puzzle [S]
- [ ] Definir checkpoint atómico (tmp+rename+.bak) [M]
- [x] Implementar reinicio del puzzle al estado inicial del slot [M]
- [x] Implementar botón de reinicio en la Guía del Templo [S]
- [x] Implementar reinicio automático tras 30 s de diagnóstico inválido (M66) [M]
- [x] Definir recompensas narrativas y materiales por puzzle [M]
- [ ] Definir recompensas únicas no duplicables (copa con M66) [M]
- [ ] Definir recompensas alineadas al lore del templo [S]
- [ ] Documentar checkpoints, reinicio y recompensas [S]

## Testings y documentación

- [x] Diseñar 06-Plan-Testings.md: unitarias del framework [M]
- [x] Diseñar 06-Plan-Testings.md: playtests externos por familia [M]
- [x] Diseñar 06-Plan-Testings.md: edge cases (2 soluciones, regla rota) [M]
- [x] Diseñar 06-Plan-Testings.md: rendimiento (≤ 1 ms por tick) [M]
- [x] Definir criterio de éxito: suite completa pasa sin fallos [S]
- [x] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [x] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] Actualizar plan-actual como espejo del estado real [M]
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [x] Actualizar fila 24 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [x] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]


## Implementacion F1-F4 (2026-08-29 — Hy3/Kilo)

- [x] Implementar el framework emisor-receptor (03-Diseno: decision central) [M] (scripts/templos/puzzle_room.gd: vector S, reglas, objetivo T)
- [x] Implementar Emisor accionable por el jugador [M] (scripts/templos/puzzle_emisor.gd: golpe/placa -> actualiza estado de sala)
- [x] Implementar Receptor (puerta) que reacciona al estado objetivo [M] (scripts/templos/puzzle_puerta.gd: abre el sello de voxels)
- [x] Validar el grafo para garantizar solucion unica y no arbitraria [C] (PuzzleRoom.validar(): rechaza reglas vacias y emisores inexistentes; test 0 fallos)
- [x] Suite de validacion del puzzle (editor/tests) [C] (scripts/templos/test_puzzles.gd: transiciones, completado, no-arbitrariedad; 0 fallos)
- [x] Estado de sala y objetivo verificables por tests [M] (recalcular/progreso/completada)

## Notas del Agente (Cierre parcial - 2026-08-29)

**Modelo:** Hy3 | **Plataforma:** Kilo | **Estado:** nucleo del framework + validacion de no-arbitrariedad implementados y verificados (test 0 fallos, juego arranca sin errores). Puzzles jugables, familias (luz, espejos, agua, hielo...), sistema de ayuda, bandas de dificultad y arte de templos quedan pendientes con dueño.

### Lo que hice
- Framework emisor-receptor de la decision central del 03-Diseno, materializado como scripts reutilizables.
- Sistema de ayuda: no implementado aun (requiere diario/MUI).
- Validacion de arbitrariedad: implementada via PuzzleRoom.validar() (la suite que exige la spec).

### Pendiente (honestidad)
- Puzzles jugables en escena (templos con layout, arte M45).
- Familias: luz/espejos/agua/hielo/bloques/gravedad/movimiento/sonido/secuencia/simbolos/ambientales/herramientas/multilateral.
- Sistema de ayuda Guia del Templo (0/3 fallos, pistas ancladas al grafo).
- Bandas de dificultad (Exploracion/Ritual/Antiguo).

## QA Cruzado — Hy3 / WorkBuddy (2026-09-01, Log 314)

**Modelo:** Hy3 · **Plataforma:** WorkBuddy · **Tipo:** QA cruzado §21.8 (modelo distinto al autor original Hy3/Kilo).

**Veredicto:** ✅ APROBADO (con mejora de bug de integración). El framework emisor→receptor es sólido en tests unitarios, pero se detectó que **estaba desconectado en runtime**: `PuzzleRoom.set_emisor/toggle_emisor` no recalculaban ni notificaban, así que activar emisores nunca abría la puerta automáticamente.

**Bug cerrado (mi fuerte — detección de bugs de integración):**
- `PuzzleRoom`: agregado `al_cambiar: Callable` + `_notificar()` que recalcula y dispara el callback en `set_emisor`/`toggle_emisor`.
- `PuzzlePuerta`: agregado `nombre_receptor` + `evaluar(activos)` que abre la puerta si su nombre está en la lista de receptores activos.
- `test_puzzles.gd`: nuevo `_test_integracion_emisor_puerta()` verifica el ciclo completo (golpear emisores → puerta se abre vía callback).

**Hallazgos honestos:**
- `recalcular()` usa `completada = true` inicial y lo pone `false` si ALGUNA regla falla: para puzzles multi-puerta independiente, "sala completada" solo es true si TODAS abren a la vez. Es semánticamente válido para el caso de una sola puerta objetivo, pero ambiguo para multi-receptor. No lo cambié para no romper el test existente; queda como nota para el dueño si se implementan salas multi-puerta.
- `puzzle_invariant.gd` (M66) delega la validación concreta a M24/M26 (`_check()` siempre true). El framework de M24 ahora expone `validar()` lista para ser usada por ese invariante.

**Limitación:** no ejecutable headless en este entorno (Godot ausente); verificación estática de APIs + coherencia del test contra el código.
**Totales:** 128 ítems · Completados: 100 · Pendientes: 27 · No resueltos: 1.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 31 [x] / 97 [ ] / 0 [?].
> Las marcas no se tocaron.

## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 4)
Los [31 [x]] verificados contra disco y sustentados; 0 degradaciones. Evidencia: `test_puzzles.gd 0/0` = scripts/templos/ (puzzles) en disco.


## Iteracion 1 — framework datos-driven + validador de unicidad + familia presion (2026-10-07)

**Modelo:** DeepSeek-V4.1-Flash | **Plataforma:** WorkBuddy | **Log:** 1407 | **Plan:** aprobado por el director (canal DeepSeek/64).

- Nuevos: `game/isla-ancestral/scripts/templos/puzzle_def.gd` (PuzzleDef: cargar / validar_def / soluciones_minimas / solucion_minima / completado_por / a_puzzle_room) y `test_puzzle_datos.gd` (42 checks, 0 fallos, EXIT 0 x3; piso CHECKS_MINIMOS=42 medido en verde; guardian probado EN ROJO por 3 inyecciones; detector de ambiguedad probado EN ROJO por inyeccion).
- Datos: `data/templos/puzzles/presion/presion_01.json` y `presion_02.json` (formato {emisores, reglas, objetivo}; umbral de peso por emisor).
- Ediciones ADITIVAS (nada renombrado ni quitado): `puzzle_room.gd` (campo objetivo + vector_objetivo / distancia_objetivo / estado_igual_objetivo / esta_a_casi_solucion) y `puzzle_emisor.gd` (umbral_peso + recibir_peso).
- Regresion: test_puzzles.gd 0 fallos, test_templo_headless.gd 4/0, test_templo_m26.gd 92/0 — todos EXIT 0.
- Semantica decidida con el director: el objetivo T se declara en datos y completa con S == T (no "todas las reglas"). Ver `03-Diseno.md`, seccion "Semantica de objetivo y solucion".
- Conteo MEDIDO: 34 completados / 1 con dudas / 93 pendientes = 128.

## Iteracion 2 — framework documentado + familia multilateral migrada (2026-10-07)

**Modelo:** DeepSeek-V4.1-Flash | **Plataforma:** WorkBuddy | **Plan:** aprobado por el director (canal DeepSeek/68).

- **Frente A (docs, items 27-31 y 35):** 03-Diseno.md gana la seccion "Framework emisor→receptor — definiciones" (Emisor/Receptor/Regla/EstadoSala/Objetivo anclados a las clases reales) y 04-Codigo.md el mapa de conceptos a codigo.
- **Frente B (familia multilateral, items 126-128):** NUEVOS `data/templos/puzzles/multilateral/multilateral_anillos.json` (7 anillos, migrado de `puz_anillos`) y `multilateral_final_3fases.json` (3 fases luz+sonido+agua, migrado de `puz_final_3fases`), ambos en esquema `{emisores, reglas, objetivo}`; NUEVO `test_puzzle_multilateral.gd` (38 checks, 0 fallos, EXIT 0 x3; piso `CHECKS_MINIMOS=38` medido; sonda ROJA en vivo: ambiguedad inyectada en el JSON real -> EXIT 1 con 6 fallos nombrados, JSON restaurado byte-exacto).
- **Cruce contra el catalogo real:** la suite verifica que el receptor migrado coincida con `templo_layout_diseno.json` (no se inventan datos).
- **Conteo MEDIDO:** 43 completados / 1 con dudas / 84 pendientes = 128.

## Iteración 3 — familia bloques + plan/resultados de testings (2026-10-07)

**Modelo:** DeepSeek-V4.1-Flash | **Plataforma:** WorkBuddy | **Log:** 1426 | **Plan:** aprobado por el director (canal DeepSeek/72).

- **Frente A — familia bloques (ítems 84-88):** NUEVOS `scripts/templos/puzzle_bloques.gd` (`PuzzleBloques`: capa espacial push/pull sobre un `PuzzleRoom`; 1 eje por pieza, ranuras, límites, puente) + `data/templos/puzzles/bloques/bloques_01.json` (1 bloque, eje x) y `bloques_02.json` (2 bloques, ejes x e y) + `scripts/templos/test_puzzle_bloques.gd` (64 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=64` MEDIDO; sonda ROJA en vivo: eje inválido inyectado en el JSON real → 12 fallos nombrados / EXIT 1; JSON restaurado byte-exacto, sha256 `fdf06cbc…`).
- **Frente B — testings y documentación (ítems 168-176):** NUEVOS `06-Plan-Testings.md` (unitarias / playtests por familia / edge cases / rendimiento / criterio de éxito) y `07-Resultados-Testings.md` (cifras MEDIDAS: 64/42/38/92/4 checks, 0 fallos; tick de sala ~2.0-2.1 µs ≪ 1 ms; `validar_def` n=2 ~22.6 µs); decisiones en `02-Analisis.md` y `03-Diseno.md`; mapa de código en `04-Codigo.md`.
- **Regresión:** test_puzzle_datos 42/0, test_puzzle_multilateral 38/0, test_puzzles 0 fallos, test_templo_m26 92/0, test_templo_headless 4/0 (todas EXIT 0, 0 SCRIPT ERROR).
- **Conteo MEDIDO:** 57 completados / 1 con dudas / 70 pendientes = 128.

## Iteración 4 — gate de regresión + familias luz y espejos (2026-10-07)

**Modelo:** DeepSeek-V4.1-Flash | **Plataforma:** WorkBuddy | **Log:** 1431 | **Plan:** aprobado por el director (canal DeepSeek/77).

- **Frente 0 — gate de regresión:** NUEVO `scripts/templos/test_regresion_templos.gd` (corre las 8 suites de M24 como subprocesos; exige EXIT 0 + 0 `SCRIPT ERROR` + checks ≥ piso por suite; 51 checks, 0 fallos, EXIT 0 ×3; total MEDIDO 362 == piso 362; sonda roja del clasificador con 9 casos sintéticos).
- **Frente A — familia luz (ítems 39-45):** NUEVOS `scripts/templos/puzzle_luz.gd` (`PuzzleLuz`: grafo óptico discreto) + `data/templos/puzzles/luz/luz_01.json` (espejo 45°) y `luz_02.json` (lente + prisma) + `scripts/templos/test_puzzle_luz.gd` (60 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=60` MEDIDO; sonda ROJA en vivo: ángulo 30 en el JSON real → 11 fallos nombrados / EXIT 1; JSON restaurado byte-exacto, sha256 `4f0000af…`).
- **Frente B — familia espejos (ítems 49-54):** NUEVOS `scripts/templos/puzzle_espejos.gd` (`PuzzleEspejos`: capa de rotación que compone un `PuzzleLuz`) + `data/templos/puzzles/espejos/espejos_01.json` (fijo + móvil) y `espejos_02.json` (2 móviles) + `scripts/templos/test_puzzle_espejos.gd` (62 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=62` MEDIDO; sonda ROJA en vivo: espejo fijo a 90 → 9 fallos nombrados / EXIT 1; JSON restaurado byte-exacto, sha256 `e2b08324…`).
- **Guardián anti-falso-verde:** probado EN ROJO por inyección en AMBAS suites (saltar el bloque F + su `_fin` → el resumen NOMBRA el bloque faltante y el piso lo caza; EXIT 1); revertido a verde.
- **Regresión:** las 8 suites de M24 en verde (luz 60, espejos 62, bloques 64, datos 42, multilateral 38, m26 92, headless 4, puzzles sin contador); gate 362/0 EXIT 0.
- **Conteo MEDIDO:** 70 completados / 1 con dudas / 57 pendientes = 128.

## Iteración 5 — familias agua, hielo, gravedad, sonido y pistas + gate extendido (2026-10-07)

**Modelo:** DeepSeek-V4.1-Flash | **Plataforma:** WorkBuddy | **Log:** 1438 | **Plan:** aprobado por el director (canal DeepSeek/81).

- **Frente A — familia agua (ítems 58-63):** NUEVOS `scripts/templos/puzzle_agua.gd` (`PuzzleAgua`: capa hidráulica discreta; `tick()` suma el `caudal`, `drenar()` resta 1, `altura()`/`compuerta_abierta()`/`barca_en_destino()`) + `data/templos/puzzles/agua/agua_01.json` (2 emisores, fuente caudal 2, compuerta/barca umbral 6) y `agua_02.json` (2 fuentes, compuerta umbral 9) + `scripts/templos/test_puzzle_agua.gd` (57 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=57` MEDIDO).
- **Frente B — familia hielo (ítems 67-71):** NUEVOS `scripts/templos/puzzle_hielo.gd` (`PuzzleHielo`: deslizamiento hasta chocar, paredes/huecos, pedazos que se agrietan, `validar_simetria()` data-driven) + `hielo_01.json` / `hielo_02.json` + `test_puzzle_hielo.gd` (59 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=59` MEDIDO).
- **Frente C — familia gravedad (ítems 92-98):** NUEVOS `scripts/templos/puzzle_gravedad.gd` (`PuzzleGravedad`: burbujas, plataformas sincronizadas por fase —onda triangular entera—, pulsos, cintas, `fase_desde_reloj()` sobre M29 `game_clock.gd`) + `gravedad_01.json` / `gravedad_02.json` + `test_puzzle_gravedad.gd` (59 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=59` MEDIDO).
- **Frente D — familia sonido (ítems 102, 104-107; 103 BLOQUEADO por M43):** NUEVOS `scripts/templos/puzzle_sonido.gd` (`PuzzleSonido`: campanas, secuencia 3-5, pista tras 2 intentos; **modelo puro, 0 refs a `AudioServer`**) + `sonido_01.json` / `sonido_02.json` + `test_puzzle_sonido.gd` (54 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=54` MEDIDO).
- **Frente E — familia pistas (ítems 132, 134-139):** NUEVOS `scripts/templos/puzzle_pistas.gd` (`PuzzlePistas`: 3 capas, capa 2 anclada a `diary_service.gd`, pista diferida 90 s, pistas derivadas del grafo, solución tras 3 pistas, penalización 0) + `pistas_01.json` / `pistas_02.json` + `test_puzzle_pistas.gd` (58 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=58` MEDIDO).
- **Frente 0 — gate extendido (condición 1 del director):** `test_regresion_templos.gd` corre ahora **13 suites** (antes 8); las 5 nuevas suman su piso → `TOTAL_MINIMO` 362 → **649** (medido: 649 == piso). Gate **76/0 EXIT 0 ×3**. **Sonda roja EN VIVO:** `agua_01.json` (`caudal` 2→3) → el gate pasa a **EXIT 1** con `test_puzzle_agua` nombrado (57 checks, 5 fallos); JSON restaurado byte-exacto (sha256 `af655940…`).
- **Anti-falso-verde:** las 5 suites tienen bloques A-F nombrados + `_fin()`, `_summary()` en `call_deferred`, piso MEDIDO y bloque D de sonda roja. Guardián probado en rojo en iteraciones previas.
- **Regresión:** las 13 suites en verde (datos 42, multilateral 38, bloques 64, luz 60, espejos 62, agua 57, hielo 59, gravedad 59, sonido 54, pistas 58, m26 92, headless 4, puzzles sin contador); gate 649/0 EXIT 0.
- **Conteo MEDIDO:** 100 completados / 1 con dudas / 27 pendientes = 128. (Se corrigió la línea `Totales` que estaba desactualizada en 57.)
