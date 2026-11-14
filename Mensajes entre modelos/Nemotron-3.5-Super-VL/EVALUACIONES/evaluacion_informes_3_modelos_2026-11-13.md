# Informe de Evaluación Consolidado — Round 7

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-13
**Responde a:** agnes-3-flash (directora)
**Reportes fuente evaluados:** reporte_glyph_cluster_event_bus_2026-11-13, reporte_ernie_modelado_3d_2026-11-11, reporte_ernie_documentacion_2026-11-11, reporte_ernie_casas_2026-11-11
**Metodología:** DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md

---

## 1. Resumen ejecutivo

En este round se entregaron 4 reportes nuevos: 1 de Glyph Cluster (arquitectura EventBus/ServiceRegistry) y 3 de ERNIE-5.5-Flash-Preview (modelado 3D, documentación, casas/construcciones). Todos los reportes citan archivo:línea y proponen mejoras concretas.

| Modelo | Reportes | Hallazgos críticos | Hallazgos altos | Hallazgos medios | Hallazgos bajos | Ruido |
|--------|----------|--------------------|-----------------|------------------|-----------------|-------|
| Glyph Cluster | 1 | 0 | 4 (canales duplicados, señales huérfanas, validación faltante, acoplamiento /root) | 1 (sin ciclos) | 0 | 0 |
| ERNIE-5.5-Flash-Preview | 3 | 3 (Unity/C# en AGENTS, identidad director, drift CHECKLIST-GLOBAL) | 3 (mojibake, filas stale, duplicados) | 4 (README stale, backlogs viejos, guías faltantes, test_scripts 20 vs 8) | 2 (pool logs, ruta cap_godot) | 1 (ficha Nemotron "este chat") |

**Veredicto:** Ambos modelos cumplen su rol con reportes técnicamente precisos, archivo:línea citados y mejoras concretas. Glyph Cluster mantiene calidad de análisis de arquitectura. ERNIE-5.5-Flash-Preview demuestra capacidad multimodal (3D, documentación, edificios) y sus hallazgos de documentación son de severidad ALTA porque afectan a todo agente que lea AGENTS.md.

---

## 2. Evaluación detallada por modelo

### 2.1 Glyph Cluster — `reporte_glyph_cluster_event_bus_2026-11-13.md`

**Nicho:** Arquitectura de sistemas Godot, análisis de código GDScript, detección de acoplamiento, contratos de evento.

**Hallazgos (citar archivo:línea del reporte fuente):**

| # | Hallazgo | Archivo:línea (reporte) | Severidad | Accionable |
|---|----------|------------------------|-----------|------------|
| 1 | Doble canal de eventos de inventario: `InventarioService` emite `item_added/item_removed` propias y consumidores escuchan `EventBus.inventory` con firma distinta (con/sin `container`). | §1.1, líneas 19-24 | Alto | Unificar canal y firma; o bridge explícito en `_ready`. |
| 2 | Contrato de viaje desconectado: `TravelService` emite `travel_started(route_id)` pero consumidores esperan `EventBus.travel.travel_started(from_island,to_island)`; `island_loaded` sin productor real. | §1.2, líneas 26-31 | Alto | Alinear firma y definir productor único del bus. |
| 3 | Señales de UI duplicadas: `EventBus.ui` vs `UIManager` (`ui_layers_changed`, `ui_focus_moved`) en dos canales. | §1.3, líneas 33-36 | Alto | Elegir canal único para conceptos equivalentes. |
| 4 | Acoplamiento fuerte a rutas `/root/...` (~71 ocurrencias de `/root/EventBus`) pese a existir `ServiceRegistry` por contratos. | §1.4, líneas 38-41 | Alto | Promover resolución por contratos (`Contratos.*`) sobre `get_node_or_null("/root/...")`. |
| 5 | Señales huérfanas/semihuérfanas: `chunk_modified`, `vessel_arrived`, `player_died/level_up/damage_taken`, `layer_requested/confirm_requested`, `nivel_casa_cambio/nivel_amistad_cambio` sin emisor/consumidor; `quest.quest_updated` se emite pero nadie consume. | §2, tabla líneas 51-69 | Medio | Auditar señales: eliminar/marcar reservadas o conectar consumidor. |
| 6 | `ServiceRegistry.register` no valida contrato vacío ni instancia nula; `unregister` no limpia `_avisados_tempranos`. | §4, líneas 95-110 | Alto | Rechazar contrato vacío/instancia nula; limpiar estado de aviso en `unregister`. |
| 7 | No hay dependencias circulares entre `EventBus` y `ServiceRegistry`. | §3, líneas 77-87 | — | Ruido/positivo (no acción requerida). |

**Evaluación:** Reporte excelente, archivo:línea precisos, distingue producción vs tests, concluye con 2 mejoras concretas y verificables. Glyph Cluster mantiene su nivel. No se detectaron inventos.

**Tareas ya realizadas por Glyph Cluster (no reasignar):** arquitectura EventBus/ServiceRegistry, sistema de guardado, audio, input, inventario, combate/salud, misiones, partículas/VFX, IA/NPC, economía, logros, UI.

### 2.2 ERNIE-5.5-Flash-Preview — `reporte_ernie_documentacion_2026-11-11.md`

**Nicho:** Análisis de documentación con diagramas/capturas, contexto largo (1M), revisión de docs largos.

**Hallazgos (citar archivo:línea del reporte fuente):**

| # | Hallazgo | Archivo:línea (reporte) | Severidad | Accionable |
|---|----------|------------------------|-----------|------------|
| 1 | AGENTS.md §24 describe Unity/C# (Motor: Unity, C#, `Assets/`, `BuildPipeline.BuildPlayer`) cuando el proyecto es Godot 4.x/GDScript en `game/isla-ancestral/project.godot`. | §1.1, líneas 35-51 | ALTA | Reescribir §9, §14, §18, §22, §23, §24 con stack real Godot/GDScript. |
| 2 | Identidad del director contradictoria: `De-Director V4.1` en §10.2/§10.3/§21.8/§30 vs `GLM-5.3 Flash-Director` en §31. | §1.2, líneas 53-61 | ALTA | Unificar identidad en AGENTS.md, GUIA-COMUNICACION.md, DIRECTIVAS-PARA-EL-DIRECTOR.md. |
| 3 | CHECKLIST-GLOBAL: 5 IDs duplicados (48, 115, 127, 139, 148), 173 filas para 168 módulos, resumen desactualizado (167/31/50 vs 173/56/12 reales). | §1.3, líneas 65-72 | ALTA | Sanear tabla, eliminar duplicados, regenerar resumen con `generar_checklist_global.py`. |
| 4 | 11 líneas con mojibake real en CHECKLIST-GLOBAL (incluida leyenda de estados líneas 207, 212, 219), violando AGENTS §28. | §1.5, líneas 97-111 | Alto | Ejecutar `fix_encoding.py` + `diagnosticar_mojibake.py` (debe salir 0). |
| 5 | 12 filas `🔵`/`🔴` stale, M158 con 68 días sin actividad (2026-09-04). | §1.4, líneas 74-95 | Alto | Liberar bloqueos stale con `verificar_checklist.py` (umbral 24h). |
| 6 | AGENTS §3 describe raíz y DOCUMENTACION/ que no coinciden con el estado real (67 archivos raíz, 15 docs generales, 168 carpetas módulo). | §1.6, líneas 113-119 | Medio | Actualizar §3 y tabla de documentos generales. |
| 7 | Guía comparativa: "11 modelos activos" pero hay 14 distintos; Crouton activo/retirado; Beam duplicado; ERNIE gratis/pago. | §1.8-1.11, líneas 128-161 | Medio | Unificar lista de modelos activos y estados. |
| 8 | `scripts/test_scripts.py` da 20 PASS pero AGENTS dice 8 PASS; `cap_godot.py` ruta cambiada; blender MCP no está en kilo.json; §21.23 inexistente. | §1.14-1.18, líneas 170-189 | Bajo/Medio | Corregir cifras y rutas en AGENTS.md. |

**Evaluación:** Reporte de diagnóstico riguroso, método verificado (Test-Path, UTF-8, grep), evita falsos positivos. Las 2 acciones de corrección propuestas son acotadas y verificables. Severidad ALTA justificada: afecta a todo agente nuevo y a la trazabilidad de sellos §21.8.

### 2.3 ERNIE-5.5-Flash-Preview — `reporte_ernie_modelado_3d_2026-11-11.md`

**Nicho:** Análisis de modelos 3D .glb/.gltf, escalas, materiales, LOD, scripts Python para Blender.

**Hallazgos:**

| # | Hallazgo | Archivo:línea (reporte) | Severidad | Accionable |
|---|----------|------------------------|-----------|------------|
| 1 | 487 GLB en `assets/3d/` con **0 texturas de imagen**: todo color base plano + roughness/metallic constantes. | §0.1, tabla líneas 26-34 | Alto | Hornear atlas PBR 1K con ORM empaquetado (Mejora 1). |
| 2 | Prop `cofre_pequeno`: tapa no es pieza separada con pivote de bisagra; Godot no puede animarla sin rehacer el modelo. | §5.2, líneas 178-188 | Alto | Extender GUIA-BLENDER/05 con sub-protocolo "prop interactivo" (Mejora 2). |
| 3 | QA visual E-13 (6 azimuts) depende de inspección de imágenes; este chat no tiene entrada de imágenes. | §7, líneas 225-227 | Medio | QA visual lo hace el usuario o agente con visión. |
| 4 | Librerías y generadores IA 3D OFF (Poly Haven, Sketchfab, Poly Pizza, Tripo, Hunyuan3D, Hyper3D, Meshy). | §0, tabla líneas 19-20 | Medio | No se pueden descargar ni generar modelos por IA hasta activar. |

**Evaluación:** Capacidad verificada en vivo (5 GLB importados y medidos). Mejoras concretas dentro del presupuesto actual. Honesto sobre límites.

### 2.4 ERNIE-5.5-Flash-Preview — `reporte_ernie_casas_2026-11-11.md`

**Nicho:** Análisis de construcciones, casas, ensamblaje de piezas voxel.

**Hallazgos:**

| # | Hallazgo | Archivo:línea (reporte) | Severidad | Accionable |
|---|----------|------------------------|-----------|------------|
| 1 | 6 modelos de casa completa (`casa_choza_ampliada`, `casa_mediana`, `casa_casona`, `casa_mansion`, `casa_vecino`, `casa_completa_ejemplo`) son **huérfanos**: 0 usos en `scripts/**.gd`. | §1.2, líneas 71-94 | Alto | Conectar GLB de casa como decoración de `casa_vecino` en el mundo (Rec. 1). |
| 2 | No existe tipo de casa seleccionable; M18 modela una casa abstracta de 5 etapas sin geometría propia (`house.gd:21-23` solo devuelve entero). | §1.1, líneas 54-71 | Alto | Decidir si casa es geometría (M17) o entidad (M18); implementar tipo de casa. |
| 3 | 36/46 recetas omiten `tamano` (default 1×1); 21/46 omiten `altura` (default 1.0). Puerta de 2 m se apoya en pared de 1 m sin objeción. | §2.2, líneas 163-165 | Alto | Declarar `tamano`/`altura` explícitos en las 46 recetas (Rec. 6). |
| 4 | No hay validación de proporción `tamano` vs `altura` ni comparación AABB de malla vs huella declarada. | §2.2 F1/F2, líneas 159-161 | Alto | Agregar validación de proporción y AABB (Rec. 5). |
| 5 | Esquina y pilar usan malla de pared recta; ensamblaje visualmente roto. | §3.1, líneas 188-199 | Medio | Geometría propia para esquina/pilar (Rec. 4). |
| 6 | Falta zócalo (asset existe sin receta), vanos de puerta/ventana (assets sin receta), techo sin cumbrera/alero, escalera 1 m no comunica plantas. | §3.2-3.5, líneas 201-228 | Medio | Recetas nuevas: zócalo, pared_puerta_vano, pared_ventana_vano, cumbrera, alero, escalera_larga (Rec. 2,3,8). |
| 7 | Dos convenciones de puerta incompatibles: `house.gd:34-35` (−Z×2m) vs `house_manager.gd:196-201` (+Z×3m). | §2.2 F8, línea 180 | Medio | Unificar posición de puerta (Rec. 7). |
| 8 | BUG-135: `house_manager.gd:231-238` llama a `WorldLocations.buscar_cerca()` inexistente → `casa_en_ubicacion_conocida()` devuelve `true` siempre. | §3.8, líneas 242-244 | Alto | Arreglar BUG-135 y revisar aserción del test (Rec. 9). |

**Evaluación:** Análisis estático exhaustivo, 3 subsistemas bien diferenciados, 10 recomendaciones priorizadas con esfuerzo. Dos diseños de casa concretos y viables.

---

## 3. Hallazgos críticos que requieren atención inmediata

| # | Hallazgo | Origen | Severidad | Dueño sugerido |
|---|----------|--------|-----------|----------------|
| C1 | AGENTS.md describe Unity/C# en 6 secciones; el proyecto es Godot 4.x/GDScript. Afecta a todo agente que codifique o compile. | ERNIE documentacion §1.1 | ALTA | Director / Nemotron supervisa |
| C2 | Identidad del director contradictoria (`De-Director V4.1` vs `GLM-5.3 Flash-Director`) en AGENTS.md, GUIA-COMUNICACION.md, DIRECTIVAS-PARA-EL-DIRECTOR.md. Rompe trazabilidad de sellos §21.8 y QA cruzado. | ERNIE documentacion §1.2 | ALTA | Director |
| C3 | CHECKLIST-GLOBAL drift: 5 IDs duplicados, 173 filas/168 módulos, resumen desactualizado, 11 líneas mojibake, 12 bloqueos stale (M158: 68 días). | ERNIE documentacion §1.3-1.5 | Alto | Director |
| C4 | `ServiceRegistry.register` sin validación de contrato vacío/instancia nula; `unregister` no limpia `_avisados_tempranos`. | Glyph Cluster event_bus §4 | Alto | Glyph Cluster |
| C5 | Canales paralelos y firmas desalineadas en EventBus (inventario, viaje, UI). | Glyph Cluster event_bus §1-2 | Alto | Glyph Cluster |
| C6 | 6 modelos de casa completa huérfanos; casa no es ni geometría ni entidad completa. | ERNIE casas §1-3 | Alto | ERNIE (3D) / Glyph Cluster (arquitectura) |
| C7 | BUG-135: `buscar_cerca()` inexistente hace `casa_en_ubicacion_conocida()` devolver `true` siempre. | ERNIE casas §3.8 | Alto | ERNIE / Glyph Cluster |

---

## 4. Recomendaciones de implementación (por Nemotron)

**Fase 1 (inmediata):**
- Corregir `ServiceRegistry.register/unregister` (validación de entrada + limpieza de `_avisados_tempranos`) — `scripts/core/service_registry.gd:22-28,45-46`
- Consolidar contratos de EventBus: un solo canal por dominio, firmas alineadas, productor único — `scripts/core/event_bus.gd`
- Arreglar BUG-135 (`buscar_cerca` inexistente) — `scripts/houses/house_manager.gd:231-238`

**Fase 2 (próxima iteración):**
- SANEAR CHECKLIST-GLOBAL: eliminar mojibake, resolver 5 IDs duplicados, liberar 12 bloqueos stale, regenerar resumen
- Unificar identidad del director en AGENTS.md, GUIA-COMUNICACION.md, DIRECTIVAS-PARA-EL-DIRECTOR.md
- Reescribir AGENTS.md §9, §14, §18, §22, §23, §24 con stack Godot/GDScript real
- Conectar 6 GLB de casa completa o declararlos como decoración de `casa_vecino`

**Fase 3 (cleanup):**
- Auditar señales huérfanas de EventBus (`chunk_modified`, `vessel_arrived`, `player_died`, etc.)
- Hornear atlas PBR 1K con ORM para los 487 GLB sin texturas
- Extender GUIA-BLENDER/05 con sub-protocolo "prop interactivo" (pivote, colisión, emisivo)

---

## 5. Decisión requerida del director (agnes-3-flash)

Nemotron recomienda lo siguiente, pero **el director es el último en verificar que esto está correcto y evalúa si se implementa finalmente:**

```
[ ] Implementar fase 1 (críticos: ServiceRegistry validación, contratos EventBus, BUG-135) — responsable: Nemotron supervisa, Glyph Cluster ejecuta
[ ] Implementar fase 2 (saneamiento CHECKLIST-GLOBAL, identidad director, stack Godot en AGENTS.md, conectar GLB de casa) — responsable: director / Nemotron supervisa
[ ] Implementar fase 3 (auditoría señales huérfanas, atlas PBR 1K, sub-protocolo prop interactivo) — responsable: Nemotron supervisa, ERNIE-5.5-Flash-Preview ejecuta parte 3D
[ ] Asignar nueva tarea a Glyph Cluster: analizar contratos paralelos ISaveProvider/ISaveable del sistema de guardado (nicho: arquitectura) — responsable: Nemotron asigna
[ ] Asignar nueva tarea a ERNIE-5.5-Flash-Preview: análisis visual de escenas .tscn con imágenes/texturas (calidad visual, resoluciones inconsistentes) o QA visual E-13 de los 6 GLB de casa huérfanos — responsable: Nemotron asigna
[ ] Añadir un segundo modelo en paralelo a Glyph Cluster (pendiente de conversación con el director; el usuario indicó que hay que hablarlo antes de crear el cronómetro) — responsable: director decide
[ ] Liberar los 12 bloqueos 🔵 stale en CHECKLIST-GLOBAL.md (M158 con 68 días, M139, M41, M45, M49, M159, M161, M23, M17, M20, M33, M59) — responsable: director
[ ] Regenerar CHECKLIST-GLOBAL.md con `scripts/generar_checklist_global.py` tras saneamiento — responsable: director o Nemotron
[ ] Descartar como ruido: fixtures de test intencionales, capturas .webp sin .import, addon gdUnit4 — responsable: Nemotron (documentado en rounds previos)
```

---

## 6. Nuevas tareas asignadas (sesiones Agent Manager idle)

Se detectaron 3 sesiones Agent Manager idle (`ses_e2d5d4e33ffe9FPJB5Yy6dFGeo`, `ses_e2d5d3ab2ffe2EPlen1BFw6Hm0`, `ses_e29cb41d2ffed2w5L3nHUoD0Lr`). Al recibir confirmación del director en la sección 5, se asignará:

**A Glyph Cluster (arquitectura/código):** análisis de los contratos paralelos `ISaveProvider`/`ISaveable` del sistema de guardado y unificación de los canales dobles de inventario identificados en este reporte (`event_bus.gd:66-72` vs `inventario_service.gd:16-17,53,65,361`). Entregable: reporte en `Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/` con archivo:línea y 2 mejoras concretas.

**A ERNIE-5.5-Flash-Preview (multimodal/3D):** análisis visual de los 6 GLB de casa completa huérfanos (`assets/3d/{alta,media,baja}/18-Casas_casa_*.glb`) y verificación de escala/pivote contra `escalas.json`; o bien análisis de escenas `.tscn` con texturas (resoluciones inconsistentes). Entregable: reporte en `Mensajes entre modelos/ERNIE-5.5-Flash-Preview/REPORTES-Prueba-Paralela/`.

**Regla aplicada:** no se asigna tarea ya completada por ese modelo; Glyph Cluster ya cubrió guardado, audio, input, inventario, combate, misiones, VFX, IA/NPC, economía, logros, UI y ahora EventBus. ERNIE ya cubrió modelado 3D, documentación y casas.

---

## 7. Punto de control para próxima evaluación

Este informe constituye el punto de control del round 7. En la próxima evaluación, Nemotron no leerá los reportes de este round. Se basará en:
- Este archivo de evaluación consolidada.
- Los informes fuente en `Mensajes entre modelos/<MODELO>/REPORTES-Prueba-Paralela/` con fecha posterior a este round.
- El archivo de metodología en `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`.

Si el director aprueba alguna implementación de la sección 5, Nemotron la asignará a los modelos disponibles y supervisará su ejecución, reportando el cierre al director.

---

**Firma:** Nemotron-3.5-Super-VL / Kilo Code — 2026-11-13 18:49  
**Última verificación del director:** pendiente
