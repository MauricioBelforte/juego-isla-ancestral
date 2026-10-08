**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Modulo 163: Sistema de Encantamientos

## 1. Arquitectura del Sistema

```
EnchantmentSystem (autoload)
├── EnchantmentData (Resource)        <- definicion de cada encantamiento
├── ShamanNPC (Node3D)                <- chaman del monte
├── IncenseCultivation (Resource)     <- cultivo de incienso
└── EnchantedToolVisual (Node3D)      <- efectos visuales de herramienta encantada
```

## 2. Definicion de Encantamientos

Tabla completa (verificada por `test_enchant_tiers.gd` 45/0, iter. 3 — costos
Y duraciones contrastados contra los `.tres` de `data/enchantments/`):

| ID | Nombre | Tier | Habilidad (ability_type x value) | Efecto Visual | Incienso | Monedas | Anim. |
|----|--------|------|----------------------------------|---------------|----------|---------|-------|
| ancestral_cobre | Cobre Ancestral | T1 | special_trade x1 — intercambio especial + bonus | Brillo naranja suave | 3 | 200 | 2s |
| prospero_hierro | Hierro Prospero | T2 | double_coins x2 — x2 monedas al romper minerales | Brillo gris brillante | 5 | 500 | 3s |
| brillante_oro | Oro Brillante | T3 | sell_bonus +0.5 — +50% precio venta tiendas | Brillo dorado intenso | 8 | 800 | 4s |
| caverna_cristal | Cristal de Caverna | T4 | cave_bonus x1.5 — bonus extraccion cuevas | Brillo azul cristalino | 12 | 1000 | 5s |

Estado de implementación (2026-10-07, iter. 3):

- **Definido y probado**: datos de los 4 tiers (costos, duraciones, habilidades,
  colores de brillo, nombres/descripciones unicos) y reglas de equipamiento
  (1 por herramienta, no re-encantar, no desactivable, cobro de incienso).
- **Cobro de monedas**: en `shaman_ui.gd` (valida y descuenta ambas monedas).
- **Persistencia**: EnchantmentSystem es ISaveProvider (seccion
  `enchantments`, registro en SaveManager en `_ready`).
- **Pendiente de otros modulos** (ver 05-Checklist `[?]`): hooks de los
  efectos en tiendas/mineria/cuevas/intercambio, iconos, mejoras M13.
- **Pendiente seccion F**: efectos visuales de brillo/animacion (el dato
  `animation_duration` y `visual_color` ya estan en los `.tres`).

## 3. Flujo del Chamán

```
Jugador habla con chaman del monte
  → Se abre ShamanUI
  → Se muestra lista de herramientas encantables
  → Se muestra costo en incienso + monedas por tier
  → Jugador selecciona herramienta
  → Se valida: tiene incienso suficiente? tiene monedas?
  → Si todo OK: se aplica encantamiento
  → Se consume incienso y monedas
  → Herramienta se actualiza con encantamiento
  → Se aplica efecto visual
  → Se registra en GameState
  → Se notifica a M14 (Inventario)
```

## 4. Costos de Encantamiento

| Tier | Incienso | Monedas | Tiempo de animacion |
|------|----------|---------|---------------------|
| T1 Cobre | 3 | 200 | 2s |
| T2 Hierro | 5 | 500 | 3s |
| T3 Oro | 8 | 800 | 4s |
| T4 Cristal | 12 | 1000 | 5s |

Verificado contra los `.tres` y cobrado en `shaman_ui.gd` (incienso via
`EnchantmentSystem`, monedas via `_retirar`/EconomyManager) — checks A6-A9
y B5 de `test_enchant_tiers.gd`.

## 5. Visual de Encantamientos

| Estado | Visual |
|--------|--------|
| Sin encantar | Sin brillo especial |
| Cobre Ancestral | Brillo naranja suave en filo |
| Hierro Prospero | Brillo gris con particulas |
| Oro Brillante | Brillo dorado intenso |
| Cristal de Caverna | Brillo azul cristalino |

## 6. Venta de Encantamientos

| Tienda | Compra | Precio premium |
|--------|--------|----------------|
| Mercader de rarezas (Aurora) | Cualquier encantado | +100% base |
| Herrero (Ceniza) | Hierro Prospero | +80% base |
| Sabio (Aurora) | Cristal de Caverna | +120% base |
| Sanador (Coral) | Cobre Ancestral | +60% base |

---

## Modulos Relacionados

### Depende de

| Modulo | Que aporta |
|--------|------------|
| **M013** — Herramientas | Sistema base |
| **M158** — Tiers | Definicion de tiers |
| **M159** — Catalogo | Items encantados |

### Relacionados laterales

| Modulo | Relacion |
|--------|----------|
| **M039** — Tiendas | Vende encantados |
| **M038** — Economia | Precios premium |
| **M014** — Inventario | Guarda encantados |
