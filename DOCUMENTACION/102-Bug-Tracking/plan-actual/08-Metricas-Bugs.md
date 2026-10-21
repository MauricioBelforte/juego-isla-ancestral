# Metricas de bugs — informe automatico

Generado por `scripts/metricas_bugs.py` sobre `DOCUMENTACION/11-BUGS.md`.
Fuente de verdad: `DOCUMENTACION/11-BUGS.md` (registro local).

## Totales medidos

| Metrica | Valor |
|---|---|
| Filas en la tabla resumen (seccion 5) | 92 |
| IDs unicos en la tabla | 88 |
| Entradas con encabezado | 137 (129 unicas) |
| IDs unicos en el registro (union tabla+entradas) | 137 |
| No resueltos (abierto + delegado + en progreso) | 25 |
| ID maximo | BUG-140 |
| Huecos de numeracion | 3 |
| — mencionados sin entrada canonica | BUG-023, BUG-119 |
| — ausentes del registro entero | BUG-045 |

## Universo paralelo: dashboard de GitHub Issues

`docs/bug_metrics.md` declara **0 abiertos / 0 cerrados**.
Ese dashboard cuenta SOLO issues de GitHub; el registro local (`11-BUGS.md`) es la fuente de verdad de este informe. Si los dos numeros no coinciden, el defecto `dashboard_divergente` lo declara.

## Por estado

| Estado | Cantidad |
|---|---|
| abierto | 14 |
| delegado | 7 |
| en_progreso | 4 |
| resuelto | 67 |

## Por severidad

| Severidad | Cantidad |
|---|---|
| baja | 2 |
| critica | 15 |
| mayor | 26 |
| menor | 44 |
| trivial | 5 |

## Defectos de sincronizacion

| Tipo | Cantidad |
|---|---|
| dashboard_divergente | 1 |
| entrada_duplicada | 8 |
| entrada_sin_fila | 49 |
| estado_sin_marca | 1 |
| etiqueta_severidad_inconsistente | 4 |
| fila_malformada | 3 |
| fila_sin_entrada | 8 |
| id_duplicado_tabla | 4 |
| seccion_pegada | 1 |

### Detalle

- L141 `estado_sin_marca` — BUG-058 declara 'resuelto' sin marca [x]/[ ]/[?]/[->]: '✅ **Resuelto (fix exclusiones, Log 1092, hy3 2026-'
- L153 `fila_malformada` — BUG-127 tiene 14 celdas (esperadas 7)
- L177 `fila_malformada` — BUG-088 tiene 15 celdas (esperadas 7)
- L205 `fila_malformada` — BUG-118 tiene 6 celdas (esperadas 7)
- L3061 `seccion_pegada` — encabezado con otro encabezado embebido: '## 7. Bugs Resueltos (historial)## BUG-119: IncenseSpawner genera 0 puntos por r'
- L149 `id_duplicado_tabla` — BUG-071 aparece 2 veces en la tabla (lineas 149, 172)
- L154 `id_duplicado_tabla` — BUG-129 aparece 2 veces en la tabla (lineas 154, 206)
- L155 `id_duplicado_tabla` — BUG-130 aparece 2 veces en la tabla (lineas 155, 207)
- L159 `id_duplicado_tabla` — BUG-139 aparece 2 veces en la tabla (lineas 159, 209)
- L3154 `entrada_duplicada` — BUG-047 tiene 2 entradas (lineas 3154, 5383)
- L3458 `entrada_duplicada` — BUG-051 tiene 2 entradas (lineas 3458, 5752)
- L3406 `entrada_duplicada` — BUG-052 tiene 2 entradas (lineas 3406, 4577)
- L2060 `entrada_duplicada` — BUG-058 tiene 2 entradas (lineas 2060, 3367)
- L2234 `entrada_duplicada` — BUG-061 tiene 2 entradas (lineas 2234, 3342)
- L2266 `entrada_duplicada` — BUG-062 tiene 2 entradas (lineas 2266, 3322)
- L1083 `entrada_duplicada` — BUG-089 tiene 2 entradas (lineas 1083, 4267)
- L2952 `entrada_duplicada` — BUG-120 tiene 2 entradas (lineas 2952, 4132)
- L182 `fila_sin_entrada` — BUG-095 esta en la tabla y no tiene entrada
- L193 `fila_sin_entrada` — BUG-106 esta en la tabla y no tiene entrada
- L194 `fila_sin_entrada` — BUG-107 esta en la tabla y no tiene entrada
- L205 `fila_sin_entrada` — BUG-118 esta en la tabla y no tiene entrada
- L162 `fila_sin_entrada` — BUG-131 esta en la tabla y no tiene entrada
- L163 `fila_sin_entrada` — BUG-132 esta en la tabla y no tiene entrada
- L157 `fila_sin_entrada` — BUG-137 esta en la tabla y no tiene entrada
- L158 `fila_sin_entrada` — BUG-138 esta en la tabla y no tiene entrada
- L1930 `entrada_sin_fila` — BUG-024 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L3740 `entrada_sin_fila` — BUG-026 tiene entrada (## 7. Bugs Resueltos (historial)## BUG-119: Ince) y no esta en la tabla
- L3790 `entrada_sin_fila` — BUG-027 tiene entrada (## 7. Bugs Resueltos (historial)## BUG-119: Ince) y no esta en la tabla
- L4291 `entrada_sin_fila` — BUG-028 tiene entrada (## 8. Bugs Delegados a Otros Agentes) y no esta en la tabla
- L4337 `entrada_sin_fila` — BUG-029 tiene entrada (## 8. Bugs Delegados a Otros Agentes) y no esta en la tabla
- L4382 `entrada_sin_fila` — BUG-030 tiene entrada (## 8. Bugs Delegados a Otros Agentes) y no esta en la tabla
- L4882 `entrada_sin_fila` — BUG-031 tiene entrada (## BUG: test caso_reloj C56/E89/E90 falla por fa) y no esta en la tabla
- L4929 `entrada_sin_fila` — BUG-032 tiene entrada (## BUG: test caso_reloj C56/E89/E90 falla por fa) y no esta en la tabla
- L4992 `entrada_sin_fila` — BUG-033 tiene entrada (## BUG: test caso_reloj C56/E89/E90 falla por fa) y no esta en la tabla
- L5040 `entrada_sin_fila` — BUG-034 tiene entrada (## BUG: test caso_reloj C56/E89/E90 falla por fa) y no esta en la tabla
- L4470 `entrada_sin_fila` — BUG-036 tiene entrada (## 8. Bugs Delegados a Otros Agentes) y no esta en la tabla
- L4492 `entrada_sin_fila` — BUG-037 tiene entrada (## 8. Bugs Delegados a Otros Agentes) y no esta en la tabla
- L4519 `entrada_sin_fila` — BUG-038 tiene entrada (## 8. Bugs Delegados a Otros Agentes) y no esta en la tabla
- L5193 `entrada_sin_fila` — BUG-043 tiene entrada (## BUG-043: bioma "snow" inalcanzable en el gene) y no esta en la tabla
- L5245 `entrada_sin_fila` — BUG-044 tiene entrada (## BUG-044: modulo M12 Camara — dos sistemas par) y no esta en la tabla
- L5339 `entrada_sin_fila` — BUG-046 tiene entrada (## BUG-046: catalogo M159 — 12 items con id inte) y no esta en la tabla
- L3154 `entrada_sin_fila` — BUG-047 tiene entrada (## 7. Bugs Resueltos (historial)## BUG-119: Ince) y no esta en la tabla
- L5498 `entrada_sin_fila` — BUG-048 tiene entrada (## BUG-048: UI no compila en runtime (parse erro) y no esta en la tabla
- L5589 `entrada_sin_fila` — BUG-049 tiene entrada (## BUG-049: `reservar_log.py` CIEGO a los numero) y no esta en la tabla
- L5669 `entrada_sin_fila` — BUG-050 tiene entrada (## BUG-050: M39 Tiendas — `catalogo_tiendas.gd` ) y no esta en la tabla
- L2234 `entrada_sin_fila` — BUG-061 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L2266 `entrada_sin_fila` — BUG-062 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L6059 `entrada_sin_fila` — BUG-063 tiene entrada (## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / Wo) y no esta en la tabla
- L6143 `entrada_sin_fila` — BUG-064 tiene entrada (## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / Wo) y no esta en la tabla
- L6218 `entrada_sin_fila` — BUG-065 tiene entrada (## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / Wo) y no esta en la tabla
- L6316 `entrada_sin_fila` — BUG-066 tiene entrada (## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / Wo) y no esta en la tabla
- L6386 `entrada_sin_fila` — BUG-070 tiene entrada (## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / Wo) y no esta en la tabla
- L6457 `entrada_sin_fila` — BUG-072 tiene entrada (## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / Wo) y no esta en la tabla
- L6501 `entrada_sin_fila` — BUG-073 tiene entrada (## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / Wo) y no esta en la tabla
- L4588 `entrada_sin_fila` — BUG-074 tiene entrada (## 8. Bugs Delegados a Otros Agentes) y no esta en la tabla
- L1248 `entrada_sin_fila` — BUG-075 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L6538 `entrada_sin_fila` — BUG-079 tiene entrada (## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / Wo) y no esta en la tabla
- L6580 `entrada_sin_fila` — BUG-080 tiene entrada (## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / Wo) y no esta en la tabla
- L6729 `entrada_sin_fila` — BUG-082 tiene entrada (## 8.1 Bugs Delegados — auditoría reductos (256,) y no esta en la tabla
- L6756 `entrada_sin_fila` — BUG-083 tiene entrada (## 8.1 Bugs Delegados — auditoría reductos (256,) y no esta en la tabla
- L6778 `entrada_sin_fila` — BUG-084 tiene entrada (## 8.1 Bugs Delegados — auditoría reductos (256,) y no esta en la tabla
- L6801 `entrada_sin_fila` — BUG-085 tiene entrada (## 8.1 Bugs Delegados — auditoría reductos (256,) y no esta en la tabla
- L6822 `entrada_sin_fila` — BUG-086 tiene entrada (## 8.1 Bugs Delegados — auditoría reductos (256,) y no esta en la tabla
- L1050 `entrada_sin_fila` — BUG-090 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L7097 `entrada_sin_fila` — BUG-099 tiene entrada (## 8.4 Delegados - hallazgos colaterales del fre) y no esta en la tabla
- L7128 `entrada_sin_fila` — BUG-100 tiene entrada (## 8.4 Delegados - hallazgos colaterales del fre) y no esta en la tabla
- L2952 `entrada_sin_fila` — BUG-120 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L629 `entrada_sin_fila` — BUG-121 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L2870 `entrada_sin_fila` — BUG-122 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L2962 `entrada_sin_fila` — BUG-123 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L2977 `entrada_sin_fila` — BUG-128 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L7250 `entrada_sin_fila` — BUG-134 tiene entrada (## 8.4 Delegados - hallazgos colaterales del fre) y no esta en la tabla
- L7319 `entrada_sin_fila` — BUG-135 tiene entrada (## 8.5 Delegados — auditoría Patrón D de M160 (D) y no esta en la tabla
- L3024 `entrada_sin_fila` — BUG-140 tiene entrada (## 6. Bugs Abiertos (pendientes)) y no esta en la tabla
- L0 `etiqueta_severidad_inconsistente` — severidad 'baja' con 2 etiquetas distintas: Baja x1, Mayor x1
- L0 `etiqueta_severidad_inconsistente` — severidad 'critica' con 4 etiquetas distintas: Alta x7, Crítico x4, Critica x2, Crítica x2
- L0 `etiqueta_severidad_inconsistente` — severidad 'menor' con 2 etiquetas distintas: Menor x31, Media x13
- L0 `etiqueta_severidad_inconsistente` — severidad 'trivial' con 2 etiquetas distintas: Trivial x4, Invalido x1
- L0 `dashboard_divergente` — docs/bug_metrics.md declara 0 bugs abiertos y el registro local tiene 25 no resueltos (abierto=14, delegado=7, en_progreso=4)

