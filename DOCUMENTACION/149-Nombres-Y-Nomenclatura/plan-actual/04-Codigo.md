# Módulo 149: Nombres y Nomenclatura — Código

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-21 (spec original por Nemotron 3 Ultra)
**Estado:** Implementación operativa completa (pendiente de QA cruzado; 3 ítems [?] con dueño/programados)

> **Adaptación de rutas:** el spec original ubicaba los documentos en `docs/naming/`; por la convención del proyecto (`AGENTS.md` §3) viven en `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/`.

## Archivos Implementados (2026-08-28)

| Spec original | Archivo real | Estado |
|---|---|---|
| `docs/naming/npc-names.md` | `operativa/npc-names.md` | ✅ sistema de nombres + 15 nombres (canon vs PROPUESTA) + pronunciación + validación cultural |
| `docs/naming/place-names.md` | `operativa/place-names.md` | ✅ categorías/reglas + 11 lugares (canon y propuestas) + mapa referencias + equivalencias 6 idiomas |
| `docs/naming/code-conventions.md` | `operativa/code-conventions.md` | ✅ tabla GDScript (con ejemplos reales) + archivos/carpetas + IDs de datos + tags + template |
| `docs/naming/quick-reference.md` | `operativa/quick-reference.md` | ✅ cheatsheet 1 página + no-hacer + templates + snippets IDE |
| `docs/naming/validation-process.md` | `operativa/validation-process.md` | ✅ flujo cultural + code review + validador + changelog |
| — (añadido) | `operativa/validar_nombres.py` | ✅ validador ejecutable (detecta violaciones reales; excluye Obsoletos/) |

## Archivos a Modificar

No hay archivos de código a modificar. Este módulo es documentación de convenciones (el validador es una herramienta de apoyo en esta carpeta, invocable por M111).

## Integración con Sistemas Existentes

> **Corrección documentada:** la tabla del spec original citaba M23 (NPCs), M30 (Mundo) y M103 (Localización); los dueños reales son M19/M161 (NPCs), M27/M160 (Mundo) y M87 (Localización).

| Sistema | Cómo se conecta |
|---------|-----------------|
| Historia (M22) | Nombres de NPCs y lugares en la narrativa (canon verificado) |
| NPCs (M19/M161) | Nombres de personajes (Catalina Oso canon; propuestas para adoptar) |
| Mundo (M27/M160) | Nombres de lugares (islas canon; Mirador del Alba propuesta) |
| Localización (M87) | Reglas multiidioma y tabla de equivalencias |
| Audio (M41-44/M150) | Pronunciación y patrón de nombres de pistas/efectos |
| Código (todos) | Convenciones de naming; autoridad técnica: 07-GUIA-GODOT |
| Código de Calidad (M111) | Recibe las reglas para su linter/pre-commit (en curso) |

## Notas del Agente

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 23:25:00
**Estado:** Parcial programado (con [?] futuros) — pendiente de QA cruzado

### Lo que hice
- Implementé los 5 documentos del spec + validador ejecutable (`validar_nombres.py`), verificado sobre el árbol real del juego (detecta 1 violación legacy: `villager.tscn`).
- Formalicé convenciones con **evidencia real**: señales = snake_case (corregido vs checklist original, autoridad 07-GUIA-GODOT §1.1), escenas entidad = PascalCase (formaliza Player.tscn/CameraRig.tscn existentes), patrón de IDs de ítems M159 (`item_<cat3>_<sub3>_<NNN>`), patrón de tests/previews (`test_*`/`preview_*`).
- Construí el sistema de nombres artísticos alineado al canon real (Catalina Oso, Finneas, Aurora, islas, Templo de la Brisa, Gran Vapor) con 15 nombres NPC (canon vs PROPUESTA) y 11 lugares, con pronunciación y validación multilingüe documentada.
- Hallazgos documentados: backups con fecha correcta en Obsoletos/ (validador los excluye), `villager.tscn` legacy (deuda M19/M04), integraciones del spec con IDs corregidos.
- Marqué el checklist 97/100 `[x]` + 3 `[?]` (hablantes nativos, hook pre-commit = M111, evaluación de efectividad con uso acumulado).
- Actualicé registros globales y generé el log 201.

### Lo que NO pude hacer (honestidad obligatoria)
- No renombré `villager.tscn` (rompería referencias de escenas: tarea de código del dueño M19/M04).
- No implementé el pre-commit hook (zona de M111, en curso); solo su especificación.
- No realicé revisión con hablantes nativos (requiere humanos; chequeo documental hecho).

### Recomendaciones para el próximo agente
- QA cruzado rápido: ejecutar `validar_nombres.py`, verificar las 2 correcciones documentadas (señales, IDs de integración) y el marcado 97/100 + 3 `[?]`.
- M161 (al implementar) debe adoptar/rechazar las 12 PROPUESTAS de nombres NPC con la ficha del template.
- M111 debe integrar `validar_nombres.py` en su linter/pre-commit cuando implemente los hooks.
- Cualquier nombre nuevo (NPC o lugar) usa los templates y entra al canon vía M147/M161/M160.
