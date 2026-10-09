# Log 1529: Script verificar_backlogs.py — estandarizacion del metodo LOTE 12

**Fecha:** 2026-10-09
**Hora:** 16:56
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen
Se creo `scripts/verificar_backlogs.py`, que estandariza el metodo de
sincronizacion backlog<->checklist aplicado a mano en el LOTE 12. El script es
READ-ONLY por diseno y reproduce y amplifica los hallazgos del lote.

## Cambios Realizados

### Script nuevo: `scripts/verificar_backlogs.py` (~400 lineas, Python 3)

Cuatro detectores sobre cada `BACKLOG-MASTER.md` de
`DOCUMENTACION/TAREAS-POR-MODELO/`:

1. **Cierres afirmados con delta**: items `[x]` que afirman un conteo de modulo
   se contrastan contra el conteo real del `plan-actual/05-Checklist.md`.
   Parser **posicional**: cada conteo se asocia al modulo citado mas cercano a
   su izquierda (las lineas resumen citan varios modulos). Clasifica
   RETROCESO vs avance posterior. Umbral configurable (`--umbral N`, default 5)
   para descartar ruido de pocos items.
2. **Drift inverso**: items `[ ]` del backlog que ya estan `[x]` en el modulo
   citado = trabajo que el agente podria REPETIR. Clave: los items no siempre
   citan el modulo (lo heredan del **encabezado de su seccion**), asi que se
   mantiene tracking de seccion: el ultimo encabezado que cita exactamente un
   modulo presta ese id a sus items.
3. **Marcas `[->]` EN CURSO colgadas**: detecta el patron de `[x]` duplicado
   mas abajo en vez de cerrar el original in-situ.
4. **Modulos inexistentes**: referencias a IDs sin carpeta en `DOCUMENTACION/`.

Soporta los dos formatos de backlog de la flota: marcas en items de lista
(agnes/mimo/DeepSeek) y marcas en el TITULO del encabezado
(`### L-09 - M108 - [x] CERRADO`, atria-dawn-s3).

Flags: `--dry-run` (sin efecto, el script no escribe), `--modelo X` (repetible),
`--json`, `--solo-alertas`, `--umbral N`.

Codigos de salida: 0 limpio / 1 alertas materiales / 3 DETECTOR CIEGO (no se
pudo leer la fuente de verdad). Salida forzada a UTF-8 en Windows.

### Bugs encontrados y corregidos durante el desarrollo (3 iteraciones)

- **Drift inverso = 0 en la primera corrida**: los items `[ ]` de DeepSeek
  estan bajo `### 62-Memoria` sin repetir el ID. Fix: tracking de seccion.
- **33 falsos "modulos inexistentes"**: el regex de `M\d+` matcheaba los IDs de
  TAREA del protocolo (`T-M0`, `T-M1`) y el padding de carpetas (`04-` vs `M4`)
  rompia la comparacion. Fixes: lookbehind `(?<![\w-])` + canonizacion de id
  (`int()`).
- **318 cierres con ruido**: una linea que cita 3 modulos con 3 conteos cruzaba
  cada modulo con cualquier conteo. Fixes: parser posicional + solo items (no
  encabezados) + umbral 5. Resultado final: **149**.

## Resultados de la corrida (22 modelos con backlog)

- Cierres afirmados con delta material: **149**
- **DRIFT INVERSO (trabajo ya hecho): 100** — 96 concentrados en kimi-k3
  (backlog inactivo = copia vieja de checklists ya completados; informativo, no
  actionable)
- Modulos inexistentes citados: **0**

### Validacion cruzada contra mi informe manual del LOTE 12
- mimo-v2.6-flash-free: **drift 0** — confirma que es la referencia de la flota.
- DeepSeek-V4.1-Flash: **drift 0 hoy** — los 15 items de M62 que reporte en el
  msg 169 **ya no existen**: el director aviso a DeepSeek (msg 170) y este
  actualizo su backlog (la seccion "62-Memoria (52 pendientes)" se reemplazo
  por la tabla de encargos T-D9). El script refleja estado actual, no es un
  bug.
- agnes-3-flash: reproduce los 3 obsoletos (drift inverso).
- atria-dawn-s3: reproduce los `[->]` acumulados sin cerrar in-situ.

### Hallazgos NUEVOS del script (no cubiertos por mi analisis manual)
Retrocesos = flips posteriores a un cierre afirmado (delta positivo):
- Hy3 L756 **M146**: afirma 209 [x] vs real 100/0/0 (**+109**)
- Hy3 L865 **M63**: afirma 143 vs real 67/7/27 (**+76**)
- kimi-k3 L234 **M70**: afirma 155 vs real 77/121/0 (**+78**)
- Hy3 L743 **M62**: afirma 179 vs real 113/37/0 (**+66**)
- Hy3 L555 **M57**: afirma 98 vs real 91/27/1 (**+7**)

Hy3 es un agente **activo**; los retrocesos de M146/M63/M62 merecen revision.

## Archivos Modificados/Creados
- `scripts/verificar_backlogs.py` — NUEVO (script de verificacion read-only)
- `Logs/1529-...md` — este log
- `Mensajes entre modelos/atria-dawn-s2/171-...md` — informe al director
- `Logs/NUMEROS_DISPONIBLES.txt` — 1529 consumido
- `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` — 171 consumido
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/BACKLOG-MASTER.md` — tarea
  del script registrada
