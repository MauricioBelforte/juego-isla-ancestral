**Modelo:** Devin
**Plataforma:** Antigravity

# 03-Diseno.md — Módulo 102: Bug Tracking

## 1. Arquitectura del sistema

```
GitHub Issues (Plataforma)
├── .github/ISSUE_TEMPLATE/bug_report.md    ← Plantilla estandarizada
├── .github/labels/                         ← Etiquetas predefinidas
│   ├── severity: critical
│   ├── severity: major
│   ├── severity: minor
│   ├── severity: trivial
│   ├── priority: immediate
│   ├── priority: high
│   ├── priority: medium
│   ├── priority: low
│   ├── category: gameplay
│   ├── category: ui
│   ├── category: audio
│   ├── category: render
│   ├── category: networking
│   ├── category: assets
│   ├── category: build
│   ├── category: localization
│   ├── category: performance
│   ├── category: crash
│   ├── status: new
│   ├── status: in-progress
│   ├── status: verified
│   ├── status: closed
│   ├── status: wontfix
│   └── status: duplicate
└── .github/workflows/                      ← (Opcional) Automatización futura
    └── bug_metrics.yml                     ← Dashboard de métricas
```

## 2. Estructura de plantilla de issue

El archivo `.github/ISSUE_TEMPLATE/bug_report.md` contiene:

```markdown
---
name: Bug Report
about: Reporta un bug en el juego
title: '[BUG] <breve descripción>'
labels: ['bug', 'status:new']
assignees: ''
---

## Descripción del bug
[Breve descripción del problema]

## Severidad
- [ ] Crítico (bloquea release)
- [ ] Mayor (bloquea milestone)
- [ ] Menor (no bloquea)
- [ ] Trivial (cosmético)

## Categoría
- [ ] Gameplay
- [ ] UI/UX
- [ ] Audio
- [ ] Render/Física
- [ ] Networking
- [ ] Assets
- [ ] Build/Deploy
- [ ] Localización
- [ ] Performance
- [ ] Crash

## Prioridad
- [ ] Inmediata (hotfix)
- [ ] Alta (sprint actual)
- [ ] Media (backlog)
- [ ] Baja (eventual)

## Pasos para reproducir
1. 
2. 
3. 

## Comportamiento esperado
[Lo que debería pasar]

## Comportamiento actual
[Lo que pasa en realidad]

## Reproducibilidad
- [ ] Siempre (100%)
- [ ] A veces (intermitente)
- [ ] Nunca (no reproducible)

## Contexto técnico
- **Versión del juego:** 
- **Plataforma:** Windows/Linux/macOS
- **Specs:** [CPU/GPU/RAM si relevante]
- **Seed de generación:** [si aplica a M08/M10]
- **Archivo de guardado:** [si aplica a M59]

## Evidencia
- [ ] Log adjunto (Logs/*.md)
- [ ] Screenshot adjunto
- [ ] Video adjunto (enlace)

## Referencias
- Issues relacionados: #
- Módulos afectados: MXX, MYY
```

## 3. Flujo de trabajo por estados

### Estado: Nuevo (status:new)
- Issue creado por tester o desarrollador
- Triage por QA lead: asigna severidad, prioridad, categoría
- Si es duplicado → marcar como status:duplicate y cerrar
- Si wontfix → marcar como status:wontfix y justificar

### Estado: En Progreso (status:in-progress)
- Asignado a desarrollador (@usuario)
- Label status:in-progress
- Desarrollador trabaja en el fix
- Comentarios con progreso, blockers, dudas

### Estado: Verificado (status:verified)
- Desarrollador marca como listo para QA
- Label status:verified
- QA verifica el fix con checklist:
  - [ ] Bug reproducido originalmente
  - [ ] Fix aplicado
  - [ ] Bug no se reproduce tras fix
  - [ ] Regresión: no se rompieron áreas relacionadas
- Si falla verificación → status:in-progress (reabierto)

### Estado: Cerrado (status:closed)
- QA confirma verificación exitosa
- Label status:closed
- Comentario de cierre: "Fixed in v0.X.Y por @usuario"
- Remove label status:verified

## 4. Etiquetas automáticas

### Por severidad
- `severity:critical` → Color rojo
- `severity:major` → Color naranja
- `severity:minor` → Color amarillo
- `severity:trivial` → Color gris

### Por prioridad
- `priority:immediate` → Icono 🔥
- `priority:high` → Icono ⚡
- `priority:medium` → Icono 📌
- `priority:low` → Icono 📝

### Por categoría
- `category:gameplay` → Azul
- `category:ui` → Púrpura
- `category:audio` → Verde
- `category:render` → Cyan
- `category:networking` → Índigo
- `category:assets` → Rosa
- `category:build` → Marrón
- `category:localization` → Naranja claro
- `category:performance` → Rojo claro
- `category:crash` → Rojo oscuro

## 5. Integración con Debug Menu (M110)

El Debug Menu (M110) incluirá un botón "Reportar Bug" que:

1. Captura estado actual:
   - Versión del juego
   - Plataforma
   - Seed de generación (si aplica)
   - Posición del jugador
   - Estado de FPS
   - Memoria usada

2. Genera un draft de issue con:
   - Contexto técnico pre-llenado
   - Captura de pantalla automática
   - Log de la sesión adjunto

3. Abre GitHub en el navegador con la plantilla pre-llenada

## 6. Integración con Logging (M103)

Cuando se reporta un bug:

1. El sistema de logging (M103) genera un archivo `bug_{timestamp}.log` con:
   - Últimos 1000 líneas de log
   - Estado de todos los servicios
   - Stack traces si hubo excepciones

2. Este archivo se adjunta automáticamente al issue (si se usa el botón del Debug Menu)

## 7. Dashboard de métricas (opcional, futuro)

Workflow en `.github/workflows/bug_metrics.yml` que genera:

- Bugs abiertos por severidad
- Bugs abiertos por categoría
- Tiempo promedio de resolución (new → closed)
- Bugs por milestone
- Top 5 módulos con más bugs

Output: Markdown en `docs/bug_metrics.md` actualizado semanalmente.

## 8. Reglas de calidad

### Regla 1: Nunca cerrar sin verificación
- Un bug solo se cierra después de QA verification
- El desarrollador no puede cerrar sus propios bugs

### Regla 2: Metadata obligatoria
- Todo issue debe tener: severidad, categoría, al menos 1 paso de reproducción
- Issues incompletos se marcan con label `needs-info` y no se asignan

### Regla 3: Contexto específico para procedural
- Bugs de generación de mundo (M08/M10) SIEMPRE requieren seed
- Bugs de persistencia (M59) SIEMPRE requieren archivo de guardado

### Regla 4: Regresión obligatoria
- Todo fix de bug mayor/crítico requiere prueba de regresión
- Documentar áreas probadas en el comentario de verificación

### Regla 5: Sin duplicates
- Antes de crear issue, buscar en issues existentes
- Si es duplicate, comentar en el original y cerrar el nuevo

## 9. Documentación complementaria

### Guía para testers
- Cómo reproducir bugs sistemáticamente
- Cómo capturar evidencia útil
- Cómo escribir pasos claros

### Guía para desarrolladores
- Cómo priorizar bugs
- Cómo documentar fixes
- Cómo hacer regresión efectiva

### Métricas de calidad
- Bug rate: bugs por 1000 líneas de código
- Fix rate: bugs cerrados por semana
- Reopen rate: bugs reabiertos / bugs cerrados
