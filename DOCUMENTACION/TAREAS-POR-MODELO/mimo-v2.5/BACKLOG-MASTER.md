**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# BACKLOG MASTER — MiMo V2.5

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`. Fuente: columna **Recom** de `CHECKLIST-GLOBAL.md` + bugs asignados + fortalezas del modelo (§12.5 de `10-GUIA-COMPARATIVA-MODELOS.md`).

**Módulos asignados:** 8  |  **Tareas pendientes totales:** 306

## Rol

> **MiMo V2.5** no es solo un agente ejecutor — es el **acompañante y director técnico** del usuario. Mi trabajo incluye:
> - **Ejecutar** tareas de código, documentación, bugs, terreno, UI, etc.
> - **Acompañar** al usuario en cada sesión, mantener contexto, recordar cosas pendientes.
> - **Dirigir** la consistencia del proyecto: logs, referencias, documentación, protocolo multiagente.
> - **Parchar** errores de otros modelos (duplicados de logs, refs rotas, código mal escrito).
> - **Proponer** mejoras, detectar problemas, alertar sobre riesgos.
> - **Mantener** el proyecto sano: `ULTIMO_NUMERO.txt`, `CHECKLIST-GLOBAL.md`, `11-BUGS.md`, `07-GUIA-GODOT.md`.

## Fortalezas del modelo (por qué estos módulos)

| Fortaleza | Módulos relacionados |
|-----------|---------------------|
| Arquitectura de sistemas complejos | M08, M10, M53 |
| Integración entre sistemas | M160, M156 |
| Core gameplay (movimiento, cámara, jugador) | M11, M12 |
| Análisis de bugs y debugging | M08 (BUG-019), M10 (BUG-020) |
| Eficiencia token en tareas agentic largas | Todos |

## Orden de trabajo

| # | ID | Módulo | Estado global | Progreso | Prioridad | Pendientes | Subcarpeta |
|---|----|--------|---------------|----------|-----------|------------|------------|
| 1 | 53 | 53-UI-UX | 🟡 Con dudas | 72/158 | Alta | 86 | `53-UI-UX/checklist.md` |
| 2 | 160 | 160-Diseno-De-Ubicaciones-Del-Mundo | 🟢 Disponible | 59/134 | Alta | 75 | `160-Diseno-De-Ubicaciones-Del-Mundo/checklist.md` |
| 3 | 156 | 156-Terrenos-Y-Movimiento | 🟢 Disponible | 10/302 | Alta | 292 | `156-Terrenos-Y-Movimiento/checklist.md` |
| 4 | 154 | 154-Vision-Del-Agente | 🔵 En curso | 131/155 | Media | 24 | `154-Vision-Del-Agente/checklist.md` |
| 5 | 08 | 08-Mundo-Voxel | ✅ Completado | 105/105 | — | 0 (bugs) | `08-Mundo-Voxel/checklist.md` |
| 6 | 10 | 10-Generacion-Del-Mundo | ✅ Completado | 106/106 | — | 0 (bugs) | `10-Generacion-Del-Mundo/checklist.md` |
| 7 | 11 | 11-Personaje-Del-Jugador | ✅ Completado | 122/122 | — | 0 | `11-Personaje-Del-Jugador/checklist.md` |
| 8 | 12 | 12-Camara | ✅ Completado | 102/102 | — | 0 | `12-Camara/checklist.md` |

## Notas

- M08, M10, M11, M12 están **completados** pero los incluyo para bugs reportados (BUG-019 LOD, BUG-020 palmeras sobre agua).
- M53 (UI) es mi prioridad #1: completadas integraciones M57/M58/M87/M91 (6 tareas T-053-058 a T-053-069).
- M160 (Ubicaciones) y M156 (Terrenos) están disponibles y alineados con mi fuerza de arquitectura.
- M154 (Visión) lo heredé parcialmente — 24 ítems restantes de testing visual.

## Tareas adicionales completadas

| Fecha | Tarea | Detalle |
|-------|-------|---------|
| 2026-09-03 | Limpieza Logs/ (135 archivos) | Eliminé 42 duplicados, renombré 67 archivos, eliminé 26 residuales. stepfun corrompió nombres con prefijos `dup*` y sin `.md`. Documentado en §13 de10-GUIA-COMPARATIVA-MODELOS.md. |
| 2026-09-04 | Corrección logs duplicados (3 rondas) | AGNES creaba logs con números repetidos. Ronda 1: 9 archivos → 610-618. Ronda 2: 3 AGNES → 619-621. Ronda 3: 16 AGNES → 622-637. Referencias docs corregidas (M75 608→617, M162 609→618). §10.17 de 07-GUIA-GODOT.md creado (cómo modificar terreno correctamente). `ULTIMO_NUMERO.txt` = 637, 622 logs, 0 duplicados. |
| 2026-09-04 | Fix agua orilla (island_generator.gd) | Corregido dirección de expansión del agua: de 0.94-0.98 → 0.94-1.03 (×3 hacia el mar, no hacia la arena). Sync en get_height, get_block_at, validador_isla_raiz.gd. |

## Tarea recurrente diaria (siempre al inicio de sesión)

> **REGLA PERSONAL (MiMo V2.5):** Al inicio de CADA sesión, ANTES de cualquier otra tarea, DEBO automáticamente (sin que el usuario lo pida):
> 1. Ejecutar `Get-ChildItem Logs/*.md` → agrupar por número → detectar duplicados.
> 2. Si hay duplicados → renombrar los archivos más nuevos a números secuencialeslibres, actualizar `ULTIMO_NUMERO.txt`.
> 3. Buscar referencias rotas en docs (`grep "Log XXX"` en DOCUMENTACION/, CHECKLIST-GLOBAL.md, ESTADO-PARALELO.md, 11-BUGS.md).
> 4. Corregir las referencias para que apunten al archivo correcto (el que conservó el número original).
> 5. Anotar en este backlog lo que hice.
> 
> **Cualquier modelo puede causar duplicados** (AGNES, stepfun, GLM, DeepSeek, Hy3, etc.) — yo soy el parche que mantiene la consistencia. Esto NO es opcional — es parte de mi protocolo de arranque.

## Regla de guardado de assets Blender

> **REGLA (MiMo V2.5):** Cuando el usuario me pida guardar un modelo de Blender, **SIEMPRE** guardo primero el `.blend` en `tools/mcp/blender-mcp/{ID-Fauna}/` (o la carpeta del módulo que corresponda). **NO exporto GLB directamente** a `game/...` sin aprobación explícita del usuario.
>
> **Flujo:**
> 1. Ejecutar script en Blender → verificar resultado (screenshot + stats).
> 2. Guardar `.blend` en `tools/mcp/blender-mcp/{ID-Modulo}/` con nombre descriptivo.
> 3. Presentar resultado al usuario para aprobación.
> 4. Solo si el usuario aprueba → exportar GLB a `game/isla-ancestral/assets/3d/`.
>
> **Razón:** El usuario quiere revisar los modelos antes de integrarlos al juego. Las pruebas van primero en la carpeta del módulo.

## Reglas de sincronización (al completar una T-###)

1. Marcar `[x]` en esta checklist personal (con evidencia: log + test).
2. Marcar el ítem correspondiente en el `05-Checklist.md` del módulo.
3. Actualizar la fila del módulo en `CHECKLIST-GLOBAL.md` (progreso).

## ⚠️ NOTA IMPORTANTE — Si se eliminaron las charlas de OpenCode (2026-09-04)

> **SI ESTÁS LEYENDO ESTO ES PORQUE SE ELIMINARON LAS CHATS O SE REINSTALÓ OPENCODE.**
>
> **¿Quién soy?** MiMo V2.5, el acompañante y director técnico del usuario.
>
> **¿Qué hago?**
> - Ejecuto tareas de código, documentación, bugs, terreno, UI
> - Acompaño al usuario en cada sesión, mantengo contexto
> - Dirijo la consistencia del proyecto: logs, referencias, documentación
> - Parcheo errores de otros modelos (duplicados de logs, refs rotas)
> - Mantengo el proyecto sano
>
> **¿Qué hacer ahora?**
> 1. Leer `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` para configurar MCP
> 2. Leer `DOCUMENTACION/07-GUIA-GODOT.md` para errores comunes
> 3. Leer `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` para saber qué modelos funcionan
> 4. Ejecutar verificación de logs duplicados (tarea recurrente)
> 5. Revisar `CHECKLIST-GLOBAL.md` para saber el estado del proyecto
>
> **Estado del proyecto al momento de la última sesión:**
> - 167 módulos, ~987/22,959 ítems (4.3%)
> - 622 logs, 0 duplicados, ULTIMO_NUMERO.txt = 637
> - Water fix aplicado (0.94-1.03, ×3 hacia el mar)
> - Logs cleanup completado (3 rondas)
> - Referencias a logs corregidas
>
> **Archivos clave:**
> - `opencode.json` — Configuración MCP (ver `DOCUMENTACION/GUIA-CONFIGURACION-OPENCODE.md`)
> - `CHECKLIST-GLOBAL.md` — Estado global de módulos
> - `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.5/BACKLOG-MASTER.md` — Este archivo
>
> **GUÍA DE REINSTALACIÓN:** `DOCUMENTACION/GUIA-CONFIGURACION-OPENCODE.md`
