**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 43: Efectos de Sonido

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/audio/sfx_director.gd` | Autoload | Catálogo, prioridades, variación, ducking |
| `res://src/audio/sfx_pool.gd` | Nodo | Pool de 24 voces prealocadas |
| `res://src/audio/sfx_emitter.gd` | Nodo | Emisor 3D corto (pasos, bloques) |
| `res://data/audio/sfx_catalog.tres` | Data | Catálogo efecto → variaciones |
| `res://data/audio/sfx_surfaces.tres` | Data | Materiales de superficie |
| `res://data/audio/sfx_tones.tres` | Data | Familia tonal UI/eventos |
| `res://audio/sfx/...wav` | Assets | Efectos (compositor) |

## 2. API pública

```
SfxDirector (autoload/único):
  reproducir(efecto: String, pos: Vector3 = null)   # null = 2D/UI
  reproducir_localizado(tipo: String, material: String, pos: Vector3)
  configurar_volumen(bus: String, db: float)         # M91
  pausar() / reanudar()                              # M29
```

## 3. Suscripciones previstas

- M34: `paso(superficie)`, `salto()`, `caida(altura)`, `nado(entrada/salida)`, `equipar()`
- M13: `bloque_roto(material)`, `bloque_colocado(material)`
- M17: `plantar()`, `regar()`, `cosechar(cultivo)`
- M35: `pescar(etapa)`, `recoger(objeto)`
- M20: `craft_etapa()`, `craft_exito()`
- M45: `transaccion_mayor/menor` (compra/venta)
- M21: `dialogo_click()` (+ ducking)
- M45/M46 UI: `menu_abrir/cerrar`, `seleccionar`, `confirmar`, `error`, `logro()`

## 4. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| SfxDirector + pool de 24 + prioridades | Tras sistema de audio base (M06-hito M1) |
| Catálogo de variaciones (assets) | Composición de SFX |
| Enlace de señales con todos los módulos | Puntos de gancho definidos arriba |
| Tests M112 + QA M114 | Señales→SFX, pool, ducking |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 21:35:00
**Estado:** Documentación de diseño completa (módulo delegable)

### Lo que hice
- 25/25 puntos de la sección 42 resueltos.
- Familia tonal compartida con M41 (confirmación/logro/error coherentes).
- Prioridades de canal, límites por tipo y pool de 24 voces (M61).

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere sistema de audio base (M06). Dueño: AGENTE DELEGADO.
- Assets de SFX: los produce el compositor (spec lista con familia tonal).

### Recomendaciones para el próximo agente
- No crear un AudioStreamPlayer por efecto: usar el pool siempre.
- Las señales ya están definidas en este documento: no inventar nuevas; esperar las de M34/M13 (autoload M07).