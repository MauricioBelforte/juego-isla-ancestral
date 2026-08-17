**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 21: Diálogos

## 1. Dominio del problema

Los diálogos de un cozy game con deidades, misiones, amistad y estaciones (Aurora) son contenido que cambia con el tiempo: el mismo NPC habla distinto en verano, de noche, tras una misión o según la amistad. El sistema debe separar **contenido** (grafo de texto) de **máquina** (runtime) y de **presentación** (UI), y debe poder validarse sin ejecutar el juego.

## 2. Alternativas consideradas

### Alternativa A: Diálogos en código (GDScript embebido)

Escribir las conversaciones como funciones y estructuras en GDScript.

- **Pros:** sin pipeline de datos; acceso directo a variables; prototipado veloz.
- **Contras:** el texto queda acoplado al gameplay; no es localizable sin reescribir; cada cambio de guion exige recompilar; el contenido (dominio del diseñador) mezclado con la máquina (dominio del programador); imposible validar un grafo sin jugar.
- **Veredicto:** descartada. No satisface RF10 (traducción), RF11 (base de diálogos) ni el desacoplamiento de la sección 9 de AGENTS.md.

### Alternativa B: Motor propio data-driven con JSON validado (ELEGIDA)

Grafos de nodos en archivos JSON (contenido) + manejador en GDScript (máquina) + escena UI (presentación).

- **Pros:** contenido 100% data-driven; localización vía claves y diccionarios; validación estática del grafo (huérfanos, `goto` rotos, IDs duplicados) antes de runtime; recarga en caliente en el editor; texto dinámico con placeholders; sin dependencias de terceros; escala a cientos de conversaciones.
- **Contras:** requiere definir un esquema de datos y un validador; el JSON manual exige disciplina.
- **Veredicto:** elegida. Es la opción que mejor equilibra calidad, mantenibilidad y control dentro del stack Godot 4.x + GDScript.

### Alternativa C: Motor externo (Dialogic 2 / Dialogue Manager / Ink)

Plugins de la comunidad con editor visual, timelines y branching.

- **Pros:** editor visual cómodo; comunidad activa; soporte para branching avanzado.
- **Contras:** API y asignatura pendiente de mantenimiento del plugin en Godot 4.4+; el editor visual no se integra con el flujo data-driven JSON propio del proyecto; dependencia de terceros para un sistema nuclear (riesgo de obsolescencia); el proyecto ya prioriza sistemas propios desacoplados (ver módulos existentes); difícil validación personalizada contra el estado del mundo de Aurora; sobrecarga de features y assets que el juego no usa.
- **Veredicto:** descartada para el núcleo. Se deja anotado como posible herramienta de prototipado rápido y descarte generativo de guiones fuera del juego (sin integrarse al pipeline).

## 3. Decisiones técnicas justificadas

| Decisión | Opción elegida | Justificación |
|---|---|---|
| Formato de datos | JSON (`*.json` a `res://_Project/Data/Dialogues/`) | Editable, versionable, parseable sin Godot; UTF-8 para localización |
| Estructura | Grafo de nodos con `next`/`goto`/`options` | Expresivo para ramas, salidas conversacionales y eventos; validation-friendly |
| Validación | Pase estático previo al uso + validación con mensajes línea/columna | Detectar grafo inválido, nodo huérfano y `goto` roto antes de jugar |
| Localización | Claves `text_key` + diccionarios por idioma | Texto nunca incrustado en imágenes (punto del plan maestro); M87 provee fuentes |
| Condiciones | Expresiones declarativas sobre `WorldState` | Estación, hora, clima, progreso, amistad, misiones — todo vía API único |
| Texto dinámico | Placeholders `{clave}` resueltos en runtime | Un nodo sirve para muchos contextos sin duplicar guion |
| UI | Escena única reutilizable `dialogue_ui.tscn` | Sin acoplar UI a gameplay (sección 9 de AGENTS.md); un solo punto de styling |
| Idiomas de runtime | GDScript nativo (estático + tipado débil donde basta) | Coherente con el resto del proyecto |

## 4. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| JSON manual con errores de tipeo | Validador con errores descriptivos (archivo, nodo, causa) |
| `goto` a nodos inexistentes | Validación estática obligatoria; test en CI manual (plan de testings) |
| Textos que se salen de la caja | Límites de ancho probados; saltos de página automáticos para líneas largas |
| Diálogos bloqueantes | Siempre hay salida (salto rápido + opción "Despedirse" en NPCs) |
| Crecimiento desordenado de la base | ID único global por diálogo; catálogo central; revisión de consistencia de nombres |
| Desincronía con el estado del mundo | Condiciones leídas exclusivamente del `WorldStateService` (capa única) |

## 5. Conclusión

Se implementa un motor propio, data-driven y con grafo validado: contenido en JSON (contenido), `DialogueManager` como autoload (máquina) y `DialogueUI` como escena (presentación). Esta arquitectura satisface los requisitos RF1-RF12, respeta el desacoplamiento de AGENTS.md y deja la puerta abierta a un editor visual futuro sin tocar el motor.