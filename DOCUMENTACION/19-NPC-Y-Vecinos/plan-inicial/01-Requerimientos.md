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