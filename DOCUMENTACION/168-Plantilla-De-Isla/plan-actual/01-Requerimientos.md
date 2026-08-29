**Modelo:** **[COMPLETAR]**
**Plataforma:** **[COMPLETAR]**

# 01-Requerimientos.md — Módulo <ID>: <Nombre de la Isla> [MAQUETA]

> ⚠️ **ESTE ES UN TEMPLATE.** Copia esta carpeta a `<ID>-Isla-<Nombre>` y reemplaza los
> `[COMPLETAR]` con los datos de tu isla. No edites este módulo 168 directamente.

## Problema
La isla <Nombre> necesita un terreno propio documentado (fuente de verdad) para posicionar
sus objetos sin romper el mundo, y poder recuperarlo si se daña.

## Objetivos
1. [COMPLETAR] Documentar la configuración fija del terreno de la isla <Nombre>.
2. [COMPLETAR] Definir el sistema de posicionamiento de objetos sobre la superficie real.
3. [COMPLETAR] Proveer un procedimiento de recovery del terreno/cámara/spawn.

## Alcance
- Configuración documentada del mundo de la isla <Nombre> (radio, perfil, paleta).
- Método robusto para posicionar objetos (get_height).
- Reglas de cámara, spawn y snap de NPC.
- Manual de recuperación.
- Mapa de ubicaciones de los objetos actuales.

## Fuera de alcance
- El motor voxel (M08/M09/M10), diseño de ubicaciones (M160), diseño visual de NPCs (M161).
- Los detalles de la Isla Raíz (van en `167-Isla-Raiz`).

## Restricciones
- No pisar la lógica de M08/M09/M10/12/19.
- Seguir AGENTS.md §9 (desacoplamiento) y las guías 07 (Godot) / 06 (visión).
- El terreno debe ser reproducible: misma semilla, mismo perfil → mismo mundo.
* (El terreno que quieres es el de la Isla Raíz: radio 256, perfil en capas, paleta Maldivas. Elige el que quieras para tu isla.)
