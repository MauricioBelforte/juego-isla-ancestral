# Log 1741 - M90 re-QA: linea base pre-fix medida + auditoria de la lista de fixes

**Modelo:** DeepSeek-V4.1-Flash (verificador, NO autor)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-12 04:13 (GMT-3)
**Modulo:** M90-Configuracion-Grafica
**Rol:** re-QA seccion 21.8 encargado por el director (mimo, msg 187). Estado: **BLOQUEADO en la entrega de stepfun**.
**Referencia:** mi QA previo (Log 1739, canal 186) + msg 187 del director.

---

## 0. Disparo

Mensaje **187** (mimo, 2026-10-12 04:09:56): "M90 QA ACEPTADA. Step 5 aplicara los fixes.
**Siguiente: M90 re-QA despues de fixes de Step 5.**" Tracker 185 -> 187.

El director, a su vez, mando la lista de fixes a stepfun en **su** msg 187 (04:09:55), un segundo
antes. Es decir: el pedido de fixes tiene ~3 minutos de antiguedad al momento de esta medicion.

## 1. AUDITORIA DE LA LISTA DE FIXES (contra mis hallazgos del Log 1739)

| # | Fix pedido por el director | Hallazgo mio que lo origina | Coincide |
|---|---|---|---|
| 1 | Revertir 11 flips a `[ ]` (distancia L82-84, vegetacion L97-100, agua L105-108) | 11 flips no sostenidos | SI |
| 2 | Cambiar 4 flips a `[?]` (efectos L90-93) | 4 flips parciales | SI |
| 3 | Actualizar linea `**Totales:**` | la linea estaba stale en 69/180 | SI |
| 4 | `CHECKS_MINIMOS` 46 -> 85 + assert de bloques | piso no protegia; sondas B/C dieron PASS | SI |
| 5 | Quitar 3 CJK de `graphics_config.gd` L8 | fuga de idioma (U+8BBE U+5B9A U+7684) | SI |
| 6 | Corregir cita de `aplicar()` (no existe) | encabezado cita una funcion inexistente | SI |

**Cobertura: 6 de 6 hallazgos con fix asignado.** La lista del director es completa respecto de mi
informe.

**Un hallazgo mio NO entro en la lista (menor):** `_clasificar_gpu()` L260 duplica la condicion
`g.contains("gtx 16")` dos veces (redundante, sin efecto funcional). No es bloqueante; lo dejo
anotado para el re-QA.

## 2. LINEA BASE PRE-FIX (medida, para el diff del re-QA)

Al momento de esta medicion (04:13), **0 de los 6 fixes estan aplicados**:

| Fix | Estado medido | Evidencia |
|---|---|---|
| 1+2 flips revertidos | **NO** | `05-Checklist.md` sigue en **107 [x] / 142 [ ] / 0 [?]** |
| 3 linea Totales | **NO** | sigue en 69/180 |
| 4 piso + assert de bloques | **NO** | `CHECKS_MINIMOS: int = 46`; sin `_bloques ==`/`>=` en la suite |
| 5 CJK | **NO** | 3 caracteres CJK siguen en `graphics_config.gd` |
| 6 cita de `aplicar()` | **NO** | `func aplicar(` no existe; la cita sigue en L8 |

**Tamanos identicos a los de mi QA previo:** `graphics_config.gd` = 13274 B,
`test_graphics_config.gd` = 10503 B (sin cambios de contenido).
sha256 actual (baseline): cfg `ecb8711b52514bfebb65bc2e60047b9d4a9b53ccc8beaa5e69afea4b278cd26e`,
suite `c48d232940e80425a159916546376aec17f0504396304904e0b40437f7b8ac4c`.

> Nota de mtime: los dos `.gd` figuran con mtime 04:06:47/04:06:55, posterior a mi QA (04:05).
> **El contenido es identico** (mismos tamanos y mismos marcadores), asi que atribuyo el mtime a
> la restauracion byte-exacta de mis propias sondas (Log 1739 seccion 7), no a una edicion ajena. Lo dejo
> escrito para que el re-QA no se confunda con un cambio inexistente.

## 3. POR QUE NO EJECUTO EL RE-QA AHORA

Un re-QA "despues de los fixes" sin fixes es un re-QA del MISMO estado: repetiria el Log 1739 y no
aportaria evidencia nueva. Ademas, stepfun todavia no reporto su entrega en su canal (su ultimo
mensaje propio es el 185, 04:04, y es de M72). **Espero su entrega.** Regla del proyecto: no actuar
sobre el nombre de un archivo ni adelantarse a una entrega pendiente.

## 4. QUE VOY A MEDIR EN EL RE-QA (protocolo ya fijado)

1. Los 6 fixes, uno por uno, contra esta linea base (conteo por PREFIJO de linea en el checklist).
2. Re-correr la suite y confirmar el conteo real (deberia quedar >= 85 si el piso nuevo es 85).
3. **Re-inyectar las 3 sondas** con el MISMO metodo del Log 1739 y esperar el resultado INVERTIDO:
   - Sonda A (mini -> maxi): debe seguir dando EXIT 1 con los 4 fallos nombrados.
   - Sonda B (omitir bloque AA/upscaling): debe pasar a **EXIT 1** (hoy da PASS).
   - Sonda C (omitir bloque calidad, 23 checks): debe pasar a **EXIT 1** (hoy da PASS).
   Si B o C siguen dando PASS, el fix del guardian es cosmetico y el veredicto sigue CON DUDAS.
4. Verificar `_bloques` assertado y, si el director lo pidio, que el resumen NOMBRE los faltantes.
5. Higiene: CJK 0 en el `.gd`, cita de `aplicar()` corregida, `gtx 16` duplicado.
6. Solo entonces, veredicto de sello (que decide el director, no yo).

## 5. LIMITES

- 0 archivos de M90 tocados en esta corrida (solo lectura + sha256).
- 0 flips. 0 commits / 0 push (a cargo de atria-dawn).
- 0 ediciones a `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`.
- **No me auto-sello.** Colisiones de pool AJENAS vigentes: 1290, 1468, 1547, 1559, 1585, 1645,
  1698, 1726.
- **Higiene del pool:** el head volvio a arrancar con **BOM UTF-8** (`EF BB BF` antes del 1741).

## 6. ARTEFACTOS

- Log **1741** (este archivo, ASCII puro, LF, sin BOM).
- Reporte canal **188** en `Mensajes entre modelos/DeepSeek-V4.1-Flash/`.
- Pool de logs: head medido justo antes = 1741; consumido 1741 (head -> 1742).
- Tracker `.ultima-revision-deepseek.txt`: 185 -> **187**.
