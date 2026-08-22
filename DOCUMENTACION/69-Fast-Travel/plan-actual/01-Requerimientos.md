**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 01-Requerimientos.md — Módulo 69: Fast Travel

## ID del Módulo
- **Código:** M69 (plan maestro: sección 68 — Fast Travel)
- **Carpeta:** `DOCUMENTACION/69-Fast-Travel/`
- **Dependencias:** M28 (Viajes), M29 (Tiempo y Calendario), M31 (Ciclo Día/Noche), M157 (Medios de Transporte)
- **Delegable desde:** diseño completo; implementación tras sistema de mundo/base

## 1. Problema

El jugador necesita desplazarse eficientemente entre áreas del mundo sin fatiga ni interrupciones al gameplay cozy. El fast travel debe ser una **experiencia jugable por sí misma**, no una pantalla de carga. Cada viaje debe ofrecer misterios, eventos y contenido significativo que haga del trayecto algo que el jugador quiera experimentar, no saltarse.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Viajes rápidos disponibles | Desbloqueado progresivamente; costo en recursos o tiempo |
| RF2 | Punto de viaje | El jugador puede establecer marcadores en ubicaciones descubiertas |
| RF3 | Restricciones de acceso | Bloqueado durante ciertos estados (combate, eventos especiales) |
| RF4 | Costo de viaje | Cada viaje tiene un costo (recursos, tiempo de juego, o moneda) |
| RF5 | Teletransporte a deidades | Opción especial para viajar a santuarios/dioses (M17) |
| RF6 | Cancelación | El jugador puede cancelar el viaje a mitad de carga |
| RF7 | Guardado automático | El último punto de viaje se guarda por sesión |
| RF8 | Experiencia de viaje | El trayecto NO es instantáneo; tiene duración real con eventos |
| RF9 | Misterios durante el viaje | Cada ruta tiene misterios aleatorios que resolver durante el trayecto |
| RF10 | Medios de transporte | El jugador elige CÓMO viajar: barco, tren, avión, carreta, a pie (M157) |

## 3. Requisitos No Funcionales

- **Cozy:** transiciones suaves; tiempos de viaje relajados; interfaz clara y tranquila
- **Rendimiento:** lógica O(1) para lookup de destinos; sin cálculos complejos por frame
- **Coherencia con M29/M31:** los tiempos de viaje respetan el ciclo día/noche y calendario Aurora
- **Accesibilidad:** opciones de atajo de teclado y menú intuitivo
- **Pausa:** el fast travel se pausa automáticamente en modo single-player
- **Jugabilidad:** el viaje debe ser interesante, no un skip automático

## 4. Criterios de Aceptación

1. Los 13 puntos de la sección 68 resueltos.
2. Mapa de puntos de viaje en el mundo de Aurora.
3. Reglas de restricción y costo definidas.
4. Fast travel bloqueado durante combate/eventos críticos.
5. Guardado del último punto de viaje por sesión.
6. Integración con M157 (Medios de Transporte) definida.
7. Sistema de eventos aleatorios durante viajes documentado.
8. Sistema de misterios por ruta definido.
