**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 44: ASMR y Feedback

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/audio/feedback_director.gd` | Autoload | Recetas, keyframes, microfoley, contexto |
| `res://src/audio/feedback_recetas.tres` | Data | Recetas de sensación por acción |
| `res://src/audio/feedback_keyframes.tres` | Data | Puntos de sincronía por animación |
| `res://src/audio/feedback_contexto.gd` | Util | Reglas contextuales (interior/clima/hora) |
| `res://src/audio/feedback_blacklist_test.gd` | Test util | Analyser True Peak / buzz detector |
| `res://audio/microfoley/...wav` | Assets | Chasquidos y microfoley (compositor) |

## 2. API pública

```
FeedbackDirector (autoload/único):
  sensacion(accion: String, pos: Vector3)          # aplica receta de capas
  key_sync(accion: String, keyframe: int)          # M34
  set_contexto(tipo: String, valor: float)          # interior/clima/hora
  set_reverb(cueva|templo|ruinas|casa|exterior)
  config_feedback_reducido(bool) / config_direccional(bool)   # M58/M91
  pausar() / reanudar()                            # M29
```

## 3. Suscripciones previstas

- M34: `animacion_key(accion, keyframe)` — sincronía
- M13/M17: `bloque_roto/colocado`, `plantar`, `cosechar`
- M20: `cocinar(etapa)` — sizzle/vaso
- M45: `abrir_contenedor(tipo)` — cajas/cofres
- M32: `estado_clima` · M31: `fase` · M21: `dialogo()` (ducking)

## 4. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| FeedbackDirector + recetas | Tras sistema de audio base (M06-hito M1) |
| Keyframes en M34 alineados | Convención señales ya definida |
| Assets de microfoley | Compositor (spec lista) |
| Blacklist test+QA M114 | Con M112 suite |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 22:00:00
**Estado:** Documentación de diseño completa (módulo delegable)

### Lo que hice
- 17/17 puntos de la sección 43 resueltos (sensaciones + ajustes contextuales).
- Recetas de capas (4 capas estrictas) y blacklist anti-agresión verificable.
- Reglas de precedencia contextual y accesibilidad (M58).

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere sistema de audio base (M06). Dueño: AGENTE DELEGADO.
- Assets de microfoley: compositor.

### Recomendaciones para el próximo agente
- No agregar fuentes nuevas: todo debe caber en el pool de 24 de M43.
- Respetar la precedencia contextual fija (interior > clima > día/noche > diálogo).
- El test de blacklist (True Peak / buzz) es obligatorio en la suite M112.

---

## Notas del Agente — T-M4 (cierre documental, mensaje 44)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** OpenCode
**Fecha:** 2026-10-06 22:05
**Estado:** Cerrado (documental) — 108 [x] / 5 [?] / 0 [ ] = 113

### Estado REAL de la implementación (verificado en disco 2026-10-06)

- `scripts/audio/feedback_director.gd` — autoload implementado (recetas JSON, blacklist,
  precedencia interior, `sensacion`, `set_contexto`, `key_sync` stub, `pausar/reanudar` stub).
- `scripts/audio/test_feedback_m44.gd` — **suite M44: 9 checks / 0 fallos / exit 0**
  (sonda roja: renombrar `bloque_roto` → exit 1; restaurado → 9/0).
- `data/audio/feedback_recetas.json` — 8 recetas reales; `feedback_blacklist.json` — 4 prohibidas.
- **CERO llamadas externas** a `sensacion()`/`set_contexto()` fuera del autoload (rg):
  M13, M17, M45, M31, M29 siguen **sin cablear** (04 §3/§4) → checklist `[?]` con dueño.

### Diferencias diseño §2 vs código (registradas, sin tocar código)

- `sensacion(accion: String)` implementada **sin** el parámetro `pos` previsto en §2
  (las 8 recetas actuales son no espaciales; añadirlo cuando una receta lo requiera).
- `key_sync()` sigue stub (M34): la regla ±15 ms está **diseñada** (03 §3), runtime pendiente.

### Recomendaciones para el próximo agente

- Cablear emisores: solo `FeedbackDirector.sensacion("...")` / `set_contexto(...)` desde
  M13/M17/M45/M31/M29 — los datos y la API ya existen (ver §3).
- Los stubs `pausar/reanudar` y `key_sync` son el trabajo pendiente natural.
