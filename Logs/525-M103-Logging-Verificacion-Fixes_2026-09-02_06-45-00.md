# Log 525: M103 Logging — Verificación 14/14 + fixes (escritura inmediata + test colgado)

**Fecha:** 2026-09-02
**Hora:** 06:45
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Verificación del módulo M103 (Logging) desde la metodología TAREAS-POR-MODELO: el GameLogger funciona, pero se detectaron y corrigieron 2 problemas reales: (1) las líneas de log no llegaban al archivo hasta 100 líneas de buffer (invisible para el QA por logs y ante un crash), ahora escritura inmediata con flush; (2) el test nunca terminaba (faltaba `_summary()` → proceso colgado).

## Cambios Realizados

### Fix 1 — logger.gd (crítico)
- El hot-path de escritura usaba `log_buffer.append(line)` + flush cada 100 líneas: un crash perdía las últimas líneas y el QA por logs (M101/M103) no veía los mensajes recientes.
- **Ahora:** `_file.store_line(line); _file.flush()` en cada llamada (los logs de diagnóstico quedan en disco al momento; se preservan rotación y `_flush`).

### Fix 2 — test_logging_m103.gd
- El test terminaba después del último check sin llamar `_summary()` ni `quit()` → el proceso quedaba colgado (timeout). Se añadió `_summary()` al final.

## Verificación

- `test_logging_m103.gd` → **14/14 checks OK, exit 0** (antes: 14 OK + 1 FAIL de contenido + proceso colgado).
- Verificado que las líneas [INFO]/[WARNING] aparecen en el archivo en el mismo frame.

## Archivos Modificados/Creados

- Modificados: `scripts/logging/logger.gd` (flush inmediato), `scripts/logging/test_logging_m103.gd` (_summary), `DOCUMENTACION/103-Logging/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md` (fila 103 → 🟡 27/178), `Logs/ULTIMO_NUMERO.txt` (→525)
