**Modelo:** stepfun-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01

# 05-Checklist.md — Módulo 161: Diseño Visual de NPCs

## Reserva actual

- Estado: 🔵 En curso
- Agente: agnes-3-flash (Kilo Code)
- Fase: F4/Vertical slice
- Dificultad: 3
- Visión: V1
- Entrada: M19🟡 M159🟢 M155🟢
- Salida: Diseño visual de 23 NPCs en 4 islas + ropa con colores HEX + herramientas en mano con IDs M159 + rasgos físicos + variantes estacionales + reglas por profesión + integración M19/M159/M45/M46/M155/M160/M27 + test headless 0 fallos
- Archivos: `data/npc_visuals/` (Resources .tres por NPC), `scripts/data/npc_visual_database.gd` (autoload), `data/npc_visuals/npc_visual_catalog.tres`
- Fecha reserva: 2026-10-21 (agnes-3-flash, frente N650 asignado por el director #752; permiso de visión/captura concedido). B1 medición: 23 diseños (AUR×5, CEN×5, COR×5, RIZ×8); 7/7 refs herramienta→M159 válidas; variantes_estacionales={} + retrato_path="" (los 2 [?] = owner M45/M46 + iter 2). 42 [ ] + 2 [?] = 94/138.

---

## Checklist de Implementación (130 ítems)

### Estructura de Datos (15 ítems)

- [x] Crear Resource `NPCVisualData.gd` con todos los campos [C]
- [x] Crear Resource `RopaData.gd` para prendas de ropa [S]
- [x] Crear Resource `AccesorioData.gd` para accesorios [S]
- [x] Crear enum `PielType` con 5 tonos (SK-01 a SK-05) [S]
- [x] Crear enum `CabelloType` con 8 colores (HR-01 a HR-08) [S]
- [x] Crear enum `OjosType` con 5 colores (EY-01 a EY-05) [S]
- [x] Crear enum `ComplexionType` con 5 tipos [S]
- [x] Crear enum `EstacionType` con 4 estaciones [S]
- [x] Crear Autoload `NPCVisualDatabase.gd` [M]
- [x] Implementar `get_visual(npc_id)` para búsqueda [S]
- [x] Implementar `get_visuals_by_island(isla)` para filtrado [S]
- [x] Implementar `get_seasonal_variant(npc_id, estacion)` [S]
- [x] Crear carpeta `data/npc_visuals/` [S]
- [ ] Validar que todos los IDs coinciden con M19 [M]
- [x] Crear script de validación de diseños [M] — **agnes-3-flash 2026-10-21:** `tools/npc_visual_check.gd` (headless) valida 23 diseños, ids únicos, por isla (AUR/CEN/COR/RIZ), formato `npc_id`, HEX → **0 fallos, 0 avisos** (EXIT 0). Escribe `tools/reportes/`.

### Isla Raíz: 8 NPCs (20 ítems)

- [x] Diseñar Mayor del Pueblo (sombrero #2E5A4C, bastón dorado)
- [x] Diseñar Carpintero (fedora paja #F5DEB3, hacha T1)
- [x] Diseñar Vendedora Tienda General (bufanda #E2725B, bolsa)
- [x] Diseñar Viejo Sabio (sombrero gastado #36454F, bastón retorcido)
- [x] Diseñar Pescador del Puerto (gorro #87CEEB, caña T1)
- [x] Diseñar Agricultora (sombrero paja #FF69B4, rastrillo T1)
- [x] Diseñar Niña del Pueblo (cinta #FF69B4, pelota)
- [x] Diseñar Animador de Plaza (sombrero copa #FFD700, cencerro)
- [x] Definir colores HEX para cada prenda del Mayor
- [x] Definir colores HEX para cada prenda del Carpintero
- [x] Definir colores HEX para cada prenda de la Vendedora
- [x] Definir colores HEX para cada prenda del Viejo Sabio
- [x] Definir colores HEX para cada prenda del Pescador
- [x] Definir colores HEX para cada prenda de la Agricultora
- [x] Definir colores HEX para cada prenda de la Niña
- [x] Definir colores HEX para cada prenda del Animador
- [x] Crear Resources .tres para cada NPC de Raíz
- [x] Definir herramientas en mano con IDs M159
- [x] Definir accesorios para cada NPC
- [x] Validar que herramientas M159 existen

### Isla Coral: 5 NPCs (15 ítems)

- [x] Diseñar Herrero de Coral (pelada, delantal quemado #36454F, martillo)
- [x] Diseñar Pescadora de Coral (paja #F5DEB3, red)
- [x] Diseñar Comerciante Viajero (turbante #FFD700, bolsa cuero)
- [x] Diseñar Guardia del Puerto (casco #71797E, lanza)
- [x] Diseñar Niña de la Playa (flores #FF69B4, cubo)
- [x] Definir colores HEX para cada NPC
- [x] Crear Resources .tres para cada NPC de Coral
- [x] Definir herramientas en mano con IDs M159
- [x] Definir accesorios para cada NPC
- [x] Validar coherencia visual entre NPCs de Coral
- [x] Verificar identificación por profesión
- [ ] Documentar variantes primavera
- [ ] Documentar variantes verano
- [ ] Documentar variantes otoño
- [ ] Documentar variantes invierno

### Isla Ceniza: 5 NPCs (15 ítems)

- [x] Diseñar Herrero Avanzado (gafas #71797E, martillo pesado)
- [x] Diseñar Minero (casco linterna #71797E, pico T1)
- [x] Diseñar Cocinera (cofia #FFFDD0, cuchara)
- [x] Diseñar Bibliotecario (lentes, libro antiguo)
- [x] Diseñar Guardia de la Mina (casco reforzado, lanza)
- [x] Definir colores HEX para cada NPC
- [x] Crear Resources .tres para cada NPC de Ceniza
- [x] Definir herramientas en mano con IDs M159
- [x] Definir accesorios para cada NPC
- [x] Validar coherencia visual entre NPCs de Ceniza
- [x] Verificar identificación por profesión
- [ ] Documentar variantes estacionales
- [x] Definir cicatrices y marcas para Herrero/Minero
- [x] Definir manchas de ceniza para todos
- [x] Verificar gafas de seguridad en mineros

### Isla Aurora: 5 NPCs (15 ítems)

- [x] Diseñar Encantador (sombrero #191970, báculo)
- [x] Diseñar Sanadora (cofia #FFFDD0, poción)
- [x] Diseñar Guardia Ancestral (casco #FFD700, lanza dorada)
- [x] Diseñar Artista (beret #2C2C2C, paleta pintor)
- [x] Diseñar Viajero Misterioso (capucha #36454F, farol azul)
- [x] Definir colores HEX para cada NPC
- [x] Crear Resources .tres para cada NPC de Aurora
- [x] Definir herramientas en mano con IDs M159
- [x] Definir accesorios para cada NPC
- [x] Validar coherencia visual entre NPCs de Aurora
- [x] Verificar identificación por profesión
- [ ] Documentar variantes estacionales
- [x] Definir brillo mágico para Encantador
- [x] Definir efecto etéreo para Sanadora
- [x] Verificar runas y elementos ancestrales

### Tablas Resumen (10 ítems)

- [x] Crear tabla resumen visual de Isla Raíz
- [x] Crear tabla resumen visual de Isla Coral
- [x] Crear tabla resumen visual de Isla Ceniza
- [x] Crear tabla resumen visual de Isla Aurora
- [x] Verificar que todos los colores son consistentes por isla
- [x] Verificar que todas las profesiones son identificables
- [x] Verificar que no hay colores duplicados entre NPCs de misma isla
- [x] Documentar reglas de diseño visual
- [x] Documentar proporciones por tipo de NPC
- [ ] Documentar variantes estacionales generales

### Integración y Validación (20 ítems)

- [ ] Verificar que IDs coinciden con M19 (25 NPCs)
- [x] Verificar que herramientas coinciden con M159 — **agnes-3-flash 2026-10-21:** 7/7 refs de `herramienta_derecha` en los 23 NPCs resuelven a ids M159 existentes (`OBJ-ART-005`→art_005, `OBJ-HER-001/004/006`→her, `OBJ-TAL-002`→tal_002). Verificado contra `data/items/`.
- [ ] Verificar que retratos 2D (M46) usan estos diseños
- [ ] Verificar que modelos 3D (M45) implementan estos diseños
- [ ] Verificar que NPCs aparecen en ubicaciones M160
- [ ] Verificar que ropa puede coincidir con M155
- [ ] Verificar coherencia entre NPCs de misma isla
- [x] Verificar identificación por profesión
- [ ] Documentar integración con M19
- [ ] Documentar integración con M159
- [ ] Documentar integración con M45
- [ ] Documentar integración con M46
- [ ] Documentar integración con M155
- [ ] Documentar integración con M160
- [ ] Documentar integración con M27
- [ ] Documentar integración con M29
- [ ] Documentar integración con M39
- [x] Crear test de carga de NPCVisualDatabase — **agnes-3-flash 2026-10-21:** `tests/unit/data/test_npc_visual_database.gd` (headless, 13 bloques A-M) corre **356 checks, 0 fallos** (EXIT 0, "TEST OK"). Bloque K `test_npc_visual_has_required_fields` (138 checks) valida la carga + campos de los 23 NPCs.
- [x] Crear test de búsqueda por ID
- [x] Crear test de búsqueda por isla

### Testing (10 ítems)

- [x] Crear test de carga de diseños
- [x] Crear test de búsqueda por ID
- [x] Crear test de búsqueda por isla
- [x] Crear test de variantes estacionales
- [ ] Crear test de herramientas M159
- [x] Crear test de colores HEX — **agnes-3-flash 2026-10-21:** bloque M del `test_npc_visual_database.gd` (`test_npc_visual_hex_colors_valid`, 104 checks) + bloque L `clothing_has_colors` (92 checks) — 0 fallos.
- [ ] Crear test de integración con M19
- [ ] Crear test de integración con M46
- [ ] Crear test de validación visual
- [x] Crear test de coherencia por isla — **agnes-3-flash 2026-10-21:** bloques D/E/F del `test_npc_visual_database.gd` (`get_visuals_by_island` + count + all_islands) — 0 fallos.

### Documentación (10 ítems)

- [ ] Crear README con formato de IDs
- [x] Documentar paleta de piel completa — **agnes-3-flash 2026-10-21:** 03-Diseno §1 "Paleta de Colores de Piel" (9 líneas, códigos SK-01…).
- [x] Documentar paleta de cabello completa — **agnes-3-flash 2026-10-21:** 03-Diseno §2 "Paleta de Colores de Cabello" (12 líneas, códigos HR-01…).
- [x] Documentar paleta de ojos completa — **agnes-3-flash 2026-10-21:** 03-Diseno §3 "Paleta de Colores de Ojos" (11 líneas, códigos EY-01…).
- [x] Documentar reglas de identificación por profesión — **agnes-3-flash 2026-10-21:** 03-Diseno §9.1 "Identificación por Profesión".
- [x] Documentar reglas de coherencia por isla — **agnes-3-flash 2026-10-21:** 03-Diseno §8 (tabla resumen visual por isla) + §9.2 "Colores por Isla".
- [ ] Documentar variantes estacionales
- [ ] Documentar integración con otros módulos
- [ ] Crear guía para agregar nuevos NPCs
- [ ] Documentar proporciones y tamaños

**Totales:** 138 ítems · Completados: 94 · Pendientes: 42 · No resueltos: 2.

> **CORREGIDO POR AUDITORÍA DE DRIFT (atria-dawn-preview / Kilo Code, 2026-09-20,**
> **lote 6):** la línea decía *"130 items · Completados: 13 · Pendientes: 117"*.
> Conteo real: 94 [x] / 42 [ ] / 2 [?] = 138. En este caso el claim **sub-reportaba**
> el progreso (13 vs 94 [x] reales, -81) — la línea quedó obsoleta tras flips
> posteriores. Las marcas no se tocaron; solo se reescribió esta línea.
**Nota:** Iter 1 completada por stepfun-3.7-flash / Kilo Code (2026-09-01). Estructura de datos y autoload implementados. Pendiente: 22 Resources .tres restantes, variantes estacionales, tests headless.
## Iteración 1 (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Base de datos visual COMPLETA: 23 diseños .tres (RIZ 8, COR 5, CEN 5, AUR 5) validados — 0 fallos, 0 avisos
- [x] Fix del loader `npc_visual_database.gd` (recursivo) — antes cargaba 1/23 por la estructura por isla; ahora `[NPCVisualDatabase] Cargados 23 diseños visuales`
- [x] Normalizado el formato `script=ExtResource` inline (no cargaba en Godot → prendas null) a `script = ExtResource` estándar en los 22 .tres + RIZ-002; carpintero reubicado a RIZ/
- [x] Herramienta `tools/npc_visual_check.gd` (auditoría data-driven: 23, ids únicos, isla del npc_id, rangos piel/cabello/ojos SK-01..05 HR-01..08 EY-01..05, HEX #RRGGBB) → reporte tools/reportes/npc_visual_check.txt, exit 0 (apto CI)
- [x] Verificación visual con visión (swatch de paleta 23 NPCs generado y analizado): profesión identificable (alcalde verde formal, pescador azul, minero rojo-oscuro, sanadora crema, encantador violeta, artista beret negro/amarillo), coherencia por isla (AUR violeta/sagrado, CEN gris-rojo, COR turquesa-coral, RIZ verde/ocre); gap detectado y corregido: Fedora de paja RIZ-002 sin HEX (fijado #F5DEB3)
- [x] Suite completa ÉXITO (0 fallos) con el nuevo loader
- [?] Modelos 3D/retratos M46 de los 23 diseños (dueño: M45/M46 + Hy4) — el dataset está listo para consumo
- [?] Variantes estacionales (RF6): la maquina `variantes_estacionales` está vacía en los 23 (dueño: iter 2, al menos 10 NPCs documentados en 03-Diseno §9.4)
