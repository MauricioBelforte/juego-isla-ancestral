**Modelo:** atria-dawn (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 03:45 (actualización)

# BACKLOG DE DELEGACIÓN — tareas grandes por modelo

> Directiva del fundador (2026-10-10): las tareas delegadas deben ser **más grandes o más
> numerosas** para que cada modelo trabaje más tiempo por entrega. Este archivo es la reserva de
> donde se toman los bundles al responder reportes.
> **Fuente de verdad para estado:** `CHECKLIST-GLOBAL.md` y `DOCUMENTACION/11-BUGS.md`.
> Regla: un bundle se "integra" en la próxima respuesta al reporte del modelo — nunca asignar sin
> que él haya reportado primero (evita doble asignación, trampa TerrainData).

## Estado de la flota (03:45)

| Modelo | Frente actual | Créditos |
|---|---|---|
| agnes-3-flash | M100 blq 6 (meta ~190) → M104 prioridad | muchos |
| mimo-v2.6-flash-free | BUG-129 patch autorizado + BUG-052 | muchos |
| atria-dawn-s2 | QA §21.8 M156 + M82/M119 notas | delegado |
| atria-dawn-s3 | Step 5 (M110 blq 3) + Ling (BUG-034) | muchos |
| DeepSeek-V4.1-Flash | libre — M105 propuesto | limitados |
| Hy3 | auditoría M107 47→146 | limitados |
| step-5-kilocode | M24 QA §21.8 + M110 blq 4-5 | muchos |

---

## agnes-3-flash

| # | Tarea | Tamaño | Estado |
|---|-------|--------|--------|
| A1 | **M100-Community-Management** — 179/221, blq 6 es el último (meta ~190) | Grande | EN CURSO (msg 178) |
| A2 | **M104-Analytics** — 60/115 de fondo (55 [ ]) | Grande | EN CURSO |
| A3 | restore_backup.ps1 reescrito (M107) | Chico | ✅ HECHO — verificado 0 parse errors |
| A4 | **M107-Backups ronda 2** — 30 [ ] + 18 [?] restantes | Mediano | Pendiente (tras M100/M104) |
| A5 | ~~M156 reconciliación gap~~ — **RESUELTO: deriva temporal, no inflación** | Grande | CERRADO (Log 1563) |

## mimo-v2.6-flash-free

| # | Tarea | Tamaño | Estado |
|---|-------|--------|--------|
| M1 | **BUG-129 cierre completo** — patch `inst.free()` L90 autorizado + reescribir test huérfanos UTF-8 sin BOM; meta 257→0 strays medido | Mediano | EN CURSO (msg 93) |
| M2 | **BUG-052** — 434 GLBs / 0 sidecars, trinquete max 418 excedido en 16; decidir si subir trinquete o limpiar | Mediano | EN CURSO (msg 93) |
| M3 | **287 CJK + 4 BOM** en otros archivos (deuda reportada por DeepSeek al cerrar BUG-103) | Mediano | Pendiente |

## atria-dawn-s2

| # | Tarea | Tamaño | Estado |
|---|-------|--------|--------|
| S1 | ~~Fix anti-colisión~~ — commit 57d1605, 13+15 tests | Chico | HECHO |
| S2 | ~~Auditoría gap M156~~ — 22/22 sustentados, deriva temporal | Grande | HECHO |
| S3 | Reasignaciones deuda M82/M119 + texto L155-157 M156 | Chico | AUTORIZADO este turno |
| S4 | **QA §21.8 M156** — 169/82/56, módulo central (movimiento+terreno) | Mediano | ASIGNADA (msg 193) |

## atria-dawn-s3

| # | Tarea | Tamaño | Estado |
|---|-------|--------|--------|
| R1 | **Step 5 → M110 blq 3 ✓ (9 flips) + blq 4-5** (27 [?]) | Muy grande | EN CURSO (msg 29) |
| R2 | **Ling → BUG-034** — sub-alcance 10 filas, un intento más; sin respuesta = baja | Mediano | EN CURSO — sin entrega |
| R3 | **Step 5 → M24 QA §21.8** — M24 LIBERADO 126/128 | Grande | ENTREGADA (msg 29) |
| R4 | Coordinación M24 (avisar a s3 + Step 5 en el mismo ciclo) | — | Activa |

## DeepSeek-V4.1-Flash (una tarea a la vez)

| # | Tarea | Tamaño | Estado |
|---|-------|--------|--------|
| D1 | ~~M24-Templos liberar~~ — 126/128 liberado, 26 flips aplicados por director | Grande | HECHO |
| D2 | BUG-103 | Chico | ✅ HECHO — flip aplicado |

## Hy3

| # | Tarea | Tamaño | Estado |
|---|-------|--------|--------|
| H1 | **Auditoría M107 salto 47→146** — +99 [x] sin nota de auditoría; verificar "documentado en 03-Diseno.md §X" por ítem; bloques de 15-20 | Muy grande | EN CURSO (msg 121) |
| H2 | ~~QA §21.8 M156~~ — asignada a s2 (mismo modelo que Hy3, conflicto) | Mediano | REASIGNADA |
| H3 | QA §21.8 M37 — cuando agnes cierre M53/M104 | Mediano | Pendiente |

## step-5-kilocode (vía s3)

| # | Tarea | Tamaño | Estado |
|---|-------|--------|--------|
| F1 | **M110 blq 4-5** — 27 [?] restantes (blq 3 cerrado) | Muy grande | EN CURSO (msg 29) |
| F2 | **M24 QA §21.8** — ACTIVA, 6 suites + gate a verificar | Grande | EN CURSO (msg 29) |
| F3 | BUG-034 — si Ling no la toma | Mediano | Pendiente |

---

## Reserva compartida (sin dueño fijo)

| Tarea | Origen | Tamaño |
|-------|--------|--------|
| **BUG-120** — falso-verde `run_tests.gd` (M112, dueño sin asignar) | 11-BUGS | Mediano |
| **BUG-091** — "Coordinador deriva" (abierto) | 11-BUGS | Mediano |
| **BUG-034** — 14/42 filas QA-SEALS sin sello (parcial) | E-11b | Mediano |
| **287 CJK + 4 BOM** — caracteres colados en archivos vivos | BUG-103 cierre | Mediano |
| **M06** — 99/100, 1 [ ] suelto | GLOBAL | Chico |
| **M149** — 99/100, 1 [ ] suelto | GLOBAL | Chico |
| **M132** — 104/105, 1 [ ] suelto | GLOBAL | Chico |
| **M151-Control-Final** — 23/167, 144 [ ] | GLOBAL | Grande |
| **M148-Lore-Ambiental** — 23/117, 94 [ ] | GLOBAL | Grande |
| **M13-Herramientas** — 84/120, 36 [ ] | GLOBAL | Grande |
| **M16-Crafting** — 43/208, 165 [ ] | GLOBAL | Muy grande |

> **Nota:** los "1 [ ] suelto" son los mejores cierres rápidos para un modelo que queda libre
> entre bundles — cierran un módulo fundacional en minutos.

## Bugs abiertos (seguimiento del director)

| Bug | Estado | Dueño |
|-----|--------|-------|
| BUG-129 | **cierre en curso** (patch autorizado a mimo) | mimo |
| BUG-052 | abierto — 434 GLBs, trinquete excedido | mimo |
| BUG-103 | ✅ **resuelto** (DeepSeek, flip aplicado) | — |
| BUG-065 | ✅ **resuelto** (fix leyenda + deuda Δ=0 cerrada) | — |
| BUG-034 | parcial — 14/42 filas sin sello | Ling (o Step 5) |
| BUG-119 | abierto — race terreno M163 | mimo investigando |

## Lecciones del día (patrones a no repetir)

1. **Colisión de pool de logs** (3 veces: 1541, 1546, 1550): la lectura simultánea SÍ ocurre con
   4 segundos de ventana. Fix de s2 pendiente (`os.path.exists` antes de consumir).
2. **BOM en `NUMEROS_DISPONIBLES.txt`**: rompe `int()` del helper. Detectado y limpiado.
3. **WIP sin commitear con BOM + mojibake + parse error** (`test_debug_menu.gd`) mataba el runner
   entero (rc=105). **Regla nueva: `--check-only` antes de entregar cualquier suite.**
4. **Script PS1 citado sin parsear** en el log 934 → Hy3 lo cazó. **Regla: parseo real, no existencia.**
5. **Aritmética de bloques**: Step 5 tiene buen detalle línea por línea pero mala cuenta de
   rango. **Guarda: contar primero, verificar después.**
6. **Mi error de encargo**: pedí QA §21.8 sobre M107 teniendo 12 [ ] + 18 [?] — no se sella lo
   incompleto. **El veredicto "no sellable" fue correcto.**
7. **Mi error de prioridad** (ronda 1): respondí a Step 5 (7+) antes que s2 (3) y s3 (4). La
   excepción "desbloquea a otro" no aplicaba. Corregido en las rondas siguientes.
