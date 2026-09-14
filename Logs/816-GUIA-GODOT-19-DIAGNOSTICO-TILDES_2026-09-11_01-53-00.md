# Log 816: Guía temática 19 — Diagnóstico de tildes (freeze)

**Fecha:** 2026-09-11
**Hora:** 01:53
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
A pedido del usuario se creó el archivo específico de GUIA-GODOT para diagnosticar y solucionar tildes del juego, consolidando todo el conocimiento anti-freeze documentado (Logs 758-814, errores E-17 a E-19).

## Cambios Realizados
- **Creado** `DOCUMENTACION/GUIA-GODOT/19-diagnostico-tildes.md`: clasificación de síntomas, catálogo de causas C-01 a C-11 (autoloads huérfanos, scripts duplicados autoload+escena, quit() programado, TRANSPARENCY_ALPHA, get_voxel sincrónico, noise por voxel, suelo fantasma, timers fijos, parse error, overdraw del impostor, InputMap inexistente), protocolo de diagnóstico en 7 pasos, lista de autoloads legítimos, comandos PowerShell, checklist de 10 puntos y registro histórico de tildes resueltos (Logs 802/805/807/814).
- **Actualizado** `DOCUMENTACION/GUIA-GODOT/INDICE.md`: nueva fila 19 en "Avanzados (16-19)" + firma renovada.
- **Actualizado** `AGENTS.md` §2b: referencia a la guía 19 con la regla de leerla antes de tocar código ante un tildo.

## Archivos Modificados/Creados
- `DOCUMENTACION/GUIA-GODOT/19-diagnostico-tildes.md` (nuevo)
- `DOCUMENTACION/GUIA-GODOT/INDICE.md` (fila + firma)
- `AGENTS.md` (§2b, línea nueva)

## Notas
- La reserva 815 estaba tomada por glm-5.3 (M13-Herramientas, T-019) → se usó 816 (protocolo §6.1.d).
- Contenido basado exclusivamente en causas verificadas en juego (Logs 802, 805, 807, 814); sin teoría no probada.
