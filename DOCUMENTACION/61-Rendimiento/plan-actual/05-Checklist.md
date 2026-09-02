**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Reserva actual

- Estado: 🔵 En curso — iter 2 benchmark visual (2026-09-01, deepseek-v4-flash-vision-exp / Kilo Code)
- Agente: deepseek-v4-flash-vision-exp (Kilo Code)
- Fase: 5 (Base de producción)
- Dificultad: 5
- Vision: V2 (benchmark visual: profiler screenshots, draw calls, capturas)
- Entrada: M08 ✅ (terreno voxel), iter 1 ✅ (BudgetProfile + budgets.json + ValidateBudget)
- Salida: bench_scene_a.tscn + bench_recorder.gd + mediciones reales (JSON) + capturas + check ValidateBudget
- Archivos: `scenes/bench_scene_a.tscn`, `scripts/performance/bench_recorder.gd`, `docs/performance/medicion_2026-09-01.md`
- Fecha reserva: 2026-09-01 16:30

## Iteración 2 (benchmark visual — 2026-09-01, deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Crear `bench_scene_a.tscn` — escena de benchmark oficial [C] — `scenes/bench_scene_a.tscn` (terreno M08 seed 42/radio 256/altura 40 + paleta Maldivas completa + viewer + cámara con 6 waypoints)
- [x] Crear `bench_recorder.gd` [C] — `scripts/performance/bench_recorder.gd`: recorrido 90 s (6 waypoints × 15 s), overlay FPS + draw calls + objects en pantalla, muestreo cada 30 frames, JSON en `user://logs/bench/bench_AAAAMMDD.json`, check `ValidateBudget`/veredicto 60 FPS, hardware capturado (RenderingServer)
- [x] Instrumentar con BudgetProfile (etiquetas del Profiler, metodología RF D.55) [M] — sección render medida con `begin_section`/`frame_post_draw`/`end_section` en el recorder
- [x] Fix regresión de indentación en `equipment_manager.gd` (35 líneas espacios→tabs) que bloqueaba el boot [S] — causa del Debugger Break (ver guía 07 §9.60)
- [x] Ejecución del bench → mediciones reales [C] — COMPLETADO 2026-09-01 (Log 386): 90 s, 179 muestras; FPS 59.35 (WARN -0.65), draw calls 374.0 (máx 471; objetivo <=400 ✅), objects 477, process 0.018 ms, frame 16.35 ms; JSON user://logs/bench/bench_2026-09-01.json + 2 capturas en tools/mcp/godot-mcp/capturas/61-Rendimiento/
- [x] Documentar metodología de capturas del profiler [S] — capturas planificadas en `tools/mcp/godot-mcp/capturas/61-Rendimiento/` (overlay con FPS/draw calls visible en primer plano) + sección 6 de 04-Codigo

# 05-Checklist.md — Módulo 61: Rendimiento (130 ítems)

> **Nota 2026-08-30 (Deepseek V4 Flash / Kilo):** M61 es una NORMA transversal. El plan-inicial
> ya resolvía el diseño de los 28 RF. Esta iteración implementa la parte ejecutable:
> `BudgetProfile` (instrumentación), `budgets.json` (tabla oficial 16,7 ms) y `ValidateBudget`
> (gate CI). Los ítems de técnicas concretas (LOD/batching/instancing/pooling) viven en el
> módulo dueño (M07/M50/M52/...) y quedan `[ ]` aquí. La `bench_scene_a.tscn` requiere visión
> (V2). Log 255.

## A. Objetivo de FPS (RF1)

- [x] Definir 60 FPS como objetivo (hardware recomendado) [S]
- [x] Definir 30 FPS mínimo sostenido (hardware mínimo) [S]
- [ ] Definir vsync activado sin tearing [S]
- [ ] Documentar objetivo por preset de calidad (M91) [M]
- [x] Registrar presupuesto total 16,7 ms en budgets.cfg [S]

## B. Hardware Mínimo (RF2)

- [x] Definir GPU integrada de referencia [M]
- [x] Definir 8 GB RAM como mínimo [S]
- [x] Definir SSD (cargas en <30 s frío) [S]
- [?] Alinear con M114 (hardware objetivo) [M]
- [ ] Documentar resolución base (1080p) en mínimo [S]

## C. Hardware Recomendado (RF3)

- [x] Definir GPU dedicada de referencia [M]
- [x] Definir 16 GB RAM recomendado [S]
- [x] Definir SSD NVMe (cargas <10 s caliente) [S]
- [ ] Documentar 1080p 60 FPS estable en recomendado [S]
- [?] Alinear con M114 y presets M91 [M]

## D. Medir CPU (RF4)

- [x] Definir trazas por sistema (gameplay, voxel, IA, física) [M]
- [x] Definir presupuesto gameplay 2,5 ms [S]
- [x] Definir presupuesto mundo voxel 4,0 ms [S]
- [x] Definir presupuesto IA 2,0 ms [S]
- [?] Documentar metodología (Profiler Godot + etiquetas) [M]

## E. Medir GPU (RF5)

- [ ] Definir draw calls por escena objetivo [M]
- [x] Definir presupuesto render 5,0 ms [S]
- [ ] Definir control de overdraw (vegetación/sombras) [M]
- [ ] Documentar coste de shaders por material [M]
- [ ] Definir límite de draw calls por chunk [M]

## F. Medir RAM (RF6)

- [x] Delegar análisis de RAM a M62 [S]
- [x] Definir que M61 solo acota el frame (allocations) [S]
- [ ] Registrar RSS por escena en bench JSON [M]
- [ ] Coordinar pausas de GC con M62 [M]
- [ ] Documentar presupuesto de VRAM en bench [M]

## G. Medir VRAM (RF7)

- [ ] Definir texturas 4K comprimidas máx (M47) [M]
- [ ] Definir presupuesto de VRAM por escena [M]
- [ ] Definir atlas de UI (M53) [M]
- [ ] Documentar compresión BC/ASTC por plataforma [M]
- [ ] Validar VRAM < presupuesto en GPU mínima [C]

## H. Medir Disco (RF8)

- [ ] Definir carga frío <30 s (SSD mínimo) [M]
- [ ] Definir carga caliente <10 s (SSD recomendado) [M]
- [ ] Definir HDD como no soportado (documentado) [S]
- [ ] Documentar tamaño máximo de paquete de datos [M]
- [ ] Validar tiempos con build de instalador (M115) [C]

## I. Tiempos de Carga (RF9)

- [ ] Definir carga asíncrona obligatoria (M63) [S]
- [ ] Definir progreso real con mensajes de estado (AGENTS §8) [S]
- [ ] Definir bloqueo cero del hilo principal [M]
- [ ] Documentar precarga de escena siguiente [M]
- [ ] Validar pantalla de carga sin frames congelados [C]

## J. Generación de Chunks (RF10)

- [ ] Definir generación en background thread (M07) [M]
- [ ] Definir <5 ms/frame consumido por generación [M]
- [ ] Definir sin trabajo voxel en main thread [S]
- [ ] Documentar cola de chunks con prioridad [M]
- [ ] Validar generación con stream continuo (M63) [C]

## K. Destrucción de Bloques (RF11)

- [ ] Definir remesh difuso <2 ms por bloque [M]
- [ ] Definir sin GC en el bucle de interacción [M]
- [ ] Definir pooling de buffers de mesh [M]
- [ ] Documentar remesh en background (M07) [S]
- [ ] Validar destrucción masiva sin picos [C]

## L. Medir NPC (RF12)

- [ ] Definir ≤20 NPCs activos visibles [M]
- [ ] Definir LOD de actualización por distancia (M19/M64) [M]
- [x] Definir presupuesto IA 2,0 ms (total) [S]
- [ ] Documentar pooling de instancias NPC [M]
- [ ] Validar pueblo completo 60 FPS [C]

## M. Medir Partículas (RF13)

- [ ] Definir pooling de partículas (M52) [M]
- [ ] Definir ≤500 partículas simultáneas por cámara [M]
- [ ] Definir GPUParticles para larga vida (fuego/lava) [M]
- [ ] Documentar límite por evento [S]
- [ ] Validar festival (M74) sin picos [C]

## N. Sombras (RF14)

- [ ] Definir sombras dinámicas solo personajes y objetos clave [M]
- [ ] Definir sombras blended para estáticos [M]
- [ ] Definir rango de cascada limitado [M]
- [ ] Documentar costo de sombras por material [S]
- [ ] Validar noche con faroles (M49) 60 FPS [C]

## O. Iluminación (RF15)

- [ ] Definir GI suave sin bounce caro (M49) [M]
- [ ] Definir luz horaria barata (1 directional + sky) [M]
- [ ] Definir luces real-time minimizadas [S]
- [ ] Documentar lightmap/baked para interiores (M17) [M]
- [ ] Validar ciclo día/noche sin drop [C]

## P. Agua (RF16)

- [ ] Definir plano único de agua (M51) [M]
- [ ] Definir normales animadas en shader (no CPU) [M]
- [ ] Definir reflejos solo superficie [M]
- [ ] Documentar transparencia ordenada [M]
- [ ] Validar mar visible sin overdraw [C]

## Q. Vegetación (RF17)

- [ ] Definir GPU instancing obligatorio (M50) [M]
- [ ] Definir viento en vertex shader (no CPU) [M]
- [ ] Definir culling de vegetación por viento oclusivo [M]
- [ ] Documentar presupuesto de instancias por chunk [M]
- [ ] Validar bosque denso 60 FPS [C]

## R. Distancia de Dibujado (RF18)

- [ ] Definir presets 100/150/220 m (M91) [M]
- [ ] Definir LOD escalonado por distancia [M]
- [ ] Definir que el mar siempre se ve (cozy) [S]
- [ ] Documentar memoria de chunks por distancia (M62) [M]
- [ ] Validar preset mínimo 30 FPS [C]

## S. Frustum Culling (RF19)

- [ ] Usar frustum del engine por defecto [S]
- [ ] Definir culling por chunks (M07) [M]
- [ ] Definir culling de NPC/objetos por distancia [M]
- [ ] Documentar culling de partículas [M]
- [ ] Validar culling eficaz en bench [C]

## T. Occlusion Culling (RF20)

- [ ] Definir occlusion por celdas de chunks [M]
- [ ] Aplicar solo en cuevas y templos (M24/M25) [M]
- [ ] Descartar occlusion global en terreno abierto [S]
- [ ] Documentar coste de GPU queries acotado [M]
- [ ] Validar templo subterráneo (M25) 60 FPS [C]

## U. LOD (RF21)

- [ ] Definir 3 niveles de LOD para mallas voxel [M]
- [ ] Definir impostor lejano (malla simpl. + textura) [M]
- [ ] Definir LOD de NPC/fauna por distancia [M]
- [ ] Definir transición sin pop (2 m) [M]
- [ ] Validar ausencia de pop en cámara principal [C]

## V. Batching (RF22)

- [ ] Usar meshes combinados por chunk (M07) [S]
- [ ] Definir batching de estáticos por bioma [M]
- [ ] Definir límite de materiales por batch [M]
- [ ] Documentar batching de UI (M53) [M]
- [ ] Validar draw calls dentro de presupuesto [C]

## W. GPU Instancing (RF23)

- [ ] Aplicar a vegetación (M50) [M]
- [ ] Aplicar a rocas y fragmentos (M08) [M]
- [ ] Aplicar a partículas de larga vida [M]
- [ ] Documentar instancing de peces (M34) [M]
- [ ] Validar instancing con multimesh de Voxel Tools [C]

## X. Pooling (RF24)

- [ ] Pooling de partículas (M52) [M]
- [ ] Pooling de fauna y peces (M35/M34) [M]
- [ ] Pooling de efectos de herramientas [M]
- [ ] Pooling de buffers de remesh [M]
- [ ] Validar cero allocations en lazo caliente [C]

## Y. Allocations, GC y Profiling (RF25-RF27)

- [ ] Definir cero allocations en bucles calientes [M]
- [ ] Definir reuso de Arrays/Variants [M]
- [ ] Definir GC en pausas seguras (transiciones M63) [M]
- [x] Definir gate CI con bench scene (M116) [M]
- [ ] Definir playtest obligatorio en build de profiling [M]

## Z. Cierre del Módulo

- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [x] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]
## Iteración 2c — Gate verificado (2026-09-01 22:35, deepseek-v4-flash-vision-exp)

- [x] Gate ValidateBudget ejecutado en headless: godot --headless -s res://scripts/performance/validate_budget.gd → **0 fallos, exit 0** (tabla budgets.json completa: total>0, tolerancia>0, 7 categorías, suma coherente, hardware decl., medición OK/excedida detectada) [S]
- [x] Medición real del bench (Log 386) validada contra el presupuesto manualmente: frame 16.35 ms <= 16.7 ms total (dentro de tolerancia) — punto de partida del gate CI
- [?] Cableado del gate a GitHub Actions (job que corra validate_budget + bench en CI) — pertenece al módulo M118 (CI-CD, 0/100, 🟢 disponible); el runner necesita GPU/Windows para el bench y el workflow actual usa Godot 4.3 (el proyecto es 4.7.2) — actualizarlo es tarea de M118
