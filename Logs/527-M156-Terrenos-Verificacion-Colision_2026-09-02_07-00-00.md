# Log 527: M156 Terrenos — Verificación (0 fallos) + fix de colisión de clases + aviso de regresión event_bus

**Fecha:** 2026-09-02
**Hora:** 07:00
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Verificación del módulo M156 (Terrenos y Movimiento): test en verde tras **resolver una colisión de clases globales** (duplicados `TerrainModifiers`/`TerrainDetector` entre el paquete heredado `scripts/terrain/` y el vigente `scripts/terrenos/` de M156). También se detectó una regresión AJENA: `scripts/core/event_bus.gd` con parse error — el árbol no bootea (no tocado).

## Cambios Realizados

### Fix de colisión (M156)
- `scripts/terrain/terrain_modifiers.gd` → `class_name TerrainModifiersLegacy` y `scripts/terrain/terrain_detector.gd` → `class_name TerrainDetectorLegacy` (nadie los consumía — verificado con grep; se conservan como heredados del paquete del mundo).
- `scripts/terrenos/test_terrenos.gd` → preloads explícitos (`const TerrainModifiers = preload(...)`) en lugar de clases globales (patrón §9.17/§9.41).
- `scripts/editor/plugin_herramientas.gd` → `const ... = preload(...)` (sin `:=` en const — parse del editor).
- Cache de clases globales regenerada (`--editor --quit`).

### Resultado
- `test_terrenos.gd` → **0 fallos, exit 0** (TerrainProvider autoload, catálogo, modificadores, efectividad de velocidad con equipo, detección de clase).

### Regresión ajena detectada (no tocada)
- `scripts/core/event_bus.gd`: parse error "Unexpected Indent in class body" + `class_name EventBus_` (modificación reciente, git M). Aviso 🔴 en ESTADO-PARALELO — el árbol no bootea hasta el fix del agente dueño del cambio.

## Archivos Modificados/Creados

- Modificados: `scripts/terrain/terrain_modifiers.gd`, `scripts/terrain/terrain_detector.gd` (legacy), `scripts/terrenos/test_terrenos.gd` (preloads), `scripts/editor/plugin_herramientas.gd` (const), `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md` (fila 156 → 🟡 14/302), `Mensajes entre modelos/ESTADO-PARALELO.md` (aviso 🔴), `Logs/ULTIMO_NUMERO.txt` (→527)
