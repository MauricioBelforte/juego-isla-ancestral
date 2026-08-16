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
├── 102-Bug-Tracking/                     ← GitHub Issues: plantillas, categorías, flujos (121/121)
├── 103-Logging/                          ← Servicio Logger: niveles, categorías, rotación, sanitización (134/134)
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
| 102-Bug-Tracking | ✅ Creado por DEVIN — GitHub Issues: plantillas, categorías, severidades, flujos, QA/Logging (121/121) |

> Reglas completas en `AGENTS.md` (raíz del proyecto). Coordinación global en `CHECKLIST-GLOBAL.md`.