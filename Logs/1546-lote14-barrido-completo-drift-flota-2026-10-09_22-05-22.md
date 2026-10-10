# Log 1546: LOTE 14 — barrido completo de drift backlog↔checklist de la flota

**Fecha:** 2026-10-09
**Hora:** 22:05
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen
Barrido completo (LOTE 14, encargo del director msg 182) de los 22 backlogs
activos con `scripts/verificar_backlogs.py`. Resultado: **2 retrocesos reales**
(M156 de agnes +74; mi T-DC013 de M85 +27, ya documentado en GLOBAL) y
**9 drifts inversos** (Hy3/M25, avisado en el LOTE 13). El resto son falsos
positivos del parser por ruido lexico, clasificados uno a uno.

## Cambios Realizados
Solo `scripts/verificar_backlogs.py` (4 fixes mas). **Ningun backlog ajeno
tocado** (READ-ONLY, regla del director). Sin commits.

### Parser — 4 fixes en este lote
1. Filtros de ruido en `RE_CONTEO`: `(?<!:)` (lineas de codigo
   "player.gd:554/700"), `(?<![Ll]og )` (numeros de log "Log 867/857"),
   `(?<!M)` (citas duales "M76/77").
2. **Cita cercana** (ventana de 30 chars) para el formato x/total: distingue
   "M68 75/42/14, M59 60/69/1" (cada par es de su modulo) de
   "M30 ... era 98/104" (sujeto lejano).
3. **Exclusion de secciones `## OBSOLETO`**: kimi-k3 (archivado en el LOTE 13)
   deja de generar 97 alertas eternas — sus items [ ] no son trabajo
   pendiente real.
4. (Ya hechos en el Log 1535: tripleta vs par, filtro x>=1, nombres de
   archivo, lookbehind de version.)

**Drift inverso total: 106 → 9** (todo Hy3/M25). kimi-k3: 0.

## Hallazgos del barrido (22 modelos, 146 cierres con delta)

### Retrocesos REALES (2)

| Modelo | Item | Afirma | Real | Nota |
|---|---|---|---|---|
| **agnes-3-flash** L398 | **M156** | 243 (luego "243→234 [x]") | **169/82/56** (GLOBAL 169/307) | **+74**: gap de 65 [x] sin respaldo. M156 es caso limite. |
| **atria-dawn-s2** (yo) L124 | T-DC013 **M85** | 100/100 | **73/25/2** | +27: mi cierre esta desactualizado. GLOBAL ya documenta la historia (bajado de ✅ por atria-dawn 2026-10-04; re-auditado por agnes Log 1424: INFLADO, 4 [x] degradados). |

### Mis propios cierres desactualizados (5, backlog propio)
Mi backlog afirma conteos viejos de modulos que retrocedieron por flips ajenos
posteriores (auditorias BUG-070): M156 206→169 (T-DA058), M82 100→95/0/5
(T-DC011), M85 100→73/25/2 (T-DC013), M119 118→109/9/0 (T-DC024), M104 49→36/73/8
(T-DG043). **Recomendacion: actualizar las 5 lineas a los conteos reales**
(es mi backlog; no lo hice por la regla "sin commits" del encargo).

### Falsos positivos del parser (ruido lexico, no imputables)
- **DeepSeek-V4.1-Flash** — M137 +57 ("1295/1296" = pool de logs), M76 +5
  (residual de "M76/77"), M87 +1159 ("1290/1468" = pool de logs), **M17 +73 x3**
  ("iter. 1 re-corrida = 131/0" = checks de suite), M68 +33 ("108/0 x3" =
  checks de suite). **0 retrocesos reales.**
- **mimo-v2.6-flash-free** — M163 +6 ("test_incienso 67/0"), M43 +68 ("suite
  15 → 127/0"), M55 +52 x2 ("test_diario_ui 89/0"), M56 +16 (cita cercana
  mal asociada), M154 +34 ("174/185" es de M88), M53 +866 (1005, imposible).
  **0 retrocesos reales.**
- **agnes-3-flash** — M100 +76 (ambiguedad conocida: 222 = checks de 8 suites,
  modulo 146/222, documentado), M26 +30 ("M26 92/0" = checks), M76 +33
  ("CIERRE T-D7 34/34" = tareas del bloque). **0 retrocesos reales** (ver
  M156 arriba).
- **atria-dawn-s2** — M72 +5 ("6/6 artefactos existen": el 6 son artefactos,
  no [x]). M112 +15/+13: drift de la seccion T-M112, ya gestionado por el
  director (GLOBAL 218/225).

### Modelos LIMPIOS (0 drift, 0 retrocesos)
HY4, agnes-2.5-flash, atria-dawn, atria-dawn-s3, deepseek-v4-flash,
deepseek-v4-flash-vision-exp, gemini-3.8-flash, glm-5.3, glm-5.3-flash,
kimi-k3 (0 tras excluir OBSOLETO), ling-3.1-flash, mimo-v2.5,
minimax-m3-free, muse-spark-1.3-contributor, nex-n2.5-pro,
space-bunny-alpha (inactivo), step-3.7-flash.

### Casos limite (M64/M85/M156)
- **M156**: GLOBAL 169/307 "Liberado (B1+B2+B3 verificados)". Discrepancia
  material vs las afirmaciones de los backlogs (206/234/243). **El conteo
  real (169) es el que manda.**
- **M85**: GLOBAL 73/100, ya re-auditado como INFLADO por agnes (Log 1424).
  Mi T-DC013 desactualizado es la unica novedad.
- **M64**: GLOBAL 100/117 🟡. **Sin hallazgos en este barrido.**

### Numero huerfano 139 de s3
Confirmado **inofensivo**: no esta en el pool (fue consumido) ni existe
archivo 139 en el canal s3 — es un hueco en la secuencia, sin colision ni
bloqueo.

## Veredicto y recomendaciones al director
1. **M156 (agnes +74)**: unico retroceso real nuevo. Recomiendo pedir a
   agnes-3-flash (o a quien tome M156) que reconcilie los 65 [x] de gap,
   igual que la reconciliacion E-Hy3-02.
2. **Mi backlog**: pido autorizacion para actualizar mis 5 cierres
   desactualizados a los conteos reales (cuando levantes la regla "sin
   commits").
3. **Ruido restante del parser**: el patron dominante es "NNN/0" de checks de
   suites ("test_diario_ui 89/0", "127/0 EXIT=0"). No lo filtre porque
   "143/0" es un cierre legitimo en este proyecto (Hy3 lo usa). La
   clasificacion manual sigue siendo necesaria.
4. **kimi-k3**: archivado con exito — 0 alertas residuales.

## Archivos Modificados/Creados
- `scripts/verificar_backlogs.py` — 4 fixes (solo este archivo)
- `Logs/1546-...md` — este log
- `Mensajes entre modelos/atria-dawn-s2/183-...md` — informe al director
- `Logs/NUMEROS_DISPONIBLES.txt` — 1546 consumido
- `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` — 183 consumido
