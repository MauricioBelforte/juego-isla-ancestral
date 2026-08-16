# 03 — Diseño — M65: Animales IA

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Arquitectura

```
NPCManager (M64)                     ← orquestador único de IA
└── FaunaManager                         ← capa fauna (M65)
    ├── FaunaProfile (ScriptableObject)  ← perfil por especie (datos)
    ├── FaunaBrain (FSM datos-driven)    ← estados del comportamiento
    ├── FaunaBody (pool, anclado)        ← presentación + estado
    ├── PackLogic / SchoolLogic          ← manada / banco (sincronización leve)
    └── FaunaSpawner                       ← spawns por bioma, despawns, rehidratación
        └── PoblacionPresupuesto           ← límite global, por bioma, por manada
```

## Estados FSM (perfil): `Dormir → Pastorear/BuscarAgua → Comer → Explorar → Curiosear → Huir → Migrar → Reproducir → Anclado`

- **Dormir** (nocturnos de día, diurnos de noche): en madriguera/refugio; mínimo 30 s reales; ruido o agua lo despierta.
- **Pastorear** (herbívoros): sigue zonas de vegetación válidas del slot; FOV 120° interior.
- **BuscarAgua/Hidratarse:** prioridad periódica (real 5 min); cría en lagos/ríos navegables.
- **Comer:** fuente comestible por especie; hambre sube lentamente (10 min reales sin comer → emigra).
- **Explorar:** wander de bajo costo con anti-atasco (reuso watchdog M64).
- **Curiosear:** si el jugador está **quieto o agachado** (M57) dentro del radio tímido → acercarse hasta 2 m, observar 5 s, retirarse.
- **Huir:** si el jugador se mueve rápido o invade el radio de huida → huida radial; al salir de rango → vuelve a Curiosear/Explorar.
- **Migrar:** rutas por etapas entre biomas; solo en ventana migratoria (estación + hora).
- **Reproducir:** pareja si hay espacio, nido oculto, cría que crece en 3 etapas (días de juego vía M29).
- **Anclado:** fuera de la burbuja 64 m → se recicla el GameObject; queda registro ligero; al volver, rehidratación con agenda (hambre, energía, etapa, posición).

## Aéreo y acuático

- **Aves:** waypoints aéreos + perchas en árboles; térmicas que dan ascenso; jamás rozan la isla (raycast de separación vertical).
- **Acuático:** nado 3D con buceo (banco = unidad de flujo con delta ≤ 1.2 m); cangrejos costeros 2D con marea baja; peces no salen del volumen del lago/río.

## Spawns / despawns

- **Spawn:** pesos por bioma (bosque: ciervo 0.45, pájaro 0.35…), sorteo por slot con `seed = seedPartida + biomaId + slotId`; densidad máxima por bioma; validación: el slot es navegable y está sobre suelo/agua correctos.
- **Despawn:** fuera de la burbuja o en emigración → anclado; no quedan colliders huérfanos; ningún objeto se destruye a mitad de cuadro.
- **Población excesiva:** presupuesto total (M61): si sobrepasa, el spawner reintenta al próximo tick; el excedente por bioma nunca supera el 110% del tope (lo normal es ≤ 100%).

## Rendimiento (presupuestos)

- **FSM fauna ≤ 4 ms** de los 8 ms de IA (M61); pathfinding compartido ≤ 6 ms total (NPC+fauna).
- **Lejanos:** receta tick 1 s (mismo patrón M64); **instancing animado** para grupos (aves, bancos) → 1 draw call por especie en grupos ≥ 8.
- **Pooling:** reusar `FaunaBody` del pool de M64; cero allocations en Update.
- **Watchdog anti-atasco:** si un animal queda atascado > 2 s → re-path; > 6 s → teleport discreto del slot.
- **Terreno modificado (M08/M28):** al cambiar el terreno, se revalidan los slots ocupados del chunk; si queda inválido → migración temprana con despawn anclado (nunca visible atrapado).

## Sonidos contextuales (M42/M43)

| Evento | Timestamp | Radio audición |
|---|---|---|
| Alarma de manada | al huir | 40 m |
| Canto de aves | amanecer/atardecer (M31) | 30 m |
| Buceo / salpicadura | al entrar al agua | 20 m |
| Roce en pastos | pastoreo | 10 m |
| Curiosidad (oliendo) | observación | 8 m |

Los sonidos respetan `BusPriority` y never spam (cooldown mínimo por especie, ver M43).

## Integración

- **M36 Museos:** el registro de fauna pasa solo por observación (avistamiento), que alimenta la colección; jamás por caza.
- **M29/M31/M32:** horarios (día/noche) y estaciones definen ventanas de actividad, migración y reproducción.
- **M57:** "quieto/agachado" reusado por la curiosidad.
- **M63:** la burbuja y los cuerpos reciclados respetan el sistema de carga por región (océano/isle).

## QA / Testings

- 06-Plan-Testings.md: unitarias (FSM por estado, spawner, presupuesto), integración (terreno modificado, cambio de estación, spawn en biomas), edge cases (slot en agua para terrestre, población al tope, despawn a media corrida), perf (frame budget con 40 NPC + 60 animales).
- 07-Resultados se actualiza tras ejecutar la suite.