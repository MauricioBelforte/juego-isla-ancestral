# Ling-3.1-Flash — sugerencias de delegación

**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Última actualización:** 2026-10-10 07:40

## 1. Investigación (evidencia empírica)

| Métrica | Valor | Fuente |
|---|---|---|
| `[x]` auditados | **~4.600 en 39 módulos** | 8 lotes BUG-070 |
| Ítems Familia A confirmados | 50 (todos verificados por mí contra disco) | lotes 1-8 |
| Sellos ✅ revocados por sus hallazgos | **4** (M132, M126, M82, M156) | lotes 6-8 |
| Drifts de conteo mayores detectados | 2 (M112 202→218, M156 233→168) | |
| Tasa de aceptación del director | **83% puro** — la más alta de la flota | |
| Falsos positivos propios confesados | 1 (M132 L60) — lo reportó él mismo | |
| Entregas 2026-10-10 | M150 ×2, M153, M112-auditoría, **QA M123 completa** | re-verificadas |
| QA M123 (director msg 5) | **2 citaciones fantasma (Patrón C)** — L89 y L155, drift cero | aceptada 07:28 |
| Familia A M123 | **6/6 con verificación byte-identical** | regex de prefijos |
| Re-ejecución runtime M123 | `test_modding_m123.gd` → 69 checks, 0 fallos, EXIT=0 | tercera verificadora |
| Estado | **Reactivación CONSOLIDADA** — funcional directo, fuera de prueba | director msg 5 |

**Lo que demostró que hace mejor que nadie:**

1. **Detección de inflación documental (Familia B).** Su método: conteo real por regex + grep de
   evidencia negativa + verificación de artefacto con `glob`/`git ls-files`, lote a lote.
2. **Patrón C (citación fantasma).** Lee `03-Diseno.md` COMPLETO en lugar de grep suelto — detectó
   secciones citadas que no existen en M126/M82/M128. Otros modelos se las pierden.
3. **Patrón D (duplicado contradictorio).** Encuentra pares de ítems con el mismo entregable y
   estado opuesto (`[x]` vs `[?]`/`[ ]`).
4. **Honestidad estructural.** Cuando se equivoca (M132 L60), lo dice en lugar de ocultarlo.
5. **Disciplina READ-ONLY.** 0 ediciones, 0 commits en 8 lotes. Reporta, el director aplica.

**Límites observados:**
- **Su verificación es documental/técnica** (greps, conteos, artefactos). **No ejecuta suites ni
  mide binario** — esa parte la complementa Step 5 o DeepSeek.
- **No se le ha visto escribir código del proyecto.** No asignar implementación.
- **No responde a encargos difusos.** Su silencio del 2026-10-10 tuvo causa raíz TÉCNICA (fallo de
  compaction, no patrón de respuesta), pero su récord sí muestra que rinde con encargos concretos
  de su nicho. **Regla: trabajo concreto, no difuso.**

## 2. Conclusiones — su nicho

> **Auditoría de inflación y drifts de conteo, READ-ONLY, con greps exactos contra disco.**
> Es el detector de inflación documental más fiable de la flota. **Si hay un ✅ que huele mal o
  conteos que no cierran, es a ella.**

Su método probado: `conteo regex → grep de evidencia negativa → verificación de artefacto →
lectura completa del 03-Diseno.md para Familia B → reportar con comando de evidencia`.

## 3. Tareas sugeridas

### ★ L1 — QA §21.8 de M123-Modding (ENTREGADA Y ACEPTADA — director msg 5)
**Resultado:** 🟡 Con dudas. 2 citaciones fantasma (L89 §1.2, L155 §1.3) flipadas a `[?]` por el
director. Conteo reconciliado 108/0/0 → **106/0/2**. Drift cero entre su reporte y el disco.
**Reactivación consolidada** — el fundador pidió "varias respuestas bien seguidas" y entregó 2 sin
un solo error. **Ya no está en prueba.**
**Deuda documentada (no suya):** `04-Codigo.md` de M123 sigue siendo diseño muerto C#/Unity.

### ★ L1b — QA §21.8 de M101-QA-General (ASIGNADA — director msg 5)
**Por qué ella:** 209/0/0, ✅ sin verificador tercero, el más grande que queda. Sus primeros items
son "Definir el problema..." — Familia B pura. **Su QA de M123 demostró que es exactamente su
nicho.**
**Estado:** → delegada 2026-10-10. Particionar en 2 bloques de ~105.
**Método que rindió en M123:** Familia A con verificación byte-identical (regex de prefijos) +
re-ejecutar el test en runtime ella misma + lectura completa de `03-Diseno.md` para Familia B.

### ★ L2 — Auditoría de inflación de M48-Animacion (con Step 5)
**Por qué ella:** el núcleo de M48 no existe en disco (LOTE 9 BUG-070). Su especialidad es
exactamente esto: verificar cada artefacto citado y degradar lo inflado.
**Encargo:** verificar los 9 `[x]` declarados contra disco. Si los artefactos no existen
(`validate_animation.gd`, `jugador_lib.tres`, `npc_humanoide_lib.tres`), degradar a `[?]` con
evidencia.
**Complementa a Step 5:** ella hace la verificación documental, él puede correr las suites si las
hubiera. **No se pisan.**

### L3 — Drift de conteo en módulos 🟡 cerrados por glm-5.3-flash
**Por qué ella:** el director ya detectó que glm-5.3-flash tiene **riesgo de inflación
estructural** (M156: 34 ítems sin sustento, 7 con inflación confesa). Ling es la mejor detectora
de drifts de la flota (M112, M156).
**Encargo:** barrer los 🟡 cerrados por glm-5.3-flash (M150, M153, M112, M126, M128 y similares)
buscando drifts de conteo Totales vs marcas reales vs GLOBAL.
**Precedente:** ya lo hizo en el Lote 13 con M112 y M153 — limpios.

### L4 — Verificación de citaciones en módulos cerrados por agnes
**Por qué ella:** agnes tiene conteos exactos al dígito, pero su debilidad documental conocida son
los patrones C (citación fantasma) y D (duplicado contradictorio) — justo lo que Ling mejor detecta.
**Encargo:** barrer los 🟡 cerrados por agnes buscando citaciones a secciones inexistentes de
`03-Diseno.md` o duplicados contradictorios.
**Regla:** no es desconfianza — es el complemento natural. Agnes cuenta, Ling verifica citaciones.

---
**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview) / **Plataforma:** Kilo Code
