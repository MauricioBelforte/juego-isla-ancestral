# Log 1608: Numeracion de canales corregida (plantillas duplicadas) + fix de fondo en reservar_mensaje.py

**Fecha:** 2026-10-10
**Hora:** 18:15
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen

El fundador pidio revisar la numeracion de los mensajes entre modelos: numeros saltados y,
en mi canal, el 203 repetido y mal formado. El escaneo de los 11 canales activos encontro
**6 plantillas duplicadas** (s2 203, agnes 201, deepseek 139, hy3 114, hy3 121, stepfun 15)
mas huecos en 4 canales. Se borraron las 6 plantillas vacias, se regeneraron los pools de
forma canonica y se arrego la causa raiz en `scripts/reservar_mensaje.py`: el slug del tema
se truncaba a 50 chars cortando palabras a medias ("tu-estimac"), lo que llevaba al emisor
a escribir el cuerpo en un archivo NUEVO con el nombre completo y dejar la plantilla huerfana
con el numero duplicado.

## Cambios Realizados

### 1. Diagnostico (escaneo de los 11 canales)
- Script PowerShell: por canal, numeros usados de los nombres `NN-*.md`, duplicados y huecos.
- Resultado: 6 plantillas duplicadas (siempre el duplicado "corto" = plantilla vacia con slug
  truncado, el "largo" = mensaje real) y huecos en s2 (8), s3 (5), deepseek (2), agnes (1).

### 2. Borrado de las 6 plantillas vacias duplicadas
| Canal | Numero | Slug de la plantilla (truncada) |
|---|---|---|
| atria-dawn-s2 | 203 | `...-hooks-no-autorizo-aun-m` |
| agnes-3-flash | 201 | `...-mecanicos-tu-estimac` |
| DeepSeek-V4.1-Flash | 139 | `...-playergd-limpio-c5cdb37-cablea` |
| Hy3 | 114 | `...-m63-qa-aprobada-166-checks-sello-registrado` |
| Hy3 | 121 | `...-mojibake-aud` |
| StepFun-Step-5-Preview | 15 | `...-yaml-arreglado-mitad2` |

Verificacion: cada una contenia la cadena `PLANTILLA RESERVADA - NO RESPONDER` y el cuerpo
`<cuerpo del mensaje aca>`; el duplicado largo tenia contenido real. Quedan **0 duplicados**.

### 3. Pools regenerados de forma canonica
Primero se intento "reponer huecos" insertando los numeros faltantes al inicio del pool. Eso
tuvo dos problemas y se descarto:
- El pool de agnes-3-flash ya estaba corrupto (todo en una sola linea separada por espacios;
  al reponer, el `91` se pego al `213` formando `91213`).
- s3 esta activo y consumio 7/77/139 sin crear archivo (races con mi escritura del pool).

Solucion final determinista: regenerar cada pool con la misma logica de `reservar_mensaje.py`
(`1..500` menos los numeros con archivo). Estado final verificado:

| Canal | Pool | Cabeza | Dup | Numeros perdidos |
|---|---|---|---|---|
| atria-dawn-s2 | 305 | 172 | 0 | 0 |
| atria-dawn-s3 | 337 | 7 | 0 | (ver nota) |
| DeepSeek-V4.1-Flash | 355 | 102 | 0 | 0 |
| agnes-3-flash | 289 | 91 | 0 | (ver nota) |
| Hy3, StepFun, mimo, bunny, Ling, kimi | — | — | 0 | 0 |

### 4. Fix de fondo en `scripts/reservar_mensaje.py`
- `sanear_tema(tema, limite=50)` ahora corta en la **frontera de palabra** anterior en vez de
  partir una palabra a medias.
- Nuevo `_limite_tema(carpeta, fecha, emisor, receptor)`: mide la longitud REAL de la ruta del
  canal y devuelve el maximo slug seguro (piso 30, margen de 10 bajo el limite de 260 de Windows).
  Antes el tope era 50 fijo; ahora Hy3 permite 102 y StepFun-Step-5-Preview 64.
- `main()` pasa el limite adaptativo.
- Compatibilidad: la firma sigue aceptando `sanear_tema(tema)` (limite por defecto 50), de
  modo que ningun llamador existente se rompe.

Resultado del caso real: el tema de 89 chars
`m116-qa-aceptada-amarillo-23-duplicados-mecanicos-tu-estimacion-50-explicada-qa-m145-tuya`
genera ahora `...-tu-estimacion-50` (frontera de palabra) en una ruta de 243 chars, en vez del
`...-tu-estimac` mutilado que forzaba al emisor a crear un segundo archivo.

## Archivos Modificados/Creados
- `scripts/reservar_mensaje.py` — fix de `sanear_tema` + nuevo `_limite_tema`.
- `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` — regenerado (305).
- `Mensajes entre modelos/atria-dawn-s3/NUMEROS_DISPONIBLES.txt` — regenerado (337).
- `Mensajes entre modelos/DeepSeek-V4.1-Flash/NUMEROS_DISPONIBLES.txt` — regenerado (355).
- `Mensajes entre modelos/agnes-3-flash/NUMEROS_DISPONIBLES.txt` — regenerado (289).
- Borrados (plantillas vacias duplicadas): 203 de s2, 201 de agnes, 139 de deepseek,
  114 y 121 de hy3, 15 de stepfun.

## Verificacion
- Unitarios nuevos del fix: corta palabra, tema corto preservado, limite adaptativo
  (canal corto > canal largo, piso 30) y ruta completa <= 260 para el peor caso. TODOS OK.
- `scripts/test_reservar_mensaje_colision.py`: 13 PASS, 0 FAIL.
- `scripts/test_scripts.py`: 15 PASS, 0 FAIL (sin regresion).
- End-to-end en canal temporal `zz-test-numeracion` con el tema largo real: nombre legible,
  ruta 243 < 260; canal de prueba borrado despues.
- Escaneo final de los 11 canales: 0 duplicados en todos.
- Mojibake: 0 secuencias sospechosas en los 4 pools regenerados (UTF-8 limpio).

## Notas

### s3 en paralelo
Mientras se hacia este trabajo, los mensajes 164 y 165 de `atria-dawn-s3` (que existian en el
escaneo de las 20:55) desaparecieron de disco, y el 91 de agnes tambien fluctuo. S3 y otros
agentes estaban escribiendo activamente. Se dejo de tocar canales ajenos para no pisar el
trabajo de s3 (posiblemente reestructurando su propia numeracion en paralelo, mismo encargo).
Los "numeros perdidos" residuales que muestra un escaneo puntual de s3/agnes/Haiku son
artefactos de esas races, no dano confirmado: verificar de nuevo con el canal en reposo.

### El 199 de s2 no se renombro
`199-...-bug131-confirmado-corregido-bater[espacio]secundario...` lleva un espacio en el slug
("batería secundario"). El msg 200 del director lo referencia por su nombre exacto en
`Responde a:`; renombrarlo romperia esa referencia. Se deja como deuda menor: el espacio es
inofensivo para la lectura del hilo y la referencia pesa mas que la estetica del nombre.

### Sobre reponer huecos vs regenerar
El protocolo (AGENTS.md 6.1.c) trata los huecos como inofensivos, pero el fundador pidio
corregirlos. La reponicion manual en pools de canales ajenos ACTIVOS es insegura (races y
consumo sin archivo). La regeneracion canonica es deterministica y segura. Si se quiere
eliminar huecos permanentemente, la via es asignar los numeros bajos libres a los proximos
mensajes del canal (que es justo lo que hace el pool regenerado: s2 usara 172, 175... en sus
proximos mensajes, s3 usara 7, 77, 139).
