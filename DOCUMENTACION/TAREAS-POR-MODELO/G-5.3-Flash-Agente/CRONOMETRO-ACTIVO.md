# CRONÓMETRO ACTIVO — G-5.3-Flash-Agente

**Modelo:** G-5.3-Flash-Agente (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Última actualización:** 2026-10-21 21:24 (hora local del sistema ~01:24 GMT-3 del 21-10)
**Propósito de este archivo:** documentar SIEMPRE el cronómetro vigente (prompt exacto) para que —cuando el fundador lo pida— se re-creé igual sin reconstrucción.

## Identidad del cron vigente

| Campo | Valor |
|---|---|
| ID cron | (ver cronometro — se rota en cada re-creación; listar con `cron_list`) |
| Schedule | `*/10 * * * *` |
| Ciclo | cada 10 min, 4 pasos EN ORDEN (PASO 0 → 1 → 2 → 3) |

## PROMPT EXACTO del cron vigente (copiar tal cual al re-crear)

```text
BUCLE DEL AGENTE G-5.3-Flash-Agente (fundador 2026-10-17 — cada 10 min; pasos EN ORDEN):
=== PASO 0 — CONTEXTO PERSISTENTE (SIEMPRE primero, antes que cualquier otra cosa) ===
LEER tu contexto persistente del director antes de decidir qué hacer en esta vuelta:
python -X utf8 -c "import json; e=json.load(open('Logs/estado_director.json',encoding='utf-8')); print(json.dumps(e,indent=2,ensure_ascii=False))"
Sin esto estás ciego: no sabes qué agente dijo qué, qué frentes están agotados, qué trampas registró el
director y qué derivaciones están pendientes. La lectura de este archivo NO sustituye tu propio trabajo:
solo te da el mapa.
Si el archivo no existe o es ilegible:
- NO inventes contenido: seguí tu cronometro normal sin el contexto, y avisa en tu mensaje al director
  ("estado_director.json ilegible o ausente") para que lo repare.

=== PASO 1 — LEER TU CANAL ===
escanear "Mensajes entre modelos/G-5.3-Flash-Agente/" — el ÚLTIMO archivo es lo nuevo del director.
Si tiene instrucciones o preguntas → RESPONDER PRIMERO creando TU mensaje propio (numeración
último+1 SIEMPRE via scripts/proximo_numero.py G-5.3-Flash-Agente --consume; nunca a mano; pools
gitignoreados). Leer el CUERPO COMPLETO de cada mensaje (pueden ser varios nuevos).

=== PASO 2 — BACKLOG (elegir tarea [ ] de la COLA ACTIVA) ===
SIN MENSAJES NUEVOS → abrir "DOCUMENTACION/TAREAS-POR-MODELO/G-5.3-Flash-Agente/BACKLOG-MASTER.md",
elegir la próxima tarea [ ] (la COLA ACTIVA; agotada, la sección (C) FRENTE ESTÉTICO PREMIUM)
y trabajar una TANDA.

=== PASO 2-BIS — TU COLA REAL SON LOS 05 DE MÓDULOS NO-BLOQUEADOS (regla operativa del fundador 03:29 del 21-10; SIEMPRE vigente) ===
1. **JAMÁS esperar al director para producir.** En el disco SIEMPRE hay +100 [ ] libres en módulos
   no-bloqueados (verificado con escaneo 2-BIS.2: 28 módulos, ~1350 [ ] accionables). En cada
   vuelta: re-escaneá (uno o dos con el patrón `\s*- [ ]` por módulo), elegí [ ] concretos del
   módulo que te toque y EJECUTÁ la tanda SIN pedir permiso.
2. **El director NO asigna: solo INFORMA.** Le escribís el REPORT de lo hecho (mín 1 línea por
   vuelta) — no una consulta de "qué hago". Solo si LITERALAMENTE no existiera nada (imposible
   con el escaneo), recién ahí le pedís tareas.
3. Guardia por ciclo mientras corre la tanda: sonda ligera de suites + filas 4/4 — sin inventar
   tanda falsa ni tocar módulos con dueño/GO.

=== PASO 3 — REPORTE + 3 LUGARES SINCRONIZADOS ===
REPORTE AL DIRECTOR EN CADA VUELTA — OBLIGATORIO SIN EXCEPCIONES: escribir en tu canal
MÍNIMO 1 LÍNEA aunque no haya tanda ni novedad (guardia: suites + filas en estado). Si no
escribís, el fundador/director te ven INACTIVO (lección ping 226). La directiva “solo novedad
material” NO anula este piso por ciclo. Además: (tarea/estado/evidencia) + marca [x] honesta
en el BACKLOG + fila de CHECKLIST-GLOBAL si el módulo aplica. Y AL CERRAR la vuelta: si el director
te dio una orden o cerraste algo material, así deben quedar los 3 lugares sincronizados:
1) tu mensaje en tu canal (firma + acuse),
2) el 05-Checklist del módulo que tocaste (flips con cita en disco),
3) la fila de CHECKLIST-GLOBAL.md (solo si el módulo es tuyo y el cambio es material).

REGLAS PERMANENTES (vigentes sin excepción):
- UTF-8 sin BOM, LF: escribir SIEMPRE con Python (NUNCA PowerShell Set-Content ni >) — las
  tildes y los emojis del proyecto se corrompen con cp1252 (§28).
- Numeración SOLO del pool NUMEROS_DISPONIBLES.txt de la carpeta destino (borrás el número al
  escribirlo).
- Firma: tu modelo + plataforma + fecha; español.
- Independencia §21.8/§21.23: quien hizo el trabajo no se auto-verifica ni auto-sella (QA por
  Hy3/agnes).
- NUNCA push.
- Pausa/reanudación del cron SOLO por orden directa del fundador (avisa al director en tu canal
  al pausar/reanudar, con firma).

## Historial de cambios del cron

| Fecha | Cambio | Motivo |
|---|---|---|
| 2026-10-20 09:20 | Creación inicial (bucle 3 pasos, sin PASO 0) | orden del fundador |
| 2026-10-20 06:37 | Pausa del cron (aviso 192) | orden del fundador |
| 2026-10-21 17:11 | Re-activación (misma estructura 3 pasos) | orden del fundador |
| 2026-10-21 21:24 | **Esta versión**: + PASO 0 (contexto persistente `Logs/estado_director.json`) + **PASO 2-BIS** (cola agotada/bloqueada → pedir tareas concretas al director, con escaneo de 05s y alternativas; prohibido aceptar standby sin escaneo) | orden del fundador ("agregalo… documentes siempre el último cronometro") |
