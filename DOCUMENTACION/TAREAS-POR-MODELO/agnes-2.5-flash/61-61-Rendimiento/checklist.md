# Tareas módulo 61 61-Rendimiento

**Estado:** ðŸŸ¡ Con dudas

**Items pendientes:** 106

[ ] T-61-001: Definir vsync activado sin tearing
[ ] T-61-002: Documentar objetivo por preset de calidad (M91)
[ ] T-61-003: Alinear con M114 (hardware objetivo)
[ ] T-61-004: Documentar resolución base (1080p) en mínimo
[ ] T-61-005: Documentar 1080p 60 FPS estable en recomendado
[ ] T-61-006: Alinear con M114 y presets M91
[ ] T-61-007: Documentar metodología (Profiler Godot + etiquetas)
[ ] T-61-008: Definir draw calls por escena objetivo
[ ] T-61-009: Definir control de overdraw (vegetación/sombras)
[ ] T-61-010: Documentar coste de shaders por material
[ ] T-61-011: Definir límite de draw calls por chunk
[ ] T-61-012: Coordinar pausas de GC con M62
[ ] T-61-013: Documentar presupuesto de VRAM en bench
[ ] T-61-014: Definir texturas 4K comprimidas máx (M47)
[ ] T-61-015: Definir presupuesto de VRAM por escena
[ ] T-61-016: Definir atlas de UI (M53)
[ ] T-61-017: Documentar compresión BC/ASTC por plataforma
[ ] T-61-018: Validar VRAM < presupuesto en GPU mínima
[ ] T-61-019: Definir carga frío <30 s (SSD mínimo)
[ ] T-61-020: Definir carga caliente <10 s (SSD recomendado)
[ ] T-61-021: Definir HDD como no soportado (documentado)
[ ] T-61-022: Documentar tamaño máximo de paquete de datos
[ ] T-61-023: Definir carga asíncrona obligatoria (M63)
[ ] T-61-024: Definir progreso real con mensajes de estado (AGENTS §8)
[ ] T-61-025: Definir bloqueo cero del hilo principal
[ ] T-61-026: Documentar precarga de escena siguiente
[ ] T-61-027: Validar pantalla de carga sin frames congelados
[ ] T-61-028: Definir generación en background thread (M07)
[ ] T-61-029: Definir <5 ms/frame consumido por generación
[ ] T-61-030: Definir sin trabajo voxel en main thread
[ ] T-61-031: Documentar cola de chunks con prioridad
[ ] T-61-032: Validar generación con stream continuo (M63)
[ ] T-61-033: Definir remesh difuso <2 ms por bloque
[ ] T-61-034: Definir sin GC en el bucle de interacción
[ ] T-61-035: Definir pooling de buffers de mesh
[ ] T-61-036: Documentar remesh en background (M07)
[ ] T-61-037: Validar destrucción masiva sin picos
[ ] T-61-038: Definir ≤20 NPCs activos visibles
[ ] T-61-039: Definir LOD de actualización por distancia (M19/M64)
[ ] T-61-040: Documentar pooling de instancias NPC
[ ] T-61-041: Validar pueblo completo 60 FPS
[ ] T-61-042: Definir pooling de partículas (M52)
[ ] T-61-043: Definir ≤500 partículas simultáneas por cámara
[ ] T-61-044: Definir GPUParticles para larga vida (fuego/lava)
[ ] T-61-045: Documentar límite por evento
[ ] T-61-046: Validar festival (M74) sin picos
[ ] T-61-047: Definir sombras dinámicas solo personajes y objetos clave
[ ] T-61-048: Definir sombras blended para estáticos
[ ] T-61-049: Definir rango de cascada limitado
[ ] T-61-050: Documentar costo de sombras por material
[ ] T-61-051: Validar noche con faroles (M49) 60 FPS
[ ] T-61-052: Definir GI suave sin bounce caro (M49)
[ ] T-61-053: Definir luz horaria barata (1 directional + sky)
[ ] T-61-054: Definir luces real-time minimizadas
[ ] T-61-055: Documentar lightmap/baked para interiores (M17)
[ ] T-61-056: Validar ciclo día/noche sin drop
[ ] T-61-057: Definir plano único de agua (M51)
[ ] T-61-058: Definir normales animadas en shader (no CPU)
[ ] T-61-059: Definir reflejos solo superficie
[ ] T-61-060: Documentar transparencia ordenada
[ ] T-61-061: Validar mar visible sin overdraw
[ ] T-61-062: Definir GPU instancing obligatorio (M50)
[ ] T-61-063: Definir viento en vertex shader (no CPU)
[ ] T-61-064: Definir culling de vegetación por viento oclusivo
[ ] T-61-065: Documentar presupuesto de instancias por chunk
[ ] T-61-066: Validar bosque denso 60 FPS
[ ] T-61-067: Definir presets 100/150/220 m (M91)
[ ] T-61-068: Definir LOD escalonado por distancia
[ ] T-61-069: Definir que el mar siempre se ve (cozy)
[ ] T-61-070: Documentar memoria de chunks por distancia (M62)
[ ] T-61-071: Validar preset mínimo 30 FPS
[ ] T-61-072: Usar frustum del engine por defecto
[ ] T-61-073: Definir culling por chunks (M07)
[ ] T-61-074: Definir culling de NPC/objetos por distancia
[ ] T-61-075: Documentar culling de partículas
[ ] T-61-076: Validar culling eficaz en bench
[ ] T-61-077: Definir occlusion por celdas de chunks
[ ] T-61-078: Aplicar solo en cuevas y templos (M24/M25)
[ ] T-61-079: Descartar occlusion global en terreno abierto
[ ] T-61-080: Documentar coste de GPU queries acotado
[ ] T-61-081: Validar templo subterráneo (M25) 60 FPS
[ ] T-61-082: Definir 3 niveles de LOD para mallas voxel
[ ] T-61-083: Definir impostor lejano (malla simpl. + textura)
[ ] T-61-084: Definir LOD de NPC/fauna por distancia
[ ] T-61-085: Definir transición sin pop (2 m)
[ ] T-61-086: Validar ausencia de pop en cámara principal
[ ] T-61-087: Usar meshes combinados por chunk (M07)
[ ] T-61-088: Definir batching de estáticos por bioma
[ ] T-61-089: Definir límite de materiales por batch
[ ] T-61-090: Documentar batching de UI (M53)
[ ] T-61-091: Validar draw calls dentro de presupuesto
[ ] T-61-092: Aplicar a vegetación (M50)
[ ] T-61-093: Aplicar a rocas y fragmentos (M08)
[ ] T-61-094: Aplicar a partículas de larga vida
[ ] T-61-095: Documentar instancing de peces (M34)
[ ] T-61-096: Validar instancing con multimesh de Voxel Tools
[ ] T-61-097: Pooling de partículas (M52)
[ ] T-61-098: Pooling de fauna y peces (M35/M34)
[ ] T-61-099: Pooling de efectos de herramientas
[ ] T-61-100: Pooling de buffers de remesh
[ ] T-61-101: Validar cero allocations en lazo caliente
[ ] T-61-102: Definir cero allocations en bucles calientes
[ ] T-61-103: Definir reuso de Arrays/Variants
[ ] T-61-104: Definir GC en pausas seguras (transiciones M63)
[ ] T-61-105: Verificar con verificar_checklist.py (sin alertas nuevas)
[ ] T-61-106: Cableado del gate a GitHub Actions (job que corra validate_budget + bench en CI) — pertenece al módulo M118 (CI-CD, 0/100, 🟢 disponible); el runner ne
