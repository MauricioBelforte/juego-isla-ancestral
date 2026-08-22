**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 19: NPC y Vecinos

## ID del Módulo
- **Código:** M19 (plan maestro: sección 18 — NPC y Vecinos)
- **Carpeta:** `DOCUMENTACION/19-NPC-Y-Vecinos/`
- **Relaciones:** M64 (IA de NPC, consume a M19), M21 (Diálogos), M20 (Amistad), M25 (Ruinas), M29 (Tiempo/Calendario), M61 (Rendimiento)
- **Delegable desde:** hoy (diseño completo; implementación tras el bootstrap de Godot 4.4.1 + Voxel Tools GDExtension)

## 1. Problema

La isla ancestral necesita habitantes. Sin ellos, la isla se siente vacía y el juego cozy pierde su corazón social: no hay a quién conocer, ayudar, regalar ni recordar. El problema es doble:

1. **Población:** cómo definir y gestionar los 8-12 vecinos que viven en la isla, quiénes son (especie, personalidad, historia, gustos) y cómo llegan o se van sin romper la sensación de hogar.
2. **Vida cotidiana:** cada vecino debe tener rutinas diarias creíbles (según horario), reaccionar al jugador (tecla F para interactuar), responder a los regalos con personalidad y mantener memoria de lo vivido — todo sin convertirse en una orquesta de máquinas de estado costosas (eso es dominio de M64).

## 2. Objetivos

- Poblar la isla con **8-12 vecinos simultáneos**, cada uno con identidad única y memorable.
- Vecinos **rotativos**: nuevos vecinos se mudan con **permiso del jugador**; otros se van con aviso previo, permitiendo renovar la población sin perder a los favoritos.
- Cada vecino cumple **rutinas diarias** (hora de dormir, trabajar, pasear, socializar) coherentes con su perfil.
- Interacción por **tecla F** con feedback visual claro (indicador sobre el vecino) y diálogo contextual (delegado a M21 mediante hooks).
- **Reacciones a regalos** según gustos/disgustos del perfil, con impacto en el estado emocional y el vínculo (M20).
- Integración limpia con M64 (datos de perfil y contrato de agente), M21 (diálogos), M20 (amistad) y M25 (ruinas como tema de conversación y rol de descubrimiento).

## 3. Alcance

### Dentro del alcance
- Definición del perfil de vecino (especie, personalidad, edad, profesión, historia, gustos, disgustos, rutina, hogar, relaciones, hobbies, diálogos, regalos, misiones, eventos, animaciones).
- Gestión de la población: catálogo de candidatos, plaza libre, mudanza con permiso, partida con aviso.
- Orquestación de la comunidad: `VillagerManager` (autoload) como autoridad de la población.
- Datos de rutinas y horarios por perfil (el motor de ejecución horaria pertenece a M64/M29).
- Estado emocional del vecino (`VillagerMood`) calculado por eventos (regalos, charlas, clima, estaciones).
- Memoria de interacciones del jugador con el vecino (historial de regalos, charlas, hitos).
- Hooks de diálogo (`VillagerDialogueHook`) que exponen líneas/eventos a M21 sin implementar UI de diálogo.
- Interacción por tecla F: detección de objetivo cercano, indicador visual, despacho a los sistemas consumidores.
- Persistencia del estado de la población (vecinos presentes, estado emocional, memoria, hogares asignados).
- Documentación completa del módulo (5 archivos de plan-inicial + plan-actual).

### Fuera del alcance (otros módulos)
- Máquina de estados, pathfinding, navegación y simulación parcial de agentes → **M64 (IA de NPC)**.
- Sistema de diálogo completo (cajas de texto, opciones, traducción) → **M21 (Diálogos)**.
- Puntos de amistad, niveles, desbloqueos y recompensas → **M20 (Amistad)**.
- Contenido de ruinas, puzzles y narrativa de las ruinas → **M25 (Ruinas)**.
- Rendimiento global, frame budget y perfilado → **M61 (Rendimiento)**.
- Generación de terreno vóxel y mundo → módulos de mundo (M08 y afines).

## 4. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Población gestionada | 8-12 vecinos simultáneos; catálogo de candidatos mayor al límite; plaza libre como requisito de mudanza |
| RF2 | Mudanza con permiso | El jugador aprueba o rechaza la entrada; cada partida se anuncia con aviso (día previo) |
| RF3 | Rutinas diarias | Agenda por perfil y por franja horaria (mañana/tarde/noche), con variación por vecino |
| RF4 | Interacción con tecla F | Detección del vecino más cercano en rango, indicador sobre la cabeza, despacho al hook de diálogo |
| RF5 | Reacciones a regalos | Evaluación contra gustos/disgustos; respuesta emocional, texto de reacción y delta de vínculo |
| RF6 | Estado emocional | Ánimo del vecino (alegre, neutral, triste...) con factores: regalos, charlas, clima, estación, eventos |
| RF7 | Memoria de interacciones | Historial persistente por vecino: regalos recibidos, charlas, hitos de amistad |
| RF8 | Hoja de datos por vecino | Todos los atributos del perfil cargables desde recursos .tres (Godot) |

## 5. Requisitos No Funcionales

- **Cozy:** vecinos amables, cero hostilidad, reacciones suaves y lógicas; la negativa a una mudanza jamás genera castigo.
- **Desacople:** `VillagerManager` no conoce UI; solo emite señales. La UI la consume la capa de presentación (M21 y componentes UI propios del módulo de interfaz).
- **Rendimiento (M61):** los NPCs solo simulan IA plena dentro de la burbuja del jugador (64 m); el resto usa receta ligera (ver M64). Este módulo entrega los datos; M64 ejecuta el presupuesto.
- **Determinismo suave:** decisiones de población y variaciones de rutina usan PRNG de partida (M29) para coherencia entre guardados.
- **Idioma:** todo texto de diseño y diálogo en español (listo para localización posterior por M21).
- **Stack:** Godot 4.x (>= 4.4.1), GDExtension Voxel Tools, GDScript puro (sin extensiones C# en este módulo).

## 6. Criterios de Aceptación

1. Los 26 puntos de la sección 18 del plan maestro resueltos en el checklist del módulo.
2. Perfil, manager, mood y hooks de diálogo diseñados con API estable en GDScript.
3. Flujo de mudanza (entrada con permiso y salida con aviso) especificado de punta a punta.
4. Contrato de datos definido para que M64 consuma perfiles y agendas sin acoplarse a este módulo.
5. Reglas de reacción a regalos y estado emocional claras y verificables.
6. Checklist de mínimo 110 ítems completado y documentación firmada.
---

## 7. SISTEMA DE RUTINAS Y VISITAS DE NPCs (Tsuki's Odyssey + Stardew Valley)

**Filosofía:** Los NPCs son personas con vida propia. Tienen horarios, gustos, personalidades y rutinas. El jugador puede conocerlos, hacerse amigo y recibir visitas. No hay obligación de socializar.

### 7.1 Perfiles de NPC (8-12 NPCs)

#### Personalidades

| Personalidad | Comportamiento | Gustos | Disgustos |
|--------------|---------------|--------|-----------|
| Trabajador | Siempre en su tienda/taller | Herramientas, minerales | Flores, comida dulce |
| Artístico | Pasea, dibuja, observa | Flores, cuadros, música | Herramientas, minerales |
| Aventurero | Explora, busca tesoros | Mapas, antiguas, ruedas | Comida, muebles |
| Cocinero | Cocina, prueba recetas | Ingredientes, recetas | Herramientas, minerales |
| Pescador | Pesca, pasea por la costa | Pescados, cebo, conchas | Plantas, minerales |
| Jardinero | Cuida plantas, pasea | Flores, semillas, tierra | Minerales, madera |
| Sabio | Lee, investiga, medita | Libros, glifos, cristales | Comida, ropa |
| Mercader | Vende, compra, negocia | Monedas, items raros | Comida común |

#### Ejemplo de 8 NPCs

| NPC | Especie | Personalidad | Profesión | Horario |
|-----|---------|-------------|-----------|---------|
| Luna | Gato | Artístico | Pintora | 08-20 (pasea, dibuja) |
| Rocky | Oso | Trabajador | Herrero | 07-18 (taller) |
| Coral | Sirena | Aventurero | Exploradora | 06-22 (playa, ruinas) |
| Chef | Cerdo | Cocinero | Cocinero | 06-20 (cocina) |
| Fin | Pez | Pescador | Pescador | 05-19 (río, costa) |
| Flora | Conejo | Jardinero | Jardinera | 07-19 (jardín, pueblo) |
| Sage | Búho | Sabio | Bibliotecario | 09-21 (biblioteca) |
| Merc | Zorro | Mercader | Mercader | 08-18 (tienda) |

### 7.2 Rutinas Diarias por NPC

#### Formato de Rutina

Cada NPC tiene una tabla de rutina con:
- **Franja horaria** (mañana 06-12, tarde 12-18, noche 18-24)
- **Actividad** (trabajo, paseo, descanso, social)
- **Ubicación** (tienda, casa, playa, bosque, pueblo)
- **Acción del jugador** (hablar, regalar, observar)

#### Ejemplo: Rutina de Luna (Pintora)

| Hora | Actividad | Ubicación | Acción del jugador |
|------|-----------|-----------|-------------------|
| 06:00 | Despertar | Casa | Mirar por la ventana |
| 07:00 | Desayunar | Casa | Hablar (diálogo matutino) |
| 08:00 | Paseo matutino | Pueblo | Regalar (si amistad ≥ 2) |
| 09:00 | Dibujar | Playa/Bosque | Hablar (diálogo de arte) |
| 12:00 | Almuerzo | Restaurante | Sentarse juntos (+amistad) |
| 13:00 | Pintar | Pueblo/Casa | Observar (reacciona) |
| 17:00 | Visitar tiendas | Pueblo | Hablar (diálogo de tarde) |
| 19:00 | Regresar a casa | Casa | Despedirse |
| 20:00 | Descansar | Casa | No disponible |
| 22:00 | Dormir | Casa | No disponible |

### 7.3 Visitas de NPCs al Jugador

#### Reglas de Visita

| Nivel de amistad | Frecuencia | Duración | Qué hace |
|-----------------|------------|----------|----------|
| 0 (desconocido) | 0×/semana | — | No visita |
| 1 (conocido) | 1×/semana | 30 min | Llama a la puerta, habla, se va |
| 2 (amigo) | 2×/semana | 1 hora | Entra, mira decoración, regala item |
| 3 (buen amigo) | 3×/semana | 2 horas | Entra, se sienta, pide favor, regala |
| 4 (mejor amigo) | Todos los días | 3 horas | Entra, cocina juntos, regala raro |

#### Qué Hacen los NPCs en la Visita

| Acción | Resultado | Requisito |
|--------|-----------|-----------|
| Llaman a la puerta | El jugador puede abrir o ignorar | Amistad ≥ 1 |
| Entran a la casa | Miran la decoración, reaccionan | Amistad ≥ 2 |
| Se sientan | Recuperan energía (cozy) | Amistad ≥ 2 |
| Regalan un item | 1×/semana si amistad ≥ 2 | Amistad ≥ 2 |
| Piden un favor | Misión secundaria opcional (M23) | Amistad ≥ 3 |
| Cocinan juntos | Crean comida especial | Amistad ≥ 4 |
| Se despiden | Se van después de un tiempo | Siempre |

### 7.4 Sistema de Regalos Detallado

#### Reglas de Regalo

| Regla | Detalle |
|-------|---------|
| Frecuencia | 1 regalo por NPC por semana |
| Costo | El jugador gasta monedas o items |
| Gustos | Cada NPC tiene gustos específicos (perfil) |
| Reacción | ¡Le encanta! (+3), Le gusta (+2), Neutral (+0), No le gusta (-1), ¡Le odia! (-2) |
| Memoria | El NPC recuerda los últimos 10 regalos |
| Repetición | Si repite un regalo, la reacción es -1 punto |
| Cumpleaños | El regalo vale doble (positivo o negativo) |

#### Categorías de Regalos por NPC

| NPC | Le encanta | Le gusta | Neutral | No le gusta | Le odia |
|-----|-----------|----------|---------|-------------|---------|
| Luna (pintora) | Cuadros, flores | Libros, música | Comida | Herramientas | Minerales |
| Rocky (herrero) | Minerales, herramientas | Madera, piedra | Comida | Flores | Libros |
| Coral (exploradora) | Mapas, antiguas | Conchas, piedras | Comida | Ropa | Muebles |
| Chef (cocinero) | Ingredientes raros | Recetas, especias | Flores | Herramientas | Minerales |
| Fin (pescador) | Pescados raros | Cebo, conchas | Comida | Libros | Flores |
| Flora (jardinera) | Flores raras, semillas | Plantas, tierra | Comida | Minerales | Herramientas |
| Sage (bibliotecario) | Libros, glifos | Cristales, mapas | Comida | Herramientas | Ropa |
| Merc (mercader) | Monedas, items raros | Comida cara | Flores | Herramientas | Libros |

### 7.5 Regalos de NPC al Jugador

Los NPCs también regalan cosas al jugador:

| Condición | Regalo | Frecuencia |
|-----------|--------|------------|
| Primera visita | Item temático de la profesión | 1× |
| Amistad nivel 2 | Receta nueva (M16) | 1× |
| Amistad nivel 3 | Mueble exclusivo | 1× |
| Amistad nivel 4 | Item legendario / herramienta mejorada | 1× |
| Cumpleaños del jugador (M29) | Regalo especial doble | 1×/año |
| Visita aleatoria | Comida, flores, monedas | 1×/semana |

### 7.6 Memoría de NPCs

- Cada NPC recuerda los últimos 10 regalos recibidos
- Si el jugador repite un regalo, el NPC reacciona menos entusiasta (-1 punto)
- Si el jugador da algo que disgusta, el NPC lo recuerda 30 días
- Si el jugador da algo que le encanta, el NPC lo recuerda 60 días
- La memoría se persiste en M58
- Los NPCs comparten experiencias entre ellos (si dos NPCs son amigos, hablan del jugador)

### 7.7 Interacciones Sociales

| Interacción | Resultado | Costo |
|-------------|-----------|-------|
| Hablar | +1 amistad (si no hablado hoy) | Gratis |
| Regalar | +2/+3 amistad (según gusto) | Item + monedas |
| Sentarse juntos | +1 amistad (si amistad ≥ 2) | 30 min tiempo |
| Cocinar juntos | +2 amistad + comida especial | Ingredientes |
| Pasear juntos | +1 amistad + descubrimiento | 1 hora tiempo |
| Ayudar con trabajo | +2 amistad + monedas | 1 hora tiempo |

### 7.8 Anti-Frustración Social

| Principio | Implementación |
|-----------|---------------|
| Sin penalización por no socializar | Los NPCs no se enojan si no los visitas |
| Sin presión de tiempo | Las visitas no tienen fecha de expiración |
| Sin bloqueo de contenido | Todo accesible sin amistad alta |
| Sin obligación de regalar | Los regalos son opcionales |
| Sin penalización por regalo malo | La amistad baja solo 1-2 puntos |
| Sin exigencia de frecuencia | Puedes socializar cuando quieras |
