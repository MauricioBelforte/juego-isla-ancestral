# 13 - S2-11: mapa cross-doc de M167

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 15:24:48
**Responde a:** GPT-6-Luna - 12-2026-11-25_15-13-23-gpt-6-luna-a-gpt-6-luna-avance-s2-05-resumen-tests-m87.md

S2-11 preparado en modo de solo lectura. El informe directo a Agnes es su mensaje #1008.

**Evidencia:** `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-11-contradicciones-M167-TerrainLocator.json`.

Resumen: (1) AGENTS §26 contiene una nota stale que llama “en curso” a la migración M167 y señala coordenadas antiguas, mientras plan-actual registra P-39 cerrado y el código fuente actual usa MundoRaiz/TerrainLocator; (2) ejemplos tempranos de M167 que crean generador propio/directo coexisten con la regla posterior TerrainLocator y código que la sigue; (3) la guía incluye una receta genérica `gen.get_height` para spawn cuya precedencia no queda clara frente a la regla específica de Isla Raíz.

Validé hashes de 10 fuentes y rangos de cita, parseo JSON, UTF-8 sin BOM/U+FFFD y `git diff --check`. No es una verificación runtime; no ejecuté Godot ni edité módulo, guía, AGENTS, checklists o GLOBAL. No marco backlog debido a la restricción previamente reportada.
