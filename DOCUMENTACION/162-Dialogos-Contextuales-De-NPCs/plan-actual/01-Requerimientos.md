**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 162: Diálogos Contextuales de NPCs

## ID del Módulo
- **Código:** M162
- **Carpeta:** `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/`
- **Dependencias:** M21 (Diálogos), M22 (Historia Principal), M19 (NPC y Vecinos), M161 (Diseño Visual), M20 (Amistad), M29 (Tiempo)
- **Relaciones:** M23 (Historias Secundarias), M160 (Ubicaciones), M39 (Tiendas)

## 1. Problema

Los NPCs tienen personalidad (M19) y apariencia (M161), pero no tienen diálogos definidos por etapa del juego. Cuando el jugador avanza en la historia principal (M22), los NPCs deben cambiar sus diálogos para reflejar lo que ha pasado. Sin esto, el mundo no se siente vivo y el jugador no percibe que sus acciones afectan al entorno.

## 2. Objetivo

Definir la progresión de diálogos de cada NPC por capítulo de la historia principal. Cada NPC tiene una lista de diálogos que cambian según: capítulo actual, nivel de amistad, estación, hora del día y ubicación. Los diálogos deben respetar la historia principal (M22) y reflejar los eventos de cada capítulo.

## 3. Estructura de Capítulos (de M22)

| Capítulo | Nombre | Evento Clave |
|----------|--------|--------------|
| 0 | Prólogo | Llegada al pueblo, tutorial |
| 1 | Las Cenizas Futuras | Descubrimiento de cenizas, primer misterio |
| 2 | El Puente de las Memorias | Construcción/paso del puente, recuerdos |
| 3 | El Jardín Ahogado | Inundación, sombra del templo |
| 4 | El Valle de los Vientos | Sellos, templos, progresión |
| 5 | La Noche Eterna | Eclipse, momento tenso |
| 6 | El Corazón del Mundo | Geoda, descubrimiento final |
| 7 | La Brisa y el Sello | Final, elección del jugador |

## 4. Tipos de Diálogo

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| SALUDO | Saludo al acercarse | "¡Buenos días!" |
| HISTORIA | Información de la trama | "Las cenizas no son volcánicas..." |
| MISION | Asigna o comenta misión | "¿Podrías traerme...?" |
| AMBIENTE | Comentarios del entorno | "Hoy hace un día hermoso" |
| AMISTAD | Basado en nivel de amistad | "Eres mi mejor amigo" |
| ESTACIONAL | Por estación del año | "En primavera todo florece" |
| HORA | Por hora del día | "¿Trabajando tan tarde?" |

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Diálogos por capítulo | Cada NPC tiene diálogos para cada capítulo (0-7) |
| RF2 | Diálogos por amistad | 3 niveles: desconocido (0-29), conocido (30-69), amigo (70-100) |
| RF3 | Diálogos por estación | 4 variantes estacionales |
| RF4 | Diálogos por hora | 3 franjas: mañana, tarde, noche |
| RF5 | Respeto a historia | Los diálogos reflejan eventos de M22 |
| RF6 | Progresión natural | Los NPCs reaccionan a lo que el jugador ha hecho |
| RF7 | Integración con M21 | Usa el sistema de nodos de M21 |
| RF8 | Integración con M22 | Condiciones basadas en capítulo actual |
| RF9 | Integración con M20 | Condiciones basadas en amistad |
| RF10 | Organización por isla | Diálogos agrupados por isla para fácil referencia |

## 6. Criterios de Aceptación

1. 23 NPCs documentados con diálogos para cada capítulo
2. Cada NPC tiene al menos 3 tipos de diálogo (saludo, historia, ambiente)
3. Los diálogos reflejan eventos de M22 sin contradecir la historia
4. Integración con sistema de nodos de M21 verificada
5. Organización por isla clara y consistente

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M019** — NPC y Vecinos | Personalidades de NPCs |
| **M020** — Sistema de Amistad | Condiciones de amistad |
| **M021** — Diálogos | Motor de diálogos |
| **M022** — Historia Principal | Contenido por capítulo |
| **M029** — Tiempo y Calendario | Condiciones de tiempo |
| **M160** — Diseño de Ubicaciones del Mundo | Condiciones de ubicación |
| **M161** — Diseño Visual de NPCs | NPCs referenciados |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M019** — NPC y Vecinos | Depende de este módulo |
| **M020** — Sistema de Amistad | Depende de este módulo |
| **M021** — Diálogos | Depende de este módulo |
| **M022** — Historia Principal | Depende de este módulo |
| **M029** — Tiempo y Calendario | Depende de este módulo |
| **M157** — Medios de Transporte | Comparten dependencias (M019, M022) |
| **M160** — Diseño de Ubicaciones del Mundo | Depende de este módulo |
| **M161** — Diseño Visual de NPCs | Depende de este módulo |

