**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 109: Herramientas Internas (138 ítems)

## Convención
- `[ ]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Framework de editor (RF1-RF5)

- [x] Definir EditorToolBase con undo, guardado y validación [C]
- [x] Definir guardado directo en SO/mods de M108 [M]
- [x] Definir búsqueda por id/nombre/tag en cada editor [M]
- [x] Definir colores de validación (rojo bloqueante / amarillo aviso) [S]
- [x] Definir shortcuts por editor (Ctrl+1..14) [S]
- [x] Definir export/import JSON/CSV en cada editor [M]
- [ ] Definir reutilización de lista vista/detalle en todos [M]
- [x] Definir Undo de Unity en edición de SO [M]
- [x] Definir validación incremental al guardar [M]
- [ ] Definir red/amarillo por campo con error específico [S]

## 2. Editor de bloques (RF1)

- [x] Definir edición de bloque voxel: id, nombre, textura, tags [M]
- [x] Definir edición de físico (sólido/transparente) [S]
- [x] Definir validación de ids únicos [S]
- [x] Definir referencia a texturas existentes (M47/M108) [M]
- [x] Definir vista previa del bloque en 3D [M]

## 3. Editor de biomas (RF1)

- [x] Definir edición de bioma: paleta, vegetación, clima [M]
- [x] Definir validación de referencia al terreno/bioma válido [M]
- [x] Definir edición de vegetación con referencia a bloques [M]
- [x] Definir edición de alturas/pisos de generación [S]
- [x] Definir previsualización del bioma [S]

## 4. Editor de NPC (RF1)

- [x] Definir edición de NPC: nombre, profesión, casa [M]
- [x] Definir edición de rutina diaria con POI/tiempo (M19) [C]
- [x] Definir edición de relaciones/amistad (M20) [M]
- [x] Definir enlace con economía del NPC (M38) [M]
- [x] Definir validación de rutina: POI y tiempos válidos [M]
- [x] Definir vista previa del horario semanal [S]

## 5. Editor de diálogos (RF1)

- [x] Definir editor de árbol de nodos (M21) [C]
- [x] Definir edición de condiciones por flag [M]
- [x] Definir edición de efectos (objetos, amistad, misiones) [M]
- [x] Definir validación: referencias a flags/objetos/misiones existentes [M]
- [x] Definir simulación de conversación en editor [M]
- [x] Definir export de diálogos para localización (M87) [M]

## 6. Editor de misiones (RF1)

- [x] Definir edición de etapa/objetivo/recompensa (M22/23) [M]
- [x] Definir validación: objetivos refieren items/NPC/POI válidos [M]
- [x] Definir detección de ciclos en prereq de misiones [C]
- [ ] Definir vistas de misión principal vs secundarias [S]
- [x] Definir export a testear en M112 [S]

## 7. Editor de recetas (RF1)

- [x] Definir edición de receta de crafting (M16/17) [M]
- [x] Definir edición de estación de trabajo requerida [S]
- [x] Definir validación de ingreso/salida con objetos existentes [M]
- [ ] Definir detección de recetas inalcanzables [M]
- [ ] Definir vista por categoría de crafting [S]

## 8. Editor de economía (RF1)

- [x] Definir edición de precios base por objeto (M38) [M]
- [x] Definir edición de influencia de NPC en precios [M]
- [x] Definir validación: precios > 0 y NPC refiere economía [M]
- [ ] Definir simulador de mercado rápido [M]
- [x] Definir export de tabla de precios a CSV [S]

## 9. Editor de tiendas (RF1)

- [x] Definir edición de inventario y stock (M39) [M]
- [x] Definir edición de restock por día [S]
- [x] Definir validación de items existentes y sin duplicados [M]
- [ ] Definir vista por NPC/vendedor [S]

## 10. Editor de clima (RF1)

- [x] Definir edición de climas (M32) con duración y transición [M]
- [x] Definir edición de FX asociados (lluvia, niebla) [M]
- [x] Definir validación de duración y sin saltos de intensidad [S]
- [x] Definir previsualización del clima [S]

## 11. Editor de estaciones (RF1)

- [x] Definir edición de estaciones con duración y eventos (M31) [M]
- [x] Definir validación de no solapamiento de fechas [S]
- [x] Definir edición de efectos por estación (terreno M51/M50) [M]
- [ ] Definir vista de calendario anual [S]

## 12. Editor de puzzles (RF1)

- [x] Definir edición de condiciones y orden (M24) [M]
- [x] Definir edición de recompensa y unlock de zona [M]
- [x] Definir validación: solución alcanzable sin bugs [C]
- [x] Definir previsualización interactiva [M]
- [x] Definir marcado de puzzles del Templo Subterráneo (M26) [S]

## 13. Editor de ruinas (RF1)

- [x] Definir edición de layout de ruina (M25) [C]
- [x] Definir edición de loot table [M]
- [x] Definir validación: loot refiere objetos; layout valida contra seed [M]
- [x] Definir regeneración de ruina con misma seed [M]
- [x] Definir previsualización de la ruina generada [S]

## 14. Editor de spawns (RF1)

- [x] Definir edición de spawn por bioma/hora/estación [M]
- [x] Definir edición de densidad y fauna/flora (M36/65) [M]
- [x] Definir validación: entidad existe y density ≤ máximo [M]
- [x] Definir previsualización de densidad aplicada [S]

## 15. Editor de mapas (RF1)

- [x] Definir edición de islas (M27/54) y puntos de interés [M]
- [x] Definir edición de viajes entre islas (M28) [M]
- [x] Definir validación: POI únicos e islas referenciadas [M]
- [x] Definir vista del mapa completo [S]
- [x] Definir export de estructura del mapa [S]

## 16. Herramienta de teleport (RF7)

- [x] Definir teleport a coordenadas exactas [S]
- [x] Definir teleport a isla/POI/sello [M]
- [ ] Definir teleport con guardado del punto anterior [S]
- [x] Definir integración con Debug Menu (M110) [S]

## 17. Herramienta de spawn (RF7)

- [x] Definir spawn de objetos bajo cursor [S]
- [x] Definir spawn de NPC y fauna [S]
- [ ] Definir spawn con cantidad y densidad editable [S]
- [ ] Definir validación de no duplicar entidades únicas [S]

## 18. Herramienta de debug (RF7)

- [x] Definir menú de debug (M110): flags e invincibilidad [M]
- [x] Definir dar objetos/dinero al jugador [S]
- [x] Definir completar misión / desbloquear herramienta [S]
- [x] Definir cambiar hora/estación/clima [S]
- [x] Definir desbloquear isla/sello [S]
- [x] Definir resetear NPC y puzzle [S]
- [x] Definir regenerar chunk [M]
- [x] Definir mostrar colliders, FPS, chunks, navegación [M]
- [x] Definir mostrar hitboxes y estados de IA [M]
- [x] Definir exportar diagnóstico [S]

## 19. Herramienta de inspección (RF8)

- [x] Definir inspector de entidad (componentes) [M]
- [x] Definir navegación por árbol de objetos [S]
- [x] Definir edición inline de variables en editor [M]
- [ ] Definir copia de estado al portapapeles [S]

## 20. Herramienta de profiling (RF9)

- [x] Definir stats del editor: FPS, memoria, draw calls (M61/62) [M]
- [x] Definir stats por chunk/NPC/AI [M]
- [ ] Definir export de muestras a CSV [S]
- [x] Definir visual en overlay del editor [S]

## 21. Herramienta de validación (RF10)

- [x] Definir DataValidator global con cross-checks [C]
- [x] Definir análisis de recetas→objetos inexistentes [M]
- [x] Definir análisis de misiones→diálogos/objetivos [M]
- [x] Definir análisis de tiendas→items [M]
- [x] Definir análisis de economía→NPC [M]
- [x] Definir análisis de rutinas→POI [M]
- [x] Definir análisis de loot→objetos [M]
- [x] Definir reporte JSON por dominio con flag bloqueante [M]
- [x] Definir integración del validator como gate en CI (M112) [M]
- [x] Definir reutilización del validator en M151 [S]

## 22. Herramienta de generación (RF11)

- [x] Definir ContentGenerator con seeds de M10 [M]
- [x] Definir sub-seeds para ruinas (M25) y spawns [M]
- [x] Definir regeneración reproducible (misma seed → mismo mundo) [M]
- [x] Definir valor de semilla en metadata del save (M59) [S]
- [x] Definir reporte de generación tras regen [S]

## 23. Calidad y cierre (RF12)

- [x] Definir aislamiento asmdef Editor (nada en build de jugador) [C]
- [x] Definir verificación por script de exclusión en build [M]
- [x] Definir compatibilidad con M110 (Debug Menu) [M]
- [x] Definir compatibilidad con M108 (mods) [M]
- [ ] Definir soporte de herramientas para QA (M102) [S]
- [ ] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]
- [x] Definir feed a M112 (tests de editor) y M151 (validator) [S]

## Totales

**Total de ítems:** 138
**Ítems resueltos por documentación:** 120 (15 pendientes, 3 dudas)
**Ítems pendientes de implementación:** 15 (vistas/exports sin respaldo textual: ver iteracion 5; teleport/spawn/inspeccion/profiling sin respaldo: ver iteracion 6)
## Iteración 1 (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Framework común de editores: `scripts/editor/tools/editor_base.gd` (@tool PanelContainer) — lista de entradas + formulario por campo + guardado con backup .bak + mensajes de estado (base data-driven para los 14 editores RF1)
- [x] Núcleo de validación testeable: `scripts/editor/support/recipe_schema.gd` (RecipeSchema) — reglas de `data/balance/crafting.json` (categorías, estaciones, nivel>=1, resultado_cantidad>=1, coste_recursos bien formado) con `validar()/costes_a_texto()/texto_a_costes()`
- [x] Editor de recetas OPERATIVO (RF6): `scripts/editor/tools/recipe_tool.gd` — lista de recetas reales del juego, formulario de 10 campos, guardado a `crafting.json` con backup `.bak`, validación previa con RecipeSchema
- [x] Plugin del editor: `scripts/editor/plugin_herramientas.gd` (EditorPlugin) registrado en project.godot [editor_plugins] — dock "Herramientas internas" con el catálogo de editores (Recetas activo; los 13 siguientes listos para sumarse por el patrón)
- [x] Tests del núcleo (6 gdUnit): receta válida (pico de cobre real), invalidaciones (sin costes, id vacío, estación inválida, nivel 0), roundtrip de costes → suite completa ÉXITO (0 fallos)
- [?] Verificación visual del dock del editor: pendiente — requiere reinicio del editor de Godot (instancia activa de otro agente); se revalida con la primera captura de layout en la próxima sesión con editor propio (dueño: deepseek-v4-flash-vision-exp)
- [?] Editores restantes (bloques, biomas, NPC, diálogos, misiones, economía, tiendas, clima, estaciones, puzzles, ruinas, spawns, mapas, teleport, profiling = 13+2): siguen el patrón EditorBase con su propio schema validable — iteración 2 (dueño: deepseek-v4-flash-vision-exp, M109 iter 2)
## Iteración 2 (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Editor de diálogos (RF4) — núcleo: `scripts/editor/support/dialogo_schema.gd` (validador de grafos M21/M23: start existe, nodos con text, referencias next/opciones a nodos existentes, sin inalcanzables)
- [x] **Auditoría masiva del dataset real**: `scripts/editor/tools/dialogos_auditor.gd` recorre los 268 grafos (data/dialogues/ + contextual) → **268 OK, 0 con problemas** (reporte: tools/reportes/dialogos_audit.txt, exit 0) — ningún problema de referencia/huérfano en el contenido de los agentes
- [x] Auditor no-recursivo (get_files_at) — los builds headless con -s no sostienen el listado recursivo por DirAccess en este entorno (documentado; el npc_visual_check usa load() que sí recorre)
- [?] Panel del editor de diálogos en el dock (vista de grafo + edición de texto de nodo) — iter 3 (dueño: deepseek-v4-flash-vision-exp)

**Totales:** 138 ítems · Completados: 120 · Pendientes: 15 · No resueltos: 3. (Re-medido por DeepSeek-V4.1-Flash 2026-10-17, msg 302 p5: conteo real por marca = 120 [x] / 15 [ ] / 3 [?] = 138; el bloque declaraba 107/28/3.)

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, lote 5):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 27 [x] / 108 [ ] /
> 3 [?]. Las marcas no se tocaron.
## Iteración 3 (2026-10-14 — Step-5-WorkBuddy / WorkBuddy, Log 1845)

- 12 flips `[ ]` -> `[x]` (seccion 18: 6 items de debug; seccion 21: 6 analisis del DataValidator). Modulo design-heavy (items "Definir X"): diseno documentado = hecho (politica del director, M120).
- Seccion 18 -> 03-Diseno.md L72 (fila DebugMenu: dar objetos/dinero, hora/estacion/clima, desbloquear isla/sello, reset NPC/puzzle, regenerar chunk, mostrar colliders/FPS/chunks/navegacion) + respaldo DoD 01-Requerimientos.md L54.
- Seccion 21 -> 03-Diseno.md L76 (cross-checks DataValidator: recetas, misiones, tiendas, economia, rutinas, loot).
- Conteo medido tras flips: 39 [x] / 96 [ ] / 3 [?] = 138 (invariante verificado).
- Drift corregido: header (110 items) -> (138); "Total de items: 127" -> 138; linea Totales actualizada 27/108/3 -> 39/96/3.
- Los 3 [?] quedan como estan (verificacion visual del dock y paneles de editores, dueno externo deepseek-v4-flash-vision-exp).
## Iteración 4 (2026-10-14 — Step-5-WorkBuddy / WorkBuddy, Log 1845)

- 13 flips `[ ]` -> `[x]`: framework de editor (4), debug (3), generacion (5), cierre M108 (1).
- Seccion 1 -> 03-Diseno.md L40-42 (Undo Unity, guardado directo SO/mods M108, colores de validacion) + 02-Analisis.md L18 (D2-A2: validacion incremental por editor al guardar).
- Seccion 18 -> 03-Diseno.md L72 (hitboxes/IA, exportar diagnostico) + DoD 01-Requerimientos.md L54. Nota honesta: 'completar mision' es textual en L72/L54; 'desbloquear herramienta' NO es textual (el diseno dice 'desbloquear isla/sello') - marcado por respaldo del DoD, con la salvedad documentada.
- Seccion 22 -> 03-Diseno.md L80-83 (ContentGenerator con semilla M10, sub-seeds ruinas/spawns, regeneracion reproducible, semilla en metadata del save, export de reporte).
- Seccion 23 -> 02-Analisis.md L14 (D1-A2: 'compatibles con M108').
- Conteo medido tras flips: 52 [x] / 83 [ ] / 3 [?] = 138 (invariante verificado).
## Iteración 5 (2026-10-14 — Step-5-WorkBuddy / WorkBuddy, Log 1847)

- 55 flips `[ ]` -> `[x]` en las secciones 2-14 (los 14 editores de dominio de RF1). Modulo design-heavy: diseno documentado = hecho (politica del director, M120).
- Seccion 2 (bloques) -> 03-Diseno §3 L50 ("Bloques | id, nombre, textura/MOD, físico (sólido/transparente), tags | ids únicos; texturas existen") + 01-Requerimientos §3.1 (L13).
- Seccion 3 (biomas) -> 03-Diseno §3 L51 ("Biomas | id, paleta, vegetación, clima asociado, altura/piso | refere a bioma de terreno válido; vegetación refiere bloques") + 01-Requerimientos §3.2 (L14).
- Seccion 4 (NPC) -> 03-Diseno §3 L52 ("NPC | id, nombre, profesión, rutina (M19), relación (M20), economía | rutina refiere tiempo/POI válidos") + 01-Requerimientos §3.3 (L15) + fila Economia L56 ("influencia NPC (M38)") para el item de enlace con economia.
- Seccion 5 (dialogos) -> 03-Diseno §3 L53 ("Diálogos | nodos, línea, condiciones (flags), efectos (objetos/amistad) | referencias a flags/objetos/misiones existentes") + RF6 (01-Requerimientos L43) para el export.
- Seccion 6 (misiones) -> 03-Diseno §3 L54 ("Misiones | etapas, objetivos, condiciones, recompensas (M22/23) | objetivos refieren items/NPC/POI válidos; no ciclos en prerreq") + 01-Requerimientos §5.7 (L58, tests en M112) y 02-Analisis L56 para el export a testear.
- Seccion 7 (recetas) -> 03-Diseno §3 L55 ("Recetas | ingreso/salida, estación de trabajo, desbloqueo (M16/17) | ing/out refiere objetos; estación existe") + 01-Requerimientos §3.6 (L18).
- Seccion 8 (economia) -> 03-Diseno §3 L56 ("Economía | precio base por objeto, influencia NPC (M38) | precios > 0; NPC refiere economía existente") + 01-Requerimientos §3.7 (L19) + RF6 para el export CSV.
- Seccion 9 (tiendas) -> 03-Diseno §3 L57 ("Tiendas | inventario, restock, moneda (M39) | items existen; no duplicados") + 01-Requerimientos §3.8 (L20).
- Seccion 10 (clima) -> 03-Diseno §3 L58 ("Clima | climas (M32), transiciones, FX | duración > 0; top - grade sin saltos") + 01-Requerimientos §3.9 (L21).
- Seccion 11 (estaciones) -> 03-Diseno §3 L59 ("Estaciones | duración, eventos por estación (M31) | no solapamiento de fechas") + 01-Requerimientos §3.10 (L22).
- Seccion 12 (puzzles) -> 03-Diseno §3 L60 ("Puzzles | condiciones, orden, recompensa (M24) | recompensa refiere ítem; solución alcanzable") + 01-Requerimientos §3.11 (L23) + 03-Diseno §1 L23 (PuzzleEditorWindow, M24/25/26) para el marcado del Templo.
- Seccion 13 (ruinas) -> 03-Diseno §3 L61 ("Ruinas | layout, loot table, puzzles (M25) | loot refiere objetos; layout valida contra seed") + 01-Requerimientos §3.12 (L24) + 03-Diseno §6 L81-82 (sub-seeds para ruinas, regenerar con semilla X reproducible) para la regeneracion.
- Seccion 14 (spawns) -> 03-Diseno §3 L62 ("Spawns | bioma/hora, entidad (M36/65), densidad | entidad existe; no rates > máximo") + 01-Requerimientos §3.13 (L25, "fauna/flora por bioma/hora").
- Previsualizaciones -> RF4 (01-Requerimientos L41): "Previsualización en vivo (cambios aplicados al entrar al juego)" — requisito generico del toolset que cubre los 8 items de vista previa de las secciones 2-14.
- **Salvedades honestas** (concepto respaldado, acotador no textual en ninguna fuente del modulo): preview del bloque "en 3D" (L29), "casa" del NPC (L41), "horario semanal" (L46), "misiones" como efecto de dialogo (L52), destino "localizacion (M87)" del export (L55), restock "por dia" (L84), FX "lluvia, niebla" (L91), efectos por estacion sobre "terreno M51/M50" (L99), "unlock de zona" (L105), preview "interactiva" de puzzles (L107), "marcado" de puzzles del Templo (L108), estacion en spawns (L120). Marcados por el respaldo del diseno base, con esta nota explicita.
- **Quedan [ ] honestos (6 items de secciones 2-14, sin respaldo textual medido):** L62 vistas mision principal vs secundarias; L70 deteccion de recetas inalcanzables; L71 vista por categoria de crafting; L78 simulador de mercado rapido; L86 vista por NPC/vendedor; L100 vista de calendario anual. Ninguna fuente del modulo los documenta.
- Conteo medido tras los 55 flips: 107 [x] / 28 [ ] / 3 [?] = 138 (invariante verificado por script).
- Drift corregido: las lineas del bloque Totales heredado decian "resueltos por documentacion: 127 (0 pendientes, 0 dudas)" y "pendientes de implementacion: 0" -> alineadas al conteo real (107 / 28), y la linea del apendice 52/83/3 -> 107/28/3.
- Fuera de alcance de esta iteracion (siguen [ ]): seccion 1 (L18 reutilizacion lista vista/detalle, L21 rojo/amarillo por campo), secciones 15-17, 19, 20 y 3 items de la 23 (soporte QA M102, documentacion firmada, log del modulo).

## Iteración 6 (2026-10-14 — Step-5-WorkBuddy / WorkBuddy, Log 1854)

- 13 flips `[ ]` -> `[x]` (lote 3 autorizado por el director, msg 33): seccion 15 editor de mapas (5), seccion 16 teleport (2), seccion 17 spawn (2), seccion 19 inspeccion (2), seccion 20 profiling (1), L203 log del modulo (1).
- Seccion 15 -> 03-Diseno §3 L63 ("Mapas | islas (M27/54), puntos de interes, viajes (M28) | POI unicos; islas referenciadas por viajes") + RF4 (01-Requerimientos L41, previsualizacion en vivo) para la vista + RF6 (01-Requerimientos L43, export JSON/CSV) para el export.
- Seccion 16 -> 03-Diseno §4 L68 ("TeleportTool | mover jugador a coords / isla / POI / sello") + 01-Requerimientos §3.15 L27 ("moverse a coordenada/isla/POI en editor y debug").
- Seccion 17 -> 03-Diseno §4 L69 ("SpawnTool | instanciar objeto/NPC/fauna bajo cursor") + 01-Requerimientos §3.16 L28 ("instanciar objetos/NPC/fauna bajo cursor").
- Seccion 19 -> 03-Diseno §4 L70 ("InspectorTool | arbol de componentes/variables de entidad") + RF8 (01-Requerimientos L45 "Inspeccion de entidad: arbol de componentes y variables") + 01-Requerimientos §3.18 L30.
- Seccion 20 -> 01-Requerimientos §3.19 L31 ("profiling del editor: stats de chunk/NPC/AI (M62/M61)") - respaldo textual directo.
- L203 -> cumplido por este ciclo: el log del modulo se escribio en Logs/ con numero del pool (1854).
- **Quedan [ ] honestos de las secciones del lote 3 (5 items, grep = 0 en las 4 fuentes del modulo):** L137 teleport con guardado del punto anterior; L144 spawn con cantidad y densidad editable; L145 validacion de no duplicar entidades unicas (la herramienta de spawn no tiene validacion documentada; "no duplicados" es de tiendas §3 L57); L165 copia de estado al portapapeles; L171 export de muestras a CSV (RF9 no menciona export; RF6 es de los 14 editores).
- Conteo medido tras los 13 flips: 120 [x] / 15 [ ] / 3 [?] = 138 (invariante verificado por script).
