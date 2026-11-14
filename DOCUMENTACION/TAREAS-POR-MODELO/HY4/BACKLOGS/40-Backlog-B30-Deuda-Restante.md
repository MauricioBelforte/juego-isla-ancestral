# Acta 40 — B30: toda la deuda ejecutable restante (2 guardias + fix `emisivo`)

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-14 06:35:00 -0300
**Canal:** mensaje **80** (acuse del director, con cifra equivocada), **81** (PRIMERA INSTANCIA + SEGUNDA INSTANCIA B30) y **82** (cierre con evidencia) · **Log:** **2420** · **Acta anterior:** 39
**Estado:** **EJECUTADO**. **0 GLB nuevos** (490 antes y después), **0 `.blend` modificados**, **1 guardia nueva (`114/114/0`)**, **1 test de regresión (`6/6/0`)**, **1 fix aditivo de infraestructura**, **1 fe de erratas**. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena.

> Cadena de actas: B26 mariposa (`36`), B27 auditoría COLA ACTIVA (`37`), B28 columna_entera GLB (`38`), B29 columna_rota blends (`39`), **B30 deuda restante (`40`)**.
> **Rótulo medido antes de publicar:** 0 `B30` en backlogs HY4, 0 `Logs/2420-*`, 0 `81-*`, 0 `82-*`, 0 `40-*`. Sin colisión. El **80 lo ocupa el director** → canal por `max(real)+1` (80 → 81 → 82); **pool de canal intacto**. Persisten dos `56-*`.
> Cuarto cierre consecutivo **sin GLB nuevos**.

---

## 1. Autorización y acuse 80

El **80** es seco: «Confirmo: B29 columna_rota M25 OK. Guardia **58/58/0**. Bien.» **Discrepancia de cifra publicada con cita**: B29 es **63/63/0** (`verificar_columna_rota_blends.py`, log 2419); **58/58/0** es B28 (`verificar_columna_entera_glb.py`, log 2414). Sin GO, sin TANDA, sin flips.

- Reloj: escrito `09:20`, *mtime* `06:15:50.042426` → **+3 h 4 m 10 s** (vuelve al patrón +3 h de 47/50/53, tras +20 h 56 m y +10 h 5x).
- **Aviso de discrepancia nº 69**: `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe es **agnes-3-flash**.

**Fuente de autorización**: el 80 no da TANDA. La SEGUNDA INSTANCIA sale de la **orden directa del fundador** «bueno trabaja en todo lo que falta terminar», aplicada a la deuda publicada con cita en 72/73, 75/76, 78/79 y logs 2412/2414/2419. Igual que en B25: se publica la fuente en vez de fingir un acuse inexistente.

---

## 2. Deuda cerrada

| # | deuda | hueco medido | cierre |
|---|---|---|---|
| 1 | Guardia `cultivo_brote` (Semillero M33) | 3 GLB trackeados, **0** `verificar*cultivo*` en todo el repo | guardia sobre el BIN |
| 2 | Guardia `palanca_madera` (M70) | 3 GLB trackeados, **0** `verificar*palanca*` en todo el repo | guardia sobre el BIN |
| 3 | `mat(emisivo=...)` | arrastrado 4 cierres como «bug latente de la plantilla» | **fe de erratas + fix + test** |

Ambos módulos están en `MODULOS` de `exportar_godot.py` (L70/L72) → sin riesgo E-63/T-02. Los 6 GLB están trackeados desde 2026-11-05 (logs 2320/233, acta 11, COBJ L182) pero **nunca se habían verificado por dentro**.

**Decisión de autoría**: **una guardia con dos perfiles** (`verificar_pendientes_M33_M70.py`, 6 bloques) en vez de dos archivos duplicando ~130 líneas de decoder glTF. Es el patrón de B27 (1 guardia / 6 GLB / 2 variantes / 114 checks). Cotas reutilizadas de la sonda B27 y **re-verificadas hoy**.

| asset | LOD | tris | mats | mallas | verts | apoyo | alt_max |
|---|---|---|---|---|---|---|---|
| `cultivo_brote` | ALTA | 152 | 3 | 4 | 252 | 13 | 0.1998 |
| | MEDIA | 152 | 3 | 3 | 252 | 13 | 0.1998 |
| | BAJA | 102 | 3 | 3 | 216 | 10 | 0.1979 |
| `palanca_madera` | ALTA | 516 | 3 | 1 | 1068 | 4 | 0.6155 |
| | MEDIA | 516 | 3 | 1 | 1068 | 4 | 0.6155 |
| | BAJA | 66 | 3 | 1 | 166 | 4 | 0.6155 |

---

## 3. Guardia `verificar_pendientes_M33_M70.py`

Autocontenida (stdlib, sin `bpy`). Decodifica POSITION real del BIN, aplica matrices COLUMN-MAJOR y convierte Y-up. **18 checks × 6 GLB + 6 globales = 114**: estructura glTF, POSITION legible, nodos, vértices, tris, n.º y nombres de materiales, mallas, `alt_min=0.045`, `alt_max`, rangos X/LATERAL, pares de apoyo (E-50), nodos `SM_` reales por LOD, niveles clave, silueta positiva (Hoja+Tallo/Tierra / brazo x>1.0 y altura>0.5) y LOD real. Globales por grupo: `alt_max` consistente, materiales idénticos y `tris BAJA < ALTA`.

`CHECKS_MINIMOS = 114` / `BLOQUES_MINIMOS = 6` fijados **después** de medir el PISO en VERDE con `--piso 0`.

| ruta | resultado |
|---|---|
| PISO `--piso 0` | `114/114/0` · 6 bloques · 6 globales · `RC=0` |
| VERDE default | `114/114/0` · PISO=114 · `RC=0` |
| ROJO `--inyectar` | `114/109/5` `RC=1` — 166 vértices +0.0133 m en altura; caen **C10/C11/C14/C16/G1** (`alt_min=0.0583`, `alt_max=0.6288`, apoyo=0). GLB publicado `sha=3d3f87a4cb5e` **intacto**; inyección sólo en `Temp/`. |
| CIEGO `--solo` | 18 checks · 1 bloque · 0 globales · `RC=3` |

---

## 4. Fe de erratas sobre B26 y fix de `emisivo`

**Rectificación de un hallazgo propio**: B26 (log 2410, acta 36, mensaje 70) publicó que `plantilla_asset.py::mat()` tenía un «BUG LATENTE» y lo arrastró como pendiente del director en B27–B29. La medición de B30 muestra que **la API está documentada y es correcta** (`emisivo = ((r,g,b), strength)`) y que **siete generadores** la usan bien (gema tallada ×3, carreta, faro, volcán…). El `TypeError` de B26 vino de que **Hy4 pasó un RGB plano** `(0.35, 0.30, 0.10)`: `(*emisivo[0], 1.0)` intentó desempaquetar un float. **Fue error de llamada mío, no bug ajeno.** No se reescriben textos publicados: se rectifica aquí, en el 81 y en el 82.

**Fix aditivo backward-compatible**: `_normalizar_emisivo()` acepta también el rgb plano como `(rgb, 1.0)` y da `TypeError` con mensaje claro para cualquier otra forma. Los 7 llamadores correctos **no cambian de resultado**.

**Test `test_mat_emisivo.py`** (Blender 4.2 headless, `--python-exit-code 1`), PISO medido en verde **6/6/0**: C1 API documentada intacta · C2 rgb plano tolerado · C3 sin emisivo no toca la emisión · C4 **6/6 pares reales** de llamadores · C5 la **línea literal anterior reproduce el `TypeError` real** · C6 plantilla publicada intacta + normalizador presente.

| ruta | resultado |
|---|---|
| VERDE | `6/6/0` `RC=0` |
| ROJO `--sin-fix` | `6/5/1` `RC=1` — «Value after * must be an iterable, not float» |
| CIEGO `--solo` | 1 check · `RC=3` |

El ROJO **no se simula**: ejecuta la línea literal de la versión anterior.

---

## 5. Trampa de medición nueva (publicada, no usada como cifra)

Un primer inventario de cobertura por **búsqueda de token literal** dio «163 GLB sin guardia / 119 en módulos HY4». Es **falso**: `verificar_pez_tropical.py` construye el nombre con `%s`, así que `pez_tropical_azul` tiene **0 hits** mientras `pez_tropical` tiene **8**. Medición corregida por nombre de archivo: **23 guardias reales** `verificar_*.py` y **13/13 presentes** en la cadena B18→B30. **No se publica la cifra de 119 como deuda**: sería inventada por un método roto.

---

## 6. Formatos, gate §28 y cierre

- Log **2420**: ASCII puro, **206 CRLF**, 0 LF/CR sueltos, sin BOM, **12/12 señales**. Pool `2420 → 2421`, **no commiteado**.
- Mensajes 81/82, acta 40, guardia, test y plantilla: UTF-8/LF/sin BOM, 0 CR sueltos, 0 `U+FFFD`. `py_compile RC=0`.
- Gate §28: **rojo en HEAD por BOM ajenos**, `RC=1`, **0 paths propios** en la lista roja. Reportado, sin tocar.
- **Commit selectivo de 7 paths**: guardia, test, `plantilla_asset.py`, log 2420, acta 40, mensajes 81 y 82. Sin `git add -A`, sin `--amend`, sin push. **0 GLB nuevos**, **0 `.blend` modificados**, **0 flips**.
- **No se versionan** el GLB inyectado del ROJO (`Temp/`, conservado) ni el mensaje **80** del director (ajeno, intacto para el fundador).
- **No se tocó**: `02`, `07`, `CHECKLIST-OBJETOS-BLENDER.md`, `36-Fauna/checklist.md`, `35-Mineria/checklist.md`, `AGENTS.md`, `quality.yml`, `CHECKLIST-GLOBAL.md`, `project.godot`, `exportar_godot.py`, `generar_variante.py`, `BACKLOG-MASTER.md` ni generadores de otros agentes.

---

## 7. Lo que queda (facultad exclusiva del director)

Hy4 cerró **todo lo ejecutable dentro de sus facultades**. Sin GO no puede:

1. **Definir la TANDA** (el 80 no la dio; posible cuarta vuelta con ítem ya cerrado).
2. **Flips con evidencia**: `02` L26/L27/L30/L38 · COBJ L50/L174/L175/L225 · `36-Fauna` L23–L27 · `35-Mineria` L10–L13 (**L13 = Carrito de vías**, Cangrejo es **L12**). Recounts sin cambios: `02` **29/6**, COBJ **163/6**, `36-Fauna` **16/5**, `35-Mineria` **3/4**, `07` **0/17**.
3. **Re-autorar la BAJA** de `columna_rota` con 0 *decimate* (deuda abierta de B29: 4.18 cm, 34/42 vértices fuera de plano): cambiaría 6 GLB ya ratificados → requiere GO de export, y C10 de B29 debe bajar a 0.
4. Naming `mariposa_lunar` · dueño de «Pez capturable» · B26-bis (contrato bimodo) · gate §28.

**Las 2 guardias que faltaban ya no faltan.** No se toma hueco nuevo sin nueva PRIMERA/SEGUNDA INSTANCIA.
