# 03 — Diseño — M66: Anti-Softlock

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Arquitectura

```
SoftlockGuard (Singleton)              ← detector + recuperador central
├── Invariants                          ← reglas declarativas por categoría
│   ├── ObjetoClaveInvariant  (2+ caminos o justificado)
│   ├── NpcInvariant          (nodo válido, agenda rehidratable)
│   ├── MisionInvariant       (objetivos existentes, sin condición imposible)
│   ├── PuzzleInvariant       (resoluble en 30 s de diagnóstico)
│   ├── VehiculoInvariant     (dentro del mundo)
│   └── JugadorInvariant      (vivo, sobre geometría válida)
├── RecoveryHandlers                     ← acciones en cascada por categoría
│   ├── CofreRecuperacion     (objetos únicos, 1 copia inmutable por clave)
│   ├── CheckpointManager     (3 slots/bioma + 1 emergencia, escritura atómica)
│   ├── MisionFallbacks       (registro declarativo de rutas alternativas)
│   ├── NpcRestore            (hogar + agenda + inventario transaccional)
│   ├── VehiculoRestore       (amarre tras 30 s)
│   └── JugadorRestore        (checkpoint más cercano)
└── GuardEvents               ← eventos emitidos al periférico (toast ligero M57)
```

## Flujo del detector

1. **Disparo:** cada 60 s (tick real, no por frame) + en transiciones de escena + al guardar.
2. **Chequeo por invariantes** en orden de prioridad: Jugador → Misiones → NPC → Objetos → Puzzles → Vehículos.
3. Si hay >= 1 invariante rota → **plan de recuperación** en cascada y se ejecuta (nunca dos a la vez por categoría).
4. Cada recuperación registra evento (`GuardEvents`) y — si afecta al jugador — toast de baja prioridad (no spam).
5. Tras 3 recuperaciones de la misma instancia en 10 min → se manda al Cofre y se avisa con toast informativo.

## Cofre de recuperación

- Ubicación: aldea principal + reproducción en templo (M26, zona central).
- Catálogo: `ClaveUnica` → slot + copia inmutable. Al entregarse, el objeto se marca "recuperado" y el slot queda vacío (jamás se duplica).
- Índice del cofre es serializado en el guardado; no se borra jamás si el objeto ya se tomó.

## Checkpoints

| Tipo | Contenido | Cuándo |
|---|---|---|
| Bioma (x3 rotativo) | posición, estado misiones del bioma, inventario clave | entrada a bioma |
| Emergencia global | estado completo de la partida (atómico) | evento crítico (completar misión, puzzle de templo) |

Escritura siempre atómica: `tmp` + rename + `.bak` (patrón ya establecido en persistencia).

## Reglas de recuperación por caso (resumen)

| Invariante rota | Acción |
|---|---|
| Jugador fuera del mundo | Teleport al checkpoint más cercano, efectos suaves, toast |
| Objeto clave sin dueño | Cofre de recuperación (slot dedicado) |
| NPC atascado | Re-path → teleport hogar → agenda reset |
| Misión imposible | Fallback declarado (misma recompensa), aviso en diario de misión |
| Puzzle irresoluble | Reinicio del slot del puzzle (estado inicial), se notifica |
| Vehículo perdido | Reaparece en amarre tras 30 s |
| Múltiples fallos (3/10 min) | Cofre + toast informativo |

## Rendimiento

- Tick del detector cada 60 s (real); en eventos (transición/guardado) costo ≤ 0.5 ms.
- Cero I/O síncrona en Update; toda escritura de checkpoint usa el patrón atómico asíncrono ya establecido.
- Invariantes con datos cacheados (sin raycast en masa: se rechaga solo el chunk del jugador).
- Reuso del watchdog M64 para NPC y de NavigationServer3D para validar 2+ caminos (caché por clave).

## QA / Testings

- 06-Plan-Testings.md: unitarias (invariantes, cofre, checkpoints), integración (cierre a mitad de guardado, terreno extremo M08), edge cases (cofre lleno, doble recuperación, vehículo en amarre ocupado), perf (tick con isla completa).
- 07-Resultados se actualiza tras la ejecución en Play Mode.