**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 139: Pre-Alpha

## 1. Análisis del dominio

### 1.1 Estado de entrada
El proyecto llega al Pre-Alpha con un **Vertical Slice aprobado** (M138): una zona jugable de 20-30 minutos (esquina de Aurora, Finneas, una ruina con puzzle, autosave v2, música/SFX/UI/VFX básicos) que valida el núcleo (M152) y la visión (M153) con frame budget M61. Lo que el slice NO prueba es **escala**: el salto de "una zona curada" a "un mundo de 6 islas con 40+ NPC, 60+ recursos, 6 templos y viajes" es el riesgo técnico más grande del proyecto.

### 1.2 Problemas técnicos a resolver en la fase

| # | Problema | Origen | Riesgo si no se resuelve |
|---|---|---|---|
| P1 | Arquitectura del slice no escala | Módulos curados a mano (M138) | Re-trabajo estructural en cada zona nueva |
| P2 | Pipeline de assets inexistente | Assets del slice hechos manualmente (M138) | Producción de contenido imposible de sostener |
| P3 | Economía con 1-2 precios | M93 solo en papel | M38/M39 rotos con 60+ recursos |
| P4 | Construcción sin validación | M17 sin prototipo en slice | Promesa de M152 (libertad) no cumplida |
| P5 | Templo/Puzzle solo en ruina | M26 sin diseño validado | El contenido estrella (6 templos) no probado |
| P6 | Save pequeño y local | M59 v2 solo slice | Save de mundo completo lento o corrupto |
| P7 | Menú inexistente | Slice arranca directo (M138) | Flujo de sesión no definido |
| P8 | Audio curado, no sistemático | M41-M44 sin buses globales | Inconsistencia sonora entre zonas |
| P9 | Sin medición continua | M61 validado puntualmente | Regresiones de rendimiento indetectables |

### 1.3 Restricciones del dominio
- **Cozy (M152):** ningún sistema nuevo puede agregar grind, ansiedad ni espera frustrante. El viaje, la construcción y la economía tienen ritmo propio.
- **Visión (M153):** el mundo Pre-Alpha debe comunicar los misterios de fondo (Sellos, ruinas) sin explicarlos: misterio visible.
- **Rendimiento (M61):** el pipeline M108 impone el frame budget como gate de aceptación de cada zona.
- **Escala declarada:** al cierre, un tester nuevo juega 2-4 h sin agotar contenido.
- **Sin re-trabajo:** lo que se construye en Pre-Alpha debe sobrevivir a Alpha/Beta sin migraciones estructurales.

## 2. Alternativas evaluadas

### 2.1 Estrategia de expansión del mundo
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| A1: Expandir la zona del slice hasta cubrir Aurora completa | Reutiliza todo lo curado | Aurora es la isla hub: cubrirla exige todos los sistemas igual | ✅ **Elegida**: Aurora completa = banco de pruebas de TODOS los sistemas con el contenido más rejugable |
| A2: Construir 2 islas medianas nuevas | Variedad rápida | Duplica pipeline sin validar nada nuevo | ❌ Descarta: valida lo mismo con 3 veces el trabajo |
| A3: Isla de pruebas procedural | Barato | No representa el contenido real | ❌ Descarta: no valida el mundo real |

### 2.2 Templo piloto
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| T1: Templo de Brisa (1º de los 6, en Aurora) | Es el primero que el jugador encuentra; escapa del spoiler de los otros; herramientas: viento | Obliga a definir normas de templo ahora | ✅ **Elegida**: establece el canon de templos (M26) que se repetirá 5 veces |
| T2: Los 6 templos en miniatura | Prueba todo el set | Spoilers masivos, costo altísimo, contradice M153 | ❌ Descarta |

### 2.3 Personajes y NPC
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| N1: Ciclo completo de Finneas + 5-9 vecinos nuevos con rutinas | Valida M19/M64 a escala | Esfuerzo de contenido alto | ✅ **Elegida**: 6-10 NPC = mínimo para que Aurora "viva" |
| N2: Solo Finneas y extras decorativos | Barato | No valida la vida del pueblo | ❌ Descarta |

### 2.4 Sistema de construcción
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| C1: Grid voxel ligero con 30+ piezas (mobiliario, vallas, caminos) | Coherente con mundo voxel; bajo costo; sin física compleja | Menos libertad que construcción libre | ✅ **Elegida**: la libertad cozy en este proyecto es *decorar y habilitar*, no ingeniería |
| C2: Construcción libre con física | Máxima libertad | Fricción, fixtures desbalanceados, frame budget en riesgo | ❌ Descarta (M152: la frustración rompe el cozy) |

### 2.5 Economía y moneda
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| E1: Moneda AO + 2 tiendas + trueques en islas remotas | Valida M93 y deja espacio a lo conceptual | — | ✅ **Elegida** (M38/M39/M93) |
| E2: Troco puro sin moneda | Económicamente seductor | Arcos de progresión débiles; balance más frágil | ❌ Descarta para fase: la moneda deja rastro de progresión visible |

### 2.6 Viaje
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| V1: El Gran Vapor a Coral (en-clave real visitable, sin construir) | Hito emocional; valida M28/M27/M67 | El buque necesita animación/cámara | ✅ **Elegida**: el "primer viaje" del plan maestro |
| V2: Teatro de viaje (fade + pantalla) | Barato | Rompe inmersión, no valida navegación | ❌ Descarta |

### 2.7 Guardado
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| S1: Save v3 particionado por zona + delta voxel (M59/M60) | Carga < 2 s, escrituras pequeñas | Más piezas móviles | ✅ **Elegida** |
| S2: Un archivo JSON gigante | Simple | Carga lenta, corrupción total | ❌ Descarta |

## 3. Decisiones clave

1. **Aurora completa como primer bioma** (A1), con núcleos del bioma vecino (Coral) solo como meta del viaje.
2. **Templo de Brisa = canon de templos** (T1): 2 puzzles de gala + herramienta del viento (M24/M26/M13).
3. **6-10 NPC con rutinas** (N1): Finneas + elenco vecino (M19/M64) con diálogos de 10+ líneas (M21).
4. **Construcción por grid/catálogo** (C1): 30+ piezas de mobiliario/valla/camino (M17/M16) sin física.
5. **Moneda AO + 2 tiendas** (E1) según curvas de M93, con simulación de desbalance.
6. **Gran Vapor a Coral** (V1) con cutscene de travesía breve (M28).
7. **Save v3 particionado** (S1): por zona + delta para el mundo voxel (M59/M60).
8. **Pipeline M108 como gate**: cada zona nueva entra al mundo solo si cumple frame budget M61 y memoria M62/M63.
9. **Métricas continuas**: telemetría local de sesión (M104/M105) activada en cada build Pre-Alpha.
10. **Menú completo** (M53): continuar/nuevo/ajustes/créditos con verificación de integridad del save (M66).
11. **Audio global** (M41-M44): buses por zona, transiciones de clima/día-noche, eventos, ASMR de recolección.
12. **Producción masiva evitada**: el pipeline se valida con ~30 assets reales, no con cientos sintéticos.

## 4. Análisis de riesgo de la fase

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Aurora completa no entra en frame budget | Media | Alta | Gate M61 por zona; LOD/culling M63 desde el día 1; presupuesto por categoría |
| NPC con rutinas falla (caminos, colisiones) | Media | Alta | Rutinas con waypoint asistido y teleport anti-stuck (M66); test de marcha >
 24 h simuladas |
| Economía explota con min-maxing | Media | Alta | Simulación M93 en CI; márgenes 55-70%; techo de dinero |
| Construcción desconecta del mundo voxel | Baja | Media | Malla de piezas separada pero integrada al guardado (M60) |
| Save v3 se corrompe en viaje | Baja | Alta | Checksum por partición; doble escritura; test de 20 ciclos |
| Oficios de contenido (6-10 NPC, 30+ piezas) | Alta | Media | Pipeline M108 + plantillas de personaje/tienda (M19/M38) |
| Scope creep a Alpha | Alta | Media | GONOGO-M140 con criterios fijos (sección criterios de aceptación) |

## 5. Criterios de éxito de la fase (GONOGO a M140-Alpha)

1. Tester nuevo: 2-4 h de juego sin bloqueos ni pérdida de progreso.
2. 60 FPS media en Aurora con densidad real de NPC y flora.
3. Cualquier zona nueva se agrega sin cambios estructurales (prueba de contención).
4. El 100% de los assets del Pre-Alpha pasó por el pipeline M108.
5. Templo de Brisa completo sin spoilers de los otros templos.
6. Simulación económica estable en CI (M93).
7. ≥ 80% de testers quieren seguir jugando al cerrar la sesión.
8. Save v3 carga < 2 s en 20/20 ciclos.
9. Documentación DoD cumplida (sección 12 AGENTS.md) y QA cruzado superado.