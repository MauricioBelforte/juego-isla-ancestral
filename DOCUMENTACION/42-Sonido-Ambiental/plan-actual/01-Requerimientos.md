**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 42: Sonido Ambiental

## ID del Módulo
- **Código:** M42 (plan maestro: sección 41 — Sonido Ambiental)
- **Carpeta:** `DOCUMENTACION/42-Sonido-Ambiental/`
- **Dependencias:** M07 (buses/arquitectura), M29 (hora), M31 (fases), M32 (clima), M09 (biomas/POI). Relaciones: M41 (música), M44 (feedback)
- **Delegable desde:** hoy (diseño completo; implementación tras sistema de audio base)

## 1. Problema

Crear el paisaje sonoro ambiental de Aurora: los sonidos "de fondo" que dan vida al mundo (viento, hojas, agua, fauna, mecanismos) por bioma, hora y clima — con oclusión y espacialización, sin máscara de la música ni fatiga auditiva.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Banquero por bioma | 13 biomas + subterráneo: cada uno un banco de ambientes |
| RF2 | Capas por hora/clima | Día/noche/alba (M31) y lluvia/tormenta/nieve (M32) modifican densidades |
| RF3 | Fuentes posicionales | Río, cascada, océano, mecanismos: AudioStreamPlayer3D (espacialización) |
| RF4 | Súper-banco de fauna | Aves, insectos, animales con variaciones y horas de actividad |
| RF5 | Sonidos de acción | Madera, piedra, minería, construcción, árboles (M13/M17 eventos) |
| RF6 | Interiores | Cuevas, ruinas, templo con reverb propio |
| RF7 | Máscaras de evolución | Crossfade suave por banco (60-90 s, alineado con M32) |

## 3. Requisitos No Funcionales

- **Cozy:** sin sonidos agresivos; volúmenes ambientales ≤ -18 LUFS de pico promedio; sin "scare".
- **Rendimiento:** máx 8 fuentes ambientales activas por zona + 2 de fauna; sin fuentes instantáneamente activas en cada frame (M61).
- **Oclusión:** paredes/rocas atenúan la fuente (AudioServer 3D / RayCast oclusão) solo en interiores clave.
- Pausa con GameClock (M29).

## 4. Criterios de Aceptación

1. Los 25 puntos de la sección 41 resueltos.
2. Mapa banco→bioma completo (qué zona suena a qué).
3. Capas por hora/clima definidas para cada banco.
4. Clasificación posicional vs 2D y reglas de activación (atraer/ocioso).
5. Delegable para implementación.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M041** — Música | Ambiente sobre música base |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M041** — Música | Depende de este módulo |

