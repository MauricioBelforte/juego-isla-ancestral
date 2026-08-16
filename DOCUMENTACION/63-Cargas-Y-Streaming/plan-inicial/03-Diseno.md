**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 63: Cargas y Streaming

## 1. Arquitectura

```
          StreamManager.gd (autoload)
   ┌───────┬──────────────┬──────────────┬──────────────┐
   ▼       ▼              ▼              ▼              ▼
  Cola   AsyncLoader  ChunkStream   LODManager   Precalentador
  (prio) (threaded)   (LRU M08)     (mips/mesh)  (menú principal)
   │       │              │              │              │
   └───────┴───────┬──────┴──────────────┴──────────────┘
                   ▼
          ProgresoReal (pesos por operación)
                   ▼
          LoadingScreen.gd (barra + consejos cozy)
                   ▼
          Eventos: chunk_listo, banco_listo, shader_listo
```

## 2. Pesos de progreso (RF-11)

| Operación | Peso |
|---|---|
| Chunk voxel (LOD 0) | 1 |
| Chunk voxel (LOD 1+) | 3 |
| Banco de audio regional | 3 |
| Textura atlas (mip) | 2 |
| Compilación de shader | 5 |
| Instanciación de NPC | 1 |
| Malla de región (océano/isla) | 4 |

Barra = (Σ pesos completados) / (Σ pesos totales encolados) × 100. Piso 2% mientras haya operaciones (feedback inmediato), tope 98% hasta cerrar.

## 3. Cola de streaming (prioridades)

1. Chunks del anillo 0-1 (alrededor del jugador)
2. Chunks anillo 2-3 (precarga anticipada del movimiento)
3. Bancos de audio + texturas de la región
4. Chunks anillo 4-5 (solo si presupuesto OK)
5. Precalentamiento demandado por near-event (Gran Vapor → isla destino)

## 4. LRU de chunks (M08)

- Tope hard `MAX_CHUNKS` (config; default 4096 en PC, 2048 en Deck).
- Descarga: `chunk_distancia > R_max + 1` → marcar envejecido → 2 frames después se libera (silencioso).
- Prioridad de descarga: primero los más lejanos, luego los más viejos en uso (distancia pesa más).
- El pool de meshes se reutiliza (sin allocs de Memory por frame — M61).

## 5. Streaming por región de mundo

- **Océano:** anillo de LOD con 3 coronas (lejano lowpoly estático → medio → costa detallada). El anillo sigue a la cámara (M12); updates solo en el borde del anillo.
- **Subterráneo:** pisos LOD: piso 0 (techo, dentro de cueva real) y 1-2 (profundidad opcional futura); al subir se descarga el piso bajo sin huecos (encadenado LOD 0 precargado del piso destino).
- **Islas:** `StreamableBox` por isla (caja inicial: radio 10 m alrededor del aterrizaje); entra → preload LOD 0; el vuelo de aproximación (M28) precarga la isla destino al 60% de la ruta.

## 6. Pantalla de carga (cozy)

- Escena full-screen con arte del mundo (islas, nubes animadas en parallax suave).
- Barra con progreso real + texto de etapa ("Cargando islas...", "Calentando bancos de audio..." — sección 8 AGENTS).
- Consejos de mundo rotando (base de datos `tips.txt`, seed por partida M29).
- Al terminar → transición fade a la escena; el jugador nunca ve "espera injustificada".
- Movimiento rápido (Fast Travel/teletransporte M69/gran vapor): transición corta (≤ 2 s) con fades, sin pantalla de carga plena (el mundo es continuo).

## 7. Precalentamiento (menú principal)

1. Al arrancar el juego: `precalentar_mundo()` — shaders del mundo/efectos, bancos de bioma inicial, atlas base, chunk seed del spawn (si hay partida, 3 anillos alrededor del punto de guardado).
2. Al elegir "Continuar": solo se encola el resto (resto < 30 operaciones) → carga casi instantánea.

## 8. Anti-congelamiento (reglas verificables)

- Prohibido `load()` síncrono en gameplay; todo vía cola.
- Deltas de frames de streaming < 50 ms (M113 profiler).
- `_process`/`_physics_process` libres de trabajo de carga.
- Test de movimiento rápido: teleport extremo a extremo ×10 sin hitching.

## 9. QA

- Test M112: barra real (pesos correctos), precarga sin huecos, LRU libera memoria (Memory Profiler), delta < 50 ms.
- Test movimiento: teleport + Gran Vapor + buceo (subterráneo) sin chunks vacíos.
- Deck: presupuesto 2048 chunks, textures comprimidas (M47 alineado).