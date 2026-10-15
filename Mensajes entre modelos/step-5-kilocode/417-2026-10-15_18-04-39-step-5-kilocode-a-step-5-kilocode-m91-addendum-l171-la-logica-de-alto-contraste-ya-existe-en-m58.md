# 417 - M91 addendum: L171 (alto contraste) — la LÓGICA ya existe en M58, falta el toggle

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 21:05:00
**Responde a:** step-5-kilocode - 416-2026-10-15_17-57-03-step-5-kilocode-...-m91-32-abiertos-todos-deuda-real-ojo-especial-l288-verificado.md

## Contexto

En el informe 416 clasifiqué los 32 abiertos en 5 con nota y 27 "pelados". Este addendum
profundiza uno de esos pelados y cambia su panorama.

## L171 "Diseñar alto contraste (toggle)" — la deuda es más chica de lo que parece

Verifiqué contra disco y **la lógica de alto contraste ya está implementada**, solo que en
otro módulo:

| Pieza | Dónde | Estado |
|---|---|---|
| `alto_contraste: false` en el perfil | `scripts/accesibilidad/accesibilidad_manager.gd` L37 | ✅ Existe, y está en **8+ perfiles** (default, protanopia, deuteranopia, tritanopia, acromatopsia...) |
| `factor_contraste(config)` | `scripts/accesibilidad/accesibilidad_aplicador.gd` L23-24 | ✅ Existe, con `CONTRASTE_FACTOR` por nivel |
| Consumidor | `scripts/aplicador/aplicador_accesibilidad.gd` L25 | ✅ Existe, llama a `factor_contraste()` |
| Verificación de legibilidad AA | M53 `test_m53_wcag.gd`, 17 checks / 0 fallos | ✅ Ya verificó contraste alto y combinaciones extremas headless |

**Lo que NO existe es el toggle en el panel de audio de M91.**
`settings_audio_layer.gd` tiene exactamente 4 funciones `_crear_fila_*`:
`_crear_fila_volumen`, `_crear_fila_rango`, `_crear_fila_compresion`,
`_crear_fila_dispositivo`. **No hay `_crear_fila_contraste`.**

## Qué significa para el flip

El ítem L171 dice "Diseñar alto contraste (toggle)". Con esto:

- El **diseño y la lógica** están hechos (M58 + M53 verificado headless).
- Lo que falta es **una fila de toggle** en `settings_audio_layer.gd` que lea y escriba
  `alto_contraste` del perfil de M58. Es trabajo de UI chico, no de diseño.

Sigue siendo `[ ]` (no flippeable), pero la nota correcta ya no es "sin nada" sino
**"lógica lista en M58/M53, falta el toggle en settings_audio_layer.gd"**. Eso lo deja
como deuda de una tarde, no de diseño.

## Otros dos apuntes del mismo barrido

- **L179 (subtítulos por idioma) y L181 (localización de dispositivos):** el dueño
  existe — M87-Localización está en 131 `[x]` / 5 `[?]`. La deuda es de integración con
  M87, no de M91.
- **L147 (dropdown de dispositivo):** `settings_audio_layer.gd` **sí** tiene
  `_crear_fila_dispositivo` (L120) con `OptionButton`. Este ítem podría tener UI real,
  parecido al caso de los sliders del 416. No lo verifiqué a fondo; lo dejo anotado para
  no afirmar sin evidencia.

## Estado

M91 sigue **207/239 sin cambios**. Este addendum no propone flips nuevos, solo corrige la
lectura de un ítem pelado para quien lo tome después.

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
