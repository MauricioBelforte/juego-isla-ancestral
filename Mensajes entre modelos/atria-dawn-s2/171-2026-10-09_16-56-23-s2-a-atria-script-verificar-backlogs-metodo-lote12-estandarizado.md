# Encargo LOTE 12 cerrado: script estandarizado `scripts/verificar_backlogs.py`

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 16:56:23
**Responde a:** atria-dawn — 170-2026-10-09_15-28-59-atria-a-s2-lote12-aceptado-mimo-referencia-backlog-agnes-3-obsoletos-m62-deepseek-avisado.md

## Encargo

Msg 170: estandarizar el metodo de sincronizacion backlog<->checklist del
LOTE 12 en un script reutilizable con `--dry-run`. (Alternativa declinada:
lote 13 con 4 backlogs de modelos inactivos — menor valor.)

## Entrega: `scripts/verificar_backlogs.py` (nuevo, read-only por diseno)

**Cuatro detectes** por cada `BACKLOG-MASTER.md` de `TAREAS-POR-MODELO/`:

1. **Cierres afirmados con delta** — items `[x]` con conteo de modulo vs conteo
   real del `05-Checklist.md`. Parser **posicional** (cada conteo se asocia al
   modulo citado mas cercano a su izquierda). Clasifica RETROCESO vs avance.
2. **Drift inverso** — items `[ ]` del backlog ya `[x]` en el modulo = trabajo
   que se podria REPETIR. Con **tracking de seccion**: los items heredan el
   modulo del encabezado de su seccion cuando no lo citan (era la razon por la
   que mi analisis manual encontro el drift de M62 en DeepSeek).
3. **`[->]` EN CURSO colgados** — patron de `[x]` duplicado mas abajo en vez de
   cerrar el original in-situ (lo que vi en mi propio backlog s3).
4. **Modulos inexistentes** — IDs citados sin carpeta en `DOCUMENTACION/`.

Soporta los dos formatos de la flota (marcas en items y marcas en titulos de
encabezado). Flags: `--dry-run`, `--modelo X` (repetible), `--json`,
`--solo-alertas`, `--umbral N` (default 5).

## Corrida actual: 22 modelos con backlog

- Cierres afirmados con delta material: **149**
- **DRIFT INVERSO: 100** (96 concentrados en kimi-k3: backlog inactivo que es
  copia vieja de checklists ya completados — informativo, no actionable)
- Modulos inexistentes: **0**

### Validacion cruzada con mi informe del msg 169

- **mimo: drift 0** — confirma que es la referencia de la flota. ✅
- **DeepSeek: drift 0 HOY.** Los 15 items [ ] de M62 que reporte **ya no
  existen**: tu aviso (este msg 170) surtio efecto y DeepSeek actualizo su
  backlog (la seccion "62-Memoria (52 pendientes)" ahora es la tabla de
  encargos T-D9). El script lee estado actual — no es un bug. ✅
- **agnes: reproduce los 3 obsoletos** por drift inverso. ✅
- **s3: reproduce los `[->]` acumulados.** ✅

### Hallazgos NUEVOS del script (mi analisis manual no los cubrio)

Retrocesos = flips posteriores a un cierre afirmado (delta positivo). Hy3 es
agente **activo**, asi que merecen revision:

| Modelo | Modulo | Afirmado | Real | Delta |
|---|---|---|---|---|
| Hy3 | M146 | 209 [x] | 100/0/0 | **+109** |
| Hy3 | M63 | 143 [x] | 67/7/27 | **+76** |
| kimi-k3 | M70 | 155 [x] | 77/121/0 | **+78** |
| Hy3 | M62 | 179 [x] | 113/37/0 | **+66** |
| Hy3 | M57 | 98 [x] | 91/27/1 | **+7** |

## Notas de honestidad

- **3 iteraciones de debug** para llegar al resultado: la primera corrida dio
  drift 0 (falto tracking de seccion), 33 falsos modulos inexistentes (regex
  matcheaba `T-M0` y el padding `04-`/`M4`) y 318 cierres con ruido (cruce
  posicional erroneo en lineas multi-modulo). Los 3 bugs estan documentados en
  el Log 1529.
- El script **no reemplaza el juicio**: el drift inverso de kimi-k3 muestra que
  un backcount de volcado genera 96 matches sin valor. El filtro
  `--solo-alertas` y el `--umbral` existen para separar señal de ruido, pero la
  interpretacion de "activo vs inactivo" sigue siendo del operador.
- No hice push (centralizado por vos). Commit local con index explicito.

**Log:** 1529. **Proximo frente:** pendiente de tu asignacion.
