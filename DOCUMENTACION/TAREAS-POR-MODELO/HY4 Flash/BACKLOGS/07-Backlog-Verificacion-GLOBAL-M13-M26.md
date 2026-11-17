# 07-Backlog: Verificacion GLOBAL M13-M26

> Creada por: agnes-3-flash - 2026-11-17 07:55
> Nicho: verificacion de conteos, NO codigo

## Metodo
- Conteo: grep -cF con patron fijo sobre plan-actual/05-Checklist.md
- Comparar contra Progreso de CHECKLIST-GLOBAL.md
- Drift > 5: REPORTAR. Drift <= 5: anotar.

## Tareas

- [x] T7-01: M13 Herramientas (real 119x+1o=120) - drift GLOBAL — GLOBAL L71 119/120, drift 0
- [x] T7-02: M14 Inventario (real 139x+1q=140) - drift GLOBAL — GLOBAL L82 139/140, drift 0 (6 citas `> - [x]` NO contadas como ítems)
- [x] T7-03: M16 Crafting (real 187x+16q=203) - drift GLOBAL — GLOBAL L109 187/203, drift 0
- [x] T7-04: M17 Construccion (real 141x+33o+1q=175) - drift GLOBAL — **DRIFT >5: GLOBAL L120 135/175, real 141 → +6**. REPORTADO, NO corregido
- [x] T7-05: M19 NPC-Y-Vecinos (real 128x=128) - drift GLOBAL — GLOBAL L122 128/128, drift 0
- [x] T7-06: M20 Sistema-De-Amistad (real 102x+48o=150) - drift GLOBAL — GLOBAL L123 102/150, drift 0
- [x] T7-07: M21 Dialogos (real 137x+6q=143) - drift GLOBAL — **DRIFT >5: GLOBAL L124 143/143, real 137 → -6**. REPORTADO, NO corregido
- [x] T7-08: M22 Historia-Principal (real 80x+7o+4q=91) - drift GLOBAL — GLOBAL L125 80/91, drift 0
- [x] T7-09: M23 Historias-Secundarias (real 89x+14o+2q=105) - drift GLOBAL — GLOBAL L126 89/105, drift 0
- [x] T7-10: M24 Templos-Y-Puzzles (real 128x=128) - drift GLOBAL — GLOBAL L127 127/128, drift +1 (anotado)
- [x] T7-11: M25 Ruinas (real 122x=122) - drift GLOBAL — **DRIFT >5: GLOBAL L128 106/122, real 122 → +16**. REPORTADO, NO corregido
- [x] T7-12: M26 Templo-Subterraneo (real 128x+1q=129) - drift GLOBAL — **DRIFT >5: GLOBAL L129 122/129, real 128 → +6**. REPORTADO, NO corregido

## Evidencia de la tanda (HY4 Flash, 2026-11-17 07:5x UTC)

Conteo anclado a inicio de línea con `grep -cF` (criterio que reproduce los claims; ver informe 016):

```
M13:119/1/0  M14:139/0/1  M16:187/0/16 M17:141/33/1
M19:128/0/0  M20:102/48/0 M21:137/0/6  M22:80/7/4
M23:89/14/2  M24:128/0/0  M25:122/0/0  M26:128/0/1
```

| Módulo | Real `[x]` | GLOBAL | Drift | Resultado |
|---|---|---|---|---|
| M13 | 119 | 119/120 (L71) | 0 | Sin drift |
| M14 | 139 | 139/140 (L82) | 0 | Sin drift |
| M16 | 187 | 187/203 (L109) | 0 | Sin drift |
| **M17** | **141** | **135/175 (L120)** | **+6** | **Reportado** |
| M19 | 128 | 128/128 (L122) | 0 | Sin drift |
| M20 | 102 | 102/150 (L123) | 0 | Sin drift |
| **M21** | **137** | **143/143 (L124)** | **-6** | **Reportado** |
| M22 | 80 | 80/91 (L125) | 0 | Sin drift |
| M23 | 89 | 89/105 (L126) | 0 | Sin drift |
| M24 | 128 | 127/128 (L127) | +1 | Anotado |
| **M25** | **122** | **106/122 (L128)** | **+16** | **Reportado** |
| **M26** | **128** | **122/129 (L129)** | **+6** | **Reportado** |

**Detalle de los 4 drifts materiales (NO corregidos):**
- **M17-Construcción:** el `Totales` vigente (L318, re-medido 2026-11-08) ya dice 141/33/1, igual que el disco; el GLOBAL conserva 135/175 de una medición anterior (Log 2220, 2026-10-27). Drift +6.
- **M21-Diálogos:** `Totales` L340 dice 137/0/6 y coincide con el disco; el GLOBAL dice 143/143 (otra vez total/total, patrón ya visto en M74 y M71). Drift -6.
- **M25-Ruinas:** el disco tiene 122 `[x]` y 0 `[?]`; el `Totales` L162 y el GLOBAL siguen en 106 completados / 16 no resueltos (degradación de QA de 2026-10-12). Drift +16.
- **M26-Templo-Subterráneo:** el disco tiene 128 `[x]` + 1 `[?]`; el `Totales` L187 y el GLOBAL siguen en 122/7. Drift +6.

**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55
**Ejecucion:** HY4 Flash / WorkBuddy - 2026-11-17 07:56
