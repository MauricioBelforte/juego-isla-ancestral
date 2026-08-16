**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 11: Personaje del Jugador

## ID del Módulo
- **Código:** M11 (plan maestro: sección 10 — Personaje del Jugador)
- **Carpeta:** `DOCUMENTACION/11-Personaje-Del-Jugador/`
- **Dependencias:** M07 (Arquitectura, ServiceLocator). Dependen de este: M12 (Cámara), M13 (Herramientas), M14 (Inventario), M19 (NPC)

## 1. Problema

El jugador necesita un **cuerpo jugable** con movimiento cómodo (cozy), físico coherente con el mundo voxel de 1 m y estados claros (caminar, correr, saltar, nadar, interactuar) que soporten el loop diario y la exploración sin fricción.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Movimiento terrestre | Caminar, correr, saltar (altura 1.2 m = 2 bloques) |
| RF2 | Movimiento acuático | Nadar en superficie y buceo limitado por aire |
| RF3 | Colisiones con voxel | Hitbox 0.6×1.8 m vs bloque de 1 m (GDD altura de personas 1.8 m) |
| RF4 | Estados del personaje | idle, run, sprint, jump, swim, dive, interact, sleep, craft |
| RF5 | Interacción | Prompts contextuales con tecla única (F) sobre IInteractable |
| RF6 | Energía/Terreno | Sistema de desgaste que regula el sprint (no castiga) |
| RF7 | Recogida de luz | Destellos de luz (Ø×Ø) recogidos al pasar con magnetismo suave |
| RF8 | Animaciones/sonido | Base jugable con animaciones placeholder y pasos |

## 3. Requisitos No Funcionales

- **Cozy:** sin haters; el movimiento nunca castiga al jugador (sin daño por caída > 3 bloques; fatiga progresiva).
- Cámara tercera persona fija tras el hombro (M12 la define; el personaje expone el pivot).
- Física suave: no velocidad de sprint infinita; stamina regen libre.
- Punto de data: presets de movimiento (data/player/player_motion.tres).

## 4. Criterios de Aceptación

1. Los 30 puntos del plan maestro (sección 10) resueltos.
2. Modelo de estados completo con transiciones y permisos.
3. Hitbox, velocidades y físicas documentadas como constantes consumibles.
4. Sin contradicción con la filosofía cozy (cero daño por caída, fatiga suave).