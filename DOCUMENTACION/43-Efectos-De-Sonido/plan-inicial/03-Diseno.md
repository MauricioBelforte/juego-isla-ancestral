**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 43: Efectos de Sonido

## 1. Arquitectura

```
M34 (movimiento) ─┐
M13/M17 (voxel) ──┤
M35 (recursos) ───┼─► SfxDirector.gd (autoload, pool de 24 voces)
M20 (crafting) ───┤        │  ──► canales por prioridad
M45 (comercio) ───┤        │  ──► variación + pitch random
M21 (diálogo) ────┤        │  ──► ducking (M41/M21)
M45/M46 (UI) ─────┘        ▼
                    BUS SFX del árbol de audio (M07)
                    (3D los espaciales / 2D los de UI)
```

## 2. Reglas de prioridad de canal

| Prioridad | Categoría | Comportamiento |
|---|---|---|
| 1 (alta) | UI (selección, confirmación, error, logro) | Nunca se corta; máx 2 simultáneos |
| 2 | Acciones de mundo (recoger, abrir, cosechar, comprar) | Se corta un pasos si hace falta |
| 3 | Interacciones bloque (romper, colocar, plantar) | Se corta un ambiente (M42) si hace falta |
| 4 (baja) | Pasos y movimiento | Se corta primero |

## 3. Mapa material → variaciones

| Material/acción | Variaciones | Notas |
|---|---|---|
| Pasos hierba | 5 | fisicidad suave |
| Pasos madera | 4 | puentes, decks |
| Pasos piedra | 5 | eco ligero |
| Pasos tierra | 4 | impacto seco |
| Pasos nieve | 4 | crujido suave |
| Pasos arena | 4 | roce |
| Romper piedra | 5 | + gravilla |
| Romper madera | 5 | crujido + astillas |
| Romper tierra | 4 | golpe blando |
| Romper cristal | 4 | tintineo |
| Romper metal | 4 | golpe metálico |
| Colocar (misma familia) | 4 | impacto corto |

## 4. Familia tonal (coherencia con M41)

| SFX | Notas/intervalos | Tono |
|---|---|---|
| Confirmación | 2 notas ascendentes (5ª justa) | cálido |
| Logro | arpegio tríada mayor (3 notas) | brillante |
| Error | tríada menor descendente, 0.4 s | suave, no agresivo |
| Recoger | nota aguda corta (1 hz base + envolvente) | positiva |
| Compra | 2 monedas + nota mayor | ligero |
| Venta | monedas + nota media | distinto de compra |
| Crafting éxito | arpegio corto (4ª-5ª) | productivo |

## 5. Pool y rendimiento (M61)

- **Pool `SfxPool`:** 24 voces prealocadas (AudioStreamPlayer estáticos).
- **Límite por tipo:** ≤ 6 simultáneos del mismo SFX (ej. romper bloques en cadena) → los excesos se cortan, jamás se apilan.
- **Sin allocs por frame:** las variaciones se resuelven con índice PRNG de partida (M29).
- **Espacialización:** pasos/interacciones en 3D; UI y diálogos en 2D; distancias máx: pasos 15 m, rotura 20 m, mundo 30 m.

## 6. Configuración

- `res://data/audio/sfx_catalog.tres` (catálogo efecto → variaciones)
- `res://data/audio/sfx_surfaces.tres` (materiales)
- `res://data/audio/sfx_tones.tres` (familia tonal/UI)
- `res://src/audio/sfx_director.gd` · `sfx_pool.gd` · `sfx_emitter.gd`

## 7. QA

- Test M112: cada señal de M34/M13/M17/M35/M20/M45/M21 dispara su SFX.
- Test de pool: 24 voces máx, sin cortes de UI.
- Test de ducking: diálogo → SFX -6 dB; logro → música -6 dB.
- Recorrido M114: acciones frecuentes (romper/correr) nunca cansan (variaciones + límites).