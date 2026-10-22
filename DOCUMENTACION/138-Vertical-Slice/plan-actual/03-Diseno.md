**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 138: Vertical Slice

## 1. Arquitectura del Slice

```
┌─────────────────────────────────────────────────────────────────┐
│ Escena: vslice_aurora.tscn (zona = esquina de Aurora)          │
│  ├── Zona (M10): costa + bosque + prado + ruina + casa         │
│  ├── Player (M11/M12/48): movimiento + animaciones             │
│  ├── Recurso y herramienta (M15/M13): madera + hacha con anim  │
│  ├── NPC Finneas (M19/M64/M21): rutina + diálogos              │
│  ├── Casa (M18): dormir/save + interior                        │
│  ├── Ruina + puzzle (M25/M24): recompensa                      │
│  ├── Audio (M41-M44): música + SFX + ambiente                  │
│  ├── VFX (M52): extracción, colocación, recompensa, dormir     │
│  └── Autosave (M59/M60): al dormir y en hitos                  │
├─────────────────────────────────────────────────────────────────┤
│ UI (M53): inventario, diálogo, prompt, pausa                   │
│ Tutorial (M92): guiado visual (flechas + resaltado)            │
│ Misión (M22/M23/M38): 3 pasos + recompensa                     │
├─────────────────────────────────────────────────────────────────┤
│ docs/vslice/                                                   │
│  ├── PLAYTEST.md          (5+ testers, encuesta)               │
│  ├── REPORTE-FPS.md       (M61 por categoría)                  │
│  ├── GONOGO-M139.md       (decisión de escalar)                │
│  └── IDEAS-DESCARTADAS.md (congelación de alcance)             │
└─────────────────────────────────────────────────────────────────┘
```

## 2. Componentes

### 2.1 Zona (RF1)
- Geografía: playa curva + bosque de pinos + prado abierto; 3-5 puntos de interés (casa, ruina, muelle roto, arboleda, altar).
- Altura + iluminación (M49) dentro del budget de render (M61: 5.0ms).
- Vegetación (M50) con instanciado (`MultiMesh`), sin rebalsar draw calls.

### 2.2 Recursos y herramienta (RF3)
- Madera como recurso clave (árboles de la zona, 5 bloques de madera por árbol).
- Hacha: 15 usos, animación de swing (M48), SFX de impacto (M43) y VFX de virutas (M52).
- Modelo M13: durabilidad + mejora simple esbozada (mejora no entra al slice).

### 2.3 Finneas (RF2)
- Rutina de día simple en la zona (waypoints: muelle→faro→plaza→casa; M64 esbozado).
- 6+ líneas de diálogo con rama de LÍNEA 1 misión (búsqueda de la herramienta).
- Regalo de bienvenida conceptual (consistente con M20 futuro).
- Consume `world_data.json` (M147) para mostrar su nombre en el idioma correcto (M87).

### 2.4 Misión y recompensa (RF12)
```
Paso 1: Finneas pide madera (2)  → entregar
Paso 2: Finneas pide el hacha perdida en la ruina → resolver puzzle
Paso 3: Recompensa: 20 AO + semilla de jardín (M33 futuro)
```
Recompensa obedece M93 (margen 5-15%).

### 2.5 Ruina y puzzle (RF5)
- Ruina de 3 salas pequeñas; puzzle de palancas (2 palancas + alineación de símbolos, M24/M147 consulta símbolos del canon).
- Recompensa: el Hacha de Finneas (tool) + mensaje ominoso/cozy (M148/M150 futuro).

### 2.6 Casa y autosave (RF4/RF9)
- Casa: entrada + cama + mesa; dormir: fade a negro, pasa el día, autosave.
- Autosave también en hitos (entrega, puzzle resuelto, compra futura).
- Formato v2 (M60): full zone state, schema_version.

### 2.7 Audio (RF6/RF7)
- Música (M41): tema diurno/noche de Aurora (2 stems), transición suave al dormir.
- SFX (M43): extraer, colocar, swing, moneda, puerta, puzzle.
- Ambiente (M42): viento, mar, pájaros; mezcla con `AudioMixer` (M42).
- Feedback (M44): sprint text cues (música/tonos) para logros de acción.

### 2.8 Rendimiento (RF15)
- Profiler con el perfil M61: gameplay 2.5 / voxel 4.0 / IA 2.0 / partículas 1.0 / culling 0.5 / render 5.0 / UI 1.5 = 16.5ms.
- `VSYNC` off durante el muestreo (medición cruda); reporte en `REPORTE-FPS.md`.

## 3. Flujo de Juego (loop de 20-30 min)

```
Spawn en la playa de Aurora
 → Guiado visual (M92) resalta el faro y al NPC
 → Conocer a Finneas (diálogo + misión: hacha perdida en la ruina)
 → Extraer madera (siente voxel + SFX + VFX + animación)
 → Ir a la ruina (explorar: planta, mar, bosque)
 → Resolver el puzzle de palancas/símbolos → obtener el Hacha
 → Volver donde Finneas → entrega → recompensa (20 AO + semilla)
 → Plantar la semilla (micromomento de jardín)
 → Dormir en la casa → autosave → día 2 con cambio de música
 → Fin del slice (créditos de demo + encuesta)
```

## 4. Criterios de Escala a Pre-Alpha (M139)

| Criterio | Métrica | Escalar si |
|---|---|---|
| Experiencia completa | % testers que terminan el slice | ≥ 90% |
| Encuesta "es my game" | % que identifica Isla Ancestral | ≥ 90% |
| Diversión | Media encuesta | ≥ 7,5/10 |
| Rendimiento | FPS medio + máx frame (P99) | ≥ 60 / +40ms P99 |
| Guardado | Ciclos 10× | 0 pérdidas |
| Deuda técnica | Registrada y aceptada | Documentada |
| Alcance | Congelado | Sin creep |

## 5. Cierre del Slice

1. Tag git `vslice-v1`, demo empaquetada (M116/M117 aplicar build).
2. Playtest ampliado (5+ testers) + feedback externo (publishers).
3. GONOGO-M139.md firmado.
4. Retrospectiva: qué escalar, qué cortar, qué deuda queda.
5. Presupuesto ajustado con los datos reales del slice (M134).

## Definiciones del slice — turno 2-BIS (G-5.3-Flash-Agente, 2026-10-22)


Definiciones consolidadas de los items [S] "Definir X" del 05-Checklist
(los numeros vienen del propio 05; esta seccion los consolida como decision
de diseño para el slice de Aurora; flip de [S], los [M] profundos quedan).

## Input M02 — recursos y herramientas del slice

- **M madera como recurso clave del slice**: fuente = arboles de la zona
  (Aurora bosque/prado). Cada arbol derriba entrega 5 bloques de madera
  (input del 05) con la Hacha; la madera alimenta la mision principal del
  slice (3 pasos) y el crafting minimo de muebles del slice de M16/M17.
- **Arbol con 5 bloques de madera**: el derribo completo consume la
  durabilidad de la Hacha proporcional al swing por bloque (Hacha = 15
  usos de durabilidad modelo: cada swing gasta 1; derribar un arbol entero
  gasta ~5 usos, dejando 10 usos para el resto del slice).
- **Hacha con 15 usos de durabilidad**: herramienta del slice definida en
  el catalogo M12/M13; al llegar a 0 se rompe (feedback de ruptura por
  M43/M52 en el itemifct [M] profundo no cubierto aquí).

## Mision del slice (3 pasos)

**UX de mision / indicador de objetivo (input M53, G-5.3-Flash-Agente
2026-10-22):** panel de mision activa en la esquina superior derecha del HUD
(capas M53 ya montadas: DOM-UI dialogo/pausa/menus): 1 linea de objetivo
actual ("Madera: 2/5" / "Afilar hacha en la ruina" / "Volver a Finneas"),
color canonico sello brisa para el destacado del paso completado (check corto,
sin animacion costosa). Sin minimapa ni flecha 3D (budget de render del slice;
la flecha es sustituida por el texto de POI en la linea 2). El panel se
oculta en dialogo activo (cede lugar al submenu M21) y reaparece al cerrarlo.
Contrato: señal mision_paso_actualizada(dict) desde el sistema de mision ->
UI escucha y re-pinta; sin polling por frame.

1. Conversacion con Finneas:	dialogo con 6+ lineas y rama de mision (M21).
2. Recolectar madera:	derribar arboles (5 bloques por arbol con la Hacha
   de 15 usos).
3. Entrega: llevar la madera a la ruina del slice -> recompensa.

## Recompensa (input M93 margen 5-15%)

**Anclaje canonico del margen (G-5.3-Flash-Agente, 2026-10-22):** regla M93
(05-Checklist M93: "recompensa por mision secundaria entre 5-15% del siguiente
desbloqueo") ejercida desde data: `unlocks.json` -> taller_crafting = 150 AO
(orden 1, condicion "mision_secundaria_inicial": el slice ES esa mision).
Banda valida: 5-15% de 150 = 7.5-22.5 -> canon redondea [8, 22]
(quests.json reglas.recompensa_secundaria_ao). Recompensa del slice: 20 AO =
13.3% de 150 -> DENTRO del margen (7 AO bajo el tope, holgura de balance para
el QA de economia). La semilla de jardin no computa AO (insumo de progreso,
items_exclusivos_no_monetizables).

- 20 AO + semilla de jardin (la semilla habilita el garden plant bed del
  slice; el AO fijo 20 se mantiene dentro del margen 5-15% de la economia
  M93 de la etapa incial).

## Finneas (NPC guia del slice)

- Rutina por waypoints (M64) con validacion de NO atravesar muros/obstaculos
  (el pathing real usa el NavigationServer M64 — prohibido forzar posición).
- 6+ lineas de dialogo con rama de mision (M21 grafo; localizacion es/es).
- Regalo de bienvenida conceptual (M20 futuro): 1 regalito al primer
  handshake con el jugador (gacha cozy, sin economia real).

## Zona del slice: esquina de Aurora (definicion de contenido - G-5.3-Flash-Agente, 2026-10-22)

La slice vive en UNA esquina de Aurora (no requiere isla nueva): el cuadrante
costero sudeste del mapa raiz (M167/MundoRaiz RADIO_ISLA), delimitado por:

- **Playa de Finneas**: franja arenosa sur, spawn del slice (escalera del muelle
  como ancla de misión paso 3).
- **Prado interior**: pasto bajo con 3-4 arboles talables (fuente de los 5
  bloques de madera del paso 1; respeta madera=5 bloques/arbol de M138).
- **Bosque en franja**: borde oeste denso (pared natural del slice, no navegable
  a fondo; deliberado para acotar el area).
- **Costa abierta / muelle roto**: enlace visual con el mar (POI cuando el
  jugador mira hacia fuera; sin gameplay M-desbloqueado).
- **Ruina del atalaya**: acantilado este. POI de misión paso 2 (afilar el
  Hacha), decorada con el simbolo canonico del sello brisa (ver canon abajo).
  La inscripcion final guarda "un canto sobre el viento" (gancho hacia M148).

POI total del slice: 5 (casa de Finneas, prado talable, muelle roto, ruina del
atalaya, altar menor de la arboleda). Toda posicion de NPC se resuelve con
get_height + posicionar_sobre_terreno (M64 NavigationServer; prohibido forzar).

## Ruina del atalaya (3 salas + puzzle - G-5.3-Flash-Agente, S27 2026-10-22)

**Layout de 3 salas (interior compacto, 1 escena):**

1. **Sala de entrada "El Vestibulo del Viento"**: derrumbe parcial con la
   puerta sellada por el grabado repetido de `simbolo_del_sello_brisa`
   (canon M147). Entrada libre; pausa de lectura (Placa derruida: "los
   primeros jardineros cantaban con el viento"). El jugador ve las 2 palancas
   al fondo reja de por medio.
2. **Sala central "La Camara de las Palancas"**: puzzle de 2 palancas
   (detalle abajo). Al resolver: la reja abre y el viento ambiental sube de
   volumen (cuelgue auditive intencional, M42).
3. **Santuario "El Cantico"**: inscripcion final (La inscripcion guarda un
   canto sobre el viento - gancho M148) y el pedestal del **Hacha de Finneas**
   (recompensa de la sala, entrega en mano). Guardado por hito (autosave
   "puzzle_resuelto").

**Puzzle de 2 palancas + alineacion de simbolos (input M24):**

- 2 palancas (izquierda = disco del SOL, derecha = disco de la BRISA del sello); cada palanca tiene 3 posiciones (alba/mediodia/ocaso).
- Objetivo: alinear el disco del SOL en OCASO y el disco de la BRISA en ALBA
  (pista de la placa: "el viento nace cuando el sol muere; busca el espejo
  del horizonte" - la BRISA queda en el valor espejo del SOL).
- Interaccion M24 (interact 1 boton por palanca, cicla posicion); feedback:
  trinquete SFX + click del disco (M43); posiciones invalidas NO castigan
  (sin reset ni tiempo: cozy; la reja solo mirar cerrada).
- Solucion canonica: (palanca_SOL=ocaso, palanca_BRISA=alba) - 9 estados
  posibles, 1 valido, 8 invalidos benignos. Sin orden secuencial (los
  cambios son simultaneos: combinacion, no secuencia).
- Codigo de gancho: senal puzzle_sala_resuelta (identificador "ruina_sello")
  para autosave/verificacion (M60).

**Recompensa de la ruina: Hacha de Finneas + mensaje cozy:**

- **Hacha de Finneas** (id `hacha_finneas`): herramienta unica del slice,
  duracion compartida con el Hacha comun (M138: 15 usos; la de Finneas arranca
  a 30 usos), desbloquea talado de la ARBOLEDA (los arboles del prado ya
  talables con hacha comun; los 2 arboles viejos de la arboleda exigen
  hacha_finneas: contenido post-puzzle para pacing 20-30 min).
- **Mensaje cozy** (placa del santuario, al retirar el Hacha): "Quien guarda
  el viento guarda la mano que tala. - F." (texto final del grafo
  finneas_slice v2: node `recompensa_cozy` pendiente de v2 del JSON, no
  bloquea el slice).

## Casa de Finneas y el ciclo del dia (dormir + autosave - S29 2026-10-22)

**Casa (L50):** cabin de una pieza en la playa, a 8 m de la escalera del
muelle. Interior: entrada libre (colision servida por muros M08), CAMA
(single) contra la pared norte y MESA con una vela y la carta del slice
(relee la mision: interaccion M24 reabre el panel de objetivo sin volver al
NPC). Sin tesoros ni cofres (scope acotado).

**Dormir (L51):** interact con la cama de noche (o en cualquier hora si el
jugador completo el paso 1 de la mision) dispara: fade a negro 1.2 s
(CanvasLayer UI, opacidad del negro) -> salto del reloj del mundo al alba
(M29 partida/definicion de dia) -> fade in 0.8 s. La musica sale con
crossfade 1.0 s (tema diurno surge de nuevo; M41/L60-L59). Estados
intermedios invalidos: NO dormir durante dialogo activo.

**Autosave (L52/L53, anclado al save v2 de S28):**
- Al dormir: snapshot completo del save v2 (schema_version 2; claves del
  slice: mision_paso, hacha_finneas_duracion, estado_discos,
  puzzle_resuelto, flags M21).
- En hitos (sin dormir): entregas de la mision (paso 2->3) y
  `puzzle_sala_resuelta("ruina_sello")` disparan autosave puntual con las
  mismas claves; marca de humo "Guardando..." 0.6 s en la esquina (UI M53,
  sin bloquear input).
- Contrato: senal `guardado(slice_dict, motivo)` del sistema M60; la UI
  escucha y pinta; sin polling.

## Contratos de animacion y SFX del talado (S30 2026-10-22)

**Animacion de swing del Hacha (L21, input M48):** clip `hacha_swing`
(AnimationPlayer del herramienta-node, contrato M48): duracion 0.35 s a
30 fps (11 frames), evento de señal de impacto en el frame 8 (~0.27 s del
corte, ventana de hit), raiz del personaje NO se mueve (solo brazos/herramienta);
transicion de retorno via reset del nodo (sin blend_segundo). Coyote: un solo
swing por click (no loop); can-busy durante la animacion (no talable otra vez
hasta frame 10).

**SFX de impacto + VFX de virutas (L22, inputs M43/M52):**
- SFX `impacto_madera` (M43): un disparo por swing con hit acertado; volumen
  -6 dB por debajo del ambiente (mezcla equilibrada M44); variante tonal por
  arbol (2 pitches pregrabados, sin pitch-shifter runtime).
- VFX `virutas_madera` (M52): 6-8 particulas cuadritas color madera clara
  (emitter por hit point, contrato M52), vida media 0.4 s, gravedad
  del proyecto; un burst por impacto; pool de 3 emitters reciclabes (sin
  instanciar en runtime).
- Contrato comun: senal `sen_impacto(pos)` del nodo herramienta; M43 (sfx)
  y M52 (vfx) escuchan por senal, sin conexiones duras.

## Audio del slice: musica y SFX (S31 2026-10-22)

**Musica (L58, inputs M41/M44/M84):**
- 2 stems de Aurora: TEMA DIURNO (mayor, Do, 80 bpm, flauta de madera +
  arpa; bucle 64 compases) y TEMA NOCTURNO (menor, La, mismo tempo y
  armonicos, pads suaves; bucle 64 compases comparte el pulso para
  crossfade sin boton de tempo).
- Player PROPIO de musica: AudioStreamPlayer dedicado (no el bus de SFX),
  crossfade 1.0 s entre stems en la transicion al dormir (L59: el mismo
  crossfade definido en el bloque del dormir; sin detener el stream, solo
  ganancias).
- MEZCLA: musica -10 dB vs SFX base (L61, M44: el SFX manda; el impacto de
  talado ya definido a -6 dB sobre ambiente queda 4 dB encima de la musica).
  Ninguna pista> -3 dB pico.
- LICENCIA (L62, chequeo M84): todo stem del slice CC0 o propio (sin
  sampling de bibliotecas con copyright); registro de fuente por stem en el
  04-Codigo al importarlos. Sin musica con claims.

**SFX restantes del slice (L66/L67/L68, M43; L69 ambiente M42):**
- L66 extraccion/colocacion: `extraccion_recurso` (talado/mineria, pitch por
  material: madera/mineral) y `colocacion_bloque` (construir M17, mismo
 bus sen_impacto).
- L67 swing/moneda: `swing_herramienta` (whoosh corto 0.15 s, la senal del
  frame 8 del hacha_swing si NO hubo hit) y `moneda_ao` (pickup AO, blip
  doble 12 ms).
- L68 puerta/puzzle: `reja_abre` (madera+piedra, 0.8 s) y `palanca_click`
  (mecanico corto; el exito usa `puzzle_resuelto_chime` 3 notas del sello).
- L69 AMBIENTE (M42): capa continua por zona: viento (todo el slice),
  mar (playa/muelle, volumen bajo por distancia al agua) y pajaros
  (prado/arboleda, solo de dia; callen -out con el tema nocturno). Un
  AudioStreamPlayer por capa con volumen por posicion (sin 3D emitters por
  arbol: budget).

## UI del slice + serializacion + convenciones (S32 2026-10-22)

**HUD slice (L74, input M53):** inventario visible = 1 fila de hotbar (6
slots: hacha, madera, semilla, AO y 2 libres) en la franja inferior; un solo
icono por recurso con contador; el slot activo de herramienta se marca con
el borde del color sello brisa. Sin sub-inventarios ni drag&drop (scope).

**Caja de dialogo (L75, input M88):** caja inferior centrada al 78% del
ancho, fondo semi-opaco oscuro, tipografia canonica del proyecto; texto con
el typewriter M21 ya resuelto (velocidad configurable en ajustes); nombre
del hablante en cabina pequena arriba-izquierda de la caja. Replay con click
(sin saltar lineas de mision).

**Indicador de interactivo (L76):** etiqueta flotante screen-space
"Interactuar [E]" sobre el objetivo activo del raycast M70 (enchufado al
fade 0.10 s ya definido: la etiqueta hereda el mismo fade, sin polling
propio). Un solo indicador por vez (el objetivo mas cercano).

**Menu de pausa (L77):** capa pausa ya montada por M53: CONTINUAR / SALIR /
AJUSTES MINIMOS (volumen musica y SFX -2 sliders con los buses ya definidos
en S31- L70-; calidad grafica alta/baja) + version del slice. Pausa real
(get_tree().paused, los NPC quedan congelados por el puente M21->M64 ya
resuelto). Salir = volver al menu principal (sin confirmacion doble).

**Serializacion del slice (L109/L110, base save v2 S28):**
- Puzzle: el par `estado_discos` (2 ints de posicion) + `puzzle_resuelto`
  (bool) ya viven en las claves del slice del save v2; al cargar, si
  puzzle_resuelto la reja arranca abierta y los discos en la solucion canonica
  (SOL=ocaso, BRISA=alba) (idempotente).
- schema_version: el save v2 lleva VERSION 2 explicita; al cargar: version
  < 2 -> migracion v1 (mapa M60); version > 2 -> RECHAZO con aviso legible
  (sin crash); version == 2 -> carga directa. La migracion futura (v3) agrega
  claves nuevas sin renombrar las viejas (solo additivo).
- La validacion de schema vive en el loader M60 (un unico punto), no en cada
  sistema del slice.

**Convenciones de nombres del slice (L171):** scripts del slice prefijo
`vslice_` (vslice_mision.gd, vslice_puzzle.gd...), QAs `qa_vslice_*`,
escenas `vslice_*.tscn`, datos bajo data/vslice/; el sufijo `*_vs.gd` queda
RESERVADO para variantes de prueba del slice (no production). Nada del slice
sin prefijo: el barrido de alcance del M139 lo exigira.

## VFX y animaciones del slice (S33 2026-10-22)

**VFX (inputs M52/M47; todos via pool, sin instanciar en runtime):**
- L82 extraccion (fragmentos): 8-10 fragmentos del material golpeado
  (astillas de madera claras / esquirlas de piedra grises), vida 0.5 s,
  gravedad del proyecto; un burst por hit de talado/mineria al lado del
  punto de impacto.
- L83 colocacion (polvo): nube chica de 6 particulas beige 0.3 s al caer el
  bloque (construccion M17); sin flash de camara ni shake.
- L84 recompensa (chispas nobles): 12 chispas doradas 0.8 s con gravedad
  invertida (suben 0.3 s y caen); dispara al entregar la mision y al tomar
  el Hacha de Finneas (2 usos por slice).
- L85 dormir (humo suave): 5-6 particulas de humo blanco 1.2 s que suben
  durante el fade a negro (credito visual del salto de dia, sin gameplay).

**Animaciones (input M48; transiciones con blend, nunca frame seco):**
- L91 caminar del jugador: clip `jugador_walk` ciclo 0.8 s (4 poses); blend
  walk <-> idle 0.15 s; velocidad de animacion acoplada a la velocidad real
  del personaje (sin patinaje).
- L92 USO del hacha (ciclo de tala, distinto del swing base S30): 3 golpes
  encadenados reusando `hacha_swing` como sub-clip; el arbol cae en el
  evento de frame 8 del TERCER golpe (OJO honesto: la senal de
  caida NO existe vigente en scripts/farm a fecha de hoy - queda como
  contrato pendiente de M33, el slice no la inventa).
- L93 Finneas idle/hablar: `finneas_idle` (respiracion, loop 4 s) y
  `finneas_hablar` (gesto de brazo loop 1.5 s que arranca con start_dialogue
  y para con stop — el puente M21->M64 ya da el gancho exacto).
- L94 puertas: puerta de la casa rotacion 90 grados en bisagra, 0.6 s
  (interact abre/cierra); reja de la ruina sube vertical 1.0 s al resolver
  (puzzle_sala_resuelta), sin reversible (queda abierta para el conteo).
- L95 blend sin snap (M48): TODA transicion del slice usa blend 0.2 s
  (caminar/idle/hablar/puertas); prohibido pose cruda (chirrido visual);
  el contrato del pose_foto_en (M56) ya usa el mismo blend.

## Guiado visual + reglas de alcance del slice (S34 2026-10-22)

**Guiado visual sin texto largo (L99-L102, accesibilidad M58):**
- L99 guiado: flechas discretas screen-space (3 chevrones apilados) del
  jugador hacia el POI objetivo activo de la mision + RESALTADO del POI
  (outline suave 0.4 s de periodo, color sello brisa); SIN texto de
  tutorial (maximo 2 palabras por etiqueta).
- L100 arranque: al spawn, el FARO y Finneas llevan resaltado doble (2 s)
  para anclar "a donde ir primero" (diferenciado: faro = ambiente curioso;
  finneas = outline de mision).
- L101 ocultamiento: el guiado (flechas y outline) SE APAGA al completar la
  primera accion de la mision (paso 1 done) y no vuelve salvo 60 s de
  inactividad (anti-estagnacion; vuelve solo el outline, no las flechas).
- L102 desactivar: toggle "Guiado" en AJUSTES MINIMOS del menu de pausa
  (apaga flechas; el outline de interactivo L76 se conserva por
  accesibilidad).

**Reglas de alcance del slice (L153/L156/L172):**
- L153: nada nuevo entra al slice sin pasar POR ESTE documento (03-Diseno):
  pedidos de ultimo momento van a IDEAS-DESCARTADAS (L152) y el director
  decide.
- L156: el alcance definido aqui es 100% reproducible: cada item del 05
  tiene definicion cerrada en 03/06 (sin "se decide en implementacion").
- L172: deuda tecnica detectada se REGISTRA en el 05 como [?] con motivo
  (nunca se silencia ni se marca [x] falso); este archivo ya lo activo con
  la nota de la senal de caida de M33 (S33).

**Codificacion del slice (L201):** todo valor repetido del slice va a const
o export en su script (por ej. claves del save v2: mision_paso,
hacha_finneas_duracion, estado_discos, puzzle_resuelto — const en el loader;
banda de recompensa [8, 22] — const en BalanceService si se expone). Prohibido
string literal duplicado de flags entre sistemas (usar las const), para que
el grep de verificacion del slice sea exacto.

**Umbral de guardado (L147, input TC7):** cero perdidas es el umbral al
guardar: despues de cada autosave (dormir o hito) el save v2 debe leer
schema_version 2 y las claves del slice PRESENTES y no-nulas; mientras una
sola lectura falle, el guardado se cuenta como PERDIDO en el conteo de
GONOGO-M139 (no hay zona gris).

## Canon y estilo (M147)

- Nombre del slice y su historico consume el canon M147 (glpts); toda
  referencia textual debe resolver contra el diccionario canonico.
- **Simbolo canonico del slice: `simbolo_del_sello_brisa`** (M147: significado
  "viento_primeros_jardineros", consumido tambien por M24/M148). En el slice se
  usa como grabado repetido en la ruina del atalaya (inscripcion del paso 2) y
  como motivo del altar menor: el mismo icono, dos usos, cero simbolos nuevos.
- **NPC**: Finneas ya existe en el canon M147 (`personajes.finneas`, rol guia,
  capa_conocida 1, consumido por M21/M19): el slice NO crea lore nuevo, solo
 consume lo canonizado (voz practica, no mistica).
- **Dialogo**: el grafo `data/dialogues/finneas_slice.json` implementa las
  lineas de guia del slice (rama de mision con flags M21
  `flag_mision_finneas_aceptada` / `flag_mision_finneas_pasos`); validado con
  validate_all_dialogues.gd (CI-DGT: 8 archivos, 0 problemas, 2026-10-22).

## Presupuesto tecnico de render (L5 - Beams spec, no toca contenido de G-5.3)

### Budget por frame (16.6ms para 60 FPS)
| Sistema | Budget (ms) | Notas |
|---------|-------------|-------|
| Gameplay (input, fisica, logica) | 2.5 | Incluye player, inventario, construccion |
| Voxel (terreno, LOD, culling) | 4.0 | M08/M156 - chunks visibles |
| IA (NPCs, animales, pathfinding) | 2.0 | M20/M40 - max 20 agentes activos |
| Particulas (VFX, polvo, agua) | 1.0 | M52/M156 - emision por terreno |
| Culling (frustum, occlusion) | 0.5 | M113 - LOD por distancia |
| UI (HUD, menus, dialogos) | 1.0 | M53/M10 - canvas |
| Reserva (spikes, GC) | 1.6 | Buffer para picos |
| **Total** | **12.6** | **Margen: 4.0 ms** |

### Medicion
- P99 (percentil 99) ademas de FPS medio.
- Muestreo con VSYNC off para medir frame time real.
- Profiler: Godot Performance monitor + custom (M116).
### Mediciones de render (P-100 L5 batch)

### VFX dentro del budget particulas (M61: 1.0ms)
- Maximo de particulas simultaneas: 500 (polvo + agua + virutas).
- Emision por terreno: frecuencia * intensidad del data/terrenos/terrenos.json.
- LOD de particulas por distancia: < 20m full, 20-50m half, > 50m off.

### P99 y muestreo
- P99: percentil 99 del frame time (no solo media).
- Muestreo con VSYNC off para medir frame time real.
- Umbral: FPS >= 60 (media), P99 <= 40 ms (max frame).

### GONOGO
- 7 criterios: completo, identificacion, FPS, P99, sin crash, sin softlock, playtest OK.
### GONOGO con 7 criterios (P-100 M138 batch 2)

### Criterios GONOGO
- 7 criterios: completo, identificacion, FPS>=60, P99<=40ms, sin crash, sin softlock, playtest OK.
- Todos deben cumplirse para GO.

### docs/vslice/
- Carpeta docs/vslice/ con PLAYTEST, REPORTE-FPS, GONOGO-M138.
- Documentacion del vertical slice.