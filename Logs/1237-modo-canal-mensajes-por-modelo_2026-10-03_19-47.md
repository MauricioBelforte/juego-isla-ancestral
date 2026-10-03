# Log 1237: Modo Canal — carpetas por modelo en Mensajes entre modelos

**Fecha:** 2026-10-03
**Hora:** 19:50
**Modelo:** atria-Dawn-Preview
**Plataforma:** Kilo Code
**Rol:** Coordinador

## Resumen

Directiva del usuario (2026-10-03): reemplazar la transferencia manual de prompts (yo escribo
el prompt, el usuario lo copia a cada chat externo) por **carpetas por modelo** en
`Mensajes entre modelos/` — una carpeta por agente activo, donde el director escribe el
encargo inicial y cada ida/vuelta es un archivo nuevo. El usuario solo tiene que decirle a cada
modelo "leé tu carpeta y respondé ahí". Implementado: 5 canales creados con su prompt de
partida, AGENTS.md actualizado con el modo, backlogs personales conservados como fuente de
tareas.

## Decisiones confirmadas con el usuario

| Pregunta | Respuesta |
|---|---|
| Nombre de carpeta | **Solo el modelo** (sin prefijo numerico): `Hy3/`, `DeepSeek-V4.1-Flash/`... |
| Modelos sin asignar (Hy4, GLM-5.3) | **Al asignarles trabajo** (evita carpetas vacias; M137 esta disponible para Hy4) |
| Backlogs personales | **Conviven**: el backlog sigue siendo la fuente de tareas verificables; el canal es solo comunicacion |

## Cambios Realizados

### 1. Cinco canales creados con su prompt de partida (archivo 01)

Cada uno con `01-2026-10-03_19-36-22-apertura-canal.md`: firma del director, explicacion del
protocolo del canal, las 12 reglas comunes (backlog, formato de respuesta, firma, forma del
informe, testing con godot472 real, GLOBAL byte-exact, reserva de logs, git con pathspec,
UTF-8, honestidad) y el encargo actual con prioridades.

| Canal | Frente | Bytes |
|---|---|---|
| `Hy3/` | Lote N: QA M59 > BUG-090 > cita Log 1036; despues re-verify de sellos de agnes (M129 sin sello + M100/125/79/132); cola P M17/M43/M37/M168 | 6103 |
| `DeepSeek-V4.1-Flash/` | M17-Construccion (11/175) + M68 encolado; agradecimiento por M59 (BUG-087/088); aviso de no tocar M152 | 4451 |
| `agnes-3-flash/` | M168-Plantilla-De-Isla (0/104, falso-cierre); redireccion definitiva de M152; reconocimiento por 5 modulos cerrados (Log 1229) + aviso informativo del re-verify | 4970 |
| `mimo-v2.6-flash-free/` | M43-Efectos-De-Sonido (61/100, 39 [ ] [S]); M150 descartado | 4163 |
| `kimi-k3/` | M37-Museos-Y-Colecciones (36/148, 112 [ ] ejecutables); M64 y M76 descartados | 4239 |

### 2. AGENTS.md: seccion 10 reorganizada en dos modos (commit pendiente)

- Encabezado general: "Protocolo de Comunicacion entre Modelos de Lenguaje" (antes "Chat por
  Temas") + parrafo explicando los dos modos.
- **10.1 Modo Tema** (lo existente, intacto): carpetas por tema para colaboracion puntual
  entre pares; reglas 1-9 y formato `AAAA-MM-DD_HH-MM-SS_N-MODELO-descripcion.md`.
- **10.2 Modo Canal** (nuevo, 8 reglas): carpeta por modelo activo; el `01` lo escribe el
  director como prompt de partida; nombre `NN-AAAA-MM-DD_HH-MM-SS-tema-breve.md`; firma
  obligatoria con `Responde a`; sin mezclar temas en un archivo; **el backlog sigue siendo la
  fuente de tareas** (regla 6); no se eliminan mensajes; ventaja operativa para el usuario;
  origen y nota de que los hilos por tema preexistentes no se migran (seccion 19).
- EOL preservado: CRLF 1294 -> 1333 lineas, 0 CR sueltos, 0 mojibake.

### 3. Previamente en la sesion (ya commiteado)

- Cola de re-verify de sellos de agnes cargada en el backlog de Hy3 (commit 7894fb7): M129 sin
  sello + M100/125/79/132 por posible auto-verificacion (autor agnes-2.5-flash vs sello
  agnes-3-flash). Se elimino una linea obsoleta de un lote viejo (M132 63/105, M100 146/222).
- Cierre de la sesion s2 registrado en ESTADO-PARALELO (commit 8e9efcb): M137 parcialmente
  desbloqueado por M59 liberado (Hy4 puede arrancar el nucleo), M158 sigue bloqueado por
  M13+M38, falsos bloqueos verificados (M91 emite eventos de audio -> M53 J.7 cerrable;
  tools_save_provider.gd desconectado de SaveManager; M33/M35 maduros), M59 confirmado
  60/130 Liberado, BUG-089 (doble _ready) confirmado fixeado.


## Informes entrantes ya en el repo (hallados al verificar la colision de logs)

Al renumerar descubri que la flota ya habia trabajado en la ventana intermedia (commits en
HEAD local, pendientes de push). Sus informes estan en Logs/, no en los canales nuevos — los
canalices despues. A procesar en el siguiente turno:

| Log | Quien | Que |
|---|---|---|
| 1232 | agnes-3-flash | **M152-Principios-Innegociables CERRADO** (08:10, ANTES de mi redireccion de las 19:36 — sesion vieja, no es desobediencia). Revisar estado final de M152 |
| 1233 | Hy3 | **QA 21.8 de M59** completada |
| 1234 | Hy3 | **BUG-090 resuelto por cuarentena** |
| 1235 | Hy3 | **Cita Log 1036 ANULADA** (fila 11) |
| 1236 | agnes-3-flash | **M168-Plantilla-De-Isla CERRADO 104/104** (08:35, antes de mi asignacion — ella ya lo habia tomado y cerrado en su sesion de la manana) |

Implicaciones: el Lote N de Hy3 quedo completo (los 3 items) y agnes ya no tiene M168 pendiente
— habra que darle nuevo encargo por su canal recien creado. Mi cola de re-verify de sellos de
agnes gana prioridad: M152 ahora podria tener doble cierre (Hy3 Log 866 + agnes Log 1232).

## Errores propios (memoria del entorno)

- **Heredoc en PowerShell:** `python - <<'PYEOF'` falla otra vez (PowerShell no soporta
  heredoc; la trampa M-11 de mi propia lista). Solucion aplicada por segunda vez: escribir el
  script .py con la herramienta write y ejecutarlo con `python archivo.py`.
- **Script .ps1 escrito por write leido como ANSI:** el primer `reverify_agnes.ps1` se leyo
  con mojibake (`â€”` por `—`, `âœ…` por el emoji) y fallo el parse. Solucion: escribir los
  scripts de PowerShell **en ASCII puro** (sin em-dash, sin emojis) o pasar la logica a
  Python, que maneja UTF-8 nativamente.
- **Patron de busqueda con EOL equivocado:** AGENTS.md es CRLF puro y mi string de reemplazo
  usaba `\n` -> assert fallado. Solucion: funcion `crlf()` que normaliza
  `\n` -> `\r\n` (con `s.replace("\r\n","\n").replace("\n","\r\n")` para no doblar).
- **Bloque truncado al aqui-string largo:** el comando PowerShell con un aqui-string de 30
  lineas solo escribio 1 de las 5 reglas en el backlog. Solucion: scripts a archivo.

## Archivos Modificados/Creados

- Mensajes entre modelos/{Hy3,DeepSeek-V4.1-Flash,agnes-3-flash,mimo-v2.6-flash-free,kimi-k3}/01-2026-10-03_19-36-22-apertura-canal.md (5 nuevos)
- AGENTS.md — seccion 10 reorganizada (10.1 Tema + 10.2 Canal)
- Logs/NUMEROS_DISPONIBLES.txt — 1237 consumido; cabeza 1238
- Logs/1237-modo-canal-mensajes-por-modelo_2026-10-03_19-47.md — este log

## Push con huella (seccion 4.3)

Rango empujado: **ee9914f..ac8f4f5** (2026-10-03, 19:55, atria-Dawn-Preview, Kilo Code) — push principal del Modo Canal: 5 carpetas con su archivo 01 + AGENTS.md (secciones 10.1/10.2) + Log 1237 + pool. origin/main == HEAD == ac8f4f5.


## Proximos pasos

1. Push de este lote (canal + AGENTS.md) y entrega al usuario de los 5 prompts cortos
   ("leé tu carpeta en Mensajes entre modelos/<modelo>/").
2. Crear canal de **Hy4** al asignarle M137 (nucleo: escena + jugador + camara; M11 pendiente).
3. Monitorear los primeros informes entrantes por los canales nuevos; registrar en
   ESTADO-PARALELO si hay cambios de frente.
