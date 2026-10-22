# Log 2097: M17 — wrapper integrador: las 7 suites de M17 entran al circuito central (498 checks)

**Fecha:** 2026-10-21
**Hora:** 21:25 (local; reloj real del sistema)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Que se hizo

GO del director (msg 022): "llevar las 8 suites de M17 al runner central ... con deteccion estatica
conservadora de tu pool".

**`game/isla-ancestral/tests/test_m17_suites_integracion.gd`** (NUEVO, en `res://tests/` -> el runner
central lo descubre solo): ejecuta las **7 suites de `scripts/construccion/`** como subprocesos y agrega
su resultado. Verificado: **17 checks, 0 fallos, rc=0, 73.3 s** y **498 checks de M17 verificados**
(131 + 99 + 138 + 45 + 39 + 22 + 24).

La 8a suite (`tests/test_m17_construccion_validacion.gd`, 44 checks) ya estaba en `res://tests/` y el
runner la descubre por su cuenta.

## Detalles de implementacion (y los dos tropiezos)

1. `OS.execute()` **no captura la salida** de un hijo consola en Windows (los 7 hijos daban rc=1 y salida
   vacia). Se adopto el **patron que ya funciona en el runner central**: `cmd.exe /V:ON /C` con redirect a
   archivo + polling con `OS.create_process` + `OS.is_process_running`, y lectura del archivo. Con eso los
   7 hijos corrieron y se leyeron sus lineas `RESUMEN`.
2. Los **umbrales** se calibraron con lo MEDIDO, no estimado: el total real de las 7 suites es **498**
   checks (yo habia puesto 500 y el piso propio en 40; el suite hace 17 checks). Corregidos a 490 y 15
   respectivamente — **por debajo** de lo medido, nunca por encima para forzar el verde.

## Pendiente honesto

El wrapper corre sus 7 hijos **en serie** (73.3 s). El runner central los ejecuta dentro de su **pool de
6 workers**, asi que ese tiempo se solapa con el resto de suites: el total deberia quedar cerca de los
**545 s** que cerro M112 (presupuesto 600 s). **No lo he re-medido todavia** (una corrida completa son
~9 min) -> el item de tiempo de M112 queda con su medicion de 545.3 s **y** esta nota: si la corrida con el
wrapper dentro pasa de 600 s, el ajuste es **paralelizar los 7 hijos dentro del wrapper** (o mover el
wrapper fuera del pool).

## Archivos

- Creado: `game/isla-ancestral/tests/test_m17_suites_integracion.gd` (17 checks, 0 fallos)
- Creado: este log + el acuse 025 del canal
- Modificado: `BACKLOG-MASTER.md`, `ESTADO-PARALELO.md`
- Sin push ni commits. No se toco codigo de otros modulos.
