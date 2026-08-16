# 02 — Análisis — M65: Animales IA

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Puntos de la sección 64 resueltos

| Punto (Plan) | Resolución |
|---|---|
| Diseñar comportamiento herbívoro | Manada con líder, pastoreo por zonas de vegetación, FOV interior 120°, reposición de alimento |
| Diseñar comportamiento acuático | Nado 3D con buceo, bancos (unidad de flujo), cangrejos costeros en 2D en marea baja |
| Diseñar comportamiento aéreo | Aves con waypoints circulares, perchas, térmicas (evitan obstáculos, nunca rozan la isla) |
| Diseñar comportamiento nocturno | Búhos/murciélagos en rango nocturno de M31 (sol < 3°), día en reposo; luciérnagas decorativas |
| Diseñar comportamiento migratorio | Rutas entre biomas en estación lluviosa/seca, columnata de aves, marcadores de etapa |
| Diseñar comportamiento estacional | Perfil estacional distinto por estación (M32): pelaje/agrupación, fuentes de alimento cambiantes |
| Diseñar reproducción si existe | Ciclo por especie: pareja, nido, cría (crece en 3 etapas), sin loot, sin explotación |
| Diseñar descanso | Estado dormir: refugio o madriguera, mínimo real 30 s, despierta por ruido/agua |
| Diseñar alimentación | Fuente comestible por especie, hambre lenta (real 10 min sin comer), emigra al final |
| Diseñar huida no violenta | Huida radial del jugador (radio por especie), retorna con curiosidad; cero daño, cero agresión |
| Diseñar curiosidad | Acercamiento si el jugador está quieto/agachado (M57), umbral tímido por especie |
| Diseñar interacción con entorno | Hidratación en lagos/ríos, madrigueras, perchas, árboles frutales; reaccionan a zonas alteradas |
| Diseñar sonidos contextuales | M42/M43: timestamps (llamadas de alarma, aves al amanecer/atardecer, buceo) con radio de audición |
| Diseñar spawns | Pesos por bioma con sorteo local, densidades máximas, validación de navegación del slot |
| Diseñar despawns | Fuera de la burbuja → estado anclado (objeto reciclado), sin residuos; retorno rehidratado |
| Optimizar agentes | Instancing animado, pooling del orquestador M64, tick 1 s para lejanos, 0 cierres síncronos |
| Evitar población excesiva | Presupuesto total de activos M61 + tope por bioma + tope de manada + reintegro probabilístico |
| Probar comportamiento en terreno modificado | Reglas de validación al spawn; revalidación de zona si M08/M28 cambia el terreno; teleport discreto anti-atasco |

## Alternativas descartadas

1. **Sistema de IA propio por animal (sin orquestador compartido):** descartado — duplica FSM, navegación y burbuja de M64; más memoria y más bugs.
2. **Simulación completa con Voxel Tools del mundo (M08):** descartado — fuera del presupuesto M61; solo se usa el mapa de navegación.
3. **Comportamiento agresivo/huida con daño:** descartado por regla cozy explícita del proyecto; la huida nunca lastima y nunca se recoge loot.
4. **Población por simulación ecológica completa (depredadores):** descartado — sin depredadores por visión cozy; la regulación es con presupuestos y densidades.

## Decisiones

- La fauna hereda **la burbuja de simulación de M64** (64 m, ≤ 60 NPC plena, resto receta tick 1 s). Si sobrepasa presupuesto, se reduce la burbuja fauna (penalización de ambiente, no de gameplay).
- **Un solo orquestador:** `NPCManager` delega la fauna a `FaunaManager` (mismo pool, misma NavigationServer3D, mismo watchdog anti-atasco).
- Estados "anclados" (fuera de burbuja) viven en un registro ligero (posición, agenda, hambre, energía) — rehidratación al volver a la burbuja.
- Determinismo: PRNG con `seed = seedPartida + biomaId + slotId` (reuso del esquema M29/M64) para tests estables.
- La reproducción jamás produce recursos: las crías crecen a adultez y quedan en el mundo (conservación, sección 35 "Evitar explotación").