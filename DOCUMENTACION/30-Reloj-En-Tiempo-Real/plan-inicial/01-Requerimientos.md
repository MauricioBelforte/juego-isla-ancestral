**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 30: Reloj en Tiempo Real

## ID del Módulo
- **Código:** M30 (plan maestro: sección 29 — Reloj en Tiempo Real)
- **Carpeta:** `DOCUMENTACION/30-Reloj-En-Tiempo-Real/`
- **Dependencias:** M29 (Tiempo y Calendario, GameClock). Dependen de este: M74 (Eventos), M28 (Viajes), M36 (Fauna)
- **Delegable desde:** hoy (servicio puro por encima de GameClock)

## 1. Problema

Decidir cómo se muestra el **tiempo del mundo** al jugador y si el tiempo real del sistema tiene alguna influencia (sí/no/parcial) — controlando exploits, castigos offline y manipulación del reloj del SO.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Reloj visible | Hora actual siempre accesible en HUD |
| RF2 | Dependencia del reloj del SO | **NO** influye en el juego (decisión) |
| RF3 | Comportamiento offline | Tiempo del mundo congelado (M29 ya lo pausa) |
| RF4 | Anti-exploits | Adelantar/retroceder reloj del SO no produce ventaja |
| RF5 | Sincronización | Reloj del mundo propio (GameClock), no reloj OS |
| RF6 | Fallback | Si el OS da hora anómala, no afecta nada (ignora) |
| RF7 | Pruebas de fechas límites | Año nuevo, fin de mes, fechas de cumpleaños |

## 3. Requisitos No Funcionales

- Sin castigos por no jugar (cozy roja — alineado con M29).
- Sin manipulaciones: el jugador jamás puede "adelantar" tiempo con trucos de SO.
- El reloj es display puro: lee de GameClock, no tiene lógica propia de tiempo.

## 4. Criterios de Aceptación

1. Los 20 puntos de la sección 29 del plan maestro resueltos.
2. Decisión explícita: tiempo real NO condiciona el juego (justificada).
3. Anti-exploit documentado (manipulación OS sin efecto).
4. Estrategia de pruebas de fechas límite escrita.