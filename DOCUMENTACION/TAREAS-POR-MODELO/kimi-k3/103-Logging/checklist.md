**Modelo:** kimi-k3 (Moonshot AI)
**Plataforma:** Kilo Code
**Modulo:** 103-Logging
**Fuente:** `DOCUMENTACION/103-Logging/plan-actual/05-Checklist.md` (fuente de verdad)
**Total:** 12 tareas (0 pendientes + 12 con dudas)

## Reglas
- Marcar `[x]` SOLO con evidencia (log + test headless rc=0 o verificacion binario real).
- `[?]` = no resuelto, con razon y dueno. `[→]` = movida a otro modelo.
- Al completar T-###: actualizar tambien el `05-Checklist.md` del modulo y la fila de CHECKLIST-GLOBAL.
- Reservar log: `python scripts/reservar_log.py --reservar --agente kimi-k3 --modulo 103`.

## Tareas

- [?] T-001 RF18: crash reporting integración [S] -- [?] — integración con M122 (Crash Reporting) NO implementada: el módulo consumidor no existe todavía. Diseño especificado en 03-Diseno.md §8.
- [?] T-002 Definir buffer de escritura (performance) [S] -- [?] — iter. 1 (2026-09-15): el buffer de escritura se RETIRÓ por ser código muerto; la escritura es inmediata + flush por línea (mejor para el crash-proof). El objetivo de rendimiento se cubre con is_level_enabled(); revisable si M61 mide impacto.
- [?] T-003 Definir flush periódico (cada 100 líneas o 1s) [S] -- [?] — no hay flush periódico (100 líneas / 1 s): desde el fix del 2026-09-02 se hace flush por línea. La rotación se controla con el contador incremental _bytes_written.
- [?] T-004 Definir generación de bug_{timestamp}.log para issues [S] -- [?] — no existe definición de bug_{timestamp}.log: solo export_{timestamp}.log (LogExporter) y crash_{timestamp}.log (diseño M122).
- [?] T-005 Definir búsqueda de texto [S] -- [?] — no hay API de búsqueda de texto en logger.gd; depende de la consola in-game (M53/M110).
- [?] T-006 Definir scroll en consola in-game [S] -- [?] — sin consola in-game propia; depende de M110 (Debug Menu).
- [?] T-007 Definir coloreado por nivel (INFO=blanco, ERROR=rojo) [S] -- [?] — iter. 1: se retiró la nota previa que afirmaba «colores definidos en logging_config.gd»: logging_config.gd NO define colores (verificado). El coloreado depende de M110.
- [?] T-008 Definir timestamp relativo (hace X segundos) [S] -- [?] — solo timestamps absolutos; el relativo exigiría calcular un delta por línea.
- [?] T-009 Definir impacto máximo en frame budget (< 0.5%%) [S] -- [?] — impacto en frame budget NO medido; corresponde a M61 (Rendimiento). El diseño (§10 Regla 5) evita allocaciones en hot path, pero no hay medición.
- [?] T-010 Criterios de aceptación cumplidos [M] -- [?] — de los 5 criterios de aceptación de 01-Requerimientos.md §4, el nº4 (integración con M102 para adjuntar logs a issues) no está implementado.
- [?] T-011 Implementar buffer + flush periódico (cada 100 líneas) para performance [M] -- [?] — igual que el ítem G de diseño: el buffer de 100 líneas se retiró (código muerto). Escritura inmediata + flush por línea.
- [?] T-012 Regresión completa: 6 tests de economía/tiendas/tiempo con 0 fallos tras el autoload (Godot 4.7.2) [S] -- [?] — verificado 2026-09-15: 5 de 6 pasan (test_m38_economia_smoke, test_barter, test_tiendas, test_consumidores_tiempo, test_reloj_hud); test_loop_economico.gd da 14/1 por «precio compra definido», un fallo de ECONOMÍA (M38) ajeno a M103 — probado por dependencia: ese test no referencia GameLogger. Además hay cambios sin commitear de otro agente en scripts/economia/.
