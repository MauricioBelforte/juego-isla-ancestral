**Modelo:** opencode/mimo-v2-pro-free
**Plataforma:** OpenCode
**Fecha:** 2026-09-10

---

# 07 — Set de Captura vs. Asset

## 7. Set de captura vs. Asset — qué viaja a Godot y qué no (2026-08-28, directiva del usuario)

> ⚠️ **Regla crítica para todos los agentes:** cada script de asset incluye elementos de **escenografía** (set de captura) que **NO son parte del asset**. Nunca los exportes, nunca los confundas con el modelo.

### 7.1 Qué es el "set de captura"

Los scripts de assets incluyen un mini-estudio de QA visual con estos elementos:

| Elemento | Nombre típico | Función | ¿Viaja a Godot? |
|---|---|---|---|
| Disco/plano de arena | `Base_Arena` | Piso de referencia: escala, sombra, encastre | ❌ NUNCA |
| Luz solar | `SOL` | Iluminación de estudio para la captura | ❌ NUNCA |
| Mundo (cielo) | `Mundo` | Fondo celeste de la captura | ❌ NUNCA |
| Cámara con nombre | `CAM_*` | Encuadre reproducible de capturas | ❌ NUNCA |

**Solo los objetos `SM_*` (y sus materiales `MAT_*` aplicados) son el asset real.**

### 7.2 Por qué existe el set

- **Escala:** el disco da referencia de tamaño contra los demás objetos (todas las bases usan el mismo radio ~2.2).
- **QA visual:** sol + mundo permiten ver sombras y colores reales en Material Preview (ver E-06).
- **Reproducibilidad:** la cámara nombrada permite que cualquier agente recapture con el mismo encuadre (§6.2).

### 7.3 Comparativa con el flujo profesional (contexto)

El flujo de un estudio profesional difiere en varios puntos; saberlo evita sobre-ingeniería:

| Etapa | Profesionales | Este proyecto | Nota |
|---|---|---|---|
| Referencia | Moodboards / concept art | Checklist maestro (§6.1) | Suficiente para assets lowpoly |
| Proporciones | Blockout contra el personaje/escena | Disco de referencia del set | Equivalente funcional |
| Geometría | Box modeling / sculpt + retopología | bmesh programático | Válido para lowpoly estilizado |
| Materiales | Texturas PBR pintadas (albedo/normal/roughness) | Colores planos `MAT_*` | Aceptable en estilo flat; migrar a texturas solo si el usuario lo pide |
| QA | Render/prueba en motor | Capturas estandarizadas + verificación en Godot | Ambos obligatorios |

### 7.4 Reglas concretas para el agente

1. **Al exportar a Godot (glTF/FBX):** exportar SOLO los `SM_*`, nunca `Base_Arena`, `SOL`, `Mundo` ni `CAM_*`.
2. **Al iterar un asset:** los cambios de forma/color van sobre el `SM_*`; el set de captura se copia igual de asset a asset (misma receta).
3. **No "mejorar" el set** (cambiar el disco, el sol, etc.) sin actualizar esta guía: la consistencia entre capturas de todos los módulos depende de que el set sea idéntico.
4. **El estilo lowpoly flat es una decisión de diseño vigente**, no una carencia: no agregar texturas PBR ni subdividir mallas sin directiva del usuario.
5. **Medir antes de apoyar:** ningún objeto se posiciona usando el espesor nominal de la pieza de abajo; se mide el bounding box real con `verificar_bounds.py` (E-09).
6. **Cobertura completa + asentado en base** (E-12, directiva del usuario 2026-08-28): todo asset que toque la arena tiene su autocorrección `Z_APOYO = 0.045` embebida en el script y su `z_min` de la pieza base ≤ 0.05 (verificable con `auditar_apoyos.py`). Las hojas/abanicos/discos de apoyo cubren TODA la planta horizontal del objeto, no un sector.
7. **Verificación multi-ángulo obligatoria** (E-13, directiva del usuario 2026-08-28: *"si es necesario girá la cámara y sacá captura, pero no deben flotar los objetos en la base"*): correr `capturar_angulos.py` y revisar TODAS las capturas resultantes. **Una sola captura frontal no alcanza para aprobar**. Si una sola muestra luz/aire entre el objeto y la base, corregir y volver a correr.
8. **Aplicar DECIMATE por depsgraph, no por `bpy.ops`** (E-22): `bpy.ops.object.modifier_apply` falla por socket. Patrón: `dg = bpy.context.evaluated_depsgraph_get(); me_eval = bpy.data.meshes.new_from_object(o.evaluated_get(dg)); o.data = me_eval; o.modifiers.clear()`.
9. **Decimate sobre mallas lowpoly: ratio 0.7 + proteger críticas** (E-23): 0.5 rompe cajas planas. Marcar como `_NOFUNDIR` o por matching de lista `CRITICAS_NO_FUNDIR` las piezas con detalle fino (costillas, cerraduras, gemas, ojos, asas, tiradores). Lista extensible por asset.
10. **Activar SSR en el script de captura, no en el .blend** (E-20): `escena.eevee.use_ssr = True; escena.eevee.use_ssr_refraction = True; escena.eevee.use_raytracing = True` antes de `bpy.ops.render.render()`. Así no se contamina el asset y todas las capturas quedan comparables.
11. **M166 — generar variantes antes de exportar** (módulo 166): una vez aprobado el ALTA, correr `generar_variante.py --media --baja` para obtener las 2 variantes derivadas. Las 3 son la única fuente de verdad; no se versionan a mano.
12. **R9 — el merge es obligatorio al aprobar, el source nunca se exporta** (M166 §3.4, directiva del usuario 2026-08-28): el `.blend` source con N objetos separados es el archivo de **autoría** (editable) y **nunca llega a Godot**. Solo se exportan `_media.blend` (merge lossless, ~6 draw calls) y `_baja.blend` (perfil bajo). No se "dejan objetos sin optimizar": el source no se envía. Verificable con `auditar_optimizacion.py`, que devuelve exit 1 si algún asset aprobado falta de mergear.
13. **Por qué el merge NO va dentro del script de creación** (M166 §3.4): (a) durante la iteración hay que mover piezas sueltas y una malla fusionada no lo permite; (b) si el algoritmo mejora (como el fix decimate 0.5→0.7 de E-23), se cambia una constante en un script en vez de 117; (c) el merge es idempotente y barato, se regenera con un comando.
14. **Set de captura para assets "de pared" (E-28)**: cuando un asset va montado sobre una superficie vertical (antorcha de pared, cartel colgante, dintel), el set de captura debe incluir un panel `Set_Pared` QUE TAMBIÉN ESTÉ ASENTADO EN LA ARENA. Fórmula: `Y_CENTER_PARED = offset_negativo` (más cerca del origen), `Z_CENTER_PARED = -0.05 + ALTO/2` (base enterrada 5 cm), y para piezas montadas `Y_CENTER_PLACA = (Y_CENTER_PARED + ESP_PARED/2) + ESP_PLACA/2` (cara trasera tangente a cara frontal). El panel de referencia pasa `auditar_apoyos.py` con `z_min ≤ 0.05` antes de aprobar. Si el `Set_Pared` flota, el operador ve "una placa cuadrada separada flotando en el aire" y el reporte puede confundir con un defecto del asset. Bug real: `antorcha_pared` v1.

---

**Cambios 2026-09-01 00:00 (M18 cerrado + E-62/E-63):** cierre administrativo del Tier E. Con Blender GUI abierto (socket UP) se desbloqueó E-56 y se derivaron las variantes de los 11 assets de `18-Casas`: MEDIA ≤6 obj/≤212 tris/≤6 mats y BAJA ≤6 obj/≤144 tris/≤4 mats, todas dentro de M166 §3.3. **Antes de derivar apareció E-62**: `generar_variante.py` re-asentaba incondicionalmente y hundía 2.6 m los techos; se agregó el umbral `UMBRAL_REASENTADO = 0.25`. Los techos conservan `z_min 2.6450` en las 3 variantes (sin salto de LOD, E-48). **Al exportar apareció E-63**: `18-Casas` no estaba en la whitelist `MODULOS` de `exportar_godot.py` y el export devolvió `{"exportados": 0}` sin warning; agregado + `--dry-run` incorporado como práctica obligatoria. Resultado: **33 GLB exportados** a `assets/3d/{alta,media,baja}/18-Casas_*.glb` y **33 `.import`** generados por Godot. **M18 = 100% cerrado** (autoría + auditoría + 6 capturas × 11 + visión + variantes + GLB + import). Hallazgo colateral: el backlog de M50 Vegetación decía 5 pendientes pero son **3 reales** — las líneas "Hongo luminoso" y "Flor de isla" figuraban como `- [ ]` siendo duplicados rancios de ítems ya hechos más abajo en la misma lista.

**Cambios 2026-09-01 05:00 (Tier F cerrado + E-64):** cierre del **Tier F — M50 Vegetación**. El backlog decía 5 pendientes pero 2 eran duplicados rancios, así que eran **3 reales**: `arbol_frutal` (15 obj/464 tris/4 mats, faldón cónico + 4 raíces horizontales + tronco 2.30 m + copa de 3 ico-esferas + 6 frutas), `musgo_roca` (9/204/4, cilindro bajo de 12 lados con jitter) y `raices_expuestas` (6/106/2, tocón + 5 raíces en abanico de 150°). Los 3 con `z_min 0.0450` y huella validada (E-50: ≥8 vértices tocando y footprint ≥0.30 m por eje). Los 3 auditados con `chk_asset.py`, 6 capturas orbitales c/u y aprobados por visión; variantes MEDIA/BAJA derivadas; **9 GLB exportados**. **Sobre el import:** primero se diagnosticó mal (E-64 a las 05:00) creyendo que el editor abierto bloqueaba el import. Verificado por archivos a las 12:20, **el import nunca estuvo bloqueado**: los 33 GLB de M18 entraron a las 21:02 y los 9 de M50 a las 21:16, con el editor abierto (PID 3672). El diagnóstico falso vino de E-65: el sidecar se llama `<asset>.glb.import`, así que el glob `*_<asset>.import` daba 0. Los `ERROR:` de `voxel.gdextension` son ruido benigno. **Estado real: 198 GLB / 198 `.import`, cobertura 100%, cero pendientes de import.** Deja temporales `~libvoxel...TMP` (11 archivos / 82 MB desde el 26-ago) que son basura no bloqueante.

**Última actualización:** 2026-09-02 04:55 — MiniMax-M3 · WorkBuddy AI · Windows (tarea #56 cerrada: **M35 carretilla_minero** + **M33 espantapajaros**). 15 SM_ cada uno, 243 GLB/`.import`/`.scn` en Godot (cobertura 100%). Nuevos módulos `35-Mineria/` y `33-Agricultura/` agregados a la whitelist `MODULOS` de `exportar_godot.py` (**E-63**). Además: lecciones de **rueda adelantada** (carretilla: para que el cilindro de la rueda no atraviese el frente inclinado de la batea) y de **sombrero copa+ala** (espantapájaros: dos cilindros separados leen como sombrero mejicano en lowpoly, más robusto que un mesh toroidal). **E-37 positivo** = la diferencia entre "poste con cajas" y "espantapájaros" son 3 señales: sombrero, cara con rasgos, paja asomando.)
**Cambios 04:35 (barrido visual ALTA completo, 52/52):** tras la auditoría E-24, lancé el barrido visual ALTA (52 assets) por bucle shell directo (`for b in $(find ...)` con `cut -d/ -f4`) — `qa_lote.py` espera `N_lowpoly_VARIANTE.blend` pero para ALTA la fuente ES `N_lowpoly.blend`. Duración 16m 27s, 0 fallidas. **52/52 APROBADAS** en los 6 azimuts (E-13). Único outlier numérico: `veta_hierro_lowpoly` `z_min 0.0275` — **NO bug**: la roca (SM_Veta_Roca) está en 0.0450 (toca=16, fp=2.3×2.0); los 5 cristales cuelgan en 0.027-0.149 (diseño decorativo). El grupo arrastra el `z_min=0.0275` por el cristal_3. **M166 visual sweep: 100% (52 BAJA + 52 MEDIA + 52 ALTA = 156/156).** Capturas especiales: `antorcha_pared` el set de pared (E-28) bloquea el asset en az 240/300 (esperado), `puerta_templo` se ve de canto en az 000/180 (esperado), `palmera` (4.66m) pierde el suelo en algunas azimuts por encuadre (no flota).
