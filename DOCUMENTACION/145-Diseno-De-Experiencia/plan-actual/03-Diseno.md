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
└──自由 exploración
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

- [ ] WCAG 2.1 AA para contraste de colores
- [ ] Todos los sonidos tienen representación visual
- [ ] Todos los eventos visuales tienen representación de audio
- [ ] Texto legible en todos los tamaños de pantalla
- [ ] Controles funcionan con una mano (opcional)
