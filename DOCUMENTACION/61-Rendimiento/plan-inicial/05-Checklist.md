**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 61: Rendimiento (130 ítems)

## A. Objetivo de FPS (RF1)

- [x] Definir 60 FPS como objetivo (hardware recomendado) [S]
- [x] Definir 30 FPS mínimo sostenido (hardware mínimo) [S]
- [x] Definir vsync activado sin tearing [S]
- [x] Documentar objetivo por preset de calidad (M91) [M]
- [x] Registrar presupuesto total 16,7 ms en budgets.cfg [S]

## B. Hardware Mínimo (RF2)

- [x] Definir GPU integrada de referencia [M]
- [x] Definir 8 GB RAM como mínimo [S]
- [x] Definir SSD (cargas en <30 s frío) [S]
- [x] Alinear con M114 (hardware objetivo) [M]
- [x] Documentar resolución base (1080p) en mínimo [S]

## C. Hardware Recomendado (RF3)

- [x] Definir GPU dedicada de referencia [M]
- [x] Definir 16 GB RAM recomendado [S]
- [x] Definir SSD NVMe (cargas <10 s caliente) [S]
- [x] Documentar 1080p 60 FPS estable en recomendado [S]
- [x] Alinear con M114 y presets M91 [M]

## D. Medir CPU (RF4)

- [x] Definir trazas por sistema (gameplay, voxel, IA, física) [M]
- [x] Definir presupuesto gameplay 2,5 ms [S]
- [x] Definir presupuesto mundo voxel 4,0 ms [S]
- [x] Definir presupuesto IA 2,0 ms [S]
- [x] Documentar metodología (Profiler Godot + etiquetas) [M]

## E. Medir GPU (RF5)

- [x] Definir draw calls por escena objetivo [M]
- [x] Definir presupuesto render 5,0 ms [S]
- [x] Definir control de overdraw (vegetación/sombras) [M]
- [x] Documentar coste de shaders por material [M]
- [x] Definir límite de draw calls por chunk [M]

## F. Medir RAM (RF6)

- [x] Delegar análisis de RAM a M62 [S]
- [x] Definir que M61 solo acota el frame (allocations) [S]
- [x] Registrar RSS por escena en bench JSON [M]
- [x] Coordinar pausas de GC con M62 [M]
- [x] Documentar presupuesto de VRAM en bench [M]

## G. Medir VRAM (RF7)

- [x] Definir texturas 4K comprimidas máx (M47) [M]
- [x] Definir presupuesto de VRAM por escena [M]
- [x] Definir atlas de UI (M53) [M]
- [x] Documentar compresión BC/ASTC por plataforma [M]
- [x] Validar VRAM < presupuesto en GPU mínima [C]

## H. Medir Disco (RF8)

- [x] Definir carga frío <30 s (SSD mínimo) [M]
- [x] Definir carga caliente <10 s (SSD recomendado) [M]
- [x] Definir HDD como no soportado (documentado) [S]
- [x] Documentar tamaño máximo de paquete de datos [M]
- [x] Validar tiempos con build de instalador (M115) [C]

## I. Tiempos de Carga (RF9)

- [x] Definir carga asíncrona obligatoria (M63) [S]
- [x] Definir progreso real con mensajes de estado (AGENTS §8) [S]
- [x] Definir bloqueo cero del hilo principal [M]
- [x] Documentar precarga de escena siguiente [M]
- [x] Validar pantalla de carga sin frames congelados [C]

## J. Generación de Chunks (RF10)

- [x] Definir generación en background thread (M07) [M]
- [x] Definir <5 ms/frame consumido por generación [M]
- [x] Definir sin trabajo voxel en main thread [S]
- [x] Documentar cola de chunks con prioridad [M]
- [x] Validar generación con stream continuo (M63) [C]

## K. Destrucción de Bloques (RF11)

- [x] Definir remesh difuso <2 ms por bloque [M]
- [x] Definir sin GC en el bucle de interacción [M]
- [x] Definir pooling de buffers de mesh [M]
- [x] Documentar remesh en background (M07) [S]
- [x] Validar destrucción masiva sin picos [C]

## L. Medir NPC (RF12)

- [x] Definir ≤20 NPCs activos visibles [M]
- [x] Definir LOD de actualización por distancia (M19/M64) [M]
- [x] Definir presupuesto IA 2,0 ms (total) [S]
- [x] Documentar pooling de instancias NPC [M]
- [x] Validar pueblo completo 60 FPS [C]

## M. Medir Partículas (RF13)

- [x] Definir pooling de partículas (M52) [M]
- [x] Definir ≤500 partículas simultáneas por cámara [M]
- [x] Definir GPUParticles para larga vida (fuego/lava) [M]
- [x] Documentar límite por evento [S]
- [x] Validar festival (M74) sin picos [C]

## N. Sombras (RF14)

- [x] Definir sombras dinámicas solo personajes y objetos clave [M]
- [x] Definir sombras blended para estáticos [M]
- [x] Definir rango de cascada limitado [M]
- [x] Documentar costo de sombras por material [S]
- [x] Validar noche con faroles (M49) 60 FPS [C]

## O. Iluminación (RF15)

- [x] Definir GI suave sin bounce caro (M49) [M]
- [x] Definir luz horaria barata (1 directional + sky) [M]
- [x] Definir luces real-time minimizadas [S]
- [x] Documentar lightmap/baked para interiores (M17) [M]
- [x] Validar ciclo día/noche sin drop [C]

## P. Agua (RF16)

- [x] Definir plano único de agua (M51) [M]
- [x] Definir normales animadas en shader (no CPU) [M]
- [x] Definir reflejos solo superficie [M]
- [x] Documentar transparencia ordenada [M]
- [x] Validar mar visible sin overdraw [C]

## Q. Vegetación (RF17)

- [x] Definir GPU instancing obligatorio (M50) [M]
- [x] Definir viento en vertex shader (no CPU) [M]
- [x] Definir culling de vegetación por viento oclusivo [M]
- [x] Documentar presupuesto de instancias por chunk [M]
- [x] Validar bosque denso 60 FPS [C]

## R. Distancia de Dibujado (RF18)

- [x] Definir presets 100/150/220 m (M91) [M]
- [x] Definir LOD escalonado por distancia [M]
- [x] Definir que el mar siempre se ve (cozy) [S]
- [x] Documentar memoria de chunks por distancia (M62) [M]
- [x] Validar preset mínimo 30 FPS [C]

## S. Frustum Culling (RF19)

- [x] Usar frustum del engine por defecto [S]
- [x] Definir culling por chunks (M07) [M]
- [x] Definir culling de NPC/objetos por distancia [M]
- [x] Documentar culling de partículas [M]
- [x] Validar culling eficaz en bench [C]

## T. Occlusion Culling (RF20)

- [x] Definir occlusion por celdas de chunks [M]
- [x] Aplicar solo en cuevas y templos (M24/M25) [M]
- [x] Descartar occlusion global en terreno abierto [S]
- [x] Documentar coste de GPU queries acotado [M]
- [x] Validar templo subterráneo (M25) 60 FPS [C]

## U. LOD (RF21)

- [x] Definir 3 niveles de LOD para mallas voxel [M]
- [x] Definir impostor lejano (malla simpl. + textura) [M]
- [x] Definir LOD de NPC/fauna por distancia [M]
- [x] Definir transición sin pop (2 m) [M]
- [x] Validar ausencia de pop en cámara principal [C]

## V. Batching (RF22)

- [x] Usar meshes combinados por chunk (M07) [S]
- [x] Definir batching de estáticos por bioma [M]
- [x] Definir límite de materiales por batch [M]
- [x] Documentar batching de UI (M53) [M]
- [x] Validar draw calls dentro de presupuesto [C]

## W. GPU Instancing (RF23)

- [x] Aplicar a vegetación (M50) [M]
- [x] Aplicar a rocas y fragmentos (M08) [M]
- [x] Aplicar a partículas de larga vida [M]
- [x] Documentar instancing de peces (M34) [M]
- [x] Validar instancing con multimesh de Voxel Tools [C]

## X. Pooling (RF24)

- [x] Pooling de partículas (M52) [M]
- [x] Pooling de fauna y peces (M35/M34) [M]
- [x] Pooling de efectos de herramientas [M]
- [x] Pooling de buffers de remesh [M]
- [x] Validar cero allocations en lazo caliente [C]

## Y. Allocations, GC y Profiling (RF25-RF27)

- [x] Definir cero allocations en bucles calientes [M]
- [x] Definir reuso de Arrays/Variants [M]
- [x] Definir GC en pausas seguras (transiciones M63) [M]
- [x] Definir gate CI con bench scene (M116) [M]
- [x] Definir playtest obligatorio en build de profiling [M]

## Z. Cierre del Módulo

- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [x] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [x] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]