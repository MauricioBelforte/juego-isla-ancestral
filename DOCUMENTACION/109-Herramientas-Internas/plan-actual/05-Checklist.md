**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 109: Herramientas Internas (110 ítems)

## Convención
- `[ ]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Framework de editor (RF1-RF5)

- [ ] Definir EditorToolBase con undo, guardado y validación [C]
- [ ] Definir guardado directo en SO/mods de M108 [M]
- [ ] Definir búsqueda por id/nombre/tag en cada editor [M]
- [ ] Definir colores de validación (rojo bloqueante / amarillo aviso) [S]
- [ ] Definir shortcuts por editor (Ctrl+1..14) [S]
- [ ] Definir export/import JSON/CSV en cada editor [M]
- [ ] Definir reutilización de lista vista/detalle en todos [M]
- [ ] Definir Undo de Unity en edición de SO [M]
- [ ] Definir validación incremental al guardar [M]
- [ ] Definir red/amarillo por campo con error específico [S]

## 2. Editor de bloques (RF1)

- [ ] Definir edición de bloque voxel: id, nombre, textura, tags [M]
- [ ] Definir edición de físico (sólido/transparente) [S]
- [ ] Definir validación de ids únicos [S]
- [ ] Definir referencia a texturas existentes (M47/M108) [M]
- [ ] Definir vista previa del bloque en 3D [M]

## 3. Editor de biomas (RF1)

- [ ] Definir edición de bioma: paleta, vegetación, clima [M]
- [ ] Definir validación de referencia al terreno/bioma válido [M]
- [ ] Definir edición de vegetación con referencia a bloques [M]
- [ ] Definir edición de alturas/pisos de generación [S]
- [ ] Definir previsualización del bioma [S]

## 4. Editor de NPC (RF1)

- [ ] Definir edición de NPC: nombre, profesión, casa [M]
- [ ] Definir edición de rutina diaria con POI/tiempo (M19) [C]
- [ ] Definir edición de relaciones/amistad (M20) [M]
- [ ] Definir enlace con economía del NPC (M38) [M]
- [ ] Definir validación de rutina: POI y tiempos válidos [M]
- [ ] Definir vista previa del horario semanal [S]

## 5. Editor de diálogos (RF1)

- [ ] Definir editor de árbol de nodos (M21) [C]
- [ ] Definir edición de condiciones por flag [M]
- [ ] Definir edición de efectos (objetos, amistad, misiones) [M]
- [ ] Definir validación: referencias a flags/objetos/misiones existentes [M]
- [ ] Definir simulación de conversación en editor [M]
- [ ] Definir export de diálogos para localización (M87) [M]

## 6. Editor de misiones (RF1)

- [ ] Definir edición de etapa/objetivo/recompensa (M22/23) [M]
- [ ] Definir validación: objetivos refieren items/NPC/POI válidos [M]
- [ ] Definir detección de ciclos en prereq de misiones [C]
- [ ] Definir vistas de misión principal vs secundarias [S]
- [ ] Definir export a testear en M112 [S]

## 7. Editor de recetas (RF1)

- [ ] Definir edición de receta de crafting (M16/17) [M]
- [ ] Definir edición de estación de trabajo requerida [S]
- [ ] Definir validación de ingreso/salida con objetos existentes [M]
- [ ] Definir detección de recetas inalcanzables [M]
- [ ] Definir vista por categoría de crafting [S]

## 8. Editor de economía (RF1)

- [ ] Definir edición de precios base por objeto (M38) [M]
- [ ] Definir edición de influencia de NPC en precios [M]
- [ ] Definir validación: precios > 0 y NPC refiere economía [M]
- [ ] Definir simulador de mercado rápido [M]
- [ ] Definir export de tabla de precios a CSV [S]

## 9. Editor de tiendas (RF1)

- [ ] Definir edición de inventario y stock (M39) [M]
- [ ] Definir edición de restock por día [S]
- [ ] Definir validación de items existentes y sin duplicados [M]
- [ ] Definir vista por NPC/vendedor [S]

## 10. Editor de clima (RF1)

- [ ] Definir edición de climas (M32) con duración y transición [M]
- [ ] Definir edición de FX asociados (lluvia, niebla) [M]
- [ ] Definir validación de duración y sin saltos de intensidad [S]
- [ ] Definir previsualización del clima [S]

## 11. Editor de estaciones (RF1)

- [ ] Definir edición de estaciones con duración y eventos (M31) [M]
- [ ] Definir validación de no solapamiento de fechas [S]
- [ ] Definir edición de efectos por estación (terreno M51/M50) [M]
- [ ] Definir vista de calendario anual [S]

## 12. Editor de puzzles (RF1)

- [ ] Definir edición de condiciones y orden (M24) [M]
- [ ] Definir edición de recompensa y unlock de zona [M]
- [ ] Definir validación: solución alcanzable sin bugs [C]
- [ ] Definir previsualización interactiva [M]
- [ ] Definir marcado de puzzles del Templo Subterráneo (M26) [S]

## 13. Editor de ruinas (RF1)

- [ ] Definir edición de layout de ruina (M25) [C]
- [ ] Definir edición de loot table [M]
- [ ] Definir validación: loot refiere objetos; layout valida contra seed [M]
- [ ] Definir regeneración de ruina con misma seed [M]
- [ ] Definir previsualización de la ruina generada [S]

## 14. Editor de spawns (RF1)

- [ ] Definir edición de spawn por bioma/hora/estación [M]
- [ ] Definir edición de densidad y fauna/flora (M36/65) [M]
- [ ] Definir validación: entidad existe y density ≤ máximo [M]
- [ ] Definir previsualización de densidad aplicada [S]

## 15. Editor de mapas (RF1)

- [ ] Definir edición de islas (M27/54) y puntos de interés [M]
- [ ] Definir edición de viajes entre islas (M28) [M]
- [ ] Definir validación: POI únicos e islas referenciadas [M]
- [ ] Definir vista del mapa completo [S]
- [ ] Definir export de estructura del mapa [S]

## 16. Herramienta de teleport (RF7)

- [ ] Definir teleport a coordenadas exactas [S]
- [ ] Definir teleport a isla/POI/sello [M]
- [ ] Definir teleport con guardado del punto anterior [S]
- [ ] Definir integración con Debug Menu (M110) [S]

## 17. Herramienta de spawn (RF7)

- [ ] Definir spawn de objetos bajo cursor [S]
- [ ] Definir spawn de NPC y fauna [S]
- [ ] Definir spawn con cantidad y densidad editable [S]
- [ ] Definir validación de no duplicar entidades únicas [S]

## 18. Herramienta de debug (RF7)

- [ ] Definir menú de debug (M110): flags e invincibilidad [M]
- [ ] Definir dar objetos/dinero al jugador [S]
- [ ] Definir completar misión / desbloquear herramienta [S]
- [ ] Definir cambiar hora/estación/clima [S]
- [ ] Definir desbloquear isla/sello [S]
- [ ] Definir resetear NPC y puzzle [S]
- [ ] Definir regenerar chunk [M]
- [ ] Definir mostrar colliders, FPS, chunks, navegación [M]
- [ ] Definir mostrar hitboxes y estados de IA [M]
- [ ] Definir exportar diagnóstico [S]

## 19. Herramienta de inspección (RF8)

- [ ] Definir inspector de entidad (componentes) [M]
- [ ] Definir navegación por árbol de objetos [S]
- [ ] Definir edición inline de variables en editor [M]
- [ ] Definir copia de estado al portapapeles [S]

## 20. Herramienta de profiling (RF9)

- [ ] Definir stats del editor: FPS, memoria, draw calls (M61/62) [M]
- [ ] Definir stats por chunk/NPC/AI [M]
- [ ] Definir export de muestras a CSV [S]
- [ ] Definir visual en overlay del editor [S]

## 21. Herramienta de validación (RF10)

- [ ] Definir DataValidator global con cross-checks [C]
- [ ] Definir análisis de recetas→objetos inexistentes [M]
- [ ] Definir análisis de misiones→diálogos/objetivos [M]
- [ ] Definir análisis de tiendas→items [M]
- [ ] Definir análisis de economía→NPC [M]
- [ ] Definir análisis de rutinas→POI [M]
- [ ] Definir análisis de loot→objetos [M]
- [ ] Definir reporte JSON por dominio con flag bloqueante [M]
- [ ] Definir integración del validator como gate en CI (M112) [M]
- [ ] Definir reutilización del validator en M151 [S]

## 22. Herramienta de generación (RF11)

- [ ] Definir ContentGenerator con seeds de M10 [M]
- [ ] Definir sub-seeds para ruinas (M25) y spawns [M]
- [ ] Definir regeneración reproducible (misma seed → mismo mundo) [M]
- [ ] Definir valor de semilla en metadata del save (M59) [S]
- [ ] Definir reporte de generación tras regen [S]

## 23. Calidad y cierre (RF12)

- [ ] Definir aislamiento asmdef Editor (nada en build de jugador) [C]
- [ ] Definir verificación por script de exclusión en build [M]
- [ ] Definir compatibilidad con M110 (Debug Menu) [M]
- [ ] Definir compatibilidad con M108 (mods) [M]
- [ ] Definir soporte de herramientas para QA (M102) [S]
- [ ] Definir documentación plan-actual actualizada y firmada [S]
- [ ] Definir log del módulo en Logs/ [S]
- [ ] Definir feed a M112 (tests de editor) y M151 (validator) [S]

## Totales

**Total de ítems:** 127
**Ítems resueltos por documentación:** 127 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)