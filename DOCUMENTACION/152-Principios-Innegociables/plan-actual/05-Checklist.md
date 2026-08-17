**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 152: Principios Innegociables

## Checklist de implementación del módulo

### [S] Especificación de principios innegociables
- [x] No agregar combate simplemente porque "todo juego necesita combate"
- [x] No convertir el juego en un survival de hambre si contradice la visión
- [x] No castigar al jugador por jugar poco
- [x] No obligar al jugador a optimizar constantemente
- [x] No hacer que todos los NPC sean iguales
- [x] No llenar el mundo únicamente con contenido procedural vacío
- [x] No usar puzzles arbitrarios
- [x] No esconder información esencial detrás de una sola acción fácilmente perdible
- [x] No diseñar la economía alrededor del grind
- [x] No sacrificar rendimiento por una pequeña mejora visual
- [x] No añadir sistemas sin comprobar que aporten algo
- [x] No ampliar el mapa solamente para hacerlo grande
- [x] No confundir cantidad con profundidad
- [x] No introducir monetización que destruya la experiencia
- [x] No depender de servicios externos sin plan de contingencia
- [x] No utilizar assets sin licencia clara
- [x] No depender de una sola persona para conocimiento crítico del proyecto

### [S] Filosofía cozy
- [x] Definir filosofía cozy (sin FOMO, sin castigos irreversibles, eventos repetibles)
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
- [x] Diseñar formato de revisión de decisión
- [x] Diseñar campo de justificación para desviaciones
- [x] Diseñar campo de aprobación
- [x] Diseñar registro de desviaciones justificadas
- [x] Definir métricas de cumplimiento (porcentaje de decisiones revisadas, porcentaje de decisiones que cumplen principios)
- [x] Definir objetivo: 100% de decisiones críticas revisadas
- [x] Definir objetivo: < 5% de desviaciones justificadas por mes
- [x] Definir objetivo: 0% de principios violados sin justificación

### [S] Documentación de principios
- [x] Diseñar docs/principios/README.md
- [x] Diseñar docs/principios/filosofia_cozy.md
- [x] Diseñar docs/principios/diseno_juego.md
- [x] Diseñar docs/principios/tecnicos.md
- [x] Diseñar docs/principios/proceso_revision.md
- [x] Diseñar docs/principios/desviaciones_justificadas.md
- [x] Diseñar docs/licencias_assets.md
- [x] Diseñar docs/knowledge_sharing.md
- [x] Definir introducción a los principios innegociables
- [x] Definir lista de principios por categoría
- [x] Definir cómo aplicar los principios
- [x] Definir proceso de revisión
- [x] Definir registro de desviaciones justificadas

### [S] Integración con otros módulos
- [x] Especificar integración con M01 (Fundamentos del Proyecto)
- [x] Especificar integración con M02 (Visión y Concepto)
- [x] Especificar integración con M07 (Arquitectura)
- [x] Especificar integración con M10 (Generación del Mundo)
- [x] Especificar integración con M13 (Herramientas)
- [x] Especificar integración con M14 (Inventario)
- [x] Especificar integración con M16 (Crafting)
- [x] Especificar integración con M29 (Tiempo y Calendario)
- [x] Especificar integración con M50 (Modelos 3D)
- [x] Especificar integración con M59 (Guardado)
- [x] Especificar integración con M61 (Rendimiento)
- [x] Especificar integración con M64 (NPC)
- [x] Especificar integración con M90 (Configuración Gráfica)
- [x] Especificar integración con M107 (Backups)
- [x] Especificar integración con M111 (Código de Calidad)
- [x] Especificar integración con M131 (Créditos)

### [S] Revisión periódica
- [x] Definir frecuencia de revisión (cada 3 meses)
- [x] Definir responsable de revisión (equipo de diseño)
- [x] Diseñar proceso de revisión de principios
- [x] Diseñar proceso de actualización de principios
- [x] Diseñar proceso de documentación de cambios
- [x] Diseñar proceso de comunicación de cambios al equipo

### [S] Ejemplos de aplicación
- [x] Diseñar ejemplo 1: decisión de agregar combate
- [x] Diseñar ejemplo 2: decisión de agregar sistema de hambre
- [x] Diseñar ejemplo 3: decisión de ampliar mapa
- [x] Documentar resultado de ejemplo 1 (aprobado)
- [x] Documentar resultado de ejemplo 2 (aprobado con modificación)
- [x] Documentar resultado de ejemplo 3 (aprobado con condición)

### [S] Documentación de filosofia_cozy.md
- [x] Diseñar definición de cozy
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
- [x] Diseñar formato de revisión de decisión
- [x] Diseñar checklist de principios (8 ítems)
- [x] Diseñar campo de justificación
- [x] Diseñar campo de aprobación
- [x] Diseñar campo de fecha
- [x] Diseñar campo de responsable

### [S] Documentación de desviaciones_justificadas.md
- [x] Diseñar tabla de desviaciones justificadas
- [x] Diseñar campos: ID, decisión, principio desviado, justificación, aprobado por, fecha
- [x] Diseñar ejemplo de desviación justificada

### [S] Documentación de licencias_assets.md
- [x] Diseñar formato de registro de licencias
- [x] Diseñar campos: asset, licencia, atribución, fuente
- [x] Definir licencias comunes (MIT, CC0, CC BY, CC BY-SA, CC BY-NC, propietario)
- [x] Diseñar proceso de verificación de licencias
- [x] Diseñar proceso de registro de assets
- [x] Diseñar proceso de inclusión de archivo de licencia
- [x] Diseñar proceso de atribución en créditos

### [S] Documentación de knowledge_sharing.md
- [x] Diseñar prácticas de documentation
- [x] Diseñar prácticas de code reviews
- [x] Diseñar prácticas de pair programming
- [x] Diseñar prácticas de knowledge sharing sessions
- [x] Diseñar herramientas de knowledge sharing
- [x] Diseñar proceso de documentación de arquitectura
- [x] Diseñar proceso de documentación de sistemas
- [x] Diseñar proceso de code reviews
- [x] Diseñar proceso de pair programming
- [x] Diseñar proceso de knowledge sharing sessions

### [S] Checklist de revisión contra principios
- [x] Diseñar ítem: ¿Esta decisión respeta la filosofía cozy?
- [x] Diseñar ítem: ¿Esta decisión no castiga al jugador por jugar poco?
- [x] Diseñar ítem: ¿Esta decisión no obliga a optimizar constantemente?
- [x] Diseñar ítem: ¿Esta decisión aporta calidad, no solo cantidad?
- [x] Diseñar ítem: ¿Esta decisión no sacrifica rendimiento por bells and whistles?
- [x] Diseñar ítem: ¿Esta decisión tiene propósito claro?
- [x] Diseñar ítem: ¿Esta decisión no depende de servicios externos sin fallback?
- [x] Diseñar ítem: ¿Esta decisión no introduce dependencia crítica de una sola persona?

### [S] Métricas de cumplimiento
- [x] Definir métrica: porcentaje de decisiones revisadas contra principios
- [x] Definir métrica: porcentaje de decisiones que cumplen todos los principios
- [x] Definir métrica: número de desviaciones justificadas por mes
- [x] Definir métrica: número de principios violados sin justificación
- [x] Definir objetivo: 100% de decisiones críticas revisadas
- [x] Definir objetivo: < 5% de desviaciones justificadas por mes
- [x] Definir objetivo: 0% de principios violados sin justificación

### [S] Proceso de revisión periódica
- [x] Definir frecuencia: cada 3 meses
- [x] Definir responsable: equipo de diseño
- [x] Diseñar paso 1: revisar principios actuales
- [x] Diseñar paso 2: evaluar relevancia de principios
- [x] Diseñar paso 3: agregar nuevos principios si es necesario
- [x] Diseñar paso 4: eliminar principios obsoletos si es necesario
- [x] Diseñar paso 5: documentar cambios y justificaciones
- [x] Diseñar paso 6: comunicar cambios al equipo

## Totales

**Total de ítems:** 189
**Ítems resueltos por documentación:** 189
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
