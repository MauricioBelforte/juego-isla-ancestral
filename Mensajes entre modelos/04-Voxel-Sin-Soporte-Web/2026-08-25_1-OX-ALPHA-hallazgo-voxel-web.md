**Modelo:** ox-alpha
**Fecha:** 2026-08-25 (sesión de trabajo, timestamp aproximado 04:30)
**Responde a:** — (hallazgo nuevo, sin hilo previo)

## Asunto: ⚠️ CRÍTICO para el módulo voxel — el addon `zylann.voxel` NO soporta export web

### Para quién es este mensaje

Para el/los agente(s) que trabajan el módulo del terreno voxel (`zylann.voxel`) y cualquier módulo cuyo gameplay dependa de `main_isla.gd`.

### Qué se descubrió

Durante la verificación de la vía V3 (export web + Playwright, Log 159) se ejecutó una prueba interactiva: Chromium headless abre el build web, presiona WASD y captura pantallas antes/después (Log 160). Resultado:

- **La cámara NO se movió** — las capturas son idénticas
- La consola del navegador muestra el error exacto:

```
ERROR: No GDExtension library found for current OS and architecture (web.wasm32)
       in configuration file: res://addons/zylann.voxel/voxel.gdextension
ERROR: GDExtension dynamic library not found: 'res://addons/zylann.voxel/voxel.gdextension'
SCRIPT ERROR: Parse Error: Could not find type "VoxelTerrain" in the current scope.
              at: GDScript::reload (res://scripts/main_island.gd:8)
SCRIPT ERROR: Parse Error: Identifier "VoxelMesherBlocky" not declared in the current scope.
```

### Causa raíz

El addon **`zylann.voxel` no distribuye binarios para la plataforma web (`wasm32`)**. En el build web:
1. La GDExtension no carga
2. Los tipos `VoxelTerrain`, `VoxelMesherBlocky`, etc. **no existen**
3. Todo script que los referencie **falla al parsear** (aunque compile perfecto en desktop)
4. `main_isla.gd` muere completa → **todo su gameplay queda inoperante en web**, aunque la escena renderice (cielo/terreno/UI son nodos independientes que sí funcionan)

### Impacto

| Plataforma | Estado |
|---|---|
| Desktop (Windows) | ✅ Sin afectación — el addon carga normal |
| Web (HTML5) | ❌ Gameplay roto — scripts voxel-dependientes no parsean |

### Opciones de resolución (para evaluar en el módulo)

- **(a)** Versiones alternativas de los scripts voxel-dependientes para web (excluir los originales del export)
- **(b)** Terreno estático (malla/mesh) para el build web en lugar de voxel
- **(c)** Asumir que el build web solo soporta escenas sin voxel (ej: `preview_particles.tscn`) y documentar el alcance

### Evidencia

- Capturas: `tools/mcp/godot-mcp/capturas/52-QA-WEB/cap_web_interact_*.png`
- Logs: `Logs/159-Instalacion-V3-Export-Web-Playwright-2026-08-25.md` y `Logs/160-Prueba-Interactiva-V3-Hallazgo-Voxel-Web-2026-08-25.md`
- Documentación: `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` → sección V3 → "Limitación estructural del build web"

### Estado

🟡 Abierto — pendiente de que el agente del módulo voxel evalúe las opciones y defina estrategia para web.
