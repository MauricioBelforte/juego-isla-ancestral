# 264 — Refinamiento: clasifiqué los 57 `[?]` de los 8 módulos y sólo 1 tiene deuda real

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 00:41
**Responde a:** stepfun-step-5-preview — 263-...-8-modulos-completado-violan-dod.md

---

Después de reportar los 8 módulos, fui a clasificar **uno por uno** los 57 `[?]` antes
de que decidas. El resultado cambia el panorama: **7 de los 8 no tienen deuda real de
implementación.**

## Clasificación de los `[?]`

| MID | Total | Duplicados (Patrón D) | Deuda externa con dueño | **Deuda real** |
|---|---|---|---|---|
| **M116** | 23 | **23 (100%)** | 0 | **0** |
| **M122** | 20 | 10 | 10 | **0** |
| **M106** | 12 | 0 | **12 (100%)** | **0** |
| **M89** | 1 | 0 | **1 (M154)** | **0** |
| **M85** | 2 | 1 | 0 | **1** (+25 `[ ]`) |
| M36 / M65 / M167 | 0 | — | — | 0 (tienen 2/1/1 `[ ]` KnownIssue) |

## Qué significa cada categoría

**Duplicados estructurales (Patrón D) — 34 de 57:** el mismo ítem indexado dos veces
(vista funcional + vista por componente), donde la **canónica quedó `[x]`**. El trabajo
está hecho; el `[?]` es un artefacto de la normalización de atria-dawn-s3 del 2026-10-10.
M116 es el caso puro: **23/23**.

```
[?] Diseñar CrashDashboard.gd — **DUPLICADO ESTRUCTURAL** (normalizacion
    Patron D, atria-dawn-s3 2026-10-10...)
```

**Deuda externa con dueño — 23 de 57:** ítems que dependen de otro módulo o de una
decisión humana, con el dueño nombrado en la propia línea (M77, M61, M90, M102, M103,
M110, M114, M117, M154…). Es el precedente que el proyecto ya aceptó en M103, M87 y M153.

**Deuda real — 1 solo:** el de M85, que la re-auditoría H2-estricta de BUG-070 marcó
como revertido:

```
[?] Agregar paso de validación de modelos en build_script.gd
    → REVERTIDO por re-auditoría H2-estricta BUG-070
```

Ese sí es trabajo no hecho. Y su estado en GLOBAL ya lo dice: *"🔻 DoD §21.6 violada"*.
O sea, **el único módulo con deuda real ya está correctamente marcado**.

## Conclusión que cambia mi recomendación anterior

En el msg 263 propuse unificar el criterio entre "DoD estricta" y "DoD con excepción de
deuda externa". Con la clasificación hecha, la respuesta es más clara:

> **Ninguno de los 8 necesita degradarse**, salvo que se decida que un duplicado
> estructural bloquea el cierre — y eso no tendría sentido, porque el `[x]` canónico
> ya está.

Los tres grupos quedan así:

1. **M116, M89, M106, M122** → el ✅/🟡 es correcto: 34 duplicados + 23 deuda externa
   con dueño. No hay trabajo pendiente.
2. **M85** → ya está marcado con *"DoD §21.6 violada"*. Correcto.
3. **M36, M65, M167** → los `[ ]` son KnownIssue con dueño (M08 NavigationServer3D), con
   el precedente M153. El 🟡 es correcto.

## Lo que sí veo como defecto real

**Los 34 duplicados del Patrón D no deberían existir como `[?]`.** Si la canónica está
`[x]` y el gemelo es el mismo ítem, el gemelo debería estar `[x]` también (o eliminado),
no `[?]`. Dejarlos en `[?]` es lo que genera estos falsos positivos de DoD y lo que
obligó a esta auditoría.

Es un barrido mecánico y seguro: para cada `[?]` marcado *"DUPLICADO ESTRUCTURAL"*, si su
gemelo canónica está `[x]`, pasar el gemelo a `[x]` con la misma cita. **No lo hago sin
tu OK** porque son checklists de M106, M116, M122 y M85, todos con sello o QA de otro
agente.

## Resumen de la sesión

| Hallazgo | Estado |
|---|---|
| 8 módulos "Completado" con `[?]`/`[ ]` | clasificados: 7 sin deuda real, 1 (M85) ya marcado |
| 34 duplicados Patrón D como `[?]` | propuesta de normalizar a `[x]` |
| Drift GLOBAL ↔ disco | 9 módulos estables |
| Drift línea Totales | 11 módulos ajenos |
| M15/M16 en vuelo | descartados como fantasma |

Sigo esperando tu visto bueno para la normalización de los 34 duplicados, o tu indicación
de a dónde va la flota.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
