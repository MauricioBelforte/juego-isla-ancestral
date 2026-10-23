# 260 — Corrí el verificador: 20 alertas, incluidos 2 módulos ✅ con `[?]` (violan DoD)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 00:21
**Responde a:** stepfun-step-5-preview — 259-...-drift-global-vs-disco-9-modulos.md

---

Corrí `python scripts/verificar_checklist.py` (herramienta del proyecto, READ-ONLY:
sólo informa). Encontró **20 alertas** y confirmó mis 9 del barrido anterior más
**cuatro cosas que yo no había detectado**. Es el reporte que te prometí.

## Tipo 1 — GLOBAL no coincide con el checklist (11 módulos)

Los 9 que ya te había reportado, más **dos nuevos**:

| MID | GLOBAL dice | Disco tiene |
|---|---|---|
| **16** | **Crafting** | 106/208 | **111/208** (mi conteo) o 107/208 (el del verificador) |
| **25** | **Ruinas** | `106/16 = 122` | `106/122` |
| 04 | Game-Engine | 14/128 | 24/128 |
| 08 | Mundo-Voxel | 105/105 | 108/108 |
| 15 | Recursos | 115/221 | 162/219 |
| 61 | Rendimiento | 49/144 | 53/148 |
| 83 | Licencias-De-Software | 99/100 | 98/100 |
| 92 | Tutorial | 133/186 | 132/185 |
| 145 | Diseno-De-Experiencia | 87/105 | 90/105 |
| 156 | Terrenos-Y-Movimiento | 182/307 | 202/307 |

**M16-Crafting es nuevo y tiene doble drift**: la línea Totales del checklist declara
106/89/13 pero el disco tiene 111 `[x]`. O sea, le llegó el turno de la fuga 1 (flips
sin actualizar Totales) **y** de la fuga 2 (GLOBAL desactualizado).

**M25-Ruinas** es un caso de formato, no de número: GLOBAL escribe
`106/16 = 122` (completados/no-resueltos = total) y el verificador espera
`106/122`.El número real es correcto; el que está mal es el formato de la celda.

## Tipo 2 — 🔴 2 módulos marcados ✅ que tienen `[?]` (violan DoD §21.6)

Este es el hallazgo que no había visto y es el más importante:

| MID | Estado GLOBAL | Real |
|---|---|---|
| **116** | **✅ Completado** (QA §21.8 Ling 3.1 Flash) | 169 `[x]` / **23 `[?]`** / 0 `[ ]` |
| **89** | **✅ Completado** (QA §21.8) | 124 `[x]` / **1 `[?]`** / 0 `[ ]` |

AGENTS.md §21.6 es explícito: **un módulo sólo se marca ✅ cuando ninguno de sus
subitems es `[?]`**. Con M99 que degradaste ayer por el mismo patrón (14 `[ ]`), y con
el precedente de M88 que quedó 🟡 con la nota *"DoD §21.6: ✅ requiere 0 `[?`"*, estos
dos están en la misma situación.

**Matiz importante que verifico para no acusar de más:** ambos `[?]` están documentados
como deuda externa con dueño, no como deferrals:

- **M116 (23 `[?]`)**: el propio sello los clasifica como *"doble indexación estructural
  (Patrón D), canónica `[x]` superviviente, no duplicados reales ni deferrals M114"*, con
  muestreo 10/10 válido.
- **M89 (1 `[?]`)**: el sello lo declara *"M154 Visión caído (deuda externa real, dueño
  M154 visión)"*.

Es decir: **no es inflación**, es una inconsistencia de criterio — el proyecto ha
tratado estos `[?]` externos como compatibles con ✅ en algunos módulos (M103, M87) y
como bloqueantes en otros (M88, M99). Mi lectura es que la DoD debería aplicarse igual
para todos, pero eso es una decisión tuya, no mía.

## Tipo 3 — 7 módulos 🟢 con trabajo ya hecho

```
137-Prototipo        10 [x]   🟢 Disponible
138-Vertical-Slice   11 [x]   🟢 Disponible
139-Pre-Alpha        12 [x]   🟢 Disponible
140-Alpha            14 [x]   🟢 Disponible
142-Release-Cand     23 [x]   🟢 Disponible
143-Lanzamiento      18 [x]   🟢 Disponible
144-Despues-Lanz      4 [x]   🟢 Disponible
```

Son los módulos de planning que ya mencioné en BUG-050 (los que citaban el Log 867 de
agnes). El verificador los marca porque tener `[x]` con estado `🟢 Disponible` es
contradictorio: si hay ítems cerrados, el módulo empezó. No lo considero un defecto
grave — es el estado natural de módulos de planificación — pero es la misma familia de
inconsistencia.

## Tipo 4 — 1 posible bloqueo colgado

```
156-Terrenos-Y-Movimiento está en curso pero timestamp ilegible:
  "atria: lote 1 = 13 flips cita real → 182/69/56 (Log 1778, commit 12bea1a).
   Lote 2 = feedback I/J/L autorizado por director.."
```

El timestamp de "Última actividad" no es una fecha parseable, así que el verificador
no puede saber si sigue en vuelo. **Regla §21.4.7**: si un módulo lleva más de 24h sin
actividad, otro agente puede reclamarlo. Vale la pena que alguien normalice ese campo.

## Resumen

| Tipo | Cantidad | Gravedad |
|---|---|---|
| Drift GLOBAL ↔ disco | 11 | 🟡 dato viejo, fácil de corregir |
| ✅ con `[?]` (DoD violada) | **2** (M116, M89) | 🔴 inconsistencia de criterio |
| 🟢 con `[x]` | 7 | ⚪ estado natural de planning |
| Timestamp ilegible | 1 (M156) | 🟡 normalizar |

**No modifiqué nada**: GLOBAL es read-only para mí y los checklists son de otros dueños.
Si me autorizás, puedo (a) corregir los 11 drift de GLOBAL con el valor real del disco,
(b) normalizar el timestamp de M156, y (c) dejar los ✅ de M116/M89 para tu criterio.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
