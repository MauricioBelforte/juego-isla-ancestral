# Log 161: Instalación de Skills de Desarrollo (Godot + Blender + find-skills)

**Fecha:** 2026-08-25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Se instaló en la raíz del proyecto una biblioteca de skills procedimentales reutilizables en `.claude/skills/`, provenientes de repos de terceros auditados por su comunidad, con un subconjunto curado seleccionado según las necesidades del proyecto (mundo voxel/3D, partículas/VFX, NPC, combate, UI, etc.).

## Cambios Realizados
- Verificada la realidad de skills.sh y de las 3 librerías (GD-Agentic-Skills 99/27 Godot, Blender-skills 94 Blender, vercel-labs/skills find-skills).
- Confirmados node v24 + npx disponibles; se optó por instalación por `git clone` (más confiable que `npx skills add`, que quedó colgado en descarga).
- Creada carpeta `.claude/skills/` en la raíz (no había `.claude/` antes).
- **Subconjunto curado instalado (69 skills):** 1 find-skills + ~44 Godot + ~24 Blender, según relevancia al proyecto.
- Documentada la convención en **AGENTS.md §27** (nuevo): reglas de uso, estructura SKILL.md, auditoría de terceros, licencias, curatoria específica.

### Skills de Godot instaladas (thedivergentai/GD-Agentic-Skills, LGPLv3) — subconjunto relevante
- Core/general: godot-master, godot-analyst, godot-auditor, godot-builder, godot-gdscript-mastery, godot-project-foundations, godot-version-migration, godot-composition, godot-autoload-architecture, godot-agent-vision
- Gameplay/mundo: godot-3d-world-building, godot-procedural-generation, godot-camera-systems, godot-navigation-pathfinding, godot-ai-navigation, godot-characterbody-2d, godot-physics-3d, godot-input-handling, godot-combat-system, godot-inventory-system, godot-quest-system, godot-ability-system, godot-dialogue-system, godot-state-machine-advanced
- VFX: godot-particles
- Sistemas: godot-scene-management, godot-resource-data-patterns, godot-signal-architecture, godot-save-load-systems, godot-audio-systems, godot-ui-containers, godot-ui-theming, godot-tweening
- Render: godot-3d-lighting, godot-3d-materials, godot-shaders-basics
- Calidad: godot-debugging-profiling, godot-testing-patterns, godot-performance-optimization, godot-export-builds, godot-platform-desktop, godot-platform-web, godot-raycasting-queries

### Skills de Blender instaladas (arjun988/blender-skills, MIT) — subconjunto relevante
- Artista/modelado: blend modeler, character-artist, creature-artist, environment-artist, prop-artist, vegetation-artist, hard-surface, sculpting, retopology, procedural-modeling
- Pipeline: godot-export, export-pipeline, lod-pipeline, collision-proxy, asset-optimization, materials, texture-workflow, uv-workflow, scene-assembly, set-dressing, lighting, rendering, camera-cinematography
- Director/QA: blender-director, qa-review

## Archivos Creados/Modificados
- `.claude/skills/` (nuevo, 69 skills)
- `AGENTS.md` (nueva sección 27)
- (clones de referencia temporales en `C:\Temp\skills_tmp\...`, no versionado)