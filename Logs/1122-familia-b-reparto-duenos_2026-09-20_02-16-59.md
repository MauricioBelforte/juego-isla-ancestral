# Log 1122: Familia B repartida — slices por módulo en el backlog de cada dueño

**Fecha:** 2026-09-20
**Hora:** 02:16
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code (sesión 2)

## Resumen

La **Familia B** del BUG-068 (114 items en 17 módulos — "el plan fue malo y las
checklists no corresponden") se dejó como **tarea de planeamiento de autor** en el
backlog de cada dueño, según la directriz del usuario. **No se tocó ni una marca**: es
trabajo de re-evaluar `plan-actual/` + `05-Checklist.md`, no de auditoría.

## Reparto

| Dueño (backlog) | Módulos | Items |
|-----------------|---------|-------|
| `glm-5.3-flash` | M32, M93, M118, M145, M146 | 55 |
| `agnes-2.5-flash` | M78, M82, M85 | 29 |
| `deepseek-v4-flash-vision-exp` | M36, M65, M94 | 12 |
| `step-3.7-flash` | M114, M119, M167 | 6 |
| `deepseek-v4-flash` | M116 | 2 |
| `mimo-v2.5` | M154 | 4 |
| **(sin asignar)** | **M81 Legal-Menores** | 6 |

Cada archivo `FAMILIA-B-REPLANIFICACION.md` explica la tarea, cita el BUG-068 y lista
los items con la razón de su clasificación Familiar B.

## M81 — sin dueño con backlog

Su `plan-actual/04-Codigo.md` firma **Nemotron 3 Ultra**, que no tiene carpeta en
`TAREAS-POR-MODELO/`. El global lo atribuye a `ox-alpha (Cline)` (sin backlog tampoco).
Su slice queda en el reporte general
(`familia_b_slice_2026-09-20.txt`) a la espera de que el usuario decida la asignación.

## Corrección de un error propio

Inicialmente asigné **M32 Clima a mi propio backlog**. Al verificar la firma vigente
del `04-Codigo.md` (L6: *"Firma vigente (iter. 1): glm-5.3-flash"*), confirmé que el
autor es **glm-5.3-flash** — yo solo hice el QA §21.8 (Log 942). Corregido y re-dejado
en su backlog. Eliminé el archivo residual de mi carpeta.

> **Lección:** el dueño de un módulo es quien **firma el plan-actual**, no quien hizo
> el último QA. Un verificador ≠ autor.

## M32 — por qué NO se revirtió

M32 tiene 14 items Familia B pero **su núcleo está implementado y verificado**
(`weather_service.gd` + `test_clima.gd` 0 fallos, 4 suites, Log 942). Los items
Familia B son integraciones pendientes (M90/M61/M19/M36) con spec documentada — plan,
no código ausente. Se mantiene ✅ 121/121 y se reparte como replanificación.

## Exclusiones respetadas

Ninguno de los 17 módulos Familia B está 🔵 en curso por otro agente — el filtro del
script lo verificó contra el global. **M04/M05/M103/M106/M122** (los 🔵 que mencionó el
usuario) no están en la lista Familia B; no se tocaron.

## BUG-065 — solapamiento registrado

Tal como indicó el usuario, **BUG-065** (leyenda rota en 9 fundacionales: M02-M06,
M41-M44) se solapa con Familia B. Cuando los dueños de esos módulos hagan su
re-evaluación, **deben arreglar la leyenda en el mismo pase**. Se dejó nota en el
encabezado de cada `FAMILIA-B-REPLANIFICACION.md`.

## Archivos Modificados/Creados

- `DOCUMENTACION/TAREAS-POR-MODELO/{glm-5.3-flash,agnes-2.5-flash,
  deepseek-v4-flash-vision-exp,step-3.7-flash,deepseek-v4-flash,mimo-v2.5}/
  FAMILIA-B-REPLANIFICACION.md` (6 archivos)
- `.../atria-dawn-s2/familia_b_slice_2026-09-20.txt` (reporte completo, 17 módulos)
- `.../atria-dawn-s2/scripts-prueba/repartir_familia_b.py`
- `.../atria-dawn-s2/scripts-prueba/dejar_familia_b_backlogs.py`
- `Logs/1122-familia-b-reparto-duenos_2026-09-20_02-16-59.md`

## Próximos pasos

1. **BUG-067 → DeepSeek-V4.1-Flash** (M103 es 🔵 suyo; es un bug de rendimiento real,
   no mío).
2. **QA §21.8** sobre los 28 ✅ con binario real, priorizando los **sin sello genuino**
   en `CHECKLIST-QA-SEALS.md` (hy3 ya cubrió 10 + 5 sellos nuevos en BUG-050).
