# Log 1807: M139 dos ítems degradados a [?] por evidencia inexistente

**Fecha:** 2026-10-12
**Hora:** 19:50
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Barrido de inflación §21.8.2.b sobre los 7 módulos 🟢 con `[x]` (M137, M138, M139,
M140, M142, M143, M144), encargado por el director mimo (msg 272/273). De 92 `[x]`
revisados, **2 resultaron inflados**, ambos en M139-Pre-Alpha.

## Cambios Realizados

### M139-Pre-Alpha: 12 [x] → 10 [x] / 2 [?]

**Ítem degradado 1 — anti-stuck con teleport a waypoint previo (M66) [M]**

- Evidencia a favor: el anti-stuck **sí existe** —
  `scripts/ia_npc/m65_animal_ai.gd:165`, comentario *"Si el animal acumuló demasiada
  distancia sin llegar, abortar (anti-stuck)"*.
- Evidencia en contra: el **teleport a waypoint previo no existe** — grep de
  `teleport|waypoint` sobre ese archivo da 0 resultados.
- Veredicto: mitad hecho. Degradado a `[?]`.

**Ítem degradado 2 — Integrar precios desde `curvas.json` (M93) [M]**

- Evidencia en contra: `curvas.json` **no existe** en ninguna ruta del repo (búsqueda
  por nombre base en `.`, `game/isla-ancestral`, `tools`, `scripts`, `DOCUMENTACION`).
- Ningún script lo carga: grep de `curvas.json|curvas.load|load_curvas` sobre
  `scripts/**/*.gd` da 0 resultados.
- Sólo está definido en papel (`02-Analisis.md`, `03-Diseno.md`).
- Veredicto: el verbo es "Integrar", no "Definir". Degradado a `[?]`.

### Los otros 6 módulos: sin inflación

M137 (10 [x]), M138 (11), M140 (14), M142 (23), M143 (18), M144 (4). Todos de verbo
blando ("Definir X", "Verificar que Y") con la definición presente en los docs del
módulo. No son inflación: el `[x]` refleja que la definición existe, no que el hito
esté implementado.

## Archivos Modificados

- `DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md` — 2 flips `[x]`→`[?]` con
  cita a este log, y línea `Totales` corregida (12/130/0 → 10/130/2).

## Método y autocorrección

Mi primer script buscó `144-Post-Lanzamiento` y reportó "SIN ARCHIVO". Era falso: la
carpeta es `144-Despues-Del-Lanzamiento`. Verificado por vía alternativa antes de
reportarlo — octavo falso negativo de la sesión.

Autocrítica de muestreo: el barrido fue **exhaustivo** (92 de 92 `[x]`), no por
muestra, porque el total era pequeño.

---

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
