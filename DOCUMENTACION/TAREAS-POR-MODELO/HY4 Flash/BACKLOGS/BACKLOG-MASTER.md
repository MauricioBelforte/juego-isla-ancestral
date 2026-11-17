# BACKLOG-MASTER — HY4 Flash

**Modelo:** HY4 Flash  
**Plataforma:** Kilo Code  
**Rol:** Tareas de alto volumen repetitivo, limpieza de backlogs, revisión de formato/documentación, verificación de checklists (formato, no contenido profundo), deep search ligero, documentación de tareas, bug triage asistido.  
**Fecha:** 2026-11-17

---

## Carpetas de tareas (por módulo)

Las carpetas de tarea por módulo se crearán a medida que el director asigne trabajo a HY4 Flash. Estructura esperada:

```
DOCUMENTACION/TAREAS-POR-MODELO/HY4 Flash/
├── BACKLOGS/
│   ├── BACKLOG-MASTER.md          ← este archivo
│   └── 00-Backlog-Original-PreSplit.md
└── {ID-Modulo}-Nombre/            ← creadas por módulo según se asignen tareas
```

---

## Estado actual

- **Tareas asignadas:** ninguna todavía (modelo nuevo en flota).
- **Canal de mensajes:** `Mensajes entre modelos/HY4 Flash/` (creado). Escribe mensajes directamente en su canal como el resto de la flota normal, no genera reportes separados.
- **Numeración:** `Mensajes entre modelos/HY4 Flash/NUMEROS_DISPONIBLES.txt` (números 1–200).

---

## Reglas de asignación (desde GUIA-COMPARATIVA-MODELOS-V1.md)

**Asignar a HY4 Flash:**
- Deep search, procesamiento de documentos, slides simples, demos frontend simples, computer use
- Bug triage asistido, limpieza de backlogs, revisión de formato/documentación
- Verificación de checklists (formato, no contenido profundo)

**NO asignar a HY4 Flash:**
- Código crítico largo-horizonte (→ Glyph Cluster)
- Análisis de arquitectura profunda (→ Glyph Cluster)
- Matemática de balance compleja (→ Reflection-Beam-1.0)

---

## Método de trabajo

1. Análisis profundo → citas de archivo:línea
2. 2 mejoras de diseño concretas con código (cuando aplique)
3. Conclusión técnica

**Razonamiento:** `variant: "standard"` (modelo flash, no forzar xhigh).

---

**Ficha técnica (fuente oficial Tencent, 2026-11-16):**
- 224B total params (64B Engram), 12B active/token
- Nativamente multimodal (imagen + texto), 1M contexto, >150 tps
- Arquitectura: hybrid attention, LatentMoE, Engram
- Precio aprox 1/20 de Hy4 (muy bajo costo)

---

**Modelo:** HY4 Flash  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-17

## Backlogs creados (17nov)

| Archivo | Tareas | Estado |
|---------|--------|--------|
| 01-Backlog-Limpieza-Backlogs.md (CERRADO 004 17nov) | 12 | PENDIENTE |
| 02-Backlog-Bug-Triage-Docs.md (CERRADO 005 17nov) | 12 | PENDIENTE |
| 03-Backlog-Verificacion-Checklist.md (CERRADO 006 17nov) | 12 | PENDIENTE |

**Total: 36 tareas en 3 backlogs. Prioridad: 01 -> 02 -> 03.**

- 04-Backlog-Verificacion-Progreso-GLOBAL.md (12 tareas, creada 17nov 04:03)

- 05-Backlog-Verificacion-Masiva-GLOBAL.md (12 tareas, creada 17nov 06:06)
