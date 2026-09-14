# Log 822: M38-Economía iter 5 — Secciones J/K/L + docs M/N (cierre de la iter 4 PARCIAL)

**Fecha:** 2026-09-11
**Hora:** 19:35
**Modelo:** GLM-5.3
**Plataforma:** Kilo Code

## Resumen

Iteración 5 de M38-Economía: cerré las secciones J-N que quedaron pendientes al cortarse la iter 4 por fin de sesión (Log 819). Combiné auditoría con evidencia (técnica de la iter 4) e implementación de brechas reales de código. Resultado: **161/163 ítems [x]** (quedan 2 [ ] honestos documentados), módulo liberado a 🟡 a un paso del cierre total. Esta es la segunda iteración de la sesión de continuación GLM-5.3 (tras M15 iter 5 / Log 821).

## Cambios Realizados

**Brechas REALES de código (antes muertas/ausentes):**
1. **K.4 + I.9 — Rebaja 50% por límite diario:** `FACTOR_EXCEDIDO_DIARIO` era constante muerta y la señal `precio_rebajado` nunca se emitía. Ahora `precio_venta_vigente()` aplica el 50% al exceder el límite diario, y `registrar_venta()` emite `precio_rebajado(item, antes, después)` UNA vez al CRUZAR el límite (no en la consulta — evita spam). Extraje `_precio_venta_base()` para el "antes" sin mutar estado.
2. **L.1 — Índice O(1):** `EconomyPriceCatalog._indice` (Dictionary item_id→def) construido una vez; `get_price_def()` pasa de O(n) lineal a O(1) con fallback defensivo.
3. **L.3 — Caché de tabla del día:** `tabla_del_dia()` recalculaba en cada consulta; ahora cachea e invalida por venta/recálculo/feria/estación.
4. **L.6 + J.8 — Caché de amistad + señal M20:** `_descuento_amistad()` cachea (npc→{nivel, desc}); `EconomyManager._conectar_senal_amistad_m20()` conecta `EventBus.progresion.nivel_amistad_cambio` (M20) → `invalidar_cache_amistad(npc)`.
5. **L.7 — Tope de ventana:** `MAX_ENTRADAS_VENTANA = 120` en `_podar_ventana()` — memoria constante.
6. **I.10 — DOM-ECO-MERCADO con motivos:** prints en `_ajuste_estacional` (temporada_bono/temporada_penalizacion) y `_ajuste_por_oferta` (oferta_saturada), solo cuando aplican.

**Auditoría con evidencia:** 34 ítems [x] en J/K/L con número de línea/test que los verifica. Anti-arbitraje J.5/J.7 verificado CON DATOS REALES (venta pico_cobre 60 < materiales 78).

**Documentación:** `06-Plan-Testings.md` CREADO (pruebas T1-T10 + regresión obligatoria) y `07-Resultados-Testings.md` CREADO (12 suites 0 fallos con detalle por sección) — cerraba el ítem M de docs. Notas del Agente iter 5 en `04-Codigo.md`.

## Decisiones

1. Señal `precio_rebajado` en el CRUCE del límite (registrar_venta), no en la consulta pura — un disparo por evento, no spam por render de UI.
2. Caché de amistad por NPC (nivel+desc) y no por (npc, ítem): el descuento aplica igual a todos los ítems del NPC.
3. Los 2 [ ] honestos que quedan: M.6 ("146 ítems todos completados" — el checklist real creció a 163 con las iteraciones, quedan ítems conceptuales duplicados de diseño) y M.8 (copia byte-a-byte plan-inicial→plan-actual: NO APLICA — borraría 5 iteraciones de divergencia documentada).
4. T7 (amistad 3 niveles reales) y T9 (5000 tx) definidos en 06-Plan pero no corridos: el primero requiere datos de M20 (NPCs con amistad alta en test), el segundo quedó fuera por presupuesto de sesión — ambos documentados como ejecutables.

## Archivos Modificados/Creados

**Código GDScript:**
- `game/isla-ancestral/scripts/economia/price_manager.gd` (+caché tabla L.3, +caché amistad L.6, +rebaja K.4, +`_precio_venta_base`, +tope ventana L.7, +prints I.10, +invalidación por estación)
- `game/isla-ancestral/scripts/economia/economy_manager.gd` (+conexión señal M20)
- `game/isla-ancestral/scripts/economia/economy_price_catalog.gd` (+índice O(1) L.1)
- `game/isla-ancestral/scripts/economia/test_iter5_jkl.gd` (NUEVO, 33 checks)

**Documentación:**
- `DOCUMENTACION/38-Economia/plan-actual/05-Checklist.md` (J/K/L/M/N con evidencia, registro iter 5, Reserva)
- `DOCUMENTACION/38-Economia/plan-actual/06-Plan-Testings.md` (NUEVO)
- `DOCUMENTACION/38-Economia/plan-actual/07-Resultados-Testings.md` (NUEVO)
- `DOCUMENTACION/38-Economia/plan-actual/04-Codigo.md` (Notas del Agente iter 5)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M38)
- `CHECKLIST-GLOBAL.md` (fila 38)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada iter 5)

## Verificación (QA numérico — Godot 4.7.2 headless)

- `test_iter5_jkl.gd` (NUEVO): **33 checks, 0 fallos**
- Regresión completa (todas 0 fallos): smoke M38 · edge_cases 20 · topos_banda · minorista_mayorista · tabla_dia 29 · mercado_estacion_ferias 23 · barter · iter4_brechas 17 · tiendas M39 · crafting M16 · autosave M59 — **12 suites, 0 fallos**
- UTF-8 sin BOM verificado en los 4 archivos de código (§28). Sin errores de parseo.
