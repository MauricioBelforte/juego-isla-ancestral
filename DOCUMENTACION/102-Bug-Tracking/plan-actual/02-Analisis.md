**Modelo:** SWE-1.6
**Plataforma:** Devin

# 02-Analisis.md — Módulo 102: Bug Tracking

## 1. Análisis de los puntos del plan maestro (sección 101)

| # | Punto | Resolución |
|---|---|---|
| 1 | Elegir herramienta de bugs | ✅ GitHub Issues (ya disponible por el proyecto) |
| 2 | Crear categorías | ✅ Gameplay, UI/UX, Audio, Render/Física, Networking, Assets, Build/Deploy, Localización, Performance, Crash |
| 3 | Crear severidades | ✅ Crítico (bloquea release), Mayor (bloquea milestone), Menor (no bloquea), Trivial (cosmético) |
| 4 | Crear prioridades | ✅ Inmediata (hotfix), Alta (sprint actual), Media (backlog), Baja (eventual) |
| 5 | Definir reproducibilidad | ✅ Siempre (100%), A veces (intermitente), Nunca (no reproducible) |
| 6 | Registrar pasos para reproducir | ✅ Plantilla con sección "Pasos para reproducir" (número y detalle) |
| 7 | Registrar versión | ✅ Campo "Versión del juego" (ej: v0.5.2-alpha) |
| 8 | Registrar plataforma | ✅ Campo "Plataforma" (Windows, Linux, macOS, especificar specs) |
| 9 | Adjuntar logs | ✅ Campo para adjuntar archivo de log (Logs/*.md) |
| 10 | Adjuntar capturas | ✅ Campo para adjuntar screenshots |
| 11 | Adjuntar videos | ✅ Campo para adjuntar enlaces a videos (opcional) |
| 12 | Registrar seed cuando corresponda | ✅ Campo "Seed de generación" (para bugs de mundo procedural) |
| 13 | Registrar save afectado | ✅ Campo "Archivo de guardado" (para bugs de persistencia) |
| 14 | Asignar responsable | ✅ Asignación en GitHub (@usuario) |
| 15 | Definir estado | ✅ Etiquetas: new, in-progress, verified, closed, wontfix, duplicate |
| 16 | Verificar corrección | ✅ Checklist de verificación en el issue |
| 17 | Hacer regresión | ✅ Prueba de no-breaking changes en áreas relacionadas |
| 18 | Cerrar bug | ✅ Comentario de cierre con versión de fix |
| 19 | Mantener historial | ✅ GitHub mantiene historial automático de comentarios/cambios |
| 20 | Integración con pruebas | ✅ Referencia a test automatizado si existe (M112) |
| 21 | Métricas de bugs | ✅ Dashboard simple con bugs abiertos/cerrados por milestone |

## 2. Alternativas consideradas

| Herramienta | Pros | Contras | Decisión |
|---|---|---|---|---|
| GitHub Issues | Gratis, integrado con repo, UI conocida, API potente | Requiere configuración de templates | ✅ ELEGIDO |
| Jira | Potente, workflows personalizables | Costo, overkill para equipo pequeño | ❌ Descartado |
| Trello | Visual, simple | Limitado para tracking técnico profundo | ❌ Descartado |
| Notion | Flexible, documentación integrada | No optimizado para tracking de bugs técnico | ❌ Descartado |

## 3. Estructura de categorías (taxonomy)

### Gameplay
- Movimiento del jugador
- Interacción con objetos
- Comportamiento de NPC
- Sistemas de combate (si aplica)
- Progresión y desbloqueos

### UI/UX
- Menús y HUD
- Inventario
- Diálogos
- Controles y accesibilidad
- Responsive

### Audio
- Música
- Efectos de sonido
- Volumen y mezcla
- Espacialización

### Render/Física
- Gráficos y shaders
- Iluminación
- Voxel rendering
- Colisiones
- Framerate

### Networking
- Multiplayer (M76/M77 si se implementa)
- Sincronización
- Latencia

### Assets
- Modelos 3D
- Texturas
- Animaciones
- Faltantes o incorrectos

### Build/Deploy
- Errores de compilación
- Instalador
- Plataformas específicas

### Localización
- Traducciones
- Textos cortados
- Encoding

### Performance
- FPS bajo
- Memoria
- Cargas lentas

### Crash
- Cuelgues del juego
- Excepciones no manejadas

## 4. Matriz de severidad vs prioridad

| Severidad \ Prioridad | Inmediata | Alta | Media | Baja |
|---|---|---|---|---|
| Crítico | ✅ Hotfix | ✅ Sprint actual | ⚠️ Excepción | ❌ No aplica |
| Mayor | ⚠️ Solo si bloquea milestone | ✅ Sprint actual | ✅ Backlog cercano | ⚠️ Excepción |
| Menor | ❌ No aplica | ⚠️ Solo si acumulado | ✅ Backlog | ✅ Eventual |
| Trivial | ❌ No aplica | ❌ No aplica | ⚠️ Solo si acumulado | ✅ Eventual |

## 5. Plantilla de issue (estructura)

```markdown
## Descripción del bug
[Breve descripción del problema]

## Severidad
- [ ] Crítico
- [ ] Mayor
- [ ] Menor
- [ ] Trivial

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

## Pasos para reproducir
1. Ir a...
2. Hacer...
3. Ver...

## Comportamiento esperado
[Lo que debería pasar]

## Comportamiento actual
[Lo que pasa en realidad]

## Reproducibilidad
- [ ] Siempre (100%)
- [ ] A veces (intermitente)
- [ ] Nunca (no reproducible)

## Contexto técnico
- **Versión del juego:** v...
- **Plataforma:** Windows/Linux/macOS
- **Specs:** [CPU/GPU/RAM si relevante]
- **Seed de generación:** [si aplica]
- **Archivo de guardado:** [si aplica]

## Evidencia
- [ ] Log adjunto (Logs/*.md)
- [ ] Screenshot adjunto
- [ ] Video adjunto (enlace)

## Referencias
- Issues relacionados: #
- Módulos afectados: MXX, MYY
```

## 6. Flujo de trabajo (workflow)

```
Nuevo → En Progreso → Verificado → Cerrado
  ↓         ↓           ↓
Wontfix   Duplicate   Reabierto
```

**Estados detallados:**
- **Nuevo:** Issue creado, pendiente de triage
- **En Progreso:** Asignado a desarrollador, trabajo en curso
- **Verificado:** Fix implementado, awaiting QA verification
- **Cerrado:** Verificado y confirmado, versión de fix documentada
- **Wontfix:** No se corregirá (por diseño, costo, deprecated)
- **Duplicate:** Marcado como duplicado de otro issue
- **Reabierto:** Verificación falló, vuelve a En Progreso

## 7. Integración con otros módulos

- **M101 (QA General):** Los testers crean issues desde esta plantilla
- **M103 (Logging):** Los logs adjuntos provienen del sistema de logging
- **M110 (Debug Menu):** Debug info capturado desde el menú se adjunta al issue
- **M112 (Testing Automático):** Tests que fallan crean issues automáticamente
- **M122 (Crash Reporting):** Crashes reportados generan issues con metadata

## 8. Decisiones clave

- **GitHub Issues:** Elección natural (gratis, integrado, conocido por el equipo)
- **Plantilla obligatoria:** Estandariza la calidad de los reports
- **Severidad separada de prioridad:** Permite bugs críticos de baja prioridad (raros pero posibles)
- **Metadata específica:** Seed y save son críticos para bugs de mundo procedural (M08/M10)
- **Historial automático:** GitHub ya lo provee, no requiere tooling adicional
