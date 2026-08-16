**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 13: Herramientas

## ID del Módulo
- **Código:** M13 (plan maestro: sección 12 — Herramientas)
- **Carpeta:** `DOCUMENTACION/13-Herramientas/`
- **Dependencias:** M11 (Personaje), M08 (Mundo Voxel). Dependen de este: M16 (Crafting), M46 (Recursos y Minería), M17 (Construcción)

## 1. Problema

El jugador necesita **herramientas** para interactuar con el mundo voxel (extraer, plantar, pescar, regar) con una jerarquía clara de niveles, durabilidad amable (cozy, sin frustración) y mejoras que premien el progreso sin castigo.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Catálogo de 9 herramientas | Pico, azada, hacha, pala, regadera, caña de pescar, martillo, tijeras, lupa |
| RF2 | Uso por herramienta | Cada una actúa sobre `IInteractable`/voxel con su acción específica |
| RF3 | Niveles | Cobre → Hierro → Oro → Cristal (mini-ups progesivos) |
| RF4 | Durabilidad cozy | Se degrada pero nunca se rompe ni desaparece (se repara gratis con recursos del mundo) |
| RF5 | Herramienta de mano | El martillo construye/arregla (M17); la lupa inspecciona (M26) |
| RF6 | Área y velocidad | Mejor nivel = más rápido + área 3×3 en minaría desde ow |
| RF7 | Feedback por uso | Partículas, sonido y seña visual en el rayo de 4 m (M11) |
| RF8 | Estado persistente | Durabilidad/nivel guardados en GameState.M13 |

## 3. Requisitos No Funcionales

- Curva de progreso: la herramienta de nivel +1 se obtiene al coordinar con el mundo (M46 recursos).
- Sin microtransacciones ni elementos aleatorios en el desgaste (siempre determinista según nivel).
- El inventario (M14) guarda herramientas como objetos con instancia (durabilidad por item).
- Frame budget: la extracción usa el contrato `try_extract` de M08 (sin tocar la física).

## 4. Criterios de Aceptación

1. Los 27 puntos del plan maestro (sección 12) resueltos.
2. Catálogo completo de herramientas con tablas de durabilidad y tiempos.
3. Contrato de extracción/colocación con M08 verificado.
4. Sin ningún elemento castigador (romper/desaparecer herramienta) — regla cozy roja.