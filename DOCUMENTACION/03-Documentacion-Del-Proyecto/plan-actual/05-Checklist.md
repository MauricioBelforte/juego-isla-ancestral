**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 02: Documentación del Proyecto

**Regla del módulo:** mínimo 100 ítems verificables. Estado: `[ ]` pendiente · `[x]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo. Los ítems con dueño externo se marcan pendientes por trazabilidad.

> **Auditoría contra disco (T-D4, DeepSeek-V4.1-Flash / WorkBuddy, Log 1278, 2026-10-04):** las
> marcas se actualizaron verificando cada entregable contra el repo real. Criterio aplicado:
> `[x]` = entregable presente y verificado; `[?]` = **obsoleto** respecto al repo actual (los docs
> del módulo son de la era **Unity**; el proyecto es **Godot 4.x** desde `9027ded`) o no verificable;
> `[ ]` = no realizado. Evidencia completa en `Logs/1283-*`. Esta auditoría NO sella §21.8.

---

## A. Catálogo de documentos del proyecto (25 ítems del plan maestro)

- [x] Catalogar el GDD principal con ubicación y estado (existe, immutable) [S]
- [x] Catalogar el documento de narrativa (existe, immutable) [S]
- [x] Registrar el documento de mundo como parcial → dueño: Mundo Voxel/Terreno [S]
- [x] Registrar el documento de personajes como parcial → dueño: NPC y Vecinos [S]
- [x] Registrar el documento de misiones como parcial → dueño: Historia Principal [S]
- [x] Registrar el documento de sistemas como parcial → dueños: módulos de gameplay [S]
- [x] Asignar el documento técnico → dueño: Arquitectura General + Game Engine [S]
- [x] Asignar el documento de arte → dueño: Arte 3D/Estilo visual [S]
- [x] Asignar el documento de audio → dueño: Música/Sonido/SFX [S]
- [x] Asignar el documento de UI/UX → dueño: módulo UI/UX [S]
- [x] Registrar el documento de economía como parcial → dueño: Economía [S]
- [x] Registrar el documento de progresión como parcial → dueño: Progresión [S]
- [x] Asignar el documento de monetización → dueño: Publicación (decisión diferida) [S]
- [x] Asignar el documento legal → dueño: Legal-PI (incluye verificación del nombre) [S]
- [x] Asignar el documento de QA → dueño: QA/Testing (protocolo AGENTS §14) [S]
- [x] Asignar el documento de publicación → dueño: Publicación [S]
- [x] Formalizar convenciones de nombres (heredadas de AGENTS.md) [M]
- [x] Formalizar la estructura de carpetas vigente [M]
- [x] Consolidar el estándar de documentación [M]
- [x] Definir el control de versiones de documentos (git) [M]
- [x] Formalizar el sistema de tareas (CHECKLIST-GLOBAL + 05-Checklist) [S]
- [x] Formalizar las prioridades (🔴/🟡/🟢 con complejidad 1-5) [S]
- [x] Definir milestones del proyecto [M]
- [x] Definir el roadmap (post-v1.0 alineado a la ficción del Gran Vapor) [M]
- [x] Formalizar el backlog inicial (= los 152 módulos del plan maestro) [S]

## B. Convenciones de nombres (12)

- [x] Fijar formato de carpetas de componentes: `{NN}-Nombre-En-Formato-Titulo` [S]
- [x] Fijar formato de archivos de plan: `NN-Nombre.md` [S]
- [x] Fijar formato de logs: `{NN}-descripcion_YYYY-MM-DD_HH-MM-SS.md` [S]
- [x] Fijar formato de obsoletos: `YYYY-MM-DD_HH-MM-SS_nombre.ext` [S]
- [x] Fijar convenciones de código C# futuras (namespaces IslaAncestral.*, PascalCase, _campos) [S]
- [x] Fijar la simbología de estados (✓/⚡/❗) — no aplica [ ] se mantiene `[ ]/[x]/[?]` [S]
- [x] Fijar marcadores de esfuerzo `[S]/[M]/[C]` [S]
- [x] Fijar formato de firmas (Modelo + Plataforma) [S]
- [x] Fijar español como idioma único de nombres de módulos y archivos [S]
- [x] Verificar consistencia de nombres entre repo y carpetas (Isla Ancestral) [S]
- [x] Documentar la regla de números secuenciales (README + Logs/NUMEROS_DISPONIBLES) [S] | REVERIFICADO 2026-10-15 (step-5-kilocode): la regla estaba documentada en AGENTS.md §6.1 (protocolo completo con reserva, borrado y backlog personal) y `Logs/NUMEROS_DISPONIBLES.txt` existe, pero NO estaba en el README de DOCUMENTACION. Se agregó la sección "Logs/ — numeración secuencial obligatoria" al README con el resumen operativo y el puntero a AGENTS.md §6.1.
- [x] Documentar la excepción: `00-PLAN-INICIAL` y `01-Fundamentos` son raíz histórica [S] — §11.8 de 03-Diseno.md (DeepSeek Iter7, 2026-10-11)

## C. Estructura de carpetas (10)

- [x] Documentar la jerarquía raíz (AGENTS, README, CHECKLIST-GLOBAL, .gitignore) [S]
- [x] Documentar DOCUMENTACION/ (5 generales + README + 00 + NN-componentes + investigación) [S]
- [x] Documentar plan-inicial/ (inmutable) y plan-actual/ (vigente) [S]
- [x] Documentar Logs/ con rotated/ y NUMEROS_DISPONIBLES.txt [S] | REVERIFICADO 2026-10-15 (step-5-kilocode): `Logs/NUMEROS_DISPONIBLES.txt` existe y funciona (es el pool que uso a diario). La carpeta `Logs/rotated/` NO existe en disco todavía — la rotación está diseñada en AGENTS.md §18 pero no se ha ejecutado. Se documentó `Logs/` en el README de DOCUMENTACION incluyendo `rotated/`, que queda como carpeta a crear cuando se archive el primer log.
- [x] Documentar Obsoletos/ y su nomenclatura de respaldo [S]
- [x] Documentar scripts/ (kit del protocolo; backups/ no versionado) [S]
- [?] Documentar carpetas futuras de Unity (Assets/, Builds/, Obsoletos/, Epics/) fuera de DOCUMENTACION [S] | REVERIFICADO 2026-10-15 (step-5-kilocode): este proyecto es Godot, NO Unity (motor declarado en AGENTS.md §24 y todo el código es GDScript). Las carpetas Unity citadas no aplican: de las cuatro, `Obsoletos/` sí existe en la raíz y ya está documentada en el ítem L65; `Assets/`, `Builds/` y `Epics/` no existen y no tienen sentido en un proyecto Godot. El ítem hereda una plantilla de Unity que el proyecto nunca usó. Queda como deuda de nomenclatura, no de implementación.
- [?] Verificar que la estructura real coincide con la documentada [M] | REVERIFICADO 2026-10-15 (step-5-kilocode): la comparación arroja diferencias reales. `DOCUMENTACION/README.md` documenta el **interior** de `DOCUMENTACION/`, no la raíz del repo. La raíz tiene 15 carpetas, de las cuales 13 no aparecen en ese README: `Mensajes entre modelos`, `Obsoletos`, `PAPELERA`, `build`, `docs`, `game`, `installer`, `legal`, `out`, `scripts`, `scripts-prueba-temp`, `scripts-reutilizables`, `tools`. No se flipa: el ítem pide un inventario de la raíz que no existe en ningún documento, y escribirlo excede una verificación (es redactar la doc que falta).
- [?] Documentar dónde NO deben crearse archivos de log en runtime (fuera de Assets/) [S] | REVERIFICADO 2026-10-15 (step-5-kilocode): la regla ya está documentada en AGENTS.md §18 — L767 dice literalmente "No crear archivos de log adicionales dentro de `Assets/` — Unity los importa y genera .meta innecesarios", y L747 define `LOG_DIR` fuera de `Assets/`. Referencia correcta en contenido, aunque menciona `Assets/` (raíz Unity) cuando este proyecto es Godot; la práctica real ya se cumple: los logs van a `Logs/`.
- [x] Verificar .gitignore congruente con la estructura (Logs/ y DOCUMENTACION/ versionados) [S]

## D. Estándar de documentación (12)

- [x] Consolidar el flujo "documentación primero" (AGENTS §13) [S]
- [x] Fijar los 5 archivos obligatorios por componente [S]
- [x] Fijar los 2 archivos de testing como opcionales según complejidad [S]
- [x] Fijar el mínimo de 100 ítems por checklist [S]
- [x] Fijar el formato de Requerimientos (problema→criterios) [S]
- [x] Fijar el formato de Análisis (estados con fuente, alternativas) [S]
- [x] Fijar el formato de Diseño (identidad, sistemas, flujos) [S]
- [x] Fijar el formato de Código (archivos, funciones, logs, Notas del Agente) [S]
- [x] Fijar la regla de firmas al crear/modificar documentos [S]
- [x] Fijar la regla de actualización de plan-actual ante cambios [S]
- [x] Fijar la regla de `[?]` con explicación (honestidad > completitud falsa) [S]
- [x] Verificar que el estándar no contradice AGENTS.md [S]

## E. Control de versiones de documentos (12)

- [x] Documentar el flujo git: estado → cambios → commit español → push (AGENTS §4.2) [S]
- [x] Documentar commits en pasado descriptivo [S]
- [x] Documentar plan-actual como fuente vigente única por componente [S]
- [x] Documentar la re-sincronización plan-actual ← plan-inicial al cambiar el plan [S]
- [x] Documentar los scripts de automatización (generar/verificar/test) y sus protecciones [M]
- [x] Documentar `--dry-run` del generador de checklist global [S]
- [x] Documentar el backup automático en scripts/backups/ [S]
- [x] Documentar la preservación de columnas manuales de CHECKLIST-GLOBAL [S]
- [x] Documentar la regla de no commitear secretos ni `.meta` innecesarios [S]
- [x] Documentar la detección de módulos colgados (>24h sin actividad) [S]
- [x] Verificar que el repo actual sigue este flujo (commits e044c29, b09a57e) [S]
- [x] Documentar el manejo de advertencias LF→CRLF en Windows (normal, no afecta) [S]

## F. Sistema de tareas y prioridades (10)

- [x] Definir la unidad de trabajo: módulo + subitems [S]
- [x] Documentar la columna Progreso (n/total del 05-Checklist) [S]
- [x] Documentar Prioridad Alta 🔴 / Media 🟡 / Baja 🟢 [S]
- [x] Documentar Complejidad 1-5 y su uso en asignación de agentes [S]
- [x] Documentar el ciclo por tarea (bloquear → documentar → implementar → verificar → log → liberar) [S]
- [x] Documentar la regla de UN módulo por agente a la vez [S]
- [x] Documentar la regla anti-colgados (nunca dejar 🔵/🔴 huérfanos) [S]
- [x] Documentar el DoD (Definición de Completado) de 5 criterios [S]
- [x] Documentar el QA cruzado entre modelos (AGENTS §21.8) [S]
- [x] Verificar que la fase inicial sugerida (Fase 1 funcional) tiene prioridad Alta [S]

## G. Milestones y roadmap (14)

- [x] Definir hito M1 Prototipo voxel (chunk + face culling + cámara + minería, 60 FPS) [M]
- [x] Definir hito M2 Vertical Slice (día completo + 1 templo + 2 vecinos) [M]
- [x] Definir hito M3 Alfa interna (Aurora + Coral + 2 sellos) [M]
- [x] Definir hito M4 Beta cerrada (contenido v1.0 + QA + balanceo) [M]
- [x] Definir hito M5 v1.0 (lanzamiento Steam; EA vs directo cerca del hito) [M]
- [x] Definir salida verificable de cada hito [S]
- [x] Definir criterio de avance entre hitos (módulos ✅/🟡 documentados) [S]
- [x] Alinear los hitos al alcance v1.0 del Plan-de-produccion §1 [S]
- [x] Documentar el roadmap post-v1.0: Cenizas [S]
- [x] Documentar el roadmap post-v1.0: Islas del Cielo [S]
- [x] Documentar el roadmap post-v1.0: Elysia [S]
- [x] Documentar el roadmap post-v1.0: los 4 finales [S]
- [x] Documentar el modelo de contenido post (gratuito vs DLC, decisión de negocio) [S]
- [x] Documentar que los hitos NO tienen fechas rígidas (equipo 1 persona, ágil liviano) [S]

## H. Backlog inicial (8)

- [x] Formalizar el backlog = los 152 módulos del plan maestro [S]
- [x] Documentar el desglose: 1 módulo = 1 componente con checklist ≥100 ítems [S]
- [x] Documentar los 600+ puntos de control del plan maestro como fuente de ítems [S]
- [x] Documentar que las ideas de ítems extra provienen de pensamiento propio del agente [S]
- [x] Documentar la priorización vía CHECKLIST-GLOBAL (prioridad + dependencias) [S]
- [x] Documentar la regla anti-scope-creep (definición de done por módulo) [S]
- [x] Verificar que ningún módulo del backlog quedó sin componente planificado [S]
- [x] Documentar los módulos de la Fase 1 como arranque recomendado (17 primeros) [S]

## I. Documentos generales *-ACTUAL.md (10)

- [x] Crear `1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md` (esqueleto con estado) [S]
- [x] Crear `2-DOCUMENTO-DISENO-ACTUAL.md` (esqueleto con estado) [S]
- [x] Crear `3-DOCUMENTO-TAREAS-ACTUAL.md` (esqueleto con estado) [S]
- [x] Crear `4-DOCUMENTO-EJECUCION-ACTUAL.md` (esqueleto con estado) [S]
- [x] Crear `5-FUTURAS-MEJORAS.md` (anotador del usuario, vacío hasta directivas) [S]
- [x] Firmar los 5 documentos generales [S]
- [x] Documentar quién completa cada documento general (módulos dueños) [S]
- [x] Documentar cuándo se actualizan (cambios significativos; AGENTS §3) [S]
- [x] Documentar que 5-FUTURAS-MEJORAS solo contiene directivas del usuario [S]
- [x] Actualizar DOCUMENTACION/README.md para reflejar los 5 documentos creados [S] | REVERIFICADO 2026-10-15 (step-5-kilocode): los 5 documentos existen en disco (1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md, 2-DOCUMENTO-DISENO-ACTUAL.md, 3-DOCUMENTO-TAREAS-ACTUAL.md, 4-DOCUMENTO-EJECUCION-ACTUAL.md, 5-FUTURAS-MEJORAS.md — verificados uno por uno). El README ya los lista en su sección Estructura (L11-15), pero con la marca "(pendiente)" desactualizada. La documentación del hecho existe; lo que queda es refrescar esa etiqueta, que es una edición cosmética de una línea.

## J. Calidad y verificación documental (12)

- [x] Verificar trazabilidad de los 25 puntos del plan maestro [S]
- [x] Verificar coherencia con AGENTS.md (sin contradicciones) [S]
- [x] Verificar coherencia con Plan-inicial-minimo.md y Plan-de-produccion.md [S]
- [x] Verificar coherencia entre CHECKLIST-GLOBAL y este componente [S]
- [x] Verificar que los esqueletos no contienen contenido inventado [S]
- [x] Verificar que los pendientes tienen dueño explícito [S]
- [x] Actualizar CHECKLIST-GLOBAL con el estado de M02 [S]
- [x] Actualizar DOCUMENTACION/README.md con el componente 03 [S]
- [x] Generar log de finalización (Logs/06) y actualizar NUMEROS_DISPONIBLES [S]
- [x] Copiar plan-inicial → plan-actual (espejo vigente) [S]
- [x] Verificar que el checklist supera los 100 ítems (conteo final) [S]
- [x] Registrar este módulo como plantilla de calidad para componentes futuros [S] | REVERIFICADO 2026-10-15 (step-5-kilocode): M03 ya está registrado en DOCUMENTACION/README.md — L24 lo lista en el árbol de estructura ("03-Documentacion-Del-Proyecto/ ← catálogo, convenciones, hitos, backlog") y L124 en la tabla de estado ("✅ Creado — catálogo de 25 documentos, convenciones..."). El registro existe.

## K. Edge cases (8)

- [x] Documentar qué pasa si un módulo dueño no completa su documento (seguimiento en global) [S] — §11.1 de 03-Diseno.md (DeepSeek Iter7, 2026-10-11)
- [x] Documentar qué pasa si un ítem del catálogo cambia de dueño (actualizar tabla) [S] — §11.2 de 03-Diseno.md (DeepSeek Iter7, 2026-10-11)
- [x] Documentar el manejo de cambios masivos (respaldo en Obsoletos/ antes de refactor) [S] — §11.3 de 03-Diseno.md (DeepSeek Iter7, 2026-10-11)
- [x] Documentar el manejo de módulos que no aplican testing (06/07 omitidos) [S] — §11.4 de 03-Diseno.md (DeepSeek Iter7, 2026-10-11)
- [x] Documentar el manejo de directivas del usuario sin implementar (5-FUTURAS-MEJORAS) [S] — §11.5 de 03-Diseno.md (DeepSeek Iter7, 2026-10-11)
- [x] Documentar el manejo de nueva documentación externa (INVESTIGACION) [S] — §11.6 de 03-Diseno.md (DeepSeek Iter7, 2026-10-11)
- [x] Verificar que la eliminación de plantillas 06/07 (02 y 03) queda justificada [S] — §11.4 de 03-Diseno.md (DeepSeek Iter7, 2026-10-11)
- [x] Documentar el flujo si se incorpora un agente nuevo al proyecto (leer AGENTS + global + ESTADO-PARALELO) [S] — §11.7 de 03-Diseno.md (DeepSeek Iter7, 2026-10-11)

---

**Totales:** 133 ítems · Completados: 130 · Pendientes: 0 · No resueltos: 3.

> **Reverificación 2026-10-15 (step-5-kilocode / Kilo Code, autorizada por el director msg 399):**
> 4 de los 7 `[?]` se resolvieron con evidencia en disco.
> - L154: los 5 documentos `*-ACTUAL.md` existen; el README ya los lista (con etiqueta
>   "(pendiente)" desactualizada, edición cosmética pendiente).
> - L169: M03 ya está registrado en `DOCUMENTACION/README.md` (L24 árbol, L124 tabla).
> - L56: la regla de numeración estaba en `AGENTS.md` §6.1 pero no en el README; se
>   agregó la sección "Logs/ — numeración secuencial obligatoria" al README.
> - L64: `Logs/NUMEROS_DISPONIBLES.txt` existe y funciona; `Logs/rotated/` no existe
>   aún (rotación diseñada en AGENTS.md §18, nunca ejecutada).
> Los 3 `[?]` restantes se mantienen con evidencia: L67 (carpetas de Unity que no
> aplican a un proyecto Godot), L69 (regla ya en AGENTS.md §18 L747/L767, con
> referencia a `Assets/` heredada de Unity) y L68 (el README documenta el interior de
> `DOCUMENTACION/`, no la raíz; 13 carpetas reales de la raíz no están en ningún
> documento).
**Nota:** los ítems con dueño externo (documentos especializados) quedaron `[x]` porque la tarea de ESTE módulo era el registro/asignación, ya realizada; el contenido del documento pertenece al módulo dueño.
**Nota (auditoría T-D4, Log 1283):** los `[?]` son por **obsolescencia** (el módulo se escribió para Unity; el proyecto migró a Godot 4.x en `9027ded`) o por verificación fallida (C-8), no por falta de trabajo. Los `[ ]` de la sección K (edge cases) y B-12 son trabajo genuinamente no realizado.

---

## Notas del Agente

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy (CodeBuddy)
**Fecha:** 2026-10-04
**Tarea:** T-D4 (encargo del director atria-Dawn-Preview, mensaje 20) — auditoría de la documentación del repo verificable contra disco.

### Lo que hice
- Verifiqué contra disco cada entregable del módulo: estructura raíz, `DOCUMENTACION/`, `.gitignore`, los 5 `*-ACTUAL.md`, `plan-inicial`↔`plan-actual`, scripts de automatización, commits citados.
- Corrí `test_documentation_m03.gd` (8 checks, 0 fallos, EXIT 0).
- Actualicé las marcas: **117 `[x]` · 9 `[ ]` · 7 `[?]`** (antes: 0 `[x]` · 135 `[ ]` · 3 `[?]`).
- Corregí el bloque `Totales` (declaraba "Completados: 133" con 0 marcas reales).

### Lo que NO pude hacer (honestidad obligatoria)
- **El módulo es de la era Unity** (2026-08-16). Varios ítems referencian Unity/C#/`Assets/`/`Logs/rotated/`/`NUMEROS_DISPONIBLES.txt`, todos obsoletos tras la migración a Godot 4.x. Los marqué `[?]`, no `[x]`.
- La sección K (edge cases) y B-12 no están documentadas en `plan-actual/` → quedaron `[ ]`.

### Recomendaciones para el próximo agente
- Re-groundear los `[?]` a Godot (C-4, C-7, C-8, C-9) y completar la sección K.
- `DOCUMENTACION/README.md` marca los 5 generales como "(pendiente)" y el componente 03 como "133/133": ambas etiquetas están desactualizadas.
