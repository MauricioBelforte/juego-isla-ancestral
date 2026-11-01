# RIEL-S4 — VERIFICACIÓN WEB RÁPIDA (2ª pasada; 8 items)

**Creado por:** GLM-5.3-Flash (31oct) para GPT-5.6 Luna | **Nicho:** verificación web rápida (ficha: latency-sensitive, verification) — complementa lo censado por Nemotron (W1/D1-004), no lo repite.

**Output por ítem:** veredicto corto + fuente (URL + fecha de consulta). Informe en canal al cerrar.

| # | Tarea | Estado |
|---|---|---|
| S4-001 | Verificar las URLs citadas en `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` (mcp-for-blender, Playwright, etc.): activas y vigentes | [x] |
| S4-002 | Godot 4.7.2: release notes oficiales — cambios relevantes del warning/boot de autoloads (insumo del A1-WORKOUT) | [x] |
| S4-003 | Estado del endpoint `gpt-5.6-luna` en OpenRouter y OpenAI API: rate-limits, disponibilidad de Batch API (tu canal de alto volumen) | [x] |
| S4-004 | Licencias vigentes de las fuentes tipográficas del juego (M88: URLs citadas en disco) | [x] |
| S4-005 | Best practices comunitarias de "bridge de señales servicio→bus" en Godot (insumo del fix `item_removed` — BUG-150) | [x] |
| S4-006 | Changelog de Kilo Code: cambios recientes que afecten el flujo de agentes (canales/numeración) | [x] |
| S4-007 | Verificar las URLs citadas de licencias de assets 3D/audio del juego (M85/M86: activas y con la licencia declarada) | [ ] SKIP — no hay URLs de assets 3D/audio concretos en los planes consultados |
| S4-008 | El patrón "resumen sintetizado por IA" en Godot docs: mejores fuentes oficiales para el ciclo D1/D2 de la flota (solo informe) | [x] |

## Resultados de la verificación — 2026-10-31

- **S4-001 [x]:** La guía indica Playwright para QA web (`DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md:L281-L283`); Playwright describe: “Playwright Test is an end-to-end test framework for modern web apps.” https://playwright.dev/docs/intro (consulta 2026-10-31). El repo dice “formerly `blender-mcp`” y publica licencia MIT: https://github.com/ahujasid/mcp-for-blender (consulta 2026-10-31). Las únicas URLs literales de la guía son las dos declaraciones del schema de OpenCode (`DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md:L387,L551`).
- **S4-002 [x]:** La nota oficial dice: “39 contributors submitted 57 fixes for this release.” (publicada 2026-08-18); sus cambios destacados no citan warning/boot de autoloads: https://godotengine.org/article/maintenance-release-godot-4-7-2/ (consulta 2026-10-31). Enlaza el changelog interactivo completo https://godotengine.github.io/godot-interactive-changelog/#4.7.2; no se atribuye una corrección específica sin revisar el registro completo.
- **S4-003 [x]:** OpenAI publica “Model ID: `gpt-5.6-luna`” y marca Batch como supported: https://developers.openai.com/api/docs/models/gpt-5.6-luna (consulta 2026-10-31). OpenRouter lista el mismo ID y endpoint/proveedores: https://openrouter.ai/openai/gpt-5.6-luna y https://openrouter.ai/api/v1/models/openai/gpt-5.6-luna/endpoints (consulta 2026-10-31). Los límites numéricos varían por organización/cuenta; sin credenciales no se consultó el cupo concreto. Referencias: https://developers.openai.com/api/docs/guides/rate-limits y https://openrouter.ai/docs/limits (consulta 2026-10-31).
- **S4-004 [x]:** M88 identifica Nunito y Fredoka (`DOCUMENTACION/88-Fuentes-Tipograficas/plan-actual/03-Diseno.md:L11-L16`) y declara SIL OFL 1.1 (`DOCUMENTACION/88-Fuentes-Tipograficas/plan-actual/03-Diseno.md:L37`). Ambos archivos upstream dicen literalmente “This Font Software is licensed under the SIL Open Font License, Version 1.1.”: https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/OFL.txt y https://raw.githubusercontent.com/google/fonts/main/ofl/fredoka/OFL.txt (consulta 2026-10-31).
- **S4-005 [x]:** Godot describe señales como “a delegation mechanism built into Godot” para reducir coupling: https://docs.godotengine.org/en/4.7/getting_started/step_by_step/signals.html (consulta 2026-10-31). GDQuest advierte: “The main disadvantage is that you bundle a bunch of unrelated signals into a single object.” y limita el bus a comunicación distante/global cuando es la solución más simple: https://www.gdquest.com/tutorial/godot/design-patterns/event-bus-singleton/ (consulta 2026-10-31). Aplicación propuesta: servicio emisor y relay tipado; lógica de dominio fuera del bus.
- **S4-006 [x]:** Kilo Code registra: “Keep a reply that another Kilo process on the same data directory is still writing” y hacer que tareas programadas “fire once when several Kilo processes open the same workspace”: https://github.com/Kilo-Org/kilocode/releases (consulta 2026-10-31). Esas notas no definen la numeración de canales propia del repo.
- **S4-007 [ ] SKIP:** M85 expone `license_document_path` (`DOCUMENTACION/85-Modelos-3D-Legal/plan-actual/04-Codigo.md:L117-L135`), mientras M86 describe “Permitido / Prohibido” y “Registro de herramientas” como plantilla (`DOCUMENTACION/86-IA-Generativa/plan-actual/04-Codigo.md:L39-L75`). Ninguno identifica URL de assets 3D/audio concretos para verificar; no infiero licencias.
- **S4-008 [x]:** Godot ofrece documentación versionada en https://docs.godotengine.org/en/4.7/, notas oficiales de release y el changelog asociado; la guía de señales es fuente primaria para ese tema: “Signals are a delegation mechanism built into Godot” (https://docs.godotengine.org/en/4.7/getting_started/step_by_step/signals.html, consulta 2026-10-31). Los resúmenes IA deben quedar como borradores anclados a esas fuentes/versiones.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-31 23:49.

**Verificación de cierre:** GPT-5.6 Luna / Copilot SDK en VS Code — 2026-10-31.
