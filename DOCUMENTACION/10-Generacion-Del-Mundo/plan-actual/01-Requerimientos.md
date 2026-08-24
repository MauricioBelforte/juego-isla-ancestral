**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 10: Generación del Mundo

## ID del Módulo
- **Código:** M10 (plan maestro: sección 9 — Generación del Mundo)
- **Carpeta:** `DOCUMENTACION/10-Generacion-Del-Mundo/`
- **Dependencias:** M08 (Mundo Voxel), M09 (Terreno y Geografía). Dependen de este: M50 (Vegetación), M27 (Islas), M51 (Agua y Clima)

## 1. Problema

El mundo voxel (Aurora 2048×2048) debe generarse **computacionalmente** de forma determinista, visualmente rica y con coste de tiempo real; cada semilla debe producir una isla única pero **jugable** (biomas, riqueza, accesibilidad).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Generación procedural determinista | Misma semilla → mismo mundo byte a byte |
| RF2 | Ruido multi-octava | Perlin/Simplex apilado para terreno, biomas, variación |
| RF3 | Pipeline por capas | Altura → bioma → formaciones → vegetación → agua → estructuras |
| RF4 | Malla por chunk | Generación bajo demanda con streaming (M08) |
| RF5 | Recetas de M09 aplicadas | Formaciones, POI y biomas del módulo 09 |
| RF6 | Estructuras pre-generadas | Ruinas, templos, caminos, puentes dentro del marco narrativo |
| RF7 | Persistencia de cambios | Solo diffs del jugador (M08): el mundo base se regenera, no se guarda |
| RF8 | regen sin seed | El jugador puede re-roll lo no anclado a narrativa |

## 3. Requisitos No Funcionales

- **Tiempo real:** generación asíncrona por chunks detrás de un umbral de frame (M61).
- **Determinismo estricto:** ningún uso de tiempo/rand global; solo PRNG por seed + contexto (coordenada de chunk).
- **Frontier de referencia:** coste de una semilla nueva = mínimo (no guardado).
- **Sin mods en v1.0** (post-v1.0: API de mazmorras/dungeons — roadmap Cenizas).

## 4. Criterios de Aceptación

1. Los 26 puntos del plan maestro (sección 9) resueltos.
2. Pipeline de capas especificado con entradas/salidas por capa.
3. Regla de determinismo (PRNG por contexto) escrita y consumible.
4. Estructuras narrativas ancladas a posiciones fijas (faro, puerto, grieta).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M008** — Mundo Voxel | Pipeline de generación procedural |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M008** — Mundo Voxel | Depende de este módulo |

