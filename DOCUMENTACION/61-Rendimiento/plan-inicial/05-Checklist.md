**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 61: Rendimiento (130 ítems)

## A. Objetivo de FPS (RF1)

- [ ] Definir 60 FPS como objetivo (hardware recomendado) [S]
- [ ] Definir 30 FPS mínimo sostenido (hardware mínimo) [S]
- [ ] Definir vsync activado sin tearing [S]
- [ ] Documentar objetivo por preset de calidad (M91) [M]
- [ ] Registrar presupuesto total 16,7 ms en budgets.cfg [S]

## B. Hardware Mínimo (RF2)

- [ ] Definir GPU integrada de referencia [M]
- [ ] Definir 8 GB RAM como mínimo [S]
- [ ] Definir SSD (cargas en <30 s frío) [S]
- [ ] Alinear con M114 (hardware objetivo) [M]
- [ ] Documentar resolución base (1080p) en mínimo [S]

## C. Hardware Recomendado (RF3)

- [ ] Definir GPU dedicada de referencia [M]
- [ ] Definir 16 GB RAM recomendado [S]
- [ ] Definir SSD NVMe (cargas <10 s caliente) [S]
- [ ] Documentar 1080p 60 FPS estable en recomendado [S]
- [ ] Alinear con M114 y presets M91 [M]

## D. Medir CPU (RF4)

- [ ] Definir trazas por sistema (gameplay, voxel, IA, física) [M]
- [ ] Definir presupuesto gameplay 2,5 ms [S]
- [ ] Definir presupuesto mundo voxel 4,0 ms [S]
- [ ] Definir presupuesto IA 2,0 ms [S]
- [ ] Documentar metodología (Profiler Godot + etiquetas) [M]

## E. Medir GPU (RF5)

- [ ] Definir draw calls por escena objetivo [M]
- [ ] Definir presupuesto render 5,0 ms [S]
- [ ] Definir control de overdraw (vegetación/sombras) [M]
- [ ] Documentar coste de shaders por material [M]
- [ ] Definir límite de draw calls por chunk [M]

## F. Medir RAM (RF6)

- [ ] Delegar análisis de RAM a M62 [S]
- [ ] Definir que M61 solo acota el frame (allocations) [S]
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
- [ ] Definir presupuesto IA 2,0 ms (total) [S]
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
- [ ] Definir gate CI con bench scene (M116) [M]
- [ ] Definir playtest obligatorio en build de profiling [M]

## Z. Cierre del Módulo

- [ ] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [ ] Firmar los documentos del módulo (modelo y plataforma) [S]
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]