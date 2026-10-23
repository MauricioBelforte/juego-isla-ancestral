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
## PASO ADICIONAL OBLIGATORIO (fundador 23oct 04:38: faltaba corregir la numeracion dentro de cada archivo y referencias)
6-int. Corregir la PRIMERA LINEA de cada mensaje renombrado: numero nuevo + retener el viejo como rastro: e.g. # 043 - director -> ... (antes 226)
7-int. Anadir UNA nota de mapping por mensaje (SERIE RENUMERADA 23oct: mapping en INDICE-CANAL.md) — las citas internas historicas (Responde a / consumido N) NO se editan: resuelven con el (antes OLD) + INDICE-CANAL
Ambos pasos estan implementados en el ciclo del canal Beam (commit d50e06f: 181 primeras lineas + 170 notas).

## MANTENIMIENTO: SUBCARPETAS DE ARCHIVO (fundador 23oct 05:40: agrupar las carpetas cada 100 mensajes, dejando libre los ultimos 100)

Cuando la raiz de un canal supere los 100 mensajes: mover todos los viejos a subcarpetas rch_0001-0100/, rch_0101-0200/... por rangos de 100, dejando en la raiz SOLO los ultimos 100 + NUMEROS_DISPONIBLES.txt + .ultima-revision*.txt.
- Los nombres de archivo NO se cambian (el numero original conserva la trazabilidad citable).
- Los archivos-fantasma NTFS (>260 MAX_PATH) no se pueden mover: quedan en raiz con skip documentado.
- El detector CRON A/B escanea primer nivel: los viejos en subcarpeta salen del sweep (mas rapido, sin perdida).
- Implementado en los 8 canales (23oct 05:40): 1.146 archivos movidos en 19 subcarpetas, 12 fantasma NTFS quedados en raiz.

