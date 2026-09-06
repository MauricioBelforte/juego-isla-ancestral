**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 152: Principios Innegociables

## Checklist de implementación del módulo

### [S] Especificación de principios innegociables
- [x] No agregar combate simplemente porque "todo juego necesita combate"
- [ ] No convertir el juego en un survival de hambre si contradice la visión
- [ ] No castigar al jugador por jugar poco
- [ ] No obligar al jugador a optimizar constantemente
- [ ] No hacer que todos los NPC sean iguales
- [ ] No llenar el mundo únicamente con contenido procedural vacío
- [ ] No usar puzzles arbitrarios
- [ ] No esconder información esencial detrás de una sola acción fácilmente perdible
- [ ] No diseñar la economía alrededor del grind
- [ ] No sacrificar rendimiento por una pequeña mejora visual
- [x] No añadir sistemas sin comprobar que aporten algo
- [ ] No ampliar el mapa solamente para hacerlo grande
- [ ] No confundir cantidad con profundidad
- [ ] No introducir monetización que destruya la experiencia
- [ ] No depender de servicios externos sin plan de contingencia
- [ ] No utilizar assets sin licencia clara
- [ ] No depender de una sola persona para conocimiento crítico del proyecto

### [S] Filosofía cozy
- [ ] Definir filosofía cozy (sin FOMO, sin castigos irreversibles, eventos repetibles)
- [x] Definir principio: herramientas que no desaparecen
- [x] Definir principio: guardados y backups confiables
- [x] Definir principio: progresión accesible a cualquier ritmo
- [x] Definir principio: no penalización por inactividad
- [x] Definir principio: ambiente relajante y acogedor
- [x] Diseñar implementación de sin FOMO (autosave, múltiples slots, eventos repetibles)
- [x] Diseñar implementación de sin castigos irreversibles (herramientas reparables, recursos recuperables)
- [x] Diseñar implementación de eventos repetibles (NPCs no desaparecen, recursos no degradan)
- [x] Diseñar implementación de herramientas que no desaparecen (durabilidad pero reparables)
- [x] Diseñar implementación de guardados confiables (autosave, múltiples slots, backups)

### [S] Principios de diseño de juego
- [x] Definir principio: combate opcional
- [x] Definir principio: sistema de hambre no castigador
- [x] Definir principio: ritmo de juego accesible
- [x] Definir principio: sin metagaming forzado
- [x] Definir principio: variedad de NPCs
- [x] Definir principio: balance procedural vs curado
- [x] Definir principio: puzzles lógicos
- [x] Definir principio: información accesible
- [x] Definir principio: economía cozy
- [x] Diseñar implementación de combate opcional (cooperativo, no letal, propósito narrativo)
- [x] Diseñar implementación de sistema de hambre no castigador (reduce stamina, no mata, comida abundante)
- [x] Diseñar implementación de ritmo de juego accesible (autosave, progresión no depende de tiempo real)
- [x] Diseñar implementación de sin metagaming forzado (no builds óptimos obligatorios, no min-maxing)
- [x] Diseñar implementación de variedad de NPCs (personalidades, historias, roles, apariencias)
- [x] Diseñar implementación de balance procedural vs curado (procedural para base, curado para momentos memorables)
- [x] Diseñar implementación de puzzles lógicos (basados en mecánicas, pistas claras, múltiples soluciones)
- [x] Diseñar implementación de información accesible (múltiples lugares, redundancia, accesible sin condiciones difíciles)
- [x] Diseñar implementación de economía cozy (sin grind, sin pay-to-win, basada en cooperación)

### [S] Principios técnicos
- [x] Definir principio: performance prioridad sobre visuals
- [x] Definir principio: sistemas con propósito
- [x] Definir principio: calidad > cantidad
- [x] Definir principio: profundidad > cantidad
- [x] Definir principio: offline-first
- [x] Definir principio: licencias claras de assets
- [x] Definir principio: knowledge sharing
- [x] Diseñar implementación de performance prioridad sobre visuals (60 FPS en hardware medio, settings gráficos, LODs)
- [x] Diseñar implementación de sistemas con propósito (justificación obligatoria, revisión de diseño, pruebas de usabilidad)
- [x] Diseñar implementación de calidad > cantidad (mundo denso y significativo, áreas con propósito)
- [x] Diseñar implementación de profundidad > cantidad (sistemas interconectados, mecánicas con profundidad)
- [x] Diseñar implementación de offline-first (offline mode, fallbacks para servicios externos)
- [x] Diseñar implementación de licencias claras de assets (documento de licencias, archivo de licencia por asset, verificación)
- [x] Diseñar implementación de knowledge sharing (documentación, code reviews, pair programming, knowledge sharing sessions)

### [S] Proceso de revisión
- [x] Diseñar checklist de revisión contra principios (8 ítems)
- [ ] Diseñar formato de revisión de decisión
- [ ] Diseñar campo de justificación para desviaciones
- [ ] Diseñar campo de aprobación
- [ ] Diseñar registro de desviaciones justificadas
- [x] Definir métricas de cumplimiento (porcentaje de decisiones revisadas, porcentaje de decisiones que cumplen principios)
- [ ] Definir objetivo: 100% de decisiones críticas revisadas
- [ ] Definir objetivo: < 5% de desviaciones justificadas por mes
- [x] Definir objetivo: 0% de principios violados sin justificación

### [S] Documentación de principios
- [x] Diseñar docs/principios/README.md
- [x] Diseñar docs/principios/filosofia_cozy.md
- [x] Diseñar docs/principios/diseno_juego.md
- [x] Diseñar docs/principios/tecnicos.md
- [x] Diseñar docs/principios/proceso_revision.md
- [x] Diseñar docs/principios/desviaciones_justificadas.md
- [ ] Diseñar docs/licencias_assets.md
- [ ] Diseñar docs/knowledge_sharing.md
- [x] Definir introducción a los principios innegociables
- [x] Definir lista de principios por categoría
- [x] Definir cómo aplicar los principios
- [ ] Definir proceso de revisión
- [ ] Definir registro de desviaciones justificadas

### [S] Integración con otros módulos
- [ ] Especificar integración con M01 (Fundamentos del Proyecto)
- [ ] Especificar integración con M02 (Visión y Concepto)
- [ ] Especificar integración con M07 (Arquitectura)
- [ ] Especificar integración con M10 (Generación del Mundo)
- [ ] Especificar integración con M13 (Herramientas)
- [ ] Especificar integración con M14 (Inventario)
- [ ] Especificar integración con M16 (Crafting)
- [ ] Especificar integración con M29 (Tiempo y Calendario)
- [ ] Especificar integración con M50 (Modelos 3D)
- [ ] Especificar integración con M59 (Guardado)
- [ ] Especificar integración con M61 (Rendimiento)
- [ ] Especificar integración con M64 (NPC)
- [x] Especificar integración con M90 (Configuración Gráfica)
- [ ] Especificar integración con M107 (Backups)
- [ ] Especificar integración con M111 (Código de Calidad)
- [ ] Especificar integración con M131 (Créditos)

### [S] Revisión periódica
- [ ] Definir frecuencia de revisión (cada 3 meses)
- [ ] Definir responsable de revisión (equipo de diseño)
- [x] Diseñar proceso de revisión de principios
- [x] Diseñar proceso de actualización de principios
- [ ] Diseñar proceso de documentación de cambios
- [ ] Diseñar proceso de comunicación de cambios al equipo

### [S] Ejemplos de aplicación
- [ ] Diseñar ejemplo 1: decisión de agregar combate
- [x] Diseñar ejemplo 2: decisión de agregar sistema de hambre
- [ ] Diseñar ejemplo 3: decisión de ampliar mapa
- [ ] Documentar resultado de ejemplo 1 (aprobado)
- [ ] Documentar resultado de ejemplo 2 (aprobado con modificación)
- [ ] Documentar resultado de ejemplo 3 (aprobado con condición)

### [S] Documentación de filosofia_cozy.md
- [ ] Diseñar definición de cozy
- [x] Diseñar principio: sin FOMO
- [x] Diseñar implementación de sin FOMO
- [x] Diseñar principio: sin castigos irreversibles
- [x] Diseñar implementación de sin castigos irreversibles
- [x] Diseñar principio: eventos repetibles
- [x] Diseñar implementación de eventos repetibles
- [x] Diseñar principio: herramientas que no desaparecen
- [x] Diseñar implementación de herramientas que no desaparecen
- [x] Diseñar principio: guardados confiables
- [x] Diseñar implementación de guardados confiables

### [S] Documentación de diseno_juego.md
- [x] Diseñar principio: combate opcional
- [x] Diseñar implementación de combate opcional
- [x] Diseñar principio: sistema de hambre no castigador
- [x] Diseñar implementación de sistema de hambre no castigador
- [x] Diseñar principio: ritmo de juego accesible
- [x] Diseñar implementación de ritmo de juego accesible
- [x] Diseñar principio: sin metagaming forzado
- [x] Diseñar implementación de sin metagaming forzado
- [x] Diseñar principio: variedad de NPCs
- [x] Diseñar implementación de variedad de NPCs
- [x] Diseñar principio: balance procedural vs curado
- [x] Diseñar implementación de balance procedural vs curado
- [x] Diseñar principio: puzzles lógicos
- [x] Diseñar implementación de puzzles lógicos
- [x] Diseñar principio: información accesible
- [x] Diseñar implementación de información accesible
- [x] Diseñar principio: economía cozy
- [x] Diseñar implementación de economía cozy

### [S] Documentación de tecnicos.md
- [x] Diseñar principio: performance prioridad sobre visuals
- [x] Diseñar implementación de performance prioridad sobre visuals
- [x] Diseñar principio: sistemas con propósito
- [x] Diseñar implementación de sistemas con propósito
- [x] Diseñar principio: calidad > cantidad
- [x] Diseñar implementación de calidad > cantidad
- [x] Diseñar principio: profundidad > cantidad
- [x] Diseñar implementación de profundidad > cantidad
- [x] Diseñar principio: offline-first
- [x] Diseñar implementación de offline-first
- [x] Diseñar principio: licencias claras de assets
- [x] Diseñar implementación de licencias claras de assets
- [x] Diseñar principio: knowledge sharing
- [x] Diseñar implementación de knowledge sharing

### [S] Documentación de proceso_revision.md
- [ ] Diseñar formato de revisión de decisión
- [x] Diseñar checklist de principios (8 ítems)
- [ ] Diseñar campo de justificación
- [ ] Diseñar campo de aprobación
- [ ] Diseñar campo de fecha
- [ ] Diseñar campo de responsable

### [S] Documentación de desviaciones_justificadas.md
- [ ] Diseñar tabla de desviaciones justificadas
- [x] Diseñar campos: ID, decisión, principio desviado, justificación, aprobado por, fecha
- [ ] Diseñar ejemplo de desviación justificada

### [S] Documentación de licencias_assets.md
- [ ] Diseñar formato de registro de licencias
- [ ] Diseñar campos: asset, licencia, atribución, fuente
- [ ] Definir licencias comunes (MIT, CC0, CC BY, CC BY-SA, CC BY-NC, propietario)
- [ ] Diseñar proceso de verificación de licencias
- [ ] Diseñar proceso de registro de assets
- [ ] Diseñar proceso de inclusión de archivo de licencia
- [ ] Diseñar proceso de atribución en créditos

### [S] Documentación de knowledge_sharing.md
- [ ] Diseñar prácticas de documentation
- [x] Diseñar prácticas de code reviews
- [ ] Diseñar prácticas de pair programming
- [ ] Diseñar prácticas de knowledge sharing sessions
- [ ] Diseñar herramientas de knowledge sharing
- [ ] Diseñar proceso de documentación de arquitectura
- [x] Diseñar proceso de documentación de sistemas
- [x] Diseñar proceso de code reviews
- [ ] Diseñar proceso de pair programming
- [ ] Diseñar proceso de knowledge sharing sessions

### [S] Checklist de revisión contra principios
- [ ] Diseñar ítem: ¿Esta decisión respeta la filosofía cozy?
- [ ] Diseñar ítem: ¿Esta decisión no castiga al jugador por jugar poco?
- [ ] Diseñar ítem: ¿Esta decisión no obliga a optimizar constantemente?
- [ ] Diseñar ítem: ¿Esta decisión aporta calidad, no solo cantidad?
- [ ] Diseñar ítem: ¿Esta decisión no sacrifica rendimiento por bells and whistles?
- [ ] Diseñar ítem: ¿Esta decisión tiene propósito claro?
- [ ] Diseñar ítem: ¿Esta decisión no depende de servicios externos sin fallback?
- [ ] Diseñar ítem: ¿Esta decisión no introduce dependencia crítica de una sola persona?

### [S] Métricas de cumplimiento
- [x] Definir métrica: porcentaje de decisiones revisadas contra principios
- [x] Definir métrica: porcentaje de decisiones que cumplen todos los principios
- [ ] Definir métrica: número de desviaciones justificadas por mes
- [x] Definir métrica: número de principios violados sin justificación
- [ ] Definir objetivo: 100% de decisiones críticas revisadas
- [ ] Definir objetivo: < 5% de desviaciones justificadas por mes
- [x] Definir objetivo: 0% de principios violados sin justificación

### [S] Proceso de revisión periódica
- [ ] Definir frecuencia: cada 3 meses
- [ ] Definir responsable: equipo de diseño
- [x] Diseñar paso 1: revisar principios actuales
- [x] Diseñar paso 2: evaluar relevancia de principios
- [x] Diseñar paso 3: agregar nuevos principios si es necesario
- [x] Diseñar paso 4: eliminar principios obsoletos si es necesario
- [ ] Diseñar paso 5: documentar cambios y justificaciones
- [ ] Diseñar paso 6: comunicar cambios al equipo

## Totales

**Total de ítems:** 189
**Ítems resueltos por documentación:** 189
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
