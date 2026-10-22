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

1. Conversacion con Finneas:	dialogo con 6+ lineas y rama de mision (M21).
2. Recolectar madera:	derribar arboles (5 bloques por arbol con la Hacha
   de 15 usos).
3. Entrega: llevar la madera a la ruina del slice -> recompensa.

## Recompensa (input M93 margen 5-15%)

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