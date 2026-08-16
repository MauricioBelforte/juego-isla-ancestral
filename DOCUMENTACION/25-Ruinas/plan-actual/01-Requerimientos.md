# 01 — Requerimientos — M25: Ruinas

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Problema

La isla ancestral está salpicada de ruinas de la civilización anterior: estructuras rotas con historia, secretos y puzzles (M24). El módulo define los **tipos de ruinas, su modularidad constructiva y su progresión de descubrimiento** para que M45 (Arte 3D) y M47 (Texturas) las produzcan sin re-hacer geometría por pieza.

## Objetivos

- Resolver los 25 puntos de la sección 24 del plan maestro.
- Definir 13 tipos de ruinas (pequeñas, medianas, grandes, templos, ciudades antiguas, observatorios, estaciones, faros, puentes antiguos, jardines, edificios abandonados, bibliotecas, talleres) + cámaras secretas y pasajes ocultos.
- **Piezas reutilizables e interconectadas** (modularidad): un kit de ruinas con variantes visuales y de puzzles (gancho a M24).
- Progresión de descubrimiento con recompensas y registros (murales, inscripciones, objetos arqueológicos).

## Alcance

- 13 tipos de estructuras + tanques/contenedores secretos.
- Murales, inscripciones, objetos arqueológicos y sistemas de activación.
- Modularidad: piezas reutilizables, conexiones entre ruinas (caminos, túneles), variantes visuales y variantes de puzzles.
- Progresión de descubrimiento y estado por ruina (persistencia).

## Fuera de alcance

- Puzzles y su framework (M24, ya documentado) — solo se definen los puntos de anclaje.
- Templo subterráneo completo (M26, módulo propio) y su lore.
- Arte 3D, texturas y materiales (M45, M47) — solo se entrega el documento de referencia visual.
- Historia/diálogos (M22/M23) — solo se definen hooks de lore.

## Restricciones

- **Modularidad real**: el kit debe armar 13 tipos con ≤ 40 piezas base; cada pieza con pivote y snaps verificables.
- **Cozy:** las ruinas nunca son laberintos punitivos; pasajes ocultos siempre tienen 2+ caminos o pista ambiental (M24).
- **Persistencia:** estado por ruina (descubierta, restaurada, puzzles completados) en el guardado atómico del proyecto.
- Presupuesto: las ruinas son estáticas; sin costos de simulación (solo culling/grandes LOD via M63).
- Documentación `{ID}-Nombre` (`plan-inicial/` inmutable, `plan-actual/` espejo).

## Criterios de éxito

1. Los 25 puntos de la sección 24 cumplidos y verificables.
2. El kit de 40 piezas arma los 13 tipos + variantes en el Editor sin escena rota (suite).
3. Cada ruina tiene su estado persistente y su progresión de descubrimiento.
4. Cero objetos inaccesibles (integración M66) y cero piezas sin pivote/snap válido (validación en Editor).