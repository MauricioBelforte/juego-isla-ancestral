# Log 1327: Protocolo de comunicacion mejorado — numeracion global + nombre emisor->receptor

**Fecha:** 2026-10-05
**Hora:** 08:15
**Modelo:** atria-dawn-preview
**Plataforma:** Kilo Code

## Resumen

El fundador pidio tres mejoras al protocolo de comunicacion entre modelos: (1) que los numeros
de los mensajes no se repitan nunca mas, (2) que el nombre del archivo diga **quien le escribe a
quien**, y (3) ampliar el pool de numeros. Las tres implementadas. La primera se resolvio
**estructuralmente**: la numeracion de mensajes salio del pool global en vez de ser por carpeta,
lo que hace que la colision sea imposible por diseno.

## Cambios Realizados

### 1. Numeracion de mensajes: pool GLOBAL (resuelve de raiz T-8/T-12)
- **Antes:** cada carpeta de canal tenia su propia secuencia (01, 02, 03...). Numerar requeria
  "listar la carpeta destino y elegir el siguiente libre" — una accion facultativa que nadie
  cumplia bajo concurrencia. Resultado: **11 colisiones en un dia** (3 el dia anterior + 8 en la
  jornada).
- **Ahora:** el numero de un mensaje sale de `Logs/NUMEROS_DISPONIBLES.txt`, el mismo pool de los
  logs. Cada numero se consume una sola vez en todo el proyecto, de modo que **no puede
  repetirse** en ninguna carpeta.
- **Consecuencia aceptada:** los numeros dentro de una carpeta dejan de ser consecutivos. El
  orden del hilo se sigue por fecha/hora del nombre y por `**Responde a:**`.
- **Pool ampliado** de 1500 a **3000** (174 -> 1673 libres).

### 2. `scripts/reservar_mensaje.py` (nuevo)
Reserva atomica que automatiza todo el proceso:
- verifica que la carpeta del receptor exista (si no, **lista las disponibles**);
- lista los ultimos 3 mensajes de la carpeta destino para el `**Responde a:**`;
- toma el siguiente numero del pool global y lo borra;
- **crea el archivo** en la carpeta del receptor con el nombre emisor-a-receptor y una plantilla
  con `**Modelo:**` / `**Plataforma:**` / `**Fecha:**` / `**Responde a:**` ya puestos;
- reintenta con el siguiente numero si el libre ya existe en la carpeta destino.
- Probado: reserva OK, error de carpeta inexistente con lista de disponibles OK, devolucion del
  numero de prueba al pool OK.

### 3. Nombre de archivo con emisor -> receptor (directiva del fundador)
- Formato: `NN-AAAA-MM-DD_HH-MM-SS-<emisor>-a-<receptor>-tema.md`
- Ej: `1327-2026-10-05_08-15-00-atria-dawn-s2-a-deepseek-v4.1-flash-td8-m103.md`
- Permite ver de un vistazo **quien le escribe a quien** sin abrir el archivo, incluyendo
  comunicacion entre modelos sin intervencion del director.
- **Los archivos anteriores no se renombran** (romperia las referencias cruzadas). Regla para
  mensajes nuevos a partir de 2026-10-05.

### 4. Documentacion del protocolo
- `Mensajes entre modelos/GUIA-COMUNICACION.md`:
  - Seccion nueva "Numeracion de mensajes: pool GLOBAL" (regla, por que, helper, consecuencias).
  - Seccion nueva "Nombre de archivo: emisor -> receptor" con tabla de ejemplos.
  - Corregida la seccion "Colaboracion horizontal", que decia que cada modelo escribe en su
    propia carpeta — contradictoria con T-8 (se escribe en la del RECEPTOR).
  - **T-11** (byte NUL en el GLOBAL, ver Log 1324) y **T-12** (numeracion por carpeta) agregadas.
  - T-8 marcada como **resuelta de raiz** con la solucion estructural.
  - Invariante documentado actualizado (CR-suelto 218 -> 147).
- `AGENTS.md` §10.2: reglas 3 (nombre) y 4 (numeracion) reescritas; regla 1 actualizada; resto
  renumeradas.
- `Mensajes entre modelos/ESTADO-PARALELO.md`: aviso de cambio de protocolo al inicio del
  archivo (lo leen todos los modelos antes de trabajar).

## Archivos Modificados/Creados

- `scripts/reservar_mensaje.py` (nuevo)
- `Logs/NUMEROS_DISPONIBLES.txt` — ampliado a 3000 + reserva 1327
- `Mensajes entre modelos/GUIA-COMUNICACION.md` — secciones nuevas + T-11/T-12 + correcciones
- `AGENTS.md` — §10.2 reglas 1/3/4 reescritas
- `Mensajes entre modelos/ESTADO-PARALELO.md` — aviso de cambio de protocolo
- `Logs/1327-PROTOCOLO-COMUNICACION-NUMERACION-GLOBAL-EMISOR-RECEPTOR_2026-10-05_08-15-00.md`

## Leccion

La trampa T-12 (numeracion por carpeta) se repitio 11 veces en un dia pese a estar documentada
en T-8 con su regla explicita. **Pedirles a los agentes que tengan cuidado no escala**: cuando
una trampa se repite tres veces, la unica respuesta real es cambiar el proceso para que el error
sea imposible. Mover la numeracion al pool global convierte la colision de "error humano
frecuente" en "imposible por diseno".
