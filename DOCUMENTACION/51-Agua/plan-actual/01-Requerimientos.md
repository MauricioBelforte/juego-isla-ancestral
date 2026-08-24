**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 51: Agua

## ID del Módulo
- **Código:** M51 (CHECKLIST-GLOBAL: ID 51 — Agua; plan maestro: sección 50 "AGUA")
- **Carpeta:** `DOCUMENTACION/51-Agua/`
- **Dependencias:** M08 (Mundo Voxel — bloques de agua), M09 (Terreno — nivel del mar, océano, ríos), M10 (Generación del Mundo — ríos/corrientes procedurales), M47 (Texturas — shader agua), M04 (Godot). Relaciones: M61 (Rendimiento), M62 (Memoria), M11 (Natación), M32 (Clima), M28/M67 (Barcos), M36/M65 (Fauna acuática), M42 (Sonido), M52 (Partículas), M24 (Puzzles), M13 (Herramientas), M33 (Agricultura — riego)
- **Delegable desde:** M08 (bloque de agua), M09 (nivel de mar), M47 (shader de agua), M04 (física)

## 1. Problema

Aurora es una isla (M09) rodeada de océano, con ríos, lagos, cascadas, agua subterránea y zonas congeladas. Sin un sistema de agua definido, el proyecto degeneraría en: océano infinito renderizado carísimo (draw calls), agua sin colisiones (el jugador la atraviesa), transparencia/refracción que rompe el presupuesto de frame (M61), ríos que no fluyen, nivel del mar inconsistente entre chunks (M10), o agua que ignora la física cozy de natación (M11). El plan maestro lista 25 exigencias: tipos de agua, olas, reflejos, transparencia, espuma, corrientes, inundación/drenaje, congelamiento/evaporación, interacciones (herramientas, puzzles, clima, barcos, fauna), sonidos, partículas, optimización y colisiones. El objetivo del módulo es que TODA agua de Aurora se comporte, se vea y suene coherente: olas con espuma, reflejos suaves, transparencia determinista, corrientes que mueven objetos (M70), congelamiento en invierno, y coste verificado.

## 2. Objetivo

Definir el sistema de agua de la isla: catálogo de tipos (océano, río, lago, cascada, subterránea, congelada, especial — aguas termales/M31), nivel del mar global consistente (M09/M10), render de océano con olas y espuma (shader M47), transparencia y reflejos acotados (M61), corrientes (ríos con flujo), mecánicas de inundación/drenaje y congelamiento/evaporación (clima M32, estaciones M29), interacciones (balde M13, puzzles de agua M24, lluvia M32, barcos M28/M67, fauna M36/M65, natación M11), sonidos (M42) y partículas (M52), colisiones coherentes con la física voxel, y presupuesto de rendimiento verificable. El resultado debe ser agua determinista, cozy y barata.

## 3. Alcance

### 3.1 Dentro del alcance
- Tipos de agua: océano, río, lago, cascada, subterránea, congelada, especial (termal/laguna brillante).
- Nivel del mar: global por semilla (M09/M10), consistente entre chunks, ajustable por POI (M09).
- Render: océano con olas (shader M47), espuma en costa, transparencia determinista, reflejos acotados (reflection probes solo en escenas clave), sin refracción global.
- Corrientes: ríos con flujo (velocidad por punto), mueven objetos sueltos (M70) y barcos (M28).
- Mecánicas: inundación (puzzles M24, lluvia M32), drenaje (puzzles), congelamiento (invierno M29/M32: caminar sobre hielo acotado), evaporación (lago del desierto, M32).
- Interacciones: balde (M13), botella (recursos M15), riego (M33), puzzles de agua (M24: represas, canales, cerraduras), barcos (M28/M67), fauna acuática (M36/M65), natación del jugador (M11).
- Sonido: chapoteo, olas, cascadas (M42).
- Partículas: salpicaduras, gotas en cascadas, rocío (M52).
- Colisiones: superficie sólida para nadar/pies, bloques de agua interactuables (M08).
- Optimización: mesh de nivel de mar por chunk/LOD, sin per-instancia; presupuesto M61/M62.

### 3.2 Fuera del alcance
- El modelado del terreno costero/lecho: M09.
- La fauna acuática (peces, etc.): M36/M65 (aquí solo su interacción con el agua).
- Los barcos/vehículos acuáticos: M67/M28 (aquí solo la interacción física con el agua).
- El sonido del agua: M42 (se consume, no se genera).
- Las partículas de salpicadura: M52 (se consumen desde este módulo).
- La natación del jugador (movimiento): M11 (se consume la física de flotación aquí definida).

## 4. Restricciones

- **Godot 4.x (>= 4.4.1):** shaders de agua (M47), reflejos vía ReflectionProbe/Mirror donde se justifique, transparencia con depth_prepass.
- **Presupuesto:** océano por mesh con LOD; reflejos solo donde califican; transparencia sin overdraw; contra M61/M62.
- **Determinismo:** olas/corrientes por fase fija + semilla (M10); sin RNG por frame.
- **Coherente con voxel:** el nivel de agua es un plano a nivel de mar (M09); los bloques de agua (M08) son para fuentes/interacción.
- **Congelamiento:** caminar sobre hielo solo en zonas congeladas estacionales (M29/M32), con límites de tiempo (M31) y sin softlock (M66).
- **Colisiones:** el jugador flota (M11) con física suave; los objetos sueltos flotan (M70) si densidad < agua.
- **Validable:** `validate_water.gd` verifica nivel de mar, presupuesto y determinismo.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Tipos de agua | Océano, río, lago, cascada, subterránea, congelada, especial — con parámetros de shader, sonido y física por tipo |
| RF2 | Nivel del mar | Global por semilla (M09/M10), consistente entre chunks; alturas ajustables por POI documentadas |
| RF3 | Render de océano | Mesh por chunk con olas (shader M47), espuma costera (altura de ola vs costa), transparencia determinista |
| RF4 | Reflejos y transparencia | Reflejos: ReflectionProbe solo en escenas clave (≤2 por escena); sin refracción global (solo pools pequeños M24) |
| RF5 | Olas y corrientes | Olas por fase fija; corrientes de río por spline (velocidad), mueven objetos y barcos |
| RF6 | Cascadas | VF: mesh de caída con partículas (M52), sonido de cascada (M42), remolino en base |
| RF7 | Agua subterránea | En cuevas (M26): charcos, nivel de agua estático, espuma de esporas; sin olas |
| RF8 | Agua congelada | Invierno (M29/M32): superficie congelada caminable (límites M31/M66), hielo como bloque (M08) |
| RF9 | Agua especial | Termales/lagunas brillantes (M47 emisivos), sin daño, sin congelamiento |
| RF10 | Inundación y drenaje | Puzzles (M24): compuertas, represas; lluvia (M32) eleva lagos temporales (límites) |
| RF11 | Evaporación | Desierto (M32): lagos efímeros, secado gradual; sin impacto en progresión |
| RF12 | Interacción con herramientas | Balde (M13), botella (M15), riego (M33); el agua transportada es un ítem (M14) |
| RF13 | Interacción con puzzles | Canales, compuertas, cerraduras de agua (M24); flujo direccional |
| RF14 | Interacción con barcos | Flotabilidad y deriva por corriente (M28/M67); olas afectan balanceo visual |
| RF15 | Interacción con fauna | Peces (M36/M65) nadan según corrientes; sin colisiones duras |
| RF16 | Interacción con jugador | Natación (M11): flotación suave, chapoteo al entrar/salir, sprint en agua costoso (M11) |
| RF17 | Sonidos | Chapoteo, olas, cascadas, hielo al caminar (M42) |
| RF18 | Partículas | Salpicaduras, rocío, gotas de cascada (M52) |
| RF19 | Colisiones | Superficie sólida para flotar; bloques de agua (M08) interactuables; física voxel coherente |
| RF20 | Optimización | Mesh de agua por chunk con LOD, culling, sin instancias; presupuesto M61/M62 |
| RF21 | Validación | `validate_water.gd`: nivel de mar consistente, presupuesto, determinismo |
| RF22 | Naming | Convention `water_`, `wave_` (M108) |

## 6. Criterios de Aceptación (Verificables)

1. El nivel del mar es consistente entre chunks (sin escalones visibles) y coincide con M09/M10.
2. El océano con olas y espuma corre dentro del presupuesto (fps objetivo) en hardware medio.
3. Las corrientes de río mueven objetos sueltos y barcos con deriva correcta.
4. El hielo caminable solo aparece en zonas/estaciones congeladas y se disuelve sin softlock (M66).
5. Las cascadas tienen sonido + partículas sincronizados (M42/M52).
6. El agua subterránea y los puzzles de compuertas/canales funcionan (M24).
7. La natación (M11) flota suave, sin clipping, con chapoteo correcto.
8. El presupuesto de render (mesh, reflejos, transparencia) se verifica con el validador.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M008** — Mundo Voxel | Agua por chunks |
| **M024** — Templos y Puzzles | Base para templos y puzzles |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M008** — Mundo Voxel | Depende de este módulo |
| **M024** — Templos y Puzzles | Depende de este módulo |

