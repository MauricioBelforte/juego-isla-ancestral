# 05-Checklist — M166 · Variantes de Assets por Perfil de Rendimiento

**Modelo:** minimax-m3-free (Kilo Code)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02

Regla del proyecto: este checklist debe tener **≥ 100 ítems** verificables. Las ideas provienen del `Plan-inicial-minimo.md` (600+ puntos), del `Plan-de-produccion.md` y de las necesidades descubiertas durante el piloto del cofre ancestral.

## A. Modelo conceptual (1–15)

- [x] A1. Definir las 3 variantes según **nivel de detalle**, no según draw calls.
- [x] A2. MEDIA = asset actual (lowpoly ya aprobado) tal cual, con merge por material al exportar.
- [x] A3. BAJA = asset actual + poda + decimate 0.7 + merge.
- [x] A4. ALTA = pasada artística futura, modelada a mano, con merge por material al exportar.
- [x] A5. El merge por material es una **etapa de exportación**, no una variante.
- [x] A6. Documentar el error de la primera versión: confundir draw calls con detalle y producir 3 variantes idénticas.
- [x] A7. La diferencia entre ALTA y MEDIA debe ser **visible** (≥ 3× los triángulos), no solo medible.
- [x] A8. ALTA y MEDIA comparten silueta, paleta y z_min (R7).
- [x] A9. Si la silueta cambia, no es una variante — es otro asset.
- [x] A10. Las variantes derivadas (MEDIA/BAJA) no se versionan — se regeneran.
- [x] A11. La ALTA sí se versiona — es hand-authored.
- [x] A12. MultiMesh obligatorio para > 10 instancias del mismo asset (vegetación).
- [x] A13. El `merge` se aplica a las 3 variantes, incluida la ALTA (R8).
- [x] A14. Una ALTA de 80 piezas sin mergear tendría 80 draw calls: peor que el asset actual.
- [x] A15. Documentar el diagrama de 2 ejes (detalle ↑ vs draw calls →) en `02-Analisis.md`.

## B. Tabla de presupuestos (16–25)

- [x] B1. ALTA: ≤ 16 objetos (tras merge) / ≤ 6.000 tris / ≤ 12 materiales.
- [x] B2. MEDIA: ≤ 8 objetos / ≤ 1.500 tris / ≤ 8 materiales.
- [x] B3. BAJA: ≤ 6 objetos / ≤ 700 tris / ≤ 4 materiales.
- [x] B4. La tabla de presupuesto se mide **después del merge** (output del script).
- [x] B5. Si una ALTA mergeada da OK en MEDIA, **la pasada artística no agregó suficiente detalle** y hay que seguir trabajando.
- [x] B6. Salto ALTA/MEDIA ≥ 3× triángulos para que se note visualmente.
- [x] B7. Justificar 6.000 tris ALTA: ~7,6× el cofre actual, coherente con Animal Crossing.
- [x] B8. Justificar 1.500 tris MEDIA: holgura sobre los 784 actuales.
- [x] B9. Justificar 700 tris BAJA: ~50 % de MEDIA, coherente con decimate 0.7.
- [x] B10. La tabla vive en `stats_asset.py` y se referencia desde `02-Analisis.md §8`.

## C. Scripts y herramientas (26–50)

- [x] C1. `stats_asset.py` mide objetos / triángulos / vértices / materiales.
- [x] C2. `stats_asset.py` imprime verdict OK/NO contra los 3 perfiles.
- [x] C3. `stats_asset.py` lista el desglose por objeto (top offenders).
- [x] C4. `stats_asset.py` corre sobre la malla **ya mergeada** (output del script de variante).
- [x] C5. `generar_variante.py` con sub-comandos `--media` y `--baja`.
- [x] C6. `generar_variante.py` abre el .blend source con `wm.open_mainfile` (E-14).
- [x] C7. `generar_variante.py` aplica PODA ANTES del merge (orden importa).
- [x] C8. `generar_variante.py` MERGE por material agrupando por tupla de nombres.
- [x] C9. `generar_variante.py` preserva `material_index` en cada cara merged.
- [x] C10. `generar_variante.py` libera hijos antes de borrar padres (huérfanos).
- [x] C11. `generar_variante.py` bakéa los `SM_M_*` a `location=(0,0,0)`, `scale=(1,1,1)`.
- [x] C12. `generar_variante.py` aplica DECIMATE solo a mallas fundidas.
- [x] C13. `generar_variante.py` aplica DECIMATE por depsgraph, no por `bpy.ops` (E-22).
- [x] C14. `generar_variante.py` reasienta con `Z_APOYO = 0.045` (E-12).
- [x] C15. `generar_variante.py` guarda con `os.remove(ruta + '@')` previo (E-21).
- [x] C16. `generar_variante.py` constante `DECIMATE_RATIO = 0.7` (no 0.5, ver E-23).
- [x] C17. `generar_variante.py` constante `UMBRAL_PODA = 1e-4` calibrada sobre el cofre.
- [x] C18. `generar_variante.py` constante `CRITICAS_NO_FUNDIR = ()` por defecto (opt-in por asset).
- [x] C19. `generar_variante.py` constante `PROTEGIDAS` para piezas que nunca se podan.
- [x] C20. Crear `abrir_blend.py` para que `stats_asset` y `capturar_angulos` operen sobre el .blend correcto.
- [x] C21. Activar SSR + raytracing en `capturar_angulos.py` antes de `bpy.ops.render.render()` (E-20).
- [x] C22. `capturar_angulos.py` activa SSR en el script, no en el .blend (no contamina).
- [x] C23. El pipeline funciona con la sesión de Blender ya abierta vía socket MCP.
- [x] C24. Los scripts son idempotentes: re-ejecutables sin duplicar geometría.
- [x] C25. Los scripts no versionan outputs — se regeneran con un comando.

## D. Nomenclatura y convenciones (51–65)

- [x] D1. `.blend` source del asset actual: `cofre_ancestral_lowpoly.blend` (es la MEDIA source).
- [x] D2. `.blend` derivado MEDIA: `cofre_ancestral_lowpoly_media.blend` (NO versionado).
- [x] D3. `.blend` derivado BAJA: `cofre_ancestral_lowpoly_baja.blend` (NO versionado).
- [x] D4. `.blend` ALTA futuro: `cofre_ancestral_alta.blend` (versionado a mano, es hand-authored).
- [x] D5. Piezas: `SM_{Asset}_{Pieza}` (ej. `SM_Cofre_Cuerpo`).
- [x] D6. Piezas animadas: `SM_{Asset}_{Pieza}_NOFUNDIR` (no se mergean, para preservar animación).
- [x] D7. Mallas fundidas: `SM_{Asset}_M_{Materiales}` (ej. `SM_Cofre_M_Madera_Cofre`).
- [x] D8. Materiales: `MAT_{Material}_{Asset}` (ej. `MAT_Madera_Cofre`).
- [x] D9. Capturas de QA: `cap_{modulo}_{asset}_{perfil}_{HH-MM-SS}_az{NN}.png`.
- [x] D10. Rutas Godot: `res://assets/props/{asset_id}/{perfil}/{asset_id}_{perfil}.gltf`.
- [x] D11. Perfil en minúsculas en la ruta: `alta`, `media`, `baja`.
- [x] D12. Set de captura (`Base_Arena`, `SOL`, `Mundo`, `CAM_*`) nunca se exporta a Godot.
- [x] D13. Solo `SM_*` y `MAT_*` cruzan la frontera Blender → Godot.
- [x] D14. PROTEGIDAS por palabra clave en el nombre (lowercase compare).
- [x] D15. CRITICAS_NO_FUNDIR por substring (case-sensitive, más estricto, opt-in por asset).

## E. Piloto sobre el cofre ancestral (66–85)

- [x] E1. Source: `cofre_ancestral_lowpoly.blend` con 33 piezas (hand-authored).
- [x] E2. Generar MEDIA con `generar_variante.py --media`.
- [x] E3. MEDIA verificado: **6 obj / 784 tris / 6 mats** (cumple presupuesto MEDIA).
- [x] E4. Capturar 6 ángulos orbitales de MEDIA con SSR activo.
- [x] E5. Verificar MEDIA visualmente: idéntica al source, sin flotación (z_min 0.045).
- [x] E6. Generar BAJA con `generar_variante.py --baja`.
- [x] E7. BAJA verificado: **6 obj / 571 tris / 6 mats** (cumple presupuesto BAJA).
- [x] E8. Poda de BAJA elimina `SM_Cofre_Glifos` y `SM_Cofre_Tirador` (umbral 1e-4 m³).
- [x] E9. Capturar 6 ángulos orbitales de BAJA con SSR activo.
- [x] E10. Verificar BAJA visualmente: cerradura, gema, costillas, anillo y vetas preservados.
- [x] E11. Confirmar que las 3 variantes comparten `z_min` en 0.045 ± 0.000.
- [x] E12. Activar SSR en `capturar_angulos.py` (E-20 refinado, no se había hecho antes).
- [x] E13. Re-sacar source (asset actual) con SSR para comparar manzanas con manzanas.
- [x] E14. Confirmar que el SSR es lo que hace la diferencia visual entre source (con SSR) y capturas tempranas (sin SSR).
- [x] E15. Documentar que el azul claro de la `MAT_Madera_Cofre` es el color real bajo SSR + emisión.
- [x] E16. Iterar BAJA con críticas mergeadas (CRITICAS_NO_FUNDIR vacío): 6 obj / 571 tris.
- [x] E17. Comparar visualmente la BAJA con/sin críticas preservadas: ambas aceptables, pero merge sin críticas cumple el presupuesto.
- [x] E18. Decisión: dejar CRITICAS_NO_FUNDIR vacía por defecto. Override opt-in si un asset específico lo necesita.
- [x] E19. Documentar el contraste entre la versión inicial del módulo (críticas excluidas, 14 obj) y la corregida (críticas mergeadas, 6 obj).
- [x] E20. Documentar que el merge es lossless y excluir piezas cuesta draw calls innecesarios.

## F. Integración con Godot (86–95) — diseño, no implementación

- [x] F1. Diseñar el autoload `AssetProfile` (perfil, ruta, cargar, cambiar_perfil, debe_usar_multimesh).
- [x] F2. Tabla de detección de hardware (GPU tier + RAM + resolución) → perfil default.
- [x] F3. Regla MultiMesh obligatoria para > 10 instancias de la misma asset (vegetación).
- [x] F4. `ItemData` (M159) extendido con `modelo_id`, `usa_multimesh`, `variantes_disponibles`.
- [x] F5. Degradación graceful: si la variante pedida no existe, fallback a MEDIA → ALTA.
- [x] F6. Path en Godot: `res://assets/props/{asset_id}/{perfil}/{asset_id}_{perfil}.gltf`.
- [x] F7. Exportar a glTF: usar `bpy.ops.export_scene.gltf` con `export_keep_originals=True`.
- [x] F8. Exportar: limpiar la escena antes (solo `SM_*` + `MAT_*`).
- [x] F9. No exportar a glTF: `Base_Arena`, `SOL`, `Mundo`, `CAM_*`, `CAM_Orbital`.
- [x] F10. Plan: implementar el autoload DESPUÉS de tener 5+ assets con sus 3 variantes.

## G. Operación y mantenimiento (96–100)

- [x] G1. Workflow: `stats_asset (source) → generar_variante --media --baja → stats_asset por variante → capturar 6 ángulos por variante → comparar`.
- [x] G2. Si una variante rompe: NO versionar, regenerar desde source.
- [x] G3. Si una variante se desincroniza del source: regenerar, no editar a mano.
- [x] G4. Los logs de generación van en `Logs/{n}-M166-...-{YYYY-MM-DD}_{HH-MM-SS}.md`.
- [x] G5. El módulo M166 se considera cerrado tras 10 assets procesados con sus variantes MEDIA y BAJA aprobadas visualmente.

## H. Alcance de la pasada ALTA (101–112) · decisión D9 (2026-08-28 22:00)

- [x] H1. Definir que **NO todos** los assets reciben pasada ALTA (D9, §3.5 de `03-Diseno.md`).
- [x] H2. Criterio 1: si el jugador interactúa con el asset → ALTA.
- [x] H3. Criterio 2: si se sostiene en mano y se ve en primer plano → ALTA.
- [x] H4. Criterio 3: si es un hito visual de la isla → ALTA.
- [x] H5. Criterio 4: si se instancia por cientos (MultiMesh) → solo MEDIA.
- [x] H6. Criterio 5: si es decoración de fondo o se pisa → solo MEDIA.
- [x] H7. Argumento numérico documentado: palmera 700 → 4.000 tris × 300 instancias = 1,2 M tris.
- [x] H8. Clasificar los 41 assets: 15 héroes / 3 frontera / 23 relleno.
- [x] H9. Los 12 assets de `50-Vegetacion` quedan en MEDIA de forma permanente.
- [x] H10. Un asset sin ALTA se declara con `variantes_disponibles = ["media", "baja"]` (M159), no es un hueco.
- [x] H11. Ningún asset de relleno queda sin optimizar: los 23 tienen `_media` y `_baja` mergeadas (R9).
- [ ] H12. Ejecutar la pasada ALTA sobre los 15 héroes, de a un módulo por vez.

## Total: 112 ítems (111 cubiertos, 1 pendiente: la pasada ALTA de los 15 héroes).

## Nota del agente (2026-09-02, minimax-m3-free / Kilo Code)

> **M166 al 99.1% (111/112)**. El único item [?] pendiente es **H12 (ejecutar la pasada ALTA sobre los 15 heroes, de a un modulo por vez)**.
>
> **H12 requiere Blender + V5** (categoria visual): no es mi perfil segun guia 10 §6. Queda con dueno explicito **Hy4 (WorkBuddy)**.
>
> **Lo que verifique en esta iter (cierre):**
> - 4 scripts Python existen en 	ools/mcp/blender-mcp/scripts-reutilizables/: stats_asset.py, generar_variante.py, capturar_angulos.py, brir_blend.py. Test manual requiere Blender MCP corriendo (socket en puerto local).
> - Plan-actual firmado por minimax-m3-free (Kilo Code) en 5 archivos.
> - Items A1-A15, B1-B10, C1-C25, D1-D15, E1-E20, F1-F10, G1-G5, H1-H11 (111 items) **cubiertos por Hy4 en el diseno y en la implementacion previa de los scripts**.
>
> **Lo que NO hice (con honestidad):**
> - **H12**: requiere ejecutar generar_variante.py --alta sobre 15 assets en Blender. Esto es V5 (vision+Blender) — delegable a Hy4.
> - **Test headless Godot**: M166 es 100% scripts Python (Blender pipeline), no tiene codigo GDScript. No hay nada que testear con godot --headless.
> - **Re-corregir scripts Python**: iteraciones previas (Hy4) los dejaron funcionales segun el plan. No los modifique.
>
> **Estado:** 🟡 Liberado al 99.1%. Listo para QA cruzado (Hy3 en WorkBuddy). M166 completo salvo la pasada visual final.