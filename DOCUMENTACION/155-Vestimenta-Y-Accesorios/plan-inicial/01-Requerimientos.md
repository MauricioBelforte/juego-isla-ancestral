**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 01-Requerimientos.md — Módulo 155: Vestimenta y Accesorios

## ID del Módulo
- **Código:** M155 (nuevo módulo — usuario solicitó sistema de vestimenta funcional)
- **Carpeta:** `DOCUMENTACION/155-Vestimenta-Y-Accesorios/`
- **Dependencias:** M11 (Personaje del Jugador), M14 (Inventario), M156 (Terrenos)
- **Dependen de este:** M11 (movimiento), M59 (guardado), M65 (assets)

## 1. Problema

El jugador necesita un sistema de vestimenta que le permita **personalizar la apariencia** de su personaje y **obtener bonificaciones funcionales** según el terreno y la actividad. El sistema debe mantener la filosofía cozy (sin penalizaciones duras, solo mejoras suaves) y ser coherente con el mundo voxel de Aurora.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Slots de equipamiento | 4 slots: cabeza, cuerpo, pies, accesorio |
| RF2 | Prendas cosméticas | Ropa que cambia la apariencia sin afectar stats |
| RF3 | Prendas funcionales | Accesorios que dan bonos según terreno (botas barro, patines, bicicleta) |
| RF4 | Bonos suaves | +5-15% velocidad o comodidad en terreno adecuado |
| RF5 | Penalización suave | Usar equipamiento "equivocado" da malus leve (-5-10%), nunca bloquea |
| RF6 | Desbloqueo progresivo | Prendas se obtienen por exploración, tiendas, misiones, eventos |
| RF7 | Visual coherente | Las prendas se renderizan sobre el personaje voxel (M11) |
| RF8 | Guardado | Equipo persistente en GameState (M59) |

## 3. Requisitos No Funcionales

- **Cozy:** sin penalizaciones duras; usar patines en barro es lento pero no imposible.
- **Visual:** las prendas deben ser reconocibles en estilo voxel (sin texturas ultra detalladas).
- **Rendimiento:** máximo 4 meshes adicionales por personaje (slots); sin impacto en FPS.
- **Accesibilidad:** feedback visual claro de qué terreno es mejor para el equipamiento actual.

## 4. Criterios de Aceptación

1. 4 slots de equipamiento funcionando (cabeza, cuerpo, pies, accesorio).
2. Tabla de bonos por terreno y equipamiento definida.
3. Sistema de desbloqueo progresivo documentado.
4. Integración con M11 (personaje), M14 (inventario), M156 (terrenos), M59 (guardado) definida.
5. Visual coherente con estilo voxel del juego.
