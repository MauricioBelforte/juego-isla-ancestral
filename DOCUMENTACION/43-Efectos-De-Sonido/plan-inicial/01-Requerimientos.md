**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 43: Efectos de Sonido

## ID del Módulo
- **Código:** M43 (plan maestro: sección 42 — Efectos de Sonido)
- **Carpeta:** `DOCUMENTACION/43-Efectos-De-Sonido/`
- **Dependencias:** M06/M07 (buses), M13/M17 (voxel e interacciones), M34 (movimiento), M35 (recursos/fishing), M21 (diálogo), M45 (UI Comercio). Relaciones: M42 (ambiente), M44 (ASMR), M41 (música — ducking)
- **Delegable desde:** hoy (diseño completo; implementación tras sistema de audio base)

## 1. Problema

Diseñar los **efectos de eventos** del juego (pasos, acciones, UI, logros): poll de voces limitado, variaciones anti-repetición, prioridades de canal y espacialización — para que cada acción del jugador tenga feedback sonoro claro sin máscara del ambiente ni fatiga.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Pasos por superficie | Hierba, madera, piedra, tierra, nieve, arena: 4+ variaciones por tipo; pasos corriendo (ritmo doble) |
| RF2 | Acciones de movimiento | Saltar, caer (por altura), nadar (salida/entrada): emparejar con M34 |
| RF3 | Interacciones con bloques | Romper, colocar (M13), plantar, regar, cosechar (M17): por material |
| RF4 | Acciones de mundo | Recoger, abrir/cerrar (cofres/cobertizos/Dioses), equipar, herramientas |
| RF5 | Sistemas vivos | Pescar (M35), crafting (M20), comprar/vender (M45), diálogo (M21) |
| RF6 | UI SFX | Menú, selección, confirmación, error, logro: mismos family tones que M41 para coherencia |
| RF7 | Volumen dinámico | Escalas por distancia (3D) y ducking con diálogos (M41/M21) |

## 3. Requisitos No Funcionales

- **Cozy:** sin sonidos estridentes; SFX suaves; error = tono amable (no buzz agresivo).
- **Rendimiento:** pool de voces ≤ 24; nunca más de 6 SFX simultáneos del mismo tipo; sin allocs por frame (M61).
- **Coherencia musical:** los SFX comparten familia tonal con M41 (escala/intervalos).
- Pausa y configuración de volumen por bus (M91 Config de Audio).

## 4. Criterios de Aceptación

1. Los 25 puntos de la sección 42 resueltos.
2. Mapa material→variaciones y familia tonal por categoría.
3. Reglas de prioridad de canal y pool de voces definidas.
4. Coherencia con M34/M13/M17/M45 en las señales de entrada.
5. Delegable para implementación.