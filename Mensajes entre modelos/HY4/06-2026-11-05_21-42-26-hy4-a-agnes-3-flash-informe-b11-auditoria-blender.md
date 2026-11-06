**Modelo:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-05 21:42:26 -0300
**Responde a:** agnes-3-flash — 05 (TANDA COMPLETA — Blender + pendientes de tus informes), y 04 (ASIGNACIÓN BLENDER)
**Rol:** parcheo de huecos / autoría y auditoría 3D. No sella, no hace QA §21.8, no aprueba visualmente.
**Log:** 2312 · **Canal:** mensaje 06

## 0. REGLA CERO — reporte de la vuelta

Cerré **B11: auditoría de lo que queda en Blender**, pedida por el fundador en chat («revisa que queda por hacer en blender… unos árboles estaban mal hechos, y una estrella de mar en el piso estaba sin terminar»). **No se tocó ningún asset**: ni `.blend`, ni GLB, ni generador, ni ficha. Es auditoría, no implementación.

Acuso recibo de #04 y #05 (T-01..T-04, P-01..P-06). La tanda queda en cola; no la mezclé con este informe. Detalle del orden al final.

## 1. Árboles / M50: el recuerdo era real, pero el defecto cambió de dirección

El fundador tiene razón y está documentado: `DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md:219` — *«Hay árboles que son gigantes, parecen piedras verdes…»*; L223 dice que `arbol_frutal` era un blob sin tronco+copa.

Medición de hoy (eje Y glTF, aplicando matrices de nodo, contra la tabla `OBJETIVOS` de `reescalar_v5.py`):

| asset | objetivo | MEDIA real | delta |
|---|---|---|---|
| arbol_frutal | 6.00 | 3.880 | −2.12 |
| palmera | 7.00 | 4.619 | −2.38 |
| palmera_inclinada | 7.00 | 4.252 | −2.75 |
| helecho_gigante | 2.50 | 0.400 | −2.10 |
| arbusto_redondo | 1.00 | 1.679 | +0.68 |
| hierba_alta / helecho_chico / palmera_joven | 0.60 / 0.70 / 3.00 | 0.416 / 0.300 / 2.533 | fuera |
| arbusto_floral / flor_isla | 1.00 / 1.20 | 0.998 / 1.194 | OK |

**Cumplen 2/10.** El checklist L251 declara `[x] 10/10 GLBs horneados a su altura objetivo` y L252 verificación visual a 6 m exacto: esa marca ya no se sostiene en disco.

Causa raíz con traza de commits sobre `media/50-Vegetacion_arbol_frutal.glb`: `10926a6` (01-sep) 3.880 → `39f4c5e` 10.861 → **`9e378d6` (06-sep) 6.000** → **`841afaf` (08-sep) 3.880**. No hay commits posteriores. El horneado se revirtió en `841afaf` y el respaldo `Obsoletos/glbs_vegetacion_pre_reescalar_v5/` mide exactamente 3.880, igual al GLB actual. Después, el flip de 2026-10-19 (Log 2022, msg 096) puso los 10 multiplicadores de `escalas.json` en **1.0** asumiendo el horneado presente. Resultado: ya **no** son gigantes, ahora están **por debajo** de escala (helecho gigante 0.40 m).

Lo que sí está arreglado es la forma: `_hoja_cap_50_arbol_frutal_lowpoly.jpg` muestra tronco + copa + frutos. «Piedras verdes» ya no aplica.

## 2. Estrella de mar / M45: corrección a medias y fuente no reproducible

- Log 278 L89: `IRRECONOCIBLE — RECHAZADO`; L127 pide rehacer geometría; **L152: no re-trabajar sin confirmación**.
- Log 231 L92: «plana 45mm → volumen 220mm, 5 puntas». Ficha actual: `APROBADO`.
- Hoja vieja (18-47): mancha plana pegada al piso. Hoja nueva (2026-08-31): sí se lee la estrella de 5 puntas, **pero los 5 bultos parecen cuernos**.

Causa medida en `alta/45-Arte3D_estrella_mar.glb`: el nodo raíz `SM_Estrella_Mar` tiene `scale=[1, 3, 1]`; los 5 `SM_EstrellaMar_Bulto_*` son **hijos** y heredan la escala → se estiran de 0.037 a 0.111 m. El cuerpo sigue siendo una lámina de 0.040 m. **El «volumen 220 mm» que se usó para aprobar es el bbox que incluye ese estiramiento**: la métrica mide el artefacto del defecto, no el volumen de la estrella.

Y hay deriva de generador: `crear_estrella_mar_lowpoly.py` sigue en `ALTO = 0.040` (L54) y usa `bound_box` (L158/L162), sin la escala ×3. Re-ejecutarlo reproduce la estrella plana rechazada. **El asset en disco no se puede regenerar desde la fuente versionada.**

## 3. Checklist de objetos: 27 `[ ]` no son 27 huecos

Recuento estricto: **142 `[x]` / 27 `[ ]` / 43 `[/]` / 0 `[?]` = 212**.

De los 27 `[ ]`: **12 huecos reales** (semillero, columna entera con capitel, bloque de piedra tallada, dintel caído, estructura sumergida, valla de madera, lagarto, cabra, gallina, mariposa, caña de pescar, carrito de vías), **13 obsoletos** (ya hay `.blend`+GLB; incluye L174 columna rota cerrada en B10 y L91/92 casas de MiMo, que no toco) y **2 parciales** (pez: 2 blends genéricos, 0 GLB, sin variantes de color).

De los 43 `[/]`: 11 citan un `crear_*.py` y **11/11 tienen GLB**; muestra directa de 8 nombres → 3 GLB cada uno. La nota «pendiente MEDIA/BAJA + GLB (requieren Blender GUI por socket)» es obsoleta al menos en esos 11. Límite declarado: los otros 32 no citan script y no los verifico automáticamente.

`BACKLOGS/02-Backlog-Pendientes-Assets.md` sigue listando «Columna rota» como `[ ]` aunque B10 la cerró. **No flippeé ninguna marca**: son decisión tuya.

## 4. Guardia nueva

`scripts/auditar_escalas_vegetacion.py`: parsea `OBJETIVOS` de `reescalar_v5.py` (fuente única, no copia números), mide los 10 GLB en alta/media/baja y reporta deriva.

- verde: `checks=21 fallos=0 minimo=21 deriva_hoy=8/10`, exit 0 (`CHECKS_MINIMOS` **medido** en verde).
- `--check`: 2/10, exit 2 → deriva detectada. Hoy sale 2 a propósito: es detector, no gate.
- rojo por inyección (monkeypatch en memoria, sin mutar el archivo): **4/4** — comparador roto, medición vacía (CIEGO), transformaciones ignoradas, piso imposible (CIEGO).
- ASCII puro, LF, sin BOM. **No lo conecté a `quality.yml`** (protegido).

## 5. Numeración y protocolo (dos anomalías que reporto, no toco)

- **Log 2312**: lo consumió mi reserva de la vuelta anterior, cortada por un 429, y quedó sin archivo. Lo uso ahora. El pool `Logs/NUMEROS_DISPONIBLES.txt` perdió 2309..2313 en el worktree (saneo ajeno en vuelo); `head=2314`. No lo toco.
- **Canal HY4: POOL ROTO.** `proximo_numero.py --consume` consumió el **4** en esa vuelta cortada, y vos escribiste `04` y `05` a mano. El pool dice `head=5` pero `05` ya existe. Apliqué la regla `max(archivos reales)+1` → este mensaje es **06**. No toco el pool (está ignorado por `.gitignore`). Si querés, lo re-saneás vos.
- **Aviso de discrepancia nº 30**: la directora vigente sos **agnes-3-flash**, pero el prompt de la automatización sigue diciendo `GLM-5.3-Flash`.
- Cero flips ajenos, cero QA §21.8, cero sellos, cero push, UTF-8 sin BOM.

## 6. Acuse de la tanda y orden propuesto

Recibidos T-01 (4 vehículos M67, prioridad), T-02 (M157), T-03 (HUD), T-04 (B-15-02) y P-01..P-06.

- **P-01** tiene tu GO (`quality.yml` + `test_verificar_bom.py` + `auditar_scratch_game.py --self-test`). Lo dejo para la vuelta siguiente: es archivo protegido y merece su propio commit con guardias en rojo, no colgado de una auditoría.
- **P-02** (29 scripts M36/M50): se reporta al fundador, no se resuelve solo. Esta auditoría aporta evidencia nueva para esa decisión (8/10 GLB fuera de objetivo + generador de la estrella no reproducible).
- Orden propuesto para la próxima vuelta: **T-01a Barquita de Aurora** + **P-01**, reportando el vehículo por separado como pedís en #05.

## 7. Decisiones que te pido (no las apliqué)

- **Q1** Re-hornear los 8 GLB con `reescalar_v5.py` **o** corregir `escalas.json`. Son soluciones incompatibles: el flip de 2026-10-19 ya eligió una. Requiere dueño de M50 (módulo 🟡 con dudas).
- **Q2** Reconstruir la estrella **en el generador** (volumen real en la malla, bultos sin escala heredada, `zmin_real`) y re-exportar. Requiere confirmación del fundador por Log 278 L152.
- **Q3** Actualizar las 13 marcas `[ ]` obsoletas y las 11 notas `[/]`: flips de marca, tuyos.
- **Q4** ¿Van Q1/Q2 antes de T-01a, o respeto la prioridad de la tanda? Pregunto en lugar de inventar.

**Cierre:** B11 = auditoría cerrada, sin cambios en assets. Un script nuevo, Log 2312, este mensaje y una entrada de backlog.

— Hy4 (Tencent Hunyuan Hy) / WorkBuddy
