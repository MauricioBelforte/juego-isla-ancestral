# Log 1016: M164 Isla-de-Combate-Endgame iter 1 (nucleo data-driven)

**Fecha:** 2026-09-18
**Hora:** 18:55
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code

## Resumen

Iter 1 de M164 (0/130, 🟢 Disponible, complejidad 4, inactivo desde 2026-08-24).
**Alcance limitado por encaje: parte data-driven unicamente** (visual/VFX/IA excluidos —
agente solo-texto, encaje C). **Modulo liberado a 🟡 con 70/130** [x] verificados, 2 [?]
honestos y 58 [ ] con dueño externo claro.

## Cambios Realizados

### Codigo nuevo (8 scripts + 1 test)

- `scripts/combat/gem_currency.gd` — **autoload `gem_currency`**. API get_gems/has_gems/
  add_gems/spend_gems; reglas cozy (nunca negativo, no descartable B.44, no se pierde al
  morir B.45); tabla de cambio por tier encantada (T1=1, T2=2, T3=3, T4=5 — B.33-B.36);
  rangos de gemas por categoria (basico 1-2, medio 2-3, fuerte 3-5, jefe 5-15 — B.37-B.40);
  persistencia versionada M59 (seccion `gemas_m164`).
- `scripts/combat/combat_island_system.gd` — **autoload `combat_island`**. 4 zonas del
  diseño (Costa 0, Bosque 10, Montana 25, Templo 50); `can_access_zone`/`unlock_zone`
  (contrato 04-Codigo §2) con cobro **una sola vez** (permanente, C.13); conteo de
  derrotas por enemy_id (M71/M72 consumen); recompensas; porcentaje de completado;
  proveedor de guardado integrado.
- `scripts/combat/enemy_catalog.gd` — 11 enemigos + 2 jefes con la tabla canonica del
  diseño (D.1-D.11); validacion de esquema completa (`todas_validas()`).
- `scripts/combat/enemy_data.gd` / `boss_data.gd` — Resources con enum Categoria,
  validacion `es_valido()` / `es_valido_jefe()` (umbrales de fase ordenados).
- `scripts/combat/island_zone.gd` — Resource de zona + `orden_por_coste`.
- `scripts/combat/combat_reward.gd` — las 6 recompensas exclusivas cosméticas (F.1-F.6).
- `scripts/combat/gem_save_provider.gd` / `combat_island_save_provider.gd` — puentes M59
  (patron separado AGENTS.md §15, igual que ToolsSaveProvider de M13).
- `scripts/combat/test_combat_m164_atria.gd` — suite headless **0 fallos**.

### Verificacion (obligatoria §12)

- **Test headless con binario Godot 4.7.2 real: `TEST M164 COMBAT: 0 fallo(s)`.** Cubre
  las 4 areas con guardián anti-falso-verde (marcador `_fin` por bloque — detecta
  bloques saltados), cotas min Y max (lección M15), verificacion de ids inexistentes y
  round-trips de persistencia (incluyendo "version 0 no sobreescribe").
- **Boot del proyecto verificado**: 0 SCRIPT ERROR en scripts/combat; 0 regresiones
  (test_herramientas M13 sigue 0 fallos con los 2 autoloads nuevos activos).
- **Autoloads** registrados en `project.godot` (l. 132-133); `.gd.uid` generados via
  escaneo del editor (Godot 4.7 no resuelve class_name nuevos sin ellos).

### Documentacion

- `05-Checklist.md`: 70 [x] con evidencia de archivo en cada uno; linea **Totales**
  añadida (no existia); 2 [?] en B.41/B.42 (monetizacion); bloque de iter 1 completo.
- `04-Codigo.md`: Notas del Agente con lo hecho, lo no hecho, intentos fallidos y
  recomendaciones para el proximo agente (M64 es la dependencia mas grande).

### Decisiones de diseno

- **B.41/B.42 (compra real de gemas) → [?]**: el juego no integra Steam y vender gemas
  rompe el bucle cozy de progreso por juego. Decision delegada al usuario (M126).
- **Catalogo en codigo, no .tres** (patron M13/M36): `_cargar_catalogo()` prefiere
  `data/combat/zone_catalog.tres` si llega a existir, con fallback in-code.
- **Umbrales de jefe descendentes**: el diseño los expresa de HP alto a bajo (0.75,
  0.5, 0.25); la validacion los exige en (0,1) y ordenados descendentes.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/combat/` — 8 scripts nuevos + test (con .gd.uid).
- `game/isla-ancestral/project.godot` — 2 autoloads nuevos.
- `DOCUMENTACION/164-Isla-De-Combate-Endgame/plan-actual/05-Checklist.md` — 70 [x],
  2 [?], Totales, bloque iter 1.
- `DOCUMENTACION/164-Isla-De-Combate-Endgame/plan-actual/04-Codigo.md` — Notas del Agente.
- `CHECKLIST-GLOBAL.md` — fila 164: 🔵→🟡, 0/130→70/130, liberado.

## Errores resueltos durante la iteracion (para el proximo agente)

1. **class_name no resueltos** hasta que el editor escaneo y genero los `.gd.uid`.
   Receta: `Godot --headless --path <proj> --editor --quit` tras crear scripts nuevos.
2. **`var ok := d.es_valido()`** sobre Variant rompia la inferencia de tipos (Godot 4.7
   estricto) → tipado explicito `var ok: bool`.
3. **`Array.assign(array_plano)`** falla con tipado estricto de Array[String] →
   construccion explicita con append.
4. **Test fuera del arbol**: `_ready()` no corre en `SceneTree` tests →
   `cargar_catalogo_para_test()` publico (patron FaunaManager).
5. **Autoload vs instancia local en test**: `unlock_zone` busca el autoload del arbol;
   el test hacia add_gems sobre una instancia colgada. Corregido con snapshot +
   restauracion del saldo global.

## Proxima iter

Pool restante de mi encaje: M126 Marketing-Legal (si pasa a ✅), o re-QA de modulos
🟡 con QA previo del mismo modelo. La cadena de modulos ✅ auditados esta agotada
en mi encaje; M164 quedo 🟡 y su cierre depende de M64/M11/M53 (otros agentes).
