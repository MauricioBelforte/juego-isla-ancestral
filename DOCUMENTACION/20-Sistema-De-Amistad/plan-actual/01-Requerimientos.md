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

## 5. SISTEMA DE AMISTAD DETALLADO (Stardew Valley + Animal Crossing)

**Filosofía:** La amistad es una inversión a largo plazo. No hay atajos. No hay penalización por no jugar. Los NPCs recuerdan las interacciones y reaccionan en consecuencia.

### 5.1 Niveles de Amistad

| Nivel | Nombre | Puntos necesarios | Desbloquea |
|-------|--------|-------------------|------------|
| 0 | Desconocido | 0 | Nada |
| 1 | Conocido | 50 | Diálogos básicos |
| 2 | Amigo | 150 | Misiones secundarias, regalo semanal |
| 3 | Buen amigo | 300 | Regalos exclusivos, eventos |
| 4 | Mejor amigo | 500 | Confidencias, recetas, visitas diarias |
| 5 | Alma gemela | 800 | Evento especial, viaje juntos, regalo legendario |

**Regla cozy:** Los puntos NUNCA bajan por no jugar. Solo bajan por acciones negativas explícitas (regalar algo que odia). Nunca bajan de nivel.

### 5.2 Fuentes de Puntos de Amistad

| Acción | Puntos | Frecuencia | Costo |
|--------|--------|------------|-------|
| Hablar | +1 | 1×/día/NPC | Gratis |
| Regalar (le gusta) | +2/+3 | 1×/semana/NPC | Item + monedas |
| Regalar (neutral) | +0 | 1×/semana/NPC | Item + monedas |
| Regalar (le disgusta) | -1/-2 | 1×/semana/NPC | Item + monedas |
| Sentarse juntos | +1 | 1×/día/NPC | 30 min tiempo |
| Cocinar juntos | +2 | 1×/semana/NPC | Ingredientes |
| Pasear juntos | +1 | 1×/semana/NPC | 1 hora tiempo |
| Ayudar con trabajo | +2 | 1×/semana/NPC | 1 hora tiempo |
| Celebrar cumpleaños | +5 | 1×/año/NPC | Regalo especial |
| Completar misión del NPC | +3 | Según misión | Variable |

### 5.3 Sistema de Regalos Detallado

#### Gustos por NPC (ejemplo)

| NPC | ¡Le encanta! | Le gusta | Neutral | No le gusta | ¡Le odia! |
|-----|-------------|----------|---------|-------------|-----------|
| Luna (pintora) | Cuadros, flores raras | Libros, música | Comida | Herramientas | Minerales |
| Rocky (herrero) | Minerales raros, herramientas | Madera, piedra | Comida | Flores | Libros |
| Coral (exploradora) | Mapas, antiguas | Conchas, piedras | Comida | Ropa | Muebles |
| Chef (cocinero) | Ingredientes raros, recetas | Especias, hierbas | Flores | Herramientas | Minerales |
| Fin (pescador) | Pescados raros, cebo | Conchas, coral | Comida | Libros | Flores |
| Flora (jardinera) | Flores raras, semillas | Plantas, tierra | Comida | Minerales | Herramientas |
| Sage (bibliotecario) | Libros, glifos | Cristales, mapas | Comida | Herramientas | Ropa |
| Merc (mercader) | Monedas, items raros | Comida cara | Flores | Herramientas | Libros |

#### Impacto de Regalos

| Calificación | Puntos | Recuerdo | Memoria |
|-------------|--------|----------|---------|
| ¡Le encanta! | +3 | 60 días | Recuerda el regalo y lo menciona |
| Le gusta | +2 | 30 días | Recuerda que le gustó |
| Neutral | +0 | 7 días | No recuerda |
| No le gusta | -1 | 30 días | Recuerda y menciona desagrado |
| ¡Le odia! | -2 | 60 días | Recuerda y menciona enfado |

#### Reglas de Repetición

- Si el jugador repite un mismo regalo, la reacción es -1 punto adicional
- Si el jugador da 3 regalos iguales seguidos, el NPC dice "¿Otro igual?"
- El NPC recuerda los últimos 10 regalos recibidos
- No hay límite de cuántos regalos puedes dar por semana (solo 1 efectivo)

### 5.4 Eventos de Amistad

| Evento | Condición | Recompensa | Frecuencia |
|--------|-----------|------------|------------|
| Cumpleaños del NPC | Amistad ≥ 2 | +5 amistad, regalo especial | 1×/año/NPC |
| Fiesta sorpresa | Amistad ≥ 4 | NPCs invitados vienen a la casa | 1×/año |
| Viaje juntos | Amistad = 5 | Viaje a isla especial | 1× por NPC |
| Carta de agradecimiento | 10 regalos dados | Receta secreta | 1× por NPC |
| Talla en madera | 20 visitas del NPC | Mueble exclusivo | 1× por NPC |
| Cena especial | Amistad ≥ 3 | Comida rara + conversación | 1×/mes |

### 5.5 Memoria de Amistad

- Cada NPC recuerda: regalos recibidos, visitas del jugador, favoritos hechos
- La memoria afecta los diálogos (M21): el NPC menciona cosas pasadas
- Ejemplo: "¿Te acuerdas del cuadro que me regalaste? Sigue en mi pared."
- Los NPCs hablan entre ellos del jugador (reputación social)
- Si dos NPCs son amigos, comparten experiencias del jugador

### 5.6 Decaimiento (suave, cozy)

| Condición | Decaimiento | Mínimo |
|-----------|-------------|--------|
| No jugar 1 semana | 0 puntos | — |
| No jugar 1 mes | 0 puntos | — |
| No visitar NPC 1 mes | -2 puntos | Nunca baja de nivel 1 |
| No visitar NPC 3 meses | -5 puntos | Nunca baja de nivel 1 |

**Regla cozy:** El decaimiento es MUY suave. Si el jugador ya era amigo (nivel 2+), nunca baja de nivel 1. No hay FOMO.

### 5.7 Anti-Frustración

| Principio | Implementación |
|-----------|---------------|
| Sin FOMO | Todo contenido desbloqueable siempre |
| Sin timers obligatorios | No hay recompensas diarias que perder |
| Sin penalización por ausencia | La amistad no baja significativamente |
| Sin bloqueo de contenido | Todo accesible sin amistad alta |
| Sin presión de社交 | Puedes ignorar a los NPCs sin consecuencias |
| Sin penalización por regalo malo | Solo -1/-2 puntos (recuperable en 1-2 semanas) |

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M019** — NPC y Vecinos | Sistema de amistad |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M038** — Economía | Usado por economía |
| **M093** — Balance | Usado por balance |
| **M162** — Diálogos Contextuales de NPCs | Usado por diálogos contextuales de npcs |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M019** — NPC y Vecinos | Depende de este módulo |
| **M038** — Economía | Este módulo lo necesita |
| **M093** — Balance | Este módulo lo necesita |
| **M162** — Diálogos Contextuales de NPCs | Este módulo lo necesita |

