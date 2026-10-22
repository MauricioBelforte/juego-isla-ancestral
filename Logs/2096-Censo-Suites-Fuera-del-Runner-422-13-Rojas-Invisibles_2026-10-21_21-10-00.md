# Log 2096: CENSO de suites invisibles — 422 suites fuera del runner central, 13 en ROJO que nadie veia

**Fecha:** 2026-10-21
**Hora:** 21:10 (local; reloj real del sistema, no el UTC)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Resumen

El director (msg 022) eligio como siguiente GO "(b) aplicar el mismo descubrimiento de cobertura a OTROS
modulos cuyas suites vivan fuera de res://tests/ ... identificar cuantos hoyos como el de M17 existen".
Lo ejecute como **CENSO DE TODO EL PROYECTO** (no solo M17): se identificaron todas las suites del repo y
se **ejecutaron una por una** (6 workers, `APPDATA` aislado por worker, timeout 45 s).

**Resultado: de 471 suites del proyecto, solo 49 las descubre el runner central (`res://tests/`).
Las otras 422 NUNCA corrieron en CI. Al ejecutarlas: 387 verdes, 13 EN ROJO, 22 con TIMEOUT.**

## La herramienta (entregable durable)

`scripts/auditar_suites_fuera.py` — corre las suites fuera de `res://tests/`, aísla `user://` por worker
(APPDATA) y escribe el detalle en `Logs/auditoria_suites_fuera.json`. No toca codigo de ningun modulo ni
borra nada.

## Las 13 suites invisibles EN ROJO (fallos que nadie veia)

- `scripts/audio/test_narrative_m150.gd` → rc=1 · === Resumen M150: 12 checks, 1 fallos ===
- `scripts/core/test_m66_handler.gd` → rc=1
- `scripts/core/test_m66_inv_ruta.gd` → rc=1
- `scripts/dialogos/test_m21_lote1_hy3.gd` → rc=1 · === Resumen M21 Lote1 Hy3: 23 checks, 3 fallos ===
- `scripts/eventos/test_barrido_m74.gd` → rc=1 · === RESUMEN M74 BARRIDO: 40 checks, 6 fallos, 13 bloques cerrados === · PISO NO CUMPLIDO: 40 < 45
- `scripts/eventos/test_event_manager_verificacion.gd` → rc=1 · === RESUMEN M74 EVENTOS (verificacion): 57 checks, 0 fallos, 9 bloques · PISO NO CUMPLIDO: 57 < 58
- `scripts/farm/test_farm_m33_lote.gd` → rc=1 · === Resumen M33 lote: 41 checks, 2 fallos ===
- `scripts/interacciones/test_mock_interactable.gd` → rc=1
- `scripts/legal/test_credits_m131_iter2.gd` → rc=1 · === Resumen M131 iter 2: 44 checks, 1 fallos ===
- `scripts/npc/test_memoria_agenda.gd` → rc=1
- `scripts/test/test_anillo_arena.gd` → rc=1
- `scripts/ui/test_m53_extremos.gd` → rc=1
- `scripts/world/test_generacion_m10_atria.gd` → rc=1

**De estas, 2 son el MISMO patron que M17** (piso declarado > checks medidos, auto-FAIL):
- `scripts/eventos/test_barrido_m74.gd` (40 < 45)
- `scripts/eventos/test_event_manager_verificacion.gd` (57 < 58)
-> se arreglan AGREGANDO checks (nunca bajando el piso), como hice con `iter6`/`iter7` de M17.

Las otras 11 tienen **checks en rojo de verdad** (1-6 fallos) en rieles de otros duenos: M150 (audio),
M66 (core, x2), M21 (dialogos), M33 (farm), M131 (legal), interacciones, npc (memoria agenda), ui (M53),
world (M10) y `scripts/test/`.

**Y 22 con TIMEOUT (>45 s)**: hay que separar los que son lentos de los que se cuelgan — es el mismo
censo que destapo los 2 timeouts de M159.

## Por que importa

El runner central reporto **45/47 suites OK** durante horas mientras **13 suites de otros modulos
estaban en rojo sin ejecutarse nunca**. El numero "verde" del CI media solo el 10% de los tests del
proyecto. Con la auditoria de M17 (y ahora este censo), la foto real es: **13 fallos invisibles + 22
timeouts** que el CI no puede ver.

## Recomendaciones

1. **Paso 1 (barato, imediato):** que el runner central ejecute, ademas de `res://tests/`, las suites de
   `scripts/<modulo>/test_*.gd` — con la deteccion estatica conservadora que ya usa mi pool (no `user://`
   ni `OS.execute` -> paralelizables; el resto serial). Efecto inmediato: los 13 rojos pasan a verse.
2. **Paso 2:** un gate de `scripts/auditar_suites_fuera.py` en el flujo de CI que falle si hay suites
   invisibles en rojo (o al menos las liste).
3. Cerrar los 2 "PISO NO CUMPLIDO" de M74 agregando checks (no bajando el piso) y derivar las 11 con
   checks rojos a sus duenos.

## Archivos

- Creado: `scripts/auditar_suites_fuera.py` (la herramienta del censo, reejecutable)
- Creado: este log + el acuse 024 del canal
- Modificado: `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md`, `ESTADO-PARALELO.md`
- Sin push ni commits. **No se toco codigo de ningun modulo** (el censo solo LEE y ejecuta).
