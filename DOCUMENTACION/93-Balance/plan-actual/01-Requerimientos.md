**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 93: Balance

## ID del Módulo
- **Código:** M93 (CHECKLIST-GLOBAL: ID 93 — Balance; plan maestro: sección 92 "BALANCE")
- **Carpeta:** `DOCUMENTACION/93-Balance/`
- **Dependencias:** M38 (Economía), M20 (Sistema de Amistad). Relaciones: M15 (Recursos), M16 (Crafting), M17 (Construcción), M13 (Herramientas), M33 (Agricultura), M34 (Pesca), M35 (Minería), M28 (Viajes), M22 (Historia Principal), M23 (Historias Secundarias), M24 (Templos y Puzzles), M26 (Templo Subterráneo), M71 (Progresión), M72 (Logros), M153 (Objetivo Final — Sellos), M29 (Tiempo y Calendario), M31 (Ciclo Día-Noche), M59 (Guardado), M105 (Telemetría de Gameplay), M114 (Playtest), M152 (Principios Innegociables), M94 (Retención sin FOMO)
- **Delegable desde:** M38 (economía), M20 (amistad), M153 (objetivo final)

## 1. Problema

Un juego cozy con economía, amistad, agricultura, pesca, minería, crafting, construcción, viajes, Sellos, misiones, puzzles y desbloqueos corre el riesgo de degenerar en sistemas descoordinados: precios sin criterio, recompensas que dejan de motivar, builds que convierten el juego en un trámite, o progresión rápida que vacía el contenido. Sin un sistema central de balance, cada módulo ajusta por intuición, aparecen exploits (bucles infinitos de dinero, granjas imposibles de mantener) y el jugador termina con grind, algo prohibido por el principio M152. El objetivo es un sistema de balance con datos verificables: valores, curvas, matrices y metas de tiempo — todo centralizado, editable y validable.

## 2. Objetivo

Definir el sistema de balance del juego: un único lugar con los valores de equilibrio de todos los sistemas (precios, recompensas, costes, tiempos, curvas de progresión), reglas anti-grind y anti-exploit verificables por script, simulaciones económicas para detectar desvíos, y medición con métricas reales (M105) para el ajuste continuo. El resultado debe ser: jugar es agradable, el progreso se siente generoso, nada obliga a grindear, y ningún bucle de juego genera recursos sin esfuerzo equivalente.

## 3. Alcance

### 3.1 Dentro del alcance
- Tabla de balance central (precios, recompensas, costes de construcción, crafting, herramientas, recursos, agricultura, pesca, minería, viajes).
- Balance de Sellos (M153): condición, esfuerzo y recompensa por Sello.
- Balance de amistad (M20): regalos, diálogos, umbrales de amistad.
- Balance de misiones (M22/M23), puzzles (M24/M26) y desbloqueos (M71).
- Balance de tiempo diario: duración estimada de actividades y sesión.
- Curvas de progresión: dinero, recursos, amistad, colecciones, Sellos.
- Reglas anti-grind y anti-exploit verificables (`validate_balance.gd`).
- Simulaciones económicas (escenarios de generación vs. gasto).
- Integración con métricas reales (M105) y playtesting (M114).

### 3.2 Fuera del alcance
- La implementación de la economía (precios, tiendas): M38.
- La implementación del sistema de amistad: M20 (aquí solo su balance).
- La implementación de agricultura/pesca/minería/crafting: M33/M34/M35/M16 (aquí solo sus valores).
- La telemetría y analytics: M104/M105 (aquí solo qué medir en relación al balance).
- La decisión de monetización: M95.

## 4. Restricciones

- **Cozy (M152):** sin grind; nada de recompensas que exijan ausencia; sin penalizaciones irreversibles.
- **Vision (M153):** el progreso hacia Sellos debe respetar el contrato O1-O19 (ritmo accesible, sin metagaming forzado).
- **Un solo lugar de verdad:** los valores de balance viven en recursos `.tres`/`.json` bajo `data/balance/`; los módulos los consumen; nada de valores hardcodeados en gameplay.
- **Validable:** `validate_balance.gd` sin errores en consola; cada regla tiene un `assert` explícito.
- **Rendimiento:** los recursos de balance se cargan una vez; no hay I/O por frame.
- **Persistencia (M59):** ningún valor de balance se guarda en GameState (solo puede variar por parche/versión).
- **Idioma:** valores documentados en español y con unidades explícitas (moneda "AO", horas, días).

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Tabla de precios | Precio de compra/venta de cada ítem (M38) en la moneda del juego (AO) |
| RF2 | Recompensas | Recompensa (dinero/ítems) por actividad: recolección, pesca, minería, misiones, puzzles, Sellos |
| RF3 | Coste de construcción | Coste en recursos y dinero de cada pieza de construcción (M17) |
| RF4 | Balance de crafting | Receta → coste de recursos + tiempo; utilidad del resultado ≥ coste acumulado |
| RF5 | Balance de herramientas | Durabilidad, mejoras (M13), y retorno de la inversión |
| RF6 | Balance de recursos | Abundancia por bioma/temporada (M15, M29), respawn y rareza |
| RF7 | Balance de agricultura | Tiempo de crecimiento, rendimiento, precio de venta por cultivo (M33) |
| RF8 | Balance de pesca | Probabilidades por hora/clima/temporada y precio por pez (M34, M31, M32) |
| RF9 | Balance de minería | Probabilidades por profundidad, valor de minerales/gemas (M35) |
| RF10 | Balance de viajes | Coste y tiempo de viaje entre islas (M28); viaje no debe ser castigo |
| RF11 | Balance de Sellos | Esfuerzo, condición y recompensa de cada Sello (M153) |
| RF12 | Balance de amistad | Puntos por regalo, umbrales de amistad, beneficios por nivel (M20) |
| RF13 | Balance de misiones | Recompensa por misión principal (M22) y secundaria (M23) en AO y ítems |
| RF14 | Balance de puzzles | Recompensa y tiempo estimado de resolución (M24/M26) |
| RF15 | Balance de desbloqueos | Coste y condición de cada desbloqueo (M71) |
| RF16 | Tiempo diario | Duración estimada de cada actividad; sesión cómoda < 30 min diarios |
| RF17 | Curvas de progresión | Curvas de dinero, recursos, amistad, colecciones y Sellos en el tiempo |
| RF18 | Anti-grind | Reglas verificables: ningún recurso necesario en cantidades molestas; capas de generosidad |
| RF19 | Anti-exploit | Detección de bucles de ganancia sin costo (simulación) |
| RF20 | Simulación económica | Terminal de simulación: generación vs. gasto por día de juego |
| RF21 | Métricas reales | Qué medir (M105): AO por día, tiempo por actividad, abandono, picos de recursos |
| RF22 | Revisión con playtest | Proceso de ajuste alimentado por M114 (playtest) y M101 (QA) |

## 6. Criterios de Aceptación (Verificables)

1. Existe la tabla de balance central con TODOS los valores pedidos (RF1-RF16) en recursos bajo `data/balance/`.
2. Ningún valor de balance está hardcodeado en scripts de gameplay (grep verifica).
3. `validate_balance.gd` valida los 130+ ítems del checklist y pasa sin errores.
4. Las reglas anti-grind/anti-exploit son verificables por simulación y todas pasan.
5. La curva de progresión promedio cumple: llegar al 1er Sello sin grind, con < 2 h de juego activo por bloque de progreso.
6. El tiempo diario cómodo (RF16) no supera los 30 min para la rutina básica.
7. Las métricas (M105) definidas miden los desvíos de balance real vs. simulado.
8. El proceso de ajuste por playtest (M114) está documentado y conectado.
9. La documentación plan-actual refleja el estado real del sistema.
10. El log en `Logs/` está generado y firmado.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M020** — Sistema de Amistad | Base para sistema de amistad |
| **M038** — Economía | Balance de progresión |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M094** — Retención sin FOMO | Usado por retención sin fomo |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M020** — Sistema de Amistad | Depende de este módulo |
| **M038** — Economía | Depende de este módulo |
| **M094** — Retención sin FOMO | Este módulo lo necesita |

