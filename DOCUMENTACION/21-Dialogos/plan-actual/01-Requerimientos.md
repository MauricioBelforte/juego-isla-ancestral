**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 21: Diálogos

## ID del Módulo
- **Código:** M21 (tabla global: ID 21 — Diálogos; plan maestro: sección 20 — DIÁLOGOS)
- **Carpeta:** `DOCUMENTACION/21-Dialogos/`
- **Prioridad:** Alta · **Complejidad:** 4 · **Dependencias:** M19 (sistema de amistad)
- **Relaciones:** M22 (historias secundarias), M23 (templos y puzzles), M87 (fuentes tipográficas), M29/M31 (tiempo/clima/estaciones), M64 (IA de NPC), M73 (eventos y festivales), M17 (obras del jugador)

## 1. Problema

Los NPC de Aurora necesitan conversar con el jugador de forma viva, ramificada y contextual, pero el texto incrustado en código no escala: no se puede localizar, no se puede ramificar sobre el estado del mundo, no se puede mantener ni auditar, y cualquier cambio narrativo obliga a recompilar. Se requiere un motor de diálogos data-driven, separado de la lógica de gameplay y de la capa de UI, que permita escribir conversaciones nodo a nodo con opciones ramificadas, tipografía progresiva, salto rápido y condiciones alimentadas por las variables de estado del mundo.

## 2. Objetivos

1. Motor de diálogo **nodo a nodo** con transiciones lineales y saltos directos.
2. **Opciones ramificadas** con condiciones de visibilidad y bloqueo.
3. **Tipografía progresiva** con velocidad configurable y salto rápido.
4. **Variables de estado del mundo** (estación, hora, clima, progreso, amistad, misiones) capaces de alterar ramas y textos dinámicos.
5. Datos en **JSON validado** con detección de grafos inválidos antes de runtime.
6. Textos **preparados para localización** desde el primer día, sin texto incrustado en imágenes.
7. Integración limpia con M19, M22, M23, M87 y el resto de los sistemas del mundo.

## 3. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Motor nodo a nodo | Grafo de nodos (texto/opciones/eventos) con `next`, `goto` y cierre |
| RF2 | Opciones ramificadas | Selección del jugador entre 2-4 opciones con `conditions` y `effects` |
| RF3 | Tipografía progresiva | Letra a letra con velocidad configurable y aceleración al mantener entrada |
| RF4 | Salto rápido | Confirmar durante el tipeo completa la línea; doble confirmación salta el diálogo |
| RF5 | Variables de estado del mundo | Condiciones sobre estación, hora, clima, progreso, amistad, misiones, eventos y variables de partida |
| RF6 | Textos dinámicos | Placeholders `{nombre}`, `{estación}`, `{amistad}` resueltos en runtime |
| RF7 | Diálogos contextuales | Variantes por estación, hora, clima y progreso de la historia |
| RF8 | Diálogos automáticos | Avance automático opcional con temporizador y pausa en opciones |
| RF9 | Eventos de conversación | Señales de inicio, fin, cambio de nodo y selección de opción |
| RF10 | Sistema de traducción | Claves `text_key` + diccionarios de idioma; preparar textos para localización |
| RF11 | Base de diálogos | Catálogo central por NPC con IDs únicos y consistencia de nombres |
| RF12 | Triggers | Iniciar diálogo por interacción (M19/M64), proximidad, evento o script |

## 4. Requisitos No Funcionales

- **Cozy:** conversaciones cálidas, cero interrupciones agresivas; el diálogo nunca bloquea la partida para siempre (siempre existe salida).
- **Pausa (M29):** al congelar el reloj, la conversación se pausa sin perder estado.
- **Rendimiento:** carga diferida de grafos, pool de nodos, cero allocs notables por frame durante el tipeo (M61/M113).
- **Desacoplamiento:** la UI no contiene lógica de grafo; los scripts de gameplay no conocen el Canvas (sección 9 de AGENTS.md).
- **Localizable:** UTF-8, sin texto en imágenes, claves únicas para M87 (fuentes tipográficas).
- **Robustez:** un grafo inválido nunca crashea el juego; fallback amigable con log.

## 5. Alcance

**Dentro:**
- Motor nodo a nodo, opciones, condiciones y efectos.
- Tipografía progresiva, salto rápido y avance automático.
- Validación de grafos JSON (editor y runtime).
- Variables de estado del mundo y textos dinámicos.
- Trigger por interacción y por evento.
- Escena UI de diálogo reutilizable.

**Fuera:**
- El contenido narrativo en sí (pertenece a M22/M23/historia principal).
- Editor visual de grafos (queda como mejora futura, ver `5-FUTURAS-MEJORAS.md` si el usuario lo pide).
- IA de NPC (M64) y sistema de amistad (M19): solo se integran vía API.
- Voces y lipsync (requeriría audio; fuera de alcance inicial).

## 6. Restricciones

- Stack: Godot 4.x (>= 4.4.1) + Voxel Tools + GDScript.
- Los datos viven en `res://_Project/Data/Dialogues/*.json`; sin diálogos en código.
- Identificadores únicos globales por diálogo y por nodo.
- Sin texto incrustado en imágenes; sin emojis en datos de producción.
- Validación obligatoria antes de usar un grafo en partida.

## 7. Criterios de Aceptación

1. Los 26 puntos de la sección 20 del plan maestro resueltos.
2. Un diálogo de ejemplo con ramas, condiciones y efectos corre en play mode sin errores.
3. Un JSON malformado y un grafo con `goto` huérfano se detectan con mensajes claros.
4. La tipografía progresiva admite salto rápido y velocidad configurable.
5. Los textos dinámicos se resuelven con el estado del mundo en runtime.
6. La localización funciona con al menos dos idiomas de ejemplo.
7. Módulo delegable para implementación, con plan de testings (sección 14 de AGENTS.md).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M019** — NPC y Vecinos | Motor de diálogos |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M022** — Historia Principal | Historia principal |
| **M087** — Localización | Localización |
| **M162** — Diálogos Contextuales de NPCs | Diálogos contextuales |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M019** — NPC y Vecinos | Depende de este módulo |
| **M022** — Historia Principal | Este módulo lo necesita |
| **M087** — Localización | Este módulo lo necesita |
| **M162** — Diálogos Contextuales de NPCs | Este módulo lo necesita |

