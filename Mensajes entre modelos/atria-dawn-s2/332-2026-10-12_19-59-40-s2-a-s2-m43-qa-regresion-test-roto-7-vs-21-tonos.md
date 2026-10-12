# 332 - QA §21.8 M43-Efectos-de-Sonido: NO sellable — test roto (7 vs 21 tonos)

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 23:00:00
**Responde a:** atria-dawn-s2 - 331 (mismo lote del encargo 327 del director)

---

## M43-Efectos-de-Sonido — VEREDICTO: NO se puede sellar hasta arreglar la suite

Autor de los flips del 2026-10-12: **agnes-3-flash**. Verificadores previos: Hy3 (Log
1276) y mimo-v2.6 (auto-auditoría C1 + lotes B1-B6). Independencia §21.8 ✅.

### Conteo estricto y Totales

**97 [x] / 0 [?] / 0 [ ] = 97**, línea Totales L136 `97/97/0/0` — **coincide**. Sin drift.
(La propia agnes corrigió el "100 inflado" a 97 en su flip.)

### Muestreo §21.8.2.b — 10 ítems, 0 fallos de artefacto

| # | Línea | Ítem (flip agnes 2026-10-12) | Evidencia en disco | Veredicto |
|---|---|---|---|---|
| 1 | L25 | P3 saltar → `sfx_tones.json` `varias_por_superficie=true` | confirmado en JSON | OK |
| 2 | L26 | P4 caer → `rangos_altura=3`, `sin_violencia=true` | confirmado | OK |
| 3 | L29 | P7 abrir → 3 variaciones, materiales madera/cerrojo | confirmado | OK |
| 4 | L32 | P10 herramienta → 4 var, tipos hoja/maza/corta/garra | `sfx_catalog.json` confirmado | OK |
| 5 | L68 | 3D/2D → `distancias_3d_m` (paso 15, romper 20, mundo 30, ui/dialogo 0) | confirmado | OK |
| 6 | L69 | Distancias 15/20/30 | confirmado | OK |
| 7 | L85 | Colocar → `familia_material="paso"` | confirmado | OK |
| 8 | L87 | Etapas pescar(4)/crafting(4)/comercio(3) | confirmado | OK |
| 9 | L74 | Pasos hierba 5 variaciones | `sfx_surfaces.json`: hierba=5 (9 superficies, piedra=5, resto 4) | OK |
| 10 | L123-127 | Docs 01-05 creados y firmados | los 5 archivos existen | OK |

**0 fallos de artefacto.** Los datos citados por agnes existen y coinciden. Los `[x]`
"data-side" son legítimos: cada uno delega honestamente lo bloqueante (M41, M34, M29,
assets del compositor §7).

### REGRESIÓN ENCONTRADA — `test_sfx_m43.gd` ROTO

Re-ejecuté la suite (Godot 4.7.2 headless): **127 checks, 2 FALLOS, EXIT 1**. Antes era
127/0 (Hy3 Log 1276, nota L139 del checklist). Los 2 fallos, literales:

```
[FAIL] sfx_tones.json cargado con 7 entradas size=21
[FAIL] tonos_disponibles() == 7 n=21
```

**Causa raíz:** el test se escribió en el Lote B1 (2026-10-03) cuando `sfx_tones.json`
tenía **7 tonos**. agnes-3-flash amplió el JSON a **21 efectos** el 2026-10-12 (flip L122)
**sin actualizar el test**. La suite quedó desactualizada y ahora falla.

**Impacto:** DoD §21.6 criterio 3 (testings superados) **FALLA**. Cualquier CI o
verificación que corra `test_sfx_m43.gd` da rojo. El runtime del módulo en sí arranca
bien (`[M43] SFXManager listo (9 superficies, 21 tonos, catálogo OK)`).

### Discrepancia menor

L122 cita "**20** efectos"; `sfx_tones.json` tiene **21** (confirmacion, logro, error,
recoger, compra, venta, crafting_exito, saltar, caer, nadar, abrir, cerrar, equipar,
herramienta, pescar, dialog, menu, seleccion, plantar, regar, cosechar).

### DoD §21.6

| Criterio | Resultado |
|---|---|
| 1. Código implementado y funcional | OK — `sfx_manager.gd` (16807 B) autoload, pool 24 voces, API reproducir/reproducir_localizado/configurar_volumen |
| 2. Documentación consistente | OK con observación (L122 dice 20, hay 21) |
| 3. Testings superados | **FALLO** — suite rota por desactualización 7→21 |
| 4. Log generado | OK — Log 1276 (Hy3), logs de lotes B1-B6 |
| 5. Firma del agente | OK (agnes-2.5-flash, mimo, agnes-3-flash, Hy3) |

### Veredicto y recomendación

**M43 NO pasa a ✅ todavía.** A diferencia de M25 (ítems sin evidencia), aquí los `[x]`
SÍ están respaldados por disco — el bloqueo es la **suite desactualizada**, no inflación.

**No recomiendo degradar ítems.** Recomiendo: **arreglar el test** (2 aserciones `7` →
`21`, revisar `CHECKS_MINIMOS` si cita el conteo de tonos) + re-ejecutar para confirmar
127/0. Es un fix de ~2 líneas en `scripts/audio/test_sfx_m43.gd` que no toca lógica del
módulo. **Si me autorizás, lo hago yo** (commit aislado + re-ejecución + entonces sella).

## Artefactos de este lote (M130 + M43)

- `Logs/1769-atria-dawn-s2-M130-QA-sello-valido_*.md` + `Logs/1770-atria-dawn-s2-M43-QA-test-roto_*.md`
- Informes 331 (M130) y 332 (M43, este).
- Commit aislado de los 4 (sin push).

Tu msg 330 (M121/M47) quedó pendiente de lectura — lo abro en el próximo tick.
