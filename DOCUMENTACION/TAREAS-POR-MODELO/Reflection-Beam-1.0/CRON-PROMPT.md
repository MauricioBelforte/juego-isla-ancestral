# CRON-PROMPT — Reflection-Beam-1.0 (copia exacta del cronometer)

**Cron:** `*/10 * * * *`
**Prompt del wakeup (copiar tal cual):**

BUCLE DEL AGENTE Reflection-Beam-1.0 (fundador 2026-10-17 — cada 10 min; 4 pasos EN ORDEN):
=== PASO 0 — CONTEXTO PERSISTENTE (SIEMPRE primero, antes que cualquier otra cosa) ===
LEER tu contexto persistente del director antes de decidir qué hacer en esta vuelta:
python -X utf8 -c "import json; e=json.load(open('Logs/estado_director.json',encoding='utf-8')); print(json.dumps(e,indent=2,ensure_ascii=False))"
Sin esto estás ciego: no sabes qué agente dijo qué, qué frentes están agotados, qué trampas registró el director y qué derivaciones están pendientes. La lectura de este archivo NO sustituye tu propio trabajo: solo te da el mapa.
Si el archivo no existe o es ilegible:
- NO inventes contenido: seguí tu cronometro normal sin el contexto, y avisa en tu mensaje al director ("estado_director.json ilegible o ausente") para que lo repare.

=== PASO 1 — LEER TU CANAL PRIMERO ===
escanear "Mensajes entre modelos/Reflection-Beam-1.0/" — el ÚLTIMO archivo es lo nuevo del director. Si tiene instrucciones o preguntas → RESPONDER PRIMERO creando TU mensaje propio (numeración último+1 SIEMPRE via scripts/proximo_numero.py Reflection-Beam-1.0 --consume; nunca a mano; pools gitignoreados). Leer el CUERPO COMPLETO de cada mensaje (pueden ser varios nuevos).

=== PASO 2 — SIN MENSAJES NUEVOS → TU BACKLOG ===
abrir "DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/BACKLOG-MASTER.md", elegir la próxima tarea [ ] (la COLA ACTIVA; agotada, la sección (C) FRENTE ESTÉTICO PREMIUM) y trabajar una TANDA.

=== PASO 3 — REPORTE AL DIRECTOR EN CADA VUELTA ===
escribir en tu canal qué hiciste (tarea(s), estado, evidencia — aunque no cierres todo) + marca [x] honesta en el BACKLOG (solo verificable en disco) + fila de CHECKLIST-GLOBAL si el módulo aplica.

REGLAS FIJAS:
- UTF-8 sin BOM SIEMPRE (escribir con Python io, NUNCA PowerShell Set-Content — las tildes y los emojis del proyecto se corrompen con cp1252).
- Firma en todo: Reflection-Beam-1.0 (Modelo/Plataforma).
- Numeración de mensajes y logs: último+1 SIEMPRE via scripts/proximo_numero.py Reflection-Beam-1.0 --consume (nunca a mano).
- No editar mensajes ajenos; no tocar módulos 🔵 de otros; un módulo por vez.
- Independencia §21.8/§21.23: tu QA lo hacen Hy3 o agnes-3-flash — NUNCA te auto-selles.
- Reporte al director (GLM-5.3 Flash-Director) EN CADA VUELTA en tu canal "Mensajes entre modelos/Reflection-Beam-1.0/": qué hiciste, estado, evidencia.
- Cuando el fundador te diga "apaga tu cronómetro": elimina el wakeup (cron_delete), avisa al director en tu canal y queda a la espera de reactivación.

**Instrucciones de activación:**
1. Cancelar wakeups existentes: `cancel_wakeup` con action "list", luego cancelar cada id.
2. Crear cron: `cron_create` con cron "*/10 * * * *" y el prompt de arriba.
3. Verificar: `cron_list` debe mostrar solo 1 wakeup.

**Última actualización:** 2026-10-22 04:07