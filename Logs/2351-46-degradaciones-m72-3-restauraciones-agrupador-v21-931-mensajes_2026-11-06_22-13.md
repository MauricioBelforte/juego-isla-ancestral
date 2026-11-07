# Log 2351: 46 degradaciones, 3 restauraciones con evidencia y agrupador de canales v2.1

**Fecha:** 2026-11-06
**Hora:** 22:13
**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode
**Canal:** `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` (mensaje 250)
**Rol:** gate-1 (auditor). **No sella.**
**Continua:** Log 2317 (censo de drift corregido v2.3).

---

## Resumen

Ejecutado el GO de agnes-3-flash (mensaje 246): 46 degradaciones gate-1 en M27/M72/M56/M112, revision
item-por-item de M72 (3 restauraciones con evidencia en disco), rechazo de normalizacion de M28, y
parche + ejecucion del agrupador de canales con long-path (931 mensajes archivados, idempotente).

## 1. Degradaciones aplicadas (46)

| Modulo | Antes | Despues | Detalle |
|---|---|---|---|
| 27-Islas-Del-Mundo | 189/0/3 | 152/0/40 | 37 flips `spec en` que eran `[?]` antes (commit 3a3d32c) |
| 72-Sistema-De-Logros | 200/0/0 | 197/1/2 | 6 flips, 3 restaurados con evidencia |
| 56-Fotografia | 132/5/1 | 130/7/1 | 2 flips `[ ]`->`[x]` (el tercero ya era `[x]`) |
| 112-Testing-Automatico | 232/0/0 | 228/0/4 | 4 reversiones de degradaciones BUG-070 LOTE 13 |

Respaldo por archivo: `DOCUMENTACION/<modulo>/plan-actual/Obsoletos/2026-11-06_22-12-41_05-Checklist.md`.

## 2. M72 item por item

Restaurados a `[x]` (evidencia en `game/isla-ancestral/`):

- L55: `data/logros/logros.json` (18 logros) + `_cargar_catalogo()`.
- L112: `get_save_data()`/`restore_save_data()` + `_registrar_proveedor_guardado()` (contrato M59),
  probado en `test_logros.gd::_test_guardado_carga_rf9_rn8`.
- L243: `test_logros.gd::_test_desbloqueo_por_evento` usa `Historia.marcar_sello` y verifica
  `logro_primer_sello`/`logro_siete_sellos`.

Sostenidos:

- L137 `[?]`: `locales/es.po` tiene 0 claves `LOGROS.*` (18 declaradas en el catalogo).
- L162 `[?]`: `validar_catalogo()` existe, pero el tool de editor esta pendiente de M117/M118 (lo dice
  el propio item; no hay `@tool` de logros).
- L244 `[ ]`: sin test de M37; el candidato `test_progresion.gd` L188 usa `or true` (infalsificable).

## 3. M28 no se normaliza

68 ascensos con implementaciones sin evidencia (`Curve3D baked`, `sample_position(t)`,
`compute_duration_with_weather`, `Balanceo y cabeceo`, `Estela WakeFX`) y notas "pendiente integracion
M27" / "dueno M53/M69". Normalizar ratificaria inflacion.

## 4. Censo post-degradaciones

`scripts/censo_drift_totales.py` v2.3 (read-only): 87 limpios | tipo A 79 (+1130) | tipo B 2 (-6) |
tipo C 0 | sin Totales 0.

Top-5: M72 +89, M28 +76, M56 +70, M92 +53, M12 +43. M27 sale del top (+17); M112 queda limpio.

## 5. Higiene de formato

El script de degradacion habia dejado `- [?]Texto` (sin espacio tras `]`) en las 46 lineas. Corregido;
los conteos no cambiaron. CRLF y UTF-8 sin BOM preservados.

## 6. Agrupador de canales v2.1

- Respaldo: `scripts/Obsoletos/2026-11-06_22-11-01_agrupar_canales.py` (v1) y
  `2026-11-06_22-12-29_agrupar_canales.py` (v2.0).
- `lp()` long-path + `--dry-run` + `makedirs` antes del rename.
- Dry-run v2.0: 857; ejecutado: 857 (10 canales).
- Defecto v2.0: maximo solo en raiz; agnes-3-flash (raiz 001-076, archivos hasta 991) dejaba 74
  mensajes viejos. v2.1 usa `os.walk` recursivo.
- Dry-run v2.1: 74; ejecutado: 74. Segunda pasada: 0.
- **Total: 931 mensajes, 12 subcarpetas, 0 skips.** Pools intactos; maximos recursivos verificados.

## 7. Archivos

- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md` (37 degradados)
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md` (6 degradados, 3 restaurados)
- `DOCUMENTACION/56-Fotografia/plan-actual/05-Checklist.md` (2 degradados)
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md` (4 degradados)
- `scripts/agrupar_canales.py` (v2.1)
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/250-...md`
- `Logs/NUMEROS_DISPONIBLES.txt` (consumido 2351)
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/NUMEROS_DISPONIBLES.txt` (consumido 250)

**No se toco `CHECKLIST-GLOBAL.md`. Sin commit: cambios en working tree.**
