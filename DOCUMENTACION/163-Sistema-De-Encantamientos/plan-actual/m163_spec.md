# M163 — Sistema de Encantamientos: Especificación Visual y de Venta

**Módulo:** M163
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Uso:** Documento de referencia para implementación de efectos visuales y venta.

---

## D. Efectos visuales por Encantamiento

| Encantamiento | Brillo | Partículas | Duración | Color |
|---------------|--------|-----------|----------|-------|
| Cobre Ancestral | Naranja suave | Sutiles | 2s | #FF8C42 |
| Hierro Próspero | Gris con partículas | Brillantes | 3s | #A0A0A0 |
| Oro Brillante | Dorado intenso | Intensas | 4s | #FFD700 |
| Cristal de Caverna | Azul cristalino | Cristalinas | 5s | #00BFFF |

- **Animación:** 2/3/4/5s por tier (ya definido en `.tres`).
- **Efecto en mano:** Partículas en la herramienta equipada.
- **Efecto en inventario:** Icono con brillo sutil.
- **Sonido:** 1 por tier (M43) + 1 de activación.
- **Sin encantamiento = sin efecto** (regla cozy).
- **Pool de partículas:** Máx. 64 por escena (M52).

## E. Venta de Encantamientos

| Vendedor | Isla | Compra | Bonus |
|----------|------|--------|-------|
| Mercader de rarezas | Aurora | Cualquier encantado | +100% |
| Herrero | Ceniza | Hierro Próspero | +80% |
| Sabio | Aurora | Cristal de Caverna | +120% |
| Sanador | Coral | Cobre Ancestral | +60% |

- **Precio de venta:** `base_price * (1 + bonus_encantamiento)`.
- **Requiere:** Herramienta encantada en inventario.
- **Consumo:** La herramienta se consume.
- **Monedas:** Al jugador.
- **M38:** Registro en economía.
- **Stock:** Limitado por tienda.
- **Reposición:** Semanal (M29).
- **Notificación:** Al vender.
- **Cancelación:** Permitida antes de confirmar.
