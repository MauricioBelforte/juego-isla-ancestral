# 03 — Diseño — M24: Templos y Puzzles

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Framework emisor→receptor (decisión central)

- **Emisor:** elemento que produce una señal ante una acción del jugador o del mundo (palanca, placa, cristal de luz, compuerta, secuencia, sonido).
- **Receptor:** elemento que reacciona a la señal (puerta, nivel de agua, rayo activado, bloque movido).
- **Regla:** conector declarativo entre emisores y receptores con condiciones (umbral de peso, línea de audición, dirección de luz, estado de otro puzzle).
- **Estado de sala:** vector `S = (e1…en)` con el valor de cada emisor; el **estado objetivo** `T` es la solución única verificable.

```
Palanca_A(Emisor) ──regla: si ON──▶ Puerta_Este(Receptor)
Cristal_B(Emisor luz) ──si rayo 45°──▶ Runa_Acceso(Receptor: S[7]=1)
```

## Validación de arbitrary/ambigüedad

- En el **Editor** (Validación) y en **tests** se computa el grafo: si hay 0, 2+ soluciones alcanzables o una solución que dependa de una regla no conectada → el puzzle **falla la suite** y no entra al build.
- Doble convalidación en runtime: `estado == objetivo` para completar; si el jugador está a 1 paso del objetivo, el framework emite "casi solución" (efecto visual sutil, no texto).
- Las reglas son transitivas (el puzzle multilateral comparte el vector de sala).

## Familias y datos

| Familia | Emisores | Receptores | Verificación |
|---|---|---|---|
| Luz | farol, lente, prisma | cristal, runa activada | rayo en línea recta, ángulo de incidencia (datos) |
| Espejos | espejo rotatorio | receptor de rayo | giro 45° múltiplos, prueba de camino (Editor) |
| Agua | compuerta, fuente | nivel de agua, barca | altura por compuerta (datos), boyantes |
| Hielo | bloque de hielo | ranuras | simetría de patrón (Editor) |
| Presión | placa, umbral de peso | puerta, elevador | peso estático/dinámico |
| Bloques | bloque push/pull | ranura, puente | movimiento 1 eje, colisiones |
| Gravedad | burbuja de gravedad | dirección de desplazamiento | zonas seleccionadas por sala |
| Movimiento | plataforma móvil, cinta, pulso | sincronización reloj (M29) | fase del reloj (datos) |
| Sonido | campana, gong | receptor acústico | línea de audición clara (M43 hook) |
| Secuencia | botones de secuencia | urna sellada | patrón visible en pista tras 2 intentos |
| Símbolos | glifo, pedestal | sello de puerta | glosario M25 (inscripciones) |
| Ambientales | viento (M32), lluvia, criatura (M65) | puerta de viento, rama | condición climática activa |
| Herramientas | pico, gancho, farol | grieta, pasarela, techo | inventario presente |
| Multilateral | estado de sala compartido | puerta final | mapa-emisor central |

## Sistema de ayuda (Guía del Templo)

1. **0 fallos:** pista ambiental en el diario (icono).
2. **3 fallos / 90 s sin progreso:** pista textual de la familia (ej: "los espejos giran en múltiplos de 45°").
3. **Pista 2:** indica el emisor exacto a activar.
4. **Pista 3 / 5 min sin progreso:** solución paso a paso (una por acordeón).
5. Nunca se penaliza usar ayuda; el jugador elige cuándo consultar.

El sistema respeta "nunca arbitrarios": toda pista está anclada a una regla del grafo (se genera desde datos, no texto suelto).

## Dificultad

| Banda | Zonas | Características |
|---|---|---|
| Exploración | exteriores, ruinas pequeñas (M25) | 1-2 emisores, familia visible, pista en 90 s |
| Ritual | templos medianos | 2-4 emisores, 1 familia oculta, pista en 60 s |
| Antiguo | templo subterráneo (M26), finales | multilaterales, 2 familias, pista en 45 s |

## Checkpoints y reinicio (contrato M66)

- `PuzzleState` serializa: vector de sala, posición de jugador frente al puzzle, recompensas pendientes.
- Guardado en checkpoint de sala (atomico tmp+rename+.bak) y cada 60 s si el jugador está dentro de un puzzle.
- Reinicio: a pedido (botón en Guía del Templo si el puzzle está irresoluble) o automático a los 30 s de diagnóstico inválido (M66).
- Recompensas: 1 sola vez; el cofre de M66 no duplica (slot inmutable).

## UI / Feedbacks (hooks)

- Marco de puzzle activo + nombre (iconografía del templo), brújula de pista en el diario.
- Efecto "casi solución" (parpadeo sutil de receptor a 1 paso).
- Toast de progreso de puzzle (M57, baja prioridad, sin spam).
- M43: cues de activación/fallo con cooldowns.

## Rendimiento y QA

- Framework datos-driven: cada puzzle = archivo JSON/YAML serializable; runtime ≤ 1 ms por tick (sin allocations).
- Validación en Editor (armado) + tests automáticos por familia + playtests externos con métricas de tiempo/pistas/abandonos.
- Suite de integración con M66 (reinicio), M08 (terreno alterado), M13 (framework emisor→receptor, dependencia).

## Semantica de objetivo y solucion (iter. 1 — DeepSeek-V4.1-Flash, 2026-10-07)

**Decision aprobada por el director (canal DeepSeek/64).** Resuelve el riesgo 5.2 de la nota de QA de Hy3 (Log 314): la semantica de `recalcular()` era ambigua para puzzles multi-receptor.

- **Objetivo T:** se declara en los datos (`objetivo: [ids]`) y es el conjunto de emisores que deben estar ON. El puzzle se **completa** cuando el estado `S == T` — NO cuando "todas las reglas se cumplen". La conjuncion de todas las reglas queda como semantica legacy de la iter. 0; NO gobierna el completado datos-driven.
- **Solucion:** un conjunto `M` de emisores es una solucion si **activa el receptor objetivo** (satisface al menos una regla). Es **minima** si ningun subconjunto propio la activa. `PuzzleDef.soluciones_minimas(def)` cuenta las soluciones minimas por fuerza bruta `2^n` con `n <= 16`; si un puzzle declara mas emisores, `validar_def()` lo **rechaza** en vez de silenciar la verificacion.
- **Justicia (garantia de "puzzles justos"):** un puzzle es justo si tiene **exactamente 1** solucion minima y esa solucion == T. `validar_def(def)` devuelve `[]` en ese caso; si no, lista los motivos ("soluciones minimas = 2", "el objetivo declarado [...] no es la solucion minima unica [...]", "emisor huerfano N", "regla usa emisor inexistente N", "receptores multiples", etc.).
- **Receptor unico:** en iter. 1 todas las reglas comparten un unico receptor (el objetivo debe ser unico); `validar_def` lo exige. Multi-receptor queda para iter. 2+.
- **Casi solucion:** `PuzzleRoom.esta_a_casi_solucion()` = distancia de Hamming entre `S` y `T` igual a 1 (feedback sutil, item 148).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1407. Codigo: `scripts/templos/puzzle_def.gd`, `scripts/templos/test_puzzle_datos.gd`; datos `data/templos/puzzles/presion/`.

## Framework emisor→receptor — definiciones (iter. 2 — DeepSeek-V4.1-Flash, 2026-10-07)

Cada concepto del framework queda anclado a su clase viva (implementada en iter. 1) y a los datos.
Cierra los ítems 27-31 y 35 del checklist.

| Concepto | Definición | Implementación viva |
|---|---|---|
| **Emisor** | Elemento que produce una señal por una **acción del jugador** (palanca, golpe) o **del mundo** (peso sobre una placa). Al activarse escribe su valor en el vector de sala. | `scripts/templos/puzzle_emisor.gd` (`PuzzleEmisor`): `recibir_golpe()` (alterna), `set_activo(bool)`, `recibir_peso(peso)` con `umbral_peso` (0 = acción directa; >0 = placa por peso). Llama `sala.set_emisor(id, valor)`. |
| **Receptor** | Elemento que reacciona con un **efecto visible** cuando su regla se cumple. | `scripts/templos/puzzle_puerta.gd` (`PuzzlePuerta`): `evaluar(activos)` abre si su `nombre_receptor` está en la lista de receptores activos; `abrir()` remueve el sello de voxels. |
| **Regla** | **Conector declarativo** entre emisores y un receptor, con condiciones. Se cumple cuando **todos** sus emisores están ON. | Datos: `{"emisores": [ids], "receptor": "..."}`; API: `PuzzleRoom.add_regla(emisores, receptor)`; lectura: `PuzzleDef.reglas_def(def)`. La condición extra (umbral de peso) vive en el emisor (`umbral_peso`). |
| **EstadoSala** | **Vector de emisores** `S` con el valor de cada emisor de la sala. | `scripts/templos/puzzle_room.gd` (`PuzzleRoom`, RefCounted): `emisores` (diccionario id→bool), `get_vector_estado()`, `emisor_on_count()`, `recalcular()`. |
| **Objetivo único verificable** | **Estado objetivo** `T` (emisores que deben estar ON), declarado en datos. El puzzle **se completa** cuando `S == T`. | Datos: `objetivo: [ids]`; API: `PuzzleDef.ids_objetivo(def)`, `PuzzleRoom.objetivo`, `estado_igual_objetivo()`, `esta_a_casi_solucion()` (Hamming-1). Garantía de justicia: `PuzzleDef.validar_def` exige **exactamente 1** solución mínima y que esa solución == T (`soluciones_minimas()` por fuerza bruta). |

**Cierre de ítems:** 27 (Emisor), 28 (Receptor), 29 (Regla), 30 (EstadoSala), 31 (Objetivo único verificable) y 35 (Documentar el framework). Evidencia: las firmas reales de la tabla + suites `test_puzzle_datos.gd` (42/0) y `test_puzzle_multilateral.gd` (38/0).

## Familia multilateral (iter. 2 — DeepSeek-V4.1-Flash, 2026-10-07)

El puzzle **multilateral** comparte el vector de estado de la sala (no un estado por puzzle suelto). Cierra los ítems 126, 127 y 128.

- **Mapa-emisor central (126):** los sub-emisores de la sala central se declaran juntos en un único vector `S` y una **regla central** los une al receptor de la sala. La sala central de M26 ("Rotonda de la Columna") usa **7 anillos** (uno por glifo), migrados a `data/templos/puzzles/multilateral/multilateral_anillos.json` desde el legacy `puz_anillos` (emisor `columna_7_anillos`). Los 7 anillos juntos abren la sala del puzzle final.
- **Puerta final por estado completo (127):** el receptor final (`receptor_final`) se activa cuando `S == T`; `T` = las **3 fases** del puzzle final (luz + sonido + agua), migradas a `multilateral_final_3fases.json` desde el legacy `puz_final_3fases` (emisor `espejo_maestro_gongs_timon`, solución `luz_sonido_agua`).
- **Cruce con el catálogo real:** la suite `test_puzzle_multilateral.gd` verifica que el receptor migrado coincida con el `receptor` del legacy en `data/templos/templo_layout_diseno.json` (no se inventan datos), y que ambos legacy sean `tipo: "multilateral"`.
- **Justicia:** ambos puzzles tienen exactamente 1 solución mínima == objetivo (`PuzzleDef.validar_def` sin errores). La **sonda roja** de la suite prueba que el detector discrimina: al reemplazar la regla AND por 2 caminos OR incomparables, `soluciones_minimas` pasa a 2 y `validar_def` falla con "ambiguo".

## Familia bloques (iter. 3 — DeepSeek-V4.1-Flash, 2026-10-07)

La familia **bloques** (push/pull) es la primera que necesita una **capa espacial** además del
framework emisor→receptor: el movimiento ocurre en una grilla, no en un vector abstracto. Se resolvió
con un intérprete propio (`PuzzleBloques`) que traduce posiciones→emisores sin tocar el framework.
Cierra los ítems 84, 85, 86, 87 y 88.

- **Push/pull con restricción de 1 eje (84):** cada pieza declara `eje` ∈ {`x`, `y`}.
  `PuzzleBloques.empujar()` rechaza cualquier paso que no sea unitario y ortogonal al eje declarado;
  un eje fuera del vocabulario se detecta en `validar_espacial()` (una pieza con eje inválido nunca
  se mueve, jamás "en silencio").
- **Ranuras de destino (85):** cada pieza declara `ranura` (celda objetivo). Cuando `pos == ranura`,
  el emisor asociado pasa a ON; al completarse todas las ranuras, `S == T`.
- **Puentes desplegables (86):** el receptor del puzzle es un **puente** (`puente_bloques`); su efecto
  visible (desplegarse) ocurre cuando el estado de sala coincide con el objetivo.
- **Sin empuje a otras salas (87):** la sala declara
  `limites: {salir_de_grilla: false, salas_adyacentes: false}`. `empujar()` rechaza salir de la grilla
  y ocupar una celda ocupada por otra pieza; `validar_espacial()` exige que ambos límites estén en `false`.
- **Documentación (88):** esta sección + el mapa de código en `04-Codigo.md`.

**Esquema de datos (ejemplo `bloques_01.json`):**

```json
{
  "emisores": [{"id": 0, "tipo": "ranura", "etiqueta": "ranura_este"}],
  "reglas":   [{"emisores": [0], "receptor": "puente_bloques"}],
  "objetivo": [0],
  "bloques": {
    "grilla":   {"ancho": 4, "alto": 1},
    "limites":  {"salir_de_grilla": false, "salas_adyacentes": false},
    "piezas":   [{"id": "bloque_a", "pos": [0, 0], "eje": "x", "ranura": [3, 0], "emisor": 0}]
  }
}
```

**Por qué no hay migración legacy:** el catálogo `data/templos/templo_layout_diseno.json` no tiene
ningún puzzle `tipo: "bloques"` (a diferencia de multilateral, que migró 2 legacy). Por eso la familia
se **diseña** desde el esquema — los ítems 84-88 son "Definir", no "Migrar". Los datos viven en
`data/templos/puzzles/bloques/`.

**Justicia:** ambos puzzles tienen exactamente 1 solución mínima == objetivo (`PuzzleDef.validar_def`).
La **sonda roja** de la suite prueba la capa espacial (eje inválido → 12 fallos nombrados, EXIT 1,
JSON restaurado byte-exacto) y la ambigüedad de reglas.

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1426.

## Familia luz (iter. 4 — DeepSeek-V4.1-Flash, 2026-10-07)

La familia **luz** introduce un **grafo óptico discreto**: el rayo viaja por celdas enteras y los
componentes (espejos, lentes, prismas) lo redirigen según reglas deterministas. No hay física visual:
todo el trazado es verificable por datos. Se resolvió con un intérprete propio (`PuzzleLuz`) que
traduce el recorrido del rayo → emisores sin tocar el framework. Cierra los ítems 39-45.

- **Espejo a 45° verificable (39):** el ángulo de cada espejo es un dato (`angulo`) restringido a
  múltiplos de 45 (`ANGULOS_ESPEJO = [0, 45, 90, 135]`). La reflexión es determinista: `0` invierte la
  componente vertical (N↔S), `90` la horizontal (E↔O), `45` intercambia N↔E / S↔O y `135` intercambia
  E↔S / N↔O. Un ángulo que no sea múltiplo de 45 se detecta en `validar_optica()`.
- **Lente que concentra el rayo (40):** cada lente declara `concentracion`; el cristal receptor exige
  una `concentracion_requerida`. Sin la lente (o con menos concentración) el receptor NO se activa.
- **Prisma que desvía el rayo (41):** cada prisma declara `desvio` (múltiplos de 90, en sentido
  horario). Un desvío fuera de ese vocabulario falla en `validar_optica()`; desvío `0` deja pasar el rayo.
- **Ocultación del rayo por el jugador (42):** `bloquear(celda)`/`desbloquear(celda)` insertan/quitan
  un obstáculo; el rayo se corta en esa celda y el receptor pasa a OFF (reversible, sin fallo punitivo).
- **Cristal receptor que activa runa (43):** cuando el rayo llega al cristal con la concentración
  requerida, el emisor asociado pasa a ON y `S == T` (`estado_igual_objetivo()`).
- **Validación por datos (44):** el trazado es determinista — los mismos datos producen el mismo camino
  (`celdas()`), sin física visual ni aleatoriedad.
- **Documentación (45):** esta sección + el mapa de código en `04-Codigo.md`.

**Esquema de datos (ejemplo `luz_01.json`):**

```json
{
  "emisores": [{"id": 0, "tipo": "cristal", "etiqueta": "cristal_norte"}],
  "reglas":   [{"emisores": [0], "receptor": "runa_luz"}],
  "objetivo": [0],
  "luz": {
    "grilla":  {"ancho": 4, "alto": 4},
    "fuente":  {"pos": [0, 3], "dir": [1, 0]},
    "espejos": [{"id": "espejo_a", "pos": [3, 3], "angulo": 45}],
    "lentes":  [],
    "prismas": [],
    "cristal": {"pos": [3, 1], "concentracion_requerida": 0, "emisor": 0},
    "bloqueos": []
  }
}
```

**Por qué no hay migración legacy:** el catálogo `data/templos/templo_layout_diseno.json` no tiene
ningún puzzle `tipo: "luz"`; la familia se **diseña** desde el esquema. Los datos viven en
`data/templos/puzzles/luz/`.

**Justicia:** ambos puzzles tienen exactamente 1 solución mínima == objetivo (`PuzzleDef.validar_def`).
La **sonda roja** de la suite prueba la capa óptica EN VIVO sobre el JSON real (ángulo 30 en vez de 45 →
11 fallos nombrados, EXIT 1; JSON restaurado byte-exacto, sha256 `4f0000af…`).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1431.

## Familia espejos (iter. 4 — DeepSeek-V4.1-Flash, 2026-10-07)

La familia **espejos** es la segunda capa sobre el grafo óptico: no reimplementa el trazado, lo
**compone** (contiene un `PuzzleLuz`) y agrega la **capa de rotación**. Cierra los ítems 49-54.

- **Rotación en múltiplos de 45° (49):** `rotar(id, grados)` acepta solo múltiplos de 45, normaliza el
  resultado al rango canónico (`_norm_angulo`, módulo 180) y rechaza espejos fijos o inexistentes. La
  rotación es discreta: nunca hay ángulos intermedios.
- **Caminos verificables (Editor) (50):** `camino()` devuelve la secuencia de celdas del rayo y
  `validar_camino()` comprueba que cada paso sea contiguo (Manhattan == 1) y que, si el rayo llega,
  termine en el cristal — verificable por datos, no por render.
- **Espejos fijos y móviles (51):** cada espejo se declara en `fijos` o `moviles`; `es_movil()`/`es_fijo()`
  y `rotar()` respetan esa distinción (un espejo fijo nunca rota).
- **Cadena con la familia de luz (52):** los espejos **consumen** la salida de luz — el trazado es el
  mismo `PuzzleLuz`; la rotación solo cambia los ángulos de entrada. Un puzzle de espejos es un puzzle de
  luz + una capa de rotación.
- **Feedback de dirección al rotar (53):** `feedback(id)` devuelve `"entrada->salida"` (p. ej. `"E->N"`)
  del espejo indicado tras el último trazado, para retroalimentar al jugador al rotar.
- **Documentación (54):** esta sección + el mapa de código en `04-Codigo.md`.

**Esquema de datos (ejemplo `espejos_01.json`):**

```json
{
  "emisores": [{"id": 0, "tipo": "cristal", "etiqueta": "cristal_oeste"}],
  "reglas":   [{"emisores": [0], "receptor": "runa_espejos"}],
  "objetivo": [0],
  "luz": {
    "grilla":  {"ancho": 6, "alto": 6},
    "fuente":  {"pos": [0, 0], "dir": [1, 0]},
    "espejos": [{"id": "espejo_a", "pos": [2, 0], "angulo": 135},
                {"id": "espejo_b", "pos": [2, 4], "angulo": 0}],
    "cristal": {"pos": [0, 4], "concentracion_requerida": 0, "emisor": 0}
  },
  "espejos": {"rotacion_grados": 45, "fijos": ["espejo_a"], "moviles": ["espejo_b"]}
}
```

**Justicia:** ambos puzzles tienen 1 solución mínima == objetivo. La **sonda roja** de la suite prueba la
capa de rotación EN VIVO sobre el JSON real (espejo fijo a 90 en vez de 135 → 9 fallos nombrados, EXIT 1;
JSON restaurado byte-exacto, sha256 `e2b08324…`).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1431.

## Familia agua (iter. 5 — DeepSeek-V4.1-Flash, 2026-10-07)

La familia **agua** introduce un modelo **hidráulico discreto**: el nivel de agua es un entero por celda,
las fuentes lo alimentan gradualmente y compuertas/barcas reaccionan al superar un umbral. No hay
simulación de fluidos: el nivel es verificable por datos. Se resuelve con un intérprete propio
(`PuzzleAgua`) que traduce niveles → emisores sin tocar el framework. Cierra los ítems 58-63.

- **Compuertas con niveles (58):** cada compuerta declara `umbral`; `compuerta_abierta(id)` es
  `altura(pos) >= umbral`. El emisor asociado pasa a ON al abrirse.
- **Fuente que alimenta el nivel (59):** cada fuente declara `caudal` y `max`; `tick()` suma EXACTAMENTE
  `caudal` a su celda, con tope `max` (nunca lo supera).
- **Barca flotante (60):** cada barca declara `umbral` y `destino`; al alcanzar el umbral cruza
  (`barca_en_destino`), y el cruce es **permanente** (no se pierde al drenar).
- **Altura verificable por datos (61):** `altura(celda)` / `alturas()` devuelven enteros deterministas.
- **Relleno/drenaje gradual (62):** `tick()` suma el caudal y `drenar()` resta 1 por llamada; probado que
  NO hay salto al umbral (sonda roja con `caudal` alterado).
- **Documentación (63):** esta sección + el mapa de código en `04-Codigo.md`.

**Esquema de datos (ejemplo `agua_01.json`):**

```json
{
  "emisores": [{"id": 0, "tipo": "compuerta", "etiqueta": "compuerta_norte"},
               {"id": 1, "tipo": "barca", "etiqueta": "barca_este"}],
  "reglas":   [{"emisores": [0, 1], "receptor": "puerta_agua"}],
  "objetivo": [0, 1],
  "agua": {
    "grilla":     {"ancho": 5, "alto": 3},
    "fuentes":    [{"id": "fuente_a", "pos": [1, 1], "caudal": 2, "max": 12}],
    "compuertas": [{"id": "compuerta_a", "pos": [1, 1], "umbral": 6, "emisor": 0}],
    "barcas":     [{"id": "barca_a", "pos": [1, 1], "umbral": 6, "destino": [3, 1], "emisor": 1}]
  }
}
```

**Justicia:** ambos puzzles tienen 1 solución mínima == objetivo. La **sonda roja** de la suite prueba la
capa hidráulica EN VIVO sobre copias mutadas (umbral 0, emisor inexistente, caudal 0, destino == origen).
Además se probó EN VIVO el gate con este JSON: `caudal` 2→3 → la suite de agua falla (5 fallos) y el gate
pasa a EXIT 1; JSON restaurado byte-exacto (sha256 `af655940…`).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1438.

## Familia hielo (iter. 5 — DeepSeek-V4.1-Flash, 2026-10-07)

La familia **hielo** introduce la capa de **deslizamiento**: un bloque empujado en una dirección se
desliza hasta chocar con el borde, una pared, otro bloque, o caer en un hueco. Todo se decide por DATOS
(grilla de enteros). Intérprete propio `PuzzleHielo`. Cierra los ítems 67-71.

- **Deslizamiento (67):** `deslizar(id, dir)` desliza hasta chocar; `pos_de(id)` informa la celda.
- **Patrones simétricos (68):** `validar_simetria()` data-driven (ejes `x`/`y`/`ambos`), espejo
  `ancho-1-x` / `alto-1-y`. **No hay EditorPlugin** en el proyecto: el alcance se ajustó a un validador
  de datos (aprobado en el plan) en vez de un plugin de Editor.
- **Colisiones (69):** `paredes` detienen el bloque; `huecos` lo consumen (`cayo_en_hueco(id)`; el bloque
  desaparece y su emisor vuelve a OFF).
- **Pedazos de hielo (70):** `pedazos {pos, usos}`: se agrietan al ser pisados y al llegar a 0 se rompen
  dejando un hueco (`usos_pedazo`). El hueco que crea un pedazo NO consume al bloque que lo creó (se
  desgasta DESPUÉS de moverse), solo al siguiente.
- **Documentación (71):** esta sección + el mapa de código en `04-Codigo.md`.

**Esquema de datos (ejemplo `hielo_02.json`):**

```json
{
  "emisores": [{"id": 0, "tipo": "ranura", "etiqueta": "ranura_oeste"},
               {"id": 1, "tipo": "ranura", "etiqueta": "ranura_este"}],
  "reglas":   [{"emisores": [0, 1], "receptor": "puente_hielo_2"}],
  "objetivo": [0, 1],
  "hielo": {
    "grilla":   {"ancho": 7, "alto": 3},
    "simetria": "x",
    "paredes":  [[2, 1], [4, 1]],
    "huecos":   [[1, 0], [5, 0]],
    "bloques":  [{"id": "bloque_a", "pos": [0, 1], "emisor": 0},
                 {"id": "bloque_b", "pos": [6, 1], "emisor": 1}],
    "pedazos":  [{"pos": [1, 1], "usos": 2}, {"pos": [5, 1], "usos": 2}]
  }
}
```

**Justicia:** ambos puzzles tienen 1 solución mínima == objetivo. La **sonda roja** prueba la capa EN VIVO
sobre copias mutadas (usos 0, pared+hueco en la misma celda, emisor inexistente, simetría rota, bloque
sobre pared, y bloque detenido por otro bloque).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1438.

## Familia gravedad y movimiento (iter. 5 — DeepSeek-V4.1-Flash, 2026-10-07)

La familia **gravedad y movimiento** añade la capa de MOVIMIENTO: zonas con gravedad propia, plataformas
móviles sincronizadas por una FASE común, pulsos de aire y cintas. Todo es aritmética ENTERA sobre datos
(determinista). Intérprete propio `PuzzleGravedad`. Cierra los ítems 92-98.

- **Burbujas de gravedad (92):** `burbujas {zona:[x,y,w,h], dir}` + `direccion_gravedad(pos)` (la última
  burbuja que contiene la celda gana; fuera de toda zona vale `GRAVEDAD_DEFECTO = (0,1)`).
- **Cambio de dirección (93):** `cambia_direccion(a, b)` compara la dirección de dos celdas.
- **Plataformas sincronizadas (94):** `plataformas {grupo, amplitud, periodo}` + `plataforma_offset(id,
  fase)` (onda triangular entera) / `plataforma_en_extremo`. Mismo grupo + mismo periodo = sincronizadas;
  `validar_gravedad` rechaza un grupo con periodos distintos.
- **Pulsos de aire (95):** `pulsos {periodo, duracion}` + `pulso_activo(id, fase)` (activo dentro de
  `[0, duracion)`).
- **Cintas transportadoras (96):** `cintas {pos, dir}` + `cinta_dir(id)` / `cinta_en(pos)`.
- **Sincronización con el reloj M29 (97):** `fase_desde_reloj(reloj)` = `dia*1440 + hora*60 + minuto`
  sobre `scripts/time/game_clock.gd` (`dia_absoluto`/`get_hora`/`get_minuto`); duck-typed (devuelve -1 si
  el objeto no expone el contrato). Contrato verificado por archivo, no por doc.
- **Documentación (98):** esta sección + el mapa de código en `04-Codigo.md`.

**Esquema de datos (ejemplo `gravedad_01.json`):**

```json
{
  "emisores": [{"id": 0, "tipo": "runa", "etiqueta": "runa_alta_1"},
               {"id": 1, "tipo": "runa", "etiqueta": "runa_alta_2"}],
  "reglas":   [{"emisores": [0, 1], "receptor": "puerta_gravedad"}],
  "objetivo": [0, 1],
  "gravedad": {
    "grilla":      {"ancho": 6, "alto": 4},
    "burbujas":    [{"id": "burbuja_a", "zona": [0, 0, 6, 4], "dir": [0, -1]}],
    "plataformas": [{"id": "plat_a", "pos": [1, 3], "grupo": "g1", "amplitud": 2, "periodo": 8, "emisor": 0},
                    {"id": "plat_b", "pos": [4, 3], "grupo": "g1", "amplitud": 2, "periodo": 8, "emisor": 1}],
    "pulsos":      [{"id": "pulso_a", "periodo": 6, "duracion": 2}],
    "cintas":      [{"id": "cinta_a", "pos": [3, 3], "dir": [1, 0]}]
  }
}
```

**Justicia:** ambos puzzles tienen 1 solución mínima == objetivo. La **sonda roja** prueba la capa EN VIVO
sobre copias mutadas (periodo 0, amplitud 0, dirección nula, emisor inexistente, grupo desincronizado,
sin plataformas, pulso con duración > periodo, zona mal formada) y la semántica (sin burbujas → gravedad
por defecto; sin plataformas el receptor nunca se activa).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1438.

## Familia sonido y secuencia (iter. 5 — DeepSeek-V4.1-Flash, 2026-10-07)

La familia **sonido y secuencia** modela campanas/gongs como emisores: el jugador los toca en un orden y
el receptor se activa cuando la secuencia coincide con la declarada. Intérprete propio `PuzzleSonido`.
Cierra los ítems 102, 104-107 (el 103 queda BLOQUEADO por M43).

- **Campanas/gongs como emisores (102):** `campanas {pos, tono, emisor}` + `tocar(id)`.
- **Sin hardware de audio (104):** **modelo PURO de datos** — la clase NO toca `AudioServer` ni ningún nodo
  de audio (0 referencias en código; la suite lo verifica leyendo el fuente y descartando comentarios). El
  "sonido" es un identificador de tono, no una reproducción: el puzzle es verificable en headless.
- **Secuencias de 3-5 símbolos (105):** `secuencia` validada entre `LARGO_MIN=3` y `LARGO_MAX=5`.
- **Pista del patrón tras 2 intentos (106):** `INTENTOS_PARA_PISTA=2` + `pista_disponible()` /
  `pista_patron()` (vacío antes de 2 fallos: no se regala).
- **Documentación (107):** esta sección + el mapa de código en `04-Codigo.md`.
- **Ítem 103 (M43) — BLOQUEADO:** `scripts/audio/` no expone "línea de audición" (0 hits medidos). No se
  fuerza; queda para el dueño de M43.

**Esquema de datos (ejemplo `sonido_02.json`):**

```json
{
  "emisores": [{"id": 0, "tipo": "runa", "etiqueta": "runa_sonora_1"},
               {"id": 1, "tipo": "runa", "etiqueta": "runa_sonora_2"}],
  "reglas":   [{"emisores": [0, 1], "receptor": "puerta_sonido_2"}],
  "objetivo": [0, 1],
  "sonido": {
    "grilla":    {"ancho": 5, "alto": 1},
    "campanas":  [{"id": "c1", "pos": [0, 0], "tono": 1, "emisor": 0},
                  {"id": "c2", "pos": [1, 0], "tono": 2, "emisor": 0},
                  {"id": "c3", "pos": [2, 0], "tono": 3, "emisor": 0},
                  {"id": "c4", "pos": [3, 0], "tono": 4, "emisor": 1},
                  {"id": "c5", "pos": [4, 0], "tono": 5, "emisor": 1}],
    "secuencia": ["c3", "c1", "c5", "c2", "c4"]
  }
}
```

**Justicia:** ambos puzzles tienen 1 solución mínima == objetivo. La **sonda roja** prueba la capa EN VIVO
sobre copias mutadas (secuencia de 2 y de 6, emisor inexistente, campana inexistente en la secuencia, sin
campanas) y la semántica (una secuencia equivocada nunca resuelve; tocar una campana inexistente no rompe
el intento).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1438.

## Pistas y sistema de ayuda (iter. 5 — DeepSeek-V4.1-Flash, 2026-10-07)

La familia **pistas** extiende el framework con el sistema de ayuda. TODA pista se **deriva** de los datos
del grafo (`PuzzleDef.reglas_def` / `solucion_minima`): no hay texto suelto escrito a mano (ítem 138). Las
pistas son información, nunca penalización (ítem 139). Intérprete propio `PuzzlePistas`. Cierra los ítems
132, 134-139.

- **3 capas (132):** `capas()` = `["ambiental", "diario", "total"]`; la capa 2 se materializa con
  `registrar_en_diario(diary)` sobre el contrato real de `scripts/diario/diary_service.gd`
  (`registrar(entrada_id, categoria) -> bool`), duck-typed.
- **Pista diferida (134):** `avanzar(dt)` + `pista_diferida_disponible()` (`DEMORA_PISTA_S=90.0`);
  `reiniciar_espera()` la vuelve a bloquear ante cualquier progreso real.
- **Pista de familia textual (135):** `pista_familia()` (derivada de la familia declarada).
- **Pista de emisor exacto (136):** `pista_emisor_exacto()` (deriva de `PuzzleDef.solucion_minima`).
- **Solución paso a paso tras 3 pistas (137):** `solucion_paso_a_paso()` exige `PISTAS_PARA_SOLUCION=3` y
  devuelve `[]` antes (no regala la solución).
- **Pistas ancladas a las reglas del grafo (138):** `pista_anclada_a_grafo()` deriva de
  `PuzzleDef.reglas_def` (receptor ← conjunto de emisores). Probado EN VIVO: si el receptor cambia en los
  datos, la pista cambia.
- **Elección libre sin penalización (139):** `usar_pista()` solo incrementa el contador; `penalizacion()`
  devuelve siempre 0 (probado tras 5 pistas).

**Esquema de datos (ejemplo `pistas_01.json`):**

```json
{
  "emisores": [{"id": 0, "tipo": "placa", "etiqueta": "placa_estatica"},
               {"id": 1, "tipo": "placa", "etiqueta": "placa_dinamica"}],
  "reglas":   [{"emisores": [0, 1], "receptor": "puerta_pistas"}],
  "objetivo": [0, 1],
  "pistas": {"capas": ["ambiental", "diario", "total"], "demora_segundos": 90,
             "pistas_para_solucion": 3, "categoria_diario": "templos"}
}
```

**Anclas reales (verificadas por archivo):** `scripts/diario/diary_service.gd`
(`registrar(entrada_id, categoria)`), `scripts/templos/templo_telemetria.gd`
(`registrar_intento(puzzle_id, pistas_usadas)`).

**Justicia:** ambos puzzles tienen 1 solución mínima == objetivo. La **sonda roja** prueba la capa EN VIVO
(definición vacía, sin familia, sin reglas) y la DERIVACIÓN (receptor mutado → la pista lo cita; regla
reducida a `[0]` → el emisor exacto deja de citar el 1).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1438.
