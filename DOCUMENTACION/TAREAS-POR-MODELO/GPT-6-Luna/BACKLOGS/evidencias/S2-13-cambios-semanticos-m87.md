# S2-13 — Comparación semántica de 04-Codigo.md de M87

**Modelo:** GPT-6-Luna  
**Plataforma:** DeepAI Code  
**Fecha:** 2026-11-25  
**Alcance:** comparación read-only de la versión en el commit histórico `edb48870f942f20009757584284161c2dbf22c49` (2026-10-21) con `DOCUMENTACION/87-Localizacion/plan-actual/04-Codigo.md` del worktree actual en HEAD `6788f75a8505f1d445911ed3df4bc57d3ddcac00`. Se identifican cambios de significado, no de formato. No se ejecutó Godot ni se editó el documento.

## Identidad de las versiones

- **Histórica:** commit `edb48870f942f20009757584284161c2dbf22c49`, padre `8a51af3589bfeec37487ce10e18c22b521c79403`, fecha autor `2026-10-21T06:15:10-03:00`; SHA-256 del blob del documento `8a0307cf7f4cfd79aab5eef6fd4bcedccf91a3073447a841b386fe78e2ab5765`; 502 líneas, 43.639 bytes.
- **Actual al momento de lectura:** HEAD `6788f75a8505f1d445911ed3df4bc57d3ddcac00`; SHA-256 del worktree `6361992a56d91af1c4a25d2c6426b8385a99c260666e1c2bdbb75736b22e827e`; 522 líneas, 47.495 bytes. `git status` no mostró cambio de este documento respecto de HEAD.
- El diff mecánico Git para este archivo mostró 21 inserciones y una eliminación, pero las tres secciones semánticas siguientes resumen el contenido y no cuentan líneas/blancos como cambios conceptuales.

## Cambios semánticos

### 1. PT pasa de fuera a dentro del alcance de locale runtime

- **Histórica, §8b L223:** afirmaba que PT no era locale de runtime, que no existía `pt.po` y que el JSON PT servía para paridad.
- **Actual, §8b L223 + §8c L506-L518:** registra el GO #4 del fundador del 2026-10-27: `pt.po` de 274 entradas, `LOCALES_SOPORTADOS=["es","en","pt"]`, tabla/nombre de `LocaleUtils` para PT y regla plural añadida. El nuevo §8c también documenta la prueba de coherencia `.po` reportada en la nota y aclara que el QA visual/runtime interactivo aún estaba pendiente en esa nota histórica.
- **Cambio de significado:** la documentación cambia PT desde “no runtime” a “habilitado por cambio autorizado”. Esto actualiza la condición de idioma soportado, no prueba por sí solo la verificación runtime visual.
- **Matiz/drift remanente:** la frase inicial de §8b L223 todavía contiene la lista histórica `LOCALES_SOPORTADOS=["es","en"]` antes de la cláusula de actualización PT. La misma línea documenta ambos tiempos sin etiquetar esa primera afirmación como obsoleta, lo que puede confundir al lector. La extracción actual del código muestra `LOCALES_SOPORTADOS := ["es", "en", "pt"]` en `game/isla-ancestral/scripts/localization/localization_manager.gd:15`.

### 2. Aparece una nueva actualización de hallazgos del frente de boot/M06 y política de lenguaje técnico

- **Actual, nueva TANDA 22, §8b L251:** agrega una auditoría de literales de carga, ocho tips de loading aún propuestos para dueño M63, declaración de tareas 97/98/99 cerradas sobre idioma de comentarios/logs y seguimiento de deuda M06 con claves `ITEMS.*` aún pendientes de owner.
- **Cambio de significado:** el documento suma nuevas conclusiones de análisis y propietarios/pendientes; no dice que las ocho nuevas claves ya hayan sido implementadas. También distingue explícitamente trabajo realizado/documentado de propuestas esperando asignación.
- **Límite:** esta comparación histórica solo constata que el contenido se añadió al documento entre ambas versiones. No verifica el estado actual de `loading_layer.gd`, la implementación de las tareas ni la cola de M06.

### 3. Se agrega la ejecución autorizada de GO #4 como sección autónoma

- **Actual, nueva §8c L506-L518:** registra aprobación del fundador, artefactos PT modificados según la nota, los pasos de configuración/QA reportados y el pendiente de validación visual cruzada.
- **Cambio de significado:** el registro pasa de una afirmación negativa histórica (PT no activo) a documentar un cambio positivo posterior con evidencia y límites explícitos. La sección ancla la procedencia al Log 2217 y distingue las comprobaciones del validador reportadas de la QA visual todavía solicitada en ese momento.
- **Límite:** es evidencia documental de lo que la sección afirma que se ejecutó en 2026-10-27; esta tarea no re-ejecutó su ensayo, validador ni QA en editor.

## Sin cambio semántico identificado en el resto del diff

La comparación textual mostró que el otro cambio dentro de §8b fue la adición de la actualización de PT en la misma línea con los detalles referidos arriba; la entrada extensa de TANDA 21 preexistente se mantiene. El nuevo bloque §8c es el resto sustantivo del diff. No clasifico la variación de 502 a 522 líneas como cambio semántico por sí misma.

## Evidencia y límites

- Comandos de lectura: `git show -s --format=... edb4887`, `git rev-parse edb4887:<ruta>` y `git rev-parse HEAD:<ruta>`, `git diff --unified=0 edb4887 -- <ruta>`, extracción UTF-8 de ambos blobs y líneas actuales.
- Fuentes citadas: `DOCUMENTACION/87-Localizacion/plan-actual/04-Codigo.md` (actual §8b L223, L251 y §8c L506-L518; hash arriba); versión histórica de ese mismo archivo en `edb4887` (hash/blob arriba); `game/isla-ancestral/scripts/localization/localization_manager.gd:15` (lectura estática de lista actual; SHA-256 `6631a7469b76575f863259013d68d623fb3b0cdcdbdde60c947ca0326982a0c6`).
- Esta comparación no atribuye quién escribió un cambio, no confirma vigencia de las cifras históricas ni deduce funcionamiento runtime. No cambia el sello M87 ni subsana el drift señalado.
