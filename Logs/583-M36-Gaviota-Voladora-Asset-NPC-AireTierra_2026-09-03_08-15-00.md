# Log 583: Gaviota Voladora M36 — Asset Iterativo (11 Rondas) + NPC Aire⇄Tierra

**Fecha:** 2026-09-03
**Hora:** 08:15
**Modelo:** GLM 5.3 (z-ai)
**Plataforma:** Kilo Code

## Resumen

El "gran reto" del usuario: "un ave que deberá poder volar". Cuarto animal
del pipeline (07 §11) y PRIMER ASSET VOLADOR del proyecto — el más iterado
de la historia (11 rondas de feedback directo), aprobado y volando en
Godot con FSM completa aire⇄tierra: vuela, aterriza, camina con las alas
PLEGADAS y despega de nuevo.

## Las 11 rondas (lecciones inline en el script)

1. v1: caja() no acepta `rot` (es `rot_euler`).
2. v2: "cabeza no encaja, está más arriba" → cuello gradual + cabeza -1 cm.
3. v3: "mirando fotos: achica torso, agranda cabeza, más cuello" →
   cuerpo compacto + cuello diagonal elevándose + cabeza r 0.065.
4. v4: "un poco menos de cuello" → tramo único de cuello.
5. v5: "fusiona el cuello con la cabeza en una sola cosa" → SOLUCION
   ESTRUCTURAL: cabeza esférica ELIMINADA, el loft del cuerpo se extiende
   cola→pecho→cuello→CRANEO→frente (una sola isla geométrica).
6. v6: "pico mal posicionado, ojos muy afuera" → pico enterrado 1.5 cm en
   el eje de la frente; ojos por FÓRMULA PARAMÉTRICA de la elipse (t=50°).
7. v7: "de frente: pico abajo-izquierda, punta negra izquierda mal, cola
   en el aire" → 3 bugs: Euler X-antes-de-Y inclinaba el pico al costado
   (fix to_track_quat); rot Z 180 del ala izquierda invertía la cuerda
   (fix: espejo en el propio loft); cola con gap de 2 cm (solape interno).
8. v8: "alas separadas del torso + de punta a punta negro/gris oscuro" →
   hombros hundidos 3 cm en el flanco; barras de borde de fuga (mal).
9. v9: "no era barra, pintá la parte de arriba del torso" → MANTO gris
   oscuro por multi-material en caras superiores del cuerpo (v8 barras
   quitadas).
10. v10: "faltó pintar la parte de arriba de las alas" → mismo
    multi-material en las alas (normal.z > 0.3).
11. v11: "la colita pintala negra" → cola MAT_negro.

## Cambios Realizados

- Asset v11: 11 SM_ / 620 tris / 7 mats (multi-material cuenta slots).
  **Primer asset que OMITE el asentado a propósito**: es un ave en pose de
  vuelo; el z del set (0.35) es su ALTURA visual, Godot no la apoya.
- Variantes MEDIA (5 obj/620) y BAJA (5 obj/288, ojos podados) + 3 GLB
  (49/39/23 KB) + 3 `.import` + 3 `.scn` (E-65).
- `gaviota_npc.gd` (300 líneas): FSM **VUELO** (órbita r 30 con banking
  -0.35 rad, ondulación seno, planeo 2.2 Hz) → **ATERRIZANDO** (descenso
  espiral hacia punto proyectado, frenando, 8 Hz) → **CAMINANDO con alas
  PLEGADAS** (rot Z ±1.40 rad hacia atrás, E-74 negado; trote 0.8 m/s con
  bobbing) → **PAUSA_SUELO** → **DESPEGANDO** (ascenso espiral 9 Hz) →
  VUELO. Puntas negras re-parentadas a sus alas en runtime (offset
  preservado por affine_inverse). Snap al suelo solo en estados de tierra.
- Nodo `GaviotaNPC` en `main_island.tscn` (256, 256) orbitando el spawn.

## Verificación (V4)

- **v10 FINAL (tras 10 iteraciones de debugging, la más dura del proyecto):**
  el ciclo completo VERIFICADO en runtime con múltiples repeticiones:
  `aterrizaje elegido → voy al punto → sobre el punto → caida vertical →
  ATERRIZADA — caminatas: N → despegando tras la posada larga → en vuelo
  de nuevo` ×5+ ciclos en una sesión. Captura:
  `cap_36_gaviota_ciclo_completo_2026-09-04_01-35.png`.
- **Los 3 bugs de fondo encontrados (lecciones para 07-GUIA-GODOT §11):**
  1. **MOTION_MODE FLOATING en el descenso** (v8): en FLOATING "todas las
     colisiones se reportan como pared" → `is_on_floor()` NUNCA true: el
     propio suelo era reportado como muro. Fix: GROUNDED durante el
     descenso (y la línea se perdió una vez en un refactor — v10c).
  2. **Descenso con avance contra laderas voxel** (v8d/v9): el terreno
     sube más rápido que la caída → empuja contra caras laterales de
     cada escalón → abortos infinitos. Fix v10: patrón de ave real —
     elegir punto ANTES, volar hasta estar ENCIMA, caer VERTICAL PURO.
  3. **Esfera de colisión en terreno escalonado** (v10b): el casquete
     curvo tangentea las ARISTAS de los voxels antes de posarse. Fix:
     CÁPSULA (base plana aterriza sobre la cara superior de una) +
     `floor_max_angle` 0.96 (~55°: las aristas de 45° del voxel cuentan
     como piso transitable, no muro).
  4. Bonus: anti-atasco en tierra por TIEMPO (no por frame: v8 sumaba
     _caminatas 60 veces por segundo pegada a un escalón y despegaba al
     instante); watchdog de quietud por VENTANA (no por frame); HOP de
     ave para subir escalones (v9, se mantiene).
- Boot limpio, sin errores del script, ciclo aire⇄tierra 100% random.
- **v2 (bug usuario: "se mete debajo de la tierra"):** 3 fixes —
  (1) `CollisionShape3D` esfera r 0.30 creada en runtime (el nodo del tscn
  no tenía colisión: `move_and_slide` no veía el terreno); (2) descenso
  SIN empuje extra hacia abajo (el `-UP*2` la enterraba), directo al punto
  con velocidad proporcional; (3) **clamp anti-enterrar** en
  aterrizaje/caminata/despegue contra `_altura_suelo_en() + 0.45`.
  Aterrizaje/despegue ahora RANDOM (8-18 s vuelo, 1-4 caminatas).
  Re-verificado: 30+ s volando estable, sin hundirse.
- **v3 (feedback usuario: "queda flotando al llegar al suelo" + "otra pose
  con alas totalmente cerradas"):** NO hizo falta otro diseño — las alas ya
  son piezas con pivote en el hombro. (1) POSE DE TIERRA: al aterrizar el
  modelo baja `ALTURA_TIERRA = -0.26` para que las PATAS pisen (el GLB trae
  la panza a +0.35 del origen por la pose de vuelo del set de Blender) y
  en despegue se lerpea de vuelta; (2) `PLEGADO_ALA` 1.40 → 1.45 rad
  (~83°, alas COMPLETAMENTE cerradas contra el cuerpo). Re-verificado:
  ciclo completo estable sin hundirse ni flotar.
- **v4 (feedback usuario: "cuando choca con un bloque debe pasar a modo
  terreno"):** ANTI-ATASCO `_chequear_choque()` — si el cuerpo acumula
  colisiones de slide >1.2 s: en VUELO/ATERRIZANDO hace ATERRIZAJE DE
  EMERGENCIA donde está (baja, pliega alas, camina como corresponde);
  en CAMINANDO elige otra dirección o despega directamente (sobrevuela
  el obstáculo). Cubre chozavil, bloques del jugador, vegetación alta.
  Re-verificado 20+ s sin errores.
- **v5 (bug usuario: "baja planeando pero nunca se para ni camina"):**
  causa raíz numérica — el clamp anti-enterrar usaba `terreno + 1.45` y
  el umbral de aterrizaje era `punto + 1.40`: el clamp la sostenía 5 cm
  POR ENCIMA de la línea de aterrizaje, planeando lento eternamente.
  Fix: clamps unificados a la convención del proyecto (`h + 1.0`, la
  misma que pisan tortuga/cangrejo/jabalí), componente vertical
  obligatoria en el descenso y WATCHDOG de 9 s (aterriza si o si).
  Prints de ciclo en log: `iniciando descenso`, `aterrizada — caminatas
  planificadas: N`, `en vuelo de nuevo`. **Verificado: 4 ciclos
  completos en 90 s** con las transiciones en el log de runtime.
- **v6 (bug usuario: "la pose con alas cerradas y parada en 2 patas no
  la hace nunca"):** la FSM aterrizaba PERO el modelo quedaba en pose de
  vuelo horizontal ("acostada", planeando a ras). Fixes:
  (1) POSE PARADA `rotation.x = -0.45` (morro arriba ~26°: cabeza sube
  +33 cm, cola roza el suelo, patas como soporte vertical — silueta de
  gaviota posada); (2) ALTURA_TIERRA -0.26 → -0.16 recalculada para el
  pitch; (3) bobbing de caminata ENCIMA del pitch; (4) despegue lerpea
  pose y pitch de vuelta; (5) anti-atasco en tierra elige DIRECCION en
  vez de descontar caminatas (los roces del terreno la expulsaban al
  vuelo en 2-3 s) — despega solo tras 4 reintentos; (6) posada LARGA
  final de 6-14 s quieta antes de despegar. **Verificado: ciclo
  completo con `aterrizada y posada` en el log.**

## Archivos Modificados/Creados

- `tools/mcp/blender-mcp/36-Fauna/scripts/crear_gaviota_lowpoly.py` (v11)
- `tools/mcp/blender-mcp/36-Fauna/gaviota_lowpoly{,_media,_baja}.blend`
- `tools/mcp/blender-mcp/36-Fauna/capturas/` (66 capturas, 11 hojas)
- `game/isla-ancestral/scripts/fauna/gaviota_npc.gd` (nuevo)
- `game/isla-ancestral/scenes/main_island.tscn` (+GaviotaNPC)
- `game/isla-ancestral/assets/3d/{alta,media,baja}/36-Fauna_gaviota.glb` + `.import`
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` (ítem [x])

## Pendiente / Próximo agente

- Validación visual del usuario en juego (V1): orbita, banking,
  aterrizaje, caminata con alas plegadas, despegue.
- La FSM aire⇄tierra es replicable para futuras aves (pingüino no volador:
  solo estados de tierra).
- Backlog M36 3D restante: pez tropical (2 variantes), lagarto, cabra,
  gallina, mariposa. 5 animales ya en el zoo (tortuga, cangrejo, jabalí x2,
  gaviota).
