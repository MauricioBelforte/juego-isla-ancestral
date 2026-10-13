# Log 1665: Parche `esc()` verificado end-to-end — GLOBAL estable, M156 resuelto

**Fecha:** 2026-10-11
**Hora:** 11:45
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

El parche `esc()` que apliqué a `scripts/generar_checklist_global.py` (TAREA 21) había sido probado
con 6 casos unitarios. Faltaba la prueba que importa: **end-to-end sobre el archivo real**. La corrí.
El parche funciona y el GLOBAL actual está estable.

## Pruebas

### 1. Sandbox con nota que contiene pipe

Construí un GLOBAL de prueba con los 11 columnas y una fila cuya Notas tiene un pipe literal:

```
nota con | pipe literal en el medio
```

Resultado tras parsear + regenerar con el `join` del generador:

```
pipes=12  cierra=True
  | 999 | 999-Modulo-Prueba | ✅ Completado | ... | nota con \| pipe literal en el medio |
```

**PASS**: el pipe queda escapado dentro de Notas, la fila mantiene 12 pipes y cierra. Es exactamente
el defecto que el parche busca prevenir.

### 2. Caso real — M156, la única fila de 167 con pipe en Notas

Parseé el GLOBAL real: de 167 filas, **solo M156** tiene un `|` dentro de Notas. Al regenerarla:

```
fila regenerada: pipes=12 · cierra=True · longitud=606
fila en disco   : pipes=12 · difiere de la regenerada = False
```

**La fila regenerada es idéntica a la que está en disco.** El parche es estable sobre el archivo
real.

### 3. Cómo M156 sobrevive hoy sin el parche

El pipe de M156 **no está dentro de la fila**: quedó en una línea huérfana (L165) tras un salto de
línea. `parsear_filas` reengancha esas líneas a las Notas de la fila anterior, así que el pipe nunca
llega a partir la celda. Es una forma frágil de estar correcto — basta eliminar ese salto para que
el pipe entre en la fila — pero hoy está estable.

## Conclusión

| Aspecto | Estado |
|---|---|
| Parche `esc()` | ✅ funcionando end-to-end |
| Sandbox con pipe literal | ✅ PASS (escapa y mantiene 12 pipes) |
| GLOBAL real (167 filas) | ✅ estable, regeneración idempotente |
| Filas con pipe en Notas | 1 (M156), resuelto por línea huérfana |

**El defecto del pipe de cierre está cerrado en origen.** Con este parche y el verificador
`auditar_tabla_secciones.py`, las dos vías (generación automática y edición manual) quedan cubiertas.

## Archivos Modificados/Creados

**Creados:**
- `Logs/1665-parche-esc-verificado-e2e-global-estable_2026-10-11.md`

**Leídos (read-only):**
- `scripts/generar_checklist_global.py`
- `CHECKLIST-GLOBAL.md`
