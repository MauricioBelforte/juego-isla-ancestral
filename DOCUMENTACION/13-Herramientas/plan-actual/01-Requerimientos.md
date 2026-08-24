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

## 3.1 Tabla de Durabilidad por Herramienta y Tier

> La durabilidad se mide en **golpes**. Las herramientas **nunca se rompen** (cozy): al llegar a 0, la herramienta queda inutilizada pero se repara gratis en cualquier mesa de trabajo (M17) con recursos básicos.

### Pico (Minería)

| Tier | Nombre | Durabilidad | Velocidad (s/golpe) | Daño voxel | Reparación | Notas |
|------|--------|-------------|---------------------|------------|------------|-------|
| T1 | Pico de Cobre | 150 | 1.2 | 1×1 | 3 piedra | Apta para piedra y minerales básicos |
| T2 | Pico de Hierro | 250 | 0.9 | 1×1 | 5 piedra + 2 hierro | Apta para minerales medios (cobre, hierro) |
| T3 | Pico de Oro | 400 | 0.7 | 3×3 | 8 piedra + 3 oro | Apta para minerales avanzados (oro, obsidiana) |
| T4 | Pico de Cristal | 600 | 0.5 | 3×3 | 10 piedra + 5 cristal | Apta para todo; bonus en cuevas con encantamiento |

### Hacha (Tala)

| Tier | Nombre | Durabilidad | Velocidad (s/golpe) | Daño voxel | Reparación | Notas |
|------|--------|-------------|---------------------|------------|------------|-------|
| T1 | Hacha de Cobre | 120 | 1.0 | 1×1 | 3 madera | Apta para árboles pequeños y arbustos |
| T2 | Hacha de Hierro | 200 | 0.8 | 1×1 | 5 madera + 2 hierro | Apta para árboles medios |
| T3 | Hacha de Oro | 350 | 0.6 | 3×3 | 8 madera + 3 oro | Apta para árboles grandes; tala área |
| T4 | Hacha de Cristal | 500 | 0.4 | 3×3 | 10 madera + 5 cristal | Apta para todo; tala instantánea en madera blanda |

### Azada (Agricultura)

| Tier | Nombre | Durabilidad | Velocidad (s/golpe) | Daño voxel | Reparación | Notas |
|------|--------|-------------|---------------------|------------|------------|-------|
| T1 | Azada de Cobre | 100 | 1.0 | 1×1 | 2 piedra + 1 madera | Prepara 1 terreno por golpe |
| T2 | Azada de Hierro | 180 | 0.8 | 1×1 | 3 piedra + 2 hierro | Prepara 1 terreno; +10% calidad suelo |
| T3 | Azada de Oro | 300 | 0.6 | 3×3 | 5 piedra + 3 oro | Prepara 9 terrenos; +20% calidad suelo |
| T4 | Azada de Cristal | 450 | 0.4 | 3×3 | 8 piedra + 5 cristal | Prepara 9 terrenos; +30% calidad suelo |

### Pala (Excavación)

| Tier | Nombre | Durabilidad | Velocidad (s/golpe) | Daño voxel | Reparación | Notas |
|------|--------|-------------|---------------------|------------|------------|-------|
| T1 | Pala de Cobre | 100 | 1.2 | 1×1 | 3 piedra | Excava tierra, arena, arcilla |
| T2 | Pala de Hierro | 180 | 0.9 | 1×1 | 5 piedra + 2 hierro | Excava más rápido; suitable para roca blanda |
| T3 | Pala de Oro | 300 | 0.7 | 3×3 | 8 piedra + 3 oro | Excava área; suitable para roca dura |
| T4 | Pala de Cristal | 450 | 0.5 | 3×3 | 10 piedra + 5 cristal | Excava todo; bonus para tesoros enterrados |

### Regadera (Riego)

| Tier | Nombre | Durabilidad | Velocidad | Alcance | Reparación | Notas |
|------|--------|-------------|-----------|---------|------------|-------|
| T1 | Regadera de Cobre | 80 | 1.0 | 3×3 | 2 piedra | Riega cultivos cercanos |
| T2 | Regadera de Hierro | 150 | 0.8 | 5×5 | 3 piedra + 2 hierro | Riega más área; +15% crecimiento |
| T3 | Regadera de Oro | 250 | 0.6 | 7×7 | 5 piedra + 3 oro | Riega zona amplia; +25% crecimiento |
| T4 | Regadera de Cristal | 400 | 0.4 | 9×9 | 8 piedra + 5 cristal | Riega zona masiva; +35% crecimiento |

### Caña de Pescar (Pesca)

| Tier | Nombre | Durabilidad | Velocidad | Alcance | Reparación | Notas |
|------|--------|-------------|-----------|---------|------------|-------|
| T1 | Caña de Cobre | 100 | variable | corto | 2 madera + 1 fibra | Pescados comunes |
| T2 | Caña de Hierro | 180 | variable | medio | 3 madera + 2 hierro | Pescados medios; menos perdidas |
| T3 | Caña de Oro | 300 | variable | largo | 5 madera + 3 oro | Pescados raros; +20% calidad |
| T4 | Caña de Cristal | 450 | variable | muy largo | 8 madera + 5 cristal | Pescados legendarios; +40% calidad |

### Martillo (Construcción)

| Tier | Nombre | Durabilidad | Velocidad | Daño voxel | Reparación | Notas |
|------|--------|-------------|-----------|------------|------------|-------|
| T1 | Martillo de Cobre | 120 | 1.0 | — | 3 piedra | Construye estructuras básicas (M17) |
| T2 | Martillo de Hierro | 200 | 0.8 | — | 5 piedra + 2 hierro | Construye estructuras intermedias |
| T3 | Martillo de Oro | 350 | 0.6 | — | 8 piedra + 3 oro | Construye estructuras avanzadas |
| T4 | Martillo de Cristal | 500 | 0.4 | — | 10 piedra + 5 cristal | Construye todo; repara herramientas dañadas |

### Tijeras (Podar/Recortar)

| Tier | Nombre | Durabilidad | Velocidad | Alcance | Reparación | Notas |
|------|--------|-------------|-----------|---------|------------|-------|
| T1 | Tijeras de Cobre | 80 | 1.0 | corto | 2 piedra | Podar arbustos, cortar fibras |
| T2 | Tijeras de Hierro | 150 | 0.8 | medio | 3 piedra + 2 hierro | Podar árboles pequeños; cortar más fibras |
| T3 | Tijeras de Oro | 250 | 0.6 | largo | 5 piedra + 3 oro | Podar áreas; obtener fibras raras |
| T4 | Tijeras de Cristal | 400 | 0.4 | muy largo | 8 piedra + 5 cristal | Podar todo; fibras ancestrales |

### Lupa (Inspección)

| Tier | Nombre | Durabilidad | Velocidad | Alcance | Reparación | Notas |
|------|--------|-------------|-----------|---------|------------|-------|
| T1 | Lupa de Cobre | 200 | 1.0 | 2 m | 1 piedra | Detecta recursos ocultos comunes |
| T2 | Lupa de Hierro | 350 | 0.8 | 3 m | 2 piedra + 1 hierro | Detecta recursos medios; lee inscripciones |
| T3 | Lupa de Oro | 500 | 0.6 | 5 m | 3 piedra + 2 oro | Detecta recursos raros; revela secretos |
| T4 | Lupa de Cristal | 700 | 0.4 | 8 m | 5 piedra + 3 cristal | Detecta todo; interactúa con mecanismos antiguos |

---

## 3.2 Contrato de Extracción con M08 (Voxel)

Las herramientas de extracción (pico, hacha, azada, pala) se comunican con el mundo voxel (M08) mediante el contrato `try_extract`:

```gdscript
# Contrato de extracción — M13 → M08
# Retorna: true si la extracción fue exitosa
func try_extract(pos: Vector3i, herramienta_id: StringName) -> bool:
    # 1. Validar que la posición es un voxel válido en M08
    # 2. Verificar que la herramienta es apta para ese tipo de bloque
    # 3. Consumir 1 punto de durabilidad de la herramienta
    # 4. Generar drops según ResourceDefinition (M15)
    # 5. Modificar el voxel en M08 (reemplazar por aire o bloque dañado)
    # 6. Emitir señal golpe_aplicado para feedback
    pass
```

```gdscript
# Contrato de colocación — M13 → M08
# Retorna: true si la colocación fue exitosa
func try_place(pos: Vector3i, bloque_id: StringName) -> bool:
    # 1. Validar posición vacía y superficie válida
    # 2. Consumir 1 unidad del bloque del inventario (M14)
    # 3. Colocar el bloque en M08
    # 4. Emitir反馈 visual
    pass
```

### Reglas del contrato

1. **Sin overlay de física**: las herramientas usan raycast de 4 m (M11), no colisiones físicas.
2. **Determinista**: misma herramienta + mismo bloque = mismo resultado siempre.
3. **Sin castigo por fallo**: si el jugador golpea con herramienta incorrecta, solo pierde tiempo (no durabilidad).
4. **Feedback inmediato**: cada golpe exitoso muestra partículas + sonido + texto de cantidad.
5. **Area de extracción**: herramientas T3+ pueden extraer en área (3×3) si el jugador lo desbloqueó.

---

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
| Potenciar | 500 monedas + 2 cristales | +50% dano + efecto visual | Cristalero |

#### Reglas de Mejora

- Se mejora la herramienta que el jugador tiene equipada
- La mejora es permanente (no se puede deshacer)
- Cada herramienta solo recibe CADA mejora una vez (no se puede afilar 2 veces)
- El orden de mejora es: Afilar → Templar → Potenciar (secuencial)
- La herramienta mejorada conserva su durabilidad actual
- La herramienta mejorada se ve visualmente diferente (brillo, partículas)

#### Progresión de Mejora

`
Herramienta base (T1)
  → Afilar (+20% velocidad)
    → Templar (+30% durabilidad)
      → Potenciar (+50% dano + efecto visual)
        → Herramienta mejorada al maximo
`

#### Integración con M158 (Tiers)

- Las mejoras son OPCIONALES: el jugador puede forjar T2 sin mejorar T1
- Pero las mejoras facilitan la exploración y los puzzles
- Una herramienta T1 potenciada puede ser útil en zonas T2
- Las mejoras no reemplazan los tiers; son complementarias
- Los encantamientos del chaman (M158) son un sistema SEPARADO: dan habilidades únicas por tier

### 9.2 Mejoras por Isla

| Isla | Mejoras Disponibles | Requisito |
|------|---------------------|-----------|
| Principal | Afilar | Ninguno |
| Isla 2 | Afilar, Templar | Herrería (curso) |
| Isla 3 | Afilar, Templar, Potenciar | Herrería Avanzada (curso) |
| Isla 4 | Todas | Cristalería (curso) |

### 9.3 Visual de Mejoras

| Estado | Visual |
|--------|--------|
| Base | Sin brillo |
| Afilada | Brillo sutil en el filo |
| Templada | Brillo dorado tenue |
| Potenciada | Brillo morado + partículas |

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M011** — Personaje del Jugador | Herramientas en mano |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M024** — Templos y Puzzles | Usado por templos y puzzles |
| **M035** — Minería | Usado por minería |
| **M070** — Interacciones | Usado por interacciones |
| **M158** — Herramientas y Desbloqueo de Zonas | Usado por herramientas y desbloqueo de zonas |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M011** — Personaje del Jugador | Depende de este módulo |
| **M024** — Templos y Puzzles | Este módulo lo necesita |
| **M035** — Minería | Este módulo lo necesita |
| **M070** — Interacciones | Este módulo lo necesita |
| **M158** — Herramientas y Desbloqueo de Zonas | Este módulo lo necesita |

