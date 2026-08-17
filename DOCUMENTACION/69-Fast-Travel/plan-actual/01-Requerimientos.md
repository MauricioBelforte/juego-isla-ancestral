**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 01-Requerimientos.md — Módulo 69: Fast Travel

## ID del Módulo
- **Código:** M69 (plan maestro: sección 68 — Fast Travel)
- **Carpeta:** `DOCUMENTACION/69-Fast-Travel/`
- **Dependencias:** M28 (Viajes), M29 (Tiempo y Calendario), M31 (Ciclo Día/Noche)
- **Delegable desde:** diseño completo; implementación tras sistema de mundo/base

## 1. Problema

El jugador necesita desplazarse eficientemente entre áreas del mundo sin fatiga ni interrupciones al gameplay cozy. El fast travel debe estar disponible pero limitado, con restricciones que mantengan la exploración significativa y eviten el bypass de eventos críticos, manteniendo la sensación de un mundo vivo y conectado.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Viajes rápidos disponibles | Desbloqueado progresivamente; costo en recursos o tiempo |
| RF2 | Punto de viaje | El jugador puede establecer marcadores en ubicaciones descubiertas |
| RF3 | Restricciones de acceso | El fast travel está bloqueado durante ciertos estados (combate, eventos especiales) |
| RF4 | Costo de viaje | Cada viaje tiene un costo (recursos, tiempo de juego, o moneda) |
| RF5 | Teletransporte a deidades | Opción especial para viajar a santuarios/dioses (M17) |
| RF6 | Cancelación | El jugador puede cancelar el viaje a mitad de carga |
| RF7 | Guardado automático | El último punto de viaje se guarda por sesión |

## 3. Requisitos No Funcionales

- **Cozy:** transiciones suaves; sin tiempos de carga excesivos; interfaz clara y tranquila
- **Rendimiento:** lógica O(1) para lookup de destinos; sin cálculos complejos por frame
- **Coherencia con M29/M31:** los tiempos de viaje respetan el ciclo día/noche y calendario Aurora
- **Accesibilidad:** opciones de atajo de teclado y menú intuitivo
- **Pausa:** el fast travel se pausa automáticamente en modo single-player

## 4. Criterios de Aceptación

1. Los 13 puntos de la sección 68 resueltos.
2. Mapa de puntos de viaje en el mundo de Aurora.
3. Reglas de restricción y costo definidas.
4. Fast travel bloqueado durante combate/eventos críticos.
5. Guardado del último punto de viaje por sesión.
6. Delegable para implementación.
