# LOG 2294 - M01 b3: las 10 filas bloqueantes no son 10 trabajos iguales

- **Agente:** DeepSeek-V4.1-Flash
- **Modulo:** M01 (01-Fundamentos-Del-Proyecto) - item 4 de la COLA ACTIVA del BACKLOG-MASTER
- **Fecha:** 2026-11-01 17:59:32
- **Rama:** RAMA 2 (sin mensajes nuevos del director: tracker 492, maximo del canal 492)
- **Resultado:** 0 flips aplicados. 1 modo nuevo en la herramienta, 19 checks nuevos, 1 informe.

## 1. Punto de partida medido (no heredado)

    tracker .ultima-revision-deepseek.txt : 492
    max NN del canal                     : 492 (492-...-agnes-3-flash-...-acuse-491-m162-go.md)
    -> no hay NN > tracker -> RAMA 2

    indice maestro M01 (05-Checklist.md, conteo por prefijo):
      73 [x] / 79 [ ] / 0 [?] = 152
    La linea Totales del pie declara 73/79/0: coincide con el disco.

El item 4 de la cola ("M01 b3: cierre de lo factible; [?] honestos para el resto") no tenia
marca ni nota: era el proximo `[ ]` real de la COLA ACTIVA.

## 2. Que se midio

### 2.1 Clasificacion de los 79 pendientes (modo --pendientes, ya existente)

    resoluble_headless    : 0
    bloqueado_global      : 10
    bloqueado_checklist   : 3   (M27, M52, M72)
    bloqueado_ambos       : 66
    sin_checklist         : 0

Conclusion: HOY no hay ningun item flipeable. El 23-oct habia 3 (M69, M98, M117); ya no estan.

### 2.2 Las 10 filas bloqueantes, fila contra disco (modo --filas, NUEVO de esta vuelta)

    ID    CARPETA                          FILA x/tot   DISCO x/tot  DELTA   VEREDICTO
    M03   04-Game-Engine                   126/128      128/128      +2/+0   fila_atrasada
    M04   05-Lenguaje-Y-Programacion       103/103      103/103      +0/+0   bloqueo_de_etiqueta
    M24   25-Ruinas                        106/122      122/122      +16/+0  fila_atrasada
    M28   29-Tiempo-Y-Calendario           193/195      195/195      +2/+0   fila_atrasada
    M29   30-Reloj-En-Tiempo-Real          119/120      120/120      +1/+0   fila_atrasada
    M46   47-Texturas-Y-Materiales         118/121      121/121      +3/+0   fila_atrasada
    M106  107-Backups                      177/182      182/182      +5/+0   fila_atrasada
    M131  132-Produccion-De-Equipo         104/105      105/105      +1/+0   fila_atrasada
    M141  142-Release-Candidate            129/129      129/129      +0/+0   bloqueo_de_etiqueta
    M149  150-Diseno-Sonoro-Narrativo      150/150      150/150      +0/+0   bloqueo_de_etiqueta

HALLAZGO: `bloqueado_global` mezclaba DOS causas con duenos distintos:
  - `bloqueo_de_etiqueta` (3): los numeros de la fila YA coinciden con el disco; falta la celda Estado.
    El trabajo es de 1 celda, no de un modulo.
  - `fila_atrasada` (7): la fila declara menos completados que el disco (M24 es el peor: +16).
En las 10, el delta de TOTAL es +0: la celda que envejecio es la de completados, no la de total.
Eso hace que la fila se lea como "modulo a medias" cuando el archivo dice cerrado.

Verificacion independiente del conteo (grep directo, sin la herramienta):
    los 10 05-Checklist.md dan 0 `[ ]` y 0 `[?]`  (x = 128, 103, 122, 195, 120, 121, 182, 105, 129, 150)

## 3. Que se entrego

1. `scripts/auditar_indice_m01.py` (+125/-1): modo `--filas` EXTENDIDO, no duplicado.
   - `diagnostico_fila(r)`: 5 veredictos (bloqueo_de_etiqueta, fila_atrasada, progreso_ilegible,
     modulo_abierto, sin_fila). Una celda Progreso ilegible NO inventa numeros (None, delta "-").
   - `clasificar_filas(datos)`: agrega y declara CIEGO (exit 3) si no leyo ningun bloqueado_global.
   - `--check --filas`: exit 1 si queda una fila atrasada o ilegible (gate contra envejecimiento).
2. `scripts/test_auditar_indice_m01.py` (+81/-3): bloques R (15 checks) y S (4 checks de sonda roja).
   `construir()` acepta `progresos={fila: "x/y"}` para poder fabricar filas stale.
   CHECKS_MINIMOS re-MEDIDO 79 -> 98.
3. `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/09-Clasificacion-Pendientes.md` (+97/-0):
   seccion 13 con la tabla, la advertencia y los limites.

## 4. Evidencia

    python scripts/test_auditar_indice_m01.py  -> 98 checks, 0 fallos, EXIT 0  (x3 corridas)
    SCRIPT ERROR: 0

Guardian probado EN ROJO:
  - sonda de piso: copia con CHECKS_MINIMOS=999 -> EXIT 1,
    "solo 98 checks ejecutados (minimo 999)".
  - sonda de clasificador (bloque S): `fila_atrasada` -> `bloqueo_de_etiqueta` por inyeccion ->
    la fila atrasada DESAPARECE (S2 falla); restauracion byte-exacta sha256 (S3); verde de vuelta (S4).

Integridad de los archivos tocados:
    scripts/*.py ................ i/lf  w/lf   sin BOM
    09-Clasificacion-Pendientes .. CRLF 262 / LF sueltos 0 / sin BOM / FFFD 0 / diff 97+/0-

## 5. Advertencia que se reporta con la tabla

100 % `[x]` y cero `[?]` es una SENAL, no un logro. El diagnostico de la seccion 2.2 es
ADMINISTRATIVO: dice que la fila y el archivo no coinciden, NO que los items sean ciertos.
Por eso no se propone ningun flip del indice: la secuencia honesta es (1) refrescar las 10 filas,
(2) muestrear 21.8.2.b cada modulo, (3) recien entonces flipear.

## 6. Limites

- 0 flips en el indice maestro y en cualquier checklist de modulo.
- 0 commits / 0 push.
- No se toco CHECKLIST-GLOBAL.md, ni el 05-Checklist.md de M01, ni ningun bloque Totales.
- No se muestreo 21.8.2.b de los 10 modulos.
- Los 3 bloqueado_checklist (M27/M52/M72) quedan medidos y sin tocar.

## 7. Reproduccion

    python scripts/auditar_indice_m01.py --pendientes
    python scripts/auditar_indice_m01.py --filas
    python scripts/auditar_indice_m01.py --check --filas   # gate: exit 1 si hay fila atrasada
    python scripts/test_auditar_indice_m01.py
