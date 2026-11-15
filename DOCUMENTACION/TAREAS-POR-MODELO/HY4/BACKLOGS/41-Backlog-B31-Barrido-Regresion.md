# Acta 41 — B31: barrido de regresión de todas las guardias

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-15 00:45:00 -0300
**Canal:** mensaje **83** (acuse de cierre del director), **84** (PRIMERA INSTANCIA + SEGUNDA INSTANCIA B31) y **85** (cierre con evidencia) · **Log:** **2421** · **Acta anterior:** 40
**Estado:** **EJECUTADO**. **Verificación pura**. **0 GLB nuevos** (490 antes y después), **0 `.blend` modificados**, **0 archivos de código modificados**, **0 flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena.

> Cadena de actas: B27 auditoría COLA ACTIVA (`37`), B28 columna_entera GLB (`38`), B29 columna_rota blends (`39`), B30 deuda restante (`40`), **B31 barrido de regresión (`41`)**.
> **Rótulo medido antes de publicar:** 0 `B31` en backlogs HY4, 0 `Logs/2421-*`, 0 `84-*`, 0 `85-*`, 0 `41-*`. Sin colisión. Canal por `max(real)+1` (83 → 84 → 85); **pool de canal intacto**. Persisten dos `56-*`.
> Quinto cierre consecutivo **sin GLB nuevos**.

---

## 1. Acuse 83 y fuente de autorización

El **83** es un acuse de cierre: «B30 deuda ejecutable: CERRADO. 0 GLB nuevos, 0 cambios. Bien. **Correccion 80:** Tienes razon, cite 58/58/0 (B28) en vez de 63/63/0 (B29). Corregido. Gracias.». La directora **acepta la corrección de cifra** publicada en 81/82. Sin TANDA nueva, sin GO, sin flips. Reloj: escrito `09:50`, *mtime* `06:45:44.878165` → **+3 h 4 m 16 s** (mismo patrón del 80).

El 83 **no da TANDA** → la SEGUNDA INSTANCIA sale de la **orden directa del fundador** («segui»), igual que B25 y B30: se publica la fuente en vez de fingir un acuse inexistente. **Aviso de discrepancia nº 70**: `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe es **agnes-3-flash**.

**Estado vivo**: HEAD `2fc15c9` (fundador, 00:34:15, 47 paths / 6 202 inserciones), worktree **limpio** (0 sucias, 0 staged), 490 GLB, pool 2421, canal max 83. Verificado que `git show 2fc15c9 -- plantilla_asset.py` es **vacío** y `_normalizar_emisivo` sigue presente: **el fix de B30 sobrevivió a la preservación**.

## 2. Fe de erratas (por commit ajeno)

En log 2420 / acta 40 / mensaje 82 publiqué que el scratch de `Temp/` quedaba **«sin versionar»**. El fundador lo absorbió en `2fc15c9`:

```
Temp/hy4_b29_blends_probe_20261114.{json,py,txt}
Temp/hy4_b30_rojo_20261114.glb
```

También versionó los acuses **80/83** y un script ajeno nuevo `scripts-reutilizables/auditar_glb_490.py`. Esa afirmación quedó **desactualizada por un commit ajeno** (caso ya documentado en B22). **No se reescriben textos publicados**: se rectifica aquí. El scratch sigue en disco, ahora trackeado.

---

## 3. Barrido (`Temp/hy4_b31_barrido_20261115.py`)

25 scripts: **23** `verificar_*.py` + `test_mat_emisivo.py` + la herramienta **ajena** `auditar_glb_490.py`. Detección automática de intérprete (Blender si importa `bpy`, si no Python). Clasificación por **RC y evidencia publicada**; la categoría clave es **`SIN_EVIDENCIA`**: RC=0 sin `CHECKS=` ni `VERDE:` sería una **guardia muerta y verde** (0 fallos porque las aserciones nunca corrieron). Un RC=0 sin checks **no se cuenta como verde**.

**Barrido crudo**: `VERDE=21 · ROJO=3 · CIEGO=1 · SIN_EVIDENCIA=0 · TOTAL=25`.

### Clasificación corregida (diagnóstico por salida completa)

El barrido por RC era **insuficiente**. Cada caso no verde se diagnosticó antes de publicar (`Temp/hy4_b31_clasificacion_corregida_20261115.json`):

| script | barrido | causa real | corregido |
|---|---|---|---|
| `verificar_casa_vecino.py` | CIEGO | **Exige 3 GLB por argv**. Sin args da CIEGO por diseño; con Blender sin args toma `-b` como ruta → 36 fallos espurios «archivo ausente: -b». Con sus 3 GLB: **36/36/0 VERDE**. Fue **error de invocación mío**. | **VERDE** |
| `verificar_bounds.py` | ROJO | `ConnectionRefusedError [WinError 10061]` en `bpy_cliente.py:26` → requiere socket MCP 9876 | NO_APLICA_ENTORNO |
| `verificar_ojos_coco.py` | ROJO | mismo socket MCP 9876 | NO_APLICA_ENTORNO |
| `verificar_visual.py` | ROJO | `ModuleNotFoundError: No module named 'PIL'` en el Python de Blender | NO_APLICA_ENTORNO |

**Corregido**: `VERDE=22 · NO_APLICA_ENTORNO=3 · HERRAMIENTA=1 · ROJO_REAL=0 · CIEGO_REAL=0 · SIN_EVIDENCIA=0`.

### Resultado principal

**0 guardias muertas y verdes.** Las **22 guardias autónomas publican `CHECKS=` y dan VERDE**; **0 regresiones** tras el fix de `plantilla_asset.py` y la preservación de 47 paths. Verde medido, entre otros: `columna_rota` 114/114/0 · `columna_rota_blends` 63/63/0 · `columna_entera_glb` 58/58/0 · `pez_tropical` 114/114/0 · `pendientes_M33_M70` 114/114/0 · `valla_madera` 100/100/0 · `casa_vecino` 36/36/0 · `test_mat_emisivo` 6/6/0.

---

## 4. Auditor ajeno: los 43 «FUERA» son falsos positivos

`auditar_glb_490.py` (ajeno, absorbido en `2fc15c9`) **sólo se ejecutó**, no se modificó. Mide `z_min` exacto de los 490 GLB: **447 dentro** de `Z_APOYO 0.045 ± 0.020`, **43 FUERA**, 0 errores, `numpy=NO`.

El criterio E-12 / `Z_APOYO` **sólo aplica a props que se apoyan en el suelo**. Los 43 tienen `z_min` deliberadamente distinto: techos montados `2.6450` (6), decoración de pared `0.52–0.59` (7), vuelo/vestimenta `0.115–0.235` (4), piezas NPC ensamblables `-0.02…-0.17` (10) y vegetación con origen en `0.0000` (16). **Publicar «43 GLB defectuosos» sería una cifra falsa por criterio no aplicable** — misma familia que el inventario por token literal de B30.

**Observación para el director** (no deuda de HY4, no se toca sin GO): `36-Fauna_conejo.glb` MEDIA `zmin=-0.1700` mientras ALTA `zmin=0.0000` → posible deriva entre LOD de un asset **ajeno** (M36 legado, fuera de la cadena B18–B30).

---

## 5. Formatos, gate §28 y cierre

- Log **2421**: ASCII puro, **179 CRLF**, 0 LF/CR sueltos, sin BOM, **10/10 señales**. Pool `2421 → 2422`, **no commiteado**.
- Mensajes 84/85, acta 41, script de barrido y JSON corregido: UTF-8/LF/sin BOM, 0 CR sueltos, 0 `U+FFFD`. `py_compile RC=0`.
- Gate §28: **rojo en HEAD por BOM ajenos**, `RC=1`, **0 paths propios** en la lista roja. Reportado, sin tocar.
- **Commit selectivo de 4 paths**: log 2421, acta 41, mensajes 84 y 85. Sin `git add -A`, sin `--amend`, sin push. **0 GLB nuevos**, **0 `.blend` modificados**, **0 archivos de código modificados**, **0 flips**.
- **No se versiona** el scratch de `Temp/` (barrido `.py/.json/.txt`, `_run.txt`, clasificación corregida). **Advertencia publicada**: si el fundador lo absorbe, como hizo con B29/B30, la afirmación «sin versionar» quedará desactualizada por un commit ajeno y se rectificará igual que aquí y en B22.
- **No se tocó** `auditar_glb_490.py` ni las 3 herramientas `NO_APLICA` (sólo ejecutadas), `plantilla_asset.py`, `AGENTS.md`, `quality.yml`, `CHECKLIST-GLOBAL.md`, `project.godot`, checklists ajenos ni `exportar_godot.py`.

---

## 6. Lo que queda (facultad exclusiva del director)

B31 cerró el último trabajo verificable dentro de las facultades de HY4. Sin GO no puede:

1. **Definir una TANDA nueva** (el 83 no la dio).
2. **Flips con evidencia**: `02` L26/L27/L30/L38 · COBJ L50/L174/L175/L225 · `36-Fauna` L23–L27 · `35-Mineria` L10–L13 (**L13 = Carrito de vías**, Cangrejo es **L12**). Recounts **sin cambios**: `02` 29/6 · COBJ 163/6 · `36-Fauna` 16/5 · `35-Mineria` 3/4 · `07` 0/17.
3. **Re-autorar la BAJA** de `columna_rota` con 0 *decimate* (deuda B29: 4.18 cm, 34/42 vértices fuera de plano; requiere GO de export y C10 de B29 debe bajar a 0).
4. Naming `mariposa_lunar` · dueño de «Pez capturable» · B26-bis · gate §28 · observación del conejo M36.
5. Habilitar el socket MCP 9876 o instalar `PIL` si quiere que las 3 herramientas `NO_APLICA` pasen a ser ejecutables en headless.

No se toma hueco nuevo sin nueva PRIMERA/SEGUNDA INSTANCIA.
