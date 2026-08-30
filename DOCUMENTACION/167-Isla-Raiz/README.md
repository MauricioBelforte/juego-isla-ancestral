**Modelo:** Hy3
**Plataforma:** Kilo

# 167 — Isla Raíz (Registro del Terreno y Posicionamiento)

## Propósito
Este módulo es la **fuente de verdad del terreno FIJO de la ISLA RAIZ** y el sistema para
posicionar objetos. **Es exclusivo de la Isla Raíz** — cada isla futura tendrá su propio
módulo separado. (NPCs, ruinas, estructuras) sobre él. Nació de la jornada del 2026-08-29,
donde el terreno y la cámara se rompieron y recuperar su estado requirió ir a commits anteriores.

**Objetivo:** que cualquier agente pueda (1) reconstruir el terreno ideal exacto, (2) posicionar
un objeto sobre la superficie real, y (3) **recuperar el estado si se rompe** — sin rebuscar
en el historial de commits.

## ¿Por qué un módulo nuevo?
- El terreno de una isla debe quedar **fijo y documentado** para poder **crear otras islas**
  después (cada isla = un módulo propio con su terreno + mapa de posiciones).
- Hay sistemas críticos (cámara, spawn, snap de NPC) que necesitan reglas claras para no
  romper el mundo.

## Archivos
- `plan-inicial/` — documentación original (firma: Hy3/Kilo, 2026-08-29)
- `plan-actual/MAPA-OBJETOS.md` — **mapa de posiciones** de todos los objetos del inicio de la
  partida (jugador, NPCs, estructuras). Fuente de verdad; sincronizar con el código. Solo el
  arranque (el jugador luego mueve cosas).
- `plan-actual/` — estado vigente (se actualiza al cambiar el mundo)

## Módulos relacionados
- `08-Mundo-Voxel` — mundo voxel (BlockType, bloques)
- `09-Terreno-Y-Geografia` / `10-Generacion-Del-Mundo` — generador procedural
- `12-Camara` — cámara que sigue al jugador
- `19-NPC-Y-Vecinos` — NPCs y su posicionamiento
- `160-Diseno-De-Ubicaciones-Del-Mundo` — diseño de ubicaciones
