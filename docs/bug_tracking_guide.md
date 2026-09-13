# Guía de Bug Tracking — Isla Ancestral

## Índice
1. [Introducción](#introducción)
2. [Para Testers: Cómo reportar bugs](#para-testers-cómo-reportar-bugs)
3. [Para Desarrolladores: Cómo priorizar y corregir](#para-desarrolladores-cómo-priorizar-y-corregir)
4. [Proceso de Triage](#proceso-de-triage)
5. [Proceso de Verificación](#proceso-de-verificación)
6. [Ejemplos de bugs bien reportados](#ejemplos-de-bugs-bien-reportados)
7. [Ejemplos de bugs mal reportados](#ejemplos-de-bugs-mal-reportados)
8. [Métricas de calidad](#métricas-de-calidad)
9. [Referencias rápidas](#referencias-rápidas)

---

## Introducción

Este documento describe el sistema de seguimiento de bugs del proyecto **Isla Ancestral** usando **GitHub Issues**. El objetivo es estandarizar cómo reportamos, priorizamos, corregimos y verificamos bugs durante todo el ciclo de desarrollo (prototipo → release).

**Herramienta:** GitHub Issues (gratis, integrado en el repo, conocido por el equipo)  
**Plantilla:** `.github/ISSUE_TEMPLATE/bug_report.md`  
**Labels:** Predefinidas para severidad, prioridad, categoría y estado

---

## Para Testers: Cómo reportar bugs

### 1. Antes de crear el issue
- **Busca duplicados:** Usa la barra de búsqueda de GitHub Issues con palabras clave del bug
- **Reproduce el bug:** Confirma que puedes reproducirlo consistentemente (o documenta cuándo ocurre intermitentemente)
- **Captura evidencia:** Screenshots, logs, video si es posible

### 2. Crear el issue
1. Ve a **Issues → New issue → Bug Report**
2. Completa **TODOS** los campos obligatorios:
   - **Descripción:** Breve y clara (ej: "NPC Catalina no interactúa tras completar diálogo")
   - **Severidad:** Elige una (ver [Matriz de decisión](#matriz-de-decisión-severidad-vs-prioridad))
   - **Categoría:** Elige una (Gameplay, UI/UX, Audio, Render/Física, etc.)
   - **Prioridad:** Elige una (Inmediata, Alta, Media, Baja)
   - **Pasos para reproducir:** Numerados, específicos, sin ambigüedad
   - **Comportamiento esperado vs actual:** Qué debería pasar vs qué pasa
   - **Reproducibilidad:** Siempre / A veces / Nunca
   - **Contexto técnico:** Versión, plataforma, specs, **seed** (si mundo procedural), **save** (si persistencia)
   - **Evidencia:** Adjunta logs, screenshots, enlaces a videos
   - **Referencias:** Issues relacionados (#), módulos afectados (MXX, MYY)

### 3. Reglas de oro para testers
| Regla | Descripción |
|---|---|
| **Metadata obligatoria** | Severidad, categoría y al menos 1 paso de reproducción son requeridos |
| **Contexto procedural** | Bugs de generación de mundo (M08/M10) **SIEMPRE** requieren seed |
| **Contexto persistencia** | Bugs de guardado/carga (M59) **SIEMPRE** requieren archivo de guardado |
| **Sin duplicates** | Busca antes de crear; si es duplicate, comenta en el original y cierra el nuevo |
| **Evidencia útil** | Screenshot del bug + log de la sesión (Logs/*.md) mínimo |

---

## Para Desarrolladores: Cómo priorizar y corregir

### Matriz de decisión: Severidad vs Prioridad

| Severidad \ Prioridad | Inmediata 🔥 | Alta ⚡ | Media 📌 | Baja 📝 |
|---|---|---|---|---|
| **Crítico** 🔴 | Hotfix ya | Sprint actual | ⚠️ Excepción | ❌ No aplica |
| **Mayor** 🟠 | ⚠️ Solo si bloquea milestone | Sprint actual | Backlog cercano | ⚠️ Excepción |
| **Menor** 🟡 | ❌ No aplica | ⚠️ Solo si acumulado | Backlog | Eventual |
| **Trivial** ⚪ | ❌ No aplica | ❌ No aplica | ⚠️ Solo si acumulado | Eventual |

### Definiciones

**Severidad (impacto técnico):**
- **Crítico:** Bloquea release, crash, data loss, feature principal rota
- **Mayor:** Bloquea milestone, feature secundaria rota, workaround difícil
- **Menor:** No bloquea, workaround fácil, comportamiento incorrecto menor
- **Trivial:** Cosmético, typo, alineación visual, sugerencia

**Prioridad (orden de atención):**
- **Inmediata:** Hotfix en producción o bloquea a todo el equipo
- **Alta:** Sprint actual, comprometido en milestone
- **Media:** Backlog cercano, planificado para próximo sprint
- **Baja:** Eventual, nice-to-fix, technical debt

### Flujo de trabajo para desarrolladores

```
Nuevo (status:new) 
    ↓ Triage por QA Lead
En Progreso (status:in-progress) ← Asignado a @desarrollador
    ↓ Fix implementado + tests
Verificado (status:verified) ← Listo para QA
    ↓ QA verifica ✅
Cerrado (status:closed) ← "Fixed in v0.X.Y por @usuario"
    ↓ Si falla verificación
En Progreso (reabierto)
```

### Reglas de oro para desarrolladores
| Regla | Descripción |
|---|---|
| **Nunca cerrar sin verificación** | Solo QA puede mover a Cerrado; el desarrollador no cierra sus propios bugs |
| **Regresión obligatoria** | Bugs Crítico/Mayor requieren prueba de regresión documentada |
| **Documentar fixes** | Comentario en issue: qué se cambió, archivos modificados, tests añadidos |
| **Commits referencian issue** | `git commit -m "Fix #123: NPC interaction broken after dialogue"` |

---

## Proceso de Triage

**Responsable:** QA Lead (o desarrollador senior si no hay QA dedicado)  
**Cuándo:** Dentro de 24h de creación del issue  
**Acciones:**
1. **Validar completitud:** ¿Tiene severidad, categoría, pasos, contexto? Si no → label `needs-info`, no asignar
2. **Detectar duplicates:** Buscar issues existentes; si duplicate → `status:duplicate`, comentar en original, cerrar
3. **Evaluar wontfix:** Si es por diseño, costo excesivo, deprecated → `status:wontfix`, justificar en comentario
4. **Asignar labels correctos:** Corregir severidad/prioridad/categoría si el reporter se equivocó
5. **Asignar responsable:** `@usuario` según expertise y carga actual
6. **Mover a `status:in-progress`** si hay dueño claro y capacidad en sprint

---

## Proceso de Verificación

**Responsable:** QA (distinto del desarrollador que hizo el fix)  
**Cuándo:** Cuando desarrollador marca `status:verified`  
**Checklist de verificación:**
- [ ] Bug reproducido originalmente (antes del fix)
- [ ] Fix aplicado (commit referenciado en issue)
- [ ] Bug **no se reproduce** tras fix
- [ ] **Regresión:** No se rompieron áreas relacionadas (probar features adyacentes)
- [ ] Tests automatizados pasan (M112)

**Si falla verificación:**
1. Comentario detallado: qué falló, steps para reproducir el fallo
2. Cambiar label a `status:in-progress` (reabierto)
3. Re-asignar al mismo desarrollador

**Si pasa verificación:**
1. Cambiar label a `status:closed`
2. Comentario de cierre: `"Fixed in v0.X.Y por @usuario"`
3. Remover label `status:verified`

---

## Ejemplos de bugs bien reportados

### Ejemplo 1: Gameplay — NPC no interactúa (Crítico)
```markdown
## Descripción del bug
NPC Catalina (oso) no responde a interacción (tecla E) tras completar su diálogo de bienvenida primera vez.

## Severidad
- [x] Crítico (bloquea milestone M19 - primer NPC visible)

## Categoría
- [x] Gameplay

## Prioridad
- [x] Alta (sprint actual)

## Pasos para reproducir
1. Iniciar juego nuevo
2. Acercarse a Catalina en coordenadas (120, 8, 45)
3. Presionar E para interactuar → diálogo de bienvenida aparece
4. Cerrar diálogo (Escape o botón)
5. Presionar E nuevamente → **no pasa nada, no hay respuesta**

## Comportamiento esperado
Catalina debería ofrecer diálogo secundario o repetir saludo

## Comportamiento actual
Ninguna respuesta a la tecla E; el prompt de interacción sigue visible pero no funciona

## Reproducibilidad
- [x] Siempre (100%)

## Contexto técnico
- **Versión del juego:** v0.3.1-alpha
- **Plataforma:** Windows 10, RTX 3060, 16GB RAM
- **Seed de generación:** 12345 (mundo procedural M08)
- **Archivo de guardado:** save_slot_1.sav (tras primer diálogo)

## Evidencia
- [x] Log adjunto (Logs/bug_npc_catalina_20260828.md)
- [x] Screenshot adjunto (catalina_no_interactua.png)
- [ ] Video adjunto

## Referencias
- Issues relacionados: #
- Módulos afectados: M19 (NPC), M14 (Inventario - si dialogue abre inventario)
```

### Ejemplo 2: Render/Física — Voxel terrain hole (Mayor)
```markdown
## Descripción del bug
Hueco en el terreno voxel cerca del spawn point; el jugador cae al void y muere.

## Severidad
- [x] Mayor (bloquea milestone M08 - mundo procedural, muerte injusta)

## Categoría
- [x] Render/Física

## Prioridad
- [x] Alta (sprint actual)

## Pasos para reproducir
1. Iniciar juego con seed 98765
2. Spawnear en posición por defecto (0, 10, 0)
3. Caminar 5m al norte → caer por hueco en chunk (1, 0)
4. Jugador muere por void damage

## Comportamiento esperado
Terreno sólido continuo en área de spawn

## Comportamiento actual
Hueco de 2x2 bloques en coordenadas chunk (1, 0, 0) a (1, 0, 1)

## Reproducibilidad
- [x] Siempre (100% con seed 98765)

## Contexto técnico
- **Versión del juego:** v0.2.8-alpha
- **Plataforma:** Linux Ubuntu 22.04, GTX 1060, 8GB RAM
- **Seed de generación:** 98765 (CRÍTICO para reproducir)
- **Archivo de guardado:** N/A (ocurre al spawnear)

## Evidencia
- [x] Log adjunto (Logs/bug_terrain_hole_20260828.md)
- [x] Screenshot adjunto (terrain_hole_coords.png)
- [x] Video adjunto (https://youtube.com/watch?v=abc123 - 0:15)

## Referencias
- Issues relacionados: #45 (terrain generation artifacts)
- Módulos afectados: M08 (Voxel World), M10 (Biomas)
```

---

## Ejemplos de bugs mal reportados

### Mal ejemplo 1: Demasiado vago
> "El juego se crashea a veces"
- ❌ Sin pasos para reproducir
- ❌ Sin versión, plataforma, specs
- ❌ Sin logs ni screenshots
- ❌ "A veces" no ayuda a priorizar

### Mal ejemplo 2: Falta contexto procedural
> "El terreno se ve raro en una zona"
- ❌ Sin seed de generación (imposible reproducir en mundo procedural)
- ❌ Sin coordenadas ni screenshots
- ❌ Categoría y severidad no seleccionadas

### Mal ejemplo 3: Sin evidencia
> "El inventario no guarda items"
- ❌ Sin archivo de guardado adjunto (crítico para M59)
- ❌ Sin pasos numerados
- ❌ Sin logs de la sesión

### Mal ejemplo 4: Duplicate no buscado
> Reporter crea issue #234 "NPC Catalina no habla"
- Issue #156 ya existe con mismo bug, mismo seed, misma solución en progreso
- ❌ No buscó antes de crear
- ❌ Debería haber comentado en #156 y cerrado #234

---

## Métricas de calidad

| Métrica | Fórmula | Objetivo | Frecuencia |
|---|---|---|---|
| **Bug Rate** | Bugs reportados / 1000 líneas de código | < 5 | Semanal |
| **Fix Rate** | Bugs cerrados / semana | > 10 | Semanal |
| **Reopen Rate** | Bugs reabiertos / bugs cerrados | < 10% | Sprint |
| **Time to Fix (Crítico)** | Promedio new → closed (críticos) | < 24h | Continuo |
| **Time to Fix (Mayor)** | Promedio new → closed (mayores) | < 3 días | Sprint |
| **Backlog Aging** | Bugs abiertos > 30 días | < 5 | Mensual |

**Dashboard:** `docs/bug_metrics.md` (generado por workflow opcional `.github/workflows/bug_metrics.yml`)

---

## Referencias rápidas

### Labels predefinidas
| Tipo | Labels | Colores/Iconos |
|---|---|---|
| **Severidad** | `severity:critical` 🔴, `severity:major` 🟠, `severity:minor` 🟡, `severity:trivial` ⚪ | Rojo, Naranja, Amarillo, Gris |
| **Prioridad** | `priority:immediate` 🔥, `priority:high` ⚡, `priority:medium` 📌, `priority:low` 📝 | Iconos |
| **Categoría** | `category:gameplay` 🔵, `category:ui` 🟣, `category:audio` 🟢, `category:render` 🔵, `category:networking` 🟣, `category:assets` 🩷, `category:build` 🟤, `category:localization` 🟠, `category:performance` 🟠, `category:crash` 🔴 | Colores |
| **Estado** | `status:new`, `status:in-progress`, `status:verified`, `status:closed`, `status:wontfix`, `status:duplicate`, `needs-info` | - |

### Archivos clave
- **Plantilla:** `.github/ISSUE_TEMPLATE/bug_report.md`
- **Guía (este archivo):** `docs/bug_tracking_guide.md`
- **Métricas:** `docs/bug_metrics.md` (generado)
- **Workflow métricas:** `.github/workflows/bug_metrics.yml` (opcional, futuro)

### Módulos relacionados
- **M101** QA General — Testers crean issues
- **M103** Logging — Logs se adjuntan a issues
- **M110** Debug Menu — Botón "Reportar Bug" pre-llena plantilla
- **M112** Testing Automático — Tests fallidos pueden crear issues
- **M122** Crash Reporting — Crashes generan issues con metadata
- **M133** Gestión del Proyecto — Métricas informan roadmap
- **M136** Roadmap — Bugs críticos ajustan prioridades

---

## Historial de cambios

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| 1.0 | 2026-08-29 | Implementación M102 | Creación inicial basada en plan maestro sección 101 |

---

*Documento generado como parte del Módulo 102: Bug Tracking. Para dudas, consultar al QA Lead o al mantenedor del módulo.*