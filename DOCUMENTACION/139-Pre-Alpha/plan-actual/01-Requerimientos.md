**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 139: Pre-Alpha

## ID del Módulo
- **Código:** M139 (CHECKLIST-GLOBAL: ID 139 — Pre-Alpha; plan maestro: sección 138 "PRE-ALPHA")
- **Carpeta:** `DOCUMENTACION/139-Pre-Alpha/`
- **Dependencias:** M138 (Vertical Slice). Relaciones: M08 (Voxel), M11 (Jugador), M10 (Mundo), M27 (Islas), M19 (NPC), M38 (Economía), M17 (Construcción), M26 (Templo Subterráneo), M28 (Viajes), M108 (Pipeline de Assets), M59 (Guardado), M53 (UI), M41 (Audio), M61 (Rendimiento), M62 (Memoria), M63 (Cargas y Streaming), M07 (Arquitectura), M152/M153 (Principios, Visión), M136 (Roadmap)
- **Delegable desde:** M138 (Vertical Slice), M136 (Roadmap)

## 1. Problema

El Vertical Slice (M138) probó que el juego funciona como fragmento pulido. El salto a producción completa falla cuando los sistemas no escalan: la arquitectura del slice soporta una zona, pero no 6 islas con 40+ NPC y más de 60 recursos; el pipeline de assets no aguanta la producción masiva de contenido; el guardado no escala en tamaño; el menú y el flujo de sesión no existen fuera de la zona. El Pre-Alpha es la fase donde el juego deja de ser "una zona" y empieza a ser "un mundo": núcleo estable, primer bioma completo, arquitectura confirmada, primeros NPC/sistemas en escala real, primer templo y primer viaje — todo con pipeline y frame budget verdaderos.

## 2. Objetivo

Expandir el Vertical Slice a un **mundo Pre-Alpha**: Aurora completa (primer bioma + núcleos del segundo), arquitectura estable y modular (M07) que soporte el resto de la producción, primeros NPC con rutinas y economía real, sistema de construcción funcional, el primer templo (Templo de Brisa, M26), el primer viaje (M28 al enclave de Coral), conjunto de assets inicial completo con pipeline (M108), guardado v3 escalable, menú principal (M53/M92) y sistema de audio global (M41) — con medición continua (M61/M62/M63) y hits de calidad que garanticen que el 100% del futuro contenido entra sin re-trabajo estructural.

## 3. Alcance

### 3.1 Dentro del alcance
- Aurora completa (isla hub del juego) con todos sus puntos de interés (M10/M09/M27).
- Arquitectura estable: módulos del slice refactorizados a estándar de producción (M07).
- Primeros NPC (6-10 con rutinas de día y diálogos de 10+ líneas, M19/M21/M64).
- Primer sistema económico completo: moneda AO, tiendenteprov (M38/M39) con balance inicial (M93).
- Primer sistema de construcción: piezas, materiales, colocación (M17/M16).
- Primer templo: Templo de Brisa con 2 puzzles completos (M26/M24) + herramienta única.
- Primer viaje: el Gran Vapor al enclave de Coral y vuelta (M28/M27).
- Primer conjunto de assets: árboles, rocas, edificios, NPC, herramientas, flora (M46/M47).
- Primer pipeline de producción de assets validado (M108).
- Primer save completo del juego (v3, M59/M60) y menú principal (M53/M92).
- Primer sistema de audio global: música por zona + buses + eventos (M41/M42/M43/M44).
- Medición continua: FPS, memoria, streaming (M61/M62/M63).

### 3.2 Fuera del alcance
- Historia principal completa (M22/M23): solo misiones introductorias.
- Los otros 5 templos y Sellos (M153): el Templo de Brisa es el piloto.
- Océano completo y buceo (M34/M51): solo el viaje en Gran Vapor.
- Amistad completa (M20), temporadas (M29), eventos (M74): semillas conceptuales.
- Pulido final, optimización profunda, balance total (llegan Alpha/Beta).

## 4. Restricciones

- **Arquitectura perpetua:** nada del Pre-Alpha puede requerir re-trabajo estructural después; la modularidad (M07) es una barrera de calidad.
- **Frame budget (M61):** 60 FPS media; presupuesto por categoría aplicado a cada zona nueva como parte del pipeline (M108).
- **Escala de contenido:** tester nuevo debe poder jugar 2-4 h sin tocar el final del mundo.
- **Guardado (M59):** save v3 con particionado por zona; carga < 2 s.
- **Memoria (M62):** streaming de zonas con presupuesto 1.5 GB.
- **Cozy (M152):** los nuevos sistemas no agregan grind ni ansiedad.
- **Visión (M153):** el mundo Pre-Alpha ya debe sentir el contrato O1-O19 (misterio visible, ritmo amable).
- **Validable:** cada sistema del alcance cumple su módulo correspondiente + checklist de fase.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Aurora completa | Isla hub íntegra: geografía, POIs, vegetación, agua litoral (M10/M27) |
| RF2 | Arquitectura estable | Refactor del slice a estándar M07; módulos con interfaces claras |
| RF3 | Primeros NPC | 6-10 NPC con rutina de día y 10+ líneas de diálogo (M19/M21/M64) |
| RF4 | Economía inicial | Moneda AO, 2 tiendas, precios iniciales coherentes (M38/M39/M93) |
| RF5 | Construcción | 30+ piezas, colocación libre, catálogo (M17/M16) |
| RF6 | Primer templo | Templo de Brisa: 2 puzzles + herramienta del viento (M26/M24/M13) |
| RF7 | Primer viaje | Gran Vapor → enclave de Coral ida y vuelta (M28/M27) |
| RF8 | Pipeline de assets | Flujo validado: modelo → import → material → prefab → escena (M108) |
| RF9 | Save v3 | Guardado particionado por zona; carga < 2 s (M59/M60) |
| RF10 | Menú principal | Menú con continuar, nuevo juego, ajustes, créditos (M53/M92) |
| RF11 | Audio global | Música por zona, buses, eventos de audio (M41-M44) |
| RF12 | Medición | Reportes periódicos FPS/memoria/streaming (M61/M62/M63) |
| RF13 | Playtest de fase | Sesión de 2-4 h con 5+ testers (M114) con encuesta de fase |
| RF14 | Cierre de fase | Go/No-Go a Alpha (M140) con criterios objetivos documentados |

## 6. Criterios de Aceptación (Verificables)

1. RF1-RF11 integrados: un tester nuevo juega 2-4 h sin bloqueos ni pérdida de progreso.
2. El rendimiento global cumple M61 (60 FPS media) en las zonas densas del Pre-Alpha.
3. El guardado v3 (RF9) carga < 2 s y no pierde nada en 20 ciclos.
4. La arquitectura (RF2) no requiere cambios estructurales al agregar zona/NPC/ítem nuevos (prueba con un contenido de muestra).
5. El pipeline (RF8) se usa para el 100% de los assets del Pre-Alpha (sin atajos).
6. El Templo de Brisa (RF6) se completa sin spoilers de los otros templos.
7. La economía inicial (RF4) no se rompe con el jugador más productivo (simulación M93).
8. La sesión de playtest (RF13) termina con ≥ 80% de testers queriendo seguir jugando.
9. La decisión GO/NO-GO Alpha (RF14) está documentada y firmada.
10. El log en `Logs/` está generado y firmado.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M138** — Vertical Slice | Pre-Alpha sobre vertical slice |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M140** — Alpha | Alpha |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M138** — Vertical Slice | Depende de este módulo |
| **M140** — Alpha | Este módulo lo necesita |

