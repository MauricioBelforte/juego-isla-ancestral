# Formato de cronómetro del director (para reactivar mañana)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-15

> Guardado por pedido implícito del fundador ("hoy es un nuevo día, ¿anotaste cómo
> hacer el cronómetro en tu carpeta?"). La metodología que funcionó fue la que step-5
> registró en `TAREAS-POR-MODELO/step-5-kilocode/FORMATO-CRONÓMETRO-FUNDADOR.md`;
> esta es la versión del DIRECTOR (mimo), adaptada a mi rol de pasamanos.

## La idea central (las dos mitades)

El cronómetro de 5 minutos se dispara aunque no haya mensajes del director.
El error clásico del director es responder "sin mensajes nuevos" y no producir nada
— el fundador pierde el ciclo. La solución son dos mitades y las dos son necesarias:

1. **Mitad de monitoreo (lo de siempre):** escanear TODOS los canales sin filtro,
   leer los nuevos, procesarlos (flip/edición de fila/responsa), mantener
   `.ultima-revision-mimo.txt` al día.
2. **Mitad de producción:** si no hay mensajes entrantes, el director NO se queda
   quieto — trabaja su propia cola: `BACKLOG-DIRECTOR.md` / `BACKLOG-MASTER.md`,
   cola de muestreos pendientes, cierres de módulos 🟡, o tareas que el fundador
   haya dejado escritas.

**Regla operativa en una línea:** *el ruido va primero; si no hay mensajes nuevos,
no digas "sin nada" — trabajá en la tarea del fundador.*

## Prompt listo para copiar/pegar mañana

```
REACTIVAR BUCLE DE DIRECTOR (mimo-v2.6-flash-free). Cronómetro: cada ciclo = 1 ronda
de monitoreo + 1 unidad de producción.

CICLO (timeout 360000 ms):
1) $env:PYTHONIOENCODING='utf-8'; python scripts/scripts-reutilizables/ver_mensajes.py
   — SIEMPRE SIN FILTRO (Select-String está prohibido: el escáner re-muestra backlog
   viejo como NUEVO; ignorar los ya leídos).
2) Si hay mensajes NUEVOS → leerlos COMPLETO, procesar (fila CHECKLIST-GLOBAL con la
   línea exacta leída, flips, responsa con rondaNN.py en temp, commit con paths
   explícitos), actualizar .ultima-revision-mimo.txt.
3) Si NO hay mensajes → NO reportar "sin mensajes": ejecutar 1 unidad de producción
   del BACKLOG-DIRECTOR.md (o de la cola que el fundador haya indicado).
4) Repetir con: Start-Sleep -Seconds 300 (o el sleep manual entre rondas).

REGLAS QUE NO CAMBIAN:
- MÉTODO DE BUCLE: ver GUIA-BUCLE-DIRECTOR.md (mismo directorio).
- Emojis/§/comillas NUNCA en python -c → siempre script rondaNN.py con
  io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8').
- CHECKLIST-GLOBAL = single-writer yo; leer línea exacta antes de editar; filas
  largas → anexar al final de Notas, nunca rfind('|').
- PROHIBIDO: reservar_mensaje.py, git add -A, commitear 11-BUGS/ESTADO-PARALELO/
  quality.yml/bootstrap.gd; sin push.
- Numeración: helpers elegir_numero_seguro/borrar del rondaNN.py; borrar del pool
  SOLO tras escribir.
- Identidad por CARPETA (Mensajes entre modelos/<modelo>/), no por IDENTITY.md.
- Al terminar ronda: reporte en mi carpeta del canal (REGLA CERO) — el director no
  ve marcas [x], solo archivos nuevos en su canal.
```

## Al apagar (cierre de sesión)

1. Terminar lo que esté en vuelo (commits pendientes primero).
2. Ronda final de LECTURA de todos los canales.
3. Reporte de cierre en `Mensajes entre modelos/mimo-v2.6-flash-free/` (número del
   pool del canal).
4. Verificar que NO queden procesos del bucle:
   `Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'ver_mensajes|Start-Sleep' }`
5. Todo commiteado con mensajes en español (pasado descriptivo). Sin push salvo
   orden explícita del fundador.
