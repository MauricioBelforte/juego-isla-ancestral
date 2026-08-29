**Modelo:** Hy3
**Plataforma:** Kilo

# 01-Requerimientos.md — Módulo 167: Registro del Terreno y Posicionamiento

## Problema
El terreno de la Isla Raíz se rompió y se recuperó durante la jornada del 2026-08-29
(cámara "no me veo", spawn en el mar, NPC flotante). Recuperar el estado requirió ir a
commits anteriores. No existe un registro de la configuración fija ni de cómo posicionar
objetos sobre el terreno.

## Objetivos
1. Documentar la **configuración fija del terreno de la Isla Raíz** (generador, radio, perfil,
   colores, spawn, cámara).
2. Definir el **sistema de posicionamiento** de objetos (NPCs, ruinas, estructuras) sobre la
   superficie real del terreno, mediante `get_height()`.
3. Proveer un **procedimiento de recuperación** del terreno/cámara/spawn si se rompen, sin
   rebuscar en commits.

## Alcance
- Configuración documentada del mundo de la Isla Raíz (radio 256, perfil en capas, paleta Maldivas).
- Método robusto para posicionar cualquier objeto sobre el terreno.
- Reglas de cámara, spawn y snap de NPC.
- Manual de recuperación.
- Mapa de ubicaciones de los objetos actuales (Catalina, ruina Chozavil, spawn).

## Fuera de alcance
- El motor voxel (M08/M09/M10), el diseño de ubicaciones (M160), el diseño visual de NPCs (M161).
- Otras islas (cada isla tendrá su propio módulo 1XX siguiendo esta plantilla).

## Restricciones
- No pisar la lógica de M08/M09/M10/12/19.
- Seguir AGENTS.md §9 (desacoplamiento) y las guías 07 (Godot) / 06 (visión).
- El terreno debe ser reproducible: misma semilla, mismo perfil → mismo mundo.
