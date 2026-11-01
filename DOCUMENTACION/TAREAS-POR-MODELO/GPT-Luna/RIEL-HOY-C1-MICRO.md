# RIEL-HOY-C1 — MICRO-TAREAS DE CIERRE DEL DÍA (clasificación high-volume + visión; 12 items)

**Creado por:** GLM-5.3-Flash (31oct 23:08) por orden del FUNDADOR ("solo por hoy va a trabajar en lo que mejor sepa hacer")
**Para:** GPT-5.6 Luna (OpenAI `gpt-5.6-luna`) — su ficha: clasificación high-volume/latency-sensitive, visión (MMMU-Pro 78.4, LMArena Vision 1257), tool-use/JSON, contexto 1.05M.
**Motor:** tus salidas van CORTAS por ítem (anti-truncamiento — tu límite conocido) + EXCLUIR lo censado ya por Nemotron (evita duplicar: sus D1/I1 citan los mismos censos — lo mío complementa, no repite).

## ENVÍO (cada ítem: veredicto corto + evidencia citada archivo:L#)

| # | Tarea (alta velocidad / clasificación / visión) | Output esperado | Estado |
|---|---|---|---|
| C1-01 | Censo JSON de `Mensajes entre modelos/`: por canal → total .md, últimos 5 slugs, mensajes con pregunta sin respuesta (detección por marcador de pregunta "?" en el cuerpo) | JSON por canal | [x] 21 canales, 1266 .md, 103 candidatas — `Mensajes entre modelos/GPT-Luna/C1-01-02-censo-canales.json:L5-L7` |
| C1-02 | Clasificar esas preguntas sin respuesta por TIPO (query técnica / solicitud de tarea / aviso / otro) y por canal destino sugerido | JSON de clasificación | [x] 103; tipos 15/23/0/65 — `Mensajes entre modelos/GPT-Luna/C1-02-clasificacion-preguntas.json:L4-L5` |
| C1-03 | Censo de señales del event bus (`game/isla-ancestral/scripts/core/event_bus.gd`): declaradas / emitidas / muertas — COMPARA con el oráculo 54/20 (tu tool-use: corre `scripts/red_probe_event_bus.py`) | JSON conteo + match/no-match | [x] 54/20/34, coincide 54/20 — `Mensajes entre modelos/GPT-Luna/C1-03-event-bus.json:L3-L10`; salida literal `Mensajes entre modelos/GPT-Luna/C1-03-red-probe-output.txt:L1-L3,L24` |
| C1-04 | Visión: captura runtime del juego (`game/isla-ancestral` — run_project + screen): describir elementos visibles verbatim (textos de UI legibles), defectos si los hay | descripción + defectos | [ ] SKIP: captura existente ilegible; analyzeImage devolvió HTTP 404, sin descripción inventada — `Mensajes entre modelos/GPT-Luna/C1-12-consolidado.json:L11213-L11217` |
| C1-05 | Visión: 2ª captura de la misma escena tras interacción posible (o boot distinto): describir cambios vs C1-04 | descripción delta | [ ] SKIP: captura existente ilegible; analyzeImage devolvió HTTP 404, sin descripción inventada — `Mensajes entre modelos/GPT-Luna/C1-12-consolidado.json:L11220-L11224` |
| C1-06 | Censo `Logs/`: archivos por prefijo numérico, duplicados de nombres, tamaño total, últimos 5 por fecha | JSON por archivo | [x] 2202 archivos, 8.958.338 bytes, 2199 prefijados; duplicados y últimos 5 censados — `Mensajes entre modelos/GPT-Luna/C1-06-censo-logs.json:L3-L5,L6581-L6637` |
| C1-07 | Clasificación de los FLAGS FUNDADOR/TECNICO detectados (busca "FLAG FUNDADOR" y "FLAG TECNICO" en DOCUMENTACION): ítem, módulo, archivo, L# | JSON de flags | [x] 17 flags con módulo, archivo y línea — `Mensajes entre modelos/GPT-Luna/C1-07-flags.json:L2-L4` |
| C1-08 | Conteo de scripts `*.gd` (total, por carpeta top-10) y funciones godot (`func ` count) — alto volumen, tu especialidad | JSON de conteo | [x] 1240 scripts, 12397 funciones, top-10 — `Mensajes entre modelos/GPT-Luna/C1-08-censo-gd.json:L3-L6` |
| C1-09 | Censo `.po` (es/pt/en si existen): msgids totales, con fuzzy/sin traducir — coincidir con el oráculo Nemotron (275×3, el de su D1-004) | JSON por idioma + match | [x] 276 por idioma; fuzzy/vacías 0; HEAD=274; dos IDs locales; 275 no reproducido — `Mensajes entre modelos/GPT-Luna/C1-09-censo-po.json:L14-L29,L31-L57` |
| C1-10 | Clasificar los módulos 🔵/🔴 vigentes del CHECKLIST-GLOBAL con su agente actual (solo lectura del global — NO editar) | JSON por módulo | [x] 0 módulos bloqueados; solo columna Estado — `Mensajes entre modelos/GPT-Luna/C1-10-modulos-bloqueados.json:L6-L21` |
| C1-11 | Visión: 3er captura (escena alternativa si alcanzable por menú) o re-boot: describir + defectos | descripción | [ ] SKIP: captura existente ilegible; analyzeImage devolvió HTTP 404, sin descripción inventada — `Mensajes entre modelos/GPT-Luna/C1-12-consolidado.json:L11227-L11231` |
| C1-12 | REPORTE FINAL CONSOLIDADO del día: JSON único con todos los censos (C1-01..10) + veredictos de visión (C1-04/05/11) + contador hecho=N skip=N fail=N — dirigido a agnes-3-flash (numeración último+1, firma) | JSON consolidado en canal | [x] Consolidado 9 hecho/3 skip/0 fail — `Mensajes entre modelos/GPT-Luna/C1-12-consolidado.json:L3-L6` |

## REGLAS

- Salida CORTA por ítem (anti-truncamiento — tu límite conocido). JSON compacto.
- Las capturas van a la carpeta del módulo correspondiente (nomenclatura del repo: `cap_c1_<fecha>_gpt-luna_<nota>.png` — nunca sobrescribir).
- Si un index/censo falla: [?] + motivo (honesto) y seguís con el siguiente.
- Al terminar los 12: tu riel H1 queda agotado — sello final: agnes (directora).
- Complementar/combinar con tu T1 (T1-1 visión y T1-2 censo se pueden solapar con C1-04 y C1-01: un mismo trabajo marca ambos renglones).

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-31 23:08.
