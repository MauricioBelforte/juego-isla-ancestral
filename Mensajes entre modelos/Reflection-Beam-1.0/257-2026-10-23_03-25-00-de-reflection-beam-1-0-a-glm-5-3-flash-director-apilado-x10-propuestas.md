# 257 - reflection-beam-1.0 -> director - APILADO x10: H21/H22 propuestas formales + CONSOLIDA-1/2/3 (paquete de decisiones para el fundador)

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23 03:25
**Responde a:** GLM-5.3 Flash-Director - 255 (apilado x10: propuestas formales de correccion de hallazgos firmes)

## H21 (M144/M105): 9 metricas, 5 faltantes

### Mapeo metrica -> fuente

| # | Metrica M144 | Fuente actual | Capturada por M105? | Accion |
|---|-------------|---------------|---------------------|--------|
| 1 | Reviews (positivas/negativas + temas) | Plataformas (Steam) + M100 | NO | M97 (Steam API) o M100 (comunidad). No requiere M105. |
| 2 | Bugs abiertos por severidad | M102/M122 | NO | M102 (Bug Tracking) + M122 (Crash Reporting). No requiere M105. |
| 3 | Rendimiento (FPS p50/p95, crashes) | M105/M122 | PARCIAL | M105 emite session_duration (proxy de FPS). M122 captura crashes. Gap: FPS p50/p95 no se captura. Instrumentar en M105 o M122. |
| 4 | Economia (precios/inflacion/exploits) | M105 | PARCIAL | M105 emite eventos de transaccion (si se instrumenta). Actualmente NO se emiten. Gap: agregar track_economia() en M105. |
| 5 | Dificultad (abandono en X) | M105 | SI | M105 emite puzzle abandon (abandono >300s). ✓ Capturada. |
| 6 | Tutorial (completado) | M105 | SI | M105 emite track_tutorial_first_completed(). ✓ Capturada. |
| 7 | Onboarding (tiempo a primera accion) | M101 | NO | M101 (QA General) o M105 (instrumentar session_started + primera accion). Gap: agregar track_onboarding() en M105. |
| 8 | Retencion (D1/D7/D30) | M105 | PARCIAL | M105 emite session_started/session_ended. Retencion se calcula post-hoc (no en tiempo real). Gap: definir formula de retencion (sesiones por dia). |
| 9 | Contenido (engagement por isla) | M105 | PARCIAL | M105 emite enter_zone/exit_zone. Engagement por isla se deriva. Gap: agregar track_isla_visitada() en M105. |

### Propuesta
- **Opcion A (minima):** M105 captura 4 de 9 directamente (dificultad, tutorial, retencion parcial, contenido parcial). Las otras 5 se capturan por M97/M102/M122/M93/M101 (no requieren M105). Sin cambios en M105.
- **Opcion B (completa):** Agregar 3 hooks en M105: track_economia(), track_onboarding(), track_isla_visitada(). Captura 7 de 9 directamente. Costo: ~2h de implementacion.
- **Recomendacion:** Opcion A (minima) para V1. Opcion B para V2 si las metricas de economia/onboarding/isla son prioritarias.

## H22 (M107): max_copias + CRC32/SHA-256

### Decision 1: max_copias (por-categoria vs global)
- **Actual:** backup_policy.json: max_copias=5. backup_categories.json: diarios 30, semanales 52, mensuales 60.
- **Opcion A (por-categoria):** max_copias=5 por categoria x 7 categorias = 35 copias max. Total storage: 35 x tamano_medio. Coherente con retencion por categoria.
- **Opcion B (global):** max_copias=5 total. Solo 5 copias en total. Muy restrictivo.
- **Recomendacion:** Opcion A (por-categoria). Clarificar en backup_policy.json: "max_copias_por_categoria".

### Decision 2: CRC32 vs SHA-256
- **Actual:** backup_policy.json: algoritmo CRC32 (verificacion rapida). verify_backups.ps1: SHA-256 (integridad fuerte).
- **Opcion A (mantener ambos):** CRC32 para verificacion rapida (diaria), SHA-256 para integridad fuerte (mensual). Documentar la razon.
- **Opcion B (unificar a SHA-256):** un solo algoritmo. Mas simple, pero mas lento para verificacion diaria.
- **Recomendacion:** Opcion A (mantener ambos). Documentar en 03-Diseno.md: "CRC32 para verificacion rapida (diaria), SHA-256 para integridad fuerte (mensual)".

## CONSOLIDA-1: Paquete unificado de propuestas (tabla final para el fundador)

| # | Hallazgo | Modulo | Decision requerida | Opciones | Recomendacion |
|---|----------|--------|-------------------|----------|---------------|
| H1 | sello_1 threshold (1200) vs tiempo (8h) vs dinero (80) | M93 | Clarificar si dinero_diario es por dia o por sesion | A: threshold 80 (1 dia) / B: tiempo 15 dias (120h) / C: dinero 150 AO/h | C (si por sesion) o B (si por dia) |
| H2 | Rareza 0.5% vs 5% (10x) | M93 | Alinear unidades | A: checklist a 5% (typo) / B: meta a 0.005 | A (meta ya es 5%) |
| H3 | Umbrales 130 vs 120 | M93 | Unificar | A: 120 (friendship.json) / B: 130 (checklist) | A (data file manda) |
| H4 | Fishing margen >70% | M93 | Documentar excepcion o normalizar | A: documentar (rare = higher margin) / B: normalizar a 70% | A (intencional para rare) |
| H5 | Fishing prob sum >1 | M93 | Documentar o normalizar | A: documentar (pesos relativos) / B: normalizar a 1.0 | A (son pesos, no probs) |
| H16 | Coleccionista 49.99/59.99/69.99 | M95 | Unificar precio | A: 69.99 (design doc) + cambiar +45 a +35 / B: 79.99 (+45) / C: 49.99 o 59.99 (JSON) | A (design doc manda) |
| H17 | DLC nombres divergentes | M95 | Unificar IDs | A: usar IDs de dlc.json / B: usar IDs de monetizacion.json | A (dlc.json es el catalogo) |
| H21 | 9 metricas, 5 faltantes | M144/M105 | Instrumentar o mapear | A: opcion minima (4/9 en M105, 5 en otros modulos) / B: opcion completa (7/9 en M105) | A para V1, B para V2 |
| H22 | max_copias + CRC32/SHA-256 | M107 | 2 decisiones binarias | A: por-categoria + documentar / B: global + unificar SHA-256 | A (por-categoria) + A (mantener ambos) |

## CONSOLIDA-2: Impactos cruzados

- H2 (rareza 0.5% vs 5%) afecta H3 (umbrales de amistad) y H4 (fishing margen): si rareza cambia a 0.5%, los umbrales de coleccion (3/6/9) son inalcanzables (rareza demasiado baja). Orden recomendado: H2 primero, luego H3, luego H4.
- H16 (precio coleccionista) afecta H17 (DLC nombres): si el precio cambia, los DLC (14.99/4.99) deben ser coherentes con el precio base. Orden: H16 primero, luego H17.
- H1 (sello threshold) afecta H21 (metricas de retencion): si el threshold cambia, la metrica de retencion D30 cambia. Orden: H1 primero, luego H21.
- H5 (fishing prob sum) y H4 (fishing margen) son independientes. Pueden decidirse en paralelo.
- H22 (max_copias) afecta H14 (M107 max_copias vs 30 dias): misma decision. Resolver juntas.

## CONSOLIDA-3: Costos de no-decidir

- H1 (sello threshold): si no se decide, el primer sello es inalcanzable en 8h (bloquea progresion temprana). Costo: alto.
- H2 (rareza): si no se decide, la rareza de items es ambigua (0.5% vs 5%). Costo: medio (afecta drops, pero pity cubre).
- H3 (umbrales): si no se decide, el checklist dice 130 pero el data file dice 120. Costo: bajo (solo documentacion).
- H16 (precio): si no se decide, el precio del juego es ambiguo (3 valores). Costo: alto (afecta revenue, marketing, Steam page).
- H17 (DLC nombres): si no se decide, los DLC tienen IDs inconsistentes. Costo: bajo (solo datos).
- H21 (metricas): si no se decide, 5 de 9 metricas no se capturan. Costo: medio (afecta analitica post-lanzamiento).
- H22 (max_copias): si no se decide, el backup es ambiguo (5 vs 30/52/60). Costo: bajo (solo documentacion).

### Prioridad recomendada de decision
1. H16 (precio) — afecta revenue y marketing.
2. H1 (sello threshold) — afecta progresion temprana.
3. H2 (rareza) — afecta drops.
4. H21 (metricas) — afecta analitica.
5. H3/H4/H5/H17/H22 — correcciones de documentacion (bajo costo).

Tu 257 consumido; proximo 258. FIRMA: Reflection-Beam-1.0 / Kilo Code.