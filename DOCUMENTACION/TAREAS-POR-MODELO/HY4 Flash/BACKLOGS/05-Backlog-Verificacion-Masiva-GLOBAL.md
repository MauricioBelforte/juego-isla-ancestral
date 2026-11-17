# 05-Backlog: Verificacion Masiva GLOBAL (Parte 2)

> Creada por: agnes-3-flash - 2026-11-17 06:06
> Nicho: verificacion de conteos, NO codigo
> Metodo: grep -cF con patron fijo (- [x], - [ ], - [?]) sobre plan-actual/05-Checklist.md

## Reglas
- Drift > 5 entre [x] real y Progreso GLOBAL: REPORTAR (no fix)
- Drift <= 5: anotar y pasar
- Si el modulo no existe: [?]
- Solo 12 modulos, NO los 158 restantes

## Tareas

- [x] T5-01: M156 Terrenos-Y-Movimiento (real 223x+2[]+82[?=307) - drift GLOBAL — GLOBAL L104 223/307, drift 0. Real coincide con Totales y con el claim
- [x] T5-02: M74 Eventos (real 227x+58[?=285) - drift GLOBAL — **DRIFT >5: GLOBAL L178 285/285, real 227 → -58**. REPORTADO, NO corregido
- [x] T5-03: M112 Testing-Automatico (real 228x+4[?=232) - drift GLOBAL — GLOBAL L49 228/232, drift 0
- [x] T5-04: M36 Fauna (real 228x=228) - drift GLOBAL — GLOBAL L139 228/228, drift 0
- [x] T5-05: M110 Debug-Menu (real 179x+46[]=225) - drift GLOBAL — GLOBAL L47 179/225, drift 0
- [x] T5-06: M15 Recursos (real 215x+4[?=219) - drift GLOBAL — GLOBAL L96 215/219, drift 0; Totales interno stale (205/10 vs real 215/4)
- [x] T5-07: M18 Casas (real 200x+9[]+4[?=213) - drift GLOBAL — GLOBAL L121 200/213, drift 0; Totales interno muy stale (149/33/0 vs real 200/9/4)
- [x] T5-08: M71 Progresion (real 169x+44[?=213) - drift GLOBAL — **DRIFT >5: GLOBAL L175 213/213, real 169 → -44**. REPORTADO, NO corregido
- [x] T5-09: M40 Infraestructura (real 210x+1[]=211) - drift GLOBAL — GLOBAL L143 206/211, drift +4 (≤5, anotado); Totales interno stale (180/27/4 vs real 210/1/0)
- [x] T5-10: M101 QA-General (real 209x=209) - drift GLOBAL — GLOBAL L37 209/209, drift 0
- [x] T5-11: M111 Codigo-De-Calidad (real 209x=209) - drift GLOBAL — GLOBAL L48 209/209, drift 0
- [x] T5-12: M108 Pipeline-De-Assets (real 202x+3[?=205) - drift GLOBAL — GLOBAL L44 202/205, drift 0; estado ✅ con 3 `[?]` (coherente con la fila)

## Evidencia de la tanda (HY4 Flash, 2026-11-17 07:4x UTC)

Conteo real literal con `grep -cF` sobre `plan-actual/05-Checklist.md` de cada módulo:

```
M156 x=223  pend=2   q=82     M74  x=227  pend=0   q=58
M112 x=228  pend=0   q=4      M36  x=228  pend=0   q=0
M110 x=179  pend=46  q=0      M15  x=215  pend=0   q=4
M18  x=200  pend=9   q=4      M71  x=169  pend=0   q=44
M40  x=210  pend=1   q=0      M101 x=209  pend=0   q=0
M111 x=209  pend=0   q=0      M108 x=202  pend=0   q=3
```

| Tarea | Módulo | Real `[x]` | GLOBAL (línea) | Drift | Acción |
|---|---|---|---|---|---|
| T5-01 | M156 Terrenos-Y-Movimiento | 223 | 223/307 (L104) | 0 | Sin drift |
| T5-02 | M74 Eventos | 227 | 285/285 (L178) | **-58** | **Reportado** |
| T5-03 | M112 Testing-Automatico | 228 | 228/232 (L49) | 0 | Sin drift |
| T5-04 | M36 Fauna | 228 | 228/228 (L139) | 0 | Sin drift |
| T5-05 | M110 Debug-Menu | 179 | 179/225 (L47) | 0 | Sin drift |
| T5-06 | M15 Recursos | 215 | 215/219 (L96) | 0 | Sin drift (Totales interno stale) |
| T5-07 | M18 Casas | 200 | 200/213 (L121) | 0 | Sin drift (Totales interno stale) |
| T5-08 | M71 Progresion | 169 | 213/213 (L175) | **-44** | **Reportado** |
| T5-09 | M40 Infraestructura | 210 | 206/211 (L143) | +4 | Anotado |
| T5-10 | M101 QA-General | 209 | 209/209 (L37) | 0 | Sin drift |
| T5-11 | M111 Codigo-De-Calidad | 209 | 209/209 (L48) | 0 | Sin drift |
| T5-12 | M108 Pipeline-De-Assets | 202 | 202/205 (L44) | 0 | Sin drift |

**Drifts materiales (NO corregidos):**
- **M74-Eventos:** 227 `[x]` + 58 `[?]` = 285 en disco; `Totales` del módulo coincide; GLOBAL L178 dice `285/285` (contó los 285 ítems como completados). El numerador debería ser 227 si se mantiene el criterio de `[x]`.
- **M71-Progresion:** 169 `[x]` + 44 `[?]` = 213 en disco; `Totales` L327 coincide (169/0/44); GLOBAL L175 dice `213/213` (mismo patrón: cuenta totales como completados). La línea L301 del checklist es una reconciliación histórica (72/141), no la vigente.

**Falso positivo corregido:** el script marcó M71 como "SIN LINEA Totales" porque la línea vigente empieza con `> **Totales:**` (cita markdown); revisión manual la encontró en L327 y coincide con el conteo real.

**Firma:** agnes-3-flash (directora) - 2026-11-17 06:06
**Ejecucion:** HY4 Flash / WorkBuddy - 2026-11-17 07:45
