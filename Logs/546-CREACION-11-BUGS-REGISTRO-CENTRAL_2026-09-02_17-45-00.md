# Log 546: Se creó el registro central de bugs 11-BUGS.md

**Fecha:** 2026-09-02
**Hora:** 17:45
**Modelo:** Claude
**Plataforma:** Cline

## Resumen

Por propuesta del usuario, se creó el documento `DOCUMENTACION/11-BUGS.md` como **registro central de problemas y fallas** del proyecto, estilo checklist con el mayor detalle posible. El usuario, los LLM acompañantes y los agentes anotarán aquí los bugs detectados; los modelos que no puedan resolver un bug lo delegan al final del archivo firmando con nombre de modelo, plataforma, fecha y hora.

## Cambios Realizados

- Se creó `DOCUMENTACION/11-BUGS.md` con: propósito, 9 reglas de uso obligatorias, tabla de estados del bug (`[ ]` Abierto / `[→]` En progreso / `[?]` Delegado / `[x]` Resuelto), plantilla de registro de bug de máximo detalle (descripción, pasos para reproducir, comportamiento esperado/actual, entorno, evidencia, intentos, referencias cruzadas, firma y resolución), tabla resumen de bugs, y secciones de bugs abiertos/resueltos/delegados + historial de modificaciones.
- Se actualizó `DOCUMENTACION/README.md`: nueva línea en el árbol de estructura con la referencia a `11-BUGS.md` y firma actualizada (Claude / Cline).
- Se actualizó `AGENTS.md` (sección 3): nueva fila en la tabla de documentos generales para `11-BUGS.md` y nueva subsección `### DOCUMENTACION/11-BUGS.md — Registro Central de Bugs (usuario + LLMs)` con las reglas de registro, firma, delegación, resolución y complementariedad (no reemplaza a 102-Bug-Tracking ni a 07-GUIA-GODOT §8).

## Archivos Modificados/Creados

- `DOCUMENTACION/11-BUGS.md` (creado)
- `DOCUMENTACION/README.md` (actualizado)
- `AGENTS.md` (actualizado)
- `Logs/ULTIMO_NUMERO.txt` (546)
- `Logs/reservas/546-claude-11-BUGS.txt` (creado y luego eliminado al consumirse la reserva)