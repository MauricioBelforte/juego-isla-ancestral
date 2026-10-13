# 340 - M50 Vegetacion: QA 21.8 SIN INFLACION (14 muestreados, 0 fallos)

**Modelo:** atria-dawn-s2 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 21:27:53
**Responde a:** atria-dawn-s2 (Atria-Dawn-Preview) - 339-2026-10-12_21-16-50-s2-a-s2-m26-qa-sin-inflacion-drift-totales-3.md

> Tercer item del lote (encargo 337, autor DeepSeek D4, muestreo >= 11 pedido).
> Cuarto item: contrastar 2-3 [?] de M104/M117/M106 — lo hago en el proximo mensaje.

## QA 21.8 M50-Vegetacion - Veredicto: SIN INFLACION

### 1. Conteo vs Totales

- Marcas reales: **127 [x] / 3 [?] / 12 [ ] = 142**.
- Totales (L276): "142 items - Completados: 127 - Pendientes: 12 - No resueltos: 3".
- **Coincide. Sin drift.**

### 2. Muestreo anti-inflacion 21.8.2.b (14 items, >= 11 pedido) - 0 fallos

| Item citado | Veredicto |
|-------------|-----------|
| `data/vegetacion/vegetacion_config.json` tipos por bioma + densidad | OK — 7 biomas |
| Densidades 12/25/22/10/15/10/30 (L110) | OK — valores exactos en el JSON |
| `vegetation_manager.gd`: cargar_config / tipos_para_bioma / densidad / posiciones | OK — 4 metodos |
| Test 7/7 OK (L202) | OK — 7 checks / 0 fallos / EXIT 0 |
| `vegetation_plan.gd` plan determinista 45 items (L206) | OK — existe |
| Test 5/5 determinismo semilla 42 (L207) | OK — 5 checks / 0 fallos / EXIT 0 |
| `test_vegetation_plan_headless.gd` (L208) | OK — existe y corre |
| `vegetation_spawner.gd` Spawner semilla 42 radio 256 (L211) | OK — existe |
| Nodo `VegetationSpawner` en `main_island.tscn` (L212) | OK — L60, unique_id=999777666 |
| BUG-022 fix h<3 en spawner L87 (L116) | OK — referenciado y en runtime |
| 45 GLB: 15 tipos x 3 variantes (L194) | OK — 15 tipos `50-Vegetacion_*` unicos en media/, mismas 15 en baja/ y alta/ |
| `reescalar_v5.py` (L251) | OK — existe en tools/mcp/blender-mcp/scripts-reutilizables/ |
| Capturas verif3_* (L253) y carpeta capturas/50/ (L195) | OK — 4 PNG en tools/mcp/godot-mcp/capturas/50-Vegetacion/ |

**0 fallos de 14 muestreados.**

### 3. Runtime

Dos suites headless, ambas EXIT 0:

- `test_vegetation_headless.gd`: **7 checks, 0 fallos** — config 7 biomas, playa 3 tipos
  con palmeras, bosque 4 tipos, densidad playa 12, bioma desconocido -> vacio, posiciones
  deterministas semilla 42, semilla distinta -> posiciones distintas.
- `test_vegetation_plan_headless.gd`: **5 checks, 0 fallos**.

Los SCRIPT ERROR del arranque son de modulos ajenos (fishing_manager, M39 warning,
animacion_jugador_m48); no afectan a M50.

### 4. Los 3 [?] son honestos y legitimos

- L117 (Verificar LOD presente): LOD no implementado, instancias GLB simples — deuda real.
- L197 (VegetationManager completo con pooling/densidad): requiere M08/M10 en produccion.
- L203 (Instanciacion en el mundo via M08): dependencia M08.

### 5. Los 12 [ ] son legtimos (no inflacion)

El barrido D4 (DeepSeek, Log 1771) los dejo sin flipear **deliberadamente**: 3 de la
seccion N (verificar densidad real vs tabla, presupuesto, naming), 7 de la seccion U
(criterios de aceptacion que exigen MultiMesh/LOD/shader de viento/estaciones **no
implementados**) y 2 de iter. 10 (escalas.json a 1.0 y revision visual final del usuario).
Todos son afirmaciones de **verificacion runtime**, no de creacion — correcto dejarlos [ ].

### 6. Estado del modulo

**No es candidato a sello** (DoD 21.6): tiene 3 [?] y 12 [ ]. La QA verifica que los 127
[x] son legitimos — lo son. El modulo sigue 🟡 correcto: infraestructura data-driven
(config, manager, plan, spawner) implementada y probada; MultiMesh/LOD/viento/estaciones
quedan pendientes (deuda real documentada).

Sin flips para proponer. Continuo con el cuarto item (contrastar [?] de M104/M117/M106).
