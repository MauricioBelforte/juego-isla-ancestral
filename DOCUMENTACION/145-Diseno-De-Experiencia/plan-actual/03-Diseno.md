# Módulo 145: Diseño de Experiencia — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:32:00

## 1. Player Journey Completo

### Fases del Journey

```
FASE 1: DESCUBRIMIENTO
├── ve trailer / screenshots
├── lee descripción
└── decide descargar

FASE 2: PRIMERA VEZ
├── abre el juego
├── ve pantalla de carga
├── llega al menú principal
└── selecciona "Nueva Partida"

FASE 3: INTRODUCCIÓN
├── escena de apertura (cutscene)
├── llega a la isla
├── conoce al primer NPC
└── recibe primera misión

FASE 4: PRIMEROS PASOS
├── aprende a moverse (orgánico)
├── aprende a interactuar (orgánico)
├── aprende a construir (orgánico)
└── completa primera misión

FASE 5: JUEGO PRINCIPAL
├── explora la isla
├── completa misiones
├── construye su casa
├── socializa con NPCs
└── descubre secretos

FASE 6: PROGRESIÓN
├── desbloquea nuevas áreas
├── mejora herramientas
├── completa historia principal
└── alcanza meta principal

FASE 7: POSTGAME
├── contenido restante
├── coleccionables
├── desafíos opcionales
└── exploración libre
```

## 2. Sistema de Onboarding

### Eventos Guiados (No Tutoriales)

| Evento | Cuándo | Qué enseña | Cómo |
|--------|--------|-----------|------|
| **Primer paso** | Al llegar a la isla | Movimiento | NPC dice "ven conmigo" |
| **Primera interacción** | Al encontrar item | Interacción F | Item brilla, prompt sutil |
| **Primera herramienta** | Al encontrar herramienta | Uso de herramienta | NPC la entrega y dice "prueba" |
| **Primera construcción** | Al tener recursos | Construcción | NPC sugiere "construye algo aquí" |
| **Primera misión** | Al hablar con NPC | Misiones | NPC pide ayuda |
| **Primer viaje** | Al explorar | Mapa/viaje | NPC menciona otro lugar |

### Prerrequisitos de Onboarding

- [ ] Cada evento se activa solo cuando el jugador tiene lo necesario
- [ ] No forzar al jugador a completar el tutorial
- [ ] Permitir saltar tutorials (opción en settings)
- [ ] Recordatorios opcionales si el jugador está perdido

## 3. Arquitectura de Información de Menús

### Estructura de Menú Principal

```
MENÚ PRINCIPAL
├── Nueva Partida
├── Continuar
├── Cargar Partida
├── Configuración
│   ├── Gráficos
│   ├── Audio
│   ├── Controles
│   └── Accesibilidad
├── Créditos
└── Salir
```

### Estructura de Menú In-Game

```
MENÚ IN-GAME (ESC)
├── Reanudar
├── Inventario
├── Mapa
├── Misiones
├── Configuración
│   ├── Gráficos
│   ├── Audio
│   ├── Controles
│   └── Accesibilidad
├── Guardar
├── Cargar
├── Menú Principal
└── Salir
```

### Reglas de Navegación

- Máximo 3 niveles de profundidad
- Botón de "Volver" siempre visible
- Atajos de teclado para acciones frecuentes
- Búsqueda en menús con muchos items

## 4. Sistema de Feedback

### Tipos de Feedback

| Tipo | Ejemplo | Uso |
|------|---------|-----|
| **Visual** | Partículas, flashes, iconos | Acciones del jugador |
| **Sonoro** | Efectos de sonido, música | Eventos importantes |
| **Háptico** | Vibración del gamepad | Impactos, logros |
| **Textual** | Mensajes, tooltips | Información detallada |

### Reglas de Feedback

| Acción | Feedback |
|--------|----------|
| Recoger item | Flash verde + sonido satisfactorio + partículas |
| Construir | Sonido de construcción + partículas de polvo |
| Completar misión | Fanfarria + notificación + recompensa visual |
| Recibir daño | Flash rojo + vibración + sonido de impacto |
| Descubrir lugar | Texto + sonido de descubrimiento + mapa actualizado |
| Hablar con NPC | Bubble de diálogo + sonido de voz |

## 5. Estándares de Accesibilidad

### Requisitos Mínimos

- [ ] Subtítulos para todo el diálogo
- [ ] Opciones de color-blindness
- [ ] Tamaño de texto ajustable
- [ ] Controles remapeables
- [ ] Opciones de dificultad (sin penalizaciones)
- [ ] Soporte para gamepad y teclado
- [ ] Modo de alto contraste
- [ ] Reducción de movimiento

### Checklist de Accesibilidad

### Specs items degradados T198 (2026-10-26, Reflection-Beam-1.0)
- **L55/L56 (testear onboarding con jugadores nuevos + iterar):** requiere build jugable; planificado en plan-testing S1 (M138+). Experiencia diseñada en §1. Playtesting deferred.
- **L74/L75 (testear navegación + iterar):** requiere build; plan-testing S2 (M138). Navegación diseñada.
- **L93 (testear feedback con jugadores):** requiere build; plan-testing S3 (M139).
- **L108 (verificar sonidos tienen representación visual):** requiere audio integrado (M41-M44); §3. M41 58/110 y M42 62/100 (Con dudas, NO cerrados al 2026-10-15); solo M43 completado 97/97. Representación visual diseñada en §3. Deferred a integración.
- **L109 (verificar eventos visuales tienen audio):** requiere VFX integrados (M52); §3 diseñado. M52 completado 147/148 (al 2026-10-15). Integración deferred.
- **L111 (testear con herramientas de accesibilidad):** requiere build; programado M141/M142 (§3). KnownIssue no bloqueante DoD.
- **L124 (testear ritmo con jugadores):** requiere build; plan-testing S3 (M139).
- **L138 (revisar métricas mensualmente):** actividad recurrente; inicia con telemetría activa (M105) o playtests (M114); proceso diseñado → M105 ✅; revisión mensual programada post-release. Policy documented.
- **L144 (recolectar feedback cualitativo):** requiere sesión real con jugadores (S1-S5). KnownIssue no bloqueante DoD.
- **L145 (recolectar feedback cuantitativo):** requiere build con métricas del hito. M105 ✅. Telemetría lista para datos.
- **L146 (iterar según hallazgos):** requiere hallazgos de las sesiones. KnownIssue no bloqueante DoD. Proceso diseñado en §4.
