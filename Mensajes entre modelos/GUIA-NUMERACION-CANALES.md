# GUIA DE NUMERACION DE CANALES — SOP (fundador 23oct 04:30: "si no tenemos esa guía deberíamos crearla", para no repetir esto siempre igual)

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23 04:30

## CUÁNDO USARLA
Cuando un canal de `Mensajes entre modelos/<agente>/` queda con: números duplicados (gemelos por apuración con crons en paralelo), huecos, desorden cronológico, o después de un día de producción masiva con cron + apiladores corriendo.

## LA ESTRATEGIA DEL PROYECTO (validada por el fundador 23oct 04:26 — NO sufijos -B, NO índice-cronológico-sin-renumerar)
**RENUMERACIÓN SECUENCIAL COMPLETA por fecha cronológica real** (mismo patrón que el canal DS-OC renumerado 001-096):
1. Ordenar todos los `.md` del canal por fecha/hora del nombre.
2. Renombrar secuencialmente `001` a `NNN` (dos pasadas: primero a `tmp__`, luego a final — evita colisiones).
3. Generar `INDICE-CANAL.md` con el **mapping viejo→nuevo** (las citas históricas a números viejos resuelven con esa tabla; el contenido nunca se edita, solo se renombra).
4. Re-sembrar `NUMEROS_DISPONIBLES.txt` = `NNN+1` a `+40`.
5. Resetear el puntero `.ultima-revision*.txt` al último número.

## HERRAMIENTA (no reescribes nada)
`python -X utf8 scripts/renumerar_canal.py "Mensajes entre modelos/<canal>"`
— hace los pasos 1-5 en una corrida (tolera archivos-fantasma NTFS con try/except; los omite del sweep).

## LAS 3 TRAMPAS QUE LA HERRAMIENTA EVITA
1. **Gemelos**: crons + apiladores en paralelo consumen/borran el mismo número → 23 duplicados acumulados en una noche en el canal Beam.
2. **Predicción de nombres**: apilar con número "proximo" sin consumir del pool → gemelo garantizado. REGLA: consumir del pool EN el mismo acto de escribir.
3. **Sembra corta**: pool diario pequeño se agota en 10 mensajes → sembrar ≥ 30-40 números por adelantado en días de producción.
4. **Fantasma NTFS**: ruta > 260 chars (MAX_PATH) es listada por `scandir` pero `open/rename` dan ENOENT → skip con try/except (contenido ya versionado en git).
5. **Referencias históricas**: NUNCA editar logs antiguos para arreglar números — resuelven con el mapping del `INDICE-CANAL.md`.

## MANTENIMIENTO PREVENTIVO
- Pool de cada canal: mantener ≥ 20 números libres; los días de producción sémbralo ≥ 30-40.
- Los apiladores (CRON E/F) deben CONSUMIR head del pool en el mismo acto de escribir.
- Si aparece un gemelo igual: renombra inmediato (no lo dejes acumular).

Firma: GLM-5.3 Flash-Director / Kilo Code.
