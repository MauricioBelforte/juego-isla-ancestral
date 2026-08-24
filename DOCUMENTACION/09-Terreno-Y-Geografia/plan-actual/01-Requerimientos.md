**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 09: Terreno y Geografía

## ID del Módulo
- **Código:** M09 (plan maestro: sección 8 — Terreno y Geografía)
- **Carpeta:** `DOCUMENTACION/09-Terreno-Y-Geografia/`
- **Dependencias:** M08 (Mundo Voxel). Dependen de este: M10 (Generación), M50 (Vegetación), M27 (Islas)

## 1. Problema

El mundo voxel necesita **geografía con intención**: las formaciones de Aurora (colinas, acantilados, ríos, playas) definen la experiencia de exploración, los puntos de interés y el flujo de juego (GDD viaje del jugador). Sin diseño geográfico, la generación produce terreno sin carácter y "islas planeta" genéricas.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Catálogo de formaciones | Montañas, valles, playas, acantilados, ríos, lagos, cascadas, cuevas, túneles, cañones |
| RF2 | Catálogo de biomas | Bosque, pradera, humedal, desierto, nieve, volcánico pacífico, tropical, costero + especiales |
| RF3 | Transición de biomas suave | Sin bordes bruscos (rampas de mezcla) |
| RF4 | Puntos de interés | Faro, puerto, templo, miradores (feed M10) |
| RF5 | Legibilidad de terreno | Formaciones leíbles a distancia (siluetas) |
| RF6 | Coherencia narrativa | La geografía de Aurora "esconde" la grieta y el templo (progresión de M01) |

## 3. Requisitos No Funcionales

- Generable deterministicamente por seed (M10) — la geografía es dato de diseño, no arte suelto.
- Cada formación es un "receta" de generación reutilizable entre islas.
- Sin formaciones que bloqueen la progresión (anti-softlock geográfico, M66).

## 4. Criterios de Aceptación

1. Los 25 puntos del plan maestro (sección 8) resueltos.
2. Recetas geográficas de Aurora (isla inicial) definidas con referencia a posición.
3. Reglas de transición entre biomas establecidas.
4. Mapa geográfico de Aurora esbozado (zonas y puntos de interés).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M008** — Mundo Voxel | Biomas, terreno, formaciones |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M008** — Mundo Voxel | Depende de este módulo |

