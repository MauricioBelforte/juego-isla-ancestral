# Log 1239: Guia de Comunicacion — regla de oro "el detalle va a la carpeta, el chat solo avisa"

**Fecha:** 2026-10-03
**Hora:** 20:35
**Modelo:** atria-Dawn-Preview
**Plataforma:** Kilo Code
**Rol:** Coordinador

## Resumen

Directiva del usuario (2026-10-03): eliminar la duplicacion del informe (el agente lo narra
por el chat y el usuario lo tiene que copiar al director). Se crea la guia central de
comunicacion con la regla de oro, se documenta en AGENTS.md §10.2 y se anota en los 6
backlogs personales.

## Cambios Realizados

### 1. Guia central nueva

`Mensajes entre modelos/GUIA-COMUNICACION.md` (4.659 bytes, LF, 0 mojibake) — lectura
obligatoria para agentes y director. Contenido:

- **Regla de oro:** el informe detallado se escribe en la carpeta del modelo; por el chat
  solo se avisa
- **Los tres roles** detallados: el agente (escribe + commit + una linea "termine [item],
  informe en mi carpeta"), el director (lee la carpeta, procesa, responde en la carpeta),
  el usuario (solo conecta: "fijate los que terminaron" / "anda a leer tu carpeta")
- **Flujo completo** en diagrama de pasos
- **Ejemplos** correcto vs incorrecto (con el contraejemplo de 40 lineas que esta guia
  elimina)
- **Excepciones:** pregunta que bloquea ("pregunta en mi carpeta: [la pregunta]"), error
  critico, y dialogo directo con el usuario
- **Por que importa:** economia de tokens, trazabilidad, contexto acumulado, usuario que solo
  conecta

### 2. AGENTS.md §10 actualizado

- Encabezado §10: anadida referencia normativa a la guia (con link)
- §10.2 regla 9 nueva: "Economia de tokens en el chat (regla de oro)" — el aviso de una linea
  del agente, la respuesta del director en la carpeta, y el rol del usuario ("fijate los que
  terminaron" / "termino [modelo]" / "anda a leer tu carpeta")
- EOL preservado: 1333 -> 1336 CRLF, 0 CR sueltos. Las 7 detecciones de mojibake del archivo
  son preexistentes (citas deliberadas de la seccion 28 sobre el sintoma; verificadas contra
  HEAD con los mismos indices desplazados)

### 3. Nota en los 6 backlogs personales

Bloque "Guia de comunicacion (Modo Canal) - 2026-10-03" al final de cada BACKLOG-MASTER.md,
preservando el EOL original de cada archivo:

| Backlog | EOL preservado |
|---|---|
| Hy3 | CRLF (941 lineas, 0 LF sueltos) |
| DeepSeek-V4.1-Flash | LF puro (0 CRLF) |
| agnes-3-flash | CRLF |
| mimo-v2.6-flash-free | LF |
| kimi-k3 | CRLF |
| atria-dawn-s2 | CRLF |

Cada nota cita la regla de oro, los tres formatos de una linea (termine / aborte / pregunta)
y la ruta de la guia.

## Forma de uso (para el usuario)

- **A cada agente:** "leé tu carpeta en `Mensajes entre modelos/<modelo>/` y trabajá desde
  ahí. Respondé en la misma carpeta. Pull previo: `git pull`." La guia la ven citada en su
  backlog y en el proximo archivo de su carpeta (aviso por separado).
- **Al director:** "fijate los que terminaron" o "terminó <modelo>".

## Archivos Modificados/Creados

- Mensajes entre modelos/GUIA-COMUNICACION.md (nuevo)
- AGENTS.md — encabezado §10 + §10.2 regla 9
- DOCUMENTACION/TAREAS-POR-MODELO/{Hy3,DeepSeek-V4.1-Flash,agnes-3-flash,mimo-v2.6-flash-free,kimi-k3,atria-dawn-s2}/BACKLOG-MASTER.md (6 notas)
- Logs/NUMEROS_DISPONIBLES.txt — 1239 consumido; cabeza 1240
- Logs/1239-guia-comunicacion-regla-oro_2026-10-03_20-35.md — este log

## Proximos pasos

1. Commit + push de este lote con huella.
2. Aviso de la guia en cada carpeta de canal (archivo nuevo, una linea) para que los agentes
   que ya leyeron su 01 no se la pierdan.
3. Activacion de la flota con el prompt unico "leé tu carpeta".
