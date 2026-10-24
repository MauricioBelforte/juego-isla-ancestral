# Log 2162 - M01 - Clasificacion de los pendientes del indice maestro (iteracion 9)

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Modulo:** 01-Fundamentos-Del-Proyecto (M01)
**Fecha:** 2026-10-23 22:04:12
**Tarea de origen:** COLA ACTIVA, tarea 2 - "M01 b1: resolver bloque dependencias/documentales factibles headless"
**Mensaje al director:** 378
**Marcas:** 0 flips / 0 commits / 0 push

---

## 1. Entrada y decision de rama

El tracker estaba en 375. En el canal aparecio el mensaje 377 del director
(`377-2026-10-23_21-03-13-glm-5-3-flash-director-a-deepseek-iter8-aplicada-proxima-tanda-42-inconsistencias.md`),
pero su cuerpo es literalmente `<cuerpo del mensaje aca>`: **288 bytes de plantilla sin
rellenar**. No hay directiva ejecutable.

Precedente medido en HEAD: el commit `335ca27` marca el mensaje 360 de Hy3 como
**T-19 "mensaje caido"** por el mismo sintoma ("plantilla vacia tras 3 horas, 2do drop de
su escritor"). Se aplico el mismo criterio: **no se inventa contenido** a partir del nombre
del archivo (que menciona "42 inconsistencias", cifra que no coincide con ninguna medicion
de hoy) y se trabaja la cola (RAMA 2). La anomalia se reporta para que el director reenvie.

## 2. Medicion inicial (antes de escribir cualquier cifra)

Indice maestro `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/05-Checklist.md`,
contado por prefijo `^\s*-\s*\[([ x?])\]`: **29 [x] / 123 [ ] / 0 [?] = 152**.

Cuadre con la vuelta anterior: la iteracion 8 midio 26, propuso 6 candidatos
(M05, M18, M21, M89, M99, M113) y marco 3 stale (M31, M77, M112). El director aplico los 6
y revirtio los 3 -> 26 + 6 - 3 = 29. Verificado linea por linea (L30/L49/L52/L147/L157/L174
con `FLIP iter.8`; L65/L132/L173 con `REVERT iter.8`).

Conclusion: de los 6 candidatos de la iteracion 8 no queda ninguno; repetir ese metodo daria
0. La tarea 2 pide clasificar los 123 `[ ]`, que es lo que faltaba.

## 3. Implementacion

Se **extendio** `scripts/auditar_indice_m01.py` con el modo `--pendientes` en lugar de crear
otra herramienta (una nueva habria duplicado el mapeo M## -> carpeta {##+1}, la lectura del
GLOBAL y las guardas de ceguera).

Criterio heredado de las iteraciones 6/7, sin inventar otro: resoluble = checklist propia
cerrada (0 `[ ]` y 0 `[?]`, total > 0) **y** fila del GLOBAL en `OK`.

Cinco categorias mutuamente excluyentes, evaluadas en este orden:
`sin_checklist` -> `resoluble_headless` -> `bloqueado_global` -> `bloqueado_checklist`
-> `bloqueado_ambos`. Se agrega la lista de "casi cerradas" (abiertos <= 5).

## 4. Resultado medido (123 pendientes)

| Categoria | Items |
|---|---|
| resoluble_headless | 3 |
| bloqueado_global | 9 |
| bloqueado_checklist | 4 |
| bloqueado_ambos | 107 |
| sin_checklist | 0 |
| **Total** | **123** |

**Resolubles hoy (propuesta de flip, NO aplicada):**
- M69 -> `70-Interacciones`, checklist 198/0/0, GLOBAL `OK` 198/198
- M98 -> `99-Marketing`, checklist 169/0/0, GLOBAL `OK` 169/169
- M117 -> `118-CI-CD`, checklist 113/0/0, GLOBAL `OK` 113/113
  (cautela: es el modulo con CI rojo en HEAD; decision del director si eso invalida el `OK`)

**9 bloqueados por la FILA** (modulo cerrado, fila no en `OK`): M04, M35, M94, M118, M125,
M141, M142, M149, M152. Se destraban corrigiendo la celda estado/progreso de su fila, no el
modulo. Dos con la fila atrasada: M35 (228/228 vs fila 227/228) y M152 (130/130 vs 123/130).

**4 con la fila `OK` sobre-afirmada**: M08 (106/9/0), M111 (228/4/0), M122 (106/2/0),
M143 (104/2/0). No son flipeables (tienen `[?]`) y la fila afirma lo contrario.

**36 casi cerradas** (abiertos <= 5): 12 con 1, 10 con 2, 7 con 3, 3 con 4, 4 con 5.
Son la cola de candidatos futuros cuando su duenio cierre.

## 5. Hallazgos

**(a) EOL mixto en `05-Checklist.md` de M01 (no tocado).**
HEAD: 275 LF, 0 CRLF (LF puro). Worktree: 267 CRLF + 9 LF (mixto). Las 9 lineas LF son
exactamente las 9 que edito el director (6 flips + 3 reverts). `git diff` crudo = 276/275;
con `--ignore-cr-at-eol` = 10/9 (ese es el cambio real). `git ls-files --eol` = `i/lf w/-text`.
Riesgo: si se commitea asi, el archivo queda mixto en HEAD y todo diff futuro de M01 aparece
como reescritura total. Recomendacion: normalizar a LF antes de commitear. NO aplicado:
`05-Checklist.md` de modulo no se toca sin orden. Es el unico archivo trackeado del worktree
con EOL mixto (medido sobre los 10 cambios pendientes).

**(b) Las 4 filas sobre-afirmadas no son un hallazgo aislado.** Coinciden exactamente con 4
de las 39 inconsistencias que reporta `scripts/verificar_checklist.py` hoy, con el texto
"tiene N items [?] pero su estado global es OK". Dos caminos independientes miden el mismo
defecto.

**(c) Verificador hoy:** EXIT 1, **48 alertas** = 39 inconsistencias + 1 cobertura
(`157-Medios-De-Transporte` sin checklist -> fila stale) + 8 bloqueos colgados. La alerta de
M107 que reporte en el mensaje 376 (`GLOBAL 174/182` vs checklist `177/182`) **ya no
aparece**: el director corrigio esa fila. No se atribuye el resto del delta: no hay desglose
comparable del reporte anterior.

## 6. Guardas y pruebas

`scripts/test_auditar_indice_m01.py`: **30 checks / 0 fallos / EXIT 0 x3**. Piso
`CHECKS_MINIMOS` re-**MEDIDO** 15 -> 30 (nunca estimado).

- **Prueba EN ROJO por inyeccion** (bloque J): en una copia del auditor se anula la rama
  `resoluble_headless` (`if r["candidato"]:` -> `if False:`) y el informe pasa a
  `[0] resoluble_headless`; la asercion de la suite es por tanto falsificable. Restauracion
  byte-exacta verificada por sha256.
- **Sonda de piso separada**: 30 -> 99 produce `[FALLO] solo 30 checks ejecutados (minimo 99)`
  y EXIT 1. Restaurado y re-verificado verde.
- **Control negativo**: un item `[x]` nunca entra en la clasificacion de pendientes.

## 7. Limites

- 0 flips aplicados. 0 commits / 0 push.
- No se toco `CHECKLIST-GLOBAL.md`, ni el `05-Checklist.md` de M01, ni ningun bloque `Totales`.
- El informe **no** clasifica los 107 `bloqueado_ambos` por tipo de dependencia (asset,
  hardware, cuenta externa, decision del fundador): exige leer 107 checklists y no era
  necesario para destrabar lo factible. Queda como tarea siguiente si el director la pide.

## 8. Artefactos

- `scripts/auditar_indice_m01.py` (modificado: +`--pendientes`, `CATEGORIAS`, `categoria_de`,
  `abiertos_de`, `clasificar_pendientes`, `informe_pendientes`; ASCII puro, LF, sin BOM)
- `scripts/test_auditar_indice_m01.py` (modificado: bloques I y J, piso 15 -> 30)
- `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/09-Clasificacion-Pendientes.md`
  (NUEVO, 10.974 B, UTF-8 sin BOM, CRLF)

## 9. Reproduccion

```
python scripts/auditar_indice_m01.py --pendientes
python scripts/auditar_indice_m01.py --json
python scripts/test_auditar_indice_m01.py
```
