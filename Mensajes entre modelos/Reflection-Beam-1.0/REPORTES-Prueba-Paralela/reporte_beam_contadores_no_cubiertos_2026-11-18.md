# Reporte de Auditoría de Consistencia — Contadores, IDs Duplicados y Drift

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-18 05:21:13

## Alcance

- Scripts auditados: `game/isla-ancestral/scripts/economia/`, `scripts/progresion/`, `scripts/coleccionables/` (solo lectura, sin código de juego modificado).
- Verificación de IDs duplicados (48, 115, 127, 139, 148) en `CHECKLIST-GLOBAL.md`.
- Verificación de drift de progreso vs `05-Checklist.md` real (script `scripts/verificar_checklist.py`).
- Contadores sin cobertura de tests identificados por grep en `test_*.gd`.

## Hallazgos

### A. Contadores no cubiertos / inconsistentes

1. `game/isla-ancestral/scripts/economia/economy_manager.gd:129` (`_depositos_clampeados += 1`) — ningún test referencia `depositos_clampeados`/`_depositos_clampeados`. **Severidad: Medio.** Accionable: agregar test que fuerce depósito con saldo en tope `MAX_SALDO` y verifique incremento del contador.

2. `game/isla-ancestral/scripts/economia/economy_manager.gd:196-203` (`get_save_data`) y `:205-226` (`restore_save_data`) — `_depositos_clampeados` no se persiste ni se restaura; el contador de telemetría se resetea a 0 al cargar. **Severidad: Bajo.** Accionable: persistirlo en la sección "economy" o documentar como efímero por sesión.

3. `game/isla-ancestral/scripts/economia/price_manager.gd:353-358` (`serializar`) — no incluye `_recargos_clampeados` (L90-91, L142, L146, L156-157). **Severidad: Bajo.** Accionable: incluirlo en serialización o documentar como efímero.

4. `game/isla-ancestral/scripts/coleccionables/coleccionables_manager.gd:73` (`_categoria_collected[cat] = ... + 1`) — si `cat` no existe en `_categoria_total` (item no presente en catálogo), se crea entrada de collected sin total correspondiente; `total_count` devuelve 0, `porcentaje_categoria` 0.0 y `_categoria_completa` false. **Severidad: Medio.** Accionable: validar `cat` contra `_categoria_total` antes de incrementar o inicializar el total.

5. `game/isla-ancestral/scripts/coleccionables/coleccionables_manager.gd:156-168` (`restore_save_data`) — sobrescribe `_categoria_collected` con el guardado sin recalcular desde `_collected` + catálogo; si el catálogo cambió, drift persistente. **Severidad: Medio.** Accionable: recalcular `_categoria_collected` desde `_collected` al restaurar.

6. `game/isla-ancestral/scripts/coleccionables/coleccionables_manager.gd:122-130` (`porcentaje_total`) — suma collected/total por categoría sin clampear; si collected > total por drift, el porcentaje puede superar 1.0. **Severidad: Bajo.** Accionable: clampear resultado a [0.0, 1.0].

7. `game/isla-ancestral/scripts/coleccionables/coleccionables_manager.gd:180-181` (`_on_especie_avistada`) — `lechuza_bosque` y `halcon_montana` mapean a `&"003"` (mismo `id_local` en animales); el segundo no registra descubrimiento por idempotencia de `registrar`. Subconteo de descubrimientos. **Severidad: Medio.** Accionable: asignar `id_local` único por especie o mapear a items distintos.

8. `game/isla-ancestral/scripts/coleccionables/validate_collectibles.gd:49` y `:79` — `total` cuenta cada entrada (incluyendo inválidas) y `por_categoria` incrementa por `cat` incluso inválidos. Contador inflado. **Severidad: Bajo.** Accionable: incrementar `total`/`por_categoria` solo si el item es válido.

9. `game/isla-ancestral/scripts/progresion/player_profile.gd:39-42` (`set_stat`) — no actualiza `_contribucion` cuando `stat_id == "monedas_ganadas"`; inconsistencia con `incrementar` (L31-37). **Severidad: Medio.** Accionable: actualizar `_contribucion` en `set_stat` para ese stat.

10. `game/isla-ancestral/scripts/progresion/progression_manager.gd:392-405` (`_evaluate_cache_set`) — cache congelado de condiciones; no se invalida al marcar un hito ni al cambiar estado, puede quedar stale. `oldest_idx` sin uso. **Severidad: Medio.** Accionable: documentar semántica (cache de condición, no de hito) o invalidar al marcar hito.

11. `game/isla-ancestral/scripts/economia/barter_system.gd:144-149` y `:177-178` — `limite_diario(npc_id)` usa el máximo de límites por oferta, pero `_limite_de(oferta)` (usado en `propuestas_disponibles` L83 y `ejecutar_trueque` L111) usa el límite per-oferta, con `usos_hoy` compartido por npc. Inconsistencia de contador/límite. **Severidad: Medio.** Accionable: unificar el límite por npc (usar el máximo) en todos los paths.

### B. IDs duplicados en CHECKLIST-GLOBAL.md

- ID 48: filas L151 y L152 (mismo ID, agentes distintos).
- ID 115: filas L52 y L53.
- ID 127: filas L66 y L67.
- ID 139: filas L81 y L83 (L82 es ID 14 desalineado entre ellas).
- ID 148: filas L93 y L94.

**Severidad: Alto.** Fuente de verdad duplicada. Accionable: consolidar a una fila por ID, eliminar duplicados y mantener una sola fuente de estado.

### C. Drift de progreso (CHECKLIST-GLOBAL vs 05-Checklist.md real)

- 38-Economia: global `164/164` (✅) vs real `163/164` + 1 [?]. **Severidad: Alto.** Accionable: corregir global a `163/164` o degradar a 🟡.
- 73-Coleccionables: global ✅ `76/135` vs real `76 [x]` + 3 `[ ]` + 56 `[?]`. **Severidad: Alto.** Accionable: degradar a 🟡 (DoD §21.6 exige todo [x] para ✅).
- 139-Pre-Alpha: global `139/142` (🔵) vs real `136/142`. **Severidad: Medio.** Accionable: corregir a `136/142`.
- 148-Lore-Ambiental: global `115/117` vs real `116/117`. **Severidad: Bajo.** Accionable: corregir a `116/117`.
- 71-Progresion: global `169/213` vs real `169/213` (sin drift). OK.

## Mejoras de diseño concretas

1. **Derivar contadores de categoría desde la fuente de verdad**: en `coleccionables_manager.gd`, recalcular `_categoria_collected` a partir de `_collected` + catálogo en `_ready` y en `restore_save_data`, y clampear `porcentaje_total`/`porcentaje_categoria` a [0,1]. Elimina drift persistente y subconteos por mapeos duplicados.

2. **Persistir o declarar efímeros los contadores de telemetría**: incluir `_depositos_clampeados` y `_recargos_clampeados` en `get_save_data`/`serializar` (o documentar explícitamente que son efímeros por sesión) y añadir tests de cobertura para `_depositos_clampeados` (hoy 0 referencias en tests).
filePath">
D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Mensajes entre modelos\Reflection-Beam-1.0\REPORTES-Prueba-Paralela\reporte_beam_contadores_no_cubiertos_2026-11-18.md