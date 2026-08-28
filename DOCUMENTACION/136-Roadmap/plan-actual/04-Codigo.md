**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 (implementación) · 2026-08-17 (documentación original por Deepseek V4 Flash)
**Componente:** 136-Roadmap
**Estado:** Implementación operativa completa (pendiente de QA cruzado)

---

# 04-Codigo.md — Módulo 136: Roadmap

## 1. Carácter del Componente

Módulo **administrativo / de planificación**: define la hoja de ruta del desarrollo (fases, hitos M137-M143, priorización MoSCoW, dependencias, calendario estimado y política de releases). No genera código de juego; genera **plantillas y documentos de planificación** en Markdown que operan junto a `CHECKLIST-GLOBAL.md` y los módulos de hitos M137-M143.

**06-Plan-Testings.md:** NO aplica como suite de pruebas automatizadas de código; las verificaciones del módulo son procedimentales (conteo de checklist, coherencia de hitos con la tabla global, simulación de replanificación) y se cubren en `05-Checklist.md`.

---

## 2. Archivos Previstos (implementación del módulo)

> ✅ **Implementado el 2026-08-28 por GLM (Kilo).** `ROADMAP.md` y los 7 checklists de hito ya existen con contenido real (estados de CHECKLIST-GLOBAL al 2026-08-28). La especificación se conserva abajo como referencia.

```
DOCUMENTACION/136-Roadmap/
├── plan-inicial/                       ← Documentación original (inmutable)
├── plan-actual/                        ← Documentación vigente (espejo)
│   ├── 01-Requerimientos.md
│   ├── 02-Analisis.md
│   ├── 03-Diseno.md
│   ├── 04-Codigo.md
│   ├── 05-Checklist.md
│   └── ROADMAP.md                      ← ✅ IMPLEMENTADO (hoja de ruta ejecutiva con estado real)
└── hitos/                              ← ✅ IMPLEMENTADO (checklist por hito)
    ├── 137-prototipo-checklist.md      ← ⬜ en preparación (M13/M14 🔵)
    ├── 138-vertical-slice-checklist.md
    ├── 139-prealpha-checklist.md
    ├── 140-alpha-checklist.md
    ├── 141-beta-checklist.md
    ├── 142-rc-checklist.md
    └── 143-lanzamiento-checklist.md
```

Fuera de la carpeta (ya existentes, se OPERAN, no se reimplementan):

```
CHECKLIST-GLOBAL.md                    ← Fuente de verdad del estado global (fila 136)
DOCUMENTACION/133-Gestion-Del-Proyecto/ ← Gestión (DoD, ceremonias, hitos M1-M7)
DOCUMENTACION/135-Riesgos-Del-Proyecto/ ← Riesgos que amenazan hitos
DOCUMENTACION/137...143...             ← Módulos de hitos (reciben este marco)
```

---

## 3. Especificación de Plantillas

### 3.1 Plantilla `ROADMAP.md` (PENDIENTE DE IMPLEMENTACIÓN)

```markdown
# Roadmap de Isla Ancestral (v1.0)

**Modelo:** [Nombre del modelo] · **Plataforma:** [Plataforma] · **Última actualización:** YYYY-MM-DD
**Estado global:** Fase actual → {Fase} · Hito en curso → {M1XX}

## Resumen ejecutivo (leer en 2 minutos)
- Visión: mundo voxel cozy en la isla Aurora (Godot 4.x + Voxel Tools, GDScript).
- Meta: v1.0 con el loop cozy completo y la isla Aurora navegable.
- Estrategia de lanzamiento: EA vs full release decidida en la beta (M141).

## Fases e hitos
| Hito | Fase | Estado | Criterios de salida clave | Duración estimada |
|------|------|--------|---------------------------|-------------------|
| M137 | Prototipo | ⬜ | Mundo voxel, cavar/colocar, guardar | 4-8 semanas |
| M138 | Vertical Slice | ⬜ | Slice jugable punta a punta, playtest | 8-14 semanas |
| M139 | Pre-Alpha | ⬜ | Loop de 30 min completo | 12-20 semanas |
| M140 | Alpha | ⬜ | Contenido v1.0 jugable | 12-20 semanas |
| M141 | Beta | ⬜ | Feature complete, equilibrio, decisión EA | 8-12 semanas |
| M142 | RC | ⬜ | Estable, compatible, performance OK | 4-8 semanas |
| M143 | Lanzamiento | ⬜ | v1.0 publicada + soporte | 2-6 semanas |

## Módulos por fase (resumen MoSCoW)
{Tabla o listado por fase con Must/Should/Could/Won't}

## Dependencias entre hitos
{M137 → M138 → M139 → M140 → M141 → M142 → M143 + dependencias de módulos}

## Riesgos que amenazan el calendario
{Top riesgos de M135 con impacto en fechas}

## Historial de cambios del roadmap
| Fecha | Cambio | Motivo | Autor |
|-------|--------|--------|-------|
```

### 3.2 Plantilla de checklist por hito (`hitos/NNN-*-checklist.md` — PENDIENTE DE IMPLEMENTACIÓN)

```markdown
# Checklist del Hito {M1NN} — {Nombre}

**Modelo:** [Nombre] · **Plataforma:** [Plataforma] · **Fecha de apertura:** YYYY-MM-DD

## Criterios de entrada
- [ ] {Criterio de entrada 1}
- [ ] {Criterio de entrada 2}

## Criterios de salida (todos verificables)
- [ ] {Criterio de salida 1}
- [ ] {Criterio de salida 2}

## Módulos incluidos (vinculados a CHECKLIST-GLOBAL.md)
| ID | Módulo | Prioridad (MoSCoW) | Estado |
|----|--------|--------------------|--------|

## Retrasos y cortes aplicados
| Fecha | Decisión | Impacto | Autor |
|-------|----------|---------|-------|

## Cierre del hito (checklist de cierre)
- [ ] Build etiquetado creado y jugable
- [ ] Playtest realizado y feedback registrado
- [ ] DoD verificada en todos los módulos del hito
- [ ] Log generado y roadmap actualizado
- [ ] Cierre firmado por el agente/fundador
```

### 3.3 Ejemplo de hito (uso de la plantilla, contenido orientativo)

```markdown
# Checklist del Hito M138 — Vertical Slice

## Criterios de salida (ejemplo)
- [ ] La zona del slice de la isla Aurora carga sin errores
- [ ] El jugador camina, corre y salta con la cámara cómoda
- [ ] El jugador interactúa con al menos 3 objetos del mundo (M70)
- [ ] Se cumple un objetivo corto del GDD (ej: despertar y encender el faro)
- [ ] El progreso se guarda y carga entre sesiones
- [ ] La UI mínima (inventario + pistas) funciona en la escena del slice
- [ ] El frame budget objetivo se cumple en el hardware de prueba
```

---

## 4. Funciones Clave de la Operación del Módulo

| Función | Descripción | Herramienta |
|---------|-------------|-------------|
| Consultar estado real | Verificar filas M137-M143 + 136 en `CHECKLIST-GLOBAL.md` | `scripts/verificar_checklist.py` |
| Abrir/cerrar hito | Marcar criterios en `hitos/NNN-*-checklist.md` y actualizar la tabla global | Markdown + `scripts/generar_checklist_global.py` |
| Recalcular calendario | Ajustar rangos de duración con datos del hito cerrado | `ROADMAP.md` (historial de cambios) |
| Decidir corte de alcance | Aplicar sección 7.2 de `03-Diseno.md` | Log del módulo + `5-FUTURAS-MEJORAS.md` |
| Registrar replanificación | Escribir cambio de fecha/alcance en el historial del roadmap | `ROADMAP.md` (historial) + `Logs/` (sección 6 de AGENTS.md) |

---

## 5. Contratos de Integración

### Entrada (desde otros módulos)

- **M133 (Gestión del Proyecto):** DoD, ciclo de ceremonias, plantilla de hitos y flujo multiagente (sección 21 de `AGENTS.md`).
- **M135 (Riesgos del Proyecto):** riesgos activos que amenazan el calendario y sus mitigaciones.

### Salida (hacia otros módulos)

- **M137 (Prototipo):** marco de fase 1, criterios de salida y calendario para su implementación.
- **M138 (Vertical Slice):** marco de fase 2, criterios de salida y dependencias del slice.
- **M139 (Pre-Alpha):** marco de fase 3 y loop principal de 30 minutos.
- **M140 (Alpha):** marco de fase 4 y contenido v1.0.
- **M141 (Beta):** marco de fase 5 y decisión EA vs full release.
- **M142 (RC):** marco de fase 6 y candidatos de release.
- **M143 (Lanzamiento):** marco de fase 7 y plan de lanzamiento.
- **`CHECKLIST-GLOBAL.md`:** fila 136 actualizada con progreso y notas del roadmap.

---

## 6. Pendientes del Módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear `ROADMAP.md` a partir de la plantilla de la sección 3.1 | **IMPLEMENTACIÓN DELEGADA** (cualquier agente que reclame el módulo) |
| Crear los 7 checklist por hito (`hitos/137..143`) desde las plantillas | **IMPLEMENTACIÓN DELEGADA** |
| Confirmar las duraciones del calendario con la disponibilidad real del fundador | Fundador (no delegable) |
| Asignar los módulos del plan maestro a cada fase con MoSCoW definitivo | Fundador + agentes (primera pasada delegable) |
| Decidir EA vs full release (se hace en la beta M141, no ahora) | Fundador, en su momento |
| Ejecutar la primera recalibración del calendario al cerrar el prototipo M137 | Agente/fundador en el cierre de M137 |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentacion completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Documenté el módulo 136 (Roadmap) completo: 5 archivos en `plan-inicial/` y su espejo en `plan-actual/`, siguiendo el estándar del proyecto (firma, estructura, DoD).
- Definí el problema administrativo del ordenamiento temporal de los 150+ módulos y los objetivos del roadmap.
- Analicé el dominio: roadmaps por fases vs por fechas, vertical slice como hito central, deuda técnica en el tiempo, hitos medibles con criterios de entrada/salida + DoD, y EA vs full release con decisión pospuesta a la beta (M141).
- Evalué 4 alternativas (fechas fijas, criterios, solo backlog, EA temprano) y documenté 8 decisiones.
- Diseñé los 7 hitos M137-M143 con criterios de entrada/salida, dependencias por hito, prioridades MoSCoW por fase, calendario estimado en rangos (50-88 semanas acumuladas, recalibrable) y política de builds etiquetados.
- Especifiqué los procesos de replanificación por retraso, corte de alcance y dependencia fallida.
- Definí archivos previstos (plantilla `ROADMAP.md`, checklist por hito) marcados como "Pendiente de implementación", y documenté la integración con M133, M135 y M137-M143.
- Redacté checklist de 199 ítems verificables distribuidos en todas las secciones (problema, RF, RN, análisis, diseño, hitos, integraciones, edge cases, documentación, testings).

### Lo que NO pude hacer (honestidad obligatoria)
- No creé `ROADMAP.md` ni los 7 checklist por hito: quedan como archivos previstos **Pendiente de implementación** (el módulo es documental; la implementación operativa es delegable).
- No asigné los módulos reales del plan maestro a cada fase con MoSCoW definitivo: la asignación requiere revisar los 150+ módulos uno a uno y es decisión del fundador junto al backlog real.
- Las fechas y duraciones del calendario son rangos estimados de documentación: **dependen del ritmo real del fundador** (tiempo parcial o completo) y deben recalibrarse al cerrar el prototipo M137.
- No decidí EA vs full release: esa decisión es del fundador y se toma en la beta (M141) con datos (wishlists, playtests), según la decisión D6 del diseño.
- No pude validar el rendimiento real de Voxel Tools ni verificar el checklist de hitos contra módulos ya implementados: depende del estado real de M137/M138.

### Recomendaciones para el próximo agente
- Al implementar, crear `ROADMAP.md` desde la plantilla de `04-Codigo.md` (sección 3.1) y los 7 checklist por hito desde la sección 3.2, completando el contenido con los módulos reales de la tabla global.
- Verificar contra `CHECKLIST-GLOBAL.md` que los módulos citados en las dependencias (M08, M10, M11, M63, etc.) coincidan con los ID reales del plan maestro antes de fijarlos en los checklist por hito.
- Consultar `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` para confirmar el desglose por disciplina y ajustar la asignación de módulos por fase.
- Confirmar con el fundador la disponibilidad semanal antes de convertir los rangos del calendario en estimaciones concretas.
- Cuando M137 (Prototipo) se cierre, recalibrar el calendario acumulado y registrar el ajuste en el historial de `ROADMAP.md`.
- Actualizar `CHECKLIST-GLOBAL.md` (fila 136: Alta, complejidad 2, dependencias 133 y 135) al completar la implementación y generar log en `Logs/` según la sección 6 de AGENTS.md.
- No tocar `plan-inicial/` (inmutable); cualquier ajuste va en `plan-actual/`.

---

## Notas del Agente

**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28 21:30:00
**Estado:** Completado (pendiente de QA cruzado)

### Lo que hice
- Implementé `ROADMAP.md`: resumen ejecutivo, fases/hitos con estado real, MoSCoW de primera pasada por fase (con módulos y estados de CHECKLIST-GLOBAL al 2026-08-28), dependencias entre hitos con estado real, top riesgos de M135 que amenazan el calendario, política de builds/etiquetas, edge cases operativos añadidos (los 5 no cubiertos por la documentación original) e historial de cambios.
- Implementé los 7 checklists de hito (`hitos/137..143`) con criterios de entrada/salida del diseño, módulos incluidos con MoSCoW y estado real, tabla de retrasos/cortes y checklist de cierre.
- Realicé la primera pasada de asignación de módulos a fases (delegable según el diseño) usando la guía 08 como fuente de orden y la tabla global como fuente de estado.
- Marqué el checklist 199/199 con evidencia por ítem y verifiqué la cobertura de los docs originales con grep (D1-D8, refactor, alternativas, edge cases) antes de marcar.
- Actualicé `04-Codigo.md` (implementación) y generé el log 198; reservé y liberé en los 4 registros.

### Lo que NO pude hacer (honestidad obligatoria)
- No confirmé las duraciones del calendario con la disponibilidad real del fundador (los rangos siguen siendo orientativos).
- El MoSCoW por fase es **primera pasada** delegable: la asignación definitiva requiere la revisión del fundador.
- No abrí ningún hito formal (M137 en preparación: su apertura requiere cerrar M13 y el núcleo de M14, más la ceremonia de planificación del fundador).
- No recalibré el calendario (el primer punto obligatorio es el cierre de M137, aún no cerrado).

### Recomendaciones para el próximo agente
- QA cruzado rápido: verificar los 9 archivos nuevos, coherencia de estados citados contra CHECKLIST-GLOBAL y checklist 199/199 sin `[?]`.
- Al cerrar M13/M14, abrir formalmente M137 con la plantilla del checklist de hito y ejecutar la ceremonia de planificación del fundador.
- Al cerrar M137, recalibrar el calendario acumulado y registrar el ajuste en el historial de `ROADMAP.md`.
- Mantener el historial del roadmap append-only; los cambios de fases siempre con log.