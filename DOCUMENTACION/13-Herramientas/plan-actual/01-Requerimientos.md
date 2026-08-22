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
---

## 9. EXPANSIONES DEL MODULO 158 (2026-08-22)

### 9.1 Sistema de Mejora de Herramientas

Además de forjar herramientas nuevas, el jugador puede MEJORAR las que ya tiene. Esto es diferente a forjar: es una inversión en la misma herramienta.

#### Tipos de Mejora

| Mejora | Costo | Efecto | Dónde se hace |
|--------|-------|--------|---------------|
| Afilar | 50 monedas + 3 piedras | +20% velocidad | Herrero de la isla |
| Templar | 150 monedas + 5 minerales | +30% durabilidad | Herrero avanzado |
| Encantar | 500 monedas + 2 cristales | +50% dano + efecto visual | Encantador |

#### Reglas de Mejora

- Se mejora la herramienta que el jugador tiene equipada
- La mejora es permanente (no se puede deshacer)
- Cada herramienta solo recibe CADA mejora una vez (no se puede afilar 2 veces)
- El orden de mejora es: Afilar → Templar → Encantar (secuencial)
- La herramienta mejorada conserva su durabilidad actual
- La herramienta mejorada se ve visualmente diferente (brillo, partículas)

#### Progresión de Mejora

`
Herramienta base (T1)
  → Afilar (+20% velocidad)
    → Templar (+30% durabilidad)
      → Encantar (+50% dano + efecto visual)
        → Herramienta T4 completa
`

#### Integración con M158 (Tiers)

- Las mejoras son OPCIONALES: el jugador puede forjar T2 sin mejorar T1
- Pero las mejoras facilitan la exploración y los puzzles
- Una herramienta T1 encantada puede ser útil en zonas T2
- Las mejoras no reemplazan los tiers; son complementarias

### 9.2 Mejoras por Isla

| Isla | Mejoras Disponibles | Requisito |
|------|---------------------|-----------|
| Principal | Afilar | Ninguno |
| Isla 2 | Afilar, Templar | Herrería (curso) |
| Isla 3 | Afilar, Templar, Encantar | Herrería Avanzada (curso) |
| Isla 4 | Todas | Encantamiento (curso) |

### 9.3 Visual de Mejoras

| Estado | Visual |
|--------|--------|
| Base | Sin brillo |
| Afilada | Brillo sutil en el filo |
| Templada | Brillo dorado tenue |
| Encantada | Brillo morado + partículas |
