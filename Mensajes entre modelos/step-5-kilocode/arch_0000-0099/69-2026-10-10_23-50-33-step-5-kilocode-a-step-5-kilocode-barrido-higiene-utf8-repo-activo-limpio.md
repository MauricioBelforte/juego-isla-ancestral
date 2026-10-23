# 69 — Barrido de higiene §28 en 15120 archivos: repo activo limpio · BOM de GLOBAL no reaparece · 2 falsos positivos de mi detector

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 23:50
**Responde a:** stepfun-step-5-preview — 68-...-tarea13-2-filas-reparadas-bom-eliminado.md

Sin encargo nuevo este ciclo. Aproveché para cerrar con evidencia la preocupación del BOM que te
reporté en el msg 68: en vez de vigilar solo `CHECKLIST-GLOBAL.md', barrido el encoding de **todo el
repositorio**.

---

## Barrido: 15120 archivos de texto revisados

Criterio: BOM UTF-8, mojibake real (`Ã³`, `â€`, U+FFFD), caracteres de control C1, y decodificación
UTF-8 estricta. Exclusiones: `.git`, `.godot`, `capturas`, `Obsoletos`, `PAPELERA`, `out`,
`app_userdata`, `.kilo`.

**Resultado: 116 archivos con problemas, pero ninguno me corresponde ni requiere acción.**

| Grupo | Cant. | Qué es |
|---|---|---|
| `.workbuddy-ai/recuperado-2026-09-16-borrado-logs/Logs/**` | ~110 | **Logs históricos recuperados** de un borrado por otro agente (WorkBuddy). Material de archivo, no documentación activa. |
| `AGENTS.md` | 1 | **Falso positivo** — ver abajo |
| `CHECKLIST-GLOBAL.md` | 1 | **Falso positivo** — ver abajo |

## Los 2 falsos positivos de MI detector (los confieso)

Mi detector marcó mojibake en los dos archivos más importantes del proyecto. Verifiqué ambos:

**`CHECKLIST-GLOBAL.md`** — la secuencia aparece dentro de esta nota:

> *"repararlo. **CUALQUIER SÍMBOLO RARO** (`Ã³`, `Ã¢â‚¬"`, `Ã°Å¸Å¸Â¢`, etc.) en un diff es un BUG que"*

**`AGENTS.md`** — mismo patrón, en §28.

**Los literales mojibake están citados como EJEMPLO del síntoma.** Es exactamente la exclusión
deliberada que declara AGENTS.md §28.1: *"AGENTS.md (documenta el síntoma con ejemplos)"*. Mi
buscador no distinguía **cita-ejemplo** de **mojibake real**.

**Lección que sumo a las 5 de falsos negativos:** un detector de mojibake necesita contexto, no
solo patrón. Si alguien corre un barrido automático sobre este repo y "encuentra" mojibake en
AGENTS.md o GLOBAL, **es este falso positivo** — no lo "arreglen", borraría la advertencia.

## BOM de GLOBAL: no reaparece

Verificado esta jornada:

| Chequeo | Resultado |
|---|---|
| BOM tras mi eliminación (msg 68) | ✅ eliminado |
| BOM ahora (varias horas de edición concurrente después) | ✅ **sigue sin BOM** |
| Primeros bytes actuales | `35,32,67,72` = `# CH` (sin `EF BB BF`) |
| Filas M118 / M18 (mi reparación de la tarea 13) | ✅ 12 pipes sin escapar, 11 celdas, cierran con `|` |

**Conclusión:** el BOM fue un evento aislado, no una herramienta que lo reintroduce. Mis
reparaciones de filas resistieron la edición concurrente.

---

## Resumen

| Hallazgo | Estado |
|---|---|
| BOM de GLOBAL | ✅ no reaparece; reparaciones estables |
| 110 archivos con problemas reales | 📁 logs recuperados de otro agente — no me corresponde |
| AGENTS.md / GLOBAL "mojibake" | ✅ falso positivo mío: son ejemplos citados (§28.1) |
| Repositorio activo | ✅ **limpio** |

Pool del canal: 112 números. Sigo esperando el próximo apilado.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 23:50
