**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 123: Modding

## 1. Problema
El juego premiun cosy no necesita modding para lanzar, pero la comunidad (M100) puede pedirlo tras el lanzamiento (M143). Hoy no hay ninguna definición técnica. Este módulo decide **si habrá modding y con qué alcance**, diseñando toda la superficie técnica (API, formato, seguridad, carga, conflictos, compatibilidad, herramientas, docs, distribución, workshop, límites, saves con mods, soporte oficial, coste técnico) para que la decisión sea tomada con datos y sin re-arquitecturas.

## 2. Objetivo del módulo
Documentar el **plan de modding**: decisión de alcance (post-V2), API pública de contenido (objetos, recetas, biomas, misiones, NPC), formato (paquete embuelto de M108), seguridad (sandbox no-code: datos + scripts solo con aprobación), carga (ModLoader vía M108), conflictos/compatibilidad (prioridades y validadores de M109), herramientas (editores de M109 exportables), documentación para modders, distribución (Workshop de Steam si corresponde), límites, saves con mods y soporte oficial.

## 3. Alcance (derivado del plan maestro: sección 122 "MODDING")
1. **Decidir si habrá modding** — decisión explícita con criterios de tiempo/valor.
2. **Diseñar API** — superficie de contenido modable (data-first, sin código para datos).
3. **Definir formato de mods** — paquete ZIP/**MOD** compatible M108; manifiesto.
4. **Definir seguridad** — sandbox: datos validados, scripts solo listas de aprobación (no ejecución arbitraria).
5. **Definir carga de mods** — ModLoader al boot (M63), recarga en caliente con gate de compatibilidad.
6. **Definir conflictos** — detección de ids duplicados y orden de prioridad; resolver con validadores de M109.
7. **Definir compatibilidad** — versionado semver de mods contra el build (M117/M142).
8. **Definir herramientas** — exportadores de los editores de M109 a formato mod.
9. **Definir documentación** — guía de modding, esquemas y ejemplos.
10. **Definir distribución** — Workshop de Steam (M97) si corresponde; bundles fuera de Steam no.
11. **Definir workshop si corresponde** — sí, únicamente Steam Workshop vía Steamworks.
12. **Definir límites** — lista blanca de dominios modables; tamaños máximos; número máximo de mods.
13. **Definir saves con mods** — marca de mods activos en el save (M59); juego sin mods puede cargar saves con mods SOLO con advertencia; modo "sin mods" para soporte.
14. **Definir soporte oficial** — SLA: bugs con mods activos se trian SOLO si repoducen sin mods; FAQ de modding (M100).
15. **Evaluar coste técnico** — estimación en tiempo (equipo) y riesgo de re-arquitectura para post-lanzamiento.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Decisión de modding documentada con GATE (post-V2, prioridad Baja) |
| RF2 | API de contenido data-first (sin scripts) v1; scripts con lista de aprobación v2 (opcional) |
| RF3 | Formato de mod: paquete del mismo formato de M108 + manifiesto JSON |
| RF4 | Sandbox: validación de datos al cargar (M109 validators) |
| RF5 | ModLoader al boot con orden de carga y detección de conflictos |
| RF6 | Compatibilidad semver mod↔build con bloqueo por incompatibilidad |
| RF7 | Exportadores de M109 a formato mod |
| RF8 | Documentación de modding (guía + esquemas) |
| RF9 | Distribución a través de Steam Workshop (si corresponde) |
| RF10 | Límites: dominios modables, tamaños y cantidad de mods |
| RF11 | Saves con marca de mods; cargar sin mods con advertencia |
| RF12 | Soporte oficial: bugs con mods se trian sin mods |
| RF13 | Estimación de coste técnico (horas/riesgo) para el GATE |

## 5. Criterios de aceptación (DoD del módulo)
1. Los 15 puntos del maestro digitalizados con decisiones y diseño.
2. Decisión de alcance explícita (GATE post-V2) con criterios medibles.
3. API data-first definida (dominios modables) respetando M108.
4. Formato ModLoader, conflictos y compatibilidad diseñados.
5. Seguridad: validación al cargar + sin ejecución de scripts arbitrarios.
6. Exportadores de M109 documentados.
7. Documentación de modding esbozada (índice de guía + esquema).
8. Workshop y distribución definidos (o descartados) con razones.
9. Saves con mods: política clara (M59) y operativa.
10. Soporte oficial con SLA de triaje documentado.

## 6. Restricciones
- **Aplican:** M108 (formato de datos/mods base), M109 (herramientas), M59 (saves), M117 (builds/versionado), M97 (Steam/Workshop), M100 (comunidad), M116 (instalador).
- Rocket: **no modding antes del lanzamiento (M143)**; solo diseño preparado para implementarlo post-V2 sin re-arquitectura.
- Los scripts de mods NO se ejecutan (solo datos) en v1.
- El seguro queda cubierto por M106 (integridad) y listas de aprobación.
- Coste técnico debe mantenerse < 10% del presupuesto de V2 (estimado).