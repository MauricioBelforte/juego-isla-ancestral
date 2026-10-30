**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-30 (vuelta 16; encargo de agnes-3-flash msg 319 — cerrar K-ítems doc/verificables de M157; ítem K-15)

# 06-Plan-Testings.md — Módulo 157: Medios de Transporte

> **Estado (2026-10-30):** plan profesional creado ANTES de la primera prueba manual (AGENTS.md §14 — módulo complejo, gameplay core). El módulo está en **0 implementación verificada en disco** (scaffold doc v14); por tanto este plan es el **contrato de testing** del módulo: las suites se escriben y ejecutan cuando exista `TransportManager`/`JourneyInstance` (GO del fundador + owner de gameplay + visión M154 para assets C-15). Nada aquí afirma que el código existe.

## 1. Alcance y criterio de éxito global
- Cobertura de los CA-01..CA-10 del `01-Requerimientos.md` (plan-inicial) mediante suites headless + **0 errores de runtime en un viaje completo de cada uno de los 5 tipos de transporte** (CA-08).
- Umbral de calidad: tests unitarios del TransportManager con **≥80% cobertura** (RNF-05), ejecutables headless en CI (quality.yml).

## 2. Pruebas unitarias (TransportManager / JourneyInstance / eventos / misterios)
- **T-U1** register/unregister_transport: registro OK, duplicado rechazado, desregistro con viaje activo rechazado (no dejar viaje huérfano).
- **T-U2** get_available_transports: filtrado por posición del jugador, terreno y estado del mundo; escalado de prioridad por distancia × tipo de terreno (RF-01).
- **T-U3** start_journey: validación de costos **antes** de deducir (fondos insuficientes → rechazo limpio, sin deducción parcial — lección BUG M20, Log 2219); creación de JourneyInstance; máximo 1 viaje activo por jugador (B-11).
- **T-U4** cancel_journey: penalización aplicada (CA-06), estado CANCELLED, liberación del slot activo.
- **T-U5** selección de eventos: por peso y cooldown (sin repetición dentro de la ventana); 8 eventos únicos por tipo de transporte (CA-03); ≥2 eventos por viaje en promedio (CA-02).
- **T-U6** JourneyInstance: progreso 0.0→1.0 por delta × velocidad (D-02); tiempo restante estimado (D-03); transiciones de estado válidas (D-07/D-08) — transición inválida rechazada sin corrupción.
- **T-U7** misterios: 3-5 pistas por misterio (F-08), verificación de pistas completas (F-09), resolución con recompensa y final choice (F-10).
- **T-U8** costos: tabla base por tipo (0/25/100/150/300 — C-13) × distancia × destino; deducción correcta del inventario (CA-09); integración EconomyManager (B-09).

## 3. Pruebas de integración (flujos cruzados — sección H del checklist)
- **T-I1** flujo completo de viaje ×5 tipos (barco, tren, avión, carreta, a pie): inicio → eventos en trayecto → llegada (CA-01, CA-08).
- **T-I2** M69 Inventario: verificación y deducción de costos (H-01); obtención de items en eventos (H-02).
- **T-I3** M22 NPCs: spawning en eventos de diálogo (H-03); obtención de diálogos (H-04).
- **T-I4** M24 Misiones: triggers de objetivos de viaje (H-05); verificación de condiciones (H-06).
- **T-I5** M19 Combate: delegación CombatEvent (H-07, E-09); manejo de resultados sin romper el viaje (H-08).
- **T-I6** M29 Economía: comercio con NPCs durante el viaje (H-09); costos y recompensas económicas (H-10).
- **T-I7** contrato M28/M68: M157 **consume** el grafo de paradas/rutas de M68-Transporte-Y-Navegacion (130/130) y las 4 rutas de TravelService de M28-Viajes — **regresión de no-duplicación** (la recomendación de las Notas del Agente v14).
- **T-I8** save/load (RF-02, D-12, CA-07): viaje activo, eventos completados, misterios resueltos y transportes desbloqueados persisten y restauran.

## 4. Edge cases (CA-06, anti-softlock — Plan-inicial-minimo §65)
- **T-E1** cancelación con penalización antes de completar (CA-06).
- **T-E2** inventario lleno al recibir recompensa de evento (H-02) — comportamiento definido (devolver/avisar, no perder).
- **T-E3** fondos insuficientes (rechazo limpio, mensaje al jugador, sin estado inconsistente).
- **T-E4** jugador atrapado a medio viaje: viaje cancelado o interrumpido por carga de partida → regreso seguro o continuación (K-18; integrar softlock_rules/softlock_guard).
- **T-E5** carga de escena durante viaje activo (persistencia + reanudación).
- **T-E6** evento sin definición en la tabla del tipo (fallback seguro, log claro, sin crash).
- **T-E7** transporte no disponible por condición de desbloqueo/estación (C-12) — no aparece en disponibles ni inicia viaje.

## 5. Manejo de errores
- Catálogo JSON inválido o vacío (`diario_catalog`-style) → fallback seguro + log claro (patrón M55 `diary_service.gd` L63).
- Señales del event bus desconectadas: el viaje no se pierde por caída de UI (K-17 documenta las señales cuando se implementen).
- Persistencia de viaje corrupta → nuevo viaje limpio con aviso al jugador (nunca softlock).

## 6. Rendimiento (RNF-01, Plan-inicial-minimo §60)
- Viaje completo sin frame drops >5ms (T-I1 con profiling).
- Pooling de eventos (B-10/D-05) y generación bajo demanda — nunca pre-cargar las 40 entradas de eventos.
- Virtualización de listas de eventos/misterios en la UI (patrón M55 diario / M61 lista virtualizada).

## 7. Orden de ejecución y gates
1. Suites T-U* al crearse TransportManager/JourneyInstance (TDD recomendado — primero el test, luego el script).
2. T-I* tras las integraciones H-01..H-10.
3. T-E* + sección 5 **antes de la primera prueba manual** (este plan cumple ese gate al existir previamente).
4. quality.yml: agregar las suites al pipeline CI headless (patrón M17/M20/GUT).
5. Resultados medidos → `07-Resultados-Testings.md` (crear al ejecutar; no existe aún porque no hay código que testear).

## 8. Criterios de cierre de ítems del checklist
- I-01..I-10 y K-12..K-14 se cierran solo con suite en disco + resultados 0 fallos + evidencia citada en 07 (anti-inflación §21.8.2.b).
- K-23: QA cruzado §21.8 (verificador ≠ implementador) + muestreo ≥5 ítems `[x]` contra disco **antes** de cualquier sello del módulo.

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
