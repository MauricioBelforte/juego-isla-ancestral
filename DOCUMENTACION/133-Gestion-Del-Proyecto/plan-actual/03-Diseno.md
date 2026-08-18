**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Componente:** 133-Gestion-Del-Proyecto
**Estado:** Documentación inicial (plan original)

---

# 03-Diseno.md — Módulo 133: Gestión del Proyecto

## 1. Estructura de Gestión

### 1.1 Roles

| Rol | Titular | Responsabilidades |
|-----|---------|-------------------|
| **Fundador / Product Owner** | El humano | Visión, prioridades, decisiones finales, prueba de juego real |
| **Agente implementador** | Modelo IA (Claude, DeepSeek, Gemini, etc.) | Reclamar módulos, implementar, documentar, firmar, liberar |
| **Agente verificador (QA cruzado)** | Modelo IA distinto al implementador | Revisar módulos `✅` contra la DoD antes de considerarlos definitivos |
| **Administrador del protocolo** | Fundador o agente delegado | Mantener `ESTADO-PARALELO.md` y `CHECKLIST-GLOBAL.md` consistentes, detectar colgados |

Regla: el rol de QA cruzado **nunca** lo ejerce el mismo modelo que implementó el módulo (regla de independencia de la sección 21.8 de `AGENTS.md`).

### 1.2 Ceremonias (mínimas, livianas)

| Ceremonia | Frecuencia | Duración | Contenido |
|-----------|------------|----------|-----------|
| **Planificación de hito** | Al inicio de cada hito | 30-60 min | Elegir módulos del hito, asignar a agentes, definir criterios de salida |
| **Retrospectiva de hito** | Al cierre de cada hito | 30 min | Qué funcionó, qué no, ajustes al proceso; acta breve |
| **Revisión de estado** | Semanal | 15 min | Tabla global: módulos en curso, colgados (>24 h), dudas `🟡` |
| **Prueba de juego (fundador)** | Al cierre de cada hito | Indefinida | Jugar el vertical slice / prototipo y registrar feedback como issues |

Salidas: cada ceremonia genera un acta en la carpeta de gestión (ver `04-Codigo.md`), firma y fecha.

### 1.3 Hitos

| Hito | Módulo(s) clave | Objetivo | Criterio de salida |
|------|-----------------|----------|--------------------|
| M0 — Base documental | M01-M06, M133 (este) | Proceso y documentación base | 133 documentado, protocolo operativo, plantillas listas |
| M1 — Prototipo técnico | M137 (Prototipo) | Mundo voxel con cavar/colocar/guardar | M137 cumple DoD; jugable con los sistemas mínimos |
| M2 — Vertical slice | M138 (Vertical Slice) | Rebanada jugable de isla Aurora | Un área completa: mover, interactuar, un objetivo, guardado |
| M3 — Pre-alpha | M139 (Pre-Alpha) | Loop principal completo | Ciclo jugable de ~30 min con sistemas del GDD acotado |
| M4 — Alpha | Roadmap (M136) | Contenido de v1.0 jugable | Todos los sistemas v1.0 integrados, sin bloques críticos |
| M5 — Beta / lanzamiento | Roadmap (M136) | Estabilidad y pulido | Cero blockers, perf dentro de marco, build lista |

Cada hito queda documentado con la plantilla de hito (ver `04-Codigo.md`).

---

## 2. Flujo de Trabajo Operativo

### 2.1 Ciclo de un módulo (protocolo sección 21 de `AGENTS.md`)

```
┌────────────┐    ┌──────────────┐    ┌─────────────┐    ┌───────────┐
│ 1. Escanear │───▶│ 2. Reclamar   │───▶│ 3. Trabajar  │───▶│ 4. Marcar  │
│ tabla global│    │ y bloquear 🟢 │    │ + documentar│    │ [x]/[?]    │
└────────────┘    └──────────────┘    └─────────────┘    └─────┬─────┘
                                                                 │
                                          ┌──────────────────────┤
                                          ▼                      ▼
                              ┌───────────────────┐   ┌──────────────────┐
                              │ 5. QA cruzado     │   │ 5'. Liberar como  │
                              │ (otro modelo) ✅  │   │ 🟡 con dudas      │
                              └───────────────────┘   └──────────────────┘
```

Pasos detallados:

1. **Escanear**: leer `CHECKLIST-GLOBAL.md` + `ESTADO-PARALELO.md` antes de tocar nada.
2. **Reclamar**: estado → `🔵 En curso`, agente actual → nombre, última actividad → timestamp. Un módulo por agente.
3. **Trabajar**: documentación primero (sección 13 de `AGENTS.md`), luego implementación, luego testings (sección 14). No pisar archivos de otros agentes.
4. **Registrar resultado**: actualizar `05-Checklist.md` del módulo con `[x]` (cumple DoD) o `[?]` (honestidad obligatoria). Actualizar progreso de la tabla global.
5. **QA cruzado**: otro modelo revisa contra la DoD; si hay fallos, el módulo vuelve a `🟡` con notas en el historial.
6. **Cerrar**: log en `Logs/`, firma en documentos, actualizar tabla global y `ESTADO-PARALELO.md`.

### 2.2 Estados y su significado (fuente de verdad: tabla global)

| Estado | Uso | Transición |
|--------|-----|------------|
| `⬜` Sin iniciar | Módulo aún no tocado | → `🟢` cuando el backlog lo libera |
| `🟢` Disponible | Puede ser reclamado | → `🔵` al reclamar |
| `🔵` En curso | Bloqueado por un agente | → `🟡`/`✅`/`🟢` al liberar; `🔴` si hay riesgo |
| `🔴` En curso con riesgo | Atascado; otro agente puede reclamar tras 24 h | → `🟡`/`✅`/`🟢` |
| `🟡` Con dudas | Liberado con `[?]` pendientes | → `🔵` cuando otro agente lo retoma |
| `✅` Completado | DoD cumplida + QA cruzado | → `🟡` si QA encuentra fallos |

### 2.3 Coordinación de agentes (`ESTADO-PARALELO.md`)

Cada entrada nueva incluye: **tarea, agente, archivos involucrados, estado, timestamp**. Siempre se lee antes de trabajar; siempre se actualiza al reclamar, iniciar, bloquear y completar. Los agentes se identifican por nombre/modelo (Claude, DeepSeek, Gemini...).

---

## 3. Definición de Listo (DoD) — Adoptada de `AGENTS.md` 21.6

Un ítem se marca `[x]` solo si cumple **TODOS** estos criterios:

1. **Código implementado** y funcional (compila, entra en Play Mode sin errores; en Godot: sin errores en editor y runtime del vertical slice).
2. **Documentación actualizada**: `plan-actual/` refleja el estado real (y `plan-inicial/` queda intacto).
3. **Testings superados**: tests o verificaciones del plan del módulo ejecutados sin fallos.
4. **Log generado** en `Logs/` con el formato estándar.
5. **Firma del agente** en los documentos que modificó (modelo + plataforma).

Un módulo se marca `✅` en la tabla global solo si **todos** sus subitems cumplen la DoD **y** pasó el QA cruzado de un modelo distinto.

---

## 4. Tools: Tablero y Repositorio

### 4.1 GitHub Projects v2 (decisión D2)

| Elemento | Definición |
|----------|------------|
| Fuente de los ítems | Un issue por módulo (título = ID + nombre, descripción = enlace al `5-Checklist.md`) |
| Columnas (Single-select) | `⬜ Sin iniciar` · `🟢 Disponible` · `🔵 En curso` · `🟡 Con dudas` · `✅ Completado` |
| Campos extra | Prioridad (Alta/Media/Baja), Complejidad (1-5), Dependencias, Agente actual, Hito |
| Vistas | Vista Kanban (flujo diario) + vista Roadmap (hitos M0-M5) |
| Regla | El **estado real vive en `CHECKLIST-GLOBAL.md`**; el tablero se sincroniza manualmente al bloquear/completar módulos |
| Offline | Si no hay internet: se trabaja solo con Markdown local (los archivos en repo son la fuente durable) |

### 4.2 Repositorio (política adoptada de `AGENTS.md` sección 4)

- **Ramas**: `main` protegida (nunca commits directos) + ramas por módulo o por hito (`feat/138-vertical-slice`).
- **Commits**: español, tiempo pasado descriptivo ("Se agregó el sistema de guardado"), tamaño atómico.
- **Push**: solo bajo pedido explícito del usuario, siguiendo el protocolo de la sección 4.2 (comparar con `origin`, revisar diffs, redactar commit completo).
- **.gitignore**: respeta Godot 4.x (`.godot/`, `*.import`, etc.).
- **CI (si se activa)**: M118 (CI-CD) define el pipeline; la gestión solo exige que el estado no dependa de él para funcionar.

### 4.3 Documentación de gestión (ubicaciones)

```
DOCUMENTACION/
├── 133-Gestion-Del-Proyecto/
│   ├── plan-inicial/              ← Este diseño (inmutable)
│   └── plan-actual/               ← Espejo; se actualiza con cambios reales del proceso
├── CHECKLIST-GLOBAL.md            ← Tabla resumen global (raíz del proyecto)
└── Mensajes entre modelos/
    ├── ESTADO-PARALELO.md         ← Coordinación de agentes
    └── {NN}-Tema/                 ← Hilos de comunicación por tema
```

---

## 5. Gestión del Riesgo de Abandono (diseño D8)

| Mecanismo | Implementación |
|-----------|----------------|
| Hitos cortos y jugables | Vertical slice (M138) como objetivo motivador; cada hito termina en algo jugable |
| Progreso visible | Tabla global + tablero; completar módulos da señal de avance real |
| Variable "diversión" en retrospectivas | La retros pregunta: "¿este hito me dio energía o me la quitó?" |
| Pausas planificadas | Documentación autoexplicativa para retomar sin costo; guía "cómo retomar" en el README de gestión |
| Señales de alerta | 2+ semanas sin commits · tablero sin mover · retrospectiva pospuesta 2 veces → activar plan de recuperación (recortar alcance inmediato, celebrar un logro, pedir feedback externo) |
| Testers tempranos | Compartir el vertical slice con amigos/comunidad para recibir energía externa |
| Anti-root de tiempo | Sesiones con metas pequeñas; prohibido "maratón de 12 h" como hábito |

---

## 6. Flujo de Decisiones (ADR)

1. Todo cambio relevante de proceso/alcance/arquitectura se decide por ADR.
2. Plantilla mínima: **Contexto · Decisión · Opciones descartadas (con motivo) · Consecuencias · Fecha · Firma**.
3. Los ADRs viven en `DOCUMENTACION/133-Gestion-Del-Proyecto/plan-actual/adrs/`.
4. Si la decisión afecta a otro módulo, se registra además un log y se actualiza la documentación del módulo afectado.