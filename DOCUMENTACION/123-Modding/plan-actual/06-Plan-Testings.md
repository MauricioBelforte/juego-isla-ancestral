# 06-Plan-Testings.md — Módulo 123: Modding

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13 (iteración 2)
**Estado:** plan vigente

> Este documento **no existía**. El módulo declaraba en su `04-Codigo.md` una
> sección "Tests (M112 — proyección V2)" en C# (diseño muerto) pero nunca tuvo un
> plan de testings real para la implementación en GDScript. Se crea aquí.

## 1. Alcance

M123 es un módulo de **infraestructura de modding**: no introduce gameplay. Sus
piezas verificables son:

| Pieza | Archivo | Qué se prueba |
|---|---|---|
| Carga del manifiesto | `scripts/modding/modding_manager.gd` | lectura JSON, 2 mods, API `mod()`, `carpeta_mods()` |
| Compatibilidad con la build | idem | `es_compatible()` con `min_build` |
| Conflictos por override | idem | `detectar_conflictos()` |
| Prioridad | idem | `resolver_prioridad()` (menor prioridad se omite) |
| Compatibilidad con updates (M118) | idem | `es_compatible_update()` |
| Validación de catálogo | `scripts/modding/mod_validator.gd` | `validar()` con códigos de error |
| Validación de paquete | idem | `validar_paquete()` (corrupto, readme, schema) |
| Sandbox de rutas | `scripts/modding/mod_sandbox.gd` | `ruta_segura()` (path traversal) |
| Esquema de assets | idem | `validar_assets()` (espejo de M108) |

## 2. Casos de prueba (CP)

| CP | Qué verifica | Tipo | Automatizable |
|---|---|---|---|
| CP-01 | El manifiesto carga 2 mods y expone `mod(id)` | unit | ✅ bloque A |
| CP-02 | Mod inexistente devuelve `{}` y es incompatible | unit | ✅ bloques A/B |
| CP-03 | Compatibilidad por `min_build` (1.0.0 sí / 0.8.0 no) | unit | ✅ bloque B |
| CP-04 | Activación e idempotencia de `activar()` | unit | ✅ bloque B |
| CP-05 | 1 conflicto por override detectado | unit | ✅ bloque C |
| CP-06 | El catálogo real valida con 0 errores | unit | ✅ bloque D |
| CP-07 | Errores de manifiesto (sin id, sin versión, override inexistente) | unit | ✅ bloque E |
| CP-08 | Duplicado **con** override no bloquea | unit | ✅ bloque E |
| CP-09 | Path traversal (`..`, anidado, backslash) rechazado | seguridad | ✅ bloque F |
| CP-10 | Ruta absoluta y unidad de disco rechazadas | seguridad | ✅ bloque F |
| CP-11 | Nombre de asset contra el esquema M108 | datos | ✅ bloque G |
| CP-12 | Extensión ↔ prefijo (glb→mdl, png→tex/ui/vox) | datos | ✅ bloque G |
| CP-13 | Límite de 10 MB por dominio y assets duplicados | datos | ✅ bloque G |
| CP-14 | Paquete corrupto → E06; readme ausente → E07; schema → E13 | robustez | ✅ bloque H |
| CP-15 | Prioridad: el de mayor gana, el menor se omite con motivo | lógica | ✅ bloque I |
| CP-16 | Compatibilidad con updates M118 (incl. downgrade) | lógica | ✅ bloque J |
| CP-17 | Tabla de códigos E01..E14 completa y usada | contrato | ✅ bloque K |
| CP-18 | Integración con el Workshop de Steam (M97) | integración | ❌ no implementado (V2) |
| CP-19 | Vista de previsualización del paquete (UI M89) | UI | ❌ no implementado (M89) |
| CP-20 | Telemetría de suscripciones (M104) | integración | ❌ política definida, implementación M104 |

## 3. Casos NO cubiertos (honestidad)

- **Carga real de un `.zip`/`.mod` desde disco**: el manifiesto vive en
  `res://data/mods/mod_manifest.json`; no hay un desempaquetador implementado.
- **Instalación/desinstalación de mods en `user://mods/`**: no implementado.
- **Integración con Steam Workshop (M97)**: es V2 y depende de M97.
- **UI de mods (M89)**: la pantalla de mods no está implementada.
- **Ejecución de scripts de mod**: prohibida por diseño en V1 (solo datos).

## 4. Criterios de aprobación

1. `test_modding_m123.gd` con **0 fallos** y **0 `SCRIPT ERROR`** en 3 corridas.
2. Todos los bloques A-K ejecutados (verificación anti-falso-verde con `_fin()`).
3. Codificación UTF-8 **sin BOM** en todos los archivos del módulo (§28).
4. El catálogo real (`mod_manifest.json`) valida con 0 errores.

**Firmado:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-13
