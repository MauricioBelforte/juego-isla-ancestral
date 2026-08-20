**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 137: Prototipo

## 1. Arquitectura del Prototipo

```
┌─────────────────────────────────────────────────────────────────┐
│ Escena principal: prototipo_isla.tscn                           │
│  ├── Player (CharacterBody3D + cámara third-person M11/M12)     │
│  ├── VoxelWorld (VoxelTools M08: terreno 64³-96³, seed fija)    │
│  ├── RecursoNode (1 recurso clave: madera, M15)                 │
│  ├── NPC_Prueba (StaticBody simple + diálogo, M19/M21)          │
│  ├── Casa (para pruebas, M18)                                   │
│  ├── Ruina (bloque collectible + pista, M25)                    │
│  ├── Puzzle (puerta que abre con herramienta, M24)              │
│  ├── Sky/Sun (ciclo día-noche básico, M31)                      │
│  └── Clima (lluvia simple de partículas, M32/M52)               │
├─────────────────────────────────────────────────────────────────┤
│ Autoloads                                                        │
│  game_state.gd      (M59 — GameState con slot único)            │
│  world_seed.gd      (M10 — seed fija 20260819)                  │
│  save_manager.gd    (M59/M60 — save delta de chunks)            │
├─────────────────────────────────────────────────────────────────┤
│ docs/prototipo/                                                 │
│  ├── PLAYTEST.md           (plan + resultados M114)             │
│  ├── FILOSOFIA-CHECK.md    (checks M152/M153)                   │
│  ├── GONOGO.md             (decisión final con criterios)       │
│  └── RETROSPECTIVA.md      (lecciones → M138)                   │
└─────────────────────────────────────────────────────────────────┘
```

## 2. Componentes del Prototipo

### 2.1 Jugador (M11/M12)
- `CharacterBody3D` con movimiento en 8 direcciones + salto (decisión: sin sprint en el prototipo; la velocidad fija simplifica el feeling test).
- Colisiones voxel: `move_and_slide()` con shapes por bloque.
- Cámara: SpringArm3D + mouse orbit, sin clip contra el terreno (distancias mínima/máxima 2-8 m).
- Input: teclado/mouse provisional (M57 real llega después).

### 2.2 Voxel (M08/M09/M10)
- `VoxelTerrain` con generador de isla: 1 isla elevada rodeada de agua (sin océano navegable, M51 no aplica).
- Extracción: raycast desde la mira, `voxel_tool.do_point()` con límite de radio 3 (no minar de lejos).
- Colocación: do_point en cara apuntada; el bloque colocable = 1 recurso de madera.
- Seed fija (20260819) para que el save delta sea válido.

### 2.3 Inventario y Recurso (M14/M15)
- 1 slot: {"recursos": N, "herramienta": bool}.
- La madera se obtiene de árboles de bloque (leña) o del suelo.
- Confección mínima: 2 maderas + nada más = herramienta (M16 esbozado).

### 2.4 NPC y Diálogo (M19/M21)
- NPC de prueba ("Guía") con 3 frases: bienvenida, pista del puzzle, agradecimiento del regalo.
- Interacción: tecla E al mirarlo; caja de diálogo flotante simple (placeholder UI).

### 2.5 Puzzle y Ruina (M24/M25)
- Puzzle: puerta de ruina que se abre si tenés la herramienta (mínimo viable).
- Ruina: 5-8 bloques decorativos + 1 reliquia decorativa (placeholder).
- Recompensa del puzzle: mensaje de "¡El viento te lo agradece!" (placeholder noble M148).

### 2.6 Casa y Ambiente (M18/M31/M32)
- Casa: caja con puerta que abre y "dormir para pasar el día" (recarga): valida el ciclo de día/noche.
- Ciclo día/noche: sky procedural simple (M31), ronda en 6 min reales.
- Lluvia: particles 2D simple (M52 esbozo).

### 2.7 Guardado Delta (M59/M60)
```
save v1 = {
  "version": 1,
  "seed": 20260819,
  "player": {"pos": Vector3, "rot": float},
  "inventory": {"madera": int, "herramienta": bool},
  "modified_chunks": {"x,z": {"blocks": {...}}},
  "flags": {"puzzle_resuelto": bool}
}
```
- Load: regenera mundo con seed y re-aplica chunks modificados.

### 2.8 Playtest y Pruebas (M114/M61)
- Script `playtest_runner.gd` (herramienta editor): cámara demográfica (grabar 15 min), log de eventos (extracción, diálogo, puzzle).
- FPS log cada 5 s (M61) con `Engine.get_frames_per_second()`.
- Encuesta post-sesión (5 preguntas, ver RF14).

## 3. Flujo Principal (bucle de juego del prototipo)

```
Spawn en la playa (isla 64³)
 → Caminar por el mundo (movimiento + cámara)
 → Extraer madera (voxel_tool) → se siente el voxel
 → 2 maderas → herramienta (crafting esbozo)
 → Hablar con la Guía (diálogo: pista del puzzle)
 → Entrar a la ruina → resolver puzzle con herramienta
 → Recompensa: mensaje + regalo a la Guía + "dormir" en la casa (día siguiente)
 → Guardar → sesión 15 min → encuesta + observación
```

## 4. Criterios de Medición (GO/NO-GO)

| Criterio | Métrica | GO si |
|---|---|---|
| Diversión (RF14) | Encuesta media (M114) | ≥ 7/10 |
| Intención de seguir | % "sí" a "¿volverías a jugar?" | ≥ 80% |
| Rendimiento (RF16) | FPS medio en config media | ≥ 60 |
| Philosophy (RF15) | Checklist M152/M153 | Sin fallos críticos |
| Bucle completo (RF1-RF12) | % de testers que completan el bucle | ≥ 90% |
| Save (M59) | Test guardar→salir→cargar | 0 pérdidas |
| Métricas 1-6 | Tabla consolidada en GONOGO.md | 6/6 o 5/6 con plan de mitigación |

## 5. Cierre del Hito

1. Limpieza de logs, tag `prototipo-v1`, push.
2. Retrospectiva (lecciones → M138 Vertical Slice).
3. GONOGO.md firmado por el equipo con fecha.
4. Si NO-GO: se documenta el motivo (técnico/filosofía/diversión) y se decide: ajustar prototipo (7 días) o replanificar alcance (M136/M135).