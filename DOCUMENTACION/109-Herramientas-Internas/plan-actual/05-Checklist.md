**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 109: Herramientas Internas (110 ítems)

## Convención
- `[x]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Framework de editor (RF1-RF5)

- [x] Definir EditorToolBase con undo, guardado y validación [C]
- [x] Definir guardado directo en SO/mods de M108 [M]
- [x] Definir búsqueda por id/nombre/tag en cada editor [M]
- [x] Definir colores de validación (rojo bloqueante / amarillo aviso) [S]
- [x] Definir shortcuts por editor (Ctrl+1..14) [S]
- [x] Definir export/import JSON/CSV en cada editor [M]
- [x] Definir reutilización de lista vista/detalle en todos [M]
- [x] Definir Undo de Unity en edición de SO [M]
- [x] Definir validación incremental al guardar [M]
- [x] Definir red/amarillo por campo con error específico [S]

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
- [x] Definir vistas de misión principal vs secundarias [S]
- [x] Definir export a testear en M112 [S]

## 7. Editor de recetas (RF1)

- [x] Definir edición de receta de crafting (M16/17) [M]
- [x] Definir edición de estación de trabajo requerida [S]
- [x] Definir validación de ingreso/salida con objetos existentes [M]
- [x] Definir detección de recetas inalcanzables [M]
- [x] Definir vista por categoría de crafting [S]

## 8. Editor de economía (RF1)

- [x] Definir edición de precios base por objeto (M38) [M]
- [x] Definir edición de influencia de NPC en precios [M]
- [x] Definir validación: precios > 0 y NPC refiere economía [M]
- [x] Definir simulador de mercado rápido [M]
- [x] Definir export de tabla de precios a CSV [S]

## 9. Editor de tiendas (RF1)

- [x] Definir edición de inventario y stock (M39) [M]
- [x] Definir edición de restock por día [S]
- [x] Definir validación de items existentes y sin duplicados [M]
- [x] Definir vista por NPC/vendedor [S]

## 10. Editor de clima (RF1)

- [x] Definir edición de climas (M32) con duración y transición [M]
- [x] Definir edición de FX asociados (lluvia, niebla) [M]
- [x] Definir validación de duración y sin saltos de intensidad [S]
- [x] Definir previsualización del clima [S]

## 11. Editor de estaciones (RF1)

- [x] Definir edición de estaciones con duración y eventos (M31) [M]
- [x] Definir validación de no solapamiento de fechas [S]
- [x] Definir edición de efectos por estación (terreno M51/M50) [M]
- [x] Definir vista de calendario anual [S]

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
- [x] Definir teleport con guardado del punto anterior [S]
- [x] Definir integración con Debug Menu (M110) [S]

## 17. Herramienta de spawn (RF7)

- [x] Definir spawn de objetos bajo cursor [S]
- [x] Definir spawn de NPC y fauna [S]
- [x] Definir spawn con cantidad y densidad editable [S]
- [x] Definir validación de no duplicar entidades únicas [S]

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
- [x] Definir copia de estado al portapapeles [S]

## 20. Herramienta de profiling (RF9)

- [x] Definir stats del editor: FPS, memoria, draw calls (M61/62) [M]
- [x] Definir stats por chunk/NPC/AI [M]
- [x] Definir export de muestras a CSV [S]
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
- [x] Definir soporte de herramientas para QA (M102) [S]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]
- [x] Definir feed a M112 (tests de editor) y M151 (validator) [S]

## Totales

**Total de ítems:** 127
**Ítems resueltos por documentación:** 127 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)