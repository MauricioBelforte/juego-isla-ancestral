# 06-Backlog: Verificacion GLOBAL M01-M12

> Creada por: agnes-3-flash - 2026-11-17 07:55
> Nicho: verificacion de conteos, NO codigo

## Metodo
- Conteo: grep -cF con patron fijo sobre plan-actual/05-Checklist.md
- Comparar contra Progreso de CHECKLIST-GLOBAL.md
- Drift > 5: REPORTAR. Drift <= 5: anotar.

## Tareas

- [x] T6-01: M01 Fundamentos (real 73x+79o=152) - drift GLOBAL — GLOBAL L24 73/152, drift 0
- [x] T6-02: M02 Vision-Y-Concepto (real 165x+7q=172) - drift GLOBAL — GLOBAL L25 164/172, drift +1 (anotado)
- [x] T6-03: M03 Documentacion (real 130x+3q=133) - drift GLOBAL — GLOBAL L26 130/133, drift 0
- [x] T6-04: M04 Game-Engine (real 128x=128) - drift GLOBAL — GLOBAL L28 126/128, drift +2 (anotado)
- [x] T6-05: M05 Lenguaje-Y-Programacion (real 103x=103) - drift GLOBAL — GLOBAL L29 103/103, drift 0
- [x] T6-06: M06 Control-De-Versiones (real 100x=100) - drift GLOBAL — GLOBAL L30 100/100, drift 0
- [x] T6-07: M07 Arquitectura-General (real 105x=105) - drift GLOBAL — GLOBAL L31 105/105, drift 0
- [x] T6-08: M08 Mundo-Voxel (real 108x=108) - drift GLOBAL — GLOBAL L32 108/108, drift 0
- [x] T6-09: M09 Terreno-Y-Geografia (real 110x+5q=115) - drift GLOBAL — GLOBAL L33 110/115, drift 0
- [x] T6-10: M10 Generacion-Del-Mundo (real 88x+18q=106) - drift GLOBAL — GLOBAL L34 90/106, drift -2 (anotado)
- [x] T6-11: M11 Personaje-Del-Jugador (real 91x+32q=123) - drift GLOBAL — GLOBAL L46 91/123, drift 0
- [x] T6-12: M12 Camara (real 100x+2q=102) - drift GLOBAL — GLOBAL L58 100/102, drift 0

## Evidencia de la tanda (HY4 Flash, 2026-11-17 07:5x UTC)

Conteo real con `grep -cF` sobre líneas que **empiezan** con el marcador (`- [x]`, `- [ ]`, `- [?]`). Este anclaje reproduce exactamente los 12 claims de la directora. El conteo no anclado agregaría líneas citadas (`> - [x]`) o texto de leyenda que no son ítems; se documenta en el informe 016.

```
M01:73/79/0  M02:165/0/7  M03:130/0/3  M04:128/0/0
M05:103/0/0  M06:100/0/0  M07:105/0/0  M08:108/0/0
M09:110/0/5  M10:88/0/18  M11:91/0/32  M12:100/0/2
```

| Módulo | Real `[x]` | GLOBAL | Drift | Resultado |
|---|---|---|---|---|
| M01 | 73 | 73/152 (L24) | 0 | Sin drift |
| M02 | 165 | 164/172 (L25) | +1 | Anotado |
| M03 | 130 | 130/133 (L26) | 0 | Sin drift |
| M04 | 128 | 126/128 (L28) | +2 | Anotado |
| M05 | 103 | 103/103 (L29) | 0 | Sin drift |
| M06 | 100 | 100/100 (L30) | 0 | Sin drift |
| M07 | 105 | 105/105 (L31) | 0 | Sin drift |
| M08 | 108 | 108/108 (L32) | 0 | Sin drift |
| M09 | 110 | 110/115 (L33) | 0 | Sin drift |
| M10 | 88 | 90/106 (L34) | -2 | Anotado |
| M11 | 91 | 91/123 (L46) | 0 | Sin drift |
| M12 | 100 | 100/102 (L58) | 0 | Sin drift |

**Sin drifts >5 en este bloque.** Máximo: +2 en M04; los tres drifts menores (M02 +1, M04 +2, M10 -2) quedan anotados.

**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55
**Ejecucion:** HY4 Flash / WorkBuddy - 2026-11-17 07:56
