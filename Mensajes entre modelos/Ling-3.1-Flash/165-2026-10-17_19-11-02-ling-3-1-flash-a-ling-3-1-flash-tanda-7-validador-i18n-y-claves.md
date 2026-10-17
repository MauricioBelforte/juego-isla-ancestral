# 165 - Tanda 7: validador i18n reutilizable (tarea 27) + tareas 25/28 — Bloque C cerrado

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 19:11:02
**Responde a:** Ling-3.1-Flash - 164-2026-10-17_18-47-01-ling-3-1-flash-a-ling-3-1-flash-tanda-6-bloque-b-pt-completo.md

Ronda 22:00/22:10 (cron 10-min): sin encargo nuevo del director en el canal (mi 164 seguía siendo el último; pool cabeza 165). Ciclo V2 §2 → siguiente tarea de la COLA ACTIVA del backlog: tareas 25, 27 y 28 del Bloque C.

## Tarea 27 — CREADO `scripts/validar_i18n_integridad.py`

Script reutilizable (python stdlib, report-only, **exit 0=limpio / 1=errores**), adaptación python del "control integridad" del estándar 142. Chequeos:

1. Conteo recursivo de claves por catálogo (ES/EN/PT).
2. UTF-8 estricto, 0 BOM, 0 U+FFFD, 0 CRLF, 0 claves duplicadas (`object_pairs_hook`).
3. Paridad de claves ES↔EN↔PT (faltantes/extra por dirección).
4. Paridad de placeholders `{...}` por clave común.
5. Copias ES→PT (valores idénticos) con clasificación cognato/neutral vs sospechoso.
6. Estado cruzado JSON↔.po (comunes / solo-JSON / solo-.po) — insumo de la conciliación bloqueada (msg 153); la divergencia se reporta como ADVERTENCIA, no error.

**Ejecución** (`python scripts/validar_i18n_integridad.py`): **LIMPIO, exit 0** — ES/EN/PT 146/146/146; paridad 0/0/0 en las 3 direcciones; 0 discrepancias de placeholders; copias ES→PT: 31 cognatos/neutrales, 0 sospechosos; cruzado **121/25/115** (idéntico al insumo documentado en msg 153 — validación cruzada entre la metodología de Tanda 1 y el nuevo validador). `--verbose` lista las 115 solo-.po.

## Corrección de conteo (honestidad metodológica)

Tandas 1-6 reportaron **"147"** claves. Causa encontrada: el walk de los scripts ad-hoc de Tanda incluía la clave de metadatos `idioma` (código de locale, no traducible) al recorrer el documento completo. El conteo correcto de claves traducibles bajo `cadenas` es **146** (verificado: estructura plana, 0 dicts anidados, 121 comunes + 25 solo-JSON = 146; archivos intactos desde `074c45b`, `git log` del directorio limpio). Impacto: solo en el número reportado — ninguna paridad, placeholder ni integridad cambiaba (la clave `idioma` existe y es correcta en los 3 catálogos).

## Tarea 25 — claves usuario-visible vs técnicas

**0 claves técnicas en los catálogos**: las 146 claves JSON + 236 msgids .po son 100% contenido visible (etiquetas UI, mensajes, diálogos NPC, capítulos de historia, settings). Los 25 solo-JSON (`ui.*`, `msg.*`, `npc.*`, `eventos.historia_c*`) son contenido visible ausente del .po — deuda de la conciliación bloqueada (msg 153), **NO ejecutada**. Grep `key_*` en `scripts/` (15 hits): todos `Input.is_key_pressed` / `security_key_manager` — ninguno es clave de traducción.

## Tarea 28 — SETTINGS.* M91 (4 claves)

**4/4 presentes y traducidas en ES/EN/PT**: Ambiente/Ambient/Ambiente · Voces/Voices/Vozes · Interfaz/UI/Interface · Cinemáticas/Cinematics/Cinemáticas. Las 4 también en `locales/es.po` (msgstr verificados). El mojibake de consola al leerlas es display cp1252 de PowerShell, no corrupción (UTF-8 strict, 0 U+FFFD en disco).

## Clasificación de cognatos refinada

El validador marcó 3 "sospechosos" que la revisión confirmó como **cognatos legítimos PT**: 'Favoritos' (plural idéntico en PT), 'Cinemáticas' (idéntica en PT), 'Enter para continuar' (tecla Enter, igual en PT-BR). Añadidos a la lista: **31 válidas** (29 cognatos + 2 neutrales '???' / '{tipo}: {item}') — coincide con el "31 válidas" de Tanda 6.

## Estado

- Backlog: tareas **25/27/28 `[x]`** con evidencia inline → **Bloque C (19-28) cerrado**.
- Pool del canal: cabeza 166, restan 149. Tracking `.ultima-revision-ling.txt` = 165.
- HEAD antes del informe: `77bf431` (commits de otros agentes; mi último commit sigue siendo `074c45b`).
- Próximos candidatos: Bloque D (M88 fuentes — tarea 31, glifos PT: los 7 caracteres exclusivos de Tanda 5) o lo que ordene el director.
