# Log 1600: M3 — CJK + BOM residuales clasificados (192+2 = TODO PROT/legítimo, módulo sellable)

**Fecha:** 2026-10-10
**Hora:** 16:12
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo msg 105 (director): auditar los CJK + BOM residuales de M3 y clasificar cada uno
(PROT/stale legítimo vs mojibake real). Resultado: **192 CJK en 29 archivos + 2 BOM, TODOS
PROT/legítimos** — cero en el alcance accionable de mimo. El crecimiento 109→192 desde la
medición de M3 se explica por la propia documentación del trabajo (log 1586, msg 100, msg 101:
citas intencionales de los tokens CJK discutidos, misma clase que AGENTS.md documentando el
síntoma). **M3 es sellable** según la condición del director ("si los 109 son todos PROT/stale,
cerrá M3 con el reporte honesto").

## Medición actual (gate SB-06 + verificar_bom)

| Herramienta | Resultado |
|---|---|
| `verificar_cjk.py` (gate) | **29 archivos / 192 CJK**; 0 ilegibles; 2 BOM |
| `verificar_bom.py` | **1 BOM** en alcance vivo: `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` |
| Escaneo directo BOM | 2 reales vivos: s2 pool + fixture `m87_val_bom.po` (intencional, documentado en `verificar_bom.py`) |

## Desglose de los 192 CJK (29 archivos) — clasificación por archivo

**Todos PROT/stale. Cero en alcance mimo (scripts/, docs propios, etc.).**

### 6 backlogs ajenos (13 hits) — PROT: nunca se tocan (otros modelos)
| Archivo | Hits | Contenido |
|---|---|---|
| `agnes-2.5-flash/083-83-Licencias-De-Software/checklist.md` | 2 | `NO许可` (licencia) — mojibake en backlog ajeno |
| `agnes-2.5-flash/083-Licencias-De-Software/checklist.md` | 2 | `许可` en título |
| `agnes-2.5-flash/155-155-Vestimenta-Y-Accesorios/checklist.md` | 2 | `鼠标` (cursor) en tarea T-155-005 |
| `atria-dawn-s2/familia_b_slice_2026-09-20.txt` | 1 | `dueño` → `due帽o` (mojibake ñ) |
| `atria-dawn-s2/overmarks_clasificacion_2026-09-20.txt` | 1 | `due帽o` (mojibake ñ) |
| `step-3.7-flash/FAMILIA-B-REPLANIFICACION.md` | 1 | `due帽o` (mojibake ñ) |

### 9 Logs (94 hits) — PROT: histórico, §28.1 excluye Logs/
| Archivo | Hits | Contenido |
|---|---|---|
| `Logs/1586-M3-limpieza-...` | **64** | **Citas intencionales** de los tokens documentados (貿=ó, 帽=ñ, 目标→posición, etc.) — mi propio log de la limpieza |
| `Logs/1300-utf8-tres-mojibakes-reales` | 15 | Cita del CJK intencional de space-bunny (documentación del gate) |
| `Logs/904-HY4-AUDITORIA-...` | 4 | Citas de mojibake corregido (`Implementaci脱n` etc.) |
| `Logs/104-M83-Licencias-...` | 3 | `GPL-3允许` — mojibake viejo sin corregir (histórico) |
| `Logs/1157-P41-M119-...` | 2 | Documenta corrección de mojibake (帽=ñ, 贸=ó) |
| `Logs/231-M166-QA-...` | 2 | `场景` (escena) — mojibake viejo |
| `Logs/713-AGNES-BUCLE-P3-CLOSE` | 2 | `material问题` — mojibake viejo |
| `Logs/918-M103-Logging-...` | 1 | `IMPLEMENTACI脫N` — documenta mojibake |
| `Logs/1307-SB09-SB10-...` | 1 | `「se ve roto」` — cita CJK intencional |

### 11 Mensajes (81 hits) — PROT: mensajes de otros agentes / director + ESTADO
| Archivo | Hits | Contenido |
|---|---|---|
| `space-bunny-alpha/14-...sb06...` | 28 | Citas del CJK que documenta su gate (intencional) |
| `space-bunny-alpha/21-...utf8...` | 15 | Citas de CJK intencional de sb13 (intencional) |
| `mimo/100-...m3-cjk-bom...` | 17 | **Mi propio informe** citando los tokens limpiados (貿=ó, 目标→posición, etc.) |
| `atria-dawn-s2/10-...ci-rojo...` | 5 | `第一次` + `证据` — mojibake en msg de s2 |
| `space-bunny-alpha/03-...sb01...` | 4 | Cita de `自由` (libre) de M145 |
| `Hy3/69-...bug118...` | 3 | `独立性` — mojibake en msg de Hy3 |
| `ESTADO-PARALELO.md` | 3 | `IMPLEMENTACI脫N` + `自由` (citas de reportes) |
| `atria-dawn-s3/113-...` | 2 | `非洲` — mojibake en msg de s3 |
| `atria-dawn-s3/149-...` | 2 | `理由` — mojibake en msg de s3 |
| `atria-dawn-s3/152-...` | 2 | ` huella` — mojibake en msg de s3 |
| `atria-dawn-s2/96-...` | 2 | `测试` — mojibake en msg de s2 |
| `mimo/101-...m3-aceptado...` | 2 | Msg del director citando貿=ó, 帽=ñ |
| `mimo/55-...m163-iter2...` | 2 | `【】` — brackets CJK en msg del director |

### 1 legal/evidencia (2 hits) — PROT: rompe `.sha256` si se toca
| Archivo | Hits | Contenido |
|---|---|---|
| `legal/evidencia/autoria-repo_...txt` | 2 | `修复` en historial git de commits |

## Desglose de los 2 BOM

| # | Archivo | Clasificación |
|---|---|---|
| 1 | `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` | **PROT — backlog/pool ajeno.** Preexistente (no lo toqué). El director arregló los pools míos (mimo + Logs) en M3; el de s2 sigue con BOM — territorio de s2, no mío. |
| 2 | `game/isla-ancestral/Godot/app_userdata/isla-ancestral/m87_val_bom.po` | **Legítimo intencional** — es el fixture con el que se prueba el validador de .po (documentado en `verificar_bom.py`: "No se debe arreglar"). |

## Por qué 109 → 192 (crecimiento explicado, no regresión)

La medición de M3 (109/26) se tomó **antes** de escribir los artefactos de cierre, que
documentan los tokens como ejemplos (citas intencionales, misma clase que AGENTS.md §28):

| Artefacto | CJK hits | Cuándo |
|---|---|---|
| Medición M3 (gate post-limpieza) | 109 | 2026-10-10 03:24 |
| `Logs/1586` (log de la limpieza) | +64 | escrito después |
| `msg 100` (informe M3) | +17 | escrito después |
| `msg 101` (respuesta del director) | +2 | escrito después |
| **Total actual** | **192** | |

Archivos: 26 + 1 (log 1586) + 1 (msg 100) + 1 (msg 101) = 29. **El conteo NO subió por
regresión de codificación sino por documentación legítima del propio trabajo.**

## Veredicto

- **CJK: 192/29 = 100% PROT/stale/intencional.** 0 en alcance mimo. No hay mojibake real
  accionable pendiente.
- **BOM: 2 = 1 pool ajeno (s2) + 1 fixture intencional.** 0 BOM en archivos que yo toqué.
- **M3 queda SELLABLE** (condición del director msg 105 cumplida). El único "trabajo"
  pendiente sería limpiar CJK de canales/backlogs ajenos — **PROHIBIDO** (nunca se tocan
  archivos de otros modelos; §10.2).

## Nota sobre el checklist pedido

El director pidió leer `DOCUMENTACION/3-.../plan-actual/05-Checklist.md`. **M3 no tiene
carpeta de módulo propia** (es una tarea transversal de encoding, no un módulo de juego):
su contexto vive en `Logs/1586`, la entrada del backlog de mimo y el propio gate SB-06.
No existe `DOCUMENTACION/3-.../` con plan-actual para M3.

## Archivos Modificados/Creados

- `Logs/NUMEROS_DISPONIBLES.txt` (reserva 1600)
- (lecturas: gate `verificar_cjk.py`, `verificar_bom.py`, escaneos directos)

## Siguiente

Informe msg 106 al director. Sin flips (M3 sellado por director si acepta el reporte).
Cola: gate `.gitignore` anidados (baja, pendiente de OK).
