# DOCUMENTACION — Sistema de Documentación de Isla Ancestral

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-15

## Estructura

```
DOCUMENTACION/
├── 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md   ← (pendiente) Especificaciones técnicas vigentes
├── 2-DOCUMENTO-DISENO-ACTUAL.md                ← (pendiente) Diseño detallado vigente
├── 3-DOCUMENTO-TAREAS-ACTUAL.md                ← (pendiente) Checklist de tareas con estado actual
├── 4-DOCUMENTO-EJECUCION-ACTUAL.md             ← (pendiente) Código de ejecución vigente
├── 5-FUTURAS-MEJORAS.md                        ← (pendiente) Ideas y mejoras del usuario
├── 00-PLAN-INICIAL/                            ← Origen del proyecto (NO MODIFICAR)
├── 01-Fundamentos-Del-Proyecto/                ← Portal/índice: 152 módulos, 68 documentados [x]
├── 02-Vision-Y-Concepto/                ← M01: visión, pitch, pilares, alcance v1.0 (162/172)
├── 03-Documentacion-Del-Proyecto/       ← M02: catálogo, convenciones, hitos, backlog (133/133)
├── 04-Game-Engine/                      ← M03: Godot 4.x adoptado + Voxel Tools (94/120)
├── 05-Lenguaje-Y-Programacion/          ← M04: GDScript, convenciones, patrones (102/102)
├── 06-Control-De-Versiones/             ← M05: política git, semver, CHANGELOG (91/92)
├── 07-Arquitectura-General/             ← M06: Service Locator, capas, EventBus (102/102)
├── 08-Mundo-Voxel/                      ← M07: voxel 1m, chunks, catálogo, diffs (104/104)
├── 09-Terreno-Y-Geografia/              ← M08: 25 puntos, 13 biomas, recetas, mapa Aurora (104/104)
├── 10-Generacion-Del-Mundo/             ← M09: pipeline 8 capas, determinismo, semillas (104/104)
├── 11-Personaje-Del-Jugador/            ← M10: FSM 10 estados, hitbox, stamina, luz (102/102)
├── 12-Camara/                           ← M11: 5 modos, spring-arm, minimapa, anti-mareo (100/100)
├── 13-Herramientas/                     ← M12: 9 herramientas x 4 niveles, contrato voxel (101/101)
├── 29-Tiempo-Y-Calendario/              ← DELEGABLE: GameClock servicio puro, festivos (104/104)
├── 30-Reloj-En-Tiempo-Real/             ← DELEGABLE: sin tiempo real, anti-exploit, display (104/104)
├── 31-Ciclo-Dia-Noche/                  ← DELEGABLE: 5 franjas, anti-oscuridad, nocturnos (130/130)
├── 32-Clima/                            ← DELEGABLE: 9 climas deterministas, cozy (120/120)
├── 41-Musica/                           ← DELEGABLE: matriz de capas, leitmotifs (110/110)
├── 42-Sonido-Ambiental/                 ← DELEGABLE: banco por bioma, ≤11 buses (109/109)
├── 43-Efectos-De-Sonido/                ← DELEGABLE: pool 24 voces, familia tonal (96/96)
├── 44-ASMR-Y-Feedback/                  ← DELEGABLE: recetas de capas, blacklist cozy (113/113)
├── 57-Interfaz-De-Control/              ← DELEGABLE: capa de acciones, remapeo, prompts (119/119)
├── 63-Cargas-Y-Streaming/               ← DELEGABLE: progreso real, LRU, precalentamiento (101/101)
├── 64-IA-De-NPC/                        ← DELEGABLE: FSM, rutinas, burbuja ≤60 (107/107)
├── 65-Animales-IA/                     ← DELEGABLE: manadas, migración, presupuesto (100/100)
├── 66-Anti-Softlock/                   ← DELEGABLE: invariantes, cofre, checkpoints (100/100)
├── 24-Templos-Y-Puzzles/               ← DELEGABLE: framework emisor→receptor, 15 familias (100/100)
├── 25-Ruinas/                          ← DELEGABLE: kit modular ≤40 piezas, 13 tipos (100/100)
├── 26-Templo-Subterraneo/              ← DELEGABLE: Templo de la Brisa, 7 anillos (100/100)
├── 22-Historia-Principal/              ← DELEGABLE: 7 capítulos, 5 finales, grafo (100/100)
├── 23-Historias-Secundarias/           ← DELEGABLE: 60 cadenas, contexto obligatorio (100/100)
├── 39-Tiendas/                         ← DELEGABLE: catálogos por NPC, horarios, stock (181/181)
├── 40-Infraestructura/                 ← DELEGABLE: autoloads, servicios base (211/211)
├── 54-Mapa/                            ← DELEGABLE: mapa exploración, minimapa, POI (171/171)
├── 72-Sistema-De-Logros/               ← DELEGABLE: logros, desbloqueo, Steam sync (190/190)
├── 74-Eventos/                         ← DELEGABLE: festivales, repetibles, anti-FOMO (266/266)
├── 87-Localizacion/                    ← DELEGABLE: i18n/l10n, textos dinámicos (136/136)
├── 45-Arte-3D/                         ← DELEGABLE: estilo Cozy Voxel, LOD, kit modular (157/157)
├── 46-Arte-2D/                         ← DELEGABLE: iconos, retratos, atlas (109/109)
├── 47-Texturas-Y-Materiales/           ← DELEGABLE: atlas de bloques, variantes por bioma, shaders (107/107)
├── 48-Animacion/                       ← DELEGABLE: kit 25 dominios, FSM espejo, LOD anim (122/122)
├── 49-Iluminacion/                     ← DELEGABLE: presets por franja, pool, baked (116/116)
├── 50-Vegetacion/                      ← DELEGABLE: 26+ especies, MultiMesh, viento (117/117)
├── 51-Agua/                            ← DELEGABLE: 7 tipos, nivel de mar, olas (129/129)
├── 52-Particulas-Y-VFX/                ← DELEGABLE: catálogo 25 efectos, pool (120/120)
├── 55-Diario-Del-Jugador/              ← DELEGABLE: 14 categorías, anti-spoilers, % completado (130/130)
├── 56-Fotografia/                      ← DELEGABLE: modo foto, Navigator, presets, álbum (130/130)
├── 59-Guardado/                        ← DELEGABLE: atómico, slots, backups, migración (130/130)
├── 67-Vehiculos/                       ← DELEGABLE: barco, dirigible, submarino, streaming (130/130)
├── 68-Transporte-Y-Navegacion/         ← DELEGABLE: red de rutas, señalización, viajes (130/130)
├── 73-Coleccionables/                  ← DELEGABLE: 22 categorías, registro idempotente (130/130)
├── 75-Postgame/                        ← DELEGABLE: orquestador del 100%, catálogo FASE 1/2 (130/130)
├── 76-Multijugador/                    ← DECISIÓN: single-player v1, contrato MP futuro (130/130)
├── 77-Online-Y-Red/                    ← CONTRATO: arquitectura de red futura (BLOQUEADO por hit) (130/130)
├── 61-Rendimiento/                     ← NORMA: presupuestos 16,5 ms, bench scene, gate CI (RECLAMADO) (130/130)
├── 153-Objetivo-Final/                 ← VISIÓN: contrato O1-O19 verificable (RECLAMADO) (130/130)
├── 102-Bug-Tracking/                     ← GitHub Issues: plantillas, categorías, flujos (121/121)
├── 103-Logging/                          ← Servicio Logger: niveles, categorías, rotación, sanitización (134/134)
├── 107-Backups/                          ← Backups 3-2-1: GitHub Actions, Task Scheduler, verificación, recuperación (137/137)
├── 110-Debug-Menu/                       ← Debug Menu in-game: 5 paneles, teletransporte, tiempo, clima, objetos, visualizaciones, consola, diagnóstico (138/138)
├── 111-Codigo-De-Calidad/                ← Guía de estilo GDScript, interfaces, patrones, code reviews, deuda técnica (248/248)
├── 122-Crash-Reporting/                   ← Crash Reporting: Crashlytics/Sentry, metadata, contexto seguro, offline mode, dashboard, alertas (335/335)
├── 152-Principios-Innegociables/         ← Principios Innegociables: filosofía cozy, diseño de juego, técnicos, proceso de revisión, knowledge sharing (189/189)
├── 88-Fuentes-Tipograficas/             ← Fuentes Tipográficas: Nunito + Fredoka One, jerarquía visual, estilos UI, optimización, accesibilidad, localización (218/218)
├── 90-Configuracion-Grafica/            ← Configuración Gráfica: 23 opciones gráficas, 4 presets, detección automática de hardware, menú de settings, integración con M58/M61/M88 (248/248)
├── 91-Configuracion-De-Audio/           ← Configuración de Audio: 15 opciones de audio, 7 buses de audio, audio 3D, subtítulos, sonidos de interfaz, rango dinámico, compresión, dispositivo de salida, pruebas de audio, integración con M58/M87/M61 (227/227)
├── 81-Legal-Menores/                         ← 🔵 EN CURSO: cumplimiento COPPA/GDPR-K/LGPD, age gating, data sanitization, parental consent, IARC, políticas legales menores (110/110)
├── 82-Clasificacion-Por-Edades/              ← 🔵 EN CURSO: sistemas IARC/ESRB/PEGI/CERO/GRAC/ACB/USK/ClassInd, descriptores, rating objetivo, validación automática (100/100)
├── 83-Licencias-De-Software/                 ← 🔵 EN CURSO: inventario de licencias, validación de compatibilidad, generación automática de notices, integración build pipeline (100/100)
├── 84-Musica-Y-Audio-Legal/                  ← 🔵 EN CURSO: contratos de compositor/artistas, licencias de stock, créditos de audio, validación de audio IA (100/100)
├── 85-Modelos-3D-Legal/                      ← 🔵 EN CURSO: contratos de artistas 3D, licencias de stock, créditos, validación de modelos IA (100/100)
├── 115-Hardware/                             ← 🔵 EN CURSO: detección de hardware, ajuste automático de calidad, perfiles de rendimiento, soporte gamepads (100/100)
├── 119-Actualizaciones/                      ← 🔵 EN CURSO: sistema de updates, notificación, compatibilidad de saves, rollback, integración plataformas (100/100)
├── 128-Identidad-De-Marca/                   ← 🔵 EN CURSO: logo, paleta, tipografía, manual de marca, trademarks, presencia online (100/100)
├── 132-Produccion-De-Equipo/                 ← 🔵 EN CURSO: estructura organizativa, roles, comunicación, gestión de tareas, onboarding (100/100)
├── 134-Presupuesto/                          ← 🔵 EN CURSO: desglose por categorías, control de gastos, proyecciones de ingresos, break-even (100/100)
├── INVESTIGACION SOBRE OTROS JUEGOS/           ← Investigación de juegos de referencia
```

## Sistema de Componentes

Cada componente (`NN-Nombre/`) contiene dos carpetas:

| Carpeta | Contenido |
|---------|-----------|
| `plan-inicial/` | Documentación original del componente (NO MODIFICAR) |
| `plan-actual/` | Documentación vigente (ACTUALIZAR AQUÍ) |

**5 archivos principales obligatorios en cada carpeta:**
`01-Requerimientos.md` · `02-Analisis.md` · `03-Diseno.md` · `04-Codigo.md` · `05-Checklist.md` (≥100 ítems)

**2 archivos de testing opcionales:** `06-Plan-Testings.md` · `07-Resultados-Testings.md`

## Estado actual

| Componente | Estado |
|------------|--------|
| 01-Fundamentos-Del-Proyecto | ✅ Actualizado por Deepseek V4 Flash 2026-08-19 — portal/índice maestro sincronizado: 68/152 módulos con documentación real marcada [x]; libre de bloqueos (68/152) |
| 02-Vision-Y-Concepto | ✅ Creado — 5 archivos, checklist de 172 ítems (162 completados; 10 pendientes con dueño en M02/QA/Publicación) |
| 03-Documentacion-Del-Proyecto | ✅ Creado — catálogo de 25 documentos, convenciones, hitos M1-M5, backlog; 5 docs generales *-ACTUAL.md creados |
| 04-Game-Engine | ✅ Creado — decisión Godot 4.x + Voxel Tools, stack y config de proyecto base (95/120; pendientes = instalación/M1) |
| 05-Lenguaje-Y-Programacion | ✅ Creado — GDScript adoptado, guía de convenciones y patrones transversales (102/102) |
| 06-Control-De-Versiones | ✅ Creado — política git, ramas, semver, auto-revisión; CHANGELOG.md creado (91/92) |
| 07-Arquitectura-General | ✅ Creado — Service Locator, capas unidireccionales, EventBus por dominios, GameState (102/102) |
| 08-Mundo-Voxel | ✅ Creado — voxel 1 m, chunks 16³, catálogo de bloques, reglas de validación, diffs (104/104) |
| 09-Terreno-Y-Geografia | ✅ Creado — 25 puntos, 13 biomas, recetas de formaciones, mapa de Aurora (104/104) |
| 10-Generacion-Del-Mundo | ✅ Creado — pipeline de 8 capas, PRNG por contexto, regeneración segura (104/104) |
| 11-Personaje-Del-Jugador | ✅ Creado — FSM de 10 estados, físicas cozy, interacción y esporas de luz (102/102) |
| 12-Camara | ✅ Creado — 5 modos de cámara, spring-arm con colisión, minimapa sin render (100/100) |
| 13-Herramientas | ✅ Creado — 9 herramientas × 4 niveles, durabilidad cozy, contratos voxel (101/101) |
| 29-Tiempo-Y-Calendario | ✅ Creado — DELEGABLE: GameClock, calendario Aurora, eventos repetibles (104/104) |
| 30-Reloj-En-Tiempo-Real | ✅ Creado — DELEGABLE: sin tiempo real, anti-exploit, widget display (104/104) |
| 31-Ciclo-Dia-Noche | ✅ Creado — DELEGABLE: 5 franjas de fase, anti-oscuridad, eventos nocturnos (130/130) |
| 32-Clima | ✅ Creado — DELEGABLE: 9 climas deterministas, regla anti-molestia, accesibilidad (120/120) |
| 41-Musica | ✅ Creado — DELEGABLE: 51 puntos, matriz capas, leitmotifs, LUFS -16 (110/110) |
| 42-Sonido-Ambiental | ✅ Creado — DELEGABLE: banco por bioma, capas hora/clima (99/99) |
| 43-Efectos-De-Sonido | ✅ Creado — DELEGABLE: pool 24 voces, familia tonal (96/96) |
| 44-ASMR-Y-Feedback | ✅ Creado — DELEGABLE: recetas de capas, blacklist cozy (113/113) |
| 57-Interfaz-De-Control | ✅ Creado — DELEGABLE: capa de acciones, remapeo, prompts (119/119) |
| 63-Cargas-Y-Streaming | ✅ Creado — DELEGABLE: progreso real, LRU, precalentamiento (101/101) |
| 64-IA-De-NPC | ✅ Creado — DELEGABLE: FSM, rutinas, burbuja ≤60 (107/107) |
| 65-Animales-IA | ✅ Creado — DELEGABLE: manadas, migración, presupuesto (129/129) |
| 66-Anti-Softlock | ✅ Creado — DELEGABLE: invariantes, cofre, checkpoints (117/117) |
| 24-Templos-Y-Puzzles | ✅ Creado — DELEGABLE: framework emisor→receptor, 15 familias (121/121) |
| 25-Ruinas | ✅ Creado — DELEGABLE: kit modular ≤40 piezas, 13 tipos (116/116) |
| 26-Templo-Subterraneo | ✅ Creado — DELEGABLE: Templo de la Brisa, 7 anillos (114/114) |
| 22-Historia-Principal | ✅ Creado — DELEGABLE: 7 capítulos, 5 finales, grafo (94/94) |
| 23-Historias-Secundarias | ✅ Creado — DELEGABLE: 60 cadenas, contexto obligatorio (104/104) |
| 102-Bug-Tracking | ✅ Creado por DEVIN — GitHub Issues: plantillas, categorías, severidades, flujos, QA/Logging (140/140) |
| 69-Fast-Travel | ✅ Creado por B1-Nemotron — DELEGABLE: 143 ítems, 13 puntos sección 68, costo/restricciones/día-noche (143/143) |
| 104-Analytics | ✅ Creado por B1-Nemotron — DELEGABLE: privacidad por diseño, JSON agregado, opt-out M91 (100/100) |
| 118-CI-CD | ✅ Creado por B1-Nemotron — DELEGABLE: build Godot custom, deploy itch.io, alerts (100/100) |
| 131-Creditos | ✅ Creado por B1-Nemotron — DELEGABLE: equipos, traductores, assets licencias, accesibilidad (100/100) |
| 38-Economia | ✅ Creado por Deepseek V4 Flash — DELEGABLE: moneda, precios, tiendas, trueque, equilibrio cozy (158/158) |
| 58-Accesibilidad | ✅ Creado por Deepseek V4 Flash — DELEGABLE: visual, auditiva, motora, cognitiva, lectoescritura (173/173) |
| 70-Interacciones | ✅ Creado por Deepseek V4 Flash — DELEGABLE: detección, prompts, prioridad, estados, feedback (197/197) |
| 78-Legal-Propiedad-Intelectual | ✅ Creado por Deepseek V4 Flash — DELEGABLE: licencias, atribución, THIRD-PARTY-NOTICES (157/157) |
| 80-Legal-Privacidad | ✅ Creado por Deepseek V4 Flash — DELEGABLE: GDPR, COPPA, CCPA, consentimiento, opt-out (144/144) |
| 86-IA-Generativa | ✅ Creado por Deepseek V4 Flash — DELEGABLE: política IA, declaración Steam, registro de herramientas (129/129) |
| 62-Memoria | ✅ Creado por Deepseek V4 Flash — DELEGABLE: presupuesto RAM, pooling, GC, prevención de leaks (150/150) |
| 71-Progresion | ✅ Creado por Deepseek V4 Flash — DELEGABLE: desbloqueos, hitos, mejoras, logros, anti-frustración (213/213) |
| 92-Tutorial | ✅ Creado por Deepseek V4 Flash — DELEGABLE: onboarding inmersion, pistas contextuales, skip (185/185) |
| 112-Testing-Automatico | ✅ Creado por Deepseek V4 Flash — DELEGABLE: GUT/GdUnit4, CI headless, cobertura (230/230) |
| 133-Gestion-Del-Proyecto | ✅ Creado por Deepseek V4 Flash — DELEGABLE: metodología, hitos, DoD, tablero (127/127) |
| 135-Riesgos-Del-Proyecto | ✅ Creado por Deepseek V4 Flash — DELEGABLE: matriz de riesgos, mitigaciones, monitoreo (134/134) |
| 60-Datos-Y-Serializacion | ✅ Creado por Deepseek V4 Flash — DELEGABLE: JSON/binario, versionado, migraciones, saves (197/197) |
| 97-Steam-Store-Page | ✅ Creado por Deepseek V4 Flash — DELEGABLE: descripción, tags, capturas, precio, wishlists (195/195) |
| 101-QA-General | ✅ Creado por Deepseek V4 Flash — DELEGABLE: checklist por área, sesiones, regresión, release (205/205) |
| 108-Pipeline-De-Assets | ✅ Creado por Deepseek V4 Flash — DELEGABLE: formatos, importación, optimización, review (181/181) |
| 114-Playtest | ✅ Creado por Deepseek V4 Flash — DELEGABLE: sesiones, observación, encuestas, iteración (186/186) |
| 136-Roadmap | ✅ Creado por Deepseek V4 Flash — DELEGABLE: hitos M137-143, dependencias, prioridades (199/199) |
| 39-Tiendas | ✅ Creado por Deepseek V4 Flash — DELEGABLE: catálogos por NPC, horarios, stock renovable (181/181) |
| 40-Infraestructura | ✅ Creado por Deepseek V4 Flash — DELEGABLE: autoloads, servicios base, bootstrap (211/211) |
| 54-Mapa | ✅ Creado por Deepseek V4 Flash — DELEGABLE: mapa de exploración, minimapa, POI, marcas (170/170) |
| 72-Sistema-De-Logros | ✅ Creado por Deepseek V4 Flash — DELEGABLE: catálogo, desbloqueo, notificación, Steam sync (190/190) |
| 74-Eventos | ✅ Creado por Deepseek V4 Flash — DELEGABLE: festivales estacionales, repetibles, anti-FOMO (266/266) |
| 87-Localizacion | ✅ Creado por Deepseek V4 Flash — DELEGABLE: i18n/l10n, textos dinámicos, plurales (136/136) |
| 45-Arte-3D | ✅ Creado por Deepseek V4 Flash — DELEGABLE: estilo Cozy Voxel, techos de polígonos, LOD, sockets, kit modular, validador (157/157) |
| 46-Arte-2D | ✅ Creado por Deepseek V4 Flash — DELEGABLE: iconos, retratos con plantilla 3D, símbolos, atlas por superficie (109/109) |
| 47-Texturas-Y-Materiales | ✅ Creado por Deepseek V4 Flash — DELEGABLE: atlas de bloques 32px, variantes procedurales por bioma, kit de materiales, 4 shaders acotados, validador + presupuesto VRAM (107/107) |
| 48-Animacion | ✅ Creado por Deepseek V4 Flash — DELEGABLE: catálogo de 25 dominios, AnimationService con FSM espejo, LOD de animación, eventos en timelines, validador (122/122) |
| 49-Iluminacion | ✅ Creado por Deepseek V4 Flash — DELEGABLE: presets por franja M31, pool de luces dinámicas, baked lightmaps, niebla por bioma, topes por escena, validador (116/116) |
| 50-Vegetacion | ✅ Creado por Deepseek V4 Flash — DELEGABLE: 26+ especies por bioma, MultiMesh con LOD/culling, viento GPU determinista, estaciones, tala voxel, validador (117/117) |
| 51-Agua | ✅ Creado por Deepseek V4 Flash — DELEGABLE: 7 tipos de agua, nivel de mar global, mesh por chunk con olas/espuma, corrientes por spline, hielo estacional anti-softlock (129/129) |
| 52-Particulas-Y-VFX | ✅ Creado por Deepseek V4 Flash — DELEGABLE: catálogo de 25 efectos, pool GPUParticles, presupuesto por escena, trigger VFX+SFX+feedback, determinismo, sin luz por partícula (120/120) |
| 55-Diario-Del-Jugador | ✅ Creado por Deepseek V4 Flash — DELEGABLE: 14 categorías de registro, DiaryService por eventos, anti-spoilers, % de completado sobre descubierto, virtualización, persistencia GameState (130/130) |
| 56-Fotografia | ✅ Creado por Deepseek V4 Flash — DELEGABLE: modo foto (Fotostate M31), cámara réplica Navigator con zoom 0.5x-8x, 6-8 presets artísticos, poses por evento M07, álbum WebP con presupuesto 150 MB, compartición local con confirmación de privacidad (130/130) |
| 59-Guardado | ✅ Creado por Deepseek V4 Flash — DELEGABLE: SaveManager con encolado, escritura atómica .tmp+rename, checksum SHA-256, migración solo-hacia-delante (M60) con backup previo, rotación local de backups, snapshot por sistema vía ISaveProvider, disco lleno y 3+ slots (130/130) |
| 67-Vehiculos | ✅ Creado por Deepseek V4 Flash — DELEGABLE: presets de barco/dirigible/submarino + plantilla locomotora condicional M68, física acotada sin fluidos, chunk_target de streaming (M10/M61), docking con magnetismo suave (M28), baúl M14 con mejoras persistentes, personalización cozy, audio/animaciones con LOD (130/130) |
| 68-Transporte-Y-Navegacion | ✅ Creado por Deepseek V4 Flash — DELEGABLE: grafo central de paradas y rutas como única fuente de verdad, capa de transporte en el mapa (M54), señalización física consistente (M46), transición cozy sin perder al jugador (M61), costes con descuentos (M38/M20), viajes narrativos (M22/M23) y especiales (M74), coordinación con M69 por estaciones compartidas (130/130) |
| 73-Coleccionables | ✅ Creado por Deepseek V4 Flash — DELEGABLE: catálogo central de 22 categorías con ids unívocos, registro idempotente por eventos (M07), progreso anti-spoiler, colecciones completas con recompensa y desbloqueos (M71), vistas compartidas de museo (M37) y diario (M55), persistencia compacta (M59/M60) (130/130) |
| 75-Postgame | ✅ Creado por Deepseek V4 Flash — DELEGABLE: orquestador del contenido post-historia — epílogo (M22), hoja de ruta del 100% derivada y anti-spoiler (M55/M37/M73), logros finales categoría Epílogo (M72), eventos rotativos (M74/M29), catálogo de expansiones FASE 1/FASE 2 declarativo (M27/M51/M10/M16/M17) sin promesas al jugador, reglas cozy sin grindeo (130/130) |
| 76-Multijugador | ✅ Creado por Deepseek V4 Flash — DECISIÓN: v1 single-player cozy (argumentos de género y coste); contrato MP futuro completo (25 puntos del plan maestro): local couch primero (host autoritativo, progreso individual, anti-griefing por diseño, $0 servidores), online condicionado a hit >10k descargas (M77), economía protegida (M38: solo decoración), chat sin texto libre, manifiesto mp_contract.json + verificador validate_mp_contract.gd; implementación BLOQUEADA por producto (130/130) |
| 77-Online-Y-Red | ✅ Creado por Deepseek V4 Flash — CONTRATO: arquitectura de red futura (23 puntos del plan maestro) — cliente-servidor dedicado sobre P2P, snapshots @ 10 Hz por área, interpolación + predicción (latencia <200 ms), reconexión JWT <10 s, anti-trampas server-authoritative, seguridad API (TLS 1.3, rate limit), telemetría M64, autoscaling (1 instancia ≈ 200 CCU), backups RPO 15 min/RTO 2 h (M65), costes ~$230-370/mes condicionados a hit; net_contract.json + validate_net_contract.gd; BLOQUEADO por hit de M76, cero red en v1 (130/130) |
| 61-Rendimiento | ✅ Creado por Deepseek V4 Flash (RECLAMADO a GPT-5 por inactividad >24 h) — NORMA transversal: objetivo 60/30 FPS, presupuesto por categorías (16,5 ms @ 60 FPS), hardware min/recomendado, técnicas obligatorias con módulo dueño (culling, occlusion en cuevas/templos, LOD 3 niveles + impostor, batching por chunk, GPU instancing, pooling), bench scene oficial de 60 s, gate CI ±10 % (M116), cero allocations y GC en pausas seguras; budget_profile.gd + validate_budget.gd + budgets.cfg (130/130) |
| 153-Objetivo-Final | ✅ Creado por Deepseek V4 Flash (RECLAMADO a B2-Composer por inactividad >24 h) — VISIÓN: 19 objetivos del plan maestro (sección 152) convertidos en contrato O1-O19 con criterio verificable, indicador (playtest M113 / telemetría M104 / QA M101) y módulos dueños; regla de integración (cada módulo declara O#), subordinación a M151, prueba de visión para playtest, aplicación en M150 (Control Final); vision_contract.json + validate_vision.gd (130/130) |

> Reglas completas en `AGENTS.md` (raíz del proyecto). Coordinación global en `CHECKLIST-GLOBAL.md`.
| 88-Fuentes-Tipograficas | ✅ Creado por DEVIN — Fuentes Tipográficas: Nunito + Fredoka One, jerarquía visual, estilos UI, optimización, accesibilidad, localización (172/172) |
| 90-Configuracion-Grafica | ✅ Creado por DEVIN — Configuración Gráfica: 23 opciones gráficas, 4 presets, detección automática de hardware, menú de settings, integración con M58/M61/M88 (248/248) |
| 91-Configuracion-De-Audio | ✅ Creado por DEVIN — Configuración de Audio: 15 opciones de audio, 7 buses de audio, audio 3D, subtítulos, sonidos de interfaz, rango dinámico, compresión, dispositivo de salida, pruebas de audio, integración con M58/M87/M61 (239/239) |
| 81-Legal-Menores | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Cumplimiento COPPA/GDPR-K/LGPD, age gating, data sanitization, parental consent, IARC rating, políticas legales menores (110/110) |
| 82-Clasificacion-Por-Edades | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Sistemas IARC/ESRB/PEGI/CERO/GRAC/ACB/USK/ClassInd, descriptores de contenido, rating objetivo Everyone, validación automática, submissions (100/100) |
| 83-Licencias-De-Software | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Inventario de licencias, validación de compatibilidad, generación automática de notices, integración build pipeline, testing (100/100) |
| 84-Musica-Y-Audio-Legal | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Contratos de compositor/artistas, licencias de stock, créditos de audio, validación de audio IA, clearances (100/100) |
| 85-Modelos-3D-Legal | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Contratos de artistas 3D, licencias de stock, créditos, validación de modelos IA, verificación pre-build (100/100) |
| 115-Hardware | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Detección de hardware, ajuste automático de calidad, perfiles de rendimiento, soporte gamepads, dispositivos de entrada (100/100) |
| 119-Actualizaciones | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Sistema de updates, notificación, compatibilidad de saves, rollback, integración con plataformas (100/100) |
| 128-Identidad-De-Marca | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Logo, paleta, tipografía, manual de marca, trademarks, presencia online, merchandise (100/100) |
| 132-Produccion-De-Equipo | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Estructura organizativa, roles, comunicación, gestión de tareas, resolución de conflictos, onboarding (100/100) |
| 134-Presupuesto | 🔵 En curso por Nemotron 3 Ultra (OpenCode) — Desglose por categorías, control de gastos, proyecciones de ingresos, break-even, reserva imprevistos (100/100) |
