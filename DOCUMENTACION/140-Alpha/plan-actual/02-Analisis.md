**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 140: Alpha

## 1. Análisis del dominio

### 1.1 Estado de entrada
Pre-Alpha (M139) entregó: Aurora completa, elenco de NPC con rutinas, economía AO local, construcción (30+ piezas), Templo de Brisa, Gran Vapor a Coral, pipeline M108 estable y save v3 + menú. Lo que Alpha debe resolver:

| # | Problema | Origen | Riesgo si no se resuelve |
|---|---|---|---|
| P1 | Mecánicas principales ausentes en el núcleo | M33-M37/M16/M20 piloto o solo diseño | "Juego incompleto" percibido; promesas de M71 incumplidas |
| P2 | Historia sin recorrido completo | M22 solo misiones intro | Sin sentido de propósito; los Sellos (M153) no funcionan |
| P3 | Sistemas desconectados entre sí | Cada sistema curado por separado | El mundo no "respira"; sin emergent gameplay |
| P4 | Balance solo teórico en papel | M93 en simulación, sin contenido real | Economía rota cuando entra todo el contenido |
| P5 | Contenido insuficiente para partida completa | Pre-Alpha: 2-4 h | Partida "troncada" a las 10 h |
| P6 | Rendimiento sin medición sistemática | M61-M63 puntuales | Regresiones invisibles; llega Beta con sorpresas |
| P7 | QA reactivo, no sistémico | Bugs se arreglan sin triaje | Deuda de bugs; defectos estructurales repetidos |
| P8 | Deuda técnica acumulada (TODO/FIXME, code smells) | Velocidad de las fases previas | Re-trabajo costoso en Beta si no se paga ya |

### 1.2 Restricciones
- **Historia y canon (M147/M153):** la ruta de los Sellos respeta la biblia, no rompe misterio, no obliga contenido que contradiga el cozy (M152).
- **Rendimiento (M61):** cada sistema entra CON su medición, no después.
- **Save (M59/M60):** extendido a todo el mundo; migración sin pérdida.
- **Calendario (M29):** los eventos de temporada entran como *base* (1-2 por estación), no completos.

## 2. Alternativas evaluadas

### 2.1 Estrategia de integración de sistemas
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| I1: Integrar sistema por sistema en oleadas con "semana de integración" | Complejidad acotada | Riesgo de integración tardía | ✅ **Elegida**: 4 oleadas (W1 economía+tiendas+balance, W2 amistad+diálogos+eventos, W3 templos+puzzles+artefactos, W4 viajes+islas+clima) con una semana de integración al final |
| I2: Integrar todo de golpe al cierre | Rápido en papel | Debugging catastrófico | ❌ Descarta |

### 2.2 Director de la historia
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| H1: Director de acto (script dirigido por hitos, no por secuencia lineal) | El jugador hace la historia a su ritmo; rejugabilidad | Más estados que validar | ✅ **Elegida**: cada Sello tiene prerequisito de "terminaciones" verificables (ej: 2 sellos + amistad X), respetando libertad cozy |
| H2: Secuencia lineal fija de misiones | Simple | Rompe la libertad central (M152/M153) | ❌ Descarta |

### 2.3 Plazo de QA intensivo
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| Q1: 3-4 semanas de hardening con triaje diario | Ciclo cerrado y medible | Costo de tiempo | ✅ **Elegida** (estándar de la fase) |
| Q2: QA continuo integrado (cada sprint) | Distribuido | No garantiza el "endgame push" | ❌ Descarta como único: se usa, pero se mantiene el sprint final dedicado |

### 2.4 Balance
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| B1: Simulación + playtest dirigido + ajuste por archivo JSON (M93) | Triple red de seguridad | Costo de orquestación | ✅ **Elegida** |
| B2: Solo playtest | Barato | Sin cobertura de 40 h | ❌ Descarta |

### 2.5 Métrica de rendimiento por plataforma
| Alternativa | Ventajas | Desventajas | Decisión |
|---|---|---|---|
| R1: Perfil semanal en build de referencia + dashboard | Medible y continuo | Costo de build | ✅ **Elegida** (build semanal de referencia, M104/M105) |
| R2: Perfil al final | Simple | Detecta tarde | ❌ Descarta |

## 3. Decisiones clave

1. **4 oleadas de integración + semana de integración** (I1).
2. **Director de acto con prerequisitos de terminaciones** (H1): Sellos 1-2 libres, 3-4 exigen logros de sistemas, 5-6 exigen el conjunto.
3. **Sprint final de QA de 3-4 semanas** (Q1) con triaje diario y playtest semanal (M114).
4. **Triple red de balance** (B1): simulación M93 en CI + playtest dirigido + ajuste en JSON sin recompilas.
5. **Build semanal de referencia con perfil** (R1) y dashboard de FPS/memoria/cargas.
6. **Deuda técnica (M135) con sprint dedicado**: 2 semanas de pago (0 TODO/FIXME al cierre).
7. **Save v3 extendido** al mundo completo con migración versionada (M59/M60).
8. **Beta (M141) se prepara desde la W4**: backlog priorizado por riesgo (localización total, plataformas, pulido).
9. **Accesibilidad desde el inicio de diseño de sistemas nuevos** (M58), no al final.

## 4. Análisis de riesgo

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Historia se alarga más allá del objetivo | Media | Alta | Hitos de contenido por Sello con corte accionable en W3 |
| Integraciones cruzadas generan bugs en cascada | Alta | Alta | Semana de integración + triaje diario + test de regresión automática (M112) |
| Balance no cierra en el plazo QA | Media | Alta | Simulación con escenarios extremos; ajuste vía JSON; feature freeze de balance 2 semanas antes del GONOGO |
| 60-100 h de contenido no alcanza | Media | Media | Paralelización viajes/templos; reutilización de conjunto de assets M108 |
| Rendimiento se degrada con contenido completo | Alta | Alta | Build semanal de referencia y gate automático (M61/M118) |
| Equipo satura con Q1 | Media | Media | Triaje por severidad; fix solo críticos/altos en sprint; al resto backlog documentado |

## 5. Criterios de éxito (GONOGO a Beta — M141)

1. H1-H10 del documento de diseño cumplidos y verificados (ver `03-Diseno.md`).
2. 0 bugs críticos/altos conocidos; bajos documentados y planificados.
3. Rendimiento medible en build de referencia con las 2 plataformas objetivo de la fase.
4. 60-100 h de partida completa alcanzable y verificada por playtest dirigido (M114).
5. Simulación M93 estable en 40 h simuladas sin alertas.
6. 0 TODO/FIXME en el repositorio (M111).
7. Deuda técnica M135 reducida ≥ 50% con métrica documentada.
8. Documento GONOGO-BETA firmado, con backlog priorizado de Beta.