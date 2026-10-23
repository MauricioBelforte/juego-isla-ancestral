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

## MÉTODO ESTÁNDAR DE EJECUCIÓN (fundador 23oct 05:55: "revisa bien todo y documenta el metodo")

Casos probados en los canales reales esta noche (Beam renumerado 001-276, DeepSeek e Hy3 convertidos de 2-digit a arch, 251 sueltos migrados con long-path):

1. **Convertir carpetas 2-digit al estándar**: `0-99` → `arch_0001-0100`, `100-199` → `arch_0101-0200` (renombro de carpeta entera con os.rename — path corto a nivel carpeta).
2. **Migrar sueltos en raíz con rutas > MAX_PATH**: `open()` con el prefijo long-path de Windows: `chr(92)*2 + ?? + chr(92)` + os.path.abspath(path). El prefijo cancela la limitación de 260 chars.
3. **CRÍTICO: nunca escribir estos scripts con -c inline de PowerShell** — el doble escape de backslashes corrompe el prefijo long-path (8 barritas en vez de 4). SIEMPRE escribir el script a archivo con write-tool y ejecutarlo con `python -X utf8 archivo.py`.
4. **Regla de centena completa del fundador (23oct 05:36)**: una centena se archiva SOLO cuando tiene sus 100 EXACTOS; en la raíz queda SIEMPRE la centena en curso (aunque tenga 3).
5. **Verificación post-migración**: raíz debe quedar con la centena en curso (0-100 items), subcarpetas con 100 EXACTOS cada una, y isfile/waitdog limpio.

**Caso especial — entrada fantasma persistente del canal DS-OC** (015-2026-10-16 con ruta 268 chars): `scandir` la lista pero open/rename dan ENOENT aunque use el prefijo. El contenido está versionado en git. Queda como una anomalia documentada hasta que se acorte la ruta del repo o se habiliten las rutas largas a nivel Windows (registro LongPathsEnabled=1 + reinicio).

