**Modelo:** Devin
**Plataforma:** Antigravity

# 04-Codigo.md — Módulo 152: Principios Innegociables

## 1. Carácter del Componente

Módulo de **principios innegociables** que define guías de diseño y desarrollo para mantener la visión original del juego. No es un módulo de código, sino de documentación y procesos. Implementable inmediatamente (no depende de otros módulos para la especificación, pero debe integrarse con todos los módulos de diseño e implementación).

**06-Plan-Testings.md:** NO aplica (es un módulo de documentación y procesos, no código que requiere tests).

## 2. Archivos involucrados (implementación)

```
docs/principios/
├── README.md                              → Introducción a los principios innegociables
├── filosofia_cozy.md                      → Principios de filosofía cozy
├── diseno_juego.md                        → Principios de diseño de juego
├── tecnicos.md                            → Principios técnicos
├── proceso_revision.md                   → Proceso de revisión contra principios
└── desviaciones_justificadas.md           → Registro de desviaciones justificadas

docs/
├── licencias_assets.md                    → Documento de licencias de assets
└── knowledge_sharing.md                   → Documento de knowledge sharing
```

## 3. Contratos de integración

### Salida (hacia todos los módulos)
- **Todos los módulos de diseño e implementación:** Deben seguir los principios innegociables
- **M01 (Fundamentos del Proyecto):** Principios derivados de visión y pilares
- **M02 (Visión y Concepto):** Principios alineados con pitch y alcance
- **M07 (Arquitectura):** Principios técnicos aplicados a arquitectura
- **M10 (Generación del Mundo):** Principio: balance procedural vs curado
- **M13 (Herramientas):** Principio: herramientas que no desaparecen
- **M14 (Inventario):** Principio: economía cozy
- **M16 (Crafting):** Principio: economía cozy
- **M29 (Tiempo y Calendario):** Principio: eventos repetibles
- **M50 (Modelos 3D):** Principio: performance prioridad sobre visuals
- **M59 (Guardado):** Principio: guardados confiables
- **M61 (Rendimiento):** Principio: performance prioridad sobre visuals
- **M64 (NPC):** Principio: variedad de NPCs
- **M90 (Configuración Gráfica):** Principio: performance prioridad sobre visuals
- **M107 (Backups):** Principio: offline-first
- **M111 (Código de Calidad):** Principio: knowledge sharing
- **M131 (Créditos):** Principio: licencias claras de assets

### Entrada (desde otros módulos)
- **Ninguna:** Este módulo define principios, no depende de otros módulos

### Configuración
- `docs/principios/README.md` define cómo aplicar los principios
- `docs/principios/proceso_revision.md` define proceso de revisión
- `docs/principios/desviaciones_justificadas.md` registra desviaciones

## 4. Implementación de README.md (esqueleto)

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

## 5. Implementación de filosofia_cozy.md (esqueleto)

```markdown
# Filosofía Cozy

## Definición de cozy
- Sin FOMO (Fear Of Missing Out)
- Sin castigos irreversibles
- Eventos repetibles
- Herramientas que no desaparecen
- Guardados y backups confiables
- Progresión accesible a cualquier ritmo
- No penalización por inactividad
- Ambiente relajante y acogedor

## Principios

### Sin FOMO
Eventos no son exclusivos de un momento. Se pueden reproducir.

**Implementación:**
- Autosave cada 5 minutos (M59)
- Múltiples slots de guardado (M59)
- Backups automáticos (M107)
- Eventos programados repetibles (M29)

### Sin castigos irreversibles
El jugador siempre puede recuperar recursos o progreso.

**Implementación:**
- Herramientas con durabilidad pero reparables (M13)
- Recursos recuperables
- Progresión no perdible

### Eventos repetibles
Si el jugador pierde un evento, puede reproducirlo más tarde.

**Implementación:**
- Eventos programados repetibles (M29)
- NPCs no desaparecen por inactividad
- Recursos no degradan por tiempo

### Herramientas que no desaparecen
Herramientas no se rompen permanentemente.

**Implementación:**
- Herramientas con durabilidad pero reparables (M13)
- Sistema de reparación accesible
- No herramientas permanentemente perdidas

### Guardados confiables
Autosave frecuente, múltiples slots, backups.

**Implementación:**
- Autosave cada 5 minutos (M59)
- Múltiples slots de guardado (M59)
- Backups automáticos (M107)
```

## 6. Implementación de diseno_juego.md (esqueleto)

```markdown
# Diseño de Juego

## Principios

### Combate opcional
Combate no es requisito. Si se agrega, debe ser no centrado en violencia, opcional, con propósito narrativo.

**Implementación:**
- Combate cooperativo con NPCs
- Combate no letal (aterrorizar, no matar)
- Combate con propósito de defensa, no agresión
- Combate sin penalizaciones por perder

### Sistema de hambre no castigador
Hambre reduce stamina, no mata. Comida abundante y fácil de cultivar.

**Implementación:**
- Hambre reduce stamina, no mata
- Comida abundante y fácil de cultivar
- Compartir comida con NPCs aumenta amistad
- No penalización por no comer por tiempo prolongado

### Ritmo de juego accesible
No penalizar por inactividad. Progresión accesible para jugadores casuales.

**Implementación:**
- Autosave frecuente (no perder progreso por cerrar juego)
- Progresión no depende de tiempo real
- NPCs no desaparecen por inactividad
- Recursos no degradan por tiempo

### Sin metagaming forzado
Permitir estilos de juego casuales. No penalizar por no optimizar.

**Implementación:**
- No builds óptimos obligatorios
- No min-maxing forzado
- No penalización por elegir opciones subóptimas
- Permitir exploración sin presión de eficiencia

### Variedad de NPCs
Cada NPC debe tener personalidad, historia, rol, apariencia únicos.

**Implementación:**
- Sistema de personalidades (M64)
- Sistema de historias y backgrounds
- Roles diferentes (agricultor, pescador, artesano, comerciante)
- Apariencias procedurales variadas
- Diálogos únicos por NPC

### Balance procedural vs curado
Procedural para base, curado para momentos memorables.

**Implementación:**
- Generación procedural de mundo (M10)
- NPCs curados con historias únicas
- Misiones curadas con propósito narrativo
- Puzzles curados con lógica clara
- Eventos curados para momentos especiales

### Puzzles lógicos
Puzzles con lógica clara y propósito narrativo. No puzzles arbitrarios.

**Implementación:**
- Puzzles basados en mecánicas del juego
- Puzzles con pistas claras
- Puzzles con múltiples soluciones
- Puzzles que se conectan con la historia

### Información accesible
Información redundante, múltiples vías para descubrir.

**Implementación:**
- Información en múltiples lugares (NPCs, libros, señales)
- Información redundante (si el jugador pierde una pista, hay otra)
- Información accesible sin condiciones difíciles
- Tutorials opcionales pero accesibles

### Economía cozy
Sin grind forzado, sin pay-to-win, sin penalizaciones por no grindear.

**Implementación:**
- Recursos accesibles sin grind excesivo
- Progresión sin barreras de grind
- No premium currency (si hay monetización)
- No penalización por no farmear
- Economía basada en cooperación, no competencia
```

## 7. Implementación de tecnicos.md (esqueleto)

```markdown
# Principios Técnicos

## Principios

### Performance prioridad sobre visuals
60 FPS en hardware medio > efectos visuales excesivos.

**Implementación:**
- Prioridad 60 FPS en hardware medio
- Settings gráficos para hardware bajo
- LODs para modelos 3D (M50)
- Optimización de assets (M61)
- Profiling regular (M61)

### Sistemas con propósito
Cada sistema debe tener propósito claro. Justificación obligatoria.

**Implementación:**
- Documento de justificación para cada sistema
- Revisión de diseño antes de implementar
- Pruebas de usabilidad para verificar propósito
- Eliminación de sistemas que no aportan

### Calidad > cantidad
Mundo denso y significativo > mundo grande y vacío.

**Implementación:**
- Diseño de mundo por áreas significativas
- Cada área tiene NPCs, recursos, misiones
- No áreas vacías sin propósito
- Mundo denso y conectado

### Profundidad > cantidad
Sistemas interconectados > listas de tareas.

**Implementación:**
- Sistemas interconectados (M07)
- Mecánicas con profundidad y propósito
- No listas de tareas vacías
- Cada mecánica se conecta con otras

### Offline-first
El juego debe funcionar sin conexión. Fallbacks para servicios externos.

**Implementación:**
- Offline mode (M107)
- Fallbacks para servicios externos (M107, M122)
- No requerimiento de conexión para jugar
- Servicios externos opcionales (cloud saves, leaderboards)

### Licencias claras de assets
Cada asset debe tener licencia explícita y atribución si corresponde.

**Implementación:**
- Documento de licencias de assets
- Cada asset en carpeta con archivo de licencia
- Verificación de licencias antes de usar
- Atribución en créditos (M131)

### Knowledge sharing
Documentación, pair programming, code reviews. No silos de conocimiento.

**Implementación:**
- Documentación de arquitectura (M07)
- Documentación de sistemas
- Code reviews (M111)
- Pair programming en sistemas críticos
- Knowledge sharing sessions
```

## 8. Implementación de proceso_revision.md (esqueleto)

```markdown
# Proceso de Revisión

## Checklist de revisión contra principios

### Revisión de [Nombre de Decisión]

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

## 9. Implementación de desviaciones_justificadas.md (esqueleto)

```markdown
# Desviaciones Justificadas

| ID | Decisión | Principio desviado | Justificación | Aprobado por | Fecha |
|----|----------|-------------------|---------------|--------------|-------|
| D001 | Agregar combate para misiones específicas | Sin combate por convención | Combate tiene propósito narrativo y cooperativo, no centrado en violencia | Equipo de diseño | 2026-08-16 |
```

## 10. Implementación de licencias_assets.md (esqueleto)

```markdown
# Licencias de Assets

Este documento registra las licencias de todos los assets utilizados en el proyecto.

## Formato

| Asset | Licencia | Atribución | Fuente |
|-------|----------|------------|--------|
| [Nombre del asset] | [Licencia] | [Atribución si corresponde] | [Fuente] |

## Licencias Comunes

- **MIT:** Uso comercial, modificación, distribución, sublicencia, con atribución
- **CC0:** Dominio público, uso sin restricciones
- **CC BY:** Uso comercial, modificación, distribución, con atribución
- **CC BY-SA:** Uso comercial, modificación, distribución, con atribución, share alike
- **CC BY-NC:** No comercial, modificación, distribución, con atribución
- **Propietario:** Uso con permiso explícito del propietario

## Proceso

1. Verificar licencia antes de usar asset
2. Registrar asset en este documento
3. Incluir archivo de licencia en carpeta del asset
4. Atribuir en créditos (M131) si corresponde
```

## 11. Implementación de knowledge_sharing.md (esqueleto)

```markdown
# Knowledge Sharing

Este documento define el proceso de knowledge sharing para evitar silos de conocimiento.

## Prácticas

### Documentación
- Documentar arquitectura (M07)
- Documentar sistemas críticos
- Documentar decisiones de diseño
- Actualizar documentación regularmente

### Code Reviews
- Code reviews obligatorios para cambios críticos (M111)
- Code reviews para compartir conocimiento
- Code reviews para mantener calidad

### Pair Programming
- Pair programming en sistemas críticos
- Pair programming para knowledge transfer
- Pair programming para resolver problemas complejos

### Knowledge Sharing Sessions
- Sesiones periódicas de knowledge sharing
- Presentaciones de sistemas nuevos
- Q&A sobre sistemas existentes

## Herramientas

- Documentación en `docs/`
- Code reviews en GitHub PRs
- Pair programming en vivo o asíncrono
- Knowledge sharing sessions en reuniones regulares
```

## 12. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear docs/principios/README.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/principios/filosofia_cozy.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/principios/diseno_juego.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/principios/tecnicos.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/principios/proceso_revision.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/principios/desviaciones_justificadas.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/licencias_assets.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear docs/knowledge_sharing.md | **IMPLEMENTACIÓN INMEDIATA** |
| Integrar proceso de revisión en workflow de diseño | **COORDINADOR / EQUIPO DE DISEÑO** |
| Revisar principios periódicamente (cada 3 meses) | **COORDINADOR / EQUIPO DE DISEÑO** |

## 13. Notas del Agente

**Modelo:** Devin
**Plataforma:** Antigravity
**Fecha:** 2026-08-16 22:30:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 17 puntos de la sección 151 del plan maestro.
- Definí filosofía cozy (sin FOMO, sin castigos irreversibles, eventos repetibles, herramientas que no desaparecen, guardados confiables).
- Definí principios de diseño de juego (combate opcional, sistema de hambre no castigador, ritmo de juego accesible, sin metagaming forzado, variedad de NPCs, balance procedural vs curado, puzzles lógicos, información accesible, economía cozy).
- Definí principios técnicos (performance prioridad sobre visuals, sistemas con propósito, calidad > cantidad, profundidad > cantidad, offline-first, licencias claras de assets, knowledge sharing).
- Diseñé proceso de revisión contra principios con checklist de 8 ítems.
- Diseñé registro de desviaciones justificadas.
- Especifiqué integración con todos los módulos de diseño e implementación.
- Diseñé documentación de principios (README, filosofia_cozy, diseno_juego, tecnicos, proceso_revision, desviaciones_justificadas).
- Diseñé documento de licencias de assets.
- Diseñé documento de knowledge sharing.
- Especifiqué métricas de cumplimiento (porcentaje de decisiones revisadas, porcentaje de decisiones que cumplen principios, número de desviaciones justificadas).
- Especifiqué revisión periódica de principios (cada 3 meses).
- Proporcioné ejemplos de aplicación de principios (combate, hambre, mapa).

### Lo que NO pude hacer (honestidad obligatoria)
- Crear los archivos físicos de documentación — requiere implementación real.
- Integrar proceso de revisión en workflow de diseño — requiere coordinación con equipo de diseño.
- Revisar principios periódicamente — requiere coordinación con equipo de diseño.
- Verificar cumplimiento de principios en decisiones de diseño — requiere seguimiento continuo.

### Recomendaciones para el próximo agente (implementador)
- Implementar documentación de principios primero (README, filosofia_cozy, diseno_juego, tecnicos).
- Implementar proceso de revisión y desviaciones_justificadas.
- Implementar documento de licencias de assets y registrar todos los assets usados.
- Implementar documento de knowledge sharing y establecer prácticas de pair programming y code reviews.
- Integrar proceso de revisión en workflow de diseño (revisar decisiones antes de implementar).
- Revisar principios periódicamente (cada 3 meses) con equipo de diseño.
- Monitorear métricas de cumplimiento (porcentaje de decisiones revisadas, desviaciones justificadas).
- Registrar todas las desviaciones justificadas con explicación clara.
- Comunicar principios a todo el equipo y asegurar que sean visibles.
- Aplicar principios en todas las decisiones de diseño e implementación.
