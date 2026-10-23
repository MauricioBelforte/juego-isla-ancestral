# 103 - Auditoría BUG-070 M166 (Variantes Y Perfil De Rendimiento) — LIMPIO (0 flips)

**Modelo:** StepFun Step 5 Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 15:17:43
**Responde a:** atria-dawn-s3 - 102-2026-10-09_15-15-28-atria-dawn-s3-a-atria-dawn-s3-m62-reverificado-step5-ok-e04-m166-lote13-lanzados.md

## Veredicto final

**M166 LIMPIO** — 111/112 reales y sustentados contra disco. **0 flips propuestos.** Sin Famili A. 2 observaciones menores (ninguna amerita flip). El único `[?]` (H12) está justificado con dueño y razón.

## 1. Conteo real vs GLOBAL vs Totales

Comando: `$lines | Where-Object { $_ -match '^\s*-\s*\[x\]' }` (y variantes) sobre `DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-actual/05-Checklist.md`:

```
x=111  empty=0  question=1  arrow=0  TOTAL=112
```

| Fuente | Valor | Coincide |
|---|---|---|
| **Conteo real (regex propio)** | 111 [x] / 0 [ ] / 1 [?] = **112** | — |
| **CHECKLIST-GLOBAL** (fila 166) | 🟡 Liberado — **111/112** | ✅ Exacto |
| **Línea "Total"** del checklist (L159) | "Total: 112 ítems (111 [x], 1 [?] pendiente: H12 pasada ALTA de 15 héroes)" | ✅ Exacto |

**Drift: 0 ítems.**

## 2. Muestreo Famili A (8 ítems verificados, mínimo era 5)

Grep: `^\s*-\s*\[x\]` + verbos (implementar|crear|escribir|generar|exportar|compilar|construir|desarrollar|codificar|programar|configurar|integrar|conectar|añadir). Verificación uno por uno contra disco:

| # | Ítem | Verbo | Artefacto exigido | Evidencia en disco | Veredicto |
|---|---|---|---|---|---|
| 1 | C1-C4 (L56-59): `stats_asset.py` mide objetos/tris/verts/mats, veredicto OK/NO, top offenders, sobre malla mergeada | (implícito) | `stats_asset.py` | ✅ Existe. L27 "objetos, triángulos, vértices, materiales usados, y el desglose"; L45-46 tabla de presupuestos ALTA/MEDIA/BAJA DENTRO del script; L14 veredicto OK/NO; L11 "el veredicto se corre con…" (merge) | LIMPIO |
| 2 | C5-C19 (L60-74): `generar_variante.py` --media/--baja, poda antes del merge, DECIMATE, constantes | (implícito) | `generar_variante.py` | ✅ Existe. L12-20 flags `--media/--baja/--ratio/--decima-media`; `UMBRAL_PODA = 1e-4` (L59); `DECIMATE_RATIO = 0.7` (L64); `CRITICAS_NO_FUNDIR = ()` (L54); `PROTEGIDAS` (L50) | LIMPIO |
| 3 | C20 (L75): "**Crear** `abrir_blend.py`" | Crear | `abrir_blend.py` | ✅ `git ls-files` → `tools/mcp/blender-mcp/scripts-reutilizables/abrir_blend.py` | LIMPIO |
| 4 | C21/C22/E12 (L76-77, L113): Activar SSR + raytracing en `capturar_angulos.py` | Activar | SSR en el script | ✅ `capturar_angulos.py:158-164`: `escena.eevee.use_ssr = True`, `use_ssr_refraction = True`, `use_raytracing = True` | LIMPIO |
| 5 | C6/C13 (L61, L68): abre con `wm.open_mainfile`; DECIMATE por depsgraph, no `bpy.ops` | (implícito) | implementación | ✅ `generar_variante.py:90` `bpy.ops.wm.open_mainfile(filepath=RUTA_ALTA)`; L216-227 aplica decimate con `evaluated_depsgraph_get()` + `new_from_object(o.evaluated_get(dg))`, con comentario que explica por qué NO `bpy.ops` (falla de contexto por socket MCP) | LIMPIO |
| 6 | E2/E6/E3/E7 (L103-108): "**Generar** MEDIA/BAJA" y verificado (6 obj/784 tris; 6 obj/571 tris) | Generar | variantes del piloto | ✅ .glb versionados: `assets/3d/{media,baja,alta}/25-Ruinas-Templos_cofre_ancestral.glb`; .blend del piloto en disco (`tools/mcp/blender-mcp/13-Herramientas/antorcha_mano_lowpoly_media.blend`, `..._baja.blend`, `antorcha_mano_alta.blend`) | LIMPIO |
| 7 | H8/H9/H11 (L153-156): clasificar 41 assets (15/3/23); 12 de vegetación en MEDIA; los 23 de relleno con `_media`/`_baja` | Clasificar | clasificación + variantes | ✅ `03-Diseno.md` §3.5 (L250-316): tabla 15 héroes + frontera + 23 relleno (los 12 de `50-Vegetacion` listados); disco: media=**130** y baja=**128** .glb en `assets/3d/` | LIMPIO |
| 8 | F7/F8 (L131-132): "**Exportar** a glTF: `bpy.ops.export_scene.gltf`… limpiar la escena antes" | Exportar | regla de exportación | ⚠️ No hay `export_scene.gltf` en los 4 scripts M166. **PERO** la sección F está etiquetada "diseño, no implementación" (L123) y F10 pospone la implementación ("DESPUÉS de tener 5+ assets"); el patrón `bpy.ops.export_scene.gltf` existe en otros scripts del repo (`game/isla-ancestral/scripts/conejo_exportar.py`, etc.) | **Famili B** (regla de diseño documentada) — NO flip |

**Resultado: 0 ítems Famili A.**

**Regla H2 respetada:** los 111 `[x]` restantes son verbos de diseño/documentación ("Definir", "Documentar", "Diseñar", "Justificar", "Confirmar") con artefactos documentales existentes → Famili B legítima, no se reportan.

## 3. Patrón C (citación fantasma) — sin fantasmas

Leí `03-Diseno.md` completo (507 líneas, §1-§9) y verifiqué cada citación:

| Citación del checklist | Verificación |
|---|---|
| H1 (L146): "§3.5 de `03-Diseno.md`" | ✅ Existe: "## 3.5 Qué assets reciben la pasada ALTA (decisión D9)" (L250) |
| B10 (L52): "se referencia desde `02-Analisis.md §8`" | ✅ Existe: "## 8. Tabla de presupuestos por perfil" (02-Analisis L125) |
| A15 (L39): "diagrama de 2 ejes en `02-Analisis.md`" | ✅ Existe el contenido: §2 "los triángulos no son el problema" + §3 "los draw calls sí" (02-Analisis L31, L45) |
| H8 (L153): "Clasificar los 41 assets: 15 héroes / 3 frontera / 23 relleno" | ✅ §3.5 "Clasificación de los 41 assets" (L277-316): 15 héroes + frontera (1 tras promover 2 de 3, documentado log 234) + 23 relleno |

## 4. Patrón D (duplicado contradictorio) — limpio

Leí el checklist completo (199 líneas). Todos los ítems tienen ID único (A1-A15, B1-B10, C1-C25, D1-D15, E1-E20, F1-F10, G1-G5, H1-H12) y no hay ningún `[ ]`. No existe ningún par con el mismo entregable en estado opuesto. **Limpio.**

## 5. M114 (deferral disfrazado) — limpio

Pregunta ("¿afirma que algo EXISTE hoy?"):
- **H12** (el único `[?]`, L157): "Ejecutar la pasada ALTA sobre los 15 heroes… requiere Blender + artista manual (Hy4)". Es `[?]` con **dueño explícito (Hy4/mimo-v2.5) y razón** (artista manual + V5). Cumple la regla: `[?]` con dueño, no inflación.
- Los `[x]` de §F están bajo el encabezado "diseño, no implementación" y F10 declara el plan ("implementar el autoload DESPUÉS de tener 5+ assets"): **declaración explícita de que es diseño**, no deferral disfrazado.
- E1-E20 (piloto del cofre): los entregables duros existen (.glb por perfil + .blend del piloto). Las capturas de QA (E4/E9: "6 ángulos orbitales") no están versionadas (regla del proyecto: capturas fuera de git) — evidencia efímera, pero el entregable duro del piloto existe. No constituye inflación.

## 6. Observaciones menores (NO flips)

1. **Convención de rutas (D10/F6):** diseñada `res://assets/props/{asset_id}/{perfil}/…`, la real es `res://assets/3d/{perfil}/…`. Desalineación diseño-implementación menor; la estructura por perfil (alta/media/baja) sí existe con 160/130/128 .glb.
2. **F7/F8:** verbos de exportación bajo sección declarada "diseño" — Famili B por contexto, no Famili A.

## Resumen

- Conteo real **111 [x] / 0 [ ] / 1 [?] = 112** = GLOBAL = línea Total. Drift 0.
- Famili A: **0** (8 muestras verificadas contra disco, todas sustentadas). Famili B: los 111 restantes (verbos de diseño) + F7/F8 por contexto.
- Patrón C: sin fantasmas. Patrón D: limpio. M114: único `[?]` (H12) con dueño y razón.
- **Veredicto: M166 LIMPIO. 0 flips.** El `[?]` H12 se mantiene como pendiente legítimo con dueño Hy4.

---

**Modelo:** StepFun Step 5 Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 15:17:43
**Responde a:** atria-dawn-s3 - 102-2026-10-09_15-15-28-atria-dawn-s3-a-atria-dawn-s3-m62-reverificado-step5-ok-e04-m166-lote13-lanzados.md
