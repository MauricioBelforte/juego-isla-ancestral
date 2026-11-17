# 04-Backlog: Verificacion de Progreso CHECKLIST-GLOBAL

> Creada por: agnes-3-flash (directora) - 2026-11-17 04:03
> Nicho: verificacion de conteos, NO codigo

## Reglas
- Conteo real: grep -c con patron exacto
- Drift > 5 en Progreso de CHECKLIST-GLOBAL: reportar (NO fix)
- Drift <= 5: anotar y pasar

## Tareas

- [x] T4-01: Verificar M122-Crash-Reporting (real 256x, CHECKLIST-GLOBAL dice ?) - drift report — GLOBAL real L61 = 254/264; drift +2 (≤5, anotado). 8 `[?]` reales vs 10 declarados en Totales
- [x] T4-02: Verificar M90-Configuracion-Grafica (real 249x, CHECKLIST-GLOBAL dice ?) - drift report — GLOBAL real L194 = 249/249; drift 0. El "?" del backlog era marcador de posicion
- [x] T4-03: Verificar M120-DLC-Y-Expansiones (real 222x) - drift report — GLOBAL L59 222/222, drift 0
- [x] T4-04: Verificar M100-Community-Management (real 220x) - drift report — GLOBAL L36 220/220, drift 0
- [x] T4-05: Verificar M121-Soporte-Post-Lanzamiento (real 211x) - drift report — GLOBAL L60 211/211, drift 0
- [x] T4-06: Verificar M152-Principios-Innegociables (real 202x) - drift report — GLOBAL L99 202/202, drift 0
- [x] T4-07: Verificar M116-Instalador (real 199x) - drift report — GLOBAL L54 199/199, drift 0 (las notas de la fila citan un conteo historico 169/23)
- [x] T4-08: Verificar M106-Seguridad (real 206x) - drift report — **DRIFT >5: GLOBAL L42 194/206, real 206 → +12**. REPORTADO, NO corregido
- [x] T4-09: Verificar M88-Fuentes-Tipograficas (real 178x+7?) - drift report — GLOBAL L192 174/185, drift +4 (≤5, anotado); 7 `[?]` reales coinciden con el claim
- [x] T4-10: Verificar M99-Marketing (real 169x) - drift report — GLOBAL L203 169/169, drift 0 (nota historica de la fila dice 155/169, 14 `[ ]`)
- [x] T4-11: Verificar M91-Configuracion-De-Audio (real 239x) - drift report — GLOBAL L195 237/239, drift +2 (≤5, anotado); Totales declara 2 `[?]` pero el conteo real da 0
- [x] T4-12: Verificar M151-Control-Final (real 156x+6[]+5?) - drift report — GLOBAL L98 156/167, drift 0; 6 `[ ]` y 5 `[?]` reales coinciden con Totales

## Evidencia de la tanda (HY4 Flash, 2026-11-17 05:5x UTC)

Conteo real con patrón fijo (GNU grep BRE `\?` dio 0 falsos para `[?]`; se uso `grep -cF`):

```
$ for id in 122 90 120 100 121 152 116 106 88 99 91 151; do f=$(ls DOCUMENTACION/${id}-*/plan-actual/05-Checklist.md | head -1); printf "M%-3s x=%-4s pend=%-3s q=%-3s\n" "$id" "$(grep -cF -- '- [x]' "$f")" "$(grep -cF -- '- [ ]' "$f")" "$(grep -cF -- '- [?]' "$f")"; done
M122 x=256  pend=0   q=8      M90  x=249  pend=0   q=0
M120 x=222  pend=0   q=0      M100 x=220  pend=0   q=0
M121 x=211  pend=0   q=0      M152 x=202  pend=0   q=0
M116 x=199  pend=0   q=0      M106 x=206  pend=0   q=0
M88  x=178  pend=0   q=7      M99  x=169  pend=0   q=0
M91  x=239  pend=0   q=0      M151 x=156  pend=6   q=5
```

| Tarea | Módulo | Real `[x]` | GLOBAL (Línea) | Drift | Acción |
|---|---|---|---|---|---|
| T4-01 | M122 Crash-Reporting | 256 | 254/264 (L61) | +2 | Anotado |
| T4-02 | M90 Configuracion-Grafica | 249 | 249/249 (L194) | 0 | Sin drift |
| T4-03 | M120 DLC-Y-Expansiones | 222 | 222/222 (L59) | 0 | Sin drift |
| T4-04 | M100 Community-Management | 220 | 220/220 (L36) | 0 | Sin drift |
| T4-05 | M121 Soporte-Post-Lanzamiento | 211 | 211/211 (L60) | 0 | Sin drift |
| T4-06 | M152 Principios-Innegociables | 202 | 202/202 (L99) | 0 | Sin drift |
| T4-07 | M116 Instalador | 199 | 199/199 (L54) | 0 | Sin drift |
| T4-08 | M106 Seguridad | 206 | 194/206 (L42) | **+12** | **Reportado** |
| T4-09 | M88 Fuentes-Tipograficas | 178 | 174/185 (L192) | +4 | Anotado |
| T4-10 | M99 Marketing | 169 | 169/169 (L203) | 0 | Sin drift |
| T4-11 | M91 Configuracion-De-Audio | 239 | 237/239 (L195) | +2 | Anotado |
| T4-12 | M151 Control-Final | 156 | 156/167 (L98) | 0 | Sin drift |

**Detalle del único drift material (T4-08, M106-Seguridad):** el checklist `DOCUMENTACION/106-Seguridad/plan-actual/05-Checklist.md` tiene 206 marcas `^- [x]` y 0 `[ ]`/`[?]`; su línea `Totales` (L381) declara 194 completados / 0 pendientes / 12 no resueltos; `CHECKLIST-GLOBAL.md` L42 dice `194/206` con estado `🟡 Completado (P-36)`. Tres fuentes, dos valores: 206 real vs 194 declarado en ambas. No se corrigió nada (regla del backlog: solo reportar).

**Firma:** agnes-3-flash (directora) - 2026-11-17 04:03
**Ejecucion:** HY4 Flash / WorkBuddy - 2026-11-17 05:55
