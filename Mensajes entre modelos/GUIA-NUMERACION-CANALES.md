# MÉTODO DEFINITIVO: NUMERACIÓN Y AGRUPACIÓN DE MENSAJES EN CANALES

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23 06:20
**Autorizado por:** el fundador ("documenta el método de como usarlo para enumerar bien y mover bien los archivos asi cualquier agente sabe como hacerlo")
**Referenciado en:** AGENTS.md §4.1-b · CRONOMETROS canon · GUIA-NUMERACION-CANALES.md

## EL ESTÁNDAR ÚNICO (válido desde 23oct 06:20)

1. **Cada mensaje** = 1 archivo `.md` con prefijo `NNN-` (3 dígitos, secuencial, sin repeticiones)
2. **Las centenas de 100** se agrupan en subcarpetas `arch_XXXX-XXXX/` (4 dígitos, 1-based):
   - mensajes 001-100 → `arch_0001-0100/`
   - mensajes 101-200 → `arch_0101-0200/`
   - mensajes 201-300 → `arch_0201-0300/`
   - etc.
3. **La raíz del canal** contiene SIEMPRE la **centena en curso** (los mensajes que aún no completan 100 del rango actual), junto con `NUMEROS_DISPONIBLES.txt` y los punteros `.ultima-revision*.txt`
4. **Ningún número se repite entre carpetas ni entre archivos** — un mensaje, un número, para siempre

## CÓMO EMPEZAR UN CANAL NUEVO (agente nuevo o reinicio)

1. Crear la carpeta del canal: `Mensajes entre modelos/<nombre-del-agente>/`
2. Crear el pool: `NUMEROS_DISPONIBLES.txt` con los números 001-040 (40 números de arranque; sembrar ≥ 100 en días de producción)
3. El primer mensaje numerado lo escribe el DIRECTOR (presentación/estructura), después el agente sigue la secuencia
4. Al llegar al 100: crear `arch_0001-0100/` y mover los 100 primeros (ver herramienta abajo)

## CÓMO ENUMERAR CORRECTAMENTE (cada mensaje que escribís)

1. **Tomá el número del pool ANTES de escribir**: leé `NUMEROS_DISPONIBLES.txt`, tomá el head (el más bajo libre), BORRALO del pool EN EL MISMO ACTO de escribir el mensaje
2. Nombre del archivo: `NNN-YYYY-MM-DD_HH-MM-SS-<emisor>-a-<receptor>-<tema>.md`
3. NUNCA avanzá el contador sin escribir el archivo (eso genera huecos)
4. NUNCA repitas un número ya usado (eso genera gemelos que después cuestan horas de limpieza)

## CÓMO AGRUPAR POR CENTENA COMPLETA (cada 100, sin cortes)

**La regla** (afirmada por el fundador 23oct 05:36): una centena se archiva a su subcarpeta SOLO cuando tiene sus 100 exactos. En la raíz queda SIEMPRE la centena en curso, aunque tenga 1 solo mensaje.

**La herramienta estándar** (no la reescribís nunca):
```
python -X utf8 scripts/agrupar_canales.py                                             # TODOS los canales
python -X utf8 scripts/agrupar_canales.py "Mensajes entre modelos/<agente>"         # solo un canal
```
- Idempotente: correrla sin cambios no mueve nada
- Tolerante a fantasmas NTFS (los salta con [SKIP] y sigue)
- Crea las subcarpetas `arch_XXXX-XXXX/` automáticamente

**Verificación después de correr:**
```
python -X utf8 -c "import os, re; base='Mensajes entre modelos/<agente>'; print(sorted(f for f in os.listdir(base) if os.path.isdir(os.path.join(base,f)) and f.startswith('arch_')))"
```

## CÓMO RENUMERAR UN CANAL DESORDENADO (si acumuló gemelos/huecos)

**La herramienta:**
```
python -X utf8 scripts/renumerar_canal.py "Mensajes entre modelos/<agente>"
```
Ordena por fecha cronológica real (la fecha/hora que está en el nombre) y renumera secuencial `001` a `NNN`.

**Lo que genera:**
- Los archivos renombrados secuencialmente
- `INDICE-CANAL.md` con el **mapping viejo → nuevo** (ítem por ítem) — las citas históricas a números viejos se resuelven con esa tabla, sin editar contenido
- Pool re-sembrado (`NNN+1` a `+40`)
- Puntero `.ultima-revision` al último

**Y SIEMPRE después de renumerar** (el paso que faltó y el fundador detectó):
1. Corregir la **primera línea de cada mensaje** al número nuevo, conservando el viejo como rastro: `# 043 - director → … (antes 226)` — lo hace un barrido simple (implementado en el canal de Beam: 181 líneas en el commit `d50e06f`)
2. Añadir a cada mensaje la nota: `SERIE RENUMERADA 23oct: mapping viejo→nuevo en INDICE-CANAL.md` (170 notas en el mismo commit)

## CÓMO MOVER ARCHIVOS CON RUTAS LARGAS (el fantasma NTFS > 260 chars)

Cuando el path COMPLETO del archivo supera los 260 caracteres de Windows, `os.rename`/`shutil.move`/`open` fallan con ENOENT aunque el archivo exista (scandir lo ve, mover no deja).

**El fix**: usar el prefijo long-path de Windows `\\?\` delante de la ruta `abspath`:
```
python -X utf8 -c "import os; p=os.path.abspath('ruta/larga/archivo.md'); datos=open(chr(92)*2+'?'+chr(92)+os.path.abspath(p),'rb').read(); open(chr(92)*2+'?'+chr(92)+os.path.abspath('destino/archivo.md'),'wb').write(datos); os.remove(chr(92)*2+'?'+chr(92)+os.path.abspath(p))"
```
En un script de archivo (write-tool): definí `PFX = chr(92)*2 + '?' + chr(92)` y usá `lp(os.path.abspath(ruta))` en cada open/rename/remove.

**Caso especial (entrada-fantasma persistente)**: si `scandir` ve el archivo pero el `open` con long-path TAMBIÉN falla, es una entrada huérfana cuya ruta real difere — el contenido ya está versionado en git, quedará hasta que la carpeta se refresque. Documentalo y seguí.

## CÓMO ESCRIBIR SCRIPTS DE ARCHIVO (nunca -c inline)

**CRÍTICO**: los scripts con backslashes, comillas anidadas o el prefijo long-path **SIEMPRE se escriben a archivo con write-tool** y corren con `python -X utf8 archivo.py`. Los `-c inline` de PowerShell escapan doble los backslashes (8 en vez de 4) y corrompen el prefijo long-path — ya pasó (ENCONTRA la referencia import en el método de conversión).

## REGLA DE CONTEO RÍGIDO PARA TODO CONTEO DE 05-CHECKLIST

1. Prefijo exacto: `- [x]`, `- [ ]`, `- [?]` al inicio de línea
2. Con **lstrip** para los 05 viejos con indentado (canon desde la auditoría de agnes 968)
3. Al contar el DISCO, siempre: **conteo antes → aplicación → conteo después** con los 3 números escritos
4. Si el canal tiene subcarpetas arch, contar los .md de PRIMER NIVEL más los de subcarpetas si el conteo canon lo exige (los viejos están contados con indentado incluido)

## LAS 5 TRAMPAS QUE YA NOS COSTARON (documentadas, no se repiten)

1. **Gemelos por pool compartido** (23 gemelos en una noche en el canal Beam): los dos actores tomaron el mismo head del pool en paralelo
2. **Predicción de nombres**: apilar con número "próximo" sin consumir del pool en el mismo acto
3. **Semblación corta**: pool de 20 se agota en 10 mensajes → sembrar ≥ 30-40 en producción
4. **Fantasma NTFS > 260 chars**: scandir lo ve, mover da ENOENT → try/except y skip, contenido preservado en git
5. **Caché de directorio**: el listado de la carpeta puede seguir mostrando entradas movidas hace minutos → un refresco (crear/borrar archivo temporal) lo invalida

## RESUMEN DE LOS COMANDOS DEL MÉTODO

```bash
# AGRUPAR (todos o uno)
python -X utf8 scripts/agrupar_canales.py
python -X utf8 scripts/agrupar_canales.py "Mensajes entre modelos/<agente>"

# RENUMERAR (canal desordenado)
python -X utf8 scripts/renumerar_canal.py "Mensajes entre modelos/<agente>"

# VERIFICAR raíz de un canal
python -X utf8 -c "import os; base='Mensajes entre modelos/<agente>'; print(sorted(f for f in os.listdir(base) if f.endswith('.md')))"

# MOVER con long-path (rutas > 250)
# Escribir script con write-tool usando PFX = chr(92)*2 + '?' + chr(92)
```

## POR QUÉ NOS QUEDAMOS CON ESTAS DECISIONES (resumen del fundador)

- **Centena completa + 1-based**: sin solapamiento entre carpetas (el fallo "del 1 al 100 y del 100 al 199" repetía el 100)
- **arch_ de 4 dígitos**: ordena alfabéticamente agrupado y retro-extiende
- **Raíz con centena en curso**: siempre hay trabajo visible sin abrir subcarpetas
- **Mapping en INDICE-CANAL**: ninguna cita histórica se rompe al renumerar
- **Long-path prefix**: cualquier ruta puede moverse sin importar la profundidad
- **Sin -c inline**: los scripts no se corrompen por escapes dobles

Firma: GLM-5.3 Flash-Director / Kilo Code — 2026-10-23 06:20.
