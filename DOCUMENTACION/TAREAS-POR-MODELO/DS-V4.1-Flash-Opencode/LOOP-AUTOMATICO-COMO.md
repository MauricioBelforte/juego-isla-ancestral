# LOOP AUTOMATICO - COMO TRABAJAR EN BUCLE (sin frenarte)

**Modelo:** DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
**Plataforma:** OpenCode
**Fecha:** 2026-10-17 17:16
**Motivo:** método que SÍ funcionaba (anotado por pedido del usuario para retomar mañana)

## ROL (recordatorio)

NO soy director. Solo trabajo así:
1. **Leer mensajes del director** en mi canal (`Mensajes entre modelos/DS-V4.1-Flash-Opencode/`).
2. Si NO me escribió → ir a **mi backlog** (`DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md`), elegir UNA tarea de la cola.
3. Trabajarla con evidencia real (suites/corridas/boot).
4. **Reportar al director cuando la termino** (mensaje en mi canal) + marcas + Log.
5. Repetir.

## EL COMANDO DEL BUCLE (el que sí funciona)

Correr esto como beat de cronómetro (bloquea 5 min y al volver lista los mensajes NUEVOS):

```
Start-Sleep -Seconds 300; $env:PYTHONIOENCODING='utf-8'; python scripts/scripts-reutilizables/ver_mensajes.py
```

- Si imprime `SIN NUEVOS` → seguir con la tarea del backlog que esté en curso (o elegir la próxima).
- Si imprime `NUEVO [DS-V4.1-Flash-Opencode]: ...` → leer ese mensaje y hacer lo que pida el director ANTES de seguir.
- Repetir el comando al terminar cada vuelta. El sleep ES el cronómetro.

## NUMERACION SEGURA DE MENSAJES (la que usa el script)

Usar las funciones de `ver_mensajes.py` (NO `reservar_mensaje.py` — tiene bug de regex que matchea años):

```
import sys; sys.path.insert(0, 'scripts/scripts-reutilizables')
from ver_mensajes import elegir_numero_seguro, escribir_mensaje
n = elegir_numero_seguro('DS-V4.1-Flash-Opencode')   # pool -> verificar disco -> devolver
escribir_mensaje('DS-V4.1-Flash-Opencode', 'fecha-titulo.md', contenido)  # escribe y consume del pool
```

Regla: pool → verificar que el número NO exista en disco → escribir → recién ahí borrar del pool.

## LECCIONES DEL CIERRE (vuelta a vuelta)

1. **Log global:** mismo criterio — primer número del pool `Logs/NUMEROS_DISPONIBLES.txt` cuyo `Logs/{n}-*` NO exista en disco (colisión real 1932 con DeepSeek-WB, atrapada por este assert).
2. **Backup antes de cada cierre** en `%TEMP%\bk-backups\BK-preTNNclose\` (BACKLOG, cron, pools, marcador).
3. **UTF-8 sin BOM** siempre; escribir con `data = txt.encode("utf-8")` ANTES de abrir el archivo (NUNCA `open(wb).write(txt.encode())` — el bug de truncado del BACKLOG vino de ahí + surrogates).
4. **Sanitizador de surrogates** en textos con emoji (los `\ud83d...` rompen el encode).
5. **Marcas con assert de texto exacto** en BACKLOG (2 copias: cola + dup) y política blanket de dups 052 (citar "dup de #N, misma evidencia").
6. **Al cerrar la vuelta:** marcas BACKLOG + Log + msg al director + `.ultima-revision-ds.txt` + fila del `CRONOMETRO-V2-DS-V4.1-FLASH-OPENCODE.md` + charset scan.

## EVIDENCIA DE QUE FUNCIONA (sesión 2026-10-17)

- Vueltas 12/13/14 cerradas en bucle (sleep 300 + lectura): ítems 28 (M67 presets, 40/0), 29 (M75 postgame, 40/0), 30 (M94 motivación, 38/0) — Logs 1931/1933/1935, msgs 055/056/058.

Firma: DS-V4.1-Flash-Opencode (OpenCode).

## ALCANCE ACTUAL (aclaración del fundador 2026-10-17)

- **NO soy director.** Mi alcance es SOLO mi carpeta: respondo los mensajes de
  `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` y nada más.
- El scan `ver_mensajes.py` lista mensajes nuevos de TODOS los canales: **solo me importan
  los `[DS-V4.1-Flash-Opencode]`** — los de otros canales se ignoran (son de sus dueños).
- Si el director me escribió → responder/ejecutar eso PRIMERO.
- Si no hay mensajes míos nuevos → leer mi BACKLOG-MASTER (cola activa), elegir UNA tarea,
  trabajarla y reportarla al director cuando la termine. Repetir.

Firma: DS-V4.1-Flash-Opencode (OpenCode).
- T25 (leccion): al helper de mensajes hay que pasarle el CUERPO COMPLETO; verificar SIEMPRE read-back del mensaje antes de cerrar la vuelta (en T25 se le paso una variable equivocada y el msg 64 quedo sin cuerpo; detectado y corregido en el lugar, mismo numero).
