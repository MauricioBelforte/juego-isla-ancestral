# CHECKLIST-GLOBAL.md — Orquestador Multiagente

> **Modelo:** Deepseek V4 Flash
> **Plataforma:** OpenCode
> **Fecha:** 2026-08-15

Este archivo es la **única fuente de verdad** sobre el estado global del proyecto. Contiene la **tabla resumen** con UNA fila por módulo. Los subitems detallados viven en `DOCUMENTACION/{NN}-Modulo/plan-actual/05-Checklist.md` de cada módulo.

> ⚠️ **Puede ser generado por script.** Las columnas `Estado` y `Progreso` se recalculan automáticamente según los `05-Checklist.md`. Las columnas manuales (`Prioridad`, `Complejidad`, `Dependencias`, `Agente actual`, `Última actividad`, `Notas`) se **preservan** de la versión anterior si el módulo ya existía. Ver sección 21.9 del `AGENTS.md`.

## Especificación del Protocolo

Ver sección 21 del `AGENTS.md` para el flujo completo (incluye QA cruzado, DoD y herramientas de automatización).

## Tabla Resumen de Módulos

| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | Agente actual | Última actividad | Notas |
|----|--------|--------|----------|-----------|-------------|--------------|---------------|------------------|-------|
| 01 | Fundamentos del Proyecto | 🔵 En curso | 0/152 | Alta | 4 | — | DEEPSEEK V4 FLASH | 2026-08-15 | Base documental creada (5 archivos + checklist de 152 módulos). Pendiente: desglosar módulos 02-152 |
| 02 | Visión y Concepto | 🟢 Disponible | 162/172 | Alta | 2 | 01 | — | 2026-08-15 | Documentación completa por DEEPSEEK V4 FLASH (5 archivos + checklist 172 ítems). 10 pendientes con dueño externo (M02 legal, QA, Publicación) — ver Notas del Agente en plan-actual/04-Codigo.md |
| 03 | Documentación del Proyecto | 🟢 Disponible | 133/133 | Alta | 2 | 01 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: catálogo 25 docs con dueño, convenciones, hitos M1-M5, roadmap, 5 esqueletos *-ACTUAL.md. Contenido substantivo en módulos dueños |
| 04 | Game Engine | 🟢 Disponible | 94/120 | Alta | 5 | 01 | — | 2026-08-16 | Decisión adoptada: Godot 4.x + Voxel Tools (Plan-prod §2). Pendientes: instalación y proyecto base → hito M1. Confirmación final del usuario |
| 05 | Lenguaje y Programación | 🟢 Disponible | 102/102 | Alta | 3 | 04 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: GDScript adoptado, convenciones, patrones transversales (EventBus, GameClock, Logger), guía anti-patterns |
| 06 | Control de Versiones | 🟢 Disponible | 91/92 | Media | 1 | 01 | — | 2026-08-16 | Documentación completa por DEEPSEEK V4 FLASH: ramas, semver, auto-revisión, CHANGELOG.md creado. Pendiente: protección rama (Publicación) |
| 07 | Arquitectura General | ⬜ Sin iniciar | 0/100 | Alta | 5 | 04 | — | — | — |
| 08 | Mundo Voxel | ⬜ Sin iniciar | 0/100 | Alta | 5 | 07 | — | — | Mayor riesgo técnico del proyecto |
| 09 | Terreno y Geografía | ⬜ Sin iniciar | 0/100 | Alta | 4 | 08 | — | — | — |
| 10 | Generación del Mundo | ⬜ Sin iniciar | 0/100 | Alta | 5 | 08 | — | — | — |
| 11 | Personaje del Jugador | ⬜ Sin iniciar | 0/100 | Alta | 3 | 07 | — | — | — |
| 12 | Cámara | ⬜ Sin iniciar | 0/100 | Alta | 2 | 11 | — | — | — |
| 13 | Herramientas | ⬜ Sin iniciar | 0/100 | Alta | 4 | 11 | — | — | — |
| 14 | Inventario | ⬜ Sin iniciar | 0/100 | Alta | 3 | 11 | — | — | — |
| 15 | Recursos | ⬜ Sin iniciar | 0/100 | Alta | 3 | 14 | — | — | — |
| 16 | Crafting | ⬜ Sin iniciar | 0/100 | Alta | 3 | 14, 15 | — | — | — |
| 17 | Construcción | ⬜ Sin iniciar | 0/100 | Alta | 5 | 08, 14 | — | — | — |
| 18 | Casas | ⬜ Sin iniciar | 0/100 | Media | 3 | 17 | — | — | — |
| 19 | NPC y Vecinos | ⬜ Sin iniciar | 0/100 | Alta | 4 | 11, 25 | — | — | — |
| 20 | Sistema de Amistad | ⬜ Sin iniciar | 0/100 | Media | 3 | 19 | — | — | — |
| 21 | Diálogos | ⬜ Sin iniciar | 0/100 | Alta | 4 | 19 | — | — | — |
| 22 | Historia Principal | ⬜ Sin iniciar | 0/100 | Alta | 4 | 21, 28 | — | — | — |
| 23 | Historias Secundarias | ⬜ Sin iniciar | 0/100 | Media | 3 | 22 | — | — | — |
| 24 | Templos y Puzzles | ⬜ Sin iniciar | 0/100 | Alta | 5 | 13 | — | — | Framework emisor→receptor |
| 25 | Ruinas | ⬜ Sin iniciar | 0/100 | Media | 3 | 24 | — | — | — |
| 26 | Templo Subterráneo | ⬜ Sin iniciar | 0/100 | Alta | 4 | 24, 25 | — | — | Templo de la Brisa |
| 27 | Islas del Mundo | ⬜ Sin iniciar | 0/100 | Media | 4 | 28, 29 | — | — | — |
| 28 | Viajes | ⬜ Sin iniciar | 0/100 | Media | 3 | 22, 27 | — | — | Gran Vapor |
| 29 | Tiempo y Calendario | ⬜ Sin iniciar | 0/100 | Alta | 3 | 07 | — | — | — |
| 30 | Reloj en Tiempo Real | ⬜ Sin iniciar | 0/100 | Media | 3 | 29 | — | — | — |
| 31 | Ciclo Día/Noche | ⬜ Sin iniciar | 0/100 | Media | 3 | 29 | — | — | — |
| 32 | Clima | ⬜ Sin iniciar | 0/100 | Media | 3 | 29, 31 | — | — | — |
| 33 | Agricultura | ⬜ Sin iniciar | 0/100 | Media | 3 | 17, 29 | — | — | — |
| 34 | Pesca | ⬜ Sin iniciar | 0/100 | Media | 3 | 32 | — | — | — |
| 35 | Minería | ⬜ Sin iniciar | 0/100 | Media | 3 | 08, 13 | — | — | — |
| 36 | Fauna | ⬜ Sin iniciar | 0/100 | Media | 3 | 07, 31 | — | — | — |
| 37 | Museos y Colecciones | ⬜ Sin iniciar | 0/100 | Baja | 3 | 36 | — | — | — |
| 38 | Economía | ⬜ Sin iniciar | 0/100 | Alta | 4 | 15, 16, 20 | — | — | — |
| 39 | Tiendas | ⬜ Sin iniciar | 0/100 | Media | 3 | 38 | — | — | — |
| 40 | Infraestructura | ⬜ Sin iniciar | 0/100 | Media | 3 | 38 | — | — | — |
| 41 | Música | ⬜ Sin iniciar | 0/100 | Media | 4 | — | — | — | — |
| 42 | Sonido Ambiental | ⬜ Sin iniciar | 0/100 | Media | 3 | 41 | — | — | — |
| 43 | Efectos de Sonido | ⬜ Sin iniciar | 0/100 | Media | 3 | 41 | — | — | — |
| 44 | ASMR y Feedback | ⬜ Sin iniciar | 0/100 | Media | 3 | 43 | — | — | — |
| 45 | Arte 3D | ⬜ Sin iniciar | 0/100 | Alta | 5 | — | — | — | — |
| 46 | Arte 2D | ⬜ Sin iniciar | 0/100 | Media | 3 | 45 | — | — | — |
| 47 | Texturas y Materiales | ⬜ Sin iniciar | 0/100 | Media | 3 | 45 | — | — | — |
| 48 | Animación | ⬜ Sin iniciar | 0/100 | Media | 4 | 45, 11, 19 | — | — | — |
| 49 | Iluminación | ⬜ Sin iniciar | 0/100 | Media | 3 | 07, 45 | — | — | — |
| 50 | Vegetación | ⬜ Sin iniciar | 0/100 | Media | 3 | 08, 45 | — | — | — |
| 51 | Agua | ⬜ Sin iniciar | 0/100 | Media | 4 | 08, 24 | — | — | — |
| 52 | Partículas y VFX | ⬜ Sin iniciar | 0/100 | Media | 3 | 45 | — | — | — |
| 53 | UI/UX | ⬜ Sin iniciar | 0/100 | Alta | 4 | 11, 14 | — | — | — |
| 54 | Mapa | ⬜ Sin iniciar | 0/100 | Media | 3 | 53 | — | — | — |
| 55 | Diario del Jugador | ⬜ Sin iniciar | 0/100 | Baja | 3 | 53 | — | — | — |
| 56 | Fotografía | ⬜ Sin iniciar | 0/100 | Baja | 2 | 53 | — | — | — |
| 57 | Interfaz de Control | ⬜ Sin iniciar | 0/100 | Alta | 2 | 04 | — | — | — |
| 58 | Accesibilidad | ⬜ Sin iniciar | 0/100 | Alta | 3 | 53, 57 | — | — | — |
| 59 | Guardado | ⬜ Sin iniciar | 0/100 | Alta | 5 | 07, 14 | — | — | GameState versionado |
| 60 | Datos y Serialización | ⬜ Sin iniciar | 0/100 | Alta | 3 | 59 | — | — | — |
| 61 | Rendimiento | ⬜ Sin iniciar | 0/100 | Alta | 5 | 08, 49 | — | — | — |
| 62 | Memoria | ⬜ Sin iniciar | 0/100 | Alta | 3 | 61 | — | — | — |
| 63 | Cargas y Streaming | ⬜ Sin iniciar | 0/100 | Alta | 4 | 08, 61 | — | — | — |
| 64 | IA de NPC | ⬜ Sin iniciar | 0/100 | Alta | 5 | 19, 61 | — | — | — |
| 65 | Animales IA | ⬜ Sin iniciar | 0/100 | Media | 3 | 36, 64 | — | — | — |
| 66 | Anti-Softlock | ⬜ Sin iniciar | 0/100 | Alta | 3 | 22, 26 | — | — | — |
| 67 | Vehículos | ⬜ Sin iniciar | 0/100 | Baja | 3 | 28 | — | — | — |
| 68 | Transporte y Navegación | ⬜ Sin iniciar | 0/100 | Baja | 3 | 28, 67 | — | — | — |
| 69 | Fast Travel | ⬜ Sin iniciar | 0/100 | Baja | 1 | 28 | — | — | — |
| 70 | Interacciones | ⬜ Sin iniciar | 0/100 | Alta | 3 | 11, 13 | — | — | — |
| 71 | Progresión | ⬜ Sin iniciar | 0/100 | Alta | 3 | 22, 38 | — | — | — |
| 72 | Sistema de Logros | ⬜ Sin iniciar | 0/100 | Media | 2 | 71 | — | — | — |
| 73 | Coleccionables | ⬜ Sin iniciar | 0/100 | Media | 3 | 71, 36 | — | — | — |
| 74 | Eventos | ⬜ Sin iniciar | 0/100 | Media | 3 | 30, 29 | — | — | — |
| 75 | Postgame | ⬜ Sin iniciar | 0/100 | Baja | 3 | 22 | — | — | — |
| 76 | Multijugador | ⬜ Sin iniciar | 0/100 | Baja | 5 | — | — | — | Decisión pendiente |
| 77 | Online y Red | ⬜ Sin iniciar | 0/100 | Baja | 5 | 76 | — | — | — |
| 78 | Legal — Propiedad Intelectual | ⬜ Sin iniciar | 0/100 | Alta | 2 | 01 | — | — | — |
| 79 | Legal — Contratos | ⬜ Sin iniciar | 0/100 | Media | 2 | 78 | — | — | — |
| 80 | Legal — Privacidad | ⬜ Sin iniciar | 0/100 | Alta | 2 | 78 | — | — | — |
| 81 | Legal — Menores | ⬜ Sin iniciar | 0/100 | Media | 2 | 80 | — | — | — |
| 82 | Clasificación por Edades | ⬜ Sin iniciar | 0/100 | Media | 1 | 78 | — | — | IARC |
| 83 | Licencias de Software | ⬜ Sin iniciar | 0/100 | Media | 2 | 78 | — | — | — |
| 84 | Música y Audio — Legal | ⬜ Sin iniciar | 0/100 | Media | 2 | 41, 78 | — | — | — |
| 85 | Modelos 3D — Legal | ⬜ Sin iniciar | 0/100 | Media | 2 | 45, 78 | — | — | — |
| 86 | IA Generativa | ⬜ Sin iniciar | 0/100 | Alta | 3 | 78 | — | — | Declaración Steam |
| 87 | Localización | ⬜ Sin iniciar | 0/100 | Media | 3 | 21, 53 | — | — | — |
| 88 | Fuentes Tipográficas | ⬜ Sin iniciar | 0/100 | Baja | 1 | 53 | — | — | — |
| 89 | Diseño de Menús | ⬜ Sin iniciar | 0/100 | Media | 3 | 53 | — | — | — |
| 90 | Configuración Gráfica | ⬜ Sin iniciar | 0/100 | Media | 1 | 53 | — | — | — |
| 91 | Configuración de Audio | ⬜ Sin iniciar | 0/100 | Media | 1 | 53 | — | — | — |
| 92 | Tutorial | ⬜ Sin iniciar | 0/100 | Alta | 3 | 53, 70 | — | — | — |
| 93 | Balance | ⬜ Sin iniciar | 0/100 | Alta | 4 | 38, 20 | — | — | — |
| 94 | Retención sin FOMO | ⬜ Sin iniciar | 0/100 | Media | 3 | 93 | — | — | — |
| 95 | Monetización | ⬜ Sin iniciar | 0/100 | Media | 3 | 38 | — | — | — |
| 96 | Plataformas | ⬜ Sin iniciar | 0/100 | Media | 3 | 04 | — | — | — |
| 97 | Steam / Store Page | ⬜ Sin iniciar | 0/100 | Alta | 3 | 96 | — | — | — |
| 98 | Trailer | ⬜ Sin iniciar | 0/100 | Media | 2 | 97 | — | — | — |
| 99 | Marketing | ⬜ Sin iniciar | 0/100 | Media | 3 | 97 | — | — | — |
| 100 | Community Management | ⬜ Sin iniciar | 0/100 | Baja | 2 | 99 | — | — | — |
| 101 | QA General | ⬜ Sin iniciar | 0/100 | Alta | 3 | 110 | — | — | — |
| 102 | Bug Tracking | ⬜ Sin iniciar | 0/100 | Media | 1 | 101 | — | — | — |
| 103 | Logging | ⬜ Sin iniciar | 0/100 | Media | 2 | 04 | — | — | — |
| 104 | Analytics | ⬜ Sin iniciar | 0/100 | Baja | 2 | 103 | — | — | — |
| 105 | Telemetría de Gameplay | ⬜ Sin iniciar | 0/100 | Baja | 2 | 104 | — | — | — |
| 106 | Seguridad | ⬜ Sin iniciar | 0/100 | Baja | 2 | 77 | — | — | — |
| 107 | Backups | ⬜ Sin iniciar | 0/100 | Alta | 1 | 59 | — | — | — |
| 108 | Pipeline de Assets | ⬜ Sin iniciar | 0/100 | Alta | 3 | 45 | — | — | — |
| 109 | Herramientas Internas | ⬜ Sin iniciar | 0/100 | Media | 3 | 04 | — | — | — |
| 110 | Debug Menu | ⬜ Sin iniciar | 0/100 | Media | 1 | 04 | — | — | — |
| 111 | Código de Calidad | ⬜ Sin iniciar | 0/100 | Alta | 2 | 04 | — | — | — |
| 112 | Testing Automático | ⬜ Sin iniciar | 0/100 | Alta | 3 | 111 | — | — | — |
| 113 | Pruebas de Stress | ⬜ Sin iniciar | 0/100 | Media | 3 | 112 | — | — | — |
| 114 | Playtest | ⬜ Sin iniciar | 0/100 | Alta | 3 | 101, 137 | — | — | — |
| 115 | Hardware | ⬜ Sin iniciar | 0/100 | Media | 2 | 96 | — | — | — |
| 116 | Instalador | ⬜ Sin iniciar | 0/100 | Baja | 1 | 116 | — | — | — |
| 117 | Build System | ⬜ Sin iniciar | 0/100 | Media | 3 | 116 | — | — | — |
| 118 | CI/CD | ⬜ Sin iniciar | 0/100 | Baja | 2 | 117 | — | — | — |
| 119 | Actualizaciones | ⬜ Sin iniciar | 0/100 | Media | 2 | 117, 59 | — | — | — |
| 120 | DLC y Expansiones | ⬜ Sin iniciar | 0/100 | Baja | 2 | 95, 142 | — | — | — |
| 121 | Soporte Post-Lanzamiento | ⬜ Sin iniciar | 0/100 | Baja | 2 | 142 | — | — | — |
| 122 | Crash Reporting | ⬜ Sin iniciar | 0/100 | Baja | 1 | 103 | — | — | — |
| 123 | Modding | ⬜ Sin iniciar | 0/100 | Baja | 5 | 117 | — | — | Opcional muy a futuro |
| 124 | Contenido Generado por Usuarios | ⬜ Sin iniciar | 0/100 | Baja | 3 | 123 | — | — | — |
| 125 | Términos de Servicio | ⬜ Sin iniciar | 0/100 | Baja | 1 | 78 | — | — | — |
| 126 | Marketing Legal | ⬜ Sin iniciar | 0/100 | Baja | 1 | 78 | — | — | — |
| 127 | Copyright del Juego | ⬜ Sin iniciar | 0/100 | Baja | 1 | 78 | — | — | — |
| 128 | Identidad de Marca | ⬜ Sin iniciar | 0/100 | Media | 2 | 78, 97 | — | — | — |
| 129 | Merchandising | ⬜ Sin iniciar | 0/100 | Baja | 1 | 142 | — | — | — |
| 130 | Artbook | ⬜ Sin iniciar | 0/100 | Baja | 2 | 142 | — | — | — |
| 131 | Créditos | ⬜ Sin iniciar | 0/100 | Media | 1 | 142 | — | — | — |
| 132 | Producción del Equipo | ⬜ Sin iniciar | 0/100 | Media | 1 | 134 | — | — | — |
| 133 | Gestión del Proyecto | ⬜ Sin iniciar | 0/100 | Alta | 2 | 01 | — | — | — |
| 134 | Presupuesto | ⬜ Sin iniciar | 0/100 | Media | 2 | 133 | — | — | — |
| 135 | Riesgos del Proyecto | ⬜ Sin iniciar | 0/100 | Alta | 2 | 133 | — | — | — |
| 136 | Roadmap | ⬜ Sin iniciar | 0/100 | Alta | 2 | 133, 135 | — | — | — |
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
| 152 | Principios Innegociables | ⬜ Sin iniciar | 0/100 | Alta | 1 | 01 | — | — | — |
| 153 | Objetivo Final del Proyecto | ⬜ Sin iniciar | 0/100 | Alta | 2 | 151 | — | — | — |

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
- **Completados (`✅`):** 0
- **En curso (`🔵`):** 1 (01-Fundamentos)
- **En riesgo (`🔴`):** 0
- **Con dudas (`🟡`):** 0
- **Disponibles (`🟢`):** 0
- **Sin iniciar (`⬜`):** 152
- **Progreso total:** base documental creada; desglose de módulos pendiente

> **Nota:** los 152 módulos de la tabla corresponden a las 152 secciones de `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md`. Cada uno se creará como componente propio con checklist de ≥100 ítems.