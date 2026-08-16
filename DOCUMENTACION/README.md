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

> Reglas completas en `AGENTS.md` (raíz del proyecto). Coordinación global en `CHECKLIST-GLOBAL.md`.