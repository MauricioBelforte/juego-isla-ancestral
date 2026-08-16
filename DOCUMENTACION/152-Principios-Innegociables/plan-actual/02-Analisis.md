**Modelo:** Devin
**Plataforma:** Antigravity

# 02-Analisis.md — Módulo 152: Principios Innegociables

## 1. Análisis de los puntos del plan maestro (sección 151)

| # | Punto | Resolución |
|---|---|---|
| 1 | No agregar combate simplemente porque "todo juego necesita combate" | ✅ Combate solo si aporta a la visión cozy (cooperación, creatividad, exploración). No por convención del género. |
| 2 | No convertir el juego en un survival de hambre si contradice la visión | ✅ Mantener filosofía cozy: sin FOMO, sin castigos irreversibles, eventos repetibles, herramientas que no desaparecen. |
| 3 | No castigar al jugador por jugar poco | ✅ El juego debe ser disfrutable a cualquier ritmo. No penalizar por inactividad. Progresión accesible para todos. |
| 4 | No obligar al jugador a optimizar constantemente | ✅ Evitar metagaming forzado. Permitir estilos de juego casuales. No penalizar por no optimizar. |
| 5 | No hacer que todos los NPC sean iguales | ✅ Variedad en personalidades, historias, roles, apariencias. Cada NPC debe tener identidad única. |
| 6 | No llenar el mundo únicamente con contenido procedural vacío | ✅ Balance entre procedural y contenido curado. Procedural para base, curado para momentos memorables. |
| 7 | No usar puzzles arbitrarios | ✅ Puzzles con lógica clara y propósito narrativo. No puzzles por el sake de puzzles. |
| 8 | No esconder información esencial detrás de una sola acción fácilmente perdible | ✅ Información accesible y redundante. Múltiples vías para descubrir información esencial. |
| 9 | No diseñar la economía alrededor del grind | ✅ Economía cozy: sin grind forzado, sin pay-to-win, sin penalizaciones por no grindear. |
| 10 | No sacrificar rendimiento por una pequeña mejora visual | ✅ Performance prioridad sobre bells and whistles. 60 FPS en hardware medio > efectos visuales excesivos. |
| 11 | No añadir sistemas sin comprobar que aporten algo | ✅ Cada sistema debe tener propósito claro. Justificación obligatoria antes de agregar sistema. |
| 12 | No ampliar el mapa solamente para hacerlo grande | ✅ Calidad > cantidad. Mundo denso y significativo > mundo grande y vacío. |
| 13 | No confundir cantidad con profundidad | ✅ Profundidad mecánica > cantidad de contenido. Sistemas interconectados > listas de tareas. |
| 14 | No introducir monetización que destruya la experiencia | ✅ Si hay monetización, debe ser opcional y no intrusiva. No pay-to-win, no FOMO. |
| 15 | No depender de servicios externos sin plan de contingencia | ✅ Offline-first. Fallbacks para servicios externos. El juego debe funcionar sin conexión. |
| 16 | No utilizar assets sin licencia clara | ✅ Licencias claras y documentadas. Cada asset debe tener licencia explícita y atribución si corresponde. |
| 17 | No depender de una sola persona para conocimiento crítico del proyecto | ✅ Documentación, pair programming, knowledge sharing. No silos de conocimiento. |

## 2. Filosofía Cozy

**Definición de cozy:**
- Sin FOMO (Fear Of Missing Out)
- Sin castigos irreversibles
- Eventos repetibles
- Herramientas que no desaparecen
- Guardados y backups confiables
- Progresión accesible a cualquier ritmo
- No penalización por inactividad
- Ambiente relajante y acogedor

**Aplicación de principios cozy:**
- **No FOMO:** Eventos no son exclusivos de un momento. Se pueden reproducir.
- **Sin castigos irreversibles:** El jugador siempre puede recuperar recursos o progreso.
- **Eventos repetibles:** Si el jugador pierde un evento, puede reproducirlo más tarde.
- **Herramientas que no desaparecen:** Herramientas no se rompen permanentemente.
- **Guardados confiables:** Autosave frecuente, múltiples slots, backups (M107).

## 3. Combate vs Cozy

**Decisión sobre combate:**
- Combate no es requisito del género cozy
- Si se agrega combate, debe ser:
  - No centrado en violencia extrema
  - Opcional o evitable
  - Con propósito narrativo o de cooperación
  - Sin penalizaciones severas por perder
- Alternativas: cooperación, construcción, exploración, creatividad

**Ejemplo de combate cozy:**
- Combate cooperativo con NPCs
- Combate no letal (aterrorizar, no matar)
- Combate con propósito de defensa, no agresión
- Combate sin penalizaciones por perder (reaparición cercana)

## 4. Sistema de hambre vs Cozy

**Decisión sobre hambre:**
- Hambre no es requisito del género cozy
- Si se agrega hambre, debe ser:
  - No castigadora (no muerte por hambre)
  - Sin penalizaciones severas
  - Con食物 fácilmente accesible
  - Sin FOMO (comida siempre disponible)
- Alternativas: agricultura relajante, cocina creativa, compartir comida con NPCs

**Ejemplo de hambre cozy:**
- Hambre reduce stamina, no mata
- Comida abundante y fácil de cultivar
- Compartir comida con NPCs aumenta amistad
- No penalización por no comer por tiempo prolongado

## 5. Ritmo de juego

**Principio: no castigar por jugar poco**
- El juego debe ser disfrutable a cualquier ritmo
- No penalizar por inactividad
- Progresión accesible para jugadores casuales
- No eventos exclusivos de tiempo real

**Implementación:**
- Autosave frecuente (no perder progreso por cerrar juego)
- Progresión no depende de tiempo real
- NPCs no desaparecen por inactividad
- Recursos no degradan por tiempo

## 6. Metagaming vs Cozy

**Principio: no obligar a optimizar constantemente**
- Evitar metagaming forzado
- Permitir estilos de juego casuales
- No penalizar por no optimizar
- Permitir descubrimiento y experimentación

**Implementación:**
- No builds óptimos obligatorios
- No min-maxing forzado
- No penalización por elegir opciones subóptimas
- Permitir exploración sin presión de eficiencia

## 7. Variedad de NPCs

**Principio: no hacer que todos los NPC sean iguales**
- Variedad en personalidades
- Variedad en historias
- Variedad en roles
- Variedad en apariencias
- Cada NPC debe tener identidad única

**Implementación:**
- Sistema de personalidades (M64)
- Sistema de historias y backgrounds
- Roles diferentes (agricultor, pescador, artesano, comerciante)
- Apariencias procedurales variadas
- Diálogos únicos por NPC

## 8. Procedural vs Curado

**Principio: no llenar el mundo únicamente con contenido procedural vacío**
- Balance entre procedural y contenido curado
- Procedural para base (terreno, biomas, recursos)
- Curado para momentos memorables (NPCs, misiones, puzzles)
- Calidad > cantidad

**Implementación:**
- Generación procedural de mundo (M10)
- NPCs curados con historias únicas
- Misiones curadas con propósito narrativo
- Puzzles curados con lógica clara
- Eventos curados para momentos especiales

## 9. Puzzles arbitrarios vs Lógicos

**Principio: no usar puzzles arbitrarios**
- Puzzles con lógica clara
- Puzzles con propósito narrativo
- No puzzles por el sake de puzzles
- Puzzles deben enseñar mecánicas del juego

**Implementación:**
- Puzzles basados en mecánicas del juego
- Puzzles con pistas claras
- Puzzles con múltiples soluciones
- Puzzles que se conectan con la historia

## 10. Información esencial

**Principio: no esconder información esencial detrás de una sola acción fácilmente perdible**
- Información accesible
- Información redundante
- Múltiples vías para descubrir información
- No gatekeeping de información esencial

**Implementación:**
- Información en múltiples lugares (NPCs, libros, señales)
- Información redundante (si el jugador pierde una pista, hay otra)
- Información accesible sin condiciones difíciles
- Tutorials opcionales pero accesibles

## 11. Economía cozy

**Principio: no diseñar la economía alrededor del grind**
- Economía sin grind forzado
- Economía sin pay-to-win
- Economía sin penalizaciones por no grindear
- Economía equilibrada para jugadores casuales

**Implementación:**
- Recursos accesibles sin grind excesivo
- Progresión sin barreras de grind
- No premium currency (si hay monetización)
- No penalización por no farmear
- Economía basada en cooperación, no competencia

## 12. Performance vs Visuals

**Principio: no sacrificar rendimiento por una pequeña mejora visual**
- Performance prioridad sobre bells and whistles
- 60 FPS en hardware medio > efectos visuales excesivos
- Optimización obligatoria (M61)
- Settings gráficos ajustables (M90)

**Implementación:**
- Prioridad 60 FPS en hardware medio
- Settings gráficos para hardware bajo
- LODs para modelos 3D (M50)
- Optimización de assets (M61)
- Profiling regular (M61)

## 13. Sistemas con propósito

**Principio: no añadir sistemas sin comprobar que aporten algo**
- Cada sistema debe tener propósito claro
- Justificación obligatoria antes de agregar sistema
- Sistema debe aportar a la visión cozy
- Sistema debe tener integración con otros sistemas

**Implementación:**
- Documento de justificación para cada sistema
- Revisión de diseño antes de implementar
- Pruebas de usabilidad para verificar propósito
- Eliminación de sistemas que no aportan

## 14. Calidad vs Cantidad

**Principio: no ampliar el mapa solamente para hacerlo grande**
- Calidad > cantidad
- Mundo denso y significativo > mundo grande y vacío
- Cada área debe tener propósito
- No empty open world

**Implementación:**
- Diseño de mundo por áreas significativas
- Cada área tiene NPCs, recursos, misiones
- No áreas vacías sin propósito
- Mundo denso y conectado

## 15. Profundidad vs Cantidad

**Principio: no confundir cantidad con profundidad**
- Profundidad mecánica > cantidad de contenido
- Sistemas interconectados > listas de tareas
- Calidad de mecánicas > cantidad de mecánicas
- Significado > volumen

**Implementación:**
- Sistemas interconectados (M07)
- Mecánicas con profundidad y propósito
- No listas de tareas vacías
- Cada mecánica se conecta con otras

## 16. Monetización

**Principio: no introducir monetización que destruya la experiencia**
- Si hay monetización, debe ser opcional
- Si hay monetización, debe ser no intrusiva
- No pay-to-win
- No FOMO en monetización
- No premium currency que afecte gameplay

**Implementación:**
- Cosmetics opcionales (si hay monetización)
- DLCs con contenido adicional, no必需
- No loot boxes
- No gacha
- No premium currency que afecte gameplay

## 17. Servicios externos

**Principio: no depender de servicios externos sin plan de contingencia**
- Offline-first
- Fallbacks para servicios externos
- El juego debe funcionar sin conexión
- No dependencia crítica de servicios externos

**Implementación:**
- Offline mode (M107 offline backups)
- Fallbacks para servicios externos (M107, M122)
- No requerimiento de conexión para jugar
- Servicios externos opcionales (cloud saves, leaderboards)

## 18. Licencias de assets

**Principio: no utilizar assets sin licencia clara**
- Licencias claras y documentadas
- Cada asset debe tener licencia explícita
- Atribución si corresponde
- Comercialización permitida si es necesario

**Implementación:**
- Documento de licencias de assets
- Cada asset en carpeta con archivo de licencia
- Verificación de licencias antes de usar
- Atribución en créditos (M131)

## 19. Knowledge sharing

**Principio: no depender de una sola persona para conocimiento crítico del proyecto**
- Documentación (M02)
- Pair programming
- Knowledge sharing
- No silos de conocimiento

**Implementación:**
- Documentación de arquitectura (M07)
- Documentación de sistemas
- Code reviews (M111)
- Pair programming en sistemas críticos
- Knowledge sharing sessions

## 20. Proceso de revisión de decisiones

**Checklist de revisión contra principios:**
- [ ] ¿Esta decisión respeta la filosofía cozy?
- [ ] ¿Esta decisión no castiga al jugador por jugar poco?
- [ ] ¿Esta decisión no obliga a optimizar constantemente?
- [ ] ¿Esta decisión aporta calidad, no solo cantidad?
- [ ] ¿Esta decisión no sacrifica rendimiento por bells and whistles?
- [ ] ¿Esta decisión tiene propósito claro?
- [ ] ¿Esta decisión no depende de servicios externos sin fallback?
- [ ] ¿Esta decisión no introduce dependencia crítica de una sola persona?

**Registro de desviaciones justificadas:**
- Si una decisión desvía de un principio, debe ser justificada explícitamente
- Justificación debe incluir: por qué es necesaria, alternativas consideradas, impacto en la visión
- Justificación debe ser aprobada por equipo de diseño
- Justificación debe ser documentada en AGENTS.md o documento específico
