**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# M156 - Terrenos y Movimiento Diferenciado

## 1. Problema

El jugador necesita percibir que diferentes superficies del mundo afectan su movimiento de manera realista pero accesible. Actualmente, el jugador se mueve con velocidad constante independientemente del tipo de terreno sobre el que camina, lo que genera una experiencia plana y poco inmersiva. Se requiere un sistema que:

1. Detecte el tipo de terreno bajo los pies del jugador en tiempo real.
2. Modifique la velocidad de movimiento según el terreno detectado.
3. Permita que la equipación (M155) proporcione bonificaciones específicas por terreno.
4. Proporcione feedback visual (estelas, huellas, salpicaduras) y audio (sonidos de pasos) coherente con cada superficie.
5. Nunca bloquee el movimiento del jugador, solo lo ralentice (filosofía cozy).

## 2. Objeto

Implementar un sistema modular de detección de terrenos que interactúe con:
- El sistema de movimiento del jugador (M11) para modificar la velocidad base.
- El sistema de equipación (M155) para aplicar bonificaciones por equipo.
- Los sistemas de audio y partículas para feedback inmersivo.

## 3. Alcance

### Incluido
- 7 tipos de terreno: Ceped, Barro, Pavimento, Arena, Agua (poco profunda), Nieve, Rocas
- Modificadores de velocidad por terreno (0.6 a 1.0)
- Bonificaciones de equipación por terreno (+0.05 a +0.35)
- Detección por raycast vertical bajo el jugador
- Feedback visual por terreno (huellas, salpicaduras, partículas)
- Feedback audio por terreno (sonidos de pasos diferenciados)
- UI indicators (icono de terreno actual, indicador de velocidad)

### No Incluido
- Físicas de terreno complejas (pendientes, rozamiento dinámico)
- Deformación de terreno
- Sistema de clima que modifique terrenos dinámicamente
- Multiplayer sincronización de terrenos

## 4. Requisitos Funcionales

| ID | Requisito | Prioridad |
|----|-----------|-----------|
| RF1 | El sistema debe detectar el tipo de terreno bajo los pies del jugador usando raycast vertical | Alta |
| RF2 | Deben existir al menos 7 tipos de terreno con modificadores de velocidad diferenciados | Alta |
| RF3 | La velocidad final del jugador = VelocidadBase × ModificadorTerreno × (1 + BonificaciónEquipo) | Alta |
| RF4 | El sistema de equipación (M155) debe poder proporcionar bonificaciones específicas por tipo de terreno | Alta |
| RF5 | Cada tipo de terreno debe tener feedback visual diferenciado (huellas, salpicaduras, partículas) | Media |
| RF6 | Cada tipo de terreno debe tener feedback audio diferenciado (sonidos de pasos) | Media |
| RF7 | El movimiento NUNCA debe ser bloqueado, solo modificado en velocidad (filosofía cozy) | Alta |
| RF8 | Debe existir un indicador visual en la UI que muestre el terreno actual y la velocidad efectiva | Baja |

## 5. Requisitos No Funcionales

| ID | Requisito | Detalle |
|----|-----------|---------|
| RNF1 | Rendimiento | La detección de terreno no debe impactar más de 0.5ms por frame |
| RNF2 | Escalabilidad | Debe ser fácil agregar nuevos tipos de terreno sin modificar código existente |
| RNF3 | Compatibilidad | Debe funcionar con el sistema de movimiento actual de M11 sin refactorizaciones mayores |
| RNF4 | Mantenibilidad | Los datos de terreno deben estar en ScriptableObjects para fácil edición por diseñadores |
| RNF5 | Coherencia | El feedback visual/audio debe activarse solo cuando el jugador está en movimiento |

## 6. Criterios de Aceptación

1. ✅ El jugador se mueve más lento sobre barro que sobre pavimento
2. ✅ Equipar botas de barro reduce significativamente la penalización sobre barro
3. ✅ Se escuchan sonidos diferentes al caminar sobre cada tipo de terreno
4. ✅ Se producen efectos visuales (huellas, salpicaduras) al caminar
5. ✅ El jugador NUNCA se queda trabado o bloqueado por tener equipo inadecuado
6. ✅ El sistema funciona sin noticeable impacto en FPS (mantiene 60fps estable)
7. ✅ El indicador de UI muestra correctamente el terreno actual
8. ✅ Agregar un nuevo tipo de terreno requiere solo crear un ScriptableObject y registrar su ID

## 7. Dependencias

| Módulo | Relación | Notas |
|--------|----------|-------|
| M11 - Personaje Jugador | Depende de | Proporciona velocidad base y posición para raycast |
| M155 - Equipación | Depende de | Proporcione bonificaciones por terreno |
| Sistema de Audio | Integra con | Reproducir sonidos de pasos por terreno |
| Sistema de Partículas | Integra con | Generar efectos visuales por terreno |
| UI Manager | Integra con | Mostrar indicador de terreno actual |

## 8. Restricciones

- Usar Godot 4.x con GDScript
- Compatible con proyecto voxel existente
- No usar físicas de terreno complejas (mantener simple y cozy)
- La detección debe funcionar con terrenos voxel de diferentes alturas
- Los ScriptableObjects de terreno deben ser independientes de la escena

## 9. Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Raycast falla en terrenos irregulares | Media | Alto | Usar múltiples raycasts o adaptar la lógica |
| Impacto en rendimiento por detección constante | Baja | Alto | Usar timers de detección, no cada frame |
| Incompatibilidad con sistema de movimiento M11 | Media | Alto | Diseñar interfaz limpia de integración |
| Dificultad para agregar nuevos terrenos | Baja | Medio | Usar patrón Strategy con ScriptableObjects |

## 10. Notas de Planeación

- Este módulo es core para la experiencia cozy del juego
- La prioridad es que se sienta bien, no que sea realista
- Los modificadores deben ser editables fácilmente desde el inspector
- El feedback audio/visual es tan importante como la mecánica de velocidad

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M011** — Personaje del Jugador | Terrenos sobre movimiento |
| **M155** — Vestimenta y Accesorios | Terrenos y vestimenta |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M155** — Vestimenta y Accesorios | Usado por vestimenta y accesorios |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M011** — Personaje del Jugador | Depende de este módulo |
| **M155** — Vestimenta y Accesorios | Depende de este módulo |

