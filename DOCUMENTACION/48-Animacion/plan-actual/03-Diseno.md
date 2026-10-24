**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 48: Animación

## 1. Arquitectura

```
Assets/_Project/Animation/
├── libraries/                  (AnimationLibrary por actor/familia)
│   ├── jugador_lib.tres        (clips de la FSM de M11)
│   ├── n ncp_humanoide_lib.tres
│   ├── fauna_cuadrupedo_lib.tres
│   ├── fauna_ave_lib.tres · fauna_pez_lib.tres
│   └── props_*_lib.tres        (puertas, ascensores, barcos, mecanismos)
├── controllers/                (FSM de animación por actor)
│   ├── jugador_animation_fsm.gd
│   ├── npc_animation_fsm.gd
│   └── fauna_animation_fsm.gd
├── procedural/                 (animación procedural de mundo)
│   ├── viento_vegetacion.gd
│   ├── ondas_agua.gd
│   └── fuego_particulas.gd
├── ui/                         (animaciones UI 60 fps)
│   ├── transiciones_lib.tres
│   └── recompensas_lib.tres
└── budget/                     (animation_budget.json)

Assets/_Project/Editor/
├── validate_animation.gd
└── import_animation_defaults.gd   (plantilla de import FBX)

Assets/_Project/Services/       (autoload)
└── animation_service.gd        (API play(actor, estado, blend_time))
```

El jugador (M11), los NPC (M19/M64) y la fauna (M36/M65) llaman a `AnimationService.play(...)` con su estado de comportamiento; el servicio resuelve en qué library/clip, con qué blend y qué LOD (burbuja M64). Los eventos (sonido M43, feedback M44, partículas M52) se disparan desde las timelines de los clips. La UI (M53) usa AnimationPlayer propio con duraciones y Reduce Motion (M58).

## 2. Diagramas de Flujo (texto)

### 2.1 De estado de comportamiento a animación

```
FSM de comportamiento (M11/M64/M65) emite evento "estado cambiado"
  → AnimationService.play(actor, estado, blend_time)
    → 1) resolver familia del actor (humanoide/cuadrúpedo/ave/pez/prop)
    → 2) elegir library y nombre de clip por catálogo (estado → clip)
    → 3) LOD: ¿actor en burbuja? sí → blend normal (250 ms)
               no → idle simplificado / sin update de huesos
    → 4) precargar clip si es la primera vez (pool de AnimationPlayer)
    → 5) reproducir con blend por crossfade; evento "animation_started (actor, estado)"
  → timing de eventos (audio/feedback/partículas) sale de la timeline del clip
```

### 2.2 Producción de una animación de jugador

```
estado FSM (ej: "minar") → ficha en catálogo (anim_minar_swing_1.3s)
  → rig de M45 (humanoide voxel, sockets en manos)
  → blocking: 3 poses (windup → impacto → recovery)
  → polish: anticipación 120ms, impacto 60ms, follow-through
  → eventos: sonido impacto al frame 18, partículas al frame 20
  → export FBX 30 fps, T-pose única, bones subset del rig
  → import con plantilla (import_animation_defaults.gd) → library del jugador
  → validate_animation.gd (naming, frames, eventos, coste)
  → registro en animation_budget.json
```

### 2.3 Validación al importar (validate_animation.gd)

```
al importar clip (M108):
  → naming: anim_[actor]_[estado] (ej: anim_jugador_minar)
  → frames: 30 fps base (UI 60), duración dentro de máximos por categoría
  → rig: T-pose única, bones subset válido para la familia
  → eventos: keyframes de sonido/feedback/partículas sin desplazamiento físico
  → keyframes: sin redundancias (bicubic optimizada)
  → coste: huesos × duración vs presupuesto M61; actor en burbuja
  → emitir lista acumulada de errores
```

## 3. Tablas de Métricas (técnico)

### 3.1 FPS, duraciones y blend por categoría

| Categoría | FPS | Duración típica | Blend default | Notas |
|---|---|---|---|---|
| Locomoción (jugador/NPC) | 30 | 0.8-1.6 s | 250 ms | Blend space 2D direccion×vel |
| Acciones (herramientas, pesca, mina) | 30 | 1.0-2.5 s | 200 ms | Evento de impacto al frame 55-65% |
| Fauna (idle, huir, volar) | 30 | 1.0-3.0 s | 300 ms | Variantes de fase en manadas |
| Mecánicas (puertas, ascensores, barcos) | 30 | 1.5-4.0 s | — | Loops marca final con señal `animation_finished` |
| UI (transiciones, recompensas) | 60 | 150-600 ms | Tween | Reduce Motion M58 |
| Mundo procedural (viento/agua/fuego) | GPU | ∞ | — | Determinista por TIME con fase fija |

### 3.2 Presupuesto de animación (registro contra M61)

- Burbuja de animación plena: ≤ 60 actores (M64), cada uno ≤ 40 huesos activos.
- Fuera de burbuja: idle simplificado (2-4 huesos) o sin animación por distancia > LOD_anim.
- Blend trees: ≤ 4 nodos por actor (espacios 2D de locomoción contados como 1).
- Todos los AnimationPlayer en pooling (props reutilizables no crean players por instancia).
- Coste sincrónico de UI: solo activa mientras visible (no animar offscreen).

### 3.3 Catálogo de animaciones por dominio (25 del plan maestro)

| Dominio | Clip o aproximación | Origen FSM |
|---|---|---|
| Jugador | idle, caminar, correr, saltar, nadar, extraer, pescar, cosechar, dormir | M11 |
| NPC | idle, caminar, rutinas, conversar, gestos | M19/M64 |
| Animales | idle, pastorear, huir, volar, nadar, dormir | M36/M65 |
| Herramientas | swing, minar, plantar, regar, pescar, martillar, lupa | M13 |
| Vegetación | procedural viento (shader/script) | M50 |
| Agua | procedural ondas (shader) | M51 |
| Fuego | procedural partículas (M52) | M52 |
| Partículas | N/A (las partículas SE trigger desde clips) | M52 |
| Puertas | abrir/cerrar (rotación con easing) | M17/M24 |
| Puentes | bajar/subir | M24/M66 |
| Mecanismos | activar/desactivar | M24/M26 |
| Ascensores | subir/bajar con easing | M26 |
| Barcos | balanceo en agua, atraque | M28/M67 |
| Dirigibles | ascender/descender, balanceo | M67 |
| Submarinos | sumergir/emergir | M67 |
| UI | transiciones de menú | M53 |
| Diálogos | retratos, burbujas, gestos de conversación | M21/M46 |
| Recompensas | popup, contador, sparkle | M71/M72 |
| Descubrimientos | nuevo desbloqueo, tooltip | M71 |
| Festivales | bailes, decoraciones pixel-ID | M74 |
| Construcciones | colocar/levantar piezas | M17 |
| Cosecha | arrancar/recoger | M33 |
| Pesca | lanzar, espera, tensión, cobro | M34 |
| Minería | golpe, recogida | M35 |
| Puzzles | mover piezas, activación | M24 |

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M11/M19/M36 | FSM de comportamiento → estados → AnimationService |
| M45 | Rigs, sockets de herramientas, T-poses por familia |
| M13 | Sockets de herramientas (grip), swings por nivel |
| M64/M65 | Burbuja de animación (≤60 plenos), LOD de animación |
| M43/M44 | Eventos de sonido y feedback en timelines |
| M52 | Triggers de partículas desde timelines |
| M50/M51 | Procedural de viento/ondas deterministas |
| M21/M53/M58 | UI animada, diálogos, Reduce Motion |
| M61/M62 | Presupuesto de animación, pooling, registro |
| M74 | Animaciones de festivales y eventos |
| M108/M118 | Importación con plantilla + validación en CI |

## 5. Convenciones de produccion y contratos (S47 — G-5.3-Flash-Agente, 2026-10-23)

**Pipeline de produccion (L26):** rig (M45, huesos subset por familia) →
blocking (poses clave, cuadros 1/25/50/75/100%) → polish (curvas, easing,
solape de extremidades) → export 30 fps (cada pose un frame; NINGUN clip
con keyframes a 60 fps: el proyecto exporta a 30 y el engine interpola).
El bloque aprobado se revisa EN VISTA de juego (no en Blender) antes de
polish — M154/V5.

**Formato de export (L28):** FBX por actor, T-pose UNICA como bind pose
(sin A-pose ni variantes), bones subset por familia (humanoide ~40 huesos,
cuadrupedo ~28, ave ~22, pez ~14; sin huesos faciales en el slice: la voz
es texto, no lip-sync). Escala metrica 1 unidad = 1 m; forward = -Z
(convencion Godot).

**Familias de rigs (L30):** 4 familias canonicas — HUMANOIDE (jugador, NPCs
aldea, Finneas), CUADRUPEDO (ciervo, jabali, zorro), AVE (gaviota, pajaro
del prado), PEZ (fauna submarina). Cada familia tiene UN rig base y las
variantes por especie reutilizan el mapping de huesos (nombres identicos);
NO se crean rigs nuevos por animal.

**Maximos de duracion (L34):** hereda la tabla 3.1 como TOPES (no tips):
locomocion 1.6 s, acciones 2.5 s, fauna 3.0 s, mecanicas 4.0 s, UI 0.6 s.
Un clip que excede el tope de su categoria exige justificacion en el 03
(ie. cinematica) o se divide.

**Nombres y librerias (L181):** clip = `anim_<actor>_<accion>_<variante>`
(anim_finneas_idle_a1, anim_jugador_talar_g3); librerias POR ACTOR (una
AnimationLibrary por actor/sfamilia, no un mega-lib); prefijo `anim_`
obligatorio en todos los clips (el validador lo checara al importar).

**Senales del validador (L199, contrato para validate_animation.gd):**
cuando exista el tool de importacion, identificara 3 condiciones y EMITIRA
senales por cada una: `animation_started` (clip valido montado en el
actor), `animation_finished` (el loop termino o el one-shot completo) y
`animation_missing` (un actor referencia un clip que no esta en su
libreria — error de integracion visible en consola). MIENTRAS el tool no
existe, este item queda como CONTRATO (el flip es de definicion, no de
implementacion).

## 6. Kit de animacion: import, variantes, LOD y presupuesto (S49 — G-5.3-Flash-Agente, 2026-10-23)

**Objetivo del kit (L9):** UN kit central de animación con producción
coherente: las 4 familias (sec 5) comparten FSM espejo del M11 (estados
iguales, clips distintos por actor), presupuesto verificado por la tabla
3.2 y contratos de import de esta seccion. Todo actor animable debe poder
montarse SIN codigo nuevo de animacion: solo folder de clips + mapping de
huesos + FSM espejo.

**Criterios de aceptacion (L19, 8 criterios):** (1) todo clip cumple el
prefijo/categories de sec 5; (2) T-pose unica en el FBX; (3) duracion bajo
tope de tabla 3.1; (4) blend a FSM espejo <= 300 ms; (5) NINGUN estado de la
FSM M11 queda sin clip (el fallback idle WARN del L198 cubre lo temporal);
(6) presupuesto M61 respetado al suma N actores por escena; (7) LOD de fauna
activo por distancia (sec 6 abajo); (8) senales started/finished/missing
operativas (L199). Un kit que falla cualquier criterio vuelve a blocking.

**Plantilla de import (L32):** `import_animation_defaults.gd` (tool, cuando
exista): aplica por DROP de FBX — fps 30, loop on/off por sufijo del clip
(`_loop`), compresion activada como el resto del proyecto, remapeo de huesos por familia (tabla
sec 5) y emision de las senales L199. Mientras el tool no exista: defaults
manuales documentados aqui y checados por el checklist L173 (T-pose/bones
subset).

**Blend space 2D de locomocion (L48):** eje X = velocidad (idle 0 ->
walk 0.5 -> run 1.0), eje Y = direccion relativa (frente/derecha/atras/
izquierda, 4 muestreos); blend suave 250 ms (tabla 3.1); el FSM espejo M11
alimenta ambos ejes; un SOLO blend space por familia (compartido por
especies del mismo rig).

**Variantes por personalidad (L63):** maximo 3 variantes por gesto canonico
(a1/a2/a3) — el sistema elige aleatorio con peso (80/15/5) para no
repetir la misma variante; las variantes comparten los MISMO huesos y
duracion +-10% (para no romper el FSM espejo ni el presupuesto).

**LOD de fauna (L72):** por distancia al camara: <= 25 m el clip completo;
25-50 m una variante simplificada (idle + locomocion solamente, SIN gestos);
> 50 m pose congelada con billboard/flip de sprite (sin AnimationPlayer
corriendo). Cada actor elige su LOD por distancia PROPIA (no por manada: los
miembros lejanos apagan su AnimationPlayer de forma independiente).

**Presupuesto por escena (L189, M61):** la suma de actores animando por
escena <= 60 (burbuja M61 ya valida); el registro 3.2 del 03 lleva los
presupuestos POR escena del slice (playa/prado/ruina) — cualquier actor
nuevo que exceda la suma pide revision del 03 antes de montar.

**Alerta de excedente en editor (L191):** cuando exista el tool del
validador (L199), al exceder el presupuesto 3.2 EMITIRA un warning en el
editor con la lista de actores que pisa el tope (sin bloquear; el de
revision L154 decide). Mientras tanto, el conteo es manual en el 3.2.

## 6-bis. Integraciones del kit de animacion (S58 — G-5.3-Flash-Agente, 2026-10-23; contratos ya vigentes citados)

**Restricciones base (L9):** Godot 4.x; FPS 30 base para clips (UI 60);
deterministico por pose (sin timing dependiente del frame-rate); TODA señal
de fimite via AnimationPlayer nativo (started/finished) + animation_missing
del validador futuro (L198/L199).

**Sockets de herramientas (L50, M45):** el grip del personaje es un BoneAttachment3D
en el hueso de la mano dominante (humanoide) o boca/cola (cuadrupedo/ave/pez);
la herramienta (M13) se acopla por socket y NO por padre-escena (evita
duplicar el arbol de animacion). El swing L92 sale del mismo socket.

**Naming (S47):** anim_<actor>_<accion>_<variante> con librerias POR ACTOR;
el FSM espejo M11 resuelve el nombre por estado (mismos estados, clips por
actor).

**Integracion con M64/M65 (burbuja de actores, S49 L189/L191):** el LOD de
fauna (<=25/25-50/>50 m) pide/pagar el AnimationPlayer por actor; la alerta
de excedente del editor cuenta actores con player activo.

**Integracion con M45 (rigs/sockets):** T-pose unica + bones subset por
familia (sec 5); los sockets del L50 viven en el rig del M45 (sin rig
especial del slice).

**Integracion con M13 (herramientas):** el swing del hacha de S30: el ciclo de tala (3 golpes) se lanzan desde el Socket; el evento de impacto del frame
8/3er golpe emite a la madera (M33/M35).

**Integracion con M43/M44/M52 (eventos):** los keyframes de evento (impacto,
paso, salto) emiten senal -> M43 sfx, M44 voces, M52 particulas (pool 3
emitters S30). Sin llamar desde la animacion directa (senales desacopladas).

**Integracion con M50/M51 (procedural):** viento/agua del mundo procedural
Son GPU-shader y NO consumen AnimationPlayer: la coherencia visual es por
paleta/estilo, no por clips.

**Integracion con M21/M53/M58 (UI):** subtitulos (M58) acompanan la voz
(M44); el Reduce Motion M58 apaga shake/flashes en TODOS los clips (perfil
global activo); la UI dialogo no pide clips nuevos (solo estados del FSM
espejo).

**Integracion con M61/M62 (presupuesto):** <= 60 actores animando por escena
(burbuja; L189); alerta del editor al exceder (L191); el registro 3.2 lleva
la suma por escena.

**Integracion con M74 (festivales):** los festivales (M74) pueden pedir
poses/loops especiales: se agregan como variantes del gesto canonico (a1/a2/
a3 de L63), NO como clips de production nuevos (sin exceder presupuesto).

## 6-bis. Integraciones del kit de animacion (S58 — G-5.3-Flash-Agente, 2026-10-23; contratos ya vigentes citados)

**Restricciones base (L9):** Godot 4.x; FPS 30 base para clips (UI 60);
deterministico por pose (sin timing dependiente del frame-rate); TODA señal
de fimite via AnimationPlayer nativo (started/finished) + animation_missing
del validador futuro (L198/L199).

**Sockets de herramientas (L50, M45):** el grip del personaje es un BoneAttachment3D
en el hueso de la mano dominante (humanoide) o boca/cola (cuadrupedo/ave/pez);
la herramienta (M13) se acopla por socket y NO por padre-escena (evita
duplicar el arbol de animacion). El swing L92 sale del mismo socket.

**Naming (S47):** anim_<actor>_<accion>_<variante> con librerias POR ACTOR;
el FSM espejo M11 resuelve el nombre por estado (mismos estados, clips por
actor).

**Integracion con M64/M65 (burbuja de actores, S49 L189/L191):** el LOD de
fauna (<=25/25-50/>50 m) pide/pagar el AnimationPlayer por actor; la alerta
de excedente del editor cuenta actores con player activo.

**Integracion con M45 (rigs/sockets):** T-pose unica + bones subset por
familia (sec 5); los sockets del L50 viven en el rig del M45 (sin rig
especial del slice).

**Integracion con M13 (herramientas):** el ciclo de tala de S30 (3 golpes) se lanzan desde el Socket; el evento de impacto del frame
8/3er golpe emite a la madera (M33/M35).

**Integracion con M43/M44/M52 (eventos):** los keyframes de evento (impacto,
paso, salto) emiten senal -> M43 sfx, M44 voces, M52 particulas (pool 3
emitters S30). Sin llamar desde la animacion directa (senales desacopladas).

**Integracion con M50/M51 (procedural):** viento/agua del mundo procedural
Son GPU-shader y NO consumen AnimationPlayer: la coherencia visual es por
paleta/estilo, no por clips.

**Integracion con M21/M53/M58 (UI):** subtitulos (M58) acompanan la voz
(M44); el Reduce Motion M58 apaga shake/flashes en TODOS los clips (perfil
global activo); la UI dialogo no pide clips nuevos (solo estados del FSM
espejo).

**Integracion con M61/M62 (presupuesto):** <= 60 actores animando por escena
(burbuja; L189); alerta del editor al exceder (L191); el registro 3.2 lleva
la suma por escena.

**Integracion con M74 (festivales):** los festivales (M74) pueden pedir
poses/loops especiales: se agregan como variantes del gesto canonico (a1/a2/
a3 de L63), NO como clips de production nuevos (sin exceder presupuesto).

## Presupuestos de animacion (Beam 380, produce-first)
### animation_budget.json por actor/animacion
- Spec: archivo nimation_budget.json con presupuesto por actor/animacion.
- Formula: presupuesto_actor = huesos × duracion × complejidad_factor. Presupuesto escena = suma de actores <= 60 (M61).
- Valores: max 60 actores animando por escena (M61), huesos por actor <= 50, duracion max 10s.
- Coherente con M61 (rendimiento) y M62 (memoria). Sin exceder presupuesto M61.
