**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 62: Memoria

## 1. Arquitectura

```
                MemoryMonitor.gd (autoload — dueño del estado global)
   ┌──────────────┬──────────────────┬──────────────────┬─────────────────┐
   ▼              ▼                  ▼                  ▼                 ▼
BudgetRegistry UnloadPolicy      GlobalPool       DriftDetector    MemoryDebugPanel
(topes .tres)   (LRU/edad/       (familias          (baseline +      (panel M110)
                 prioridad)       tipadas)           alerts)
   │              │                  │                  │                 │
   └──────┬───────┴────────┬─────────┴────────┬─────────┴─────────────────┘
          ▼                ▼                  ▼
   ChunkMemory.gd     AudioMemory.gd     TextureMemory.gd      SceneMemory.gd
   (M08 voxel)        (M41-M44)          (atlas/mips)          (tránsito escenas)
          └──────────────┴──────────────────┴──────────────────┘
                              ▼
                EventBus (M07): semaforo_cambiado, presupuesto_superado,
                recurso_descargar, recurso_descargado
                              ▼
                Log (M103) + Debug Menu (M110) + presets (M90)
```

**Regla de oro:** el 62 **no carga nada** (eso es M63) y **no rinde nada** (eso es M61/Godot). El 62 vigila, presupuesta, pide descarga y pooliza.

## 2. Presupuestos por sistema (RF2 / presets M90)

| Sistema | Preset Baja | Preset Media | Preset Alta |
|---|---|---|---|
| Mundo voxel (buffers + meshes + colliders + pool chunks) | 500 MB | 650 MB | 800 MB |
| Texturas / atlas | 250 MB | 320 MB | 400 MB |
| Audio (bancos M42 + streams + voces M43) | 150 MB | 200 MB | 250 MB |
| Escenas / NPCs / objetos | 220 MB | 280 MB | 350 MB |
| Pooling global | 120 MB | 160 MB | 200 MB |
| UI y fuentes | 70 MB | 85 MB | 100 MB |
| Shaders / materiales / pipelines | 60 MB | 80 MB | 100 MB |
| Reserva del sistema | 130 MB | 225 MB | 300 MB |
| **Total** | **1.500 MB** | **2.000 MB** | **2.500 MB** |

- La suma por preset es fija (verificable en tests): ningún sistema puede crecer sin bajar otro.
- Los topes viven en `res://rendimiento/memoria/data/budgets.tres` (RF10); el preset activo lo define M90.

## 3. Semáforos y política de acción (RF9 / D3)

| Nivel | Umbral | Acción |
|---|---|---|
| 0 OK | < 80% | Solo muestreo normal (cada 5 s en calma, 1 s en movimiento) |
| 1 Warning | 80% | Log + evento; preparar candidatos de descarga (no ejecuta) |
| 2 Crítico | 90% | Degradación suave: LOD de lejanos M08, pools secundarios al mínimo, evicción de atlas fuera de pantalla |
| 3 Emergencia | 95% | Descarga dura sin excepción: bancos de audio de biomas viajeros, chunks más lejanos, texturas de regiones no próximas; el juego nunca crashea por memoria |

El cambio de semáforo dispara `semaforo_cambiado(nivel)` por EventBus (M07) → log (M103) → panel (M110).

## 4. Pooling global (RF3 / D4)

- Familias: `audio_voz` (M43), `particula`, `mesh_chunk` (M08), `objeto_recogible` (M15), `texto_efimero` (M53), `npc_temporal` (M64/M65).
- Contratos: `obtener(familia)`, `devolver(objeto)`, `precalentar(familia, n)`, `limite(familia)`, `tamanio(familia)`.
- Los ítems devueltos: invisibles, quietos, sin señales y con estado limpio (sin referencias externas).
- Fallback honesto: si el pool está lleno y se pide más, se `queue_free()` el nuevo (nunca crecer sin tope).
- Precalentamiento: al arrancar y en pantalla de carga (M63); nunca en mitad de gameplay.

## 5. Política de descarga (RF5-RF7 / D6-D7)

1. **Candidatos:** cada sistema reporta consumo y marca candidatos con peso (`marcar_candidato(recurso, peso)`).
2. **Orden de descarga:** distancia (chunks) > edad (LRU) > peso (audio/texturas).
3. **Handshake con M63:** el 62 anuncia `recurso_descargar`; si la cola del 63 lo tiene en carga, se descarta la orden; si el 63 avisó `recurso_cargado`, el 62 puede descargarlo.
4. **Escalonamiento:** por frame se descargan máximo `N` recursos (Baja 8, Media 12, Alta 16) → cumple RN2.
5. **Ejecución:** liberar referencias → `queue_free()` diferido 1 frame → contador por sistema al día.

## 6. Flujos

### 6.1 Arranque
1. `MemoryMonitor` registra línea base del menú (< 600 MB RN10).
2. `GlobalPool.precalentar()` familias base (audio_voz, texto).
3. M63 ejecuta precalentamiento de mundo; el 62 solo observa y valida presupuestos.

### 6.2 Salida de chunks del anillo (M08/M12/M63)
1. El 63 avisa `chunk_saliendo(chunk)`.
2. El 62 marca candidato LRU (distancia primero).
3. Si presupuesto voxel OK → no hace nada; si supera 90% → `recurso_descargar` escalonado.
4. Mesh al pool `mesh_chunk`, buffers voxel liberados, collider liberado; evento `recurso_descargado` para contador y log.

### 6.3 Cambio de escena/bioma de audio
1. `SceneMemory` drena pools (devolver todo), cancela timers/tweens (anti-leak RN3).
2. `AudioMemory` descarga el banco del bioma anterior **diferido 1 frame** (no corta transiciones M32).
3. Texturas de la región anterior → evicción LRU si el presupuesto lo pide.

### 6.4 Drift check (RN3 / RF1)
- Baseline estabilizada a los 5 min; cada 5 min se compara; si el drift > 5% → semáforo 2 y log con el sistema responsable (contadores por familia).

## 7. Integraciones

| Módulo | Relación |
|---|---|
| M08 (voxel) | `ChunkMemory`: buffers, meshes y colliders; pool `mesh_chunk`; diffs del jugador sin historial infinito |
| M41-M44 (audio) | `AudioMemory`: bancos por bioma, streaming de pistas largas, tope de 24 voces (M43) |
| M61 (rendimiento) | Consumo: frame budgets (deltas < 50 ms) y presupuestos globales; NO tocar la carpeta 61 |
| M63 (streaming) | Handshake de carga/descarga; el 62 no carga nada; el 63 no libera nada |
| M90 (config gráfica) | Preset activo determina `budgets.tres` (Baja/Media/Alta) |
| M103/M110 | Reportes de semáforo, drift y descargas al log y al Debug Menu |

## 8. Mediciones objetivo (RN10)

| Punto de interés | Objetivo |
|---|---|
| Menú principal | < 600 MB |
| Spawn en Aurora (anillo LOD 0-3) | < 1.600 MB |
| Horizonte terrestre completo oteado | < 2.200 MB |
| Subterráneo del templo (M26) | < 2.000 MB |
| Tormenta con clima máximo (M32) + banco de audio completo | ≤ 2.500 MB (Alta) |
| Drift en sesión de 30 min | ≤ 5% sobre baseline |