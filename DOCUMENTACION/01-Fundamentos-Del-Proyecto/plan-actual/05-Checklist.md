# 05-Checklist.md — CHECKLIST DEL PLAN INICIAL GENERICO (152 MÓDULOS)
> **NOTA DEL DIRECTOR 2026-10-12 (barrido Step 5 msg 246):** la numeración de este checklist está **desplazada +1** vs las carpetas reales de DOCUMENTACION/ (M06 = 07-Arquitectura-General, M07 = 08-Mundo-Voxel, M03 = 04-Game-Engine). Los 21 [x] marcan módulos del plan inicial identificados, NO implementación propia. Verificar el desfase antes de cualquier flip.

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-15
**Componente:** 01-Fundamentos-Del-Proyecto
**Estado:** Documentación inicial (plan genérico)

---

## Propósito

Esta checklist contiene los **152 módulos** extraídos del `Plan-inicial-minimo.md` (checklist maestro de 600+ puntos). **Cada ítem NO es una tarea simple: es un MÓDULO completo** que será desglosado en su propio componente `DOCUMENTACION/{NN}-Modulo/` con sus 5 archivos principales y una checklist propia de **no menos de 100 ítems** (regla del `AGENTS.md`, sección 3).

**Símbolos:** `[ ]` pendiente · `[ ]` completado · `[?]` no resuelto
**Esfuerzo:** `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días)
**Prioridad para este proyecto:** 🔴 Alta / 🟡 Media / 🟢 Baja (asignada según impacto en v1.0)

---

## Módulos del Plan Inicial

### FASE 1 — FUNDAMENTOS

- [x] **M01** Visión y Concepto [M] 🔴 — definir nombre definitivo, pilares, pitch, alcance v1.0
- [x] **M02** Documentación del Proyecto [M] 🔴 — GDD, narrativa, sistemas, convenciones, backlog inicial
- [ ] **M03** Game Engine [C] 🔴 — elegir Unity o Godot, fijar versión, configurar render pipeline e input
- [ ] **M04** Lenguaje y Programación [M] 🔴 — C#/GDScript, convenciones, namespaces, arquitectura de software
- [x] **M05** Control de Versiones [S] 🟡 — Git, .gitignore, ramas, mensajes de commit, Git LFS
 — FLIP iter.8 (candidato verificado por auditor_indice_m01 + director; DeepSeek 376/Log 2160)
- [x] **M06** Arquitectura General [C] 🔴 — managers, eventos globales, modularidad, evitar GameManager monolítico

### FASE 2 — MUNDO Y TECNOLOGÍA CENTRAL

- [x] **M07** Mundo Voxel [C] 🔴 — chunking, face/greedy meshing, threading, LOD, colisiones por grilla
- [x] **M08** Terreno y Geografía [C] 🔴 — montañas, valles, ríos, playas, biomas de Aurora
- [x] **M09** Generación del Mundo [C] 🔴 — seed, generador de terreno/biomas/vegetación/minerales/cuevas
- [ ] **M10** Personaje del Jugador [M] 🔴 — modelo 3D, animaciones, controlador, colisiones, interacción
- [x] **M11** Cámara [M] 🔴 — tercera persona cenital inclinada, zoom, clipping, sensibilidad configurable
- [x] **M12** Herramientas [C] 🔴 — pala, pico, hacha, gancho mecánico, lanza-semillas, vara de flujo (sin daño)
- [x] **M13** Inventario [M] 🔴 — slots, stacks, hotbar, cofres, transferencia rápida, peso
- [x] **M14** Recursos [M] 🔴 — madera, piedra, arena, minerales, frutas, peces, rareza, respawn
- [x] **M15** Crafting [M] 🔴 — banco de trabajo, recetas, desbloqueos, preview, feedback
- [x] **M16** Construcción [C] 🔴 — modo construcción/decoración, grid, snapping, rotación, demolición
- [x] **M17** Casas [M] 🟡 — parcelas, ampliaciones, habitaciones, muebles interactivos, almacenamiento

### FASE 3 — VIDA COMUNITARIA Y NARRATIVA

- [x] **M18** NPC y Vecinos [C] 🔴 — especies, personalidades, rutinas, horarios, hogares, relaciones
 — FLIP iter.8 (candidato verificado por auditor_indice_m01 + director; DeepSeek 376/Log 2160)
- [x] **M19** Sistema de Amistad [M] 🟡 — puntos de amistad, niveles, regalos, desbloqueos, eventos únicos
- [x] **M20** Diálogos [C] 🔴 — motor por nodos, flags narrativos, opciones, localización
- [x] **M21** Historia Principal [C] 🔴 — prólogo, capítulos, Sellos, templos, finales y ritmo
 — FLIP iter.8 (candidato verificado por auditor_indice_m01 + director; DeepSeek 376/Log 2160)
- [ ] **M22** Historias Secundarias [M] 🟡 — arcos de vecinos, lugares, ruinas, objetos, postgame
- [x] **M23** Templos y Puzzles [C] 🔴 — framework emisor→receptor, dificultad, pistas, checkpoints
- [ ] **M24** Ruinas [M] 🟡 — variantes pequeñas/medianas/grandes, inscripciones, pasajes ocultos
- [x] **M25** Templo Subterráneo [C] 🔴 — Templo de la Brisa: entrada, tutorial, salas, cámara del Sello

### FASE 4 — MUNDO EXPANDIDO

- [x] **M26** Islas del Mundo [C] 🟡 — Isla de Coral, Verde, Cenizas, Cielo (diseño completo por isla)
- [ ] **M27** Viajes [M] 🟡 — Gran Vapor, boletos, requisitos, pantalla de viaje diegética
- [ ] **M28** Tiempo y Calendario [M] 🔴 — día/noche, estaciones, festivales, cumpleaños, eventos
- [ ] **M29** Reloj en Tiempo Real [M] 🟡 — Gran Vapor mensual, zona horaria, offline, anti-exploits
- [ ] **M30** Ciclo Día/Noche [M] 🟡 — iluminación, cielo, estrellas, comportamiento de NPC y fauna
- [x] **M31** Clima [M] 🟡 — sol, lluvia, tormenta, niebla, nieve, transiciones, accesibilidad
 — REVERT iter.8 (sello denegado/degradado posterior; DeepSeek 376)

### FASE 5 — ACTIVIDADES Y CONTENIDO

- [x] **M32** Agricultura [M] 🟡 — parcelas, semillas, riego, fertilizante, estaciones, plantas ancestrales
- [x] **M33** Pesca [M] 🟡 — especies, minijuego no frustrante, coleccionario, peces legendarios
- [x] **M34** Minería [M] 🟡 — vetas, profundidad, minerales ancestrales, derrumbes controlados
- [x] **M35** Fauna [M] 🟡 — especies no hostiles, hábitat, migraciones, observación, ecosistemas
- [x] **M36** Museos y Colecciones [M] 🟢 — salas, vitrinas, fósiles, porcentaje completado
- [x] **M37** Economía [C] 🔴 — Gemas de Ámbar, Pases de Mérito, precios, sumideros, anti-exploits
- [x] **M38** Tiendas [M] 🟡 — tienda general, muebles, ropa, vivero, rotación de stock
- [x] **M39** Infraestructura [M] 🟡 — puentes, rampas, faro, puerto, plaza, proyectos de Finneas

### FASE 6 — ARTE, AUDIO Y PRESENTACIÓN

- [x] **M40** Música [C] 🟡 — acústica/lo-fi por bioma, leitmotifs, música adaptativa, loops
- [ ] **M41** Sonido Ambiental [M] 🟡 — viento, agua, océano, cuevas, ruinas, mecanismos
- [x] **M42** Efectos de Sonido [M] 🟡 — pasos, herramientas, bloques, diálogo, menús, logros (checklist 43-Efectos-De-Sonido 97/97 (0 [ ] / 0 [?]))
- [ ] **M43** ASMR y Feedback [M] 🟡 — sensaciones táctiles de picar/cosechar/construir, capas sonoras
- [x] **M44** Arte 3D [C] 🔴 — estilo cozy voxel redondeado, presupuesto de polígonos, LOD
- [ ] **M45** Arte 2D [M] 🟡 — logo, iconos, UI, mapas, símbolos ancestrales, guías de estilo
- [ ] **M46** Texturas y Materiales [M] 🟡 — tierra, césped, piedra, agua, variantes por bioma
- [ ] **M47** Animación [C] 🟡 — jugador, NPC, fauna, vegetación, mecanismos, UI
- [x] **M48** Iluminación [M] 🟡 — URP/Forward+, GI suave, horaria, faroles, cuevas, optimización
- [x] **M49** Vegetación [M] 🟡 — hierba, árboles ancestrales, plantas luminosas, viento, instancing
- [x] **M50** Agua [C] 🟡 — océano, ríos, cascadas, congelamiento, evaporación, puzzles hidráulicos
- [x] **M51** Partículas y VFX [M] 🟡 — polvo, hojas, Resonancia, activación de runas, obtención de Sello

### FASE 7 — INTERFAZ Y EXPERIENCIA

- [ ] **M52** UI/UX [C] 🔴 — HUD, menús, inventario, mapa, diario, calendario, tooltips
- [x] **M53** Mapa [M] 🟡 — mapa global, descubrimiento progresivo, marcadores, leyenda
- [ ] **M54** Diario del Jugador [M] 🟢 — registro de personajes, pistas, Sellos, ruinas, fotografías
- [x] **M55** Fotografía [M] 🟢 — modo fotografía, filtros, álbum, galería
- [x] **M56** Interfaz de Control [M] 🔴 — teclado, ratón, gamepad, remapeo, Steam Deck
- [x] **M57** Accesibilidad [M] 🔴 — daltonismo, subtítulos, texto ajustable, reducción de movimiento

### FASE 8 — PERSISTENCIA Y CALIDAD

- [x] **M58** Guardado [C] 🔴 — autosave, slots, GameState versionado, backups, recuperación
- [x] **M59** Datos y Serialización [M] 🔴 — formato, IDs persistentes, versionado de schema, migraciones
- [x] **M60** Rendimiento [C] 🔴 — 60 FPS, presupuestos, profiling, culling, batching, instancing
- [ ] **M61** Memoria [M] 🔴 — texturas, meshes, audio, streaming, memory leaks, sesiones largas
- [x] **M62** Cargas y Streaming [M] 🔴 — carga asíncrona, chunks cercanos, progreso real
- [ ] **M63** IA de NPC [C] 🔴 — máquina de estados, rutinas, pathfinding sobre terreno modificable
- [x] **M64** Animales IA [M] 🟡 — comportamiento no hostil, migraciones, spawn/despawn
- [x] **M65** Anti-Softlock [M] 🔴 — recuperación de objetos clave, reinicio de puzzles, fallbacks
- [x] **M66** Vehículos [M] 🟢 — barco (y post-v1.0 submarino), física, cámara, docking
- [x] **M67** Transporte y Navegación [M] 🟢 — puerto, rutas, señalización, fast travel narrativo
- [ ] **M68** Fast Travel [S] 🟢 — puntos de viaje, requisitos, anti-bypass de eventos

### FASE 9 — PROGRESIÓN Y CONTENIDO

- [x] **M69** Interacciones [M] 🔴 — distancia, indicador, prioridad, contextuales, cancelación — FLIP iter.9 (checklist propia cerrada + fila ✅; auditor_indice_m01 --pendientes, DeepSeek 378; M117: CI rojo = deuda de pipeline aparte, no invalida el contenido)
- [x] **M70** Progresión [M] 🔴 — narrativa, herramientas, construcción, social, islas, desbloqueos
- [x] **M71** Sistema de Logros [M] 🟡 — básicos, exploración, social, colección, secretos
- [ ] **M72** Coleccionables [M] 🟡 — reliquias, fragmentos, conchas, fósiles, documentos
- [x] **M73** Eventos [M] 🟡 — festivales estacionales, llegada del vapor, eventos raros
- [x] **M74** Postgame [M] 🟢 — Era del Alba, nuevas islas, objetivos 100%, contenido libre

### FASE 10 — MULTIJUGADOR (decisión)

- [x] **M75** Multijugador [C] 🟢 — decidir local/online, cantidad, voz de diseño (post-v1.0)
- [x] **M76** Online y Red [C] 🟢 — cliente-servidor, sincronización, latencia, seguridad (post-v1.0)

### FASE 11 — LEGAL Y ADMINISTRACIÓN

- [x] **M77** Legal — Propiedad Intelectual [M] 🔴 — marcas, autoría, licencias, terceros
 — REVERT iter.8 (sello denegado/degradado posterior; DeepSeek 376)
- [x] **M78** Legal — Contratos [M] 🟡 — freelancers, cesión de derechos, work-for-hire
- [x] **M79** Legal — Privacidad [M] 🔴 — GDPR/COPPA, política de privacidad, consentimientos
- [x] **M80** Legal — Menores [M] 🟡 — clasificación, controles parentales, contenido
- [x] **M81** Clasificación por Edades [S] 🟡 — IARC/ESRB/PEGI (cero violencia → permisiva)
- [x] **M82** Licencias de Software [M] 🟡 — engine, plugins, fuentes, librerías
- [x] **M83** Música y Audio — Legal [M] 🟡 — derechos de reproducción, sincronización, ámbitos territoriales
- [x] **M84** Modelos 3D — Legal [M] 🟡 — licencias de cada modelo, atribución, registro
- [x] **M85** IA Generativa [M] 🔴 — política de IA, declaración Steam, qué delegar y qué no

### FASE 12 — PLATAFORMA Y MARKETING

- [x] **M86** Localización [M] 🟡 — idioma base, claves, tablas, QA lingüístico
- [x] **M87** Fuentes Tipográficas [S] 🟢 — fuente principal/secundaria, licencia, tildes y ñ
- [x] **M88** Diseño de Menús [M] 🟡 — principal, pausa, inventario, ajustes, créditos
- [x] **M89** Configuración Gráfica [S] 🟡 — resolución, calidad, VSync, FPS, presets
 — FLIP iter.8 (candidato verificado por auditor_indice_m01 + director; DeepSeek 376/Log 2160)
- [x] **M90** Configuración de Audio [S] 🟡 — volúmenes independientes, rango dinámico
- [x] **M91** Tutorial [M] 🔴 — movimiento, cámara, recolección, construcción, progresivo
- [x] **M92** Balance [C] 🔴 — precios, recompensas, crafting, amistad, simulación económica
- [x] **M93** Retención sin FOMO [M] 🟡 — objetivos diarios/semanales, sin castigos por ausencia
- [x] **M94** Monetización [M] 🟡 — premium, DLC de islas vs contenido gratis, precio
- [x] **M95** Plataformas [M] 🟡 — PC/Steam prioritario, Steam Deck, EGS/GOG a evaluar
- [x] **M96** Steam / Store Page [M] 🔴 — página, capsule art, capturas, trailer, wishlists
- [x] **M97** Trailer [M] 🟡 — teaser, gameplay, lanzamiento
- [x] **M98** Marketing [M] 🟡 — identidad, redes, devlogs, press kit, Next Fest — FLIP iter.9 (checklist propia cerrada + fila ✅; auditor_indice_m01 --pendientes, DeepSeek 378; M117: CI rojo = deuda de pipeline aparte, no invalida el contenido)
- [x] **M99** Community Management [M] 🟢 — Discord, reglas, feedback, FAQ
 — FLIP iter.8 (candidato verificado por auditor_indice_m01 + director; DeepSeek 376/Log 2160)

### FASE 13 — QA Y DESARROLLO

- [x] **M100** QA General [M] 🔴 — funcional, regresión, rendimiento, guardado, UI, audio
- [x] **M101** Bug Tracking [S] 🟡 — herramienta, categorías, severidades, reproducción
- [x] **M102** Logging [M] 🟡 — niveles, rotación, crash reporting, exportación
- [x] **M103** Analytics [M] 🟢 — eventos, sesiones, anonimización, dashboard
- [x] **M104** Telemetría de Gameplay [M] 🟢 — tutorías, abandono de puzzles, zonas ignoradas
- [x] **M105** Seguridad [M] 🟢 — APIs, claves, validación, anti-manipulación (si online)
- [ ] **M106** Backups [S] 🔴 — repositorio, assets, documentación, builds, restauración
- [x] **M107** Pipeline de Assets [M] 🔴 — naming, carpetas, formatos, import settings, validadores
- [x] **M108** Herramientas Internas [M] 🟡 — editores de bloques/NPC/diálogos/recetas, teleport
- [ ] **M109** Debug Menu [S] 🟡 — teletransporte, tiempo/clima, objetos, regenerar chunks
- [x] **M110** Código de Calidad [M] 🔴 — sin duplicados, tests, interfaces, deuda controlada
- [x] **M111** Testing Automático [M] 🔴 — unit, integración, save/load, economía, voxel, navegación
- [x] **M112** Pruebas de Stress [M] 🟡 — miles de bloques, muchos NPC, sesiones largas
 — REVERT iter.8 (sello denegado/degradado posterior; DeepSeek 376)
- [x] **M113** Playtest [M] 🔴 — interno, externo, primera experiencia, con gamepad, hardware bajo
 — FLIP iter.8 (candidato verificado por auditor_indice_m01 + director; DeepSeek 376/Log 2160)
- [x] **M114** Hardware [M] 🟡 — PC mínimo/recomendado, GPU integrada/dedicada, SSD/HDD

### FASE 14 — ENTREGA Y PUBLICACIÓN

- [x] **M115** Instalador [S] 🟢 — build release, instalación limpia, actualización, desinstalación (checklist 116-Instalador 192/192)
- [ ] **M116** Build System [M] 🟡 — builds automatizados dev/QA/staging/release, versión, firmado
- [x] **M117** CI/CD [M] 🟢 — tests automáticos, builds, artifacts, branch protection — FLIP iter.9 (checklist propia cerrada + fila ✅; auditor_indice_m01 --pendientes, DeepSeek 378; M117: CI rojo = deuda de pipeline aparte, no invalida el contenido)
- [x] **M118** Actualizaciones [M] 🟡 — patches, versionado, compatibilidad de saves, migraciones
- [x] **M119** DLC y Expansiones [M] 🟢 — estrategia post-lanzamiento, nuevas islas (checklist 120-DLC-Y-Expansiones 222/222)
- [x] **M120** Soporte Post-Lanzamiento [M] 🟢 — canal de soporte, tickets, hotfixes, roadmap (checklist 121-Soporte-Post-Lanzamiento 211/211)
- [x] **M121** Crash Reporting [S] 🟢 — captura de stack, versión, agrupación, priorización
- [x] **M122** Modding [C] 🟢 — decidir si habrá, API, seguridad (opcional muy a futuro)
- [x] **M123** Contenido Generado por Usuarios [M] 🟢 — moderación, privacidad, términos
- [x] **M124** Términos de Servicio [S] 🟢 — EULA, licencia de uso, reembolsos
- [x] **M125** Marketing Legal [S] 🟢 — screenshots, música, influencers, claims
- [x] **M126** Copyright del Juego [S] 🟢 — registro, evidencias de autoría, titulares
- [x] **M127** Identidad de Marca [M] 🟡 — nombre (verificar colisión), logo, paleta, símbolo de Aurora
- [x] **M128** Merchandising [S] 🟢 — soundtrack, poster, artbook (post-lanzamiento)
- [x] **M129** Artbook [M] 🟢 — arte conceptual, evolución del mundo (post-lanzamiento) (checklist 130-Artbook 134/134)
- [x] **M130** Créditos [S] 🟡 — todos los roles, licencias, herramientas, agradecimientos

### FASE 15 — PRODUCCIÓN Y GESTIÓN

- [ ] **M131** Producción del Equipo [S] 🟡 — roles definidos aunque sea equipo chico
- [x] **M132** Gestión del Proyecto [M] 🔴 — kanban/scrum, milestones, sprints, backlog
- [x] **M133** Presupuesto [M] 🟡 — programación, arte, marketing, servidores, contingencia
- [x] **M134** Riesgos del Proyecto [M] 🔴 — scope creep, técnico, financiero, mitigaciones
- [x] **M135** Roadmap [M] 🔴 — preproducción → prototipo → slice → alpha → beta → lanzamiento

### FASE 16 — HITOS DE DESARROLLO

- [x] **M136** Prototipo [C] 🔴 — movimiento, cámara, voxel básico, extracción/colocación, mini puzzle, save
- [ ] **M137** Vertical Slice [C] 🔴 — Aurora + templo completo + NPC con arco, arte final, medición de rendimiento
- [ ] **M138** Pre-Alpha [C] 🔴 — núcleo jugable, arquitectura estable, primer bioma, primeros sistemas
- [x] **M139** Alpha [C] 🔴 — mecánicas completas, historia jugable, primer balance, QA intensivo
- [x] **M140** Beta [C] 🔴 — contenido completo, rendimiento objetivo, cero bugs críticos, localización
- [ ] **M141** Release Candidate [C] 🔴 — freeze, builds limpias, saves compatibles, certificación
- [x] **M142** Lanzamiento [C] 🔴 — publicación en Steam, monitoreo, hotfix de emergencia
- [x] **M143** Después del Lanzamiento [M] 🟡 — reviews, bugs, rendimiento, retención, parches

### FASE 17 — EXPERIENCIA Y FILOSOFÍA

- [x] **M144** Diseño de Experiencia [M] 🟡 — sensación de llegada, descubrimiento, hogar, comunidad, misterio
- [x] **M145** Diseño Emocional [M] 🟡 — calma, sorpresa, nostalgia, pertenencia, legado
- [ ] **M146** World Building [C] 🔴 — historia de Aurora, Arquitectos, Resonancia, Primeros Jardineros, Elysia
- [ ] **M147** Lore Ambiental [M] 🟡 — ruinas/objetos/vegetación que cuentan historias, pistas
- [x] **M148** Nombres y Nomenclatura [M] 🟡 — islas, personajes, Sellos, consistencia, marcas
- [ ] **M149** Diseño Sonoro Narrativo [M] 🟢 — sonido de Resonancia, de cada Sello, silencios narrativos
- [x] **M150** Control Final [M] 🔴 — verificación integral: diversión, economía, mundo vivo, rendimiento
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
**Totales:** 152 items - Completados: 26 - Pendientes: 126 - No resueltos: 0.
**Totales:** 152 ítems · Completados: 29 · Pendientes: 123 · No resueltos: 0. (Director GLM-5.3 Flash-Director 23oct 22:57: iter.8 aplicada — 6 flips + 3 reverts de DeepSeek 376/Log 2160, candidatos verificados por auditor_indice_m01 y por el director.)

## Auditoria del indice maestro (2026-10-14 - DeepSeek-V4.1-Flash, iter 6)

Medicion de los 152 items contra el criterio documentado (checklist propia 100% cerrada Y fila GLOBAL `[OK]`):

- Checklists propias 100% cerradas: **29**; de esas con GLOBAL `[OK]`: **26** = las **26** ya flipeadas.
- **Candidatos nuevos: 0.** Los 26/152 del indice son correctos.
- 3 cerradas pero GLOBAL NO `[OK]` (no flipeables por el criterio, igual que `M024`): `M018` -> `19-NPC-Y-Vecinos` (GLOBAL verde Disponible), `M021` -> `22-Historia-Principal` (verde Disponible), `M099` -> `100-Community-Management` (amarillo Con dudas).
- En curso: **122**; sin iniciar: **1** (`M045` -> `46-Arte-2D`).
- Suma de los 152 sub-checklists: **17469 [x] / 967 [?] / 3527 [ ] = 21963**.

**0 flips aplicados.** M01 no puede avanzar solo: depende de que los otros modulos cierren su checklist y su GLOBAL pase a `[OK]`.
Detalle y metodo en `07-Resultados-Testings.md` seccion 5.3.
 (Corregido por director 2026-10-12: barrido Step 5 msg 246, decia 0 completados - plantilla copiada sin actualizar)

## Auditoria del indice maestro (2026-10-15 - DeepSeek-V4.1-Flash, iter 7)

Encargo del director (msg 251). Medicion con el mismo criterio (checklist propia 100 % cerrada Y fila GLOBAL `[OK]`). Log **1858**.

- **Marcas medidas por prefijo de linea: 26 `[x]` / 126 `[ ]` / 0 `[?]`.** La cifra `21/152` del encargo es la tabla 5.1 del `07-Resultados-Testings.md` (iter 1), stale tras el refresco 5.3. **Vigente: 26/152.**
- Checklists propias 100 % cerradas: **29**; de esas con GLOBAL `[OK]`: **26** = las **26** ya flipeadas.
- **Candidatos nuevos: 0.** Los 26 flips existentes se re-verificaron uno por uno: **26/26 validos, 0 stale**.
- 3 cerradas sin GLOBAL `[OK]` (no flipeables, igual que `M024`): `M018` -> `19-NPC-Y-Vecinos` (Disponible, pendiente QA 21.8), `M021` -> `22-Historia-Principal` (Disponible, pendiente QA 21.8), `M099` -> `100-Community-Management` (Con dudas).
- En curso: **122**; sin iniciar: **1** (`M045` -> `46-Arte-2D`). Suma de los 152 sub-checklists: **17485 [x] / 970 [?] / 3508 [ ] = 21963**.
- **Estructura del bloqueo:** 46 modulos tienen `[ ]=0` pero `[?]>0` (767 de los 970 `[?]` totales). La palanca de M01 esta en resolver `[?]`, no en cerrar `[ ]`.
- **Cola accionable:** 17 modulos a 1-5 `[ ]` de cerrar; los mas cercanos con GLOBAL ya `[OK]` son `M05` -> `06-Control-De-Versiones` (99/0/1) y `M140` -> `141-Beta` (146/0/1).

**0 flips aplicados.** M01 sigue bloqueado por cierre ajeno. Detalle y metodo en `07-Resultados-Testings.md` seccion 5.4.

> **Nota de mapeo (evidencia dura):** el item `M##` de ESTE indice maestro corresponde a la carpeta `{##+1:03d}`; la tabla `CHECKLIST-GLOBAL.md` rotula sus filas con el **numero de carpeta** (fila `18` = `18-Casas`, fila `19` = `19-NPC-Y-Vecinos`). Son dos numeraciones distintas y conviven: `M42` "Efectos de Sonido" anota `checklist 43-Efectos-De-Sonido 97/97` y la fila GLOBAL `43` es `43-Efectos-De-Sonido`. Al cruzar este indice con el GLOBAL, desplazar +1.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 0 [x] / 152 [ ] / 0 [?].
> Las marcas no se tocaron.
