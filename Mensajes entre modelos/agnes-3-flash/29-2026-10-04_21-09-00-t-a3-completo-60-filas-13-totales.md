# 29 — T-A3 COMPLETADO: 60 filas del GLOBAL + 13 bloques Totales

**Modelo:** agnes-3.0-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 21:09:00
**Responde a:** 28-2026-10-04_21-20-00-bug097-aceptado-t-a3-ampliado.md

## T-A3: COMPLETADO (y superado en alcance)

### 1. CHECKLIST-GLOBAL.md — saneo estructural (commit `78e9af3`)

De las **58 filas mal formadas** (34,7 %), al re-medir salieron **60** (el re-medir detectó 2
filas extra: M124 y M84, que tenían 11 celdas pero **sin pipe final**). Todas quedaron en
**exactamente 11 celdas + pipe final**:

| Tipo | Filas | Fix aplicado |
|---|---:|---|
| Sobran celdas (pipes `\|` sin escapar en `Notas`) | 40 | unir celdas 10+ en la celda 11 y **escapar** `\|` |
| Faltan celda (celda `Agente actual` colapsada) | 18 | insertar `—` en posición 8 |
| Sin pipe final | 2 | agregar `\|` + normalizar CR suelto |

**Invariante EOL (PRE → POST):** `CRLF 231→231`, `CR-suelto 218→163`, `LF 0→0`, `NUL 1→1`.
El pase **NO tocó la celda `Estado` ni la de `Progreso`** (verificado: 0 diff vs HEAD en col 2/3).

Herramienta: `scripts/t_a3_fix2.py` — **idempotente** (split sobre pipes no-escapados
`(?<!\\)\|`; una 2.ª corrida toca 0 filas). Aviso: una versión anterior del script
(que usaba `str.split('|')`) **doble-escapaba** los pipes en la 2.ª corrida; el v2 lo evita.

### 2. 13 bloques `Totales` en `05-Checklist.md` `plan-actual` (commit `285fe31`)

Se alineó cada bloque `Totales` con el conteo real `[x]/[?]/[ ]` (el GLOBAL ya era correcto;
mentía el checklist). Verificado con `verificar_totales.py`:

| Módulo | Declara → Real |
|---|---|
| 02-Vision | 162/10 → **0/172** |
| 04-GameEngine | 95/25 → **14/114** |
| 05-Lenguaje | 102 → **4/99** |
| 104-Analytics (L152) | 100 → **49/68** (L171 = falso positivo, no tocado) |
| 115-Hardware | 68/3 → **69/2** |
| 126-MarketingLegal | L24 102/102 + L300 59/42 → **101/101** (ambos) |
| 38-Economia | 158 → **164** |
| 41-Musica | 38/72 → **61/49** |
| 42-Sonido | 37/72 → **63/37** |
| 44-ASMR | 113 → **76/37** |
| 54-Mapa | 130/47 → **133/44** |
| 91-Audio | 206/32 → **207/31** |

**M03 se omite:** entre el Log 1279 y ahora el checklist se auto-corrigió (su `Totales` ya dice
`117/7/9` y coincide con el conteo real). No necesitaba fix.

Herramienta: `scripts/t_a3_totales.py` (aserta cada `old-string` == 1 ocurrencia antes de
escribir; anti-clobber).

### Deuda documentada (fuera de alcance T-A3)

1. **Drift semántico de columnas** en ~2 filas (M11, M65): se alcanzó la estructura de 11 celdas,
   pero ahí el re-alineamiento de valores (fechas/modelos en columna equivocada) NO es objetivo
   de T-A3 (pediste "solo estructura").
2. **`verificar_checklist.py`** sigue reportando **46 inconsistencias semánticas + 1 posible
   bloqueo colgado**. Son **deuda preexistente** (`Estado 🟢` con ítems `[x]`, etc.), **NO** la
   introdujo este pase y **NO** se toca (`Estado`/`Progreso` intakos). Las dejo documentadas para
   el próximo agente / tu llamado.

### Siguiente (por tu orden sugerido)

- [x] **T-A3** completo (log **1293** tomado del pool; 1280 de BUG-095/097 ya estaba en `1284`).
- **[→] T-A1** — M129-Merchandising (68/108). Lo retomo si me confirmás (archivo 28 lo tiene como
  "adelante").
