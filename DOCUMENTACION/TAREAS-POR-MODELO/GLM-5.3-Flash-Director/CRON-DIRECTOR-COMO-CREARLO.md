# CRON DEL DIRECTOR — METODOLOGÍA V2 (2026-10-17) — estado: APAGADO por el fundador

**Modelo:** GLM-5.3-Flash-Director (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 04:35 (reescribe la receta del 2026-10-16; el fundador apagó el cron y anunció cambio metodológico total)

## Estado actual

- **APAGADO** el 2026-10-17 ~04:25 por directiva del fundador ("apaga el cronometro, tus fallos
  me llevaron a plantear esto" + "vamos a cambiar totalmente la metodologia de trabajo").
- El disparo rezagado de las 04:25 fue el último; la tarea `wku_147c69473001ydzHI7Qe642cVb`
  (cron `*/5 * * * *`) fue ELIMINADA con `cron_delete` (no con `cancel_wakeup`: los cron tasks
  viven en otra herramienta — lección registrada).
- Reactivación: SOLO cuando el fundador lo ordene, con el ciclo de 3 pasos de abajo.

## El cron v2 del director (3 pasos, en este orden — nunca cortar)

1. **RESPONDER MENSAJES de los modelos** (primera instancia, SIEMPRE): escanear los canales,
   responder con numeración de hilo calculada SIEMPRE con el helper obligatorio
   `python scripts/proximo_numero.py <canal> --consume` (máximo + 1, detecta colisiones —
   NUNCA a mano: motivación, error 52/53 del 2026-10-17 08:37; pools NO se commitean — gitignoreados).
2. **VERIFICAR LOS BACKLOGS** (`DOCUMENTACION/TAREAS-POR-MODELO/<MODELO>/BACKLOG-MASTER.md`):
   cada uno debe tener tareas `[ ]` por hacer (100+ disponibles); si queda corto, AGREGAR tareas
   por nicho con evidencia (GUIA-COMPARATIVA 10 + estado real del proyecto).
3. **RECORDATORIO:** si un modelo con tareas disponibles pasa MUCHO tiempo sin avanzar ni
   responder → escribirle un recordatorio en su canal (una sola vez por ciclo, sin spamear).

## Cómo crearlo (cuando el fundador ordene reactivarlo)

Herramienta `cron_create` de Kilo Code. Prompt (pegar tal cual):

```
BUCLE DEL DIRECTOR V2 (fundador 2026-10-17 — 3 pasos EN ORDEN):
[1] RESPONDER MENSAJES: escanear 'Mensajes entre modelos/<canal>/ ' — todo mensaje nuevo NO
    procesado dirigido a mí (GLM-5.3 Flash-Director) se responde primero (numeración último+1,
    borrar SOLO ese número del pool del canal; pools gitignoreados). Sin mensajes: continuar.
[2] BACKLOGS DE FLOTA: verificar que cada 'DOCUMENTACION/TAREAS-POR-MODELO/<MODELO>/BACKLOG-MASTER.md'
    tenga tareas por hacer (100+); agregar tareas si queda corto (nicho + GUIA-COMPARATIVA +
    estado del proyecto). Actualizar el backlog y la fila GLOBAL según los reportes de cierre.
[3] RECORDATORIOS: si un modelo con tareas disponibles pasa mucho tiempo sin avanzar ni
    responder → escribirle UN recordatorio en su canal.
Reglas fijas: UTF-8 (§28), firma GLM-5.3 Flash-Director, commits con pathspec explícito
(sin -A sobre WIP ajeno), independencia §21.8/§21.23, REGLA CERO de reportes, reserva 🔵 de
módulos §21.3 en los 4 registros. Fundador: SOLO novedad material.
```

## Lección del apagado (para no repetir)

- El ciclo anterior (4 bloques, 5 min) mezcló la reactividad con el trabajo propio y dejó un
  informe de DS-Opencode (24) sin acuse ~3.5 h mientras el modelo esperaba en su canal.
- La nueva cadencia pone "responder mensajes" como PASO 1 ABSOLUTO y elimina el trabajo de
  fondo del director (delegar o dejar previsto en backlog, no ejecutar).
- Si el fundador pide otra cadencia, cambiar el cron `*/5 * * * *` por la que indique.

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-17.

---

## LOS PROBLEMAS DOCUMENTADOS DE LA NOCHE (2026-10-17/18 — fundador 22:49-01:30)

### 1. EL FILTRO DEL SLUG (el caso Hy3 259)

**Problema**: el scan del cron filtraba los archivos por el slug del receptor (`-a-glm` in f or `-a-director` in f). El mensaje 259 de Hy3 tenía el slug `hy3-a-hy3-recordatorio...` (auto-dirigido) — el hash matcheó `marca but not receiver` — el director lo ignoró.

**Impacto**: 8+ horas de retraso con la delegación sin responder (21:15 → 05:23).

**El fix**: el scan de los mensajes deja de filtrar por el slug del receptor y toma TODO los .md de la carpeta con el prefijo NNN; el contenido interno decide el destinatario. El nuevo cron con el método mejorado (V2.2-Reboot 2026-10-18 05:23) queda con el método sin filtrar.

### 2. EL MAX_PATH DE WINDOWS TRUNCA LOS RENAMES

**Problema**: los renames de archivos con nombres largos (los mensajes con el slug + el nombre) + el `__tmp__` que agrega el rename en 2 pasadas supera el **MAX_PATH (261 chars) de Windows** — el `os.rename` falla `FileNotFoundError` — el riel loaca.

**Broken messagess**: `item_obj_her_017.tres` (320-BOM), `informe-078-acuse-094-verificador...`, los 22 archivos de DS-OC (18-119).

**El fix**: usar el long-path `\\\\?\\D:\...` en todos los os.rename/reopen del script (el método del 02:2X del riel de 03:30). Los scripts que lo manejan: `renum_v5_lp.py` (aplicado con éxito).

### 3. LOS PREFIJOS MIXTOS SIN PADDING (el canal DS-OC)

**Problema**: los archivos del canal DS-OC confligen los prefijos sin padding (`13-`, `16-`, `60-`, `85-`) al lado de los con padding (`023-`, `041-`, `094-`, `119-`) — el orden secuencial rompe el índice, los porcentajes ruidos, los kompares viejos/etc.

**El fix**: la **renumeración secuencial por fecha** (el método del 05:1X del 03:30) — los 107 mensajes renumerados 001-107 secuenciales — con los títulos internos `# NNN` corregidos — el pool consecutivo — 0 huecos — 0 duplicados. `990b9c4` pusheado.

### 4. EL POOL DEL CANAL CON NÚMEROS YA USADOS

**Problema**: los pools de los canales quedaban con números ya usados por los mensajes (el 59 de Step-5, el 76 del informé del Step-5, el 125 del DS-OC, los 112/115/118 quemados del DS-OC, los 262/263 de Hy3 que eran los del director).

**El fix**: la regla del fundador en el 23:03 — el pool queda revisado SIEMPRE con las 5 reglas (asignar→remover, corregir→verificar usados, prueba→devolver, pierde→agregar al final, sin BOM) — el pool queda 100 consecutivos SIN los usados.

### 5. EL UTF-16-LE DEL SET-CONTENT DE PS5.1

**Problema**: el `Set-Content -Encoding UTF8` de PowerShell 5.1 escribe **UTF-8 CON BOM** (o el redirect `>` escribe **UTF-16-LE** en algunos pipelines). El `item_obj_her_017.tres` quedó en UTF-16-LE y el CHECKLIST-GLOBAL con BOM (Ling 177/178 lo detectaron).

**El fix**: **Python `io.open(p, "w", encoding="utf-8", newline="\n")`** es el ÚNICO método de escribir archivos del repo — NUNCA `Set-Content` de PS5.1 — el §28 quede el riel desde el instructivo 312 (DeepSeek-WB) con los 5 puntos del pool del método.

### 6. EL ORDEN DEL MÉTODO (post-hoc vs guía previa)

**Problema**: el archivo `COMO-CORREGIR-NUMERACION-MENSAJES.md` fue generado DESPUÉS de ejecutar la corrección (inversión del orden natural — el fundador lo reflejó).

**El fix**: la **nota de transparencia agregada** al archivo (el post-hoc documentado); la próxima re-corr VA ESTE ARCHIVO COMO GUÍA PREVIA (antes de correr) — el paso 6 queda del método.

### 7. EL CRON B SIN FALLBACK

**Problema**: el Cron A con el scan por punteros y el filtro de receptore anclado — el fundador lo documentó el 02:10: "si ahora te digo pasa por todos y encontras mensajes vas a tener que cambiar las instrucciones del cronometro".

**El fix**: el **CRON B instituido por el fundador a las :10/:30/:50** (el cron la verificación cruzada full) con la doble verificación del fundador — el 05:23 el directiva formal — el *09:10 el CRON A el 1er... — el B instituido el 22:14 — el inversionie queda del fundador.

