**Modelo:** Claude Opus 4.6 (Thinking)
**Plataforma:** Antigravity

# Log 03 — Nuevas Directivas en AGENTS.md (Checklist 100+, Optimización, Testing Opcional)

**Fecha:** 2026-08-15 22:58:00
**Tipo:** Actualización de protocolo

## Descripción

Se agregaron 3 directivas del usuario al AGENTS.md:

### 1. Regla del Checklist Mínimo de 100 Ítems (Sección 3)
- El `05-Checklist.md` de cada módulo debe tener **mínimo 100 ítems**.
- Las ideas se extraen de `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` (600+ puntos) y `Plan-de-produccion.md`.
- El agente tiene libertad de pensar e imaginar ítems adicionales para el buen funcionamiento del juego.
- Los ítems deben ser específicos, verificables y cubrir: implementación, integración, edge cases, optimización, documentación y polish.

### 2. Archivos de Testing Opcionales (Secciones 3 y 11)
- Se separaron los 5 archivos principales (OBLIGATORIOS) de los 2 de testing (OPCIONALES).
- Los archivos `06-Plan-Testings.md` y `07-Resultados-Testings.md` solo se crean cuando el módulo lo amerita (sistemas complejos, gameplay core, integraciones críticas).
- Al crear la documentación de un módulo nuevo, el mínimo obligatorio son los 5 archivos principales del `plan-inicial/`.

### 3. Priorización de Optimización (Sección 21.4)
- Se agregó la regla 8 a la sección 21.4: "Prioridad absoluta: OPTIMIZACIÓN".
- No hacer por hacer: cada línea de código, mesh, textura y sistema debe estar bien hecho.
- Si un agente no sabe optimizar (LOD, culling, pooling, batching, compresión, frame budget), debe dejar el módulo disponible y buscar otra tarea.
- Documentar limitaciones honestamente en `[?]`.

## Archivos Modificados
- `AGENTS.md` — Secciones 3, 11 y 21.4
- `Logs/ULTIMO_NUMERO.txt` — Actualizado a 3
