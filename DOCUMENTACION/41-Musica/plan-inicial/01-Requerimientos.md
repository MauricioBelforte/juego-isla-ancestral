**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 41: Música

## ID del Módulo
- **Código:** M41 (plan maestro: sección 40 — Música)
- **Carpeta:** `DOCUMENTACION/41-Musica/`
- **Dependencias:** M07 (arquitectura), M29 (fases de hora/estación), M31 (fases de luz), M32 (clima). Consumidores: M42 (sonido ambiental), M44 (feedback), M57 (localización de títulos)
- **Delegable desde:** hoy (diseño completo; composición/implementación tras M06-Audio system y M1)

## 1. Problema

Definir el sistema musical completo de Aurora: qué música suena en cada momento (hora, estación, clima, zona), cómo se combinan las capas y cómo se transiciona sin repetición excesiva — **siempre cozy, sin tensión forzada, sin música ominosa**.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Música por contexto | Hora del día (5 fases M31), estación (4), clima (3: lluvia/tormenta/nieve), zona (12 biomas + subterráneo/templo/ruinas/cueva) |
| RF2 | Música de flujo | Intro, menú, creación de personaje, llegada a Aurora, créditos |
| RF3 | Música narrativa | Tensión narrativa SUAVE (nunca horror), descubrimiento, misterio, puzzle resuelto, obtención de Sello, festivales, ceremonias |
| RF4 | Leitmotifs | Tema de Aurora, del protagonista, de cada isla (Coral, Verde, Cenizas, Cielo) y del Gran Vapor |
| RF5 | Sistema adaptativo | Capas musicales + intensidad dinámica; variaciones sin loop obvio |
| RF6 | Volumetría | Niveles normalizados, masterización, ducking con diálogos |
| RF7 | Transiciones | Crossfade por contexto, capas entrantes/salientes |

## 3. Requisitos No Funcionales

- **Cozy garantizado:** prohibido tempo > 120 BPM sostenido, sidechaining agresivo, disonancia prolongada, "jump scares" musicales.
- **Anti-repetición:** barajar variaciones (mín. 2 variaciones por tema) y silencio entre repeticiones.
- **Rendimiento:** AudioStreamPlayer polifónico limitado (≤ 8 voces simultáneas en música) — M61.
- Toda la música se orquesta en secciones de 4/8/16 compases para loops perfectos.
- Catálogo ≤ 80 temas totales para el presupuesto de producción (M84 legal/royalties).

## 4. Criterios de Aceptación

1. Los 51 puntos de la sección 40 resueltos.
2. Matriz de contexto → tema definido (hora × estación × clima × zona) sin ambigüedad.
3. Sistema de capas/adaptativa especificado (cuántas capas, qué eventos la suben).
4. Todo el catálogo con duraciones, loops, volúmenes y transiciones.
5. Delegable para implementación; composición final requiere assets del compositor.