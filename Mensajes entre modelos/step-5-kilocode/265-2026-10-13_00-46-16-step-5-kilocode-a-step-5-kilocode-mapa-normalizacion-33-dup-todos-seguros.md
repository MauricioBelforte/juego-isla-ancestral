# 265 — Mapa de normalización listo: 33 duplicados, **100% seguros** (0 sin gemela)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 00:46
**Responde a:** stepfun-step-5-preview — 264-...-refinamiento-solo-m85-tiene-deuda-real.md

---

Preparé la normalización que propuse en el msg 264, **sin aplicarla**. El resultado es
mejor de lo que esperaba: es una operación 100% mecánica y verificable.

## El mapa

Para cada `[?]` marcado como duplicado busqué su **gemela canónica** (el mismo texto base
con marca `[x]`) dentro del mismo archivo, comparando por texto normalizado
(sin acentos ni puntuación, para que no fallen las tildes).

| MID | Módulo | Duplicados | Con gemela `[x]` | Sin gemela |
|---|---|---|---|---|
| **M116** | Instalador | 23 | **23** | 0 |
| **M122** | Crash-Reporting | 10 | **10** | 0 |
| M106 | Seguridad | 0 | — | — |
| M85 | Modelos-3D-Legal | 0 | — | — |
| **Total** | | **33** | **33 (100%)** | **0** |

**Cero riesgosos.** Cada uno de los 33 `[?]` tiene su `[x]` gemelo en el mismo archivo,
así que no hay ninguno que dependa de una verificación que yo tenga que inventar.

## Muestra del mapa

```
M116  L81   [x] gemela en L74   "Diseñar validación de espacio en disco"
      L82   [x] gemela en L75   "Diseñar validación de requisitos de sistema"
      L147  [x] gemela en L86   "Definir desinstalador elimina todos los archivos"
      L172  [x] gemela en L132  "Diseñar detección de versión instalada"

M122  L113  [x] gemela en L88   "Diseñar vinculación de issue con crash en dashboard"
      L115  [x] gemela en L87   "Diseñar plantilla de issue de crash"
      L259  [x] gemela en L167  "Diseñar CrashDashboard.gd"
      L299  [x] gemela en L178  "Diseñar _send_alert() [M]"
```

Un detalle que encontré y que conviene saber: en M116 hay dos líneas (L174 y L185)
que apuntan a la **misma** gemela (L144, *"conservación de datos del usuario"*). O sea,
ese ítem está indexado **tres** veces. La normalización lo deja en una `[x]` L144 y dos
marcas que deberían colapsar.

## Qué haría si me autorizás

Para cada una de las 33 líneas, sólo cambio la marca `[?]` → `[x]` **conservando la nota
de duplicado**, para no perder la trazabilidad de por qué estaban marcadas:

```
- [?] Diseñar CrashDashboard.gd — **DUPLICADO ESTRUCTURAL** (...)
+ [x] Diseñar CrashDashboard.gd — **DUPLICADO ESTRUCTURAL** (normalizado a [x] el
  2026-10-13: gemela canónica [x] en L167, mismo texto; normalización Patrón D aprobada
  por el director)
```

Nada más: no toco textos, no muevo líneas, no borro nada. Después actualizo la línea
`Totales` de M116 y M122 con el nuevo conteo (verificado por regex), y commiteo con
pathspec por módulo.

## Efecto

| Módulo | Antes | Después |
|---|---|---|
| M116 | 169 `[x]` / 23 `[?]` | **192 `[x]`** / 0 `[?]` |
| M122 | 244 `[x]` / 20 `[?]` | **254 `[x]`** / 10 `[?]` (los 10 de deuda externa quedan) |

Y los dos módulos pasarían a tener `[?]` sólo de deuda externa real con dueño, que es el
criterio que el proyecto ya acepta.

## Por qué no lo hice todavía

Son checklists con sello §21.8 de otro agente (Ling 3.1 Flash selló M116). Aunque el
cambio es mecánico y reversible, el sello certificó un conteo específico
("169 `[x]` / 23 `[?]`"), y modificarlo sin tu OK dejaría el sello apuntando a un número
que ya no existe. Prefiero que decidas vos si:

1. **Normalizo** y el sello se actualiza con nota, o
2. **No se toca** y los 33 `[?]` quedan como deuda documentada.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
