# 05-Checklist.md — CHECKLIST DEL PLAN INICIAL GENERICO (152 MÓDULOS)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-15
**Componente:** 01-Fundamentos-Del-Proyecto
**Estado:** Documentación inicial (plan genérico)

---

## Propósito

Esta checklist contiene los **152 módulos** extraídos del `Plan-inicial-minimo.md` (checklist maestro de 600+ puntos). **Cada ítem NO es una tarea simple: es un MÓDULO completo** que será desglosado en su propio componente `DOCUMENTACION/{NN}-Modulo/` con sus 5 archivos principales y una checklist propia de **no menos de 100 ítems** (regla del `AGENTS.md`, sección 3).

**Símbolos:** `[ ]` pendiente · `[x]` completado · `[?]` no resuelto
**Esfuerzo:** `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días)
**Prioridad para este proyecto:** 🔴 Alta / 🟡 Media / 🟢 Baja (asignada según impacto en v1.0)

---

## Módulos del Plan Inicial

### FASE 1 — FUNDAMENTOS

- [x] **M01** Visión y Concepto [M] 🔴 — definir nombre definitivo, pilares, pitch, alcance v1.0
- [x] **M02** Documentación del Proyecto [M] 🔴 — GDD, narrativa, sistemas, convenciones, backlog inicial
- [x] **M03** Game Engine [C] 🔴 — elegir Unity o Godot, fijar versión, configurar render pipeline e input
- [x] **M04** Lenguaje y Programación [M] 🔴 — C#/GDScript, convenciones, namespaces, arquitectura de software
- [x] **M05** Control de Versiones [S] 🟡 — Git, .gitignore, ramas, mensajes de commit, Git LFS
- [x] **M06** Arquitectura General [C] 🔴 — managers, eventos globales, modularidad, evitar GameManager monolítico

### FASE 2 — MUNDO Y TECNOLOGÍA CENTRAL

- [x] **M07** Mundo Voxel [C] 🔴 — chunking, face/greedy meshing, threading, LOD, colisiones por grilla
- [x] **M08** Terreno y Geografía [C] 🔴 — montañas, valles, ríos, playas, biomas de Aurora
- [x] **M09** Generación del Mundo [C] 🔴 — seed, generador de terreno/biomas/vegetación/minerales/cuevas
- [x] **M10** Personaje del Jugador [M] 🔴 — modelo 3D, animaciones, controlador, colisiones, interacción
- [x] **M11** Cámara [M] 🔴 — tercera persona cenital inclinada, zoom, clipping, sensibilidad configurable
- [x] **M12** Herramientas [C] 🔴 — pala, pico, hacha, gancho mecánico, lanza-semillas, vara de flujo (sin daño)
- [x] **M13** Inventario [M] 🔴 — slots, stacks, hotbar, cofres, transferencia rápida, peso
- [ ] **M14** Recursos [M] 🔴 — madera, piedra, arena, minerales, frutas, peces, rareza, respawn
- [x] **M15** Crafting [M] 🔴 — banco de trabajo, recetas, desbloqueos, preview, feedback
- [ ] **M16** Construcción [C] 🔴 — modo construcción/decoración, grid, snapping, rotación, demolición
- [x] **M17** Casas [M] 🟡 — parcelas, ampliaciones, habitaciones, muebles interactivos, almacenamiento

### FASE 3 — VIDA COMUNITARIA Y NARRATIVA

- [x] **M18** NPC y Vecinos [C] 🔴 — especies, personalidades, rutinas, horarios, hogares, relaciones
- [x] **M19** Sistema de Amistad [M] 🟡 — puntos de amistad, niveles, regalos, desbloqueos, eventos únicos
- [x] **M20** Diálogos [C] 🔴 — motor por nodos, flags narrativos, opciones, localización
- [ ] **M21** Historia Principal [C] 🔴 — prólogo, capítulos, Sellos, templos, finales y ritmo
- [ ] **M22** Historias Secundarias [M] 🟡 — arcos de vecinos, lugares, ruinas, objetos, postgame
- [ ] **M23** Templos y Puzzles [C] 🔴 — framework emisor→receptor, dificultad, pistas, checkpoints
- [ ] **M24** Ruinas [M] 🟡 — variantes pequeñas/medianas/grandes, inscripciones, pasajes ocultos
- [ ] **M25** Templo Subterráneo [C] 🔴 — Templo de la Brisa: entrada, tutorial, salas, cámara del Sello

### FASE 4 — MUNDO EXPANDIDO

- [x] **M26** Islas del Mundo [C] 🟡 — Isla de Coral, Verde, Cenizas, Cielo (diseño completo por isla)
- [x] **M27** Viajes [M] 🟡 — Gran Vapor, boletos, requisitos, pantalla de viaje diegética
- [x] **M28** Tiempo y Calendario [M] 🔴 — día/noche, estaciones, festivales, cumpleaños, eventos
- [x] **M29** Reloj en Tiempo Real [M] 🟡 — Gran Vapor mensual, zona horaria, offline, anti-exploits
- [x] **M30** Ciclo Día/Noche [M] 🟡 — iluminación, cielo, estrellas, comportamiento de NPC y fauna
- [x] **M31** Clima [M] 🟡 — sol, lluvia, tormenta, niebla, nieve, transiciones, accesibilidad

### FASE 5 — ACTIVIDADES Y CONTENIDO

- [x] **M32** Agricultura [M] 🟡 — parcelas, semillas, riego, fertilizante, estaciones, plantas ancestrales
- [x] **M33** Pesca [M] 🟡 — especies, minijuego no frustrante, coleccionario, peces legendarios
- [x] **M34** Minería [M] 🟡 — vetas, profundidad, minerales ancestrales, derrumbes controlados
- [ ] **M35** Fauna [M] 🟡 — especies no hostiles, hábitat, migraciones, observación, ecosistemas
- [ ] **M36** Museos y Colecciones [M] 🟢 — salas, vitrinas, fósiles, porcentaje completado
- [ ] **M37** Economía [C] 🔴 — Gemas de Ámbar, Pases de Mérito, precios, sumideros, anti-exploits
- [ ] **M38** Tiendas [M] 🟡 — tienda general, muebles, ropa, vivero, rotación de stock
- [ ] **M39** Infraestructura [M] 🟡 — puentes, rampas, faro, puerto, plaza, proyectos de Finneas

### FASE 6 — ARTE, AUDIO Y PRESENTACIÓN

- [x] **M40** Música [C] 🟡 — acústica/lo-fi por bioma, leitmotifs, música adaptativa, loops
- [x] **M41** Sonido Ambiental [M] 🟡 — viento, agua, océano, cuevas, ruinas, mecanismos
- [x] **M42** Efectos de Sonido [M] 🟡 — pasos, herramientas, bloques, diálogo, menús, logros
- [x] **M43** ASMR y Feedback [M] 🟡 — sensaciones táctiles de picar/cosechar/construir, capas sonoras
- [x] **M44** Arte 3D [C] 🔴 — estilo cozy voxel redondeado, presupuesto de polígonos, LOD
- [x] **M45** Arte 2D [M] 🟡 — logo, iconos, UI, mapas, símbolos ancestrales, guías de estilo
- [x] **M46** Texturas y Materiales [M] 🟡 — tierra, césped, piedra, agua, variantes por bioma
- [x] **M47** Animación [C] 🟡 — jugador, NPC, fauna, vegetación, mecanismos, UI
- [x] **M48** Iluminación [M] 🟡 — URP/Forward+, GI suave, horaria, faroles, cuevas, optimización
- [x] **M49** Vegetación [M] 🟡 — hierba, árboles ancestrales, plantas luminosas, viento, instancing
- [x] **M50** Agua [C] 🟡 — océano, ríos, cascadas, congelamiento, evaporación, puzzles hidráulicos
- [x] **M51** Partículas y VFX [M] 🟡 — polvo, hojas, Resonancia, activación de runas, obtención de Sello

### FASE 7 — INTERFAZ Y EXPERIENCIA

- [x] **M52** UI/UX [C] 🔴 — HUD, menús, inventario, mapa, diario, calendario, tooltips
- [x] **M53** Mapa [M] 🟡 — mapa global, descubrimiento progresivo, marcadores, leyenda
- [x] **M54** Diario del Jugador [M] 🟢 — registro de personajes, pistas, Sellos, ruinas, fotografías
- [x] **M55** Fotografía [M] 🟢 — modo fotografía, filtros, álbum, galería
- [x] **M56** Interfaz de Control [M] 🔴 — teclado, ratón, gamepad, remapeo, Steam Deck
- [ ] **M57** Accesibilidad [M] 🔴 — daltonismo, subtítulos, texto ajustable, reducción de movimiento

### FASE 8 — PERSISTENCIA Y CALIDAD

- [x] **M58** Guardado [C] 🔴 — autosave, slots, GameState versionado, backups, recuperación
- [ ] **M59** Datos y Serialización [M] 🔴 — formato, IDs persistentes, versionado de schema, migraciones
- [x] **M60** Rendimiento [C] 🔴 — 60 FPS, presupuestos, profiling, culling, batching, instancing
- [x] **M61** Memoria [M] 🔴 — texturas, meshes, audio, streaming, memory leaks, sesiones largas
- [x] **M62** Cargas y Streaming [M] 🔴 — carga asíncrona, chunks cercanos, progreso real
- [x] **M63** IA de NPC [C] 🔴 — máquina de estados, rutinas, pathfinding sobre terreno modificable
- [ ] **M64** Animales IA [M] 🟡 — comportamiento no hostil, migraciones, spawn/despawn
- [ ] **M65** Anti-Softlock [M] 🔴 — recuperación de objetos clave, reinicio de puzzles, fallbacks
- [x] **M66** Vehículos [M] 🟢 — barco (y post-v1.0 submarino), física, cámara, docking
- [x] **M67** Transporte y Navegación [M] 🟢 — puerto, rutas, señalización, fast travel narrativo
- [x] **M68** Fast Travel [S] 🟢 — puntos de viaje, requisitos, anti-bypass de eventos

### FASE 9 — PROGRESIÓN Y CONTENIDO

- [ ] **M69** Interacciones [M] 🔴 — distancia, indicador, prioridad, contextuales, cancelación
- [ ] **M70** Progresión [M] 🔴 — narrativa, herramientas, construcción, social, islas, desbloqueos
- [ ] **M71** Sistema de Logros [M] 🟡 — básicos, exploración, social, colección, secretos
- [x] **M72** Coleccionables [M] 🟡 — reliquias, fragmentos, conchas, fósiles, documentos
- [ ] **M73** Eventos [M] 🟡 — festivales estacionales, llegada del vapor, eventos raros
- [x] **M74** Postgame [M] 🟢 — Era del Alba, nuevas islas, objetivos 100%, contenido libre

### FASE 10 — MULTIJUGADOR (decisión)

- [x] **M75** Multijugador [C] 🟢 — decidir local/online, cantidad, voz de diseño (post-v1.0)
- [x] **M76** Online y Red [C] 🟢 — cliente-servidor, sincronización, latencia, seguridad (post-v1.0)

### FASE 11 — LEGAL Y ADMINISTRACIÓN

- [ ] **M77** Legal — Propiedad Intelectual [M] 🔴 — marcas, autoría, licencias, terceros
- [ ] **M78** Legal — Contratos [M] 🟡 — freelancers, cesión de derechos, work-for-hire
- [ ] **M79** Legal — Privacidad [M] 🔴 — GDPR/COPPA, política de privacidad, consentimientos
- [ ] **M80** Legal — Menores [M] 🟡 — clasificación, controles parentales, contenido
- [ ] **M81** Clasificación por Edades [S] 🟡 — IARC/ESRB/PEGI (cero violencia → permisiva)
- [ ] **M82** Licencias de Software [M] 🟡 — engine, plugins, fuentes, librerías
- [ ] **M83** Música y Audio — Legal [M] 🟡 — derechos de reproducción, sincronización, ámbitos territoriales
- [ ] **M84** Modelos 3D — Legal [M] 🟡 — licencias de cada modelo, atribución, registro
- [ ] **M85** IA Generativa [M] 🔴 — política de IA, declaración Steam, qué delegar y qué no

### FASE 12 — PLATAFORMA Y MARKETING

- [ ] **M86** Localización [M] 🟡 — idioma base, claves, tablas, QA lingüístico
- [x] **M87** Fuentes Tipográficas [S] 🟢 — fuente principal/secundaria, licencia, tildes y ñ
- [ ] **M88** Diseño de Menús [M] 🟡 — principal, pausa, inventario, ajustes, créditos
- [x] **M89** Configuración Gráfica [S] 🟡 — resolución, calidad, VSync, FPS, presets
- [x] **M90** Configuración de Audio [S] 🟡 — volúmenes independientes, rango dinámico
- [ ] **M91** Tutorial [M] 🔴 — movimiento, cámara, recolección, construcción, progresivo
- [ ] **M92** Balance [C] 🔴 — precios, recompensas, crafting, amistad, simulación económica
- [ ] **M93** Retención sin FOMO [M] 🟡 — objetivos diarios/semanales, sin castigos por ausencia
- [ ] **M94** Monetización [M] 🟡 — premium, DLC de islas vs contenido gratis, precio
- [ ] **M95** Plataformas [M] 🟡 — PC/Steam prioritario, Steam Deck, EGS/GOG a evaluar
- [ ] **M96** Steam / Store Page [M] 🔴 — página, capsule art, capturas, trailer, wishlists
- [ ] **M97** Trailer [M] 🟡 — teaser, gameplay, lanzamiento
- [ ] **M98** Marketing [M] 🟡 — identidad, redes, devlogs, press kit, Next Fest
- [ ] **M99** Community Management [M] 🟢 — Discord, reglas, feedback, FAQ

### FASE 13 — QA Y DESARROLLO

- [ ] **M100** QA General [M] 🔴 — funcional, regresión, rendimiento, guardado, UI, audio
- [x] **M101** Bug Tracking [S] 🟡 — herramienta, categorías, severidades, reproducción
- [x] **M102** Logging [M] 🟡 — niveles, rotación, crash reporting, exportación
- [ ] **M103** Analytics [M] 🟢 — eventos, sesiones, anonimización, dashboard
- [ ] **M104** Telemetría de Gameplay [M] 🟢 — tutorías, abandono de puzzles, zonas ignoradas
- [ ] **M105** Seguridad [M] 🟢 — APIs, claves, validación, anti-manipulación (si online)
- [x] **M106** Backups [S] 🔴 — repositorio, assets, documentación, builds, restauración
- [ ] **M107** Pipeline de Assets [M] 🔴 — naming, carpetas, formatos, import settings, validadores
- [x] **M108** Herramientas Internas [M] 🟡 — editores de bloques/NPC/diálogos/recetas, teleport
- [x] **M109** Debug Menu [S] 🟡 — teletransporte, tiempo/clima, objetos, regenerar chunks
- [x] **M110** Código de Calidad [M] 🔴 — sin duplicados, tests, interfaces, deuda controlada
- [ ] **M111** Testing Automático [M] 🔴 — unit, integración, save/load, economía, voxel, navegación
- [ ] **M112** Pruebas de Stress [M] 🟡 — miles de bloques, muchos NPC, sesiones largas
- [ ] **M113** Playtest [M] 🔴 — interno, externo, primera experiencia, con gamepad, hardware bajo
- [ ] **M114** Hardware [M] 🟡 — PC mínimo/recomendado, GPU integrada/dedicada, SSD/HDD

### FASE 14 — ENTREGA Y PUBLICACIÓN

- [ ] **M115** Instalador [S] 🟢 — build release, instalación limpia, actualización, desinstalación
- [ ] **M116** Build System [M] 🟡 — builds automatizados dev/QA/staging/release, versión, firmado
- [ ] **M117** CI/CD [M] 🟢 — tests automáticos, builds, artifacts, branch protection
- [ ] **M118** Actualizaciones [M] 🟡 — patches, versionado, compatibilidad de saves, migraciones
- [ ] **M119** DLC y Expansiones [M] 🟢 — estrategia post-lanzamiento, nuevas islas
- [ ] **M120** Soporte Post-Lanzamiento [M] 🟢 — canal de soporte, tickets, hotfixes, roadmap
- [x] **M121** Crash Reporting [S] 🟢 — captura de stack, versión, agrupación, priorización
- [ ] **M122** Modding [C] 🟢 — decidir si habrá, API, seguridad (opcional muy a futuro)
- [ ] **M123** Contenido Generado por Usuarios [M] 🟢 — moderación, privacidad, términos
- [ ] **M124** Términos de Servicio [S] 🟢 — EULA, licencia de uso, reembolsos
- [ ] **M125** Marketing Legal [S] 🟢 — screenshots, música, influencers, claims
- [ ] **M126** Copyright del Juego [S] 🟢 — registro, evidencias de autoría, titulares
- [ ] **M127** Identidad de Marca [M] 🟡 — nombre (verificar colisión), logo, paleta, símbolo de Aurora
- [ ] **M128** Merchandising [S] 🟢 — soundtrack, poster, artbook (post-lanzamiento)
- [ ] **M129** Artbook [M] 🟢 — arte conceptual, evolución del mundo (post-lanzamiento)
- [ ] **M130** Créditos [S] 🟡 — todos los roles, licencias, herramientas, agradecimientos

### FASE 15 — PRODUCCIÓN Y GESTIÓN

- [ ] **M131** Producción del Equipo [S] 🟡 — roles definidos aunque sea equipo chico
- [ ] **M132** Gestión del Proyecto [M] 🔴 — kanban/scrum, milestones, sprints, backlog
- [ ] **M133** Presupuesto [M] 🟡 — programación, arte, marketing, servidores, contingencia
- [ ] **M134** Riesgos del Proyecto [M] 🔴 — scope creep, técnico, financiero, mitigaciones
- [ ] **M135** Roadmap [M] 🔴 — preproducción → prototipo → slice → alpha → beta → lanzamiento

### FASE 16 — HITOS DE DESARROLLO

- [ ] **M136** Prototipo [C] 🔴 — movimiento, cámara, voxel básico, extracción/colocación, mini puzzle, save
- [ ] **M137** Vertical Slice [C] 🔴 — Aurora + templo completo + NPC con arco, arte final, medición de rendimiento
- [ ] **M138** Pre-Alpha [C] 🔴 — núcleo jugable, arquitectura estable, primer bioma, primeros sistemas
- [ ] **M139** Alpha [C] 🔴 — mecánicas completas, historia jugable, primer balance, QA intensivo
- [ ] **M140** Beta [C] 🔴 — contenido completo, rendimiento objetivo, cero bugs críticos, localización
- [ ] **M141** Release Candidate [C] 🔴 — freeze, builds limpias, saves compatibles, certificación
- [ ] **M142** Lanzamiento [C] 🔴 — publicación en Steam, monitoreo, hotfix de emergencia
- [ ] **M143** Después del Lanzamiento [M] 🟡 — reviews, bugs, rendimiento, retención, parches

### FASE 17 — EXPERIENCIA Y FILOSOFÍA

- [ ] **M144** Diseño de Experiencia [M] 🟡 — sensación de llegada, descubrimiento, hogar, comunidad, misterio
- [ ] **M145** Diseño Emocional [M] 🟡 — calma, sorpresa, nostalgia, pertenencia, legado
- [ ] **M146** World Building [C] 🔴 — historia de Aurora, Arquitectos, Resonancia, Primeros Jardineros, Elysia
- [ ] **M147** Lore Ambiental [M] 🟡 — ruinas/objetos/vegetación que cuentan historias, pistas
- [ ] **M148** Nombres y Nomenclatura [M] 🟡 — islas, personajes, Sellos, consistencia, marcas
- [ ] **M149** Diseño Sonoro Narrativo [M] 🟢 — sonido de Resonancia, de cada Sello, silencios narrativos
- [ ] **M150** Control Final [M] 🔴 — verificación integral: diversión, economía, mundo vivo, rendimiento
- [x] **M151** Principios que no deberían perderse [S] 🔴 — cero combate, cero FOMO, sin grind, sin espagueti
- [x] **M152** Objetivo Final del Proyecto [M] 🔴 — Aurora como hogar, curiosidad por explorar, mundo vivo post-créditos

---

## Resumen

| Métrica | Valor |
|---------|-------|
| Total de módulos | **152** |
| Listados en esta checklist | 152 |
| Prioridad Alta (🔴) | 62 |
| Prioridad Media (🟡) | 68 |
| Prioridad Baja (🟢) | 22 |
| Fases | 17 |

> **Nota de desglose:** cada uno de los 152 ítems se convertirá en un componente `DOCUMENTACION/{NN}-Modulo/` con su `plan-inicial/` (5+2 archivos) y `plan-actual/`, generando así **152 checklists de ≥100 ítems** (15.200+ puntos de control totales). El orden de creación de los componentes sigue la numeración de fases, priorizando los módulos de la Fase 1 y los de mayor riesgo técnico (M07, M37, M58, M60, M63).