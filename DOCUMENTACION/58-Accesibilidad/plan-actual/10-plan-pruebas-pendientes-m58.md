# Plan de Pruebas Pendientes (bloque accesibilidad M58) — reducibles a runbook

**Modelo:** G-5.3-Flash-Agente
**Plataforma:** Kilo Code
**Fecha:** 2026-10-20
**Cubre los ítems "Planear prueba de…" de la cola de accesibilidad (aim assist M34, single_hand vs remapeo M57, overhead con profiler, atajo global F10, sesión larga).** Cada plan es un runbook ejecutable por el dueño correspondiente (nota al pie de cada uno).

## 1. Aim assist de pesca (M34) — slider en 0 %, 50 % y 100 %

- **Objetivo**: el assist reduce el tiempo de captura de forma perceptible y monótona con el slider (0 < 50 < 100), sin volverse automático en 100 %.
- **Precondiciones**: caña equipada; pool de pesca activo; slider de aim assist en el menú de accesibilidad.
- **Pasos**: (1) por cada valor del slider, realizar 10 lanzamientos en la misma zona con el mismo señuelo; (2) registrar tiempo medio de captura y tasa de éxito; (3) repetir con pesca con mando y con teclado.
- **Criterios de éxito**: tiempo(0 %) > tiempo(50 %) > tiempo(100 %) con diferencias ≥ 10 % entre pasos; en 100 % la captura aún requiere el minijuego (no auto-captura); sin errores en consola.
- **Responsable**: dueño M34 (nesesita runtime con agua — no headless).

## 2. Preset single_hand vs remapeo de M57

- **Objetivo**: aplicar `single_hand` no entra en conflicto con las claves remapeadas por el usuario (el remap del usuario gana donde exista, y las acciones mantenidas usan `tiempo_mantener_multiplicador`).
- **Precondiciones**: remapear "interactuar" a una tecla no estándar; luego aplicar preset `single_hand`.
- **Pasos**: (1) verificar `get_remap_control().has("interactuar")` tras aplicar el preset (el remap del usuario prevalece); (2) ejecutar una acción mantenida (regar) y medir que usa el multiplicador del preset; (3) restaurar `estandar` y repetir.
- **Criterios de éxito**: sin pérdida de binds del usuario; `mantener_automatico()` coherente con el preset activo; `control_changed` emitido una vez por aplicación.
- **Responsable**: dueño M57 (input runtime).

## 3. Overhead del perfil de accesibilidad en escena poblada (profiler)

- **Objetivo**: el perfil aplicado añade < ~1 ms/frame de CPU median (uno de los NFR de la cola).
- **Precondiciones**: escena poblada (M15 recursos + fauna); Godot profiler (ventana Debugger → Profiler) o `--profiling`; contador de draw calls (M61).
- **Pasos**: (1) medir 60 s de juego SIN perfil activo (baseline de frame time y draw calls); (2) aplicar el perfil más pesado (alto contraste + texto grande + toasts) y medir otros 60 s; (3) comparar medianas (no picos).
- **Criterios de éxito**: delta de frame time < 1 ms median; draw calls dentro del rango reportado por M61; sin crecimiento de memoria sostenido (leak check del monitor).
- **Responsable**: dueño M61/M58 (runtime + profiler — no headless).

## 4. Atajo global F10 (accesibilidad) desde título, pausa y gameplay

- **Objetivo**: abrir/cerrar el panel de accesibilidad con F10 funciona en los 3 contextos y NO roba el foco ni rompe la pila de la M53.
- **Precondiciones**: atajo F10 registrado (InputMap global); UIRoot montado.
- **Pasos**: (1) en título: F10 → panel abre sobre MenusLayer; F10 de nuevo → cierra y el foco vuelve al primer botón del menú (`focus_first`); (2) en pausa (Juego → Esc): mismo ciclo sin perder el sub-foco de pausa; (3) en gameplay: F10 → panel abre con pausa correcta; Esc/cerrar → gameplay continúa sin que ni el jugador ni las señales se pierdan (posición/integridad).
- **Criterios de éxito**: apertura/cierre correcto en los 3 contextos; foco restaurado al volver; sin conosole ni estados zombis.
- **Responsable**: dueño M53 (atajo global) — verificación parcial headless posible con la pila de la M53 (fuera de este runbook).

## 5. Sesión larga ≥ 30 min (autosaves cada 5 minutos)

- **Objetivo**: 6+ autosaves sucesivos sin degradación (payload creciente, memoria estable, sin hitching > 50 ms por auto-save).
- **Precondiciones**: sesión real de juego (mundo, inventario, quests activas); recordatorio de tiempo (contador) o cronometraje.
- **Pasos**: (1) jugar ≥ 30 min con acciones variadas (craftear, recolectar, misiones); (2) verificar que cada auto-save de 5 min completó (señal `save_completed` con reason auto y archivos de slot incrementando); (3) medir el pico de frame time en cada auto-save; (4) al final, cargar el último slot y validar integridad del snapshot (50 secciones, validador exit) y continuidad de estado (posición/inventario/quests).
- **Criterios de éxito**: 6 autosaves sin `save_failed`; pico < 50 ms por auto-save; carga final íntegra; sin leak sostenido (monitor de memoria).
- **Responsable**: dueño M59 (runtime ≥ 30 min — no headless; una versión corta del smoke ya corre en `qa_m59_save_vacio.gd`).

## Matriz de responsabilidad

| # | Runbook | Responsable | ¿Headless? |
|---|---|---|---|
| 1 | Aim assist pesca | M34 | No (runtime agua) |
| 2 | single_hand vs remapeo | M57 | Parcial (input real) |
| 3 | Overhead profiler | M61/M58 | No (profiler) |
| 4 | Atajo global F10 | M53 | Parcial (pila M53) |
| 5 | Sesión larga autosaves | M59 | No (runtime 30 min) |
