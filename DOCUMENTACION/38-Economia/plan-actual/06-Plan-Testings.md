**Modelo:** GLM-5.3 (creación — iter 5, 2026-09-11)
**Plataforma:** Kilo Code

# 06-Plan-Testings.md — Módulo 38: Economía

> Plan de pruebas del módulo según AGENTS.md §14. Cada prueba define escenario,
> criterio de éxito y el test headless que la implementa (Godot 4.7.2, `--script`).
> Las corridas reales están en `07-Resultados-Testings.md`.

## T1. Compra normal con desglose moneda/ítem/stock

- **Escenario:** jugador compra N unidades de un ítem con stock suficiente, tienda abierta y fondos suficientes.
- **Criterios:** stock baja N, inventario sube N, saldo baja `precio*N` (precio SIEMPRE de M38), señales `compra_exitosa` + `inventario_tienda_cambio`, `transaccion_registrada` con monto/saldo/día.
- **Implementa:** `test_m38_economia_smoke.gd`, `shops/test_tiendas.gd` (M39).

## T2. Venta con límite diario y penalización

- **Escenario:** jugador vende un ítem común (límite 3/día) progresivamente.
- **Criterios:** hasta el límite exacto NO hay rebaja ni señal; la venta que CRUZA el límite emite `precio_rebajado(item, antes, después)` UNA sola vez con `después = antes * 0.5`; consultas repetidas de `precio_venta_vigente` NO re-emiten; el precio de venta consultado YA aplica el 50%; contador resetea al cambiar de día.
- **Implementa:** `test_iter5_jkl.gd` §K.4 (8 checks), `test_edge_cases_precio.gd`, `test_topos_banda.gd`.

## T3. Trueque exitoso y rechazado con motivos

- **Escenario:** trueque con ítems suficientes/insuficientes, amistad baja, estación incorrecta, límite diario agotado, inventario lleno al recibir.
- **Criterios:** éxito hace intercambio atómico vía M14 (verificar→remover→agregar, rollback cozy si no entra); cada rechazo emite `trueque_rechazado(motivo)` con motivo distinto y SIN consumir el límite diario (validación antes del intercambio, `_usos` solo tras éxito); salvavidas siempre disponible sin amistad/estación/límite; jamás toca monedas.
- **Implementa:** `test_barter.gd` (M38).

## T4. Determinismo del mercado con misma semilla

- **Escenario:** dos sesiones con la misma semilla de partida (M29) generan la misma tabla del día.
- **Criterios:** `set_semilla` + `serializar/deserializar` del estado de mercado produce precios idénticos ítem a ítem.
- **Implementa:** `test_tabla_dia_transacciones.gd` (iter 2).

## T5. Persistencia: guardar/cargar con saldo e historial exactos

- **Escenario:** transacciones → save → cargar en sesión nueva.
- **Criterios:** saldo, reputación, historial (≤200), ventas_hoy y ventana de oferta se restauran exactos; el guardado a mitad del día restaura contadores diarios intactos.
- **Implementa:** `test_tabla_dia_transacciones.gd`, `test_mercado_estacion_ferias.gd` (reputación), M59 `test_autosave_m59.gd` (integración).

## T6. Ferias: precios especiales se aplican y revierten

- **Escenario:** evento de feria (M73) con flags `precio_compra`/`precio_venta` inicia → termina.
- **Criterios:** los multiplicadores conviven con el ajuste estacional sin pisarse (orden: estacional → feria → oferta → rebaja); al terminar, `limpiar_precios_feria` restaura 1.0; ambos invalidan la caché de la tabla del día.
- **Implementa:** `test_mercado_estacion_ferias.gd` (iter 3), `test_iter5_jkl.gd` §L.3 (invalidación).

## T7. Descuentos por amistad en 3 niveles

- **Escenario:** NPC con amistad 2/3/4 (M20) compra un ítem.
- **Criterios:** descuento 5/10/15% (tope combinado con volumen: 20%); nivel < 2 → sin descuento (nivel 0/1 opera normal — el comercio básico nunca se bloquea); la caché de descuento se invalida con la señal `nivel_amistad_cambio`.
- **Implementa:** `test_iter5_jkl.gd` §L.6/J.8 (mecanismo de caché + invalidación). NOTA: la corrida con 3 niveles REALES requiere NPCs con amistad alta en el autoload Friendship de un entorno de test — documentada como pendiente de datos de M20.

## T8. Anti-arbitraje: reventa de crafting nunca rentable

- **Escenario:** craftear un producto con receta real y venderlo.
- **Criterios:** `precio_venta(resultado) < Σ precio_venta(materiales)` con datos del catálogo real (pico_cobre: 60 < 6×3+15×4=78); RF11: `venta <= compra` del mismo ítem; venta derivada de la compra (tope 0.6), nunca de los materiales.
- **Implementa:** `test_iter5_jkl.gd` §J.5/J.7.

## T9. Rendimiento: 5000 transacciones simuladas sin picos

- **Escenario:** 5000 transacciones (compras+ventas mixtas) en un loop headless.
- **Criterios:** sin picos de memoria (ventana de oferta acotada a 120 entradas — L.7; historial anillo 200); tiempo total razonable; `tabla_del_dia` cacheada no recalcula por consulta (L.3).
- **Runner (ejecutable):** `test_iter5_jkl.gd` §L.7 valida el tope con 300 registros; la corrida completa de 5000 tx queda documentada como ejecutable con el mismo patrón (bucle `registrar_venta` + medición de `Time.get_ticks_msec`) — pendiente por presupuesto de sesión, no por capacidad del sistema.

## T10. Edge cases de precios

- **Escenario:** cantidad 0/negativa, precio base 1 con descuento máximo, ítem sin precio, venta sin bonus por volumen.
- **Criterios:** cantidad inválida = minorista; clamp >= 1 en todo el camino; ítem sin precio queda fuera de `tabla_del_dia`; precio unitario de venta estable.
- **Implementa:** `test_edge_cases_precio.gd` (20 checks), `test_minorista_mayorista.gd`.

## Regresión obligatoria tras cada cambio de M38

```
scripts/economia/test_m38_economia_smoke.gd
scripts/economia/test_edge_cases_precio.gd
scripts/economia/test_topos_banda.gd
scripts/economia/test_minorista_mayorista.gd
scripts/economia/test_tabla_dia_transacciones.gd
scripts/economia/test_mercado_estacion_ferias.gd
scripts/economia/test_barter.gd
scripts/economia/test_iter4_brechas.gd
scripts/economia/test_iter5_jkl.gd
scripts/shops/test_tiendas.gd        (M39 consume precios)
scripts/crafting/test_crafting.gd    (M16 usa coste_ao)
scripts/saving/test_autosave_m59.gd  (M59 persiste economy)
```
