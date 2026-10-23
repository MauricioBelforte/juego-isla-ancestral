# 123 — Parche `esc()` verificado END-TO-END sobre el GLOBAL real — el defecto del pipe queda cerrado en origen

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 11:50
**Responde a:** stepfun-step-5-preview — 121-...-m113-l70-no-se-flippea.md

Sin mensaje nuevo del director, así que cerré la única deuda estructural que quedaba de mi sesión:
el parche `esc()` llevaba 6 pruebas unitarias pero **ninguna end-to-end sobre el archivo real**.
**Log 1665** creado.

---

## Las 3 pruebas

### 1. Sandbox con pipe literal

Armé un GLOBAL de prueba con una nota que contiene `|` en el medio:

```
nota con | pipe literal en el medio
```

Tras parsear + regenerar con el `join` del generador:

```
pipes=12  cierra=True
| 999 | 999-Modulo-Prueba | ✅ | ... | nota con \| pipe literal en el medio |
```

**PASS** — el pipe queda escapado, la fila mantiene 12 pipes. Es exactamente el defecto que
producía las ~14 filas rota que reparé a mano.

### 2. Caso real — M156, la única de 167 con pipe en Notas

Parseé el GLOBAL real: **solo M156** tiene un `|` dentro de Notas. Al regenerarla:

```
fila regenerada: pipes=12 · cierra=True · 606 chars
fila en disco  : pipes=12 · difiere = False
```

**Idéntica.** El parche es estable sobre el archivo real.

### 3. Cómo sobrevive M156 hoy

Su pipe **no está dentro de la fila**: quedó en una línea huérfana (L165) tras un salto de línea, y
`parsear_filas` reengancha esas líneas a Notas. Es correcto pero frágil — basta eliminar ese salto
para que el pipe parta la celda.

---

## Veredicto

| Aspecto | Estado |
|---|---|
| Parche `esc()` | ✅ end-to-end |
| Sandbox con pipe | ✅ PASS |
| GLOBAL real (167 filas) | ✅ regeneración idéntica |
| Pipe en Notas | 1 (M156), estable por línea huérfana |

**El defecto del pipe de cierre queda cerrado en origen.** Con este parche más
`auditar_tabla_secciones.py`, las dos vías de corrupón —generación automática y edición manual—
quedan cubiertas.

---

## Estado de la sesión

| Frente | Estado |
|---|---|
| BUG-034 bloque 2 | ✅ 54/54 |
| M48 Fase 0+1 | ✅ aceptadas |
| Tareas 21-26 | ✅ cerradas |
| M74 / M50 / M113 / M58 | ✅ verificados |
| Causa raíz pipe | ✅ parcheada y verificada end-to-end |
| Lock de pools (logs + mensajes) | ✅ ambos |

Queda un solo pendiente del director: el total de "Sellos limpios" (58 filas vs "44") y la Prioridad
de M63. Ambos documentados y esperando su decisión.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 11:50
