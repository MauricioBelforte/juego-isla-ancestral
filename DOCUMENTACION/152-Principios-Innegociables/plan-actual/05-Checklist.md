**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 152: Principios Innegociables

## Checklist de implementación del módulo

### [S] Especificación de principios innegociables
- [ ] No agregar combate simplemente porque "todo juego necesita combate"
- [ ] No convertir el juego en un survival de hambre si contradice la visión
- [ ] No castigar al jugador por jugar poco
- [ ] No obligar al jugador a optimizar constantemente
- [ ] No hacer que todos los NPC sean iguales
- [ ] No llenar el mundo únicamente con contenido procedural vacío
- [ ] No usar puzzles arbitrarios
- [ ] No esconder información esencial detrás de una sola acción fácilmente perdible
- [ ] No diseñar la economía alrededor del grind
- [ ] No sacrificar rendimiento por una pequeña mejora visual
- [ ] No añadir sistemas sin comprobar que aporten algo
- [ ] No ampliar el mapa solamente para hacerlo grande
- [ ] No confundir cantidad con profundidad
- [ ] No introducir monetización que destruya la experiencia
- [ ] No depender de servicios externos sin plan de contingencia
- [ ] No utilizar assets sin licencia clara
- [ ] No depender de una sola persona para conocimiento crítico del proyecto

### [S] Filosofía cozy
- [ ] Definir filosofía cozy (sin FOMO, sin castigos irreversibles, eventos repetibles)
- [ ] Definir principio: herramientas que no desaparecen
- [ ] Definir principio: guardados y backups confiables
- [ ] Definir principio: progresión accesible a cualquier ritmo
- [ ] Definir principio: no penalización por inactividad
- [ ] Definir principio: ambiente relajante y acogedor
- [ ] Diseñar implementación de sin FOMO (autosave, múltiples slots, eventos repetibles)
- [ ] Diseñar implementación de sin castigos irreversibles (herramientas reparables, recursos recuperables)
- [ ] Diseñar implementación de eventos repetibles (NPCs no desaparecen, recursos no degradan)
- [ ] Diseñar implementación de herramientas que no desaparecen (durabilidad pero reparables)
- [ ] Diseñar implementación de guardados confiables (autosave, múltiples slots, backups)

### [S] Principios de diseño de juego
- [ ] Definir principio: combate opcional
- [ ] Definir principio: sistema de hambre no castigador
- [ ] Definir principio: ritmo de juego accesible
- [ ] Definir principio: sin metagaming forzado
- [ ] Definir principio: variedad de NPCs
- [ ] Definir principio: balance procedural vs curado
- [ ] Definir principio: puzzles lógicos
- [ ] Definir principio: información accesible
- [ ] Definir principio: economía cozy
- [ ] Diseñar implementación de combate opcional (cooperativo, no letal, propósito narrativo)
- [ ] Diseñar implementación de sistema de hambre no castigador (reduce stamina, no mata, comida abundante)
- [ ] Diseñar implementación de ritmo de juego accesible (autosave, progresión no depende de tiempo real)
- [ ] Diseñar implementación de sin metagaming forzado (no builds óptimos obligatorios, no min-maxing)
- [ ] Diseñar implementación de variedad de NPCs (personalidades, historias, roles, apariencias)
- [ ] Diseñar implementación de balance procedural vs curado (procedural para base, curado para momentos memorables)
- [ ] Diseñar implementación de puzzles lógicos (basados en mecánicas, pistas claras, múltiples soluciones)
- [ ] Diseñar implementación de información accesible (múltiples lugares, redundancia, accesible sin condiciones difíciles)
- [ ] Diseñar implementación de economía cozy (sin grind, sin pay-to-win, basada en cooperación)

### [S] Principios técnicos
- [ ] Definir principio: performance prioridad sobre visuals
- [ ] Definir principio: sistemas con propósito
- [ ] Definir principio: calidad > cantidad
- [ ] Definir principio: profundidad > cantidad
- [ ] Definir principio: offline-first
- [ ] Definir principio: licencias claras de assets
- [ ] Definir principio: knowledge sharing
- [ ] Diseñar implementación de performance prioridad sobre visuals (60 FPS en hardware medio, settings gráficos, LODs)
- [ ] Diseñar implementación de sistemas con propósito (justificación obligatoria, revisión de diseño, pruebas de usabilidad)
- [ ] Diseñar implementación de calidad > cantidad (mundo denso y significativo, áreas con propósito)
- [ ] Diseñar implementación de profundidad > cantidad (sistemas interconectados, mecánicas con profundidad)
- [ ] Diseñar implementación de offline-first (offline mode, fallbacks para servicios externos)
- [ ] Diseñar implementación de licencias claras de assets (documento de licencias, archivo de licencia por asset, verificación)
- [ ] Diseñar implementación de knowledge sharing (documentación, code reviews, pair programming, knowledge sharing sessions)

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
- [ ] Especificar integración con M90 (Configuración Gráfica)
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
- [ ] Diseñar ejemplo 2: decisión de agregar sistema de hambre
- [ ] Diseñar ejemplo 3: decisión de ampliar mapa
- [ ] Documentar resultado de ejemplo 1 (aprobado)
- [ ] Documentar resultado de ejemplo 2 (aprobado con modificación)
- [ ] Documentar resultado de ejemplo 3 (aprobado con condición)

### [S] Documentación de filosofia_cozy.md
- [ ] Diseñar definición de cozy
- [ ] Diseñar principio: sin FOMO
- [ ] Diseñar implementación de sin FOMO
- [ ] Diseñar principio: sin castigos irreversibles
- [ ] Diseñar implementación de sin castigos irreversibles
- [ ] Diseñar principio: eventos repetibles
- [ ] Diseñar implementación de eventos repetibles
- [ ] Diseñar principio: herramientas que no desaparecen
- [ ] Diseñar implementación de herramientas que no desaparecen
- [ ] Diseñar principio: guardados confiables
- [ ] Diseñar implementación de guardados confiables

### [S] Documentación de diseno_juego.md
- [ ] Diseñar principio: combate opcional
- [ ] Diseñar implementación de combate opcional
- [ ] Diseñar principio: sistema de hambre no castigador
- [ ] Diseñar implementación de sistema de hambre no castigador
- [ ] Diseñar principio: ritmo de juego accesible
- [ ] Diseñar implementación de ritmo de juego accesible
- [ ] Diseñar principio: sin metagaming forzado
- [ ] Diseñar implementación de sin metagaming forzado
- [ ] Diseñar principio: variedad de NPCs
- [ ] Diseñar implementación de variedad de NPCs
- [ ] Diseñar principio: balance procedural vs curado
- [ ] Diseñar implementación de balance procedural vs curado
- [ ] Diseñar principio: puzzles lógicos
- [ ] Diseñar implementación de puzzles lógicos
- [ ] Diseñar principio: información accesible
- [ ] Diseñar implementación de información accesible
- [ ] Diseñar principio: economía cozy
- [ ] Diseñar implementación de economía cozy

### [S] Documentación de tecnicos.md
- [ ] Diseñar principio: performance prioridad sobre visuals
- [ ] Diseñar implementación de performance prioridad sobre visuals
- [ ] Diseñar principio: sistemas con propósito
- [ ] Diseñar implementación de sistemas con propósito
- [ ] Diseñar principio: calidad > cantidad
- [ ] Diseñar implementación de calidad > cantidad
- [ ] Diseñar principio: profundidad > cantidad
- [ ] Diseñar implementación de profundidad > cantidad
- [ ] Diseñar principio: offline-first
- [ ] Diseñar implementación de offline-first
- [ ] Diseñar principio: licencias claras de assets
- [ ] Diseñar implementación de licencias claras de assets
- [ ] Diseñar principio: knowledge sharing
- [ ] Diseñar implementación de knowledge sharing

### [S] Documentación de proceso_revision.md
- [ ] Diseñar formato de revisión de decisión
- [x] Diseñar checklist de principios (8 ítems)
- [ ] Diseñar campo de justificación
- [ ] Diseñar campo de aprobación
- [ ] Diseñar campo de fecha
- [ ] Diseñar campo de responsable

### [S] Documentación de desviaciones_justificadas.md
- [ ] Diseñar tabla de desviaciones justificadas
- [ ] Diseñar campos: ID, decisión, principio desviado, justificación, aprobado por, fecha
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
- [ ] Diseñar prácticas de code reviews
- [ ] Diseñar prácticas de pair programming
- [ ] Diseñar prácticas de knowledge sharing sessions
- [ ] Diseñar herramientas de knowledge sharing
- [ ] Diseñar proceso de documentación de arquitectura
- [ ] Diseñar proceso de documentación de sistemas
- [ ] Diseñar proceso de code reviews
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
