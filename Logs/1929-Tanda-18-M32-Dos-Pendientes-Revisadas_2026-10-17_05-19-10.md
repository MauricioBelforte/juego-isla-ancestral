# Log 1929: Tanda 18 — M32: las 2 [?] del front del clima revisadas + INCIDENCIA (BACKLOG truncado y restaurado)

**Fecha:** 2026-10-17
**Hora:** 05:20
**Modelo:** DS-V4.1-Flash-Opencode
**Plataforma:** OpenCode

## Resumen
Vuelta 10 (V2). Ítem 26 de mi cola ("M32: las 2 [?] pendientes del front"): REVISADAS con evidencia fresca — los 2 [?] siguen legítimos (auditoría previa Log 1900 re-verificada): RF5 (partículas GPU) = dueño M52 (estado amarillo); RF8 (efectos vegetación/agua/nieve) = sin implementar en ningún módulo. Greps NEGATIVOS frescos: 0 hits de partículas en scripts/clima/; 0 hits de sway/viento en scripts/vegetacion/. Suites rc=0, 0 SCRIPT ERROR: test_clima 29/0 + test_farm_clima 20/0 + test_fishing_clima 0 fallos (out/tanda18/). Pedido de ruteo RF8 al director (msg 050).

## INCIDENCIA — BACKLOG truncado a 0 bytes y restaurado (importante)
**Intento 1:** mi script pn117 truncó el BACKLOG-MASTER.md a 0 bytes — el emoji iba como par surrogate escapado y `open(...,"wb")` trunca ANTES de evaluar el `.encode()`, que falló → archivo vaciado. Nada más del cierre había corrido (pools/marcador intactos).
**Restauración:** base = último commit del director (e5ebbae, 04:14) + re-aplicación MECÁNICA de mis 17 marcas T9-T18 desde los scripts de cierre originales (pn65/85/90/94/98/101/108/113/117), verificadas línea a línea (diff = exactamente 17 líneas: [38-46] y [242-259]). Backups en %TEMP%/bk-backups (BK-EMPTY, BK-head, BK-restored). Nota fiel: el dup 65 (L246, presupuesto) quedó sin marca como en el original (T12 marcaba solo la copia de la cola).
**Intento 2:** el mismo patrón de surrogate tumbó el encode del Log/msg DESPUÉS de consumir pools → reintento 3 con sanitizador anti-surrogates (adoptado).
**Pedido al director:** si hizo ediciones propias en ese archivo después de las 04:14, re-aplicarlas (no son recuperables desde acá).
**Mitigación permanente:** encode-antes-de-abrir + os.replace mismo volumen + copia previa de BK a bk-backups + sanitizador de surrogates en cada cierre.

## Cambios Realizados
- M32: 3 corridas headless (out/tanda18/) + 2 greps negativos frescos; marcas Tanda 18 en BACKLOG (items 26+72).
- Restauración del BACKLOG (17 marcas T9-T18) + backups + mitigaciones.
- 2 [?] del checklist de M32 NO se flipean (siguen honestos); el ítem de mi cola cierra como revisión completada.

## Archivos Modificados/Creados
- DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md (restaurado + marcas T18)
- Mensajes entre modelos/DS-V4.1-Flash-Opencode/050-... (informe + incidencia)
- Logs/1929-... (este log)
- out/tanda18/ (evidencia; gitignored)
