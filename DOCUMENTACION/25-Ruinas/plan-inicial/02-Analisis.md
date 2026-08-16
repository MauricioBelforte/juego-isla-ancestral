# 02 — Análisis — M25: Ruinas

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Puntos de la sección 24 resueltos

| Punto (Plan) | Resolución |
|---|---|
| Diseñar ruinas pequeñas | Chozas/ermitas: 3-5 piezas, 1 puzzle fácil (M24 banda Exploración) |
| Diseñar ruinas medianas | Caseríos/atalayas: 8-15 piezas, 1-2 puzzles (banda Ritual) |
| Diseñar ruinas grandes | Templos/fortines: 25-60 piezas, 2-3 puzzles y multilaterales (banda Antiguo) |
| Diseñar templos | Tipo central: plan en cruz, vestíbulo, sancta; siempre con 1 puzzle de luz (M24) |
| Diseñar ciudades antiguas | 3-5 bloques urbanos con calles, una plaza y un acueducto; solo perimetral jugable |
| Diseñar observatorios | Domo con agujero cenital, anillos de piedra (M31: alineación solar para activar puzzle) |
| Diseñar estaciones | Muelles/peajes de los caminos antiguos; gancho a vehículos (M66 amarres) |
| Diseñar faros | Torres con haz fisicalizable (luz M24) y linterna de memoria (narrativa M22) |
| Diseñar puentes antiguos | 2 variantes (arco y colgante 3 cables); validación estructural por piezas |
| Diseñar jardines | Terrazas con canales de agua (M24 familia agua), flora ancestral; decorativo + puzzle suave |
| Diseñar edificios abandonados | 2 plantas con balcón roto; interiores solo donde necesarios (recorte de geometría) |
| Diseñar bibliotecas | Estanterías vacías, mural del mapa; es el "cofre de lore" (objetos arqueológicos) |
| Diseñar talleres | Hornos y yunques rotos; clues de herramientas del inventario (M24 familia herramientas) |
| Diseñar cámaras secretas | Bajo placas/estatuas; siempre con 2+ caminos de acceso (M66) |
| Diseñar pasajes ocultos | Tras puertas falsas/soterrados; detectables por pista ambiental (viento en M32) |
| Diseñar murales | 12 murales icónicos (historia de la civilización) como recompensa de descubrimiento |
| Diseñar inscripciones | Glosas de 30-60 glifos; catálogo = glosario del templo (M24 familia símbolos) |
| Diseñar objetos arqueológicos | 25 objetos con 3 estados (enterrrado→expuesto→museo, M36) |
| Diseñar sistemas de activación | 8 sistemas reutilizables (palanca, anillo, girador de estrella, llave runa, timón...) |
| Diseñar progresión de descubrimiento | Por ruina: no descubierta → descubierta → explorada → completada |
| Crear piezas reutilizables | Kit base ≤ 40 piezas con pivote/snap (suelo, pared, esquina, arco, columna, techo...) |
| Crear modularidad | Ensamblaje en Editor con snaps; validación automática (sin huecos/traslapes) |
| Crear variantes visuales | 3 paletas (edad:temprana/media/tardía) sin variantes de geometría |
| Crear variantes de puzzles | 2-3 configuraciones de puzzle por ruina grande (rejugabilidad en nueva partida, seed) |
| Crear conexiones entre ruinas | Caminos de 2-4 tramos entre ruinas; solo perimetrales (sin túneles profundos; ver M26) |

## Alternativas descartadas

1. **Ruinas únicas hechas a mano (sin kit):** descartado — 13 tipos + variantes exige 300+ piezas únicas; el kit de 40 es la decisión central.
2. **Interiores completos de todos los edificios:** descartado — costo irrelevante para la exploración; solo interiores necesarios.
3. **Pasajes ocultos sin pista:** descartado — rompe la anti-arbitrariedad (M24) y la accesibilidad.
4. **Variantes de geometría por región:** descartado — caro; 3 paletas de textura cubren la variedad visual.

## Decisiones

- **Kit modular de ≤ 40 piezas** con snaps y pivotes validados en Editor; los 13 tipos se arman por combinación.
- **Progresión de descubrimiento en 4 estados** persistidos (descubierta → explorada → completada → museo).
- **Los murales e inscripciones** son reward de descubrimiento (lore + glosario de M24).
- **Conexión entre ruinas por caminos** (2-4 tramos) que enganchan con M28 (caminos) y M08 (terreno).
- **Sistemas de activación reutilizables** (8 tipos) compartidos con M24 (las reglas del puzzle viven en datos).