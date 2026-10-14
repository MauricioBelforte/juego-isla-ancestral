# Log 1851: M162-Diálogos-Contextuales-De-NPCs — auditoría completa de 40 `[?]` (0 promociones)

**Fecha:** 2026-10-14
**Hora:** 23:40
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Auditoría de los 40 `[?]` de M162-Diálogos-Contextuales-De-NPCs (encargo del director mimo,
cola M31 → M71 → M162). Método Patrón D. Commit `a525735`.

## Resultado: 0 promociones, 40 anotados

Evidencia base verificada en disco:
- `data/dialogues/contextual/` — 367 grafos JSON: SALUDO 228, HISTORIA 109, AMISTAD 60,
  NOCHE 23, MISION 19, AMBIENTE 11; 23 NPCs en 5 islas (riz 8, aur/cor/cen 5 c/u).
- `scripts/dialogos/contextual_dialogue_manager.gd` — selector con dimensiones
  flag_capitulo (M22, 0-7), estacion/hora/es_de_dia (M29), amistad_<slug> (M20).
- Tests: `test_contextual_dialogue_m162.gd`, `test_m162_integracion_m19.gd`,
  `test_m162_robustez.gd`.

## Por qué 0 promociones

| Concepto del ítem | Estado real |
|---|---|
| Menciones de M160 (peces, minerales, mina, templo, ubicaciones) | M160 no tiene datos en disco (`data/m160` no existe) |
| Menciones de M158 (forja, hierro, encantamientos) | M158 no tiene datos en disco (`data/m158` no existe) |
| Menciones escasas | arrecife 3/367, cobre 4/367, ruta 3/367, forja 4/367, peligro 6/367, pez 2/367, precio 0/367 |
| Coherencia por capítulo (M22) | **Respaldada**: flag_capitulo alimenta el selector y hay grafos por capítulo |
| Franjas horarias (M29) | **Parcial**: dimensión hora existe, 23 grafos de noche generados; franjas completas no definidas |

## Coherencia

M162 está **bien implementado en su núcleo** (367 grafos, selector contextual con 3 dimensiones
cross-modulo, 3 tests). Los 40 `[?]` son de **coherencia cross-modulo con datos que no existen**
(M160, M158) y de contenido específico no verificado nodo por nodo.

## Archivos Modificados

- `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md`
  (40 `[?]` anotados; commit `a525735`)
