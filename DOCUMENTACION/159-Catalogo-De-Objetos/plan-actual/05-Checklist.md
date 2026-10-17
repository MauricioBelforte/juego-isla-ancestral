**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline
**Fecha:** 2026-08-25

# 05-Checklist.md — Módulo 159: Catálogo de Objetos

## Reserva actual

- Estado: 🔵 En curso
- Agente: stepfun-3.7-flash / Kilo Code
- Fase: F4/F5
- Dificultad: 2
- Visión: V0/V1
- Entrada: M14🟢 M16🟢 M18🟢
- Salida: Catálogo completo de objetos con .tres por objeto + filtros + tests headless
- Archivos: `scripts/data/item_data.gd`, `scripts/data/item_database.gd`, `data/items/`
- Fecha: 2026-09-01 18:36

## Reclamo M159 b1 — agnes-3-flash (Bloque A visual, director N702)
- **🔵 En curso — agnes-3-flash (Sapiens AI) / Kilo Code, 2026-10-17 03:45.** Reclamo M159 b1 (ítem backlog 18, Bloque A visual). Reclamo en 3 registros: CHECKLIST-GLOBAL fila 159 + este bloque + ESTADO-PARALELO. M159 hoy: 84 [x] / 18 [ ] / 49 [?] = 151.

**INVENTARIO de los 300 `.tres` (data/items/) — b1 (hallazgo anti-inflación §21.8.2.b):**
- **Data-complete:** 300/300 ítems con `nombre` + `descripcion` + `categoria` + `precio` + `rareza` + `tamano` (0 `nombre` vacío). El catálogo es **completo en datos**.
- **GAP de icono/modelo (REFINADO):** **300/300 sin ícono utilizable** — 272/300 tienen `icono=null` explícito; los 28 restantes son recursos M15 del **schema anterior** (sin campo `icono`/`modelo_3d` → también sin ícono). Coincide EXACTAMENTE con el **L212 del director ("300/300 sin icono", OPEN, deuda M45/M46)**.
- **Hallazgo anti-inflación:** los `[x]` "Crear iconos para cada objeto" + "Crear modelos 3D placeholder" **NO están soportados** en los 300 ítems (0 íconos en disco). Es el patrón conocido: **data/catalogo hecho, producción de assets (iconos .png M46 + modelos 3D M45) pendiente** → `#esperando:assets`.
- **Visual QA de iconos:** **N/A este tramo** — no hay íconos del catálogo M159 en disco que capturar (300/300 vacíos). El QA visual de íconos se hace cuando M45/M46 produzcan los assets (`cap_159_`).
- **Confirmación:** el hallazgo es **L212 ya documentado por el director** (OPEN, deuda M45) — **no es drift nuevo ni `[x]` inflado** que yo deba degradar; es una deuda de asset-production pendiente.

**Alcance b1 (este tramo):** inventario + hallazgo de huecos + flag anti-inflación. NO flippeo los `[x]` "Crear iconos/modelos" por mi cuenta — los dejo para el director (mismo patrón M49/M41: propongo, el director aplica el flip). Integración M14/M16 = b3 posterior.

## b2 — Producción de iconos placeholder (director N704, tandas de 10)

- **Herramienta (reutilizada, §15):** `tools/gen_iconos_m159.gd` — genera íconos placeholder 2D 48×48 (relleno = color de CATEGORÍA, borde 3px = color de RAREZA, esquinas suaves, **cero texto** M46, paleta D102 amber/cream sobre dark). Corrige el campo `icono` del `.tres` a la ruta real.
- **Tanda 1 (hecha):** 10 ítems de **tracción de gameplay** (criterio: los que el jugador toca en el loop básico — recursos + minerales): `baya_roja`, `madera_roble`, `piedra_caliza`, `mineral_cobre`, `fibra_algodon`, `wood`, `stone`, `iron_ore`, `grass`, `clay`. → 10 PNG en `assets/2d/items_m159/ico_<id>.png` + campo `icono` del `.tres` apuntando al PNG real.
- **Visual QA:** `tools/mcp/godot-mcp/capturas/159-Catalogo-De-Objetos/cap_159_tanda1_contact_sheet.png` (composita los 10 sobre fondo dark D102). Verificado: distinguibles por color de categoría (baya=azulado, mayoría=verde) + borde de rareza (gris=común, teal=inusual), legibles a 48×48.
- **Bug corregido:** el 1er run generaba `icono="res://res://..."` (prefijo doble) — se quitó el `"res://"+` sobrante (OUT_DIR ya lo trae); re-run limpio.
- **Flip:** los 10 ítems ahora tienen `icono` real en disco, pero el `[ ]` "Verificar que todos los objetos tienen icono" (300) **NO se flippea todavía** (10/300). Flippa al completar las tandas que cubran una categoría completa. Fila GLOBAL sigue 78/146 (real).
- **Tanda 2 (hecha):** 10 ítems (herramientas T1 `item_obj_her_001..005` + recursos `gemstone/glass/ice/mud/moss`) → 10 PNG más en `assets/2d/items_m159/` + `.tres` linked. **20/300 ítems con ícono** (tandas 1+2). QA: `cap_159_tanda2_contact_sheet.png` (verifiqué: gemstone borde ámbar rareza=2 "raro", her_002 borde teal rareza=1 "inusual", categorías por color).

---

## Checklist de Implementación

### Estructura de Datos (15 ítems)

- [x] Crear Resource `ItemData.gd` con todos los campos exportados + 3 enums tipados</arg>
- [x] Crear Autoload `ItemDatabase.gd` con carga automática desde `data/items/`

- [x] Definir enum `Categoria` con 16 categorías
- [x] Definir enum `Rareza` con 4 niveles
- [x] Definir enum `Interaccion` con 13 tipos
- [x] Crear carpeta `data/items/` para Resources .tres
- [x] Implementar `get_item(id)` para búsqueda por ID
- [x] Implementar `get_items_by_category(cat)` para filtrado
- [x] Implementar `get_items_by_rarity(rareza)` para filtrado
- [x] Implementar `get_items_by_source(fuente)` para filtrado
- [x] Implementar `get_interactive_items()` para objetos interactuables
- [x] Implementar `get_placeable_items()` para objetos colocables
- [x] Implementar `get_cookable_items()` para objetos de cocina
- [x] Validar que todos los IDs sean únicos (función `validar_ids_unicos`)
- [x] Crear placeholder `.tres` (item_obj_pla_001) de validación

### CAT-01: Mobiliario Interior (10 ítems)

### CAT-02: Decoración de Pared (8 ítems)

- [x] Documentar 10 cuadros (OBJ-CUA-001 a 010)
- [x] Documentar 5 espejos (OBJ-ESP-001 a 005)
- [x] Documentar 4 relojes (OBJ-REL-001 a 004)
- [x] Definir tamaños de grid de pared
- [x] Definir interacciones (mirar, mirarse, ver hora)
- [x] Definir precios y rareza
- [x] Crear iconos para cada objeto
- [x] Crear modelos 3D placeholder

### CAT-03: Iluminación (10 ítems)

- [x] Documentar 15 objetos de iluminación (OBJ-LUZ-001 a 015)
- [x] Definir tamaños de grid
- [x] Definir interacción (encender/apagar)
- [x] Definir radio de iluminación
- [x] Definir intensidad de luz
- [x] Definir color de luz
- [x] Definir precios y rareza
- [x] Crear iconos
- [x] Crear modelos 3D
- [x] Crear efectos de luz (point light, spot light)

### CAT-04: Plantas Interior (8 ítems)

- [x] Documentar 14 plantas (OBJ-PLA-001 a 014)
- [x] Definir tamaños de grid
- [x] Definir interacción (regar)
- [x] Definir tiempo de crecimiento
- [x] Definir precios y rareza
- [x] Crear iconos
- [x] Crear modelos 3D
- [x] Crear animaciones de crecimiento

### CAT-05: Alfombras (5 ítems)

- [x] Documentar 8 alfombras (OBJ-ALF-001 a 008)
- [x] Definir tamaños de grid
- [x] Definir precios y rareza
- [x] Crear iconos
- [x] Crear texturas de alfombras

### CAT-06: Cocina (10 ítems)

- [?] Documentar 20 objetos de cocina (OBJ-COC-001 a 020) — iter 1: 10 .tres (OBJ-COC-001 a 010)
- [x] Definir tamaños de grid
- [?] Definir interacciones (cocinar, hornear, freír, etc.)
- [?] Definir recetas asociadas
- [x] Definir precios y rareza
- [x] Crear iconos
- [x] Crear modelos 3D
- [?] Crear animaciones de uso
- [?] Integrar con M16 (Crafting)
- [?] Integrar con M18 (Casas)

### CAT-07: Taller (5 ítems)

- [?] Documentar 10 objetos de taller (OBJ-TAL-001 a 010) — iter 1: 5 .tres (OBJ-TAL-001 a 005)
- [x] Definir tamaños de grid
- [?] Definir interacciones (fabricar, forjar, etc.)
- [x] Definir precios y rareza
- [x] Crear iconos y modelos 3D

### CAT-08: Exteriores (10 ítems)

- [?] Documentar 20 objetos exteriores (OBJ-EXT-001 a 020) — iter 1: 5 .tres (OBJ-EXT-001 a 005)
- [x] Definir tamaños de grid exterior
- [?] Definir interacciones
- [x] Definir precios y rareza
- [x] Crear iconos y modelos 3D

### CAT-09: Naturaleza (10 ítems)

- [?] Documentar 10 árboles (OBJ-NAT-001 a 010) — iter 1: 5 .tres (OBJ-NAT-001 a 005)
- [?] Documentar 7 rocas (OBJ-NAT-011 a 017) — pendiente
- [?] Documentar 11 arbustos/flores (OBJ-NAT-018 a 028) — pendiente
- [x] Definir tamaños de grid
- [?] Definir interacciones (cortar, minar, recoger)
- [?] Definir drops de materiales
- [?] Definir tiempo de regeneración
- [x] Crear iconos
- [x] Crear modelos 3D
- [?] Crear animaciones de recolección

### CAT-10: Construcción (5 ítems)

- [?] Documentar 15 objetos de construcción (OBJ-CON-001 a 015) — iter 1: 5 .tres (OBJ-CON-001 a 005)
- [x] Definir tamaños de grid
- [?] Definir interacciones (abrir/cerrar puertas/ventanas)
- [x] Definir precios y rareza
- [x] Crear iconos y modelos 3D

### CAT-11: Herramientas (5 ítems)

- [?] Documentar 20 herramientas (OBJ-HER-001 a 020) — iter 1: 5 .tres (OBJ-HER-001 a 005)
- [?] Definir stats por tier (T1-T4)
- [?] Definir durabilidad
- [x] Definir precios y rareza
- [?] Integrar con M13 (Herramientas) y M158 (Desbloqueo de Zonas)

### CAT-12: Items (10 ítems)

- [?] Documentar 15 materiales (OBJ-ITE-001 a 015) — iter 1: 5 .tres (OBJ-ITE-001 a 005)
- [?] Documentar 20 comidas (OBJ-ITE-020 a 039) — iter 1: 5 .tres (OBJ-ITE-020 a 024)
- [?] Documentar 8 monedas/gemas (OBJ-ITE-050 a 057) — pendiente
- [?] Definir precios de compra/venta
- [?] Definir efectos de comida (energía)
- [?] Definir stack máximo
- [x] Crear iconos
- [?] Integrar con M14 (Inventario)
- [?] Integrar con M16 (Crafting)
- [?] Integrar con M38 (Economía)

### CAT-13: Ropa (5 ítems)

- [?] Documentar 20 prendas (OBJ-ROP-001 a 020) — iter 1: 5 .tres (OBJ-ROP-001 a 005)
- [?] Definir slot (cabeza, cuerpo, pies, accesorio)
- [?] Definir bonificaciones por terreno
- [x] Definir precios y rareza
- [?] Integrar con M155 (Vestimenta)

### CAT-14: Arte Ancestral (5 ítems)

- [?] Documentar 12 objetos ancestrales (OBJ-ART-001 a 012) — iter 1: 5 .tres (OBJ-ART-001 a 005)
- [?] Definir lore asociado a cada uno
- [?] Definir interacciones (mirar + lore)
- [?] Definir rareza (solo Raro/Legendario)
- [?] Integrar con M25 (Ruinas) y M37 (Museos)

### CAT-15: Items de Evento (5 ítems)

- [?] Documentar 12 items de evento (OBJ-EVE-001 a 012) — iter 1: 5 .tres (OBJ-EVE-001 a 005)
- [?] Asociar cada item a un festival específico
- [?] Definir duración de disponibilidad
- [?] Definir interacciones
- [?] Integrar con M29 (Tiempo y Calendario)

### CAT-16: Items Secretos (5 ítems)

- [?] Documentar 12 items secretos (OBJ-SEC-001 a 012) — iter 1: 5 .tres (OBJ-SEC-001 a 005)
- [?] Definir cómo se obtienen (puzzles, quests)
- [?] Definir lore asociado
- [?] Definir rareza (solo Raro/Legendario)
- [?] Integrar con M25 (Ruinas) y M23 (Misiones Secundarias)

### Diseño Visual (15 ítems)

- [ ] Crear `06-Diseno-Visual.md` con paleta global de colores
- [ ] Definir colores HEX para cada categoría de objeto
- [ ] Definir formas y proporciones por categoría
- [ ] Definir materiales por categoría
- [ ] Definir paleta por bioma (13 biomas)
- [ ] Definir reglas de variantes de color (máx 6 por malla)
- [ ] Definir proporciones para Godot (1m = 1 unidad)
- [ ] Definir LODs por categoría
- [ ] Definir texturas por material
- [ ] Crear referencias visuales para mobiliario
- [ ] Crear referencias visuales para herramientas
- [ ] Crear referencias visuales para naturaleza
- [ ] Validar paleta de colores con dirección de arte
- [ ] Documentar variaciones por bioma
- [ ] Integrar con M45 (Arte 3D) para producción de assets

### Integración y Validación (10 ítems)

- [x] Verificar que todos los IDs son únicos
- [x] Verificar que todas las categorías tienen objetos
- [ ] Verificar que todos los objetos tienen icono
- [x] Verificar que todos los objetos interactuables tienen interacción definida
- [x] Verificar que todos los objetos colocables tienen tamaño definido
- [x] Verificar que todos los objetos de tienda tienen precio
- [x] Verificar que la suma total es ≥ 300 objetos
- [x] Documentar integración con M14 (Inventario)
- [x] Documentar integración con M16 (Crafting)
- [x] Documentar integración con M18 (Casas)

### Testing (5 ítems)

- [x] Crear test de carga de ItemDatabase
- [x] Crear test de búsqueda por ID
- [x] Crear test de búsqueda por categoría
- [x] Crear test de búsqueda por rareza
- [?] Crear test de integración con Inventario (M14 no implementado)

**Totales:** 146 items · Completados: 78 · Pendientes: 16 · No resueltos: 52. (Corregido por step-5-kilocode, Kilo Code, 2026-10-13: 77 [x] / 52 [?] / 17 [ ]; autorizado por director msg 257. Actualizado 2026-10-16 por DeepSeek-V4.1-Flash: +1 [x] por el flip L216 -> 78 [x] / 52 [?] / 16 [ ], autorizado por director msg 284.)

> **CORREGIDO POR AUDITORÍA DE DRIFT (atria-dawn-preview / Kilo Code, 2026-09-20,**
> **lote 6):** la línea decía solo *"**Total: 135 ítems**"* (sin desglose y con total
> equivocado). Conteo real: 69 [x] / 25 [ ] / 52 [?] = 146. Las marcas no se tocaron.

## Verificacion (lote DeepSeek-V4.1-Flash, 2026-10-11) — SIN flips

Implementa la seccion "Integracion y Validacion" (L210-L219). Evidencia medida con
Godot 4.7.2 headless; los flips de marca los aplica el director.

- Validador `scripts/data/validar_catalogo_m159.gd`: exit 1 con 122 hallazgos (121 sin icono + total < 300). 0 SCRIPT ERROR.
- Suite `scripts/data/test_catalogo_m159.gd`: 17 checks / 0 fallos / EXIT 0 (x3). Piso `CHECKS_MINIMOS = 17` MEDIDO.
- Sondas ROJAS (probadas por inyeccion, luego borradas): (A) aborto de runtime al inicio del bloque C -> nombra C-G + piso 12<17 + EXIT 1; (B) invariante mutado 121->999 -> 1 fallo + EXIT 1.
- L210 OK (121 ids / 0 duplicados) | L211 OK (16/16 categorias) | L213 OK | L214 OK | L215 OK (121 con venta>0, 93 con compra>0).
- GAP L212: 0/121 con `icono` (M45). GAP L216: 121/300 objetos (faltan 179).
- Integracion documentada en `04-Codigo.md` seccion 7: M14 REAL (`inventario_service.gd` L171/L305); M16 INDIRECTA (ids de receta, sin validacion); M18 NO implementada (`FurnitureData` sin `item_id`).
- Log 1716. Informe al director: canal 174.

## Verificacion (lote L216, DeepSeek-V4.1-Flash, 2026-10-16) - flip L216 aplicado por autorizacion del director (msg 284)

Materializa el minimo L216 del catalogo desde las tablas de `03-Diseno.md`: **179 `.tres` nuevos**
(93 preexistentes + 28 materiales M14 + 179 = **300**). Evidencia con Godot 4.7.2 headless REAL.

- Validador `scripts/data/validar_catalogo_m159.gd`: L210 [OK] unicos=300/duplicados=0 | L211 [OK] 0/16 vacias | L212 [GAP] sin_icono=300/300 | L213 [OK] 0 | L214 [OK] 0 | L215 [OK] 0 | **L216 [OK] total=300, faltan=0**. Los 300 hallazgos son exactamente los 300 sin icono (L212): el EXIT 1 del validador proviene SOLO de L212. 0 SCRIPT ERROR.
- Suite `scripts/data/test_catalogo_m159.gd`: **17 checks / 0 fallos / EXIT 0 (x3)**. Piso `CHECKS_MINIMOS = 17` re-medido. Se reemplazaron 5 pins de conteo obsoletos (121/93) por invariantes (`>= TOTAL_OBJETIVO`, `total == cargados`): consagraban el estado viejo y fallaban con el catalogo correcto.
- Mapping (fuente de verdad = tablas del doc): precio_compra = columna "Precio", precio_venta = compra/2; CAT-12 usa "Precio venta" (compra = 2x venta); NAT sin precio en el doc -> derivado por rareza (30/60/150/400). `descripcion`/`material`/`color` vacios: no estan en las tablas del diseno (los cubre `06-Diseno-Visual.md`/M45).
- Reparacion incluida: 12 archivos tenian **nombre != id** (`item_obj_sil_001.tres` contenia `OBJ-MES-005`, etc.); renombrados a `item_<id>.tres`. Verificado: 0 referencias externas a esas rutas y 0 colisiones.
- GAP L212: 0/300 con `icono` (deuda M45; el director dejo el lote con L212 ABIERTO).
- Pendiente fase siguiente (36 ids del diseno): ART 7, EVE 7, ROP 15, SEC 7.
- Log 1907. Informe al director: canal 285.
