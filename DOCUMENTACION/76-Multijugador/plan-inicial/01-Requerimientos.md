**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 76: Multijugador

## ID del Módulo
- **Código:** M76 (CHECKLIST-GLOBAL: ID 76 — Multijugador; plan maestro: sección 75 "MULTIJUGADOR")
- **Carpeta:** `DOCUMENTACION/76-Multijugador/`
- **Dependencias:** — (decisión de producto primero). Relaciones: M77 (Online y Red — arquitectura), M59 (Persistencia), M07 (Eventos — sincronización), M22/M23 (Historias), M13 (Animación), M21 (Diálogos), M44 (Notificaciones), M92 (Tutorial), M61 (Rendimiento), M62 (Memoria), M38 (Economía), M73 (Coleccionables), M74 (Eventos)
- **Nota:** en la tabla global figura "Decisión pendiente". Este documento RESUELVE la decisión inicial (RF1) y define el alcance contractual.

## 1. Problema

El plan maestro exige responder 25 preguntas antes de desarrollar multijugador: ¿local? ¿online? ¿cuántos jugadores? ¿anfitrión o servidor? ¿sincronización, autoridad, persistencia, permisos, invitaciones, cuentas, identidad, chat, emotes, intercambio, construcción cooperativa, puzzles cooperativos, progreso compartido o individual, seguridad, anti-griefing, moderación, costes de servidores? El problema real: **el multijugador es la decisión de producto más cara del proyecto** (red, servidores, moderación, anti-cheat, costes recurrentes). Un cozy de isla (estilo Animal Crossing/Stardew) puede vivir perfectamente en single-player; el postgame (M75) ya cubre la "vida" de la isla sin costes de red.

## 2. Objetivo

Tomar y documentar la decisión de producto con argumentos verificables, Y dejar un **contrato de diseño de multijugador futuro** por si se suma como contenido: modo local cooperativo (couch) primero, online como extensión. La decisión de fondo: **el juego es single-player cozy; el multijugador queda como módulo futuro de complejidad 5, documentado y bloqueable, sin riesgo para el núcleo.**

## 3. Alcance

### 3.1 Dentro del alcance
- Decisión inicial documentada: single-player en lanzamiento (RF1).
- Contrato de diseño futuro: modo local (2 jugadores, mismo dispositivo, pantalla dividida o compartición de control) como primera forma; online diferido.
- Definición de los 25 puntos del plan maestro en modo "contrato": cantidad, anfitrión, servidor, sincronización, autoridad, persistencia, permisos, invitaciones, cuentas, identidad, chat, emotes, intercambio, construcción cooperativa, puzzles cooperativos, progreso compartido/individual, seguridad, anti-griefing, moderación, costes.
- Análisis de riesgo y coste con números (sin servidores en v1).
- Validación: `validate_mp_contract.gd`.

### 3.2 Fuera del alcance
- La implementación del multijugador (código de red): bloqueada hasta que el producto decida FASE MP.
- M77 (Online y Red): la arquitectura de red se detalla en el módulo 77 (sección 76 del plan maestro); M76 define el contrato de producto.
- Cuentas/identidad reales (servicio externo): solo contrato.

## 4. Restricciones

- **Decisión honesta:** el módulo NO documenta "multijugador hecho" — documenta la decisión y el contrato, con `[?]` donde no hay producto final.
- **No acoplar el núcleo:** ninguna dependencia del single-player hacia M76 (regla M15).
- **Costes:** sin servidores dedicados en v1 (modelo P2P/split-screen si se implementa).
- **Cozy:** si algún día hay online, el "visitante" NO puede romper la isla (anti-griefing por diseño).
- **Rendimiento (M61/M62):** el contrato exige que el modo local no duplique escenas con costo de memoria.
- **Validable:** `validate_mp_contract.gd` sin errores.

## 5. Requisitos Funcionales (Contrato)

| # | Requisito | Decisión de diseño (v1 = sin MP) | Futuro |
|---|---|---|---|
| RF1 | ¿Habrá multijugador? | NO en v1. Single-player cozy (decisión de producto) | Sí, como FASE MP post-lanzamiento |
| RF2 | ¿Local? | Análisis completo (couch 2P split) | Primera forma de MP |
| RF3 | ¿Online? | Diferido (requiere M77 + costes) | Extensión |
| RF4 | Cantidad de jugadores | — (v1: 1) | 2 local / 4 online |
| RF5 | Anfitrión | — | El jugador que crea la isla (local) |
| RF6 | Servidor | — | P2P para 2P local; dedicado solo si online |
| RF7 | Sincronización | — | Estado de mundo por host (local); snapshot + determinismo (online) |
| RF8 | Autoridad | — | Host autoritativo; isla pertenece al anfitrión |
| RF9 | Persistencia | Save local (M59) | El invitado NO persiste en la isla del host (solo progreso global) |
| RF10 | Permisos | — | Invitado: editar zona permitida, no la casa del host |
| RF11 | Invitaciones | — | Local: segundo mando; online: código de visita |
| RF12 | Cuentas | Sin cuentas en v1 | Perfiles locales; online requiere cuenta opcional |
| RF13 | Identidad | — | Avatar de perfil (M92), nombre de isla |
| RF14 | Chat | Sin chat | Emotes + frases rápidas (moderadas por diseño, T-chat) |
| RF15 | Emotes | — | Rueda de emotes (M44 notificaciones de emote) |
| RF16 | Intercambio | Sin intercambio (economía M38 local) | Trueque visitante prohíbe regalar ítems de historia (M22) |
| RF17 | Construcción cooperativa | — | Solo en zona permitida (permisos RF10) |
| RF18 | Puzzles cooperativos | — | Solo puzzles M24 opcionales (jamás bloquean historia) |
| RF19 | Progreso compartido | — | Nunca: cada jugador su isla (cozy) |
| RF20 | Progreso individual | — | El visitante lleva su avatar con su progreso global |
| RF21 | Seguridad | Sin red | Offline-first (M59); el código de visita expira |
| RF22 | Anti-griefing | Sin riesgo | Por diseño: invitado sin permisos destructivos |
| RF23 | Moderación | Sin chat libre | Frases rápidas; reporte si hay texto libre |
| RF24 | Costes de servidores | $0 en v1 | Presupuesto estimado incluido en 02-Analisis |
| RF25 | Modo local (couch) compatible | El juego ya es fluido 60 FPS (M61) | Split-screen 2P respeta frame budget |

## 6. Criterios de Aceptación

1. La decisión v1 (single-player) está documentada con argumentos técnicos y de coste.
2. Los 25 puntos del plan maestro están definidos como contrato (aunque la implementación sea futura).
3. El núcleo single-player NO tiene ninguna dependencia de M76 (regla M15 verificada con check).
4. El contrato exige anti-griefing y progreso individual para cualquier MP futuro.
5. El análisis de costes de servidores está documentado con estimaciones.
6. `validate_mp_contract.gd` existe y pasa sin errores.