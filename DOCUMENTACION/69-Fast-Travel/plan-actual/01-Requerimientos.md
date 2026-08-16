**Modelo:** Nemotron 3.5 Lightning
**Plataforma:** Cline

# 01-Requerimientos.md â€” MÃ³dulo 69: Fast Travel

## ID del MÃ³dulo
- **CÃ³digo:** M69 (plan maestro: secciÃ³n 68 â€” Fast Travel)
- **Carpeta:** `DOCUMENTACION/69-Fast-Travel/`
- **Dependencias:** M28 (Viajes), M29 (Tiempo y Calendario), M31 (Ciclo DÃ­a/Noche)
- **Delegable desde:** diseÃ±o completo; implementaciÃ³n tras sistema de mundo/base

## 1. Problema

El jugador necesita desplazarse eficientemente entre Ã¡reas del mundo sin fatiga ni interrupciones al gameplay cozy. El fast travel debe estar disponible pero limitado, con restricciones que mantengan la exploraciÃ³n significativa y eviten el bypass de eventos crÃ­ticos, manteniendo la sensaciÃ³n de un mundo vivo y conectado.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Viajes rÃ¡pidos disponibles | Desbloqueado progresivamente; costo en recursos o tiempo |
| RF2 | Punto de viaje | El jugador puede establecer marcadores en ubicaciones descubiertas |
| RF3 | Restricciones de acceso | El fast travel estÃ¡ bloqueado durante ciertos estados (combate, eventos especiales) |
| RF4 | Costo de viaje | Cada viaje tiene un costo (recursos, tiempo de juego, o moneda) |
| RF5 | Teletransporte a deidades | OpciÃ³n especial para viajar a santuarios/dioses (M17) |
| RF6 | CancelaciÃ³n | El jugador puede cancelar el viaje a mitad de carga |
| RF7 | Guardado automÃ¡tico | El Ãºltimo punto de viaje se guarda por sesiÃ³n |

## 3. Requisitos No Funcionales

- **Cozy:** transiciones suaves; sin tiempos de carga excesivos; interfaz clara y tranquila
- **Rendimiento:** lÃ³gica O(1) para lookup de destinos; sin cÃ¡lculos complejos por frame
- **Coherencia con M29/M31:** los tiempos de viaje respetan el ciclo dÃ­a/noche y calendario Aurora
- **Accesibilidad:** opciones de atajo de teclado y menÃº intuitivo
- **Pausa:** el fast travel se pausa automÃ¡ticamente en modo single-player

## 4. Criterios de AceptaciÃ³n

1. Los 13 puntos de la secciÃ³n 68 resueltos.
2. Mapa de puntos de viaje en el mundo de Aurora.
3. Regras de restricciÃ³n y costo definidas.
4. Fast travel bloqueado durante combate/eventos crÃ­ticos.
5. Guardado del Ãºltimo punto de viaje por sesiÃ³n.
6. Delegable para implementaciÃ³n.