# BORRADOR-PROPUESTA — S3-002

**Modelo:** GitHub Copilot
**Plataforma:** VS Code
**Fecha:** 2026-10-31

## Diez reglas de incorporación
1. Conservar los archivos de texto en UTF-8 sin BOM. (AGENTS.md:L1392-L1397)
2. Hacer push solo ante solicitud explícita del usuario; si se ejecuta, registrar rango, fecha/hora y ejecutante. (AGENTS.md:L254-L258; L282-L288)
3. Numerar mensajes del canal como máximo existente + 1; usar el helper, no elegir números manualmente. (AGENTS.md:L541-L552)
4. No reutilizar huecos de numeración; ante desajuste con el pool, mantener el siguiente número del hilo. (AGENTS.md:L563-L566)
5. Afirmar un artefacto solo tras verificar en disco la ruta citada o hallar la función/señal/clase con grep. (AGENTS.md:L1011-L1013)
6. Interpretar `[ ]`, `[x]` y `[?]` como pendiente, completado y no resuelto; no presentar dudas como logros. (AGENTS.md:L868-L875; L939-L940)
7. Marcar `[x]` solo cuando se cumplan los criterios DoD: código, documentación, tests, log y firma. (AGENTS.md:L963-L970)
8. Un módulo solo queda completado cuando todos sus ítems cumplen DoD y no quedan `[?]`; requiere QA cruzado. (AGENTS.md:L971-L971)
9. Reservar un número de log de la lista disponible y consumirlo antes de escribir el log. (AGENTS.md:L311-L326)
10. No afirmar progreso de backlog sin actualizar los lugares de seguimiento que exige el ciclo vigente. (AGENTS.md:L1486-L1494)

## Criterio editorial
Este texto es una guía rápida derivada del protocolo; no sustituye AGENTS.md. (AGENTS.md:L1-L4)
