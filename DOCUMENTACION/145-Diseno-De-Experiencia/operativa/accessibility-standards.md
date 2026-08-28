**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 145-Diseno-De-Experiencia
**Estado:** Implementación operativa (entregable M145)

---

# Estándares de Accesibilidad (`accessibility-standards`) — Módulo 145

> Requisitos mínimos de accesibilidad que **todo** sistema del juego debe cumplir. Implementación y catálogo completo: **M58 (Accesibilidad, dueño)**; controles remapeables: M57; UI base: M53. Este documento es el estándar de aceptación transversal.

## 1. Requisitos mínimos (obligatorios v1.0)

| # | Requisito | Detalle | Dueño |
|---|---|---|---|
| R1 | Subtítulos para todo el diálogo | Tamaño ajustable, nombre del hablante, fondo semitransparente | M58/M21 |
| R2 | Opciones de color-blindness | Paletas alternativas (protanopia/deuteranopia/tritanopia) + símbolos forma+color | M58/M46 |
| R3 | Tamaño de texto ajustable | 6 tamaños (ThemeUx M53), aplica a UI y subtítulos | M53/M58 |
| R4 | Controles remapeables | Teclado y gamepad, con detección de conflictos | M57 |
| R5 | Opciones de dificultad sin penalizaciones | Sin hambre punitiva, sin muerte permanente; el juego nunca castiga elegir menos desafío | M152/M58 |
| R6 | Soporte completo gamepad + teclado | Paridad total de acciones; prompts dinámicos por dispositivo | M57 |
| R7 | Modo de alto contraste | UI con contornos y fondos sólidos | M58/M53 |
| R8 | Reducción de movimiento | Desactiva shake, parallax fuerte, transiciones largas y vibración | M58/M90 |

## 2. Checklist de aceptación (inspirado WCAG 2.1 AA, adaptado a videojuego)

- [ ] Todo texto cumple contraste mínimo 4.5:1 (texto normal) / 3:1 (grande) en la paleta activa.
- [ ] La información nunca se transmite **solo** por color (siempre con forma/icono/texto).
- [ ] Todo sonido relevante tiene representación visual (subtítulo, icono o indicador).
- [ ] Todo evento visual importante tiene audio o alternativa háptica/textual.
- [ ] Legibilidad verificada: fuente con x-height clara, sin itálicas largas, medición ≤ 70 caracteres/línea.
- [ ] Flashes/ráfagas ≤ 3 por segundo (fotosensibilidad).
- [ ] Los timers (si existen) son generosos o desactivables (cozy, sin presión).
- [ ] Navegación de menús 100 % operable por teclado y gamepad (equivalencia con puntero).
- [ ] El foco de UI es siempre visible y lógico (orden de lectura).
- [ ] Los prompts de acción se muestran en el dispositivo activo (teclado/gamepad).

## 3. Verificaciones por implementación (cuando exista el sistema)

| Verificación | Cuándo | Método |
|---|---|---|
| Contraste real de la paleta | Con ThemeUx aplicado global (M53) | Medición con herramienta de contraste sobre capturas |
| Sonido ↔ visual | Con audio integrado (M41-M44) | Sesión sin audio: ¿se entiende todo? |
| Visual ↔ sonido | Con VFX integrados (M52) | Sesión sin imagen (solo audio): eventos clave audibles |
| Legibilidad en pantallas pequeñas | Con UI integrada | Capturas a 1280×720 y Steam Deck 1280×800 |
| Herramientas de accesibilidad | Pre-RC (M142) | Playtests con perfil de accesibilidad activado (M114/M58) |

> Estas verificaciones requieren el juego implementado; quedan programadas en los hitos del roadmap (M141/M142).

## 4. Regla transversal

Ningún módulo nuevo (UI, gameplay, audio) se marca `[x]` si rompe un requisito R1-R8. El QA cruzado verifica este estándar en todo módulo que cambie píxeles o sonidos.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
