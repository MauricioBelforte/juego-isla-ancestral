# CHECKLIST-GLOBAL.md — Orquestador Multiagente

> **Modelo:** Deepseek V4 Flash
> **Plataforma:** OpenCode
> **Fecha:** 2026-08-17

Este archivo es la **única fuente de verdad** sobre el estado global del proyecto. Contiene la **tabla resumen** con UNA fila por módulo. Los subitems detallados viven en `DOCUMENTACION/{NN}-Modulo/plan-actual/05-Checklist.md` de cada módulo.

> ⚠️ **Puede ser generado por script.** Las columnas `Estado` y `Progreso` se recalculan automáticamente según los `05-Checklist.md`. Las columnas manuales (`Prioridad`, `Complejidad`, `Dependencias`, `Agente actual`, `Última actividad`, `Notas`) se **preservan** de la versión anterior si el módulo ya existía. Ver sección 21.9 del `AGENTS.md`.

## Especificación del Protocolo

Ver sección 21 del `AGENTS.md` para el flujo completo (incluye QA cruzado, DoD y herramientas de automatización).

## Tabla Resumen de Módulos

| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | Agente actual | Última actividad | Notas |
|----|--------|--------|----------|-----------|-------------|--------------|---------------|------------------|-------|
| 01 | Fundamentos del Proyecto | 🔵 En curso | 0/152 | Alta | 4 | — | DEEPSEEK V4 FLASH | 2026-08-17 | Base documental creada (5 archivos + checklist de 152 módulos). Índice/portal activo (no colgado). Pendiente: desglosar módulos 02-152 |
| 02 | Visión y Concepto | 🟢 Disponible | 162/172 | Alta | 2 | 01 | — | 2026-08-15 | Documentación completa por DEEPSEEK V4 FLASH (5 archivos + checklist 172 ítems). 10 pendientes con dueño externo (M02 legal, QA, Publicación) — ver Notas del Agente en plan-actual/04-Codigo.md |
| 03 | Documentación del Proyecto | 🟢 Disponible | 133/133 | Alta | 2 | 01 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: catálogo 25 docs con dueño, convenciones, hitos M1-M5, roadmap, 5 esqueletos *-ACTUAL.md. Contenido substantivo en módulos dueños |
| 04 | Game Engine | 🟢 Disponible | 95/120 | Alta | 5 | 01 | — | 2026-08-16 | **DECISIÓN CONFIRMADA (2026-08-16):** Godot 4.x + Voxel Tools (GDExtension, requiere ≥4.4.1) + GDScript — investigación 2026 en plan-actual/04-Codigo.md (Log 17). Pendientes: instalación y proyecto base → hito M1 |
| 05 | Lenguaje y Programación | 🟢 Disponible | 102/102 | Alta | 3 | 04 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: GDScript adoptado, convenciones, patrones transversales (EventBus, GameClock, Logger), guía anti-patterns |
| 06 | Control de Versiones | 🟢 Disponible | 91/92 | Media | 1 | 01 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: ramas, semver, auto-revisión, CHANGELOG.md creado. Pendiente: protección rama (Publicación) |
| 07 | Arquitectura General | 🟢 Disponible | 102/102 | Alta | 5 | 04 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: Service Locator, capas unidireccionales, EventBus por dominios, GameState particionado, contrato de integración. Implementación → M1 |
| 08 | Mundo Voxel | 🟢 Disponible | 104/104 | Alta | 5 | 07 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: voxel 1m, chunks 16³, catálogo ~30 bloques, reglas de validación, diffs por chunk, Voxel Tools como base. Validación física → M1/M61 |
| 09 | Terreno y Geografía | 🟢 Disponible | 104/104 | Alta | 4 | 08 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: 25 puntos resueltos, 13 biomas, recetas de formaciones, mapa geográfico de Aurora con 8 POI, reglas anti-softlock. Calibración visual → M1 |
| 10 | Generación del Mundo | 🟢 Disponible | 104/104 | Alta | 5 | 08 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: pipeline de 8 capas, PRNG por contexto, semilla dev, regen 80/0, estructuras ancladas. Implementación → M1/M61 |
| 11 | Personaje del Jugador | 🟢 Disponible | 102/102 | Alta | 3 | 07 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: FSM 10 estados, hitbox 0.6x1.8, stamina informativa, interacción F, esporas de luz. Implementación → M1/M29/M65 |
| 12 | Cámara | 🟢 Disponible | 100/100 | Alta | 2 | 11 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: 5 modos de cámara, spring-arm con colisión, minimapa sin render, anti-mareo. Implementación → M1 |
| 13 | Herramientas | 🟢 Disponible | 101/101 | Alta | 4 | 11 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: 9 herramientas x 4 niveles, durabilidad cozy (nunca se rompen), contrato try_extract/try_place, martillo y lupa infinitos. Implementación → M1/M17/M35 |
| 14 | Inventario | 🟢 Disponible | 140/140 | Alta | 3 | 11 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 15 | Recursos | 🟢 Disponible | 165/165 | Alta | 3 | 14 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 16 | Crafting | 🟢 Disponible | 147/147 | Alta | 3 | 14, 15 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 17 | Construcción | 🟢 Disponible | 174/174 | Alta | 5 | 08, 14 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 18 | Casas | 🟢 Disponible | 125/125 | Media | 3 | 17 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 19 | NPC y Vecinos | 🟢 Disponible | 130/130 | Alta | 4 | 11, 25 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 20 | Sistema de Amistad | 🟢 Disponible | 147/147 | Media | 3 | 19 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 21 | Diálogos | 🟢 Disponible | 129/129 | Alta | 4 | 19 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 22 | Historia Principal | 🟢 Disponible | 94/94 | Alta | 4 | 21, 28 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 25/25 puntos sección 21, 7 capítulos, 5 finales, grafo validado, 7 sellos como gating |
| 23 | Historias Secundarias | 🟢 Disponible | 104/104 | Media | 3 | 22 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 25/25 puntos sección 22, 60 cadenas con contexto obligatorio, 12 consecuencias persistentes |
| 24 | Templos y Puzzles | 🟢 Disponible | 121/121 | Alta | 5 | 13 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 26/26 puntos sección 23, framework emisor→receptor, 15 familias, validador de arbitrariedad, Guía del Templo |
| 25 | Ruinas | 🟢 Disponible | 116/116 | Media | 3 | 24 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 25/25 puntos sección 24, kit modular ≤40 piezas, 13 tipos, progresión 4 estados, activadores |
| 26 | Templo Subterráneo | 🟢 Disponible | 114/114 | Alta | 4 | 24, 25 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 26/26 puntos sección 25, metría voxel 4x4x4, 7 anillos + sello, 5 checkpoints atómicos, Templo de la Brisa |
| 27 | Islas del Mundo | 🟢 Disponible | 170/170 | Media | 4 | 28, 29 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 28 | Viajes | 🟢 Disponible | 130/130 | Media | 3 | 22, 27 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 29 | Tiempo y Calendario | 🟢 Disponible | 104/104 | Alta | 3 | 07 | — | 2026-08-16 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: GameClock servicio puro (API en plan-actual/03), calendario Aurora (día 24min, año 336d), eventos periódicos repetibles, regla cozy anti-frustración. Sin voxel/assets |
| 30 | Reloj en Tiempo Real | 🟢 Disponible | 104/104 | Media | 3 | 29 | — | 2026-08-16 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: decisión NO tiempo real (explotes/offline), regla de oro anti-reloj-SO, widget display puro, 10 pruebas de límites de fecha. Implementación tras M29 |
| 31 | Ciclo Día/Noche | 🟢 Disponible | 130/130 | Media | 3 | 29 | — | 2026-08-16 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 22/22 puntos, 5 franjas (ALBA/DÍA/ATARDECER/NOCHE/PROFUNDA), anti-oscuridad (piso 0.15 + linterna + opción M58), eventos nocturnos opcionales. Implementación tras M29/M49 |
| 32 | Clima | 🟢 Disponible | 120/120 | Media | 3 | 29, 31 | — | 2026-08-16 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 25/25 puntos, 9 climas deterministas (seed+día), regla de oro anti-molestia (bono sí, bloqueo no), accesibilidad M58. Implementación tras M29/M31 |
| 33 | Agricultura | 🟢 Disponible | 153/153 | Media | 3 | 17, 29 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 34 | Pesca | 🟢 Disponible | 153/153 | Media | 3 | 32 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 35 | Minería | 🟢 Disponible | 142/142 | Media | 3 | 08, 13 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 36 | Fauna | 🟢 Disponible | 142/142 | Media | 3 | 07, 31 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 37 | Museos y Colecciones | 🟢 Disponible | 148/148 | Baja | 3 | 36 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 38 | Economía | 🟢 Disponible | 158/158 | Alta | 4 | 15, 16, 20 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 4, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 39 | Tiendas | 🟢 Disponible | 181/181 | Media | 3 | 38 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 7, 2026-08-17): catálogos por NPC, horarios, stock renovable determinista, precios de M38. DELEGABLE PARA IMPLEMENTAR |
| 40 | Infraestructura | 🟢 Disponible | 211/211 | Media | 3 | 38 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 7, 2026-08-17): autoloads de M38, servicios base, bootstrap. DELEGABLE PARA IMPLEMENTAR |
| 41 | Música | 🟢 Disponible | 110/110 | Media | 4 | — | — | 2026-08-16 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 51/51 puntos, matriz de capas (base+tiempo+evento) para 12×4×3 contextos, leitmotifs, volumetría LUFS -16, presupuesto ≈90 archivos. Composición → assets |
| 42 | Sonido Ambiental | 🟢 Disponible | 99/99 | Media | 3 | 41 | — | 2026-08-16 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 25/25 puntos, mapa banco→bioma (13+1), capas hora/clima que suman, ≤11 buses, ≤-18 LUFS. Samples → compositor |
| 43 | Efectos de Sonido | 🟢 Disponible | 96/96 | Media | 3 | 41 | — | 2026-08-16 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 25/25 puntos, pool 24 voces con prioridades, familia tonal con M41, 6 superficies x4 variaciones |
| 44 | ASMR y Feedback | 🟢 Disponible | 113/113 | Media | 3 | 43 | — | 2026-08-16 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 17/17 puntos, recetas de capas, sincronía keyframes M34, blacklist anti-agresión (True Peak/buzz), precedencia contextual fija |
| 45 | Arte 3D | 🟢 Disponible | 157/157 | Alta | 5 | — | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (2026-08-17): estilo Cozy Voxel, techos de polígonos por categoría, LOD, sockets, kit modular, validador de assets. DELEGABLE PARA IMPLEMENTAR (plan maestro sección 44) |
| 46 | Arte 2D | 🟢 Disponible | 109/109 | Media | 3 | 45 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (2026-08-17): estilo heredado del 3D, iconos, retratos con plantilla 3D, símbolos, atlas por superficie, validador. DELEGABLE PARA IMPLEMENTAR (plan maestro sección 45) |
| 47 | Texturas y Materiales | ⬜ Sin iniciar | 0/100 | Media | 3 | 45 | — | — | — |
| 48 | Animación | ⬜ Sin iniciar | 0/100 | Media | 4 | 45, 11, 19 | — | — | — |
| 49 | Iluminación | ⬜ Sin iniciar | 0/100 | Media | 3 | 07, 45 | — | — | — |
| 50 | Vegetación | ⬜ Sin iniciar | 0/100 | Media | 3 | 08, 45 | — | — | — |
| 51 | Agua | ⬜ Sin iniciar | 0/100 | Media | 4 | 08, 24 | — | — | — |
| 52 | Partículas y VFX | ⬜ Sin iniciar | 0/100 | Media | 3 | 45 | — | — | — |
| 53 | UI/UX | 🟢 Disponible | 144/144 | Alta | 4 | 11, 14 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por Deepseek V4 Flash |
| 54 | Mapa | 🟢 Disponible | 170/170 | Media | 3 | 53 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 7, 2026-08-17): mapa exploración + minimapa, POI, marcas propias. Conteo real verificado por script: 170 ítems. DELEGABLE PARA IMPLEMENTAR |
| 55 | Diario del Jugador | ⬜ Sin iniciar | 0/100 | Baja | 3 | 53 | — | — | — |
| 56 | Fotografía | ⬜ Sin iniciar | 0/100 | Baja | 2 | 53 | — | — | — |
| 57 | Interfaz de Control | 🟢 Disponible | 119/119 | Alta | 2 | 04 | — | 2026-08-16 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 22/22 puntos, capa de acciones única, remapeo con conflictos, prompts dinámicos por dispositivo, persistencia atómica, Steam Deck |
| 58 | Accesibilidad | 🟢 Disponible | 173/173 | Alta | 3 | 53, 57 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 4, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 59 | Guardado | ⬜ Sin iniciar | 0/100 | Alta | 5 | 07, 14 | — | — | GameState versionado |
| 60 | Datos y Serialización | 🟢 Disponible | 197/197 | Alta | 3 | 59 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 6, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 61 | Rendimiento | 🔵 En curso | 0/100 | Alta | 5 | 08, 49 | GPT-5 (Codex) | 2026-08-16 | Documentación técnica en preparación: presupuesto de frame, LOD, culling, streaming y medición para Godot 4.x + Voxel Tools. |
| 62 | Memoria | 🟢 Disponible | 150/150 | Alta | 3 | 61 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 5, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 63 | Cargas y Streaming | 🟢 Disponible | 101/101 | Alta | 4 | 08, 61 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 15/15 puntos, progreso real por pesos, LRU con tope, precalentamiento en menú, streaming océano/subterráneo/islas. Requiere M08 + presupuestos M61 |
| 64 | IA de NPC | 🟢 Disponible | 107/107 | Alta | 5 | 19, 61 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 22/22 puntos, FSM con memoria de plan, 6 perfiles de rutina, simulación parcial por burbuja (≤60 plena), anti-atascos. Requiere M19 + presupuestos M61 |
| 65 | Animales IA | 🟢 Disponible | 129/129 | Media | 3 | 36, 64 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 19/19 puntos sección 64, FSM 10 estados, manadas/bancos, migración estacional, presupuesto M61, cozy sin caza |
| 66 | Anti-Softlock | 🟢 Disponible | 117/117 | Alta | 3 | 22, 26 | — | 2026-08-17 | **DELEGABLE PARA IMPLEMENTAR** — documentación completa por DEEPSEEK V4 FLASH: 15/15 puntos sección 65, detector de invariantes, cofre de recuperación, checkpoints rotativos, IRecoverable |
| 67 | Vehículos | ⬜ Sin iniciar | 0/100 | Baja | 3 | 28 | — | — | — |
| 68 | Transporte y Navegación | ⬜ Sin iniciar | 0/100 | Baja | 3 | 28, 67 | — | — | — |
| 69 | Fast Travel | 🟢 Disponible | 143/143 | Baja | 1 | 28 | — | 2026-08-17 | Documentación completa por Nemotron 3.5 (B1). Conteo real verificado por Deepseek V4 Flash (2026-08-17): 143 ítems. DELEGABLE PARA IMPLEMENTAR |
| 70 | Interacciones | 🟢 Disponible | 197/197 | Alta | 3 | 11, 13 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 4, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 71 | Progresión | 🟢 Disponible | 213/213 | Alta | 3 | 22, 38 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 5, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 72 | Sistema de Logros | 🟢 Disponible | 190/190 | Media | 2 | 71 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 7, 2026-08-17): catálogo, desbloqueo, notificación, Steam sync, anti-grind. DELEGABLE PARA IMPLEMENTAR (M72 ya no pendiente de B2-Composer) |
| 73 | Coleccionables | ⬜ Sin iniciar | 0/100 | Media | 3 | 71, 36 | — | — | — |
| 74 | Eventos | 🟢 Disponible | 266/266 | Media | 3 | 30, 29 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 7, 2026-08-17): festivales estacionales, eventos repetibles anuales, anti-FOMO. DELEGABLE PARA IMPLEMENTAR |
| 75 | Postgame | ⬜ Sin iniciar | 0/100 | Baja | 3 | 22 | — | — | — |
| 76 | Multijugador | ⬜ Sin iniciar | 0/100 | Baja | 5 | — | — | — | Decisión pendiente |
| 77 | Online y Red | ⬜ Sin iniciar | 0/100 | Baja | 5 | 76 | — | — | — |
| 78 | Legal — Propiedad Intelectual | 🟢 Disponible | 157/157 | Alta | 2 | 01 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 4, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 79 | Legal — Contratos | ⬜ Sin iniciar | 0/100 | Media | 2 | 78 | — | — | — |
| 80 | Legal — Privacidad | 🟢 Disponible | 144/144 | Alta | 2 | 78 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 4, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 81 | Legal — Menores | ⬜ Sin iniciar | 0/100 | Media | 2 | 80 | — | — | — |
| 82 | Clasificación por Edades | ⬜ Sin iniciar | 0/100 | Media | 1 | 78 | — | — | IARC |
| 83 | Licencias de Software | ⬜ Sin iniciar | 0/100 | Media | 2 | 78 | — | — | — |
| 84 | Música y Audio — Legal | ⬜ Sin iniciar | 0/100 | Media | 2 | 41, 78 | — | — | — |
| 85 | Modelos 3D — Legal | ⬜ Sin iniciar | 0/100 | Media | 2 | 45, 78 | — | — | — |
| 86 | IA Generativa | 🟢 Disponible | 129/129 | Alta | 3 | 78 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 4, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 87 | Localización | 🟢 Disponible | 136/136 | Media | 3 | 21, 53 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 7, 2026-08-17): i18n/l10n, textos dinámicos, plurales, cambio en vivo. DELEGABLE PARA IMPLEMENTAR |
| 88 | Fuentes Tipográficas | 🟢 Disponible | 172/172 | Baja | 1 | 53 | — | 2026-08-16 23:30:00 | Documentación completa por Devin: Se seleccionó Nunito como fuente principal (sans-serif, legible, amigable, soporta cirílico, SIL Open Font License 1.1). Se seleccionó Fredoka One como fuente secundaria (rounded, amigable, perfecta para estilo cozy, SIL Open Font License 1.1). Se revisaron licencias (SIL Open Font License 1.1 con atribución). Se revisaron caracteres especiales (tildes, ñ, símbolos, cirílico). Se definieron tamaños de fuente (H1 32px, H2 24px, H3 20px, BODY 16px, SMALL 12px, MICRO 10px). Se definieron pesos (Light 300, Regular 400, Medium 500, Bold 700). Se definieron tracking (normal 0, tight -1, loose 1). Se definió line height (título 1.0, cuerpo 1.2, párrafo 1.4). Se creó jerarquía visual (H1 > H2 > H3 > cuerpo > pequeño > micro). Se diseñaron estilos de UI en Godot (Theme, StyleBox, Label, RichTextLabel, Button). Se diseñó optimización de fuentes (subsetting, compresión WOFF2, caching). Se diseñó integración con M58 (Accesibilidad) para ajustes de tamaño y contraste. Se diseñó integración con M87 (Internacionalización) para carga de fuente según idioma. Se diseñó integración con M90 (Configuración Gráfica) para settings de fuentes. |
| 89 | Diseño de Menús | ⬜ Sin iniciar | 0/100 | Media | 3 | 53 | — | — | — |
| 90 | Configuración Gráfica | 🟢 Disponible | 248/248 | Media | 1 | 53 | — | 2026-08-17 00:15:00 | Documentación completa por Devin: Se documentó configuración gráfica con 23 opciones (resolución, pantalla completa, ventana, borderless, VSync, FPS cap, escala de resolución, upscaling, calidad de sombras/texturas/efectos/vegetación/agua/partículas, anti-aliasing, anisotropic filtering, post-processing, bloom, motion blur, depth of field). Se definieron 4 presets gráficos (bajo, medio, alto, ultra). Se diseñó detección automática de hardware (GPU, RAM, CPU) y recomendación de preset. Se diseñó menú de configuración gráfica con todos los controles (dropdowns, toggles, sliders). Se diseñó GraphicsSettings (Resource) para configuración actual. Se diseñó GraphicsPresets con 4 presets. Se diseñó HardwareDetector para detección de hardware. Se diseñó GraphicsApplier para aplicación en tiempo real. Se diseñó GraphicsSettingsLoader para carga al inicio. Se diseñó GraphicsSettingsSaver para guardado al cerrar. Se diseñó integración con M58 (Accesibilidad) para ajustes de fuentes y reducción de effects. Se diseñó integración con M61 (Rendimiento) para FPS counter y profiling en debug. Se diseñó integración con M88 (Fuentes Tipográficas) para ajustes de fuentes. Se crearon 5 archivos de documentación con 248 ítems de checklist. |
| 91 | Configuración de Audio | 🟢 Disponible | 239/239 | Media | 1 | 53 | — | 2026-08-17 00:30:00 | Documentación completa por Devin: Se documentó configuración de audio con 15 opciones (volumen maestro, música, efectos, ambiente, voces, UI, cinemáticas, audio 3D, subtítulos, sonidos de interfaz, rango dinámico, compresión, dispositivo de salida, pruebas con auriculares, pruebas con altavoces). Se definieron 7 buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic). Se diseñó audio 3D con espacialización (HRTF) y oclusión. Se diseñaron subtítulos con toggle, tamaño, opacidad, fondo, color de texto. Se diseñaron sonidos de interfaz (hover, click, notificaciones, errores). Se diseñó rango dinámico (quiet, medio, dinámico) con compresión. Se diseñó compresión de audio con limiter. Se diseñó dispositivo de salida (predeterminado, auriculares, altavoces, HDMI, Bluetooth). Se diseñaron pruebas con auriculares (estéreo, espacial 3D, balance de canales) y altavoces (estéreo, 5.1, 7.1, balance de canales). Se diseñó menú de configuración de audio con todos los controles (sliders, toggles, dropdowns). Se diseñó AudioSettings (Resource) para configuración actual. Se diseñó AudioBusSetup para setup de buses de audio. Se diseñó Audio3DSetup para espacialización y oclusión. Se diseñó SubtitleManager para mostrar subtítulos. Se diseñó UISoundManager para sonidos de interfaz. Se diseñó DynamicRangeManager para rango dinámico con compresión. Se diseñó CompressionManager para compresión de audio con limiter. Se diseñó OutputDeviceManager para dispositivo de salida. Se diseñó AudioTestManager para pruebas de audio. Se diseñó AudioSettingsLoader para carga al inicio. Se diseñó AudioSettingsSaver para guardado al cerrar. Se diseñó integración con M58 (Accesibilidad) para ajustes de accesibilidad. Se diseñó integración con M87 (Internacionalización) para subtítulos multiidioma. Se diseñó integración con M61 (Rendimiento) para streaming y pool de AudioPlayers. Se crearon 5 archivos de documentación con 227 ítems de checklist. |
| 92 | Tutorial | 🟢 Disponible | 185/185 | Alta | 3 | 53, 70 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 5, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 93 | Balance | ⬜ Sin iniciar | 0/100 | Alta | 4 | 38, 20 | — | — | — |
| 94 | Retención sin FOMO | ⬜ Sin iniciar | 0/100 | Media | 3 | 93 | — | — | — |
| 95 | Monetización | ⬜ Sin iniciar | 0/100 | Media | 3 | 38 | — | — | — |
| 96 | Plataformas | ⬜ Sin iniciar | 0/100 | Media | 3 | 04 | — | — | — |
| 97 | Steam / Store Page | 🟢 Disponible | 195/195 | Alta | 3 | 96 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 6, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 98 | Trailer | ⬜ Sin iniciar | 0/100 | Media | 2 | 97 | — | — | — |
| 99 | Marketing | ⬜ Sin iniciar | 0/100 | Media | 3 | 97 | — | — | — |
| 100 | Community Management | ⬜ Sin iniciar | 0/100 | Baja | 2 | 99 | — | — | — |
| 101 | QA General | 🟢 Disponible | 205/205 | Alta | 3 | 110 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 6, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 102 | Bug Tracking | 🟢 Disponible | 140/140 | Media | 1 | 101 | — | 2026-08-16 17:20:00 | Documentación completa por Devin: GitHub Issues con plantilla, categorías, severidades, flujo de trabajo e integración con QA/Logging/Debug Menu |
| 103 | Logging | 🟢 Disponible | 157/157 | Media | 2 | 04 | — | 2026-08-16 17:50:00 | Documentación completa por Devin: Servicio Logger con niveles, categorías, rotación, sanitización de datos sensibles, exportación e integración con Bug Tracking/Debug Menu/Crash Reporting |
| 104 | Analytics | 🟢 Disponible | 100/100 | Baja | 2 | 103 | — | 2026-08-17 | Documentación completa por Nemotron 3.5 (B1). Conteo real verificado por Deepseek V4 Flash (2026-08-17): 100 ítems. DELEGABLE PARA IMPLEMENTAR |
| 105 | Telemetría de Gameplay | ⬜ Sin iniciar | 0/100 | Baja | 2 | 104 | — | — | — |
| 106 | Seguridad | ⬜ Sin iniciar | 0/100 | Baja | 2 | 77 | — | — | — |
| 107 | Backups | 🟢 Disponible | 176/176 | Alta | 1 | 59 | — | 2026-08-16 18:50:00 | Documentación completa por Devin: Estrategia 3-2-1 (GitHub + Cloud + Disco Externo), automatización con GitHub Actions y Task Scheduler, verificación de integridad SHA-256, política de retención y plan de recuperación de desastres |
| 108 | Pipeline de Assets | 🟢 Disponible | 181/181 | Alta | 3 | 45 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 6, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 109 | Herramientas Internas | ⬜ Sin iniciar | 0/100 | Media | 3 | 04 | — | — | — |
| 110 | Debug Menu | 🟢 Disponible | 222/222 | Media | 1 | 04 | — | 2026-08-16 19:50:00 | Documentación completa por Devin: Debug Menu in-game con 5 paneles, funciones de teletransporte/tiempo/clima/objetos/misiones, visualizaciones debug (colliders, FPS, chunks, navegación, hitboxes, IA), consola in-game con filtros y exportador de diagnóstico integrado con Bug Tracking |
| 111 | Código de Calidad | 🟢 Disponible | 209/209 | Alta | 2 | 04 | — | 2026-08-16 20:30:00 | Documentación completa por Devin: Se especificó guía de estilo GDScript completa con convenciones de nomenclatura (PascalCase, snake_case, UPPER_CASE). Se definieron límites de tamaño: 50 líneas método, 300 líneas clase, 500 líneas archivo. Se diseñaron plantillas de documentación para clases y funciones. Se especificaron interfaces recomendadas (IInteractable, IDamageable, ISaveable). Se diseñaron patrones de diseño (State Machine, Observer, Factory, Command). Se diseñaron utilidades comunes (MathUtils, ValidationUtils, FormatUtils). Se diseñaron constantes, enums y structs del proyecto. Se especificó proceso de code review con checklist de 16 ítems. Se diseñó registro de deuda técnica con prioridades (Alta, Media, Baja). Se diseñó script de análisis estático CodeQualityCheck. Se integró con M07 (Arquitectura), M112 (Testing), M61 (Rendimiento), M62 (Memoria), M133 (Gestión del Proyecto). Se aplicaron principios SOLID. Se definieron code smells a evitar. Se especificaron buenas prácticas de seguridad, performance, memory management, multi-threading, optimización de assets. Se diseñó checklist de calidad por commit. Se especificaron sprints técnicos de refactorización. Se definieron 8 reglas de calidad obligatorias. |
| 112 | Testing Automático | 🟢 Disponible | 230/230 | Alta | 3 | 111 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 5, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 113 | Pruebas de Stress | ⬜ Sin iniciar | 0/100 | Media | 3 | 112 | — | — | — |
| 114 | Playtest | 🟢 Disponible | 186/186 | Alta | 3 | 101, 137 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 6, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 115 | Hardware | ⬜ Sin iniciar | 0/100 | Media | 2 | 96 | — | — | — |
| 116 | Instalador | ⬜ Sin iniciar | 0/100 | Baja | 1 | 116 | — | — | — |
| 117 | Build System | ⬜ Sin iniciar | 0/100 | Media | 3 | 116 | — | — | — |
| 118 | CI/CD | 🟢 Disponible | 100/100 | Baja | 2 | 117 | — | 2026-08-17 | Documentación completa por Nemotron 3.5 (B1). Conteo real verificado por Deepseek V4 Flash (2026-08-17): 100 ítems. DELEGABLE PARA IMPLEMENTAR |
| 119 | Actualizaciones | ⬜ Sin iniciar | 0/100 | Media | 2 | 117, 59 | — | — | — |
| 120 | DLC y Expansiones | ⬜ Sin iniciar | 0/100 | Baja | 2 | 95, 142 | — | — | — |
| 121 | Soporte Post-Lanzamiento | ⬜ Sin iniciar | 0/100 | Baja | 2 | 142 | — | — | — |
| 122 | Crash Reporting | 🟢 Disponible | 259/259 | Baja | 1 | 103 | — | 2026-08-16 21:30:00 | Documentación completa por Devin: Se seleccionó Crashlytics (Firebase) como servicio externo principal con Sentry como fallback. Se diseñó CrashReporter como servicio principal con captura automática de crashes. Se diseñó MetadataCollector para recolectar información de hardware, software y contexto del juego. Se diseñó ContextSanitizer para sanitizar contexto y no enviar datos personales (cumplimiento GDPR). Se diseñó CrashCache para caché offline cuando no hay conexión. Se diseñó CrashSender para enviar crashes a servicio externo. Se diseñó CrashDashboard para visualizar crashes y estadísticas. Se diseñó integración con M103 (Logging) para loggear crashes como CRITICAL. Se diseñó integración con M102 (Bug Tracking) para crear issues automáticamente por crashes críticos. Se diseñó integración con M110 (Debug Menu) para agregar panel de "Diagnostics". Se diseñó sistema de priorización de crashes (matriz de frecuencia, severidad, impacto). Se diseñó workflow de corrección de crashes (identificar → reproducir → corregir → testear → desplegar). Se diseñó builds de diagnóstico con logs adicionales, asserts, símbolos de debug. Se diseñó alertas automáticas para crashes críticos y de alta frecuencia. Se especificó política de opt-out del usuario y cumplimiento GDPR. Se especificó política de retención de datos (90 días). |
| 123 | Modding | ⬜ Sin iniciar | 0/100 | Baja | 5 | 117 | — | — | Opcional muy a futuro |
| 124 | Contenido Generado por Usuarios | ⬜ Sin iniciar | 0/100 | Baja | 3 | 123 | — | — | — |
| 125 | Términos de Servicio | ⬜ Sin iniciar | 0/100 | Baja | 1 | 78 | — | — | — |
| 126 | Marketing Legal | ⬜ Sin iniciar | 0/100 | Baja | 1 | 78 | — | — | — |
| 127 | Copyright del Juego | ⬜ Sin iniciar | 0/100 | Baja | 1 | 78 | — | — | — |
| 128 | Identidad de Marca | ⬜ Sin iniciar | 0/100 | Media | 2 | 78, 97 | — | — | — |
| 129 | Merchandising | ⬜ Sin iniciar | 0/100 | Baja | 1 | 142 | — | — | — |
| 131 | Créditos | 🟢 Disponible | 100/100 | Media | 1 | 142 | — | 2026-08-17 | Documentación completa por Nemotron 3.5 (B1). Checklist alineado por Deepseek V4 Flash (2026-08-17, conteo real 100). DELEGABLE PARA IMPLEMENTAR |
| 132 | Producción del Equipo | ⬜ Sin iniciar | 0/100 | Media | 1 | 134 | — | — | — |
| 133 | Gestión del Proyecto | 🟢 Disponible | 127/127 | Alta | 2 | 01 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 5, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 134 | Presupuesto | ⬜ Sin iniciar | 0/100 | Media | 2 | 133 | — | — | — |
| 135 | Riesgos del Proyecto | 🟢 Disponible | 134/134 | Alta | 2 | 133 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 5, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 136 | Roadmap | 🟢 Disponible | 199/199 | Alta | 2 | 133, 135 | — | 2026-08-17 | Documentación completa por Deepseek V4 Flash (tanda 6, 2026-08-17). DELEGABLE PARA IMPLEMENTAR |
| 137 | Prototipo | ⬜ Sin iniciar | 0/100 | Alta | 5 | 08, 11, 14, 59 | — | — | Hito crítico de preproducción |
| 138 | Vertical Slice | ⬜ Sin iniciar | 0/100 | Alta | 5 | 137, 26, 19 | — | — | — |
| 139 | Pre-Alpha | ⬜ Sin iniciar | 0/100 | Alta | 5 | 138 | — | — | — |
| 140 | Alpha | ⬜ Sin iniciar | 0/100 | Alta | 5 | 139 | — | — | — |
| 141 | Beta | ⬜ Sin iniciar | 0/100 | Alta | 5 | 140 | — | — | — |
| 142 | Release Candidate | ⬜ Sin iniciar | 0/100 | Alta | 5 | 141 | — | — | — |
| 143 | Lanzamiento | ⬜ Sin iniciar | 0/100 | Alta | 5 | 142, 97 | — | — | — |
| 144 | Después del Lanzamiento | ⬜ Sin iniciar | 0/100 | Media | 3 | 143 | — | — | — |
| 145 | Diseño de Experiencia | ⬜ Sin iniciar | 0/100 | Media | 2 | 01 | — | — | — |
| 146 | Diseño Emocional | ⬜ Sin iniciar | 0/100 | Media | 2 | 145 | — | — | — |
| 147 | World Building | ⬜ Sin iniciar | 0/100 | Alta | 4 | 22 | — | — | — |
| 148 | Lore Ambiental | ⬜ Sin iniciar | 0/100 | Media | 3 | 147, 24 | — | — | — |
| 149 | Nombres y Nomenclatura | ⬜ Sin iniciar | 0/100 | Media | 2 | 147 | — | — | — |
| 150 | Diseño Sonoro Narrativo | ⬜ Sin iniciar | 0/100 | Baja | 2 | 149 | — | — | — |
| 151 | Control Final | ⬜ Sin iniciar | 0/100 | Alta | 3 | 143 | — | — | — |
| 152 | Principios Innegociables | 🟢 Disponible | 202/202 | Alta | 1 | 01 | — | 2026-08-16 22:30:00 | Documentación completa por Devin: Se definieron principios de filosofía cozy (sin FOMO, sin castigos irreversibles, eventos repetibles, herramientas que no desaparecen, guardados confiables). Se definieron principios de diseño de juego (combate opcional, sistema de hambre no castigador, ritmo de juego accesible, sin metagaming forzado, variedad de NPCs, balance procedural vs curado, puzzles lógicos, información accesible, economía cozy). Se definieron principios técnicos (performance prioridad sobre visuals, sistemas con propósito, calidad > cantidad, profundidad > cantidad, offline-first, licencias claras de assets, knowledge sharing). Se diseñó proceso de revisión contra principios con checklist de 8 ítems. Se diseñó registro de desviaciones justificadas. Se especificó integración con todos los módulos de diseño e implementación. Se diseñó documentación de principios (README, filosofia_cozy, diseno_juego, tecnicos, proceso_revision, desviaciones_justificadas). Se diseñó documento de licencias de assets. Se diseñó documento de knowledge sharing. Se especificaron métricas de cumplimiento. Se especificó revisión periódica de principios (cada 3 meses). Se proporcionaron ejemplos de aplicación de principios. |
| 153 | Objetivo Final del Proyecto | 🔵 En curso | 0/120 | Alta | 2 | 151 | B2-Composer | 2026-08-16 17:35 | Documentación transversal en preparación |

## Simbología de Estados

| Estado | Significado |
|--------|-------------|
| `⬜` | Sin iniciar |
| `🟢` | Disponible (puede ser reclamado) |
| `🔵` | **En curso** (bloqueado por un agente, avanzando normal) |
| `🔴` | **En curso con riesgo** (posiblemente atascado; si no hay actividad en 24h otro agente puede reclamarlo) |
| `🟡` | **Con dudas** (bloqueado liberado con `?` pendientes, retomable) |
| `✅` | Completado (todos los subitems resueltos, debe pasar QA cruzado) |

## Resumen del Proyecto

- **Total de módulos:** 153 (01 + los 152 del plan inicial)
- **Completados (`✅`):** 0 (ninguno tiene código implementado ni QA cruzado; los documentados son DELEGABLES)
- **En curso (`🔵`):** 3 (01-Fundamentos, 61-Rendimiento por GPT-5, 153-Objetivo Final por B2-Composer)
- **En riesgo (`🔴`):** 0
- **Con dudas (`🟡`):** 0
- **Disponibles (`🟢`):** 74 (73 con documentación completa por DeepSeek/Devin/Nemotron + 04 y 06 parciales)
- **Sin iniciar (`⬜`):** 75
- **Progreso total:** documentación de diseño de 51 módulos completada; implementación de código pendiente en todos los módulos (se marcará `✅` solo con DoD: código + testings + logs + QA)

> **Nota:** los 152 módulos de la tabla corresponden a las 152 secciones de `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md`. Cada uno se creará como componente propio con checklist de ≥100 ítems.

> **Actualización 2026-08-17 (Deepseek V4 Flash):** se corrigieron progresos inflados (conteos reales de plan-actual), caracteres `` de filas Devin y se marcaron las filas B1 (69, 104, 118, 131) como documentadas pero con checklist sin marcar.

> **Tanda 7 (2026-08-17, Deepseek V4 Flash):** se integraron los módulos 39, 40, 54, 72, 74, 87 (documentados en la sesión anterior, quedaron sin commitear). M72 liberado de la ruta de B2-Composer (ya documentado).