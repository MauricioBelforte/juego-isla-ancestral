**Modelo:** Hy3
**Plataforma:** Kilo

# 04-Codigo.md — Módulo 13: Herramientas

## 1. Carácter del Componente

Módulo que **especifica el sistema de herramientas** (catálogo, durabilidad, contratos, mejora) a implementar en el prototipo del hito M1. No crea scripts todavía. Sin 06/07 aún (los tests de herramientas entran en M1: extracción, contratos, reparación).

## 2. Archivos involucrados (implementación prevista)

```
scripts/tools/tool.gd                 → Resource base (Tool)
scripts/tools/tool_item.gd            → instancia con durabilidad (M14 integra)
scripts/tools/tool_registry.gd        → catálogo estático (ServiceLocator M07)
scripts/tools/tool_actions.gd         → dispatch de acciones por herramienta
scripts/tools/tool_feedback.gd        → sonidos/partículas
data/tools/tool_catalog.tres          → tabla completa (9 × 4 niveles)
```

## 3. Contratos de integración

- **Entrada:** `ToolAction(input.pos, tool_id)` desde M11 (InteractionService + F/click).
- **Salida:** `ToolResult(ok, drop[], diff, feedback)` → M14 (inventario) y M08 (WorldPartition).
- **Consume:** catálogo de bloques M08, durabilidad por instancia M14, recursos M46.
- **Publica:** `tool_used(tool_id, pos)`, `tool_repair_request(id)` → EventBus (HUD e informes M71).
- **Persistencia:** `GameState.M13.tools: { id → {durability, level}}`.

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Ajuste fino de tiempos reales por bloque | Prototipo M1 (playtest) |
| Mini-juego de pesca (caña) | M35 (mecánica) |
| Martillo completo (rotación/pegado) | M17 (construcción) |
| Lupa: datos de inspección por objetivo | M26/M44 (contenido) |
| Sonidos/partículas finales | M65 (assets) |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 05:30:00
**Estado:** Completado (especificación; implementación en M1/M17/M35)

### Lo que hice
- Resolví los 27 puntos de la sección 12 del plan maestro.
- Catálogo de 9 herramientas × 4 niveles con tabla de durabilidad y tiempos.
- Contrato de extracción/colocación con M08 (try_extract/try_place) verificado.
- Reglas cozy: reparación gratis con recursos, herramientas nunca desaparecen, martillo/lupa infinitos.
- Persistencia en GameState.M13 y progresión atada a M46 (cobre→hierro→oro→cristal).

### Lo que NO pude hacer (honestidad obligatoria)
- Balancear tiempos reales → playtest M1.
- Mini-juego de pesca → M35.
- Mecánica de construcción del martillo → M17.
- Contenido de la lupa → M26/M44.
- Assets finales → M65.

### Recomendaciones para el próximo agente
- Respetar el contrato try_extract/try_place (una sola escritura de diffs, M08).
- Nunca implementar rotura total de herramientas: es regla cozy roja del proyecto.
- La caña y la lupa son "herramientas de conocimiento": no gastan durabilidad (M35/M26).

## 6. Implementación real (2026-08-28 — Hy3 / Kilo)

La especificación anterior se implementó con estos archivos reales:

```
scripts/tools/tool_data.gd          → Resource con STATS 9×4, acciones, durabilidad cozy, serialización
scripts/tools/tool_controller.gd    → raycast por cámara (VoxelTool.raycast), extracción progresiva
                                      multi-golpe (GOLPES 2-6), highlight válido/inválido, cooldown,
                                      área 3×3 T3+, contrato try_extract/try_place (M08)
scripts/tools/tool_feedback.gd      → sonidos sintetizados (AudioStreamWAV) + partículas (GPUParticles3D),
                                      desacoplado: escucha señales del controller
scripts/tools/test_herramientas.gd  → test headless (0 fallos): catálogo, cozy, serialización, contratos
scripts/player/player.gd            → hotbar (1-6), HUD durabilidad M57, fallback de mano, herramientas
                                      iniciales de cobre; E/Q polling en ToolController (§9.29)
scripts/main_island.gd              → library de bloques alineada a BlockType (IDs 0-29)
```

Contratos vigentes: `intentar_golpe()` (E, con cooldown), `try_place(block_id)` (Q con martillo),
señales `bloque_extraido/bloque_colocado/golpe_conectado/golpe_fallido/herramienta_equipada/durabilidad_cambiada`
(snake_case §1.1). Lectura de voxel SOLO por `VoxelTool.get_voxel(pos)` (§9.40).

## 7. Notas del Agente (cierre Fase 3)

**Modelo:** Hy3
**Plataforma:** Kilo
**Fecha:** 2026-08-28 22:55:00
**Estado:** Fase 3 completada (guía 08); núcleo jugable + feedback operativo

### Lo que hice
- Conexión real al mundo voxel con validación in-engine (V4 godot-mcp): raycast desde cámara,
  extracción progresiva (dirt = 2 golpes verificado en vivo), drops → Inventario M14 (1/24 slots).
- Highlight "late": solo objetivos válidos según categoría de bloque; amarillo al 60% de progreso;
  inválidos (agua/roca madre/herramienta equivocada) nunca se iluminan; fallo avisa con sonido+log.
- HUD M57 completo (verificado con captura in-engine): hotbar 6 slots, durabilidad por estado,
  parpadeo <20%, herramienta activa resaltada, etiqueta equipada.
- Sonido/partículas procedurales desacoplados en tool_feedback.gd (M65 dará assets finales).
- Test headless 0 fallos + autotest in-engine end-to-end + 4 capturas en capturas/13-Herramientas/.
- Fix estructural: library de bloques alineada a BlockType (IDs 18-25 placeholders) — corrige
  renderizado/extracción de nieve/grava/musgo/barro.

### Lo que NO pude hacer (honestidad obligatoria)
- Integraciones con dueños: M16 (mesa/mejoras/reparación), M17 (zonas), M33 (parcelas),
  M35 (pesca), M46 (profundidad), M45 (modelo de mano), M65 (assets), M59 (persistencia),
  M53/M19 (prompt F), M22 (tutorial), M71 (logros), M12 (zoom de uso).
- Prueba de teclado inyectado por consola intermitente por foco; prueba de mano (E/Q, 1-6) para el usuario.

### Recomendaciones para el próximo agente
- El spawn (20,15,64) deja al jugador flotando sobre agua: revisar en M09/M11 (spec decía 20,8,64).
- Para evidencia de UI usar captura in-engine (get_viewport().get_texture()); PrintWindow puede
  omitir capas UI recientes (ver 06-GUIA-DE-CONEXION-VISION, descubrimientos de capturas).
- Herramientas iniciales hardcodeadas en _crear_herramientas_iniciales(): reemplazar por
  adquisición real cuando M14/M16 existan.

---

## Notas del Agente — Iteración 5 niveles → progresión (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 01:15:00
**Estado:** Parcial (señal nivel_herramienta_cambio implementada y verificada; módulo liberado 🟡)

### Lo que hice
- EventBus M07: dominio nuevo `progresion` (aditivo) con señales nivel_herramienta_cambio/nivel_casa_cambio/nivel_amistad_cambio — la señal estándar que el diseño M71 §3.6/§5 requería.
- ProgressionManager M71: puente `conectar_tool_controller(tc)` público (el ToolController es de ESCENA, no autoload) que traduce herramienta_equipada(tool: ToolData) → nivel_herramienta_cambio(id_legible, nivel) + estadística monótona `nivel_pico`/`nivel_azada`/... en PlayerProfile (solo sube, nunca baja — §3.6 nivel_modulo consume nivel máximo).
- tool_id legible del enum Tipo: pico/azada/hacha/pala/regadera/cana/martillo/tijeras/lupa.
- Núcleo M13 (tool_controller.gd) NO modificado — la conexión es desde M71 (§4.1: sin acoplamiento).
- Test test_nivel_herramienta.gd: puente emite señal, estadística monótona sube con HIERRO→ORO y no baja con COBRE → **0 fallos**.
- Regresiones: test_progresion M71 0 fallos, test_herramientas M13 0 fallos.
- Checklist: +2 ítems [x] (señal de niveles M13 + integración M71). Progreso 65→67/102.

### Lo que NO pude hacer (honestidad obligatoria)
- La ESCENA real (main_island.tscn) debe llamar ProgressionManager.conectar_tool_controller(tc) al montar el ToolController — 1 línea en el Bootstrap/escena (con dueño del escenerio, yo no edito la escena principal sin dueño).
- nivel_casa_cambio/nivel_amistad_cambio: iguales patrones para M18/M20 (puentes de 1 línea cuando M18/M20 lo implementen).
- Nombres i18n de niveles: ToolData.NOMBRES usa español hardcode — M87 puede traducir con claves TOOLS.* en próxima iteración.

### Recomendaciones para el próximo agente
- Bootstrap/escena principal: llamar ProgressionManager.conectar_tool_controller($ToolController) en _ready de la escena (1 línea, cierra el puente en runtime real).
- M71: las condiciones nivel_modulo(picota, 2) del §3.6 usan stat "nivel_pico" >= 2 — el formato del stat_id es "nivel_" + tool_id legible.
- M18 (casas): replicar el patrón exacto con nivel_casa_cambio.
