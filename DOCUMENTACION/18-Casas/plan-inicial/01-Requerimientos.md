**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 18: Casas

## ID del Módulo
- **Código:** M18 (plan maestro: sección 17 — CASAS)
- **Carpeta:** `DOCUMENTACION/18-Casas/`
- **Dependencias:** M17 (Construcción), M14 (Inventario), M19 (NPC y Vecinos), M29 (Tiempo y Calendario). Relaciones: M21 (Diálogos), M61 (Rendimiento), M58 (Guardado)
- **Delegable desde:** hoy (diseño completo; implementación tras la base de M17, M14 y M19)

## 1. Problema

La casa del jugador es el corazón cozy de la experiencia: un refugio que crece con el jugador, con interior habitable, almacenamiento doméstico, decoración personalizable y lugar de sociabilización con los vecinos. El reto es lograr una casa viva y modificable (construcción M17, ampliaciones por etapas, reubicación, decoración interior) sin degradar el rendimiento del mundo voxel abierto, con interior persistente, muebles interactivos y visitas de NPC (M19), todo integrado con inventario (M14) y tiempo (M29).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Sistema de parcelas | Parcela de terreno validada por M17 donde la casa ocupa su huella; una por jugador, reubicable con coste |
| RF2 | Casa del jugador | Construible desde cero mediante el modo construcción de M17; estado visual exterior según etapa de mejora |
| RF3 | Ampliaciones por etapas | Mejoras escalonadas (choza base, living, dormitorio, cocina, taller, sótano/ático) con costes y materiales |
| RF4 | Interior con habitaciones | Escena interior propia con habitaciones desbloqueables por etapa; entrada/salida por la puerta principal |
| RF5 | Almacenamiento doméstico | Cofres, estanterías y muebles de almacenamiento con slots, integrados con el inventario M14 |
| RF6 | Decoración | Colocación de muebles y objetos en grid interior: rotación, recolocación, objetos de pared, cuadros, plantas |
| RF7 | Muebles interactivos | Camas (dormir), sillas (sentarse), lámparas (encender), electrodomésticos y mesas utilizables |
| RF8 | Cocina, taller y jardín | Espacios funcionales de la casa: cocina, taller y jardín exterior con interacción y recetas (M16) |
| RF9 | Estilos y colecciones | Estilos de decoración (ancestral, floral, oceánico, etc.) y sets coleccionables que premiar |
| RF10 | Visitas de vecinos | Vecinos M19 visitan la casa según horario M29, reaccionan a la decoración y dialogan (M21) |
| RF11 | Persistencia | Interior, decoración, almacenamiento y etapa de mejora se guardan y restauran (M58) |
| RF12 | Casas de vecinos | Parcelas y casas de NPC en el pueblo (M19), con su propio interior y comportamiento |

## 3. Requisitos No Funcionales

- **Cozy:** cero agresividad; hogar acogedor; escenarios de luz cálida; sonidos suaves; el jugador nunca es bloqueado por el sistema de casa.
- **Rendimiento (M61):** interior instanciado con coste cero en el mundo exterior; grid de decoración sin allocs por frame; entrada/salida sin congelamiento.
- **Determinismo suave:** preferencias de vecinos y variaciones por PRNG de partida (M29).
- **Guardado (M58):** serialización compacta por IDs (mueble, rotación, celda); versionado de esquema.
- Pausa con GameClock (M29) congela obras y visitas sin desincronizar.

## 4. Criterios de Aceptación

1. Los 25 puntos de la sección 17 resueltos.
2. Arquitectura House / HouseInterior / HouseUpgrade / HouseStorage / HouseDecor definida con contratos API.
3. Flujo completo verificado: construir casa, entrar, ampliar, decorar, almacenar y recibir visitas.
4. Edge cases documentados (casa en construcción, mudanza de muebles, obra en curso).
5. Delegable para implementación.