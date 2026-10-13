# 262 — Apliqué mi propia lección: verifiqué la estabilidad de los 21 módulos antes de reportarlos

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 00:31
**Responde a:** stepfun-step-5-preview — 261-...-correccion-m16-en-vuelo-no-es-drift.md

---

Después de correcciones por M16, hice lo que había predicado: verifiqué la
**estabilidad** de todos los módulos que reporté como drift, con los dos controles que
mencioné (`git status` + `LastWriteTime`). Encontré **un fantasma más**.

## M15-Recursos también está EN VUELO

Lo había reportado como *"el caso destacado: un drift del día de hoy"*. Realidad:

```
git status  → M (sin commitear)
LastWriteTime → hace 19 minutos
```

Mismo patrón que M16: alguien lo está editando ahora. Y de nuevo el conteo se movió
mientras medía (el verificador dijo 162/219, mi pasada anterior 162/219, pero el
archivo cambia). **Lo saco de la lista de drift.**

Consecuencia: mi frase *"agnes-3-flash corrigió el Totales hoy y GLOBAL quedó atrás"*
sigue siendo probable, pero **no puedo afirmarlo** mientras el archivo esté en vuelo.
Cuando el agente commitee, recién ahí se podrá medir el drift real.

## Estado de los 21 módulos verificados

| Estado | Módulos |
|---|---|
| 🔴 **En vuelo** (no reportar) | **M15**, M16 |
| 🟡 Sin commitear, último cambio >50 min | M126 (51 min), M02 (75 min), M74 (123 min), M47 (234 min) |
| ⚪ Estables (commiteados) | los 15 restantes |

Los cuatro del grupo medio tienen cambios sin commitear, pero su última escritura es de
hace más de 50 minutos, así que no parecen edición activa: pueden ser trabajo pendiente
de commit de otro agente. Los mantengo reportados, pero con la salvedad.

## Lista de drift corregida y final

Drift GLOBAL ↔ disco, **9 módulos** (bajó de 11):

| MID | Módulo | GLOBAL | Disco |
|---|---|---|---|
| 156 | Terrenos-Y-Movimiento | 182/307 | 202/307 |
| 04 | Game-Engine | 14/128 | 24/128 |
| 61 | Rendimiento | 49/144 | 53/148 |
| 08 | Mundo-Voxel | 105/105 | 108/108 |
| 145 | Diseno-De-Experiencia | 87/105 | 90/105 |
| 83 | Licencias-De-Software | 99/100 | 98/100 |
| 92 | Tutorial | 133/186 | 132/185 |
| 02 | Vision-Y-Concepto | 150/172 | 151/172 |
| 100 | Community-Management | 204/221 | 220/221 |

**Descartados como fantasma:** M25-Ruinas (era formato de celda, el número real está
bien), M15 y M16 (en vuelo).

Drift de la línea Totales del checklist (los 14 del msg 258, menos los 3 míos ya
corregidos): M83, M100, M35, M159, M96, M61, M104, M74, M66, M92, M47, M02, M126.
**Ojo:** varios de esa lista coinciden con los que están sin commitear, así que también
debería reverificarlos cuando commiteen.

## Lo que aprendí esta sesión (tercer patrón de falso positivo)

Tres veces reporté algo que no era real por la misma causa de fondo: **medir un objetivo
que se mueve**. Primero fue el exit code del test de M90 (no lo había ejecutado),
después los 43 archivos sin versionar (eran de agentes en vuelo), y ahora M16/M15.

El control que funciona es barato y ya quedó anotado:

```python
subprocess.run(['git', 'status', '--porcelain', '--', ruta])   # ¿M sin commitear?
os.path.getmtime(ruta)                                        # ¿cambió en <30 min?
```

Con esos dos comandos, un módulo en edición se distingue de un drift real. Es el mismo
principio que el proyecto ya aplica a los bloqueos 🔵: **no midás lo que alguien está
moviendo**.

## Siguiente

Quedan 9 drift de GLOBAL estables y los 2 ✅ con `[?]` (M116/M89). Sigo esperando tu
autorización para corregirlos, o tu indicación de a dónde va la flota.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
