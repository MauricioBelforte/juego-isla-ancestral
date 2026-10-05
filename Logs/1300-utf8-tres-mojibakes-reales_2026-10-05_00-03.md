# Log 1300: Job UTF-8 vuelve a verde — 3 mojibakes reales en archivos de agentes

**Fecha:** 2026-10-05
**Hora:** 00:03
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

El job "UTF-8 sin BOM (AGENTS §28)" volvio a FALLAR en CI (run 37254831038, commit
9e2bea8) despues de haberlo dejado en success en el Log 1275. Diagnostico y reparacion
de los 3 marcadores encontrados.

## Cambios Realizados

### Diagnostico

`python scripts/diagnosticar_mojibake.py` local:

```
--- SUCIO (3) ---
       2  ./Mensajes entre modelos/space-bunny-alpha/13-2026-10-05_01-15-00-sb06-gate-anti-cjk.md
       1  ./DOCUMENTACION/TAREAS-POR-MODELO/space-bunny-alpha/BACKLOG-MASTER.md
       1  ./Mensajes entre modelos/atria-dawn-s2/15-2026-10-04_20-50-00-ci-aceptado-job5-m62-delegado.md
```

### No eran falsos positivos: eran mojibakes REALES

Extraje los codepoints exactos de cada marcador (la consola PowerShell es cp1252 y no
puede mostrarlos; tuve que volcarlos a archivo UTF-8):

| Archivo | Linea | Bytes | Intencion del autor |
|---|---|---|---|
| sb13 (space-bunny) | 35 | ``(`Ã©`, `Ã±`)`` U+00C3+00A9, U+00C3+00B1 | ``(`é`, `ñ`)`` |
| BACKLOG space-bunny | 114 | ``(`Ã©`)`` U+00C3+00A9 | ``(`é`)`` |
| mi canal 15 (director) | 14 | `` `Â§` `` U+00C2+00A7 | `` `§` `` |

Los tres autores querian escribir caracteres legibles (`é`, `ñ`, `§`) y sus plataformas
escribieron los bytes mojibake (`Ã©`, `Ã±`, `Â§`). La INTENCION era mostrar el caracter
limpio; reparar restaura el texto original.

### Verificacion de que no era el caso E (lineas que documentan el sintoma)

El selftest del detector tiene un caso E ("lineas que documentan el sintoma -> no
cuentan") con `PAT_LINEA_DOC` (palabras como 'mojibake', 'caracteres rotos',
'doble-codificacion'). Revise las 3 lineas: **ninguna contiene esas palabras clave**,
asi que la heuristica E no las filtra, y esta bien que no las filtre: no son
documentacion del sintoma, son texto normal con el caracter equivocado.

Tambien verifique el CJK del archivo sb13 (lineas 47/49/53/77/127: `能力强`, `顶尖`,
`分散`, `为生产力而生`, `自由`): es **CJK intencional** — space-bunny documenta
ejemplos de lo que caza su gate anti-CJK (SB-06). El detector de mojibake NO lo marca
correctamente (PAT no cubre CJK). No se toca.

### Reparacion

3 edits precisos (sin `fix_encoding.py` — para 3 caracteres, edit manual auditable):

1. `Mensajes entre modelos/space-bunny-alpha/13-2026-10-05_01-15-00-sb06-gate-anti-cjk.md:35`
2. `DOCUMENTACION/TAREAS-POR-MODELO/space-bunny-alpha/BACKLOG-MASTER.md:114`
3. `Mensajes entre modelos/atria-dawn-s2/15-2026-10-04_20-50-00-ci-aceptado-job5-m62-delegado.md:14`

### Quien rompe CI y quien no

| Archivo | Versionado | Rompe CI |
|---|---|---|
| sb13 (space-bunny) | SI (tracked, limpio en working tree) | **SI — era el unico** |
| BACKLOG space-bunny | no (`??` untracked) | no (CI no lo ve) |
| mi canal 15 (director) | no (`??` untracked) | no (CI no lo ve) |

El fallo de CI era **solo por sb13**. Los otros 2 se reparan igual (higiene: cuando se
commiteen, ya estaran limpios), pero no se commitean en este log porque no son mios:
- El BACKLOG es de space-bunny (su carpeta `TAREAS-POR-MODELO/space-bunny-alpha/`).
- El 15 es un mensaje del **director** en mi canal; lo reparo y lo dejo untracked para
  que el director lo commitee cuando quiera.

### Limpieza de temporales

Borre mis archivos temporales de diagnostico de esta sesion: `_cp.txt` (volcado de
codepoints), `_moji.txt`, `_moji2.txt`, `_chk.json`, `_chk2.json`, `_utf8.txt`. El
propio `_cp.txt` era detectado como SUCIO (11 marcadores: eran los codepoints CJK/emoji
que volque para inspeccionarlos) — al borrarlo el detector quedo en 0.

### Verificacion final

```
SUCIO           0
IRREVERSIBLE    0
EXIT=0
```

## Archivos Modificados/Creados

- `Mensajes entre modelos/space-bunny-alpha/13-2026-10-05_01-15-00-sb06-gate-anti-cjk.md` (L35)
- `DOCUMENTACION/TAREAS-POR-MODELO/space-bunny-alpha/BACKLOG-MASTER.md` (L114, sin commit)
- `Mensajes entre modelos/atria-dawn-s2/15-2026-10-04_20-50-00-ci-aceptado-job5-m62-delegado.md` (L14, sin commit)
- `Logs/1300-utf8-tres-mojibakes-reales_2026-10-05_00-03.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1300 consumido; nueva cabeza 1301)

## Huella de push (AGENTS.md seccion 4.3)

Se completa tras el push.
