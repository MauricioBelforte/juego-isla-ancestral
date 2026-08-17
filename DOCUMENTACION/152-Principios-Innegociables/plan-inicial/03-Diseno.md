**Modelo:** SWE-1.6
**Plataforma:** Devin

# 03-Diseno.md — Módulo 152: Principios Innegociables

## 1. Arquitectura del módulo

```
Principios Innegociables (guía de diseño y desarrollo)
├── Principios de Filosofía Cozy
│   ├── Sin FOMO
│   ├── Sin castigos irreversibles
│   ├── Eventos repetibles
│   ├── Herramientas que no desaparecen
│   └── Guardados y backups confiables
├── Principios de Diseño de Juego
│   ├── Combate opcional y no centrado en violencia
│   ├── Sistema de hambre no castigador
│   ├── Ritmo de juego accesible
│   ├── Sin metagaming forzado
│   ├── Variedad de NPCs
│   ├── Balance procedural vs curado
│   ├── Puzzles lógicos
│   ├── Información accesible
│   └── Economía cozy
├── Principios Técnicos
│   ├── Performance prioridad sobre visuals
│   ├── Sistemas con propósito
│   ├── Calidad > cantidad
│   ├── Profundidad > cantidad
│   ├── Offline-first
│   ├── Licencias claras de assets
│   └── Knowledge sharing
└── Proceso de Revisión
    ├── Checklist de revisión contra principios
    └── Registro de desviaciones justificadas
```

## 2. Principios de Filosofía Cozy

**Archivo: docs/principios/filosofia_cozy.md**

**Principios:**
1. **Sin FOMO:** Eventos no son exclusivos de un momento. Se pueden reproducir.
2. **Sin castigos irreversibles:** El jugador siempre puede recuperar recursos o progreso.
3. **Eventos repetibles:** Si el jugador pierde un evento, puede reproducirlo más tarde.
4. **Herramientas que no desaparecen:** Herramientas no se rompen permanentemente.
5. **Guardados confiables:** Autosave frecuente, múltiples slots, backups (M107).

**Implementación:**
- Autosave cada 5 minutos (M59)
- Múltiples slots de guardado (M59)
- Backups automáticos (M107)
- Herramientas con durabilidad pero reparables (M13)
- Eventos programados repetibles (M29)

## 3. Principios de Diseño de Juego

**Archivo: docs/principios/diseno_juego.md**

**Principios:**
1. **Combate opcional:** Combate no es requisito. Si se agrega, debe ser no centrado en violencia, opcional, con propósito narrativo.
2. **Sistema de hambre no castigador:** Hambre reduce stamina, no mata. Comida abundante y fácil de cultivar.
3. **Ritmo de juego accesible:** No penalizar por inactividad. Progresión accesible para jugadores casuales.
4. **Sin metagaming forzado:** Permitir estilos de juego casuales. No penalizar por no optimizar.
5. **Variedad de NPCs:** Cada NPC debe tener personalidad, historia, rol, apariencia únicos.
6. **Balance procedural vs curado:** Procedural para base, curado para momentos memorables.
7. **Puzzles lógicos:** Puzzles con lógica clara y propósito narrativo. No puzzles arbitrarios.
8. **Información accesible:** Información redundante, múltiples vías para descubrir.
9. **Economía cozy:** Sin grind forzado, sin pay-to-win, sin penalizaciones por no grindear.

**Implementación:**
- Sistema de personalidades de NPCs (M64)
- Generación procedural de mundo (M10)
- NPCs curados con historias únicas
- Puzzles basados en mecánicas del juego
- Información en múltiples lugares (NPCs, libros, señales)
- Economía basada en cooperación (M14, M16)

## 4. Principios Técnicos

**Archivo: docs/principios/tecnicos.md**

**Principios:**
1. **Performance prioridad sobre visuals:** 60 FPS en hardware medio > efectos visuales excesivos.
2. **Sistemas con propósito:** Cada sistema debe tener propósito claro. Justificación obligatoria.
3. **Calidad > cantidad:** Mundo denso y significativo > mundo grande y vacío.
4. **Profundidad > cantidad:** Sistemas interconectados > listas de tareas.
5. **Offline-first:** El juego debe funcionar sin conexión. Fallbacks para servicios externos.
6. **Licencias claras de assets:** Cada asset debe tener licencia explícita y atribución si corresponde.
7. **Knowledge sharing:** Documentación, pair programming, code reviews. No silos de conocimiento.

**Implementación:**
- Optimización obligatoria (M61)
- Settings gráficos ajustables (M90)
- LODs para modelos 3D (M50)
- Documento de justificación para cada sistema
- Offline mode (M107)
- Documento de licencias de assets
- Code reviews (M111)
- Documentación de arquitectura (M07)

## 5. Proceso de Revisión

**Archivo: docs/principios/proceso_revision.md**

**Checklist de revisión contra principios:**
```markdown
## Revisión de [Nombre de Decisión]

**Fecha:** [AAAA-MM-DD]
**Responsable:** [Nombre]

### Checklist de Principios

- [ ] ¿Esta decisión respeta la filosofía cozy?
- [ ] ¿Esta decisión no castiga al jugador por jugar poco?
- [ ] ¿Esta decisión no obliga a optimizar constantemente?
- [ ] ¿Esta decisión aporta calidad, no solo cantidad?
- [ ] ¿Esta decisión no sacrifica rendimiento por bells and whistles?
- [ ] ¿Esta decisión tiene propósito claro?
- [ ] ¿Esta decisión no depende de servicios externos sin fallback?
- [ ] ¿Esta decisión no introduce dependencia crítica de una sola persona?

### Justificación (si alguna casilla no está marcada)

[Explicar por qué la decisión desvía de un principio]

### Aprobación

**Aprobado por:** [Nombre]
**Fecha:** [AAAA-MM-DD]
```

**Registro de desviaciones justificadas:**
```markdown
## Desviaciones Justificadas

| ID | Decisión | Principio desviado | Justificación | Aprobado por | Fecha |
|----|----------|-------------------|---------------|--------------|-------|
| D001 | Agregar combate para misiones específicas | Sin combate por convención | Combate tiene propósito narrativo y cooperativo, no centrado en violencia | Equipo de diseño | 2026-08-16 |
```

## 6. Integración con otros módulos

**Con M01 (Fundamentos del Proyecto):**
- Principios derivados de visión y pilares del proyecto

**Con M02 (Visión y Concepto):**
- Principios alineados con pitch y alcance v1.0

**Con M07 (Arquitectura):**
- Principios técnicos aplicados a arquitectura (offline-first, knowledge sharing)

**Con M10 (Generación del Mundo):**
- Principio: balance procedural vs curado

**Con M13 (Herramientas):**
- Principio: herramientas que no desaparecen

**Con M14 (Inventario):**
- Principio: economía cozy

**Con M16 (Crafting):**
- Principio: economía cozy

**Con M29 (Tiempo y Calendario):**
- Principio: eventos repetibles

**Con M50 (Modelos 3D):**
- Principio: performance prioridad sobre visuals

**Con M59 (Guardado):**
- Principio: guardados confiables

**Con M61 (Rendimiento):**
- Principio: performance prioridad sobre visuals

**Con M64 (NPC):**
- Principio: variedad de NPCs

**Con M90 (Configuración Gráfica):**
- Principio: performance prioridad sobre visuals

**Con M107 (Backups):**
- Principio: offline-first

**Con M111 (Código de Calidad):**
- Principio: knowledge sharing

**Con M131 (Créditos):**
- Principio: licencias claras de assets

## 7. Documentación de Principios

**Archivo: docs/principios/README.md**

**Contenido:**
- Introducción a los principios innegociables
- Lista de principios por categoría
- Cómo aplicar los principios
- Proceso de revisión
- Registro de desviaciones justificadas

**Formato:**
```markdown
# Principios Innegociables de Isla Ancestral

Este documento define los principios innegociables que guían todas las decisiones de diseño e implementación del proyecto.

## Categorías

### Filosofía Cozy
- Sin FOMO
- Sin castigos irreversibles
- Eventos repetibles
- Herramientas que no desaparecen
- Guardados y backups confiables

### Diseño de Juego
- Combate opcional
- Sistema de hambre no castigador
- Ritmo de juego accesible
- Sin metagaming forzado
- Variedad de NPCs
- Balance procedural vs curado
- Puzzles lógicos
- Información accesible
- Economía cozy

### Técnicos
- Performance prioridad sobre visuals
- Sistemas con propósito
- Calidad > cantidad
- Profundidad > cantidad
- Offline-first
- Licencias claras de assets
- Knowledge sharing

## Cómo aplicar los principios

Antes de tomar cualquier decisión de diseño o implementación, revisar el checklist de principios en `docs/principios/proceso_revision.md`.

Si la decisión desvía de un principio, justificar explícitamente y registrar en el documento de desviaciones justificadas.
```

## 8. Métricas de cumplimiento

**Métricas:**
- Porcentaje de decisiones revisadas contra principios
- Porcentaje de decisiones que cumplen todos los principios
- Número de desviaciones justificadas por mes
- Número de principios violados sin justificación

**Objetivos:**
- 100% de decisiones críticas revisadas contra principios
- < 5% de desviaciones justificadas por mes
- 0% de principios violados sin justificación

## 9. Revisión periódica

**Frecuencia:**
- Revisión de principios cada 3 meses
- Revisión por equipo de diseño
- Actualización de principios si la visión del proyecto evoluciona

**Proceso:**
1. Revisar principios actuales
2. Evaluar si principios siguen siendo relevantes
3. Agregar nuevos principios si es necesario
4. Eliminar principios obsoletos si es necesario
5. Documentar cambios y justificaciones
6. Comunicar cambios al equipo

## 10. Ejemplos de aplicación

**Ejemplo 1: Decisión de agregar combate**
- **Revisión:** ¿Respecta filosofía cozy? Sí (combate cooperativo, no centrado en violencia)
- **Revisión:** ¿Tiene propósito claro? Sí (defensa de isla, cooperación con NPCs)
- **Revisión:** ¿No sacrifica rendimiento? Sí (combate simple, optimizado)
- **Resultado:** Aprobado

**Ejemplo 2: Decisión de agregar sistema de hambre**
- **Revisión:** ¿No castiga al jugador? No (hambre causa muerte)
- **Justificación:** Hambre es necesaria para mecánicas de agricultura y cocina
- **Modificación:** Hambre reduce stamina, no mata. Comida abundante y fácil de cultivar.
- **Resultado:** Aprobado con modificación

**Ejemplo 3: Decisión de ampliar mapa**
- **Revisión:** ¿Calidad > cantidad? No (mapa más grande pero mismo contenido)
- **Justificación:** Necesario para nuevos biomas y NPCs
- **Modificación:** Ampliar mapa solo si se agregan NPCs, recursos, misiones en nuevas áreas.
- **Resultado:** Aprobado con condición
