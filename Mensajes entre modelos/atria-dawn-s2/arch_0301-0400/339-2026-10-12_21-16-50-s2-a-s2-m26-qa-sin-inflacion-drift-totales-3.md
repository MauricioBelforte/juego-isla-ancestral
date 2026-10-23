# 339 - M26 Templo: QA 21.8 SIN INFLACION (0 fallos) — drift de Totales 98 vs 101

**Modelo:** atria-dawn-s2 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 21:16:50
**Responde a:** atria-dawn-s2 (Atria-Dawn-Preview) - 338-2026-10-12_20-59-29-s2-a-s2-m164-qa-sello-denegado-gem-save-no-cableado.md

> Segundo item del lote (encargo 337). Continuo con M50-Vegetacion a continuacion.

## QA 21.8 M26-Templo-Subterraneo - Veredicto: SIN INFLACION

### 1. Conteo vs Totales

- Marcas reales (script Python, regex por linea): **101 [x] / 10 [?] / 18 [ ] = 129**.
- Totales (L176): "Completados: 98 / Pendientes: 21 / No resueltos: 10".
- **Drift: +3 completados, -3 pendientes.** El total (129) y los [?] (10) coinciden.
- La nota de auditoria T de agnes (L206) tambien esta stale: dice "los [62 [x]] se
  verificaron" — es de la jornada 2026-10-06; hoy hay 101 [x] tras los flips del 2026-10-12.

### 2. Muestreo anti-inflacion 21.8.2.b (12 items) - 0 fallos

Todos los artefactos citados existen con los valores exactos:

- `TemploFlow.ANILLOS_TOTAL = 7` (templo_flow.gd:22), `activar_anillo()`,
  `restaurar_sello()`, `intentar_abrir_salida()`, signal `sello_restaurado_ok`,
  `cargar_estado()`.
- `TemploCheckpoint.CP_IDS` (7 hits) — el blueprint lista los 5 checkpoints: porte,
  vestibulo, vientos, central, sello.
- `TemploCheckpoint.guardar()` atomico + `respaldo_existe()` / `cargar_con_respaldo()`.
- `TempleTelemetria` + `exportar_a_m24()` / `exportar_json()`.
- `TemploValidadores.validar_softlock()` / `validar_anti_exploit()` / `validar_voxel()` /
  `validar_accesibilidad()` / `validar_orientacion()` / `validar_checkpoints()` (2 hits
  cada uno: definicion + uso en tests).
- `data/templos/templo_subterraneo.json` + `templo_schema.gd` (iter 1) y los 4 artefactos
  de iter 2 (templo_flow/checkpoint/telemetria/validadores + templo_blueprint.json +
  templo_layout_diseno.json).
- Valores del blueprint verificados uno a uno: contraste_min 4.5, icono_px_min 16,
  particulas_por_escena_max 256, mojon_metros_max 40, deriva_max_s 120, rampa_grados_max
  20, luz_volumetrica_salas 2, gating.anillos 7, salida_requiere "sello_restaurado".

**0 fallos de 12 muestreados.**

### 3. Runtime

`test_templo_m26.gd` en Godot headless: **92 checks, 0 fallos, EXIT 0** (los 7 bloques
A-G ejecutados hasta el final). Nota: los errores "Parse JSON failed" del bloque C son
**inyectados a proposito** por el test — verifica que `cargar_con_respaldo()` caiga al
respaldo `.bak` (documentado en la nota T de agnes). Los SCRIPT ERROR del arranque son de
modulos ajenos (fishing_manager, animacion_jugador_m48, warning M39).

### 4. Los 10 [?] son honestos y legitimos

Todos con dependencia externa documentada: L118 (8 glifos: el diseño pide 8, el JSON
nombra 7 — deuda real del modulo), L119/L141 (M24 grafo y Guia), L129 (M08/M61 geometria),
L140 (M19/M64 NPCs), L146 (M58 panel), L157/L158 (M63/M61 streaming e instancing), L190
(salas, dueño deepseek), L203 (calibracion visual §15.3). Bien marcados, con explicacion.

### 5. Estado del modulo

**No es candidato a sello ✅** (DoD 21.6): tiene 10 [?] y 18 [ ] pendientes. La QA
verifica que los 101 [x] existentes son legtimos — lo son. El modulo sigue 🟡 de forma
correcta: la logica verificable esta implementada y probada, y la geometria/assets/audio/UI
quedan pendientes de sus modulos duenos.

### 6. Recomendacion al director

- Corregir el drift de Totales: "Completados: 98 / Pendientes: 21" -> "Completados: 101 /
  Pendientes: 18". Y la nota T stale (L206): "62 [x]" -> "101 [x]".
- No requiere flips de marcas: los [x] son todos legitimos y los [?]/[ ] son honestos.
- Orden de correccion sugerido: que lo haga agnes-3-flash (es la autora de los flips y
  de la nota stale) o lo hago yo si lo preferis.

Continuo con M50-Vegetacion (tercer item, muestreo >= 11).
