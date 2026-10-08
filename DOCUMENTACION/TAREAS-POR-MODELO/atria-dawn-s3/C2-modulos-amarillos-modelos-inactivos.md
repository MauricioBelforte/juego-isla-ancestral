# Candidato 2 — Módulos 🟡 de modelos inactivos: ¿colgados o terminados?

**Modelo:** Atria-Dawn-Preview (sesión s3)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-07
**Tarea:** candidato 2 del plan de delegación (mensaje 13 del canal)
**Alcance:** read-only sobre `CHECKLIST-GLOBAL.md` y `Logs/`. Método A.

---

## Resumen

**88 módulos 🟡 sin actividad desde septiembre** (de 117 🟡 totales; 29 tuvieron actividad en octubre). La gran mayoría **no son "casi terminados"** — solo 5 están a ≤2 ítems de cerrar.

## Top 5: colgados a un paso de cerrar

| MID | Módulo | Progreso | Falta | Agente | Última actividad | Veredicto |
|---|---|---|---|---|---|---|
| **149** | Nombres-Y-Nomenclatura | 99/100 | 1 | — | 2026-09-15 | 3 `[?]` requieren humanos/M111 — **no es deuda técnica** |
| **167** | Isla-Raiz | 113/114 | 1 | Step 3.7 Flash | 2026-08-29 | drift doc↔código (radio 256 vs 2560) — **deuda real de doc** |
| **39** | Tiendas | 180/181 | 1 | glm-5.3-flash | 2026-09-17 | sobre-marca revertida: test 1000 tx NO implementado — **deuda real de test** |
| **65** | Animales-IA | 89/90 | 1 | — | 2026-09-25 | BUG-080 resuelto (Log 1154); el `[ ]` es dep externa M08 |
| **36** | Fauna | 226/228 | 2 | — | 2026-09-18 | 2 `[ ]` KnownIssue con dueño |

### Lectura sobre M39 (el caso que citó el director)

M39 **no es un módulo abandonado**: hy3 hizo re-verify independiente el 2026-10-04 (Log 1269, commit b163274), 18/19 ítems volteados verificados, 3 suites en verde. El único `[ ]` es **deuda real**: la "Prueba de rendimiento: 1000 transacciones" nunca se implementó (el test existente es funcional, de 1 compra/venta). La columna "Última actividad" del GLOBAL quedó en 2026-09-17 — **stale**, no refleja la re-verify de octubre.

**Corrección al framing del director:** "colgados o terminados" es una falsa dicotomía aquí. M39 es **casi terminado con una deuda real y conocida** de 1 ítem, cuyo dueño es glm-5.3-flash (inactivo desde el 17 de septiembre). El bloqueo no es de QA — es de implementación.

## Clasificación de los 88 colgados

| Categoría | Cantidad | Característica |
|---|---:|---|
| A ≤5 ítems de cerrar | **9** | retorno inmediato (M149/167/39/65/36/118/9/85/87) |
| B 6–20 ítems | 12 | retorno medio |
| C 21–60 ítems | 22 | trabajo sustancial |
| D >60 ítems (no iniciados) | **45** | 0–20% implementado; "colgado" = nunca arrancó |

**El 51% de los colgados (45/88) son módulos que nunca despegaron** — M74 Eventos (95/285), M72 Logros (1/185), M90 Configuración Gráfica (69/249), M16 Crafting (43/208). Llamarlos "colgados" es engañoso: son **no iniciados**, y su prioridad es otra.

## Concentración por modelo inactivo

| Modelo inactivo | 🟡 colgados | Notables |
|---|---:|---|
| deepseek-v4-flash (y variantes vision) | ~19 | M105, M156, M40, M48 |
| GLM-5.3 Flash | ~10 | M22, M31, M34, M35, M77 (0/130) |
| Step 3.7 Flash | ~6 | M16, M23, M108, M109, M167, M122 |
| agnes-2.5-flash (descatalogada) | ~6 | M46 (0/110), M76, M73, M69, M85 |
| Hy4 | ~6 | M57, M56, M161, M137-143 (fases) |
| mimo-v2.5 | ~3 | M64, M160 |
| glm-5.3-flash | ~3 | M39, M92, M18 |
| sin agente (—) | ~30 | M149, M9, M12, M15, M26, M30... |

**Patrón:** deepseek-v4-flash y GLM-5.3 Flash concentran la mayor deuda histórica. Los 30 sin agente son los más fáciles de reasignar — no requieren negociar con un modelo inactivo.

## Recomendación

1. **No atacar los 88.** El retorno real está en los **9 de categoría A**.
2. **M149 y M65 no necesitan implementación** — sus ítems faltantes son dependencias externas o decisiones humanas. Candidatos a flip a ✅ con DoD KnownIssue (precedente M153), si el director lo decide.
3. **M39 y M167 sí necesitan trabajo**: 1 ítem de test real (M39) y 1 de reconciliación doc↔código (M167). Asignables a Ling 3.1 Flash bajo mi supervisión, o a DeepSeek si vuelve a estar disponible.
4. **Los 45 "no iniciados"** deberían reclasificarse del todo — no son deuda, son backlog sin empezar. Marcarlos como `⬜` sería más honesto que `🟡`, pero eso es decisión del director (read-only para mí).

## Restricciones respetadas

- `CHECKLIST-GLOBAL.md`: read-only.
- Sin commit, sin push.
- Sin tocar `quality.yml`, `interaction_manager.gd`, `service_registry.gd`, `bootstrap.gd`.

## Notas de método

- El conteo de "colgados" usa la columna **Última actividad** (col 10) del GLOBAL, no las fechas dentro de las Notas.
- Filtré por emoji 🟡 **en la columna Estado** (col 3) — una primera iteración tuvo falsos positivos porque el emoji también aparece dentro del texto de Notas ("mantiene 🟡"), e.g. M145/M146 que en realidad están ✅.
- El veredicto por módulo se basó en la nota del GLOBAL; no abrí los `05-Checklist.md` individuales de los 88.
