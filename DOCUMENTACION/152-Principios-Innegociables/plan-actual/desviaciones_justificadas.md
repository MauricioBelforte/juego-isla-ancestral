# Desviaciones Justificadas — M152-Principios-Innegociables

**Modelo:** space-bunny-alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04
**Plantilla:** la del propio M152 en `03-Diseno.md` §5 «Registro de desviaciones justificadas»
(6 columnas: ID | Decisión | Principio desviado | Justificación | Aprobado por | Fecha)

---

## ⚠️ Nota previa: el ejemplo `D001` de la plantilla era FICTICIO

La plantilla de `03-Diseno.md` §5 trae un ejemplo de desviación con `ID = D001`
(*«Agregar combate para misiones específicas»*, fechado 2026-08-16, aprobado por «Equipo de
diseño»). **Ese ejemplo nunca existió como registro real**: no había ningún archivo de
desviaciones en el repositorio, y «Equipo de diseño» no es un rol que exista en este proyecto
(AGENTS.md §21 no lo define; el proyecto es 1 humano + agentes de IA). Es un placeholder de
plantilla que se lee como si fuera un hecho consumado — el mismo patrón H-D que detecté en los
`Totales` de M152 (**SB-01, Log 1270**) y en 13 `05-Checklist.md` más (**SB-02, Log 1279**).

**Este archivo es el primer registro REAL de desviaciones justificadas del proyecto.** Las
entradas `D-R1` y `D-R2` de abajo son las dos primeras, ambas detectadas y verificadas por
`space-bunny-alpha` en SB-01 y resueltas por el fundador el 2026-10-04.

---

## Registro

| ID | Decisión | Principio desviado | Justificación | Aprobado por | Fecha |
|----|----------|-------------------|---------------|--------------|-------|
| **D-R1** | **Agregar combate**: existe el módulo `164-Isla-De-Combate-Endgame` (4 zonas, 8 mobs con HP/ataque, 2 jefes con fases, tienda de gemas, 6 recompensas) | **Sin combate por convención** — `02-Vision-Y-Concepto/plan-actual/03-Diseno.md` §1 «Ausencia **total** de combate, muerte o penalizaciones violentas» + `01-Fundamentos-Del-Proyecto/plan-actual/03-Diseno.md` §11 decisión 1 «Cero violencia y cero penalizaciones violentas — **CERRADA**» | **El combate existe pero NO es letal en consecuencias.** `164/plan-actual/03-Diseno.md` §4: «Si el jugador pierde (HP ≤ 0): vuelve al pueblo **sin penalidad** · No se pierden objetos · **No hay game over**». Es decir: se mantiene el principio de fondo (la muerte y el castigo irreversible están prohibidos) y se abre una excepción acotada para contenido opcional de endgame. Coincide con el **Ejemplo 1** del propio M152 (`03-Diseno.md` §10), ya aprobado entonces: «combate cooperativo, no centrado en violencia». No contradice ningún otro principio de M152: ni el antigrind (M93 regla 8), ni el cozy (M15 §6, M29 §4), ni la monetización (M95 R1-R5) | **Fundador** (decisión escalada por el director atria-dawn el 2026-10-04; no es decisión de agente) | 2026-10-04 |
| **D-R2** | **Ampliar el mapa ×10**: radio 256 → **2560**, mundo **5120²**, centro (2560, 2560). Commit `c107419`, rework «Isla 10x» | **No ampliar el mapa solamente para hacerlo grande** — y la condición que el propio M152 puso en su **Ejemplo 3** (§10): *«Ampliar mapa **solo si** se agregan NPCs, recursos, misiones en **nuevas áreas**»* | **CUMPLIDA PARCIALMENTE — 2 de 3.** Se verificó cruzando los artefactos de datos reales contra el umbral del área vieja (r ≤ 256) desde el centro (2560, 2560) (**SB-03, Log 1278**):<br>· **NPCs (fauna) — CUMPLIDA.** `scripts/fauna/fauna_spawner.gd` L54-68 calcula 3 zonas nominales desde `MundoRaiz`: pradera r ∈ [1588..2088], playa r ∈ [1546..1786], humedal r ∈ [1680..1880]. **Todas a r ≥ 1546.**<br>· **Recursos (M15) — CUMPLIDA.** `scripts/main_island.gd` L71 puebla alrededor de `mundo.SPAWN_CONTENIDO` (3860, 3860) → **r = 1838**. Vegetación (M50) en `vegetation_spawner.gd` L36-37 con radio 1200 → **r ∈ [638..3038]**. Estación de crafting inicial (M16) en `main_island.gd` L55-56 → **r = 1845**.<br>· **Misiones (M22) — NO CUMPLIDA.** `data/historia/historia_principal.json` (8 capítulos, 7 sellos, 4 finales) es un **grafo narrativo sin ninguna coordenada**: los nodos tienen `id`, `capitulo`, `titulo`, `tipo`, `resumen`, `requisitos`, `siguiente`. El contenido de misiones **nunca fue anclado espacialmente**, en el área vieja ni en la nueva. Lo mismo ocurre con M160 (`data/ubicaciones/ubicaciones_loc.json` + `data/locations/*.tres`: `location_id`, `nombre`, `npcs`, `conexiones`, `objetos`, **sin posición**).<br>**Conclusión:** la ampliación **sí** agrego NPCs y recursos al área nueva (por eso no es «ampliar para hacerlo grande»). Pero la tercera pata de la condición —misiones— **no puede cumplirse con el modelo de datos actual**, porque las misiones no tienen dimensión espacial. | **Fundador** — el 2026-10-05 **APROBÓ la ampliación parcial** (2 de 3 patas del plan P1/P2/P3). Decisión relayed por el director (canal `agnes-3-flash/38`); registrada por agnes en `resolucion_pendiente_m152.md` §5 (Log 1313). **No es un análisis mío ni de agnes: es una decisión del fundador.** Las 3 tareas P1/P2/P3 quedan como deuda de **M22/M160/M167** (anclaje espacial de misiones), fuera de M152 | 2026-10-04 (verificación SB-03) / **2026-10-05 (aprobación del fundador)** |

---

## Cómo se añaden estas entradas (checklist de M152 §5 aplicado)

Cada entrada pasó los 8 ítems de `## Revisión de [Nombre de Decisión]` de `03-Diseno.md` §5. Los que
resultan **NO** marcados y su justificación:

### D-R1 — Desviación justificada

- ☑ ¿Respeta la filosofía cozy? — **Sí**: sin muerte, sin castigo irreversible, sin FOMO.
- ☑ ¿No castiga al jugador por jugar poco? — **Sí**: el combate es opcional y sin penalización.
- ☑ ¿No obliga a optimizar constantemente? — **Sí**: sin requisito de grind ni de optimización.
- ☑ ¿Aporta calidad, no solo cantidad? — **Sí**: 4 zonas y 2 jefes con fases son diseño, no relleno.
- ☑ ¿No sacrifica rendimiento? — **Sí**: la isla de combate es zona cargable (M61 tiene budgets).
- ☑ ¿Tiene propósito claro? — **Sí**: contenido opcional de endgame.
- ☑ ¿No depende de servicios externos sin fallback? — **Sí**: todo local.
- ☑ ¿No introduce dependencia crítica de una sola persona? — **Sí**.
- **La casilla que se desmarca:** *«¿Esta decisión no castiga / no introduce violencia?»* → el
  principio **«Sin combate por convención»** de `02-Vision` §1. **Desviación acotada y
  justificada** por el argumento de no letalidad de arriba.

### D-R2 — Desviación PARCIAL — **APROBADA por el fundador el 2026-10-05**

- ☑ ¿Aporta calidad, no cantidad? — **Sí**: el área nueva tiene contenido real (fauna, recursos,
  vegetación) en vez de superficie vacía.
- ☑ ¿No sacrifica rendimiento? — **Sí**: el rework vino con budgets e instanciado (M61, M50).
- **Las casillas que se desmarcan:**
  - *«¿Aporta calidad, no solo cantidad?»* — se marca **a medias**: hay contenido, pero las
    misiones siguen sin anclaje espacial, así que la profundidad narrativa no se aprovecha.
  - *«No ampliar el mapa solamente para hacerlo grande»* → la condición del Ejemplo 3 **se cumple
    en 2 de 3 patas**. **Desviación parcial**, con plan de cierre pendiente.

---


> **Sincronización (2026-10-05).** Este registro decía «PENDIENTE de aprobación» mientras
> `05-Checklist.md` (marca `[x]`) y `resolucion_pendiente_m152.md` §5 (agnes, Log 1313) ya lo
> tenían cerrado por decisión del fundador. **Dos fuentes de verdad del mismo módulo
> contradiciéndose** — el mismo patrón de drift que reporté en 14 `05-Checklist.md` (SB-02). Lo
> corrijo aquí, que es el archivo que creé en SB-04 y del que soy responsable.
> **Gobernanza:** el cierre es **del fundador**, no un análisis. Agnes lo dejó explícito y está
> bien que lo esté: simular aprobación sería peor que dejar el `[?]`.

## Tareas de plan pendientes que surgen de este registro

| # | Tarea | Origen | Dueño sugerido |
|---|---|---|---|
| P1 (**ABIERTA**) | **Anclar espacialmente M22** (`historia_principal.json`): agregar `ubicacion_id` o coordenadas a los nodos de misión, referenciando el catálogo M160 | D-R2 | M22 / M160 / M167 |
| P2 (**ABIERTA**) | **Anclar espacialmente M160**: los 39 `LOC-*` de `ubicaciones_loc.json` y los 9 `.tres` de `data/locations/` no tienen posición; hay que decidir si se ancla al mundo o se declaran explícitamente «lógicos» | D-R2 | M160 / M160 iter 5 |
| P3 | **Limpiar `data/ubicaciones/ubicaciones.json`**: sus 10 entradas tienen coordenadas del **sistema viejo** (256,256 / 350,350 / 1024,256) que, con el centro nuevo, caen a **r = 2085..3338, todas en el agua** (la orilla termina en r ≈ 1700). **No tiene ningún consumidor** en `.gd` ni `.tscn` → es dato muerto. Decidir: migrar o borrar | Hallazgo de SB-03 | M160 / limpieza |

---

## Relación con el resto de la documentación de M152

- La **plantilla** de este archivo está en `03-Diseno.md` §5.
- El **proceso de revisión** está en `04-Codigo.md` §8.
- El checklist de los 8 ítems está en `05-Checklist.md` (Familia M) y en `03-Diseno.md` §5.
- Las 2 desviaciones fueron detectadas por SB-01 (Log 1270), escaladas por el director, decididas
  por el fundador el 2026-10-04, y registradas aquí por SB-04 (Log 1280).
- La verificación de la condición de D-R2 es SB-03 (Log 1278).

**Firma de este archivo:** **Modelo:** space-bunny-alpha · **Plataforma:** Kilo Code ·
**Fecha:** 2026-10-04 · **Logs:** 1278 (verificación) + 1280 (registro)