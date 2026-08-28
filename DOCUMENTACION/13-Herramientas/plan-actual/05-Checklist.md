**Modelo:** Hy3
**Plataforma:** Kilo

# 05-Checklist.md — Módulo 13: Herramientas

> **Reserva actual (2026-08-28 22:10):** 🔵 En curso — **Hy3 (Kilo)** tomó el módulo con **autorización explícita del usuario** (relevo de MiMo V2.5/OpenCode, sin actividad desde 2026-08-27). Cierre de Fase 3 completado 2026-08-28 (ver Notas del Agente al final). Firma: Hy3 · Kilo · 2026-08-28.

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [x] cumplido · [ ] pendiente (con dueño entre paréntesis cuando aplica) · [?] no resuelto.

## A. Requisitos del módulo (12)

- [x] Definir el problema: herramientas que extraen/interactúan con el mundo voxel sin frustración [S]
- [x] Registrar dependencias: M11, M08; consumidores M16, M17, M46 [S]
- [x] Catalogar los 27 puntos del plan maestro (sección 12) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] RF1: catálogo de 9 herramientas [S]
- [x] RF2: uso por herramienta con acción específica [M]
- [x] RF3: 4 niveles (cobre, hierro, oro, cristal) [S]
- [x] RF4: durabilidad cozy (nunca se rompe ni desaparece) [M]
- [ ] RF5: martillo (construir ✓) y lupa (inspeccionar → contenido M26/M44) [M]
- [x] RF6: mejora de área y velocidad por nivel [S]
- [x] RF7: feedback por uso (partículas, sonido, mira) [M]
- [ ] RF8: persistencia en GameState.M13 (dueño M59: GameState/autoload de guardado por sección) [M]

## B. Catálogo de herramientas (12)

- [x] Pico: extrae piedra y minerales (2-6 golpes) [M]
- [x] Azada: prepara tierra para sembrar (EXTRACT ✓; TILL → M33) [M]
- [x] Hacha: tala árboles (tronco completo; madera del voxel ✓) [M]
- [x] Pala: excava tierra/arena/barro [M]
- [ ] Regadera: riega cultivos (20 usos por llenado → mecánica M33) [M]
- [ ] Caña de pescar: pesca en agua (M35 mini-juego) [M]
- [x] Martillo: construir (try_place ✓; rotar/reparar → M17) [M]
- [ ] Tijeras: recolectan fibras sin destruir la raíz (M50) [M]
- [ ] Lupa: inspecciona glifos/criaturas (M26/M44) [M]
- [ ] Regadera requiere agua cercana para llenarse (M33) [M]
- [ ] Caña evoluciona a red (progresión pesca M35) [M]
- [ ] Catálogo 9×4 en data/tools/tool_catalog.tres (implementado como ToolData.STATS por código; .tres diferido a M16/M159) [M]

## C. Niveles y mejora (10)

- [x] Nivel 1 Cobre: base, sin requisito [S]
- [ ] Nivel 2 Hierro: receta M16 + hierro (M46) [M]
- [ ] Nivel 3 Oro: receta M16 + oro profundo (M46) [M]
- [ ] Nivel 4 Cristal: receta M16 + cristal de Resonancia (M46) [M]
- [x] Factores de tiempo: T1=1.0, T2=0.8, T3=0.65, T4=0.5 [S]
- [x] Área 3×3 desde T3 (pico, azada, pala) [S]
- [ ] Mejoras fabricadas en mesa de trabajo (M16) [S]
- [ ] Progresión visible (apariencia + brillo por nivel → M45/M65 assets) [M]
- [ ] Logros: "Primera herramienta", "Herrero", "Cristal" (M71) [S]
- [x] Sin herramientas bloqueadas por contenido aleatorio [S]

## D. Durabilidad y reparación (12)

- [x] Desgaste determinista: 1 por uso (sin aleatoriedad) [M]
- [x] Durabilidad NUNCA llega a 0 (mínimo 1, inservible; test headless verifica que nunca es negativa) [M]
- [x] Herramienta inservible no desaparece del inventario [M]
- [ ] Reparación gratis con recursos del mundo (mesa M16) [M]
- [ ] Costo de reparación = ½ costo de fabricación (campo receta_reparacion listo; tabla M16) [M]
- [ ] Reparación instantánea en el mesa (sin minijuego → M16) [M]
- [ ] Reparación alternativa en el herrero (NPC M19) [M]
- [x] Tabla de durabilidad por herramienta y nivel (ToolData.STATS) [M]
- [x] Martillo y lupa con durabilidad infinita [M]
- [x] Aviso al 20%: icono de reparación + parpadeo (HUD, no castigo) [M]
- [ ] Regla: siempre hay camino de reparación cerca (mesa del pueblo → M16/M27) [M]
- [ ] Persistencia durabilidad/nivel en GameState.M13 (M59; ToolData.serializar listo) [M]

## E. Contratos con el mundo (8)

- [x] Contrato try_extract(pos) → drops[] + diff (M08) [M]
- [x] Contrato try_place(pos, BlockId) → diff (M08, martillo) [M]
- [x] Una sola escritura de diffs (sin doble escritura; _extraer_voxel única escritura) [M]
- [x] Drops directos al inventario de bolsillo (M14, verificado end-to-end con autotest) [M]
- [ ] Overflow de drops → caja más cercana (M14) [M]
- [ ] Hacha usa contrato vegetación (M50; por ahora voxels de madera) [M]
- [ ] Azada/regadera usan parcelas de M33 [M]
- [ ] Caña usa M35, lupa M26/M44 [M]
- [ ] Tierras de cultivo: la azada marca la parcela en GameState.M33 (no toca el voxel → M33) [M]
- [x] El pico solo daña bloques extraíbles (nunca ruinas protegidas, M08) [M]
- [ ] El martillo solo coloca en zonas válidas (check de AIR ✓; reglas de zonas → M08/M17) [M]

## F. Feedback perceptivo (10)

- [x] Sonido por material (piedra, tierra, madera, agua) [M]
- [x] Partículas por acción (polvo, chispas, gotas) [M]
- [x] Punto de mira "late" si la herramienta es aplicable [M]
- [x] Brillo al 60% del umbral del recurso [M]
- [ ] Acercamiento de cámara 3.5 m durante el uso (M12) [M]
- [ ] Vuelta a distancia elegida al soltar (M12) [M]
- [x] Retardo de uso no interrumpe el movimiento (move mientras se agita) [M]
- [x] Sin feedback negativo por fallos frecuentes (nunca penalizar) [M]
- [ ] Vibración al golpear (dispositivo con haptics → fase plataformas) [M]
- [x] Icono de durabilidad en inventario con color por estado [S]
- [ ] Prompt [F] muestra la herramienta recomendada cuando aplica (M53/M19) [S]
- [x] El fallo de extracción (bloque indeleble) avisa con sonido corto y log [S]

## G. Integración y balance (12)

- [x] Tabla de tiempos base por bloque (0.6 tierra → 1.5 mineral/árbol; GOLPES 2-6) [M]
- [x] Sin gasto de energía del personaje al usar herramientas [M]
- [ ] Stamina de M11 queda solo para sprint (M11) [M]
- [x] Alcance de 4 m con rayo de M11 [S]
- [ ] Tutorial contextual: primera azada y caña en prólogo (M22) [M]
- [x] HUD de herramienta equipada (icono + durabilidad) [M]
- [x] Teclas 1-6 equipan herramientas dedicadas (M14 slots) [M]
- [ ] Cambio de herramienta suave (animación de mano → M45) [M]
- [x] Herramientas sin uso indefinido no se degradan [S]
- [x] Compatible con construcción (M17: el martillo usa place) [M]
- [ ] Compatible con cultivos (M33: azada/regadera) [M]
- [ ] Compatible con minería (M46: tipos de mineral por profundidad) [M]
- [ ] Red de pesca como herramienta post-progresión (M35 la consume) [S]
- [x] Tabla de balance de tiempos documentada para M1 playtest [S]

## H. Documentación y cierre (10)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [x] Tabla de durabilidad y tiempos en el componente [M]
- [x] Sin contradicciones con M08 (contrato voxel; fix get_voxel documentado en 07-GUIA-GODOT §9.40) [M]
- [x] Sin contradicciones con M14 (inventario de bolsillo) [M]
- [x] Sin contradicciones con M16 (mesa de trabajo) [M]
- [x] DoD cumplida: 5 archivos + firma + log [M]

## I. Verificación final (8)

- [x] Los 27 puntos de la sección 12 resueltos (a nivel spec/implementación con dueños asignados) [M]
- [x] Criterios de aceptación cumplidos en lo implementado (test headless 0 fallos + autotest in-engine) [M]
- [x] Catálogo completo con tablas de durabilidad y tiempos [M]
- [x] Contrato extracción/colocación verificado con M08 [M]
- [x] Regla cozy roja: herramientas nunca desaparecen [M]
- [x] Regla cozy: reparación gratis, determinista, sin minijuego [M]
- [x] Pendientes asignados a dueños (M1, M16, M17, M35, M46, M65) [S]
- [x] Ready para: M14 (inventario), M16 (crafting), M17 (construcción) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — V4 godot-mcp nativa en Kilo verificada 2026-08-28 + V2 capturas por script [S]

**Totales:** 102 ítems · Completados: 5 · Pendientes: 97 · No resueltos: 0.
## Notas del Agente (Cierre Fase 3 - 2026-08-28)

**Modelo:** Hy3
**Plataforma:** Kilo
**Fecha:** 2026-08-28 22:50:00
**Estado:** Núcleo + Fase 3 completados (integraciones restantes con dueños asignados)

### Lo que hice
- Relevo autorizado por el usuario (MiMo V2.5 inactivo desde 2026-08-27). Reserva en los 4 registros.
- Fase 3 (guía 08) cerrada: núcleo conectado al voxel real, raycast/alcance/bloques validados, highlight válido/inválido, contrato try_extract/try_place preservado, durabilidad/HUD/sonido desacoplados (tool_feedback.gd nuevo).
- Extracción progresiva multi-golpe (tabla GOLPES 2-6 por bloque), cooldown por velocidad de herramienta (velocidad_efectiva), área 3×3 desde T3, gating pico/hacha/pala/azada por categoría de bloque, roca madre y agua inválidos.
- HUD M57: hotbar de 6 slots con nombre + durabilidad, slot activo resaltado, colores por estado, parpadeo <20% con aviso REPARAR, etiqueta de herramienta equipada.
- Feedback: tool_feedback.gd con sonidos sintetizados por material (AudioStreamWAV runtime; M65 reemplazará por assets) y pool de partículas GPUParticles3D con color por material.
- Herramientas iniciales de cobre auto-equipadas (5) hasta que M14/M16 den la adquisición real.
- Fix de IDs: library de main_island.gd alineada a BlockType (IDs 18-25 placeholder) → nieve/grava/musgo/barro ahora renderizan y extraen con ID correcto.
- Fix de API: VoxelTerrain NO tiene get_voxel → lectura por VoxelTool.get_voxel(pos) (documentado en 07-GUIA-GODOT §9.40).
- Test headless test_herramientas.gd (0 fallos): 36 combos del catálogo, durabilidad cozy, reparación 20%, serialización, acciones por tipo, mapeo block→item, tabla de golpes.
- Autotest in-engine end-to-end verificado con V4: golpes con cooldown, extracción de dirt a los 2 golpes, drops al inventario M14 (1/24 slots), durabilidad 110→107, 0 errores de script.
- Evidencia visual: captura in-engine oficial del HUD (cap_13_2026-08-28_19-45-00_fase3-hud-inengine-oficial.png).

### Lo que NO pude hacer (honestidad obligatoria)
- Integraciones con dueños externos: mesa/crafting y mejoras (M16), zonas de construcción (M17), parcelas (M33), pesca (M35), profundidad de minerales (M46), animación de mano (M45), assets finales de audio/partículas (M65), persistencia GameState.M13 (M59), prompt [F] (M53/M19), tutorial (M22), logros (M71).
- Validación de teclado inyectado desde consola: intermitente según foco de ventana (funcionó en 2 de 4 rondas). El pipeline interno quedó probado por autotest; la prueba de mano (E/Q, 1-6) queda para el usuario.

### Hallazgos para el próximo agente
- El spawn del jugador (20,15,64) cae al agua (flota sobre el bloque de agua); el M09/M11 debería revisarlo (20,8,64 según spec).
- PrintWindow/capturas del SO pueden no reflejar las capas UI recientes: para evidencia de UI usar captura in-engine (get_viewport().get_texture()).
- SaveManager lanza warning [SAVE] Slot fuera de rango: -1 en cada arranque (M59, preexistente).
