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
├── 01-Fundamentos-Del-Proyecto/                ← Base documental: decisiones y los 152 módulos
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
| 01-Fundamentos-Del-Proyecto | ✅ Creado — base documental (checklist de 152 módulos) |
| 02-Vision-Y-Concepto | ✅ Creado — 5 archivos, checklist de 172 ítems (162 completados; 10 pendientes con dueño en M02/QA/Publicación) |
| 03-Documentacion-Del-Proyecto | ✅ Creado — catálogo de 25 documentos, convenciones, hitos M1-M5, backlog; 5 docs generales *-ACTUAL.md creados |
| 04-Game-Engine | ✅ Creado — decisión Godot 4.x + Voxel Tools, stack y config de proyecto base (94/120; pendientes = instalación/M1) |
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
| 42-Sonido-Ambiental | ✅ Creado — DELEGABLE: banco por bioma, capas hora/clima (109/109) |
| 43-Efectos-De-Sonido | ✅ Creado — DELEGABLE: pool 24 voces, familia tonal (96/96) |
| 44-ASMR-Y-Feedback | ✅ Creado — DELEGABLE: recetas de capas, blacklist cozy (113/113) |
| 57-Interfaz-De-Control | ✅ Creado — DELEGABLE: capa de acciones, remapeo, prompts (119/119) |
| 63-Cargas-Y-Streaming | ✅ Creado — DELEGABLE: progreso real, LRU, precalentamiento (101/101) |
| 64-IA-De-NPC | ✅ Creado — DELEGABLE: FSM, rutinas, burbuja ≤60 (107/107) |
| 65-Animales-IA | ✅ Creado — DELEGABLE: manadas, migración, presupuesto (100/100) |
| 66-Anti-Softlock | ✅ Creado — DELEGABLE: invariantes, cofre, checkpoints (100/100) |
| 24-Templos-Y-Puzzles | ✅ Creado — DELEGABLE: framework emisor→receptor, 15 familias (100/100) |
| 25-Ruinas | ✅ Creado — DELEGABLE: kit modular ≤40 piezas, 13 tipos (100/100) |
| 26-Templo-Subterraneo | ✅ Creado — DELEGABLE: Templo de la Brisa, 7 anillos (100/100) |
| 22-Historia-Principal | ✅ Creado — DELEGABLE: 7 capítulos, 5 finales, grafo (100/100) |
| 102-Bug-Tracking | ✅ Creado por DEVIN — GitHub Issues: plantillas, categorías, severidades, flujos, QA/Logging (121/121) |

> Reglas completas en `AGENTS.md` (raíz del proyecto). Coordinación global en `CHECKLIST-GLOBAL.md`.
|| 88-Fuentes-Tipograficas | ? Creado por DEVIN � Fuentes Tipogr�ficas: Nunito + Fredoka One, jerarqu�a visual, estilos UI, optimizaci�n, accesibilidad, localizaci�n (218/218) |

|| 90-Configuracion-Grafica | ? Creado por DEVIN � Configuraci�n Gr�fica: 23 opciones gr�ficas, 4 presets, detecci�n autom�tica de hardware, men� de settings, integraci�n con M58/M61/M88 (248/248) |

|| 91-Configuracion-De-Audio | ? Creado por DEVIN � Configuraci�n de Audio: 15 opciones de audio, 7 buses de audio, audio 3D, subt�tulos, sonidos de interfaz, rango din�mico, compresi�n, dispositivo de salida, pruebas de audio, integraci�n con M58/M87/M61 (227/227) |
