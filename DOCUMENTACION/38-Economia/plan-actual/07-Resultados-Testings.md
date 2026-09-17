**Modelo:** GLM-5.3 (creación — iter 5, 2026-09-11)
**Plataforma:** Kilo Code

# 07-Resultados-Testings.md — Módulo 38: Economía

> Corridas reales headless Godot 4.7.2.stable.win64 (binario del proyecto).
> Última ejecución completa: **2026-09-11 (iter 5, Log 844)** tras cerrar J/K/L.

## Resumen de la iter 5 (2026-09-11)

| Suite | Checks | Fallos | Estado |
|---|---|---|---|
| `test_iter5_jkl.gd` (NUEVO iter 5) | 33 | 0 | ✅ |
| `test_m38_economia_smoke.gd` | — | 0 | ✅ |
| `test_edge_cases_precio.gd` | 20 | 0 | ✅ |
| `test_topos_banda.gd` | — | 0 | ✅ |
| `test_minorista_mayorista.gd` | — | 0 | ✅ |
| `test_tabla_dia_transacciones.gd` | 29 | 0 | ✅ |
| `test_mercado_estacion_ferias.gd` | 23 | 0 | ✅ |
| `test_barter.gd` | — | 0 | ✅ |
| `test_iter4_brechas.gd` (iter 4) | 17 | 0 | ✅ |
| `test_tiendas.gd` (M39) | — | 0 | ✅ |
| `test_crafting.gd` (M16) | — | 0 | ✅ |
| `test_autosave_m59.gd` (M59) | — | 0 | ✅ |

**Total iter 5: 12 suites, 0 fallos.**

## Detalle de las verificaciones nuevas (test_iter5_jkl.gd)

### K.4 + I.9 — Rebaja 50% + señal precio_rebajado
- Venta base `madera_roble` == 6 (10 × 0.6) ✅
- 3 ventas (límite exacto común): sin rebaja, sin señal ✅
- 4ª venta: señal `precio_rebajado("madera_roble", 6, 3)` emitida UNA vez ✅
- `precio_venta_vigente` == 3 (50% aplicado en consulta) ✅
- 5 consultas adicionales: la señal sigue == 1 (no re-emite) ✅

### L.3 — Caché de tabla del día
- Dos consultas sin cambios: mismo contenido (hash igual) ✅
- `registrar_venta` invalida: `vendidas_hoy`/`rebajado` visibles en la siguiente consulta ✅
- `recalcular_tabla_dia` invalida sin perder consistencia ✅

### L.7 — Tope de ventana de oferta
- 300 ventas en un día: ventana queda en 120 entradas (MAX_ENTRADAS_VENTANA) ✅
- `ventas_hoy` NO se pierde (300 intactas — vive en `_ventas_hoy`, no en la ventana) ✅

### L.6/J.8 — Caché de descuento por amistad
- 1ª consulta calcula desde el nivel REAL del autoload Friendship y cachea ✅
- 2ª consulta con mismo nivel: mismo resultado ✅
- `invalidar_cache_amistad(npc)` borra SOLO la entrada de ese NPC ✅
- La invalidación de un NPC no afecta a otro ✅
- En runtime: `EventBus.progresion.nivel_amistad_cambio` (M20) dispara la invalidación vía `EconomyManager._conectar_senal_amistad_m20()` ✅

### J.5/J.7 — Anti-arbitraje crafting (datos reales)
- Venta `pico_cobre` (60) < Σ venta materiales (madera 6×3 + cobre 15×4 = 78) ✅
- RF11: venta (60) <= compra (0 → tope no aplica; venta definida por catálogo) ✅

### K.13 — Clamp de descuentos
- Base 1 + volumen 20/50: precio final >= 1 (jamás 0) ✅

### L.1 — Índice O(1) del catálogo
- `_indice` construido (15 entradas == price_overrides) ✅
- `get_price_def` O(1) == lineal para todas las entradas ✅
- Ítem inexistente y cadena vacía → null ✅

## Hallazgos de las corridas

1. **Dominio de señales M20:** la señal `nivel_amistad_cambio` vive en `EventBus.progresion` (dominio ProgresionEvents de M07), no en el autoload Friendship — la conexión se hace con `bus.get("progresion")` (documentado en J.8).
2. **Nivel de amistad de NPC desconocido == 1** (no 0) en `FriendshipService.get_nivel` — afectaba el supuesto inicial del test L.6; corregido consultando el nivel real.
3. **La corrida de 5000 transacciones (T9)** queda definida y ejecutable; no se corrió en esta iteración por presupuesto de sesión (honestidad §21.4) — el mecanismo de memoria constante (tope 120) está validado con 300 registros.

## Regresiones históricas

- Iter 4 (Log 819): `test_iter4_brechas.gd` 17 checks 0 fallos + 7 suites 111 checks 0 fallos.
- Iter 3 (Log 544): `test_mercado_estacion_ferias.gd` 23/0.
- Iter 2 (Log 538): `test_tabla_dia_transacciones.gd` 29/0.
- Base (Log 235): `test_edge_cases_precio.gd` 20/20.


## Corridas del cierre 5b (2026-09-11 — Log 823)

| Suite | Checks | Fallos | Estado |
|---|---|---|---|
| `test_t7_amistad.gd` (NUEVO) | 12 | 0 | ✅ |
| `test_t9_rendimiento.gd` (NUEVO) | 6 | 0 | ✅ |

**Regresión completa del cierre: 14 suites, 0 fallos** (12 de la iter 5 + 2 nuevas).

### T7 — detalle
- Niveles forzados vía `VecinoAmistad.aplicar_puntos` (umbrales 20/40/70 → niveles 2/3/4) sobre el autoload real.
- 5%: tela_lino 60 → 57 · 10%: → 54 · 15%: → 51 (exactos).
- 5% sobre madera (10): se absorbe en round(9.5)=10 (half-up) — documentado, no bug.
- Tope combinado amistad 15% + volumen 15% → 20% (60 → 48).
- Señal M20: EconomyManager conectado (get_connections) + emisión sin crash.

### T9 — detalle
- 5000 tx mixtas (1667 depósitos ×2 = +3334 exacto, 1667 retiros rechazados, 1666 ventas de mercado) en 0.04 s.
- Ventana de oferta: 120 entradas exactas (tope L.7). Historial: 200 (anillo).
- 1000 consultas de tabla_del_dia: 7 ms (caché L.3 sin recálculo).
