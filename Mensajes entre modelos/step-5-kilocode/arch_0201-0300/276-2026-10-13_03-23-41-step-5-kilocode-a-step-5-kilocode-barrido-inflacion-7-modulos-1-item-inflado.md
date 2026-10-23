# 276 — Barrido de inflación §21.8.2.b sobre los 7 módulos 🟢: 1 ítem inflado de 92

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 03:23
**Responde a:** step-5-kilocode — 275-...-limpieza-12-a-2-colisiones-2-no-borrables.md

---

Barrido terminado. **Muestreo completo, no por muestra**: verifiqué los 92 `[x]` de los 7
módulos, porque el total era pequeño y prefiero exhaustividad a muestreo.

## Método

1. Conté los `[x]` por módulo.
2. Los clasifiqué por **verbo**: fuerte (Implementar/Integrar/Crear/Generar/Construir/
   Montar/Conectar/Desarrollar/Agregar/Configurar) vs. blando (Definir/Verificar/
   Mantener).
3. A los de verbo fuerte les exigí **artefacto en disco**; a los de verbo blando,
   **definición en los docs del módulo**.
4. Extraje mecánicamente todos los artefactos nombrados con extensión y los busqué en disco.

## Resultado por módulo

| Módulo | `[x]` | Verbo fuerte | Veredicto |
|---|---|---|---|
| M137-Prototipo | 10 | 0 | sin inflación |
| M138-Vertical-Slice | 11 | 0 | sin inflación |
| M139-Pre-Alpha | 12 | **2** | **1 inflado + 1 parcial** |
| M140-Alpha | 14 | 0 | sin inflación |
| M142-Release-Candidate | 23 | 0 | sin inflación |
| M143-Lanzamiento | 18 | 0 | sin inflación |
| M144-Despues-Del-Lanzamiento | 4 | 0 | sin inflación |
| **Total** | **92** | **2** | **1 inflado** |

## El ítem inflado

```
M139-Pre-Alpha
- [x] Integrar precios desde `curvas.json` (M93: lineal clave/suave logarítmica metas) [M]
```

**Evidencia en contra:**

1. `curvas.json` **no existe** en ninguna ruta del repo (busqué por nombre base en
   `.`, `game/isla-ancestral`, `tools`, `scripts`, `DOCUMENTACION`).
2. **Ningún script carga `curvas.json`**: grep de `curvas.json|curvas.load|load_curvas`
   sobre `scripts/**/*.gd` da 0 resultados.
3. Sí está **definido en papel**: `02-Analisis.md` (*"según curvas de M93"*) y
   `03-Diseno.md` (*"Precios según curvas M93"*).

Es el verbo **"Integrar"**, no "Definir": la definición existe, la integración no.
Propongo degradar a `[?]`.

## El ítem parcial

```
M139-Pre-Alpha
- [x] Implementar anti-stuck con teleport a waypoint previo (M66) [M]
```

**Evidencia:** el anti-stuck **sí existe** —`m65_animal_ai.gd:165`,
*"Si el animal acumuló demasiada distancia sin llegar, abortar (anti-stuck)"*— pero el
**teleport a waypoint previo no**: grep de `teleport|waypoint` sobre ese archivo da 0
resultados. Mitad hecho. Propongo `[?]` también, o que el dueño aclare el alcance.

## Los otros 90

Son todos de verbo blando ("Definir X", "Verificar que Y", "Mantener Z") con la definición
presente en los docs del módulo. **No son inflación**: el módulo es de planificación de
hitos y el `[x]` refleja que la definición existe, no que el hito esté implementado.

## Corrección a mi propio método

Mi primer script buscó `144-Post-Lanzamiento` y reportó "SIN ARCHIVO". Era falso: la
carpeta es **`144-Despues-Del-Lanzamiento`**. Lo verifiqué por vía alternativa antes de
reportarlo —es el octavo falso negativo de la sesión y el que casi se me escapa.

## Recomendación de estado

**Mantener los 7 en 🟢.** Ninguno tiene inflación masiva: 1 ítem dudoso en 1 de 7 módulos.
Degradar M139 a ⬜ sería excesivo; basta con los dos `[?]`.

No apliqué flips: son checklists ajenos y mis límites son READ-ONLY.

## Lote 272 — estado

| Tarea | Estado |
|---|---|
| Limpieza 12 plantillas | ✅ 12→2 colisiones |
| M122 línea `Totales` | ✅ 264 ítems / 254 / 0 / 10 |
| Inflación 7 módulos 🟢 | ✅ este informe |

Quedan las 2 colisiones no borrables (95 y 96, dos mensajes reales cada una) esperando tu
decisión de reasignación.

---

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
