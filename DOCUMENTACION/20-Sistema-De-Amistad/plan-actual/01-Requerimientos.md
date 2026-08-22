**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 20: Sistema de Amistad

## ID del Módulo
- **Código:** M20 (plan maestro: sección 19 — Sistema de Amistad)
- **Carpeta:** `DOCUMENTACION/20-Sistema-De-Amistad/`
- **Dependencias:** M19 (NPC y Vecinos), M14 (Inventario), M29 (Reloj/Calendario). Relaciones: M23 (Historias Secundarias), M21 (Diálogos), M26 (Guardado/Persistencia), M31 (Clima), M32 (Estaciones)
- **Stack:** Godot 4.x (>= 4.4.1) + Voxel Tools (GDExtension) + GDScript
- **Delegable desde:** hoy (diseño completo; implementación tras NPC base M19 e Inventario M14)

## 1. Problema

Dar profundidad emocional al juego cozy sin mecánicas punitivas: el jugador debe poder construir relaciones significativas con los vecinos de la isla mediante regalos, charlas, cartas y eventos, con progresión por niveles y recompensas, pero sin decaimiento que castigue la ausencia (retención sin FOMO, sección 93 del plan maestro). El sistema debe ser ligero (data-driven), determinista y persistible.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Niveles de amistad | Niveles progresivos por vecino (p. ej. 0-10): Conocido, Amigo, Amigo cercano, Mejor amigo; cada nivel con umbral de puntos y desbloqueos |
| RF2 | Puntos de amistad | Acumulación de puntos (p. ej. 0-100 por nivel) mediante regalos, charlas, cartas, favores y eventos; sin fuente de decaimiento |
| RF3 | Regalos diarios | Un regalo efectivo por vecino y dia; el resto suma puntos minimos (cortesia); gustos/disgustos por vecino (M19) |
| RF4 | Preferencias de regalos | Cada vecino tiene gustos, disgustos y regalos amados (definidos en M19); el evaluador pondera rareza y calidad |
| RF5 | Charlas | Conversar con un vecino una vez por dia otorga puntos y abre variantes de dialogo segun nivel (M21) |
| RF6 | Cartas | Sistema de correspondencia: enviar/recibir cartas que otorgan puntos, objetos adjuntos y respuestas escritas por el vecino |
| RF7 | Recompensas por nivel | Al subir de nivel: recetas, objetos decorativos, emotes, frases especiales, acceso a eventos, contenido narrado (M23) |
| RF8 | Eventos con amigos | Reuniones, visitas a casa, picnics, celebraciones de cumpleaños y festivales (M73) convocables segun nivel; sin obligacion |
| RF9 | Sin decaimiento | La amistad nunca baja por no jugar ni por ignorar al vecino; solo acciones negativas explícitas (opcional) podrían afectar, y quedan fuera del alcance base |
| RF10 | Recuerdos del vecino | El NPC recuerda interacciones destacadas (primer regalo, cumpleaños celebrado) y las menciona en dialogo (M19/M21) |

## 3. Requisitos No Funcionales

- **Cozy:** cero FOMO; contenido desbloqueable siempre disponible (se puede completar despues); sin timers de recompensas obligatorias diarias.
- **Rendimiento:** el sistema es data-driven y se evalua solo ante acciones del jugador; sin bucles por vecino en update; costo por evento de regalo menor a 1 ms.
- **Determinismo:** evaluador de regalos sin aleatoriedad crítica (PRNG M29 solo para variantes decorativas de respuesta).
- **Persistencia:** estado por vecino guardable (puntos, nivel, historial de hoy, cartas pendientes, eventos celebrados) con schema versionado (M26).
- **Desacoplamiento:** logica pura (puntos, evaluador, niveles) separada de la capa de UI; M20 expone API y emite señales.

## 4. Criterios de Aceptación

1. Los 26 puntos de la seccion 19 del plan maestro resueltos.
2. Regalo diario, charla diaria y cartas implementados con limites claros por dia (M29).
3. Niveles 0-10 con umbrales, desbloqueos y recompensas definidos en data.
4. Cero decaimiento: ausencia prolongada no reduce puntos ni niveles.
5. Estado persistible y restaurable (guardado/recepcion M26).
6. Gustos/disgustos por vecino consumidos desde los datos de M19.
7. Eventos con amigos conectados a M23 (misiones de amistad) y M21 (dialogos).
8. Delegable para implementacion.
---

## 4. EXPANSIONES COZY (2026-08-22)

### 4.1 Niveles de Amistad Expandidos

| Nivel | Nombre | Desbloquea | Regalo semanal |
|-------|--------|------------|----------------|
| 0 | Desconocido | Nada | No |
| 1 | Conocido | Diálogos básicos | No |
| 2 | Amigo | Misiones secundarias | Sí (básico) |
| 3 | Buen amigo | Regalos exclusivos | Sí (medio) |
| 4 | Mejor amigo | Confidencias, recetas | Sí (raro) |
| 5 | Alma gemela | Evento especial, viaje juntos | Sí (legendario) |

### 4.2 Sistema de Regalos Mejorado

#### Gustos por Categoría de NPC

| Tipo NPC | Le gusta | Le disgusta |
|----------|----------|-------------|
| Herrero | Minerales, herramientas | Flores, comida |
| Carpintero | Madera, muebles | Minerales, ropa |
| Pescador | Pescados, cebo | Plantas, minerales |
| Jardinero | Flores, semillas | Minerales, madera |
| Cocinero | Ingredientes, recetas | Herramientas, minerales |
| Arqueólogo | Glifos, reliquias | Comida, ropa |
| Mercader | Items raros, monedas | Comida común |
| Sabio | Libros, glifos | Herramientas, comida |

#### Impacto de Regalos en Amistad

| Calificación | Amistad | Recuerdo |
|-------------|---------|----------|
| ¡Le encanta! | +3 | 30 días |
| Le gusta | +2 | 14 días |
| Neutral | +0 | 7 días |
| No le gusta | -1 | 30 días |
| ¡Le odia! | -2 | 60 días |

### 4.3 Eventos de Amistad

| Evento | Condición | Recompensa |
|--------|-----------|------------|
| Cumpleaños del NPC | 1×/año (M29) | +5 amistad, regalo especial |
| Fiesta sorpresa | Amistad nivel 4 | NPCs invitados vienen a la casa |
| Viaje juntos | Amistad nivel 5 | Viaje a isla especial |
| Carta de agradecimiento | 10 regalos dados | Receta secreta |
| Talla en madera | 20 visitas del NPC | Mueble exclusivo |

### 4.4 Memoria de Amistad

- Cada NPC recuerda: regalos recibidos, visitas del jugador, favoritos hechos
- La memoria afecta los diálogos (M21): el NPC menciona cosas pasadas
- Si el jugador no visita un NPC por mucho tiempo, la amistad baja lentamente (-1/mes)
- Pero nunca baja de nivel 1 (si ya eran amigos, se mantienen)
- Los NPCs hablan entre ellos del jugador (reputación social)
