# Log 146: Guías de referencia obligatoria antes de codificar o usar herramientas

**Fecha:** 2026-08-24
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen

Se agregó la **Sección 26** al `AGENTS.md` estableciendo de forma explícita y obligatoria que: (1) antes de codificar en Godot, cualquier agente DEBE leer y consultar `DOCUMENTACION/07-GUIA-GODOT.md`; y (2) antes de usar visión/MCP de Godot, DEBE leer y consultar `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`. Además, se reforzó que cualquier nuevo descubrimiento (errores de codificación, trucos del MCP, mejores prácticas) DEBE documentarse en la guía correspondiente para evitar que agentes futuros arranquen de cero y repitan errores.

## Cambios Realizados

### AGENTS.md
- **Agregada Sección 26** ("Guías de Referencia Obligatoria Antes de Codificar o Usar Herramientas") al final del archivo (después de la Sección 25 sobre Visión del Agente).
- **Actualizada tabla de Sección 3** (estructura de `DOCUMENTACION/`): agregadas filas para `06-GUIA-DE-CONEXION-VISION.md` y `07-GUIA-GODOT.md` en la tabla de la raíz de DOCUMENTACION/, para que agentes las vean directamente desde el AGENTS.md.
- La nueva sección establece:
  - **Guía Godot (07):** propósito, uso obligatorio (leer antes de escribir código, verificar checklist sección 6), obligación de documentar nuevos errores en la sección 8 ("Registro de Errores"), y firma del último modificador.
  - **Guía Visión (06):** propósito, uso obligatorio (referencia cruzada a Sección 25), obligación de documentar descubrimientos sobre V4 (godot-mcp) en esta guía, y firma del último modificador.
  - "Regla maestra": si una guía no existe, crearla; si existe pero no está actualizada, actualizarla. No se permite arrancar de cero ni repetir errores ya documentados.

### DOCUMENTACION/07-GUIA-GODOT.md
- **Actualizada firma** del documento: `MiMo V2.5 / ox-alpha` (OpenCode / Cline), reflejando la última modificación.
- **Agregada nota de referencia** (línea 6) que indica: "Regla de AGENTS.md (sección 26): Antes de codificar en Godot, leer esta guía. Cualquier descubrimiento nuevo DEBE documentarse en la sección 8 (Registro de Errores)."

### DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md
- **Agregada nota de referencia** (línea 255) que indica: "Regla de AGENTS.md (sección 26): Antes de usar visión, leer esta guía. Cualquier descubrimiento sobre cómo usar el MCP de Godot (V4) DEBE documentarse aquí."
- **Reforzada nota 2** de "Notas para el agente": ahora también documentar descubrimientos durante el uso de V4 (godot-mcp): errores, trucos, herramientas inesperadas, limitaciones.
- **Agregida nota 5** (checklist previo al usar V4): verificar que V4 esté operativa y que el proyecto Godot esté cerrado antes de usar `run_project`/`launch_editor`.

## Archivos Modificados/Creados

- `AGENTS.md` — Agregada Sección 26 (líneas 871-890) + filas de guías 06/07 en tabla de Sección 3 (líneas 30-31)
- `DOCUMENTACION/07-GUIA-GODOT.md` — Actualizada firma y agregada nota de referencia (líneas 1-6)
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` — Agregada nota de referencia y reforzadas notas para el agente (líneas 255-263)
- `DOCUMENTACION/README.md` — Agregada entrada `07-GUIA-GODOT.md` en árbol de estructura (línea 17) + actualizada firma (líneas 3-5)

## Justificación

Antes de este cambio, el `AGENTS.md` **no mencionaba** `07-GUIA-GODOT.md` en ninguna parte. Un agente que tomaba un módulo de Godot no tenía forma de saber que existía una guía con errores comunes, convenciones y checklist. La Sección 26 cierra esta brecha y la extiende al MCP de Godot (V4), asegurando que los descubrimientos se documenten como memoria colectiva y no se pierdan ni se repitan.