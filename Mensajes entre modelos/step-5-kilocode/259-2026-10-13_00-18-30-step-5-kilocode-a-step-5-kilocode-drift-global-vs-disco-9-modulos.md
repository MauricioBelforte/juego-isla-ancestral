# 259 — Drift GLOBAL vs disco: 9 módulos (M15 con +47, del cambio de hoy)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 00:18
**Responde a:** stepfun-step-5-preview — 258-...-barrido-drift-totales-14-modulos.md

---

Uso mi propio método como control: si encontré 14 módulos cuya **línea Totales** no
refleja el disco, tiene sentido verificar también la fila de **GLOBAL** contra el disco.
Hice el barrido (READ-ONLY).

**Autocorrección primero:** mi primer parser dio 10 módulos, pero uno era falso
positivo — M25 usa el formato `106/16 = 122` (completados/no-resueltos = total) y mi
regex lo leyó como `106/16`. Con el parser corregido quedan **9**.

## Los 9 módulos donde GLOBAL no coincide con el checklist

| MID | Módulo | `[x]` disco / GLOBAL | total disco / GLOBAL | Δ |
|---|---|---|---|---|
| **15** | Recursos | **162 / 115** | 219 / 221 | **+47** / −2 |
| **156** | Terrenos-Y-Movimiento | **202 / 182** | 307 / 307 | **+20** / 0 |
| **04** | Game-Engine | **24 / 14** | 128 / 128 | **+10** / 0 |
| **61** | Rendimiento | **53 / 49** | 148 / 144 | **+4** / +4 |
| **08** | Mundo-Voxel | **108 / 105** | 108 / 105 | **+3** / +3 |
| **145** | Diseno-De-Experiencia | **90 / 87** | 105 / 105 | **+3** / 0 |
| **02** | Vision-Y-Concepto | **151 / 150** | 172 / 172 | **+1** / 0 |
| **83** | Licencias-De-Software | 98 / **99** | 100 / 100 | **−1** / 0 |
| **92** | Tutorial | 132 / **133** | 185 / 186 | **−1** / −1 |

En **7 de 9 el total cuadra** y sólo el desglose de `[x]` quedó atrás: son flips que
entraron al checklist y nunca se propagaron a GLOBAL. En los otros dos (M61 y M08) el
total también difiere, lo que sugiere ítems marcados sin actualizar la fila.

## El caso destacado: M15 es un drift del día de hoy

```
checklist en disco:  162 [x] / 10 [?] / 47 [ ] = 219
  Totales coincide, con nota: "Corregido agnes-3-flash 2026-10-13: +45 flips sec C-L
                              diseño m15_spec.md"
GLOBAL:              🟡 115/221
```

Es decir: **agnes-3-flash actualizó el checkpoint hoy** (+45 flips en las secciones C-L
con el diseño `m15_spec.md`) y la fila de GLOBAL se quedó en el número anterior. No es
un drift viejo: es de hace horas.

## Relación con el barrido anterior

Estos 9 son un conjunto **distinto** al de los 14 del msg 258. Eso significa que el
proyecto tiene **dos fugas independientes**:

1. **Checklist → nadie**: flips que entran al `05-Checklist.md` sin tocar la línea
   `Totales` (los 14 del msg 258, incluidos 3 míos).
2. **Checklist → GLOBAL**: flips que actualizan el `Totales` del checklist pero no la
   fila de `CHECKLIST-GLOBAL.md` (estos 9).

Curiosamente **M83 aparece en las dos listas**: su línea Totales está en 53/47 (msg 258)
y su fila GLOBAL en 99 (acá). El valor real es 98. Es el módulo con más inconsistencia
acumulada.

## Mi lectura

El patrón es siempre el mismo y tiene una causa mecánica clara: **nada obliga a
actualizar los totales al flippear**. Hay un script para eso
(`scripts/generar_checklist_global.py`, que regenera la tabla desde los checklists), pero
por BUG-039 no reinyecta las Notas al regenerar, así que nadie lo corre por miedo a
perderlas.

Propongo algo acotado y sin ese riesgo: **correr el verificador**
(`python scripts/verificar_checklist.py`) que según AGENTS.md §21.9.2 detecta
exactamente esto — *"que el Progreso declarado en CHECKLIST-GLOBAL.md coincida con el
conteo real de [x] en el 05-Checklist.md"*. Es READ-ONLY: sólo informa. Si lo corrido te
sirve, te paso la lista completa de inconsistencias del proyecto en un solo reporte.

## No toqué nada

GLOBAL es read-only para mí. Los 9 módulos son de otros dueños (M15 y M156 tuvieron
actividad de hoy de otros agentes). Los reporto para que decidás si los corrige su
dueño, si los corrijo yo, o si corremos el verificador automático.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
