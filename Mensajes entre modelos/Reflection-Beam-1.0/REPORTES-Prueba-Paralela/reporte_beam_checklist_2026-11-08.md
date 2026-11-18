# Reporte de Análisis de CHECKLIST-GLOBAL.md

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Archivo analizado:** `CHECKLIST-GLOBAL.md` (raíz del proyecto)

## 1. Módulos con estado 🔵/🔴 sin actividad reciente

Se detectaron **12 filas** con estado `🔵 En curso` (ninguna `🔴`). Todas tienen última actividad anterior al 2026-10-31, por lo que superan el umbral de 24 h de la regla 21.4 y deben considerarse bloqueos huérfanos o colgados.

| Línea | ID | Módulo | Estado | Progreso | Última actividad | Agente |
|-------|----|--------|--------|----------|------------------|--------|
| 83 | 139 | 139-Pre-Alpha | 🔵 En curso | 139/142 | 2026-10-14 02:20 | Hy4 |
| 106 | 158 | 158-Herramientas-Y-Desbloqueo-De-Zonas | 🔵 En curso | 83/140 | 2026-09-04 03:50 | agnes-3-flash |
| 107 | 159 | 159-Catalogo-De-Objetos | 🔵 En curso | 105/147 | 2026-10-18 11:30 | agnes-3-flash |
| 111 | 161 | 161-Diseno-Visual-De-NPCs | 🔵 En curso | 134/138 | 2026-10-22 | agnes-3-flash |
| 119 | 17 | 17-Construccion | 🔵 En curso | 135/175 | 2026-10-27 21:40 | minimax-m3-1-flash |
| 122 | 20 | 20-Sistema-De-Amistad | 🔵 En curso | 102/150 | 2026-10-27 20:25 | minimax-m3-1-flash |
| 125 | 23 | 23-Historias-Secundarias | 🔵 En curso | 89/105 | 2026-10-26 02:40 | DeepSeek-V4.1-Flash |
| 135 | 33 | 33-DOMINIO (referencia) | 🔵 En curso | 143/155 | 2026-10-25 | Step-5-WorkBuddy |
| 143 | 41 | 41-... | 🔵 En curso | 60/110 | 2026-10-16 20:20 | — |
| 147 | 45 | 45-... | 🔵 En curso | 157/171 | 2026-10-13 16:50 | agnes-3-flash |
| 152 | 49 | 49-... | 🔵 En curso | 110/143 | 2026-10-16 18:30 | — |
| 162 | 59 | 59-... | 🔵 En curso | 118/130 | 2026-10-30 06:05 | — |

Casos críticos:
- **M158 (línea 106):** última actividad 2026-09-04, 65 días sin movimiento. Bloqueo huérfano claro.
- **M139 (línea 83):** existe otra fila del mismo ID en estado `🟡` (línea 81) con progreso 138/142, generando **conflicto de identidad** del módulo.
- **M159 (línea 107):** declara cierre 300/300 pero sigue `🔵` por QA pendiente; agente actual agnes-3-flash sin liberar.

## 2. Discrepancias entre progreso declarado y [x] reales

### 2.1 Filas con progreso igual al total pero sin estado ✅

| Línea | ID | Progreso | Estado declarado |
|-------|----|----------|------------------|
| 29 | 05 | 103/103 | 🟡 Con dudas |
| 58 | 21 | 143/143 | 🟡 Con dudas |
| 60 | 119 | 124/124 | 🟡 QA-drift-doc |
| 65 | 126 | 101/101 | 🟡 Con dudas |
| 68 | 128 | 100/100 | 🟡 Con dudas |
| 72 | 142 | 129/129 | 🟢 Disponible |
| 73 | 143 | 111/111 | 🟢 Disponible |
| 75 | 146 | 100/100 | 🟡 Con dudas |
| 85 | 150 | 150/150 | 🟡 Con dudas |
| 86 | 153 | 130/130 | 🟡 Con dudas |
| 96 | 36 | 228/228 | 🟡 Completado |
| 99 | 71 | 213/213 | 🟡 Con dudas |
| 100 | 74 | 285/285 | 🟡 Con dudas |
| 101 | 92 | 185/185 | 🟡 Con dudas |
| 102 | 95 | 115/115 | 🟡 Con dudas |

Estas filas contradicen la regla 21.6 (un módulo con progreso = total y sin `[?]` debería estar en `✅`). En varios casos las notas indican deuda externa o `[?]` honestos (ej. M05: "4 [ ] deuda"; M150: "deuda implementación"), lo que explica el `🟡`, pero el conteo declarado no refleja los pendientes.

### 2.2 Filas duplicadas (mismo ID, dos filas)

| Líneas | ID | Estado A | Estado B | Progreso |
|--------|----|----------|----------|----------|
| 52-53 | 115 | 🟡 Con dudas | 🟢 Disponible | 78/104 ambas |
| 66-67 | 127 | 🟡 Con dudas | 🟢 Disponible | 76/100 ambas |
| 81,83 | 139 | 🟡 Con dudas | 🔵 En curso | 138/142 vs 139/142 |
| 93-94 | 148 | 🟡 Con dudas (x2) | — | 115/117 ambas (agentes distintos) |
| 150-151 | 48 | 🟡 Con dudas (x2) | — | 115/123 ambas |

Esto viola la unicidad de la tabla (una fila por módulo) y genera ambigüedad sobre quién trabaja qué.

### 2.3 Drift de columnas / conteo

- **Línea 25 (M02):** la columna "Estado" contiene `164/172` (un número) en lugar de un emoji de estado; el progreso real parece ser `165/172`. Drift de columnas.
- **Línea 49 (M112):** aparecen dos valores de progreso (`228/232` y `221/225`) en columnas consecutivas.
- **Línea 33 (M09):** declara `110/115`, pero las notas indican canon `108/0/5 = 113`.
- **Línea 34 (M10):** declara `90/106`, con 16 `[?]` (canon real `90/0/16 = 106`, coincidente pero con `[?]` abiertos).
- **Línea 107 (M159):** la fila contiene mojibake (`ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â`) por problema de codificación UTF-8 (AGENTS.md §28).
- **Línea 96 (M156):** `223/307` con 47 `[?]` y 39 `[ ]` abiertos; progreso declarado no cuadra con la suma documentada (221/39/47).

## 3. Módulos con `[?]` que deberían estar resueltos

Módulos con cantidad significativa de `[?]` que bloquean el sello `✅` (DoD §21.6) y que, según las propias notas, tienen causas ya identificadas o deuda trivial:

| ID | Línea | Progreso | `[?]` aprox. | Causa documentada |
|----|-------|----------|--------------|-------------------|
| 01 | 24 | 73/152 | 46 módulos con `[?]` (767/970 `[?]` totales) | Bloqueo real son los `[?]`, no los `[ ]` |
| 09 | 33 | 110/115 | 5 | Copyright liberado, resto intacto |
| 10 | 34 | 90/106 | 16 | Faltan 3 capas del pipeline; snow inalcanzable |
| 103 | 39 | 173/179 | 6 | SB-02 (DoD violada, bajado de ✅) |
| 105 | 41 | 143/171 | 45 | Justificados (dependencias reales) |
| 106 | 42 | 194/206 | 12 | P-36 cerró deuda, queda 🟡 por DoD estricta |
| 110 | 47 | 179/225 | 75 | UI pendiente (dueño M110-UI) |
| 122 | 61 | 254/264 | 20 | Externos con dueño (M117, M61, M90, etc.) |
| 128 | 68 | 100/100 | 4 | theme_ux.gd paleta ≠ M128 §3; 0 assets brand/ |
| 131 | 73 | 86/95 | 9 | 0 archivos de audio en el proyecto |
| 137 | 79 | 118/131 | 7 | Deuda externa (M114/M138) |
| 141 | 85 | 146/147 | 1 | L95 6 idiomas M87 (deuda conocida) |
| 146 | 91 | 100/100 | 9 | Playtesting con jugadores (imposible headless) |
| 154 | 102 | 149/155 | 3 (3 [ ]) | L109 no instancia jugador; L114 bug colisión nombres |
| 164 | 114 | 120/129 | 9 | gem_save sin registrar |

También hay módulos marcados `✅` con `[?]` no bloqueantes documentados (M116: 23, M120: deuda no bloqueante, M123: 2, M130: 2 tachados, M167: 1 shore-fade), lo que es aceptable bajo DoD si están justificados, pero requiere verificación de que no sean inflación (BUG-070).

## 4. Acciones de corrección sugeridas

1. **Saneamiento de bloqueos y unicidad de la tabla (prioridad alta):**
   - Consolidar las 5 filas duplicadas (M115, M127, M139, M148, M048) en una sola fila por ID, conservando la de mayor progreso y el agente activo real; eliminar la fila huérfana.
   - Liberar los 12 bloqueos `🔵` sin actividad >24 h (regla 21.4): M158 (65 días), M139, M41, M45, M49 y los demás; actualizar `Agente actual` a `—` y estado a `🟡` o `🟢` según corresponda, y registrar la liberación en `ESTADO-PARALELO.md`.
   - Resolver el conflicto de M139 (dos filas con progreso distinto) eligiendo el conteo medido en disco (139/142) y un único agente.

2. **Regeneración y verificación de consistencia (prioridad alta):**
   - Ejecutar `python scripts/generar_checklist_global.py --dry-run` y luego la escritura real para sincronizar la columna `Progreso` con el conteo real de `[x]` en cada `05-Checklist.md`, preservando las columnas manuales.
   - Corregir manualmente los defectos de columna: M02 (falta emoji de estado), M112 (doble columna de progreso), M159 (mojibake UTF-8, reescribir en UTF-8 sin BOM).
   - Ejecutar `python scripts/verificar_checklist.py` para confirmar 0 alertas y, para los módulos con `[?]` honestos en estado `✅`-cercano (M105, M106, M122, M09, M10), aplicar el muestreo anti-inflación §21.8.2.b (≥5 ítems `[x]` con verbo de creación verificados contra disco) antes de otorgar sello.

## Conclusión final

El `CHECKLIST-GLOBAL.md` está **operativo pero con deuda de higiene significativa**: 12 bloqueos `🔵` huérfanos, 5 IDs duplicados, ~15 filas con progreso = total pero sin `✅`, y múltiples drifts de columna/conteo (M02, M112, M09, M159). La mayor parte de los `[?]` son honestos y tienen dueño documentado, pero la tabla no refleja fielmente el estado real del disco. Se recomienda ejecutar el ciclo de saneamiento (consolidar duplicados + liberar bloqueos + regenerar con el script) antes de continuar con nuevas reservas de módulos, para evitar que los agentes trabajen sobre filas inconsistentes.
