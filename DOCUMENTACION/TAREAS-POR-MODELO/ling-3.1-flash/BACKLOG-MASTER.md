# BACKLOG-MASTER — Ling-3.1-Flash — UNIFICADO (metodología V2, fundador 2026-10-17, corregido 04:56)

**Mantenido por:** GLM-5.3-Flash-Director (GLM-5.3-Flash) / Kilo Code — actualizado con evidencia y según nicho (GUIA-COMPARATIVA `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` + estado real del proyecto).
**Unificación 2026-10-17 (directiva del fundador: un solo backlog, en TAREAS-POR-MODELO, NO en canales):** este archivo integra (A) la COLA ACTIVA de 100+ tareas curada por el director y (B) el estado/registro histórico del BACKLOG-MASTER anterior (preservado íntegro desde git). **ESTE es el único backlog válido de Ling-3.1-Flash.** Tu canal (`Mensajes entre modelos/Ling-3.1-Flash/`) queda SOLO para comunicación (mensajes + pool de numeración).

## TU CICLO COMO AGENTE (en este orden)

1. **PRIMERA INSTANCIA:** lee si el director te escribió un mensaje en tu canal (`Mensajes entre modelos/Ling-3.1-Flash/`). Si hay mensaje dirigido a ti, RESPÓNDELO primero (numeración de hilo: último + 1; borra SOLO ese número del pool `NUMEROS_DISPONIBLES.txt` de tu carpeta de canal — pools NO se commitean).
2. **SEGUNDA INSTANCIA:** si NO hay mensajes del director, toma el próximo item `[ ]` de la COLA ACTIVA (sección A) según tu nicho. Trabaja una TANDA de tareas (las que elijas).
3. **CIERRE DE TANDA:** al terminar, escribe un REPORTE en tu canal al director: qué cerraste (ids), evidencia (archivos/tests), y marca `[x]` honesto en ESTE archivo (solo verificable en disco — REGLA CERO: sin reporte, el trabajo no existe).
4. El director actualizará ESTE backlog, la fila de `CHECKLIST-GLOBAL.md` y te responderá.

**Reglas fijas:** reserva 🔵 §21.3 en los 4 registros antes de tocar módulos · UTF-8 §28 · independencia QA §21.8/§21.23 · no editar el backlog de otro modelo · marcas `[ ]/[→]/[x]/[?]` honestas.

---

# (A) COLA ACTIVA — 100+ TAREAS (tandas curadas por el director)

# BACKLOG 100+ TAREAS — LING-3.1-FLASH (i18n / localización)

**Modelo:** Ling-3.1-Flash (reporter-only → editor i18n desde el re-activación 2026-10-16 ~17:42)
**Canales:** `Mensajes entre modelos/Ling-3.1-Flash/` (informe 142: 112/112 integridad — calidad de referencia; encargo 144: strings_pt saldado con acuse 146)
**Fecha:** 2026-10-16 22:00 (directiva del fundador: «el de ling lo tenés que ahora está activo»)
**Nicho:** i18n/localización/catálogos — ES/EN/PT + M87 + placeholders + UTF-8 + validador headless + reporte-only de referencia (metodología informe 142).
**Reglas:** Standard informe 142 (medición por script, reporte-only)... salvo los encargos editor (144/146 — SÍ edita, con pathspec explícito y validación por script).

## LAS 105 TAREAS

### Bloque A — Estado y deuda de M87 (medición + resolución)

1. M87: medición completa del estado real del catálogo (conteo por catálogo + el estado actual verificado — informe al canal).
2. M87: resolver los ítems `[ ]`/`[?]` del `05-Checklist.md` con cierre válido (uno por uno con evidencia).
3. M87: sincronizar ES<-EN <-> PT (el parity de claveschecking estructural, no totalmente el contenido).
4. USAR el validador del estándar 142 (conteo total, UTF-8 strict, BOM, parseo JSON, calleje de placeholders).
5. [x] M87: documentar los cierres en el Log 19XX (patrón del 1906 de DeepSeek). — CERRADO 2026-10-17 19:27: **Log 1943** (`Logs/1943-Ling-i18n-auditoria-mensual-cierre-tandas_2026-10-17_19-27-00.md`) — cierre de las 7 tandas de la jornada (27 tareas, commits ed06c29→5b203ab) con tabla de cierre por tanda (msg/commit/tareas) y hallazgos vivos para el director. Pool de Logs: 1943 consumido (head post 1944).

### Bloque B — PT restante (el fruto del 144-145)

6. [x] `strings_pt.json`: WEAPONS/JUEGO — las claves restantes de `tools.csv`/catálogo M13/M15 que usan placeholders. — TANDA 6: paridad ES<->PT 0/0 (147/147); no hay sección WEAPONS en el catálogo central (las armas son datos M13/M15 dinámicos); las claves de items/tienda están traducidas (ITEMS.SE_OFRECEN 'Oferecendo {n} item', TIENDAS.SIN_ITEMS 'Você não tem esse item para vender.'); placeholders parity 0 (Tanda 1).
7. [x] `strings_pt.json`: claves M21-Diálogos (`eventos.*`, `dialogo.*` — las 32 claves de conversaciones). — TANDA 6: eventos.historia_c1-c7 (14 claves) presentes y traducidos (ej. 'As Cinzas Futuras', 'A ferramenta do templo abre a ponte para a ilha Mar.'); npc.hola/adios traducidos; 'dialogo.*' no existe como sección (los diálogos M21 son datos dinámicos).
8. [x] `strings_pt.json`: claves M74-Eventos (los 22 eventos del catálogo — `festival_*_nombre` etc.). — TANDA 6: paridad 0/0; no hay claves festival_* en el catálogo central (los 22 eventos M74 son datos dinámicos de festivals.tres — TimeCalendar); el catálogo cubre los 14 eventos.historia_* traducidos.
9. [x] `strings_pt.json`: claves M65/M36-Fauna (las especies de fauna — 22 nombres). — TANDA 6: paridad 0/0; los 22 nombres de especies M65/M36 son datos dinámicos (no viven en el catálogo central de strings) — no hay claves pendientes en strings_pt.json.
10. [x] `strings_pt.json`: claves M50-Vegetación (los 109 plan items — 65 instanciadas). — TANDA 6: paridad 0/0; los 109 plan items M50 son instancias dinámicas (no claves de catálogo) — no hay claves pendientes.
11. [x] `strings_pt.json`: claves M15-Recursos (los nodos madera/piedra/baya/etc). — TANDA 6: paridad 0/0; ITEMS.SE_OFRECEN traducida; los nodos madera/piedra/baya son datos M15 dinámicos (no claves de catálogo central).
12. [x] `strings_pt.json`: claves M76-Multijugador (el contrato MP de Step-5 — los strings por el contrato). — TANDA 6: paridad 0/0; el contrato MP M76 (Step-5) vive en sus propios datos, no en el catálogo central; claves de UI relacionadas traducidas (SETTINGS.COMPRESION 'Compressão').
13. [x] `strings_pt.json`: claves M95-Monetización (3 ediciones + 2 DLC). — TANDA 6: paridad 0/0; los nombres de 3 ediciones + 2 DLC M95 son datos dinámicos; la UI de tienda (TIENDAS.*, 20 claves) traducida — 6 cognatos válidos pt-BR (Catálogo, Comprar, Comprar máx., Saldo, Vender, Vender máx.); TIENDAS.CERRADA 'A loja está fechada...'.
14. [x] `strings_pt.json`: claves M37-Museo (4 exposiciones + items). — TANDA 6: paridad 0/0; las 4 exposiciones + items M37 son datos dinámicos (no claves de catálogo central) — no hay claves pendientes.
15. [x] `strings_pt.json`: claves M160-Ubicaciones (39 catálogo + 48 ubicaciones). — TANDA 6: paridad 0/0; los 39+48 nombres de ubicaciones M160 son datos dinámicos; DIARY.CAT_LUGARES traducida 'Lugares'->'Locais' (era la única copia-ES no cognato — aplicado en esta tanda).
16. [x] `strings_pt.json`: clave huérfana `eventos.historia_c2_nome` -> decision si rename a `_nombre` (con mi acuse). — TANDA 6: DECISIÓN: ELIMINAR, no rename. La canónica historia_c2_nombre YA existía en PT con la traducción correcta ('A Ponte das Memórias'); historia_c2_nome era un fósil duplicado (mismo valor, 0 referencias en código/tests — grep verificado). Aplicado: strings_pt.json 148->147, paridad exacta 147/147/147. Acuse: renombrar hubiera colisionado con la clave existente.
17. [x] `strings_pt.json`: revisar el fallback del localization_manager si losцат claves PT faltan (hoy: cae a ES). — TANDA 6: fallback revisado — localization_manager.gd L180-185: si la clave falta en el locale activo, cae a LOCALE_DEFECTO (ES) y avisa (_avisar_faltante, dedup); como PT no está en el runtime (Tanda 4: LOCALES_SOPORTADOS=[es,en]), el fallback PT->ES no aplica hoy; al habilitar PT el fallback ya estará implementado.
18. [x] `strings_pt.json`: reporte final del PT (conteo total, par E-W, validación all). — TANDA 6: REPORTE FINAL PT — ES/EN/PT 147/147/147, paridad de claves 0/0/0 en todas las direcciones; 116 claves traducidas (difieren de ES) + 31 válidas (28 cognatos idénticos ES/PT: Visto, Favorito, Filtro, Todos, Mapa, Pausa, Saldo... + '???' símbolo + '{tipo}: {item}' placeholder + 'Slots' técnico); 0 pendientes de traducción; UTF-8 strict, 0 BOM/U+FFFD/CRLF.

### Bloque C — Estado de integridad (estándar informe 142)

19. [x] Control integridad semanal de los 3 catálogos (ES/EN/PT): conteo, UTF-8 strict, BOM, 0 U+FFFD. — TANDA 1 (2026-10-17): 147/147/148 recursivo (anti-duplicados), 0 BOM/U+FFFD/CRLF/dupes ×5 archivos.
20. [x] Control placeholders ES<-EN: 0 discrepancias (el estándar 142 §3). — TANDA 1: parity por clave 0 discrepantes (walk recursivo).
21. [x] Control placeholders EN<-PT. — TANDA 1: parity ES<->PT 0 discrepantes.
22. [x] Control claves muertas (claves presentes en catálogo pero nunca referenciadas en código). — TANDA 1: censo canónico = `AuditorClaves.auditar()` (test_validador_po_m87.gd `_test_auditor_claves`, suite M87 82/0 — agnes M53 iter.6); auditoría estática propia (4 patrones, 1388 .gd): 80 claves referenciadas; las "muertas" estáticas son claves compuestas `tr_key(mod,sec,key)` (3 args), `tr_ctx`, `resolve_text` y prefijos dinámicos (M68.*, DIARY.CAT_*, ITEMS.*) — el auditor canónico las resuelve.
23. [x] Control claves huérfanas (referenciadas en código pero ausentes del catálogo). — TANDA 1: auditoría estática propia → 3 hits, TODOS falsos positivos (prefijos dinámicos `DIARY.CAT_` en validate_diary/diary_layer, `items.` en inventario_iter4 — ambos reconocidos por AuditorClaves L249/L260 — y artefacto regex `),`); 0 huérfanas reales nuevas; el canon afirma 0 claves de producción ausentes (suite 82/0, catálogos sin cambios desde encargo 146: `git log -- locales/ data/localizacion/`).
24. [x] Control duplicadas exactas en cada catálogo. — TANDA 1: 0 duplicados ×3 JSON (object_pairs_hook) y .po coherente.
25. [x] Control claves de usuario-visible vs técnico (las `key_*` de UI). — TANDA 7 (2026-10-17): **0 claves técnicas en los catálogos** — las 146 claves JSON + 236 msgids .po son 100% usuario-visible (etiquetas UI, mensajes, diálogos NPC, capítulos de historia, settings). Los 25 solo-JSON (`ui.*`, `msg.*`, `npc.*`, `eventos.historia_c*`) son contenido visible ausente del .po (deuda conciliación msg 153, NO ejecutada). Grep `key_*` en `scripts/` (15 hits) = todos `Input.is_key_pressed`/`security_key_manager`, ninguno es clave de traducción.
26. [x] Reporte de auditoría mensual (el estándar 142 — report-only). — CERRADO 2026-10-17 19:27: **sec.2 del Log 1943** — tabla de 12 controles con evidencia (conteo 146/146/146, UTF-8 0 BOM/U+FFFD/CRLF ×5 archivos, 0 duplicados, paridad de claves 0/0/0, placeholders 0, estilos 5 printf+9 named+0 both+133 none, 0 plurales, copias ES→PT 31 válidas/0 sospechosas, cruzado 121/25/115, 0 claves técnicas, SETTINGS M91 4/4, canon AuditorClaves 82/0). Reproducible: `python scripts/validar_i18n_integridad.py` → exit 0.
27. [x] Validador de integridad como script reutilizable (adaptación python del "control integridad" del estándar 142). — TANDA 7: **CREADO `scripts/validar_i18n_integridad.py`** (python stdlib, report-only, exit 0=limpio/1=errores): conteo recursivo, UTF-8 strict/BOM/U+FFFD/CRLF/dupes, paridad de claves ES↔EN↔PT, paridad de placeholders `{...}`, copias ES→PT con clasificación cognato (31 conocidos), estado cruzado JSON↔.po (insumo conciliación). Ejecución 2026-10-17 22:07: **LIMPIO, exit 0** — 146/146/146, paridad 0/0/0, 0 discrepancias placeholders, 0 copias sospechosas, cruzado 121/25/115 (idéntico al insumo msg 153). **Corrección de conteo:** Tandas 1-6 reportaron "147" porque su walk incluía la clave de metadatos `idioma` (código de locale, no traducible); el conteo correcto de claves traducibles bajo `cadenas` es **146** (121 comunes + 25 solo-JSON).
28. [x] Control claves SETTINGS.* las 4 M91 (AMBIENTE/VOCES/UI/CINEMATICAS) presentes en ES/EN/PT. — TANDA 7: **4/4 presentes y traducidas en los 3 catálogos** — ES: Ambiente/Voces/Interfaz/Cinemáticas; EN: Ambient/Voices/UI/Cinematics; PT: Ambiente/Vozes/Interface/Cinemáticas; las 4 también en `locales/es.po` (msgstr verificados). El mojibake de consola al leerlas es display cp1252 de PowerShell, no corrupción (UTF-8 strict, 0 U+FFFD en disco). — **TANDA 12 (msg 174): REGRESIÓN reparada** — el commit `ac098ca` (M91 iter. 12, GLM-5.3-Flash agente) pegó 6 claves nuevas (SETTINGS.GUARDAR_CONFIRMA/EXITO/FALLO/TITULO + SIN_GUARDADO_PREVIO + ULTIMO_GUARDADO) en JSON ES/EN + es.po/en.po SIN PT → paridad rota (150/150/146, exit 1; 2 aparecieron en vuelo durante la reparación — lote en curso). Reparadas las 6 en `strings_pt.json` con léxico coherente ("Salvar a partida no slot 1?", "Partida salva com sucesso.", "Não foi possível salvar a partida.", "Salvar partida", "Sem salvamento anterior.", "Último salvamento"). Verificación: **152/152/152, paridad 0/0/0, exit 0**; cruzado actualizado 127/25/115. Recomendación al director: los lotes de claves deben incluir PT o avisar al frente i18n. — **TANDA 13 (msg 175): 2ª regresión reparada** — el lote M91 siguió en curso: `SETTINGS.GUARDAR_BLOQUEADO` ('No se puede guardar ahora (hay un diálogo, carga o panel abierto).' → PT 'Não é possível salvar agora (há um diálogo, carregamento ou painel aberto).') pegada en es.po/en.po L64 sin PT → 153/152. **Balance del lote: 7 claves nuevas, las 7 ya en `strings_pt.json`**. Verificación: **153/153/153, paridad 0/0/0, exit 0**; cruzado 128/25/115. Alerta formal al director: 2 reparaciones en 20 min por el mismo origen — GLM-5.3-Flash (agente M91) debe incluir PT en cada lote o avisar al frente i18n.

### Bloque D — M88 Fuentes (el estado de fuentes para idiomas)

29. M88: medición del estado (`05-Checklist M88` — 174/185).
30. M88: resolver los ítems pendientes (11 `[ ]`/`[?]`).
31. [x] Control de glifos: los caracteres especiales de each idioma (á, ñ, ß, п...) presentes en la fuente. — TANDA 9: **CREADO `scripts/validar_glifos_fuentes.py`** (stdlib, parser cmap TTF formatos 0/4/6/12 sin fontTools, report-only, exit 0/1). 20 caracteres no-ASCII requeridos (extraídos de ES/EN/PT). **Nunito ×3: 18/20 — FALTAN U+2014 (—) y U+2192 (→); FredokaOne: 19/20 — FALTA U+2192 (→). → (U+2192) se usa en 62 lugares runtime (M68.ROUTE.* ES.po/EN.po: 20 rutas de transporte + template `→ {destino} · {metros} m`) → TOFU visible en la UI de transporte con las fuentes actuales. — (U+2014) en 8 lugares runtime (EQUIP.HINT / EQUIP.TOOLTIP_QUITAR, ES/EN) → tofu en Nunito (solo FredokaOne lo cubre). Deuda reportada al director/fundador: la corrección (añadir glifos a las fuentes / reemplazar caracteres en catálogos M68+M14 / fallback de fuente) es decisión del dueño de M88 — M68 y M14 son módulos de otros agentes, NO tocados.
32. [x] Control fuente tamanho (la precisa en UI con fuente personalizada). — TANDA 11 (msg 173): cerrada como AUDITORÍA estática report-only. (1) Jerarquía de theme_ux.gd L37-42 coincide 1:1 con la documentación M88 (H1=32/H2=24/H3=20/BODY=16/SMALL=12/MICRO=10; Nunito Regular/Bold + Fredoka One). (2) Censo de 33 archivos / 80 overrides de font_size: 33 usos vía constantes ThemeUx.FONT_SIZE_* (H1×6/H2×9/H3×2/BODY×3/SMALL×10) + 3 expresiones dinámicas legítimas (factor M58, TAMAÑOS_PX subtítulos); 47 hardcodes numéricos — 11 coinciden con la escala (10/12/16px) y ~36 FUERA de escala: 14px×14 (el más usado), 15px×3, 18px×3, 11px×3, 13px×2, 22px×1, 26px×1, 34px×1 (display hora, justificable), 8px×3 y 9px×3 (player.gd/minimap — riesgo de legibilidad, <12px mínimo WCAG → reportado a M58/M53). H1: 10 tamaños ad-hoc diluyen la jerarquía de 6 pasos; candidatos a formalizar: 14px "caption", 18px "lead" (decisión = dueño M88/M53). H3: el patrón correcto (crafting_ui.gd, shop_ui.gd) es minoritario (33/80). LÍMITE: Godot no disponible en el entorno → medición de píxeles (get_string_size) y desbordamiento visual pendientes para sesión con headless. Cambios = M88/M53/M58, reportados, no ejecutados.

### Bloque E — Subtítulos y diálogos multi-idioma (nicho Hy3/mío)

33. [x] M113: los subtítulos multi-idioma (los diálogos de M21/M162 con interliniado). — TANDA 10 (msg 170): cerrada como AUDITORÍA report-only. Censo: 375 grafos (data/dialogues + contextual), 764 nodos, 388 text_key + 4 options. **H1: 388/388 text_key (100%) son literal ES — 0 claves i18n, 0 en catálogo** → los diálogos NO son multi-idioma (el pipeline DialogueManager.resolve_text L209-227 sí traduce claves, pero ningún texto cumple la heurística MAYÚSCULAS+sin espacios+punto L226; con PT habilitado el jugador vería diálogos en ES). Patrón correcto existe como ejemplo didáctico (ejemplo_localizado_m21.json usa EJEMPLO_M21_*) — nota: la heurística exige punto y esas claves no lo tienen (verificar por dueño M21). H2: DialogoSchema M109 exige campo `text` pero el dataset migró a `text_key` (0 nodos con text, 390 con text_key) → el auditor M109 está obsoleto; reporte dialogos_audit.txt "268 OK" (2026-09-02) es histórico previo a la migración. H3: 26/27 speaker_key no están en es.po (pregunta: ID interno o clave traducible). Encoding 375/375 UTF-8 limpio, 0 U+FFFD. 6 placeholders de sesión (nombre_viajero, npc_id, item_id, new_level, encantos, nombre) resueltos por _session_vars, no M87. Implementación multi-idioma = deuda M21/M162 (Hy3): 388 text_key → claves + EN+PT (776 traducciones) + migrar 375 JSON. Reportado al director msg 170.
34. [x] Subtítulos: control de longitud de texto por idioma (ES vs PT — el draw de text ancho). — TANDA 9: 146 claves comunes — ES 2691 chars (avg 18.4, máx EQUIP.HINT 79), EN 2417 (avg 16.6, máx 65), PT 2607 (avg 17.9, máx 78). **PT vs ES: -3.1% promedio** (PT más corto en promedio, no el típico +10-20%). **9 claves con PT >15% más larga que ES**: SETTINGS.AJUSTES +86% (7→13), SETTINGS.FOGATA +33%, SETTINGS.AUDIO_FALLA +28%, SETTINGS.DESCARTAR_MENSAJE +22%, EQUIP.BONO +21%, SETTINGS.SIN_RECETAS +19%, LOADING.CARGANDO +18%, TUTORIAL.VECINO +17%, EQUIP.BONO_EQUIPO +15%. El máximo absoluto (EQUIP.HINT 79 ES / 78 PT) está cubierto por el ancho de ES; riesgo de desbordamiento acotado a Settings (M91) y Equip (M14) — verificación visual por sus dueños. Limitación: proxy por chars; el ancho en píxeles (get_string_size) requiere Godot headless — follow-up si el director lo pide.

### Bloque F — El contraste general M91 (ya aplicado — el QA)

35. M91 settings_audio: verificación de los cambios D102 (sliders 7 buses) en pantalla (captura V2 — el trato).
36. M91 settings_audio: los 12 [?] del checklist — cerrar con medición.
37. M91 settings_audio: revisar el L199 de M118 (flip cuando el CI VERDE — por el frente DeepSeek).

### Bloque G — Proyecto general i18n refuérzo (los pendientes del catálogo)

38. M159: catálogo de items — los strings ES/EN coherentes (el 300/300 — los 272 OBJ del diseño: revisar nombres en ES y EN divulgación).
39. M159: los strings pt **nuevo**: el catálogo de 272 (la misma herida del incremento — los Precedent con placeholders parity).
40. M159: nombres ES vs los prescrito del diseño (307 IDs del diseño vs materializado — la revisión de los nombres de juego).
41. M147-WorldBible: canon 1.0.0 — revisar los nombres propios (Catalina, Bruno... los 6 personajes) coherente con ES/EN/PT.
42. M160-Ubicaciones: 39 catálogo — los nombres de ubicaciones ES vs PT (16 capas de traducción).
43. M95-Monetización: los strings de las ediciones/DLC — ES/EN/PT (los 3 ediciones de la fila).
44. M100-Community: los 5 canales — los strings comunitarios ES/EN/PT si Вен conflated.
45. M121-SupportManager: 15 FAQ x 3 idiomas — el cheching de coherencia.

### Bloque H — Los pendientes de placeholder parity (nuevo ítem luego del 142)

46. [x] Control placeholder `%1$s`-estilos vs `{n}`-estilos (los 2 estilos en uso — el estándar del proyecto unificar). — TANDA 2 (2026-10-17): censo `control_i18n_tanda2.py` — ES/EN: 5 printf + 9 named + 0 both + 133 none (PT: 5/9/0/134 — el +1 es la huérfana histórica); **0 inconsistencias de estilo ES↔EN y ES↔PT** (por clave). Los 2 estilos coexisten POR DISEÑO: printf (`%s`×4, `%d`×4) en DIARY/TIENDAS/SETTINGS (conteos) y named (`{c}`×3, `{p}`×2, `{item}`×2, `{n}`×2, `{tipo}`×1, `{rareza}`×1) en EQUIP/ITEMS (UI estructurada). Unificar = decisión de diseño (director/fundador), no es bug de consistencia.
47. [x] Control pluralización (los plurales por idioma ES/EN/PT si aplican — las cantidades del juego). — TANDA 2: `.po` es/en declaran `Plural-Forms: nplurals=2; plural=(n != 1);` pero tienen **0 claves plurales** (ninguna entrada `msgstr[0]/msgstr[1]`). El runtime SÍ soporta plurales (`localization_manager.gd`: `_plural_forms`, `_indice_plural`, `tr_key(..., n)`, `format_text` inyecta `{n}`) — la infraestructura está lista; el catálogo aún no la usa (las cantidades hoy son claves separadas nombre/desc, no formas plurales).
48. [x] Control 3rd language 3er idioma (los 3er idioma del juego — la decisión del scope multilingüe). — TANDA 5: **análisis de esfuerzo para PT como 3er idioma (insumo para decisión del director/fundador).** (1) Catálogo: crear `locales/pt.po` con 236 msgids — 121 claves YA tienen traducción PT en `strings_pt.json` (aprovechables, Tanda 1) y 115 claves solo existen en `.po` (bloque M68 transporte ~85, DIARY.CAT_* 17, CLOCK.ESTACIONES 4, HUD.VIDA, ITEMS.MADERA(_DESC), MAIN_MENU.OPTIONS, SETTINGS.IDIOMA, UI.INTERACTUAR, npc.catalina, DIALOGOS.VECINO_SALUDO) — traducir ES→PT nuevo. (2) Código: `LOCALES_SOPORTADOS := ["es","en","pt"]` (localization_manager.gd L15, 1 línea) + tabla pt y NOMBRES_NATIVOS pt en locale_utils.gd (Tanda 3). (3) Glosario M87: `glosario.json` `"idiomas": ["es","en"]` — añadir "pt" + campo "pt" en los 17 términos. (4) Fuentes M88: PT añade 7 caracteres no-ASCII exclusivos (U+00E0 à, U+00E2 â, U+00E3 ã, U+00E7 ç, U+00EA ê, U+00F4 ô, U+00F5 õ) — verificar cobertura (test_fuentes_reales_m88.gd `validar_cobertura_idiomas(["es","en"])` — extender a pt). (5) Tests: `locales_disponibles().size() == 3` (test_localization.gd:75 hoy ==2, iter2:144). **Dependencia:** toca la conciliación .po↔JSON bloqueada por el fundador (msg 153) — el orden de operaciones (¿.po sigue siendo runtime o migra a JSON?) cambia el trabajo de pt. **Decisión de scope = director/fundador**; este análisis es el insumo. Pendiente relacionado: huÉrfana PT `historia_c2_nome` (tarea 16).
49. [x] Control de formato de números/fecha por idioma (los TimeCalendar strings). — TANDA 3: **API LocaleUtils (locale_utils.gd) correcta y probada** — es: 1.234,56 / 17/08/2026 / 14:30 (24h); en: 1,234.56 / 08/17/2026 / 2:30 PM (12h); tests iter4 validan 0, negativos, 1e6, relleno (test_localizacion_iter4.gd L128-136). **GAP pt:** TABLAS y NOMBRES_NATIVOS solo es/en — `get_tabla("pt")` fallback SILENCIOSO a ES y `get_nombre_nativo("pt")` devuelve "pt" literal (el juego soporta PT: pt.json 148 claves). **Adopción incompleta:** único consumidor de LocaleUtils = transport_localizer.gd (M16, 4 llamadas L254/255/284/299). **TimeCalendar (M29) NO lo usa:** formatear_hora (L165) decide 12h/24h por time_config.tres:usar_formato_12h=**false** → 24h en TODOS los idiomas (contradicción: en locale "en", transporte muestra 2:30 PM y reloj HUD 14:30); formatear_fecha_completa (L180) hardcodea plantilla ES "%s, %d de %s del año %d". **HUD jugador-visible:** w_reloj.gd L169-181 + reloj_hud.gd L56-78 — hora por usar_formato_12h (24h siempre), fecha "Lunes, 12 de Primavera, Año 1" con GameTime.NOMBRES_SEMANA/NOMBRES_ESTACIONES (constantes ES); sin LocaleUtils, sin .po. **Duplicación de fuentes:** estaciones en time_config.tres (ES) Y .po CLOCK.ESTACIONES.0-3 (catalogadas pero no consumidas). Consumidores producción: debug_menu.gd:466-467, price_manager.gd:384-385, reloj_hud.gd:115, w_reloj.gd:18/173. Fixes = deuda M29 (DS 🟡193/195)/M30 (Hy3 🟡119/120)/M46 — L117 delegada msg 149. Control solamente; sin cambios en esos módulos.
50. [x] Control de los sufixes de idioma en los archivos (es/en/pt — sistemático). — TANDA 4: **sistemático DENTRO de cada sistema, pero INCONSISTENTE entre sistemas.** (1) JSON `data/localizacion/`: `strings_{es,en,pt}.json` **3/3** (147/147/148 claves). (2) `.po` `locales/`: `es.po`/`en.po` **2/2** — coherente con el runtime: `localization_manager.gd` L15 `LOCALES_SOPORTADOS := ["es","en"]`, `_cargar_catalogos` (L35-42) lee `res://locales/{locale}.po`, `set_locale("pt")` RECHAZADO (L98-101); tests lo afirman (`test_localization.gd:75` "2 idiomas soportados", `test_localizacion_iter2.gd:144` "es+en disponibles (selector M53/M110)"). (3) **HALLAZGO: `strings_pt.json` es HUÉRFANO en runtime** — existe, versionado, 148 claves con paridad completa con ES (0/1), pero NINGÚn código de producción lo lee (el sistema JSON-autoload fue eliminado por bug104, 2026-10-08; hoy solo tests M74 lo usan como fuente). El jugador NO puede jugar en portugués: `_sugerir_locale_so` no sugiere pt, `get_locale_display_name` no tiene "Português" (LocaleUtils TABLAS/NOMBRES_NATIVOS solo es/en — Tanda 3). (4) Ruta para habilitar PT: crear `locales/pt.po` (236 msgids; contenido ya existe en strings_pt.json: 121 comunes + 25 solo-JSON normalizados) o extender `_cargar_catalogos` a JSON — decisión director/fundador (toca la conciliación .po↔JSON bloqueada, msg 153). Únicos otros archivos con sufijo: outputs de test en `Godot/app_userdata/` (no versionados).

### Bloque I — Documentación y auditoría (siempre al estándar)

51. Log de iteración del frente (por migración — Logs 19XX).
52. Reporte al canal (numeración del pool Ling — la cabeza ahora 147).
53. Registro en el BACKLOG (marcar de acá [x] los items).
54. Update fila GLOBAL del módulo tocado (hilo 11 celdas — lección del 76/55).
55. Los scripts de validación compartidos con el estándar del repo (si crees validar: update del LOG de scripts nuevo).
56. Control sintaxis Godot con el theme_ux (los SETTINGS.* los slides del M91: sin duplicados con los otros LANGAGES).

### Bloque J — Auditoría de UI strings presentes en el runtime (el flujo del jugador)

57. UI captura del juego corriendo con el idioma ES (los labels del HUD en pantalla — coherencia texto).
58. UI captura del juego corriendo con el idioma EN.
59. UI captura del juego corriendo con el idioma PT (cuando completa el lote B).
60. Validar el `ControlsLabel` (el panel de controles visible sin fondo con outline — el estado D102 'revertido').
61. Valida el toolbar M01 (los Pico de Cobre [150/150] — chrome legible con outline).
62. Valida el reloj (hora/lista estación — el D102-fix L117/L124 aplicado).

### Bloque K — Sincronización con el localizador códigos (los IDs del catálogo)

63. Localizador M12/60: el mapa de claves del código (los nombres de ítems instrumento — el catálogo interno).
64. El ID del grupo de localización (los prefijos `tools.*`, `eventos.*` — un estándar de nombres).
65. Documentación de los prefijos de claves (estándar del proyecto — documentar en M87).

### Bloque L — QA integridad de los strings con expresiones (el flujo del gameplay)

66. M21-Diálogos: los strings de diálogo no cortados en el draw (control de wrap).
67. M95: strings de precios por idioma (la formattación de monetización).
68. M100: los strings de mantenimientos comunitarios.
69. M159: el nombre largo de ítems (el draw del UI no corta el nombre — control wrap).
70. M76: los strings multijugador por idioma (el contrato MP JSON).

### Bloque M — Control técnico (los strings del sistema).

71. Strings del jugador (los logins)... evaluación: si aplica el language.
72. El texto "Controles:" del HUD — los shortcuts por idioma (WASD etc: el estándar de teclado físico).
73. El texto de errores del sistema (los logs por idioma — los spans estándar).
74. El texto del_BOOT por idioma (el flujo de arranque — el fondo del boot strings desync).

### Bloque N — El spillover de la interfaz (los ibles remaining)

75. UI: los tooltips por idioma (los tooltips de los tools de la toolbar).
76. UI: los títulos de menu por idioma (los layers del M53: pausa/menus/confirm boxes).
77. UI: los botones del dialogs por idioma (Sí/No/Espera).
78. UI: los fondos geenéricos vs el texto (el contraste dark del D102 — el tema global).

### Bloque O — Lotes del catálogo M159 (el 300/300 del L216 — ES/EN presentes? control)

79. M159: el control de nombres ES de los 179 .tres creados (los ítems .tres tienen nombre ES en el catálogo).
80. M159: los nombres EN de los 179 .tres (el strings EN con el nombre de cada .tres).
81. M159: el catálogo ES `.tres` items con el inventario dos veces (p.ej. item name ES = el display name no el técnico).
82. M159: los iconos (0/121 — synced con M45 el frente AGNES/arte — no es mío el assets).

### Bloque P — Los trabajos del autosave / guardado (los strings del flujo guardado).

83. M59-Guardado: strings de autosave (los autosave mensajes por idioma).
84. M59: strings de load/save UI (los menús del guardado).

### Bloque Q — Los mensajes del día (los eventos M74)

85. M74: los 22 eventos del festival con los strings ES/EN (los nombres del catálogo).
86. M74: los strings PT de los 22 eventos (cuando el LOTE B llegue).

### Bloque R — El flujo del collectible (los strings del collectible).

87. M73-Coleccionables: los strings colección ES/EN (los 15 items 4 categorías).
88. M73: el detalle por ítem (las descripciones de cada coleccionable).

### Bloque S — El flujo de merchandising (los strings del M95/M129).

89. M95: ediciones/dlc strings ES/EN (los 3 ediciones — nombres y descripciones).
90. M129: merch — los 10 productos (nombres ES/EN — 0 productos en el catálogo pt).

### Bloque T — El flujo de servicios (los strings M106/M116/M121/M123).

91. M106: security messages (los strings del security checker).
92. M116: instalador config (los pasos del instalador strings).
93. M121: support FAQ ES/EN (15 FAQ x idiomas).
94. M123: modding messages (los strings de los mods).

### Bloque U — Traducciones del flujos del mundo (los strings del M09/M40).

95. M09-IMP: los mensajes de la isla (el primer boot — el mensaje de impl).
96. M40-Flujo: los mensajes del game flow (los flujos de juego del boot).

### Bloque V — El estado de los textos de comentarios internos (no jugador).

97. El estándar de comentarios de código (los comentarios de código NO se traducen? — definir el estándar de comentarios).
98. El estándar del codificación de Logs (los Logs de coding por idioma — español estándar).
99. Clamp de los Logs del sistema (los logs del logger — el lenguaje del técnico).
100. Control técnico de debug_menu (los menús de debug ES/EN — 5 pestañas).
101. El estándar del strings del código de enrutamiento (los builds del route — el encargo las llaves 274).

---
**Total: 101 tareas** (partido en bloques A-V — la Σ de tareas con los frentes definidos del informe 142 + los hallazgos de M87/M159/M41 del día).

**Estado actual:** este archivo creado 2026-10-16 22:00 (directiva del fundador: «el de ling lo tenes que ahora esta activo» — esos tickets todos al rol de Ling con reportes al canal y al estándar del informe 142).

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-16

## TANDA 1 — Control de integridad (2026-10-17, metodología V2 msg 158)

**Modelo:** Ling-3.1-Flash / Kilo Code — primera tanda del ciclo V2 (acuse del msg 158 + informe msg 159).
**Alcance:** Bloque C, tareas 19-24 (control de integridad, estándar informe 142 — report-only, sin edición de catálogos).
**Evidencia (medición fresca, scripts `control_i18n_v2*.py`):**
- JSON ES/EN/PT: **147/147/148** claves recursivas (anti-duplicados) · 0 BOM · 0 U+FFFD · 0 CRLF · 0 claves duplicadas ×3.
- ES↔EN: conjuntos de claves **0/0** · parity de placeholders por clave **0 discrepantes** · 144/147 valores difieren (correcto: son traducciones) · 3 iguales (language-neutral: `DIARY.BLOQUEADO`, `EQUIP.EQUIPADO`, `SETTINGS.SLOTS`).
- ES↔PT: **0/1** — huérfana histórica `eventos.historia_c2_nome` (PT) — decisión de rename pendiente del director (tarea 16).
- `.po` ES/EN: **236/236 msgids**, conjuntos **iguales**, 0 BOM/U+FFFD.
- **Estado cruzado (input para la decisión A/B/C escalada al fundador, msg 153):** normalizando la raíz `cadenas.` del JSON → **121 comunes / 25 solo-JSON / 115 solo-.po**. Solo-JSON: 14 `eventos.historia_c*` + 3 `msg.*` + 2 `npc.*` + 6 `ui.*`. Solo-.po: bloque M68 transporte (~85: EVENT/NARR/ROUTE/SIGN/SPECIAL/STOP/TRIP), 17 `DIARY.CAT_*` + `ENTRADAS`, `CLOCK.ESTACIONES.0-3`, `HUD.VIDA`, `ITEMS.MADERA(_DESC)`, `MAIN_MENU.OPTIONS`, `SETTINGS.IDIOMA`, `UI.INTERACTUAR`, `npc.catalina`, `DIALOGOS.VECINO_SALUDO`.
- **Huérfanas/muetas (tareas 22/23):** auditoría estática propia (4 patrones de llamada, 1388 `.gd`) → 80 claves referenciadas; 3 hits falsos positivos (prefijos dinámicos `DIARY.CAT_`/`items.` + artefacto regex); el censo canónico es `AuditorClaves.auditar()` (resuelve `tr_key` compuesta, `tr_ctx`, claves como argumento, prefijos dinámicos; separa probes de test) — suite M87 **82/0**, afirma **0 claves de producción ausentes**. Catálogos sin cambios desde el encargo 146 (`git log -- locales/ data/localizacion/` → último: `a7a2754`).
**Veredicto:** integridad intra-sistema VERDE en los 5 archivos; la deuda .po↔JSON (25/115) queda DOCUMENTADA, no ejecutada (decisión del fundador pendiente).


---

# (B) ESTADO HISTÓRICO Y ENCAJE — registro del BACKLOG-MASTER anterior (preservado íntegro)

# Backlog Master — ling-3.1-flash (inclusionAI / Ant Group)

> **Estado:** 🟢 VIGENTE (alta 2026-10-06, sesión s3) — **trial gratuito hasta el 13/10/2026**
> **Plataforma:** Kilo Gateway (verificado in-house 2026-10-06) · OpenCode · Vercel AI Gateway · OpenRouter
> **Rol:** Sub-agente agentic + respaldo del coordinador en auditoría de seguridad

## Identidad y specs verificadas

Fuentes primarias: API viva de OpenRouter, Kilo Gateway (verificado in-house), models.dev, Artificial Analysis, BenchLM/Build Fast with AI (benchmarks del launch de `@AntLingAGI`), MindStudio (hands-on), aitoolsreview.co.uk.

- **Modelo:** Ling 3.1 Flash — inclusionAI (laboratorio AGI de **Ant Group**, Hangzhou)
- **Arquitectura:** MoE híbrido con **razonamiento híbrido** (variants `instant` / `thinking`, verificadas en el Kilo Gateway)
- **Parámetros:** **560B totales / 25B activos** (~4.5x el total y ~5x los activos de Ling 3.0 Flash)
- **Contexto:** **262.144 tokens** en gateways (Kilo/Vercel/OpenRouter) — **1M es design target** de InclusionAI y se mide en su API oficial. **Planear sobre 256K.**
- **Salida máxima:** 32.768 tokens
- **Entrada/Salida:** **solo texto** (NO multimodal — Artificial Analysis confirma que rechaza imagen)
- **Tool use:** function calling + tool choice + JSON mode + reasoning tokens
- **Pesos/licencia:** **CERRADOS / no publicada** — hosted-only. Toda la familia Ling hasta 3.0 era MIT; este rompe la tradición. Open-sourcing "prometido tras el trial", sin fecha.
- **Lanzamiento:** 29/09/2026 (Vercel anuncia en AI Gateway el 30/09/2026)
- **Precio:** **$0/$0 gratis hasta 13/10/2026** (Vercel `inclusionai/ling-3.1-flash-free`, OpenCode `ling-3.1-flash-free`, OpenRouter, Kilo Gateway). API oficial InclusionAI: **$0.30 input / $0.90 output** por 1M (80% cache discount). **Post-trial: NO publicado.**
- **Velocidad:** **210.7 tok/s** (#16/176 en su clase), TTFT 1.80s, 11.29s al primer token de respuesta (incluye thinking)

### Benchmarks

**Vendor-reported (launch `@AntLingAGI`, tabulados por BenchLM / Build Fast with AI):**

| Benchmark | Ling 3.1 Flash | Referencia catálogo | ¿Gana? |
|---|---:|---|:---:|
| **CyberGym** | **87.9%** | **Atria 86.5 (#1)** · GLM 5.3 84.5 | ✅ supera a Atria en su nicho |
| DRACO (research & analysis) | **85.5%** | sin comparable directo | — |
| **SkillsBench** | **68.7%** | Atria 66.4 · Qwen 3.8 Max 66.7 | 🟢 #1 del catálogo |
| HealthBench Professional | 65.3% | dominio médico, sin aplicación en game dev | — |
| Finance Agent v2 | 57.9% | dominio financiero | — |
| SWE Atlas Codebase QnA | 55.9% | Muse Spark 90.3 (otro harness) | ❌ |
| **AutomationBench** | 52.5% | **Atria 53.8 (#1)** | ❌ Atria mantiene el nicho |
| Terminal-Bench **4.0** | 40.4% | NO comparable con TB 2.1 del catálogo; Opus 5 TB 4.0: 51.8 | ❌ |
| GDPval-AA v2.1 | 1.673 Elo | Opus 5 / GPT 5.6 Sol 1.768 | ❌ ofimática débil |
| **DeepSWE 1.1** | **NO PUBLICADO** | DeepSeek V4.1 74.2 · Kimi K3 67.5 · GLM 5.3 Flash 63.4 | ⛔ no comparable |

**Independiente (Artificial Analysis, Intelligence Index v4.3.2):**

- **AA Intelligence Index: 41 — #3/176** en su clase (mediana 13). Supera la estimación de Agnes 3.0 Flash (36).
- ⚠️ **Muy verbose:** 220M tokens de output en el AA Index (mediana 100M) — **2x la mediana**; el razonamiento híbrido gasta tokens.

### Hands-on independiente (MindStudio, 01/10/2026)

| Prueba | Resultado |
|---|---|
| 🔻 **Pipeline Blender→Godot autónomo** | **Se rompió**: ejecutó la cadena de tools (~1h) pero la escena quedó con objetos desorientados, trampolín de lado, sin layout coherente. **Coherencia espacial/logica de salidas multi-herramienta = débil.** |
| ✅ SQL query optimization | Aisló el fix único de mayor impacto, construyó dataset sintético, midió before/after, ablation incluida. |
| ✅ SVG / front-end one-shot | Night skyline animado en un prompt (~20K tokens), HTML autocontenido. |
| ✅ Razonamiento de dominio estructurado | Caso médico simulado: flagueó infarto inferior, detectó trampa clínica, pidió V4R. |
| 🟡 Multilingüe (80 idiomas) | Bien en mayores; flojo en raros (Tamil, Yoruba, Euskara). |

## Reglas del protocolo (lectura obligatoria)

1. **`AGENTS.md`** (raíz del repo) — la regla maestra. Léelo completo antes de tocar nada.
2. **Tareas:** trabajás desde este backlog. NO vayas a `CHECKLIST-GLOBAL.md` a buscar trabajo.
3. **Marcado:** `[ ]` pendiente · `[→]` en progreso · `[x]` completada · `[?]` no resuelta (honestidad obligatoria).
4. **Al completar, marcar los TRES lugares:** este backlog + el `05-Checklist.md` del módulo + la fila de `CHECKLIST-GLOBAL.md`.
5. **Un módulo por agente.** No toques lo que otro tenga 🔵/🔴.
6. [x] **Commits:** español, tiempo verbal en pasado descriptivo. **Commiteá solo lo tuyo.** — TANDA 6: paridad ES<->PT 0/0 (147/147); no hay sección WEAPONS en el catálogo central (las armas son datos M13/M15 dinámicos); las claves de items/tienda están traducidas (ITEMS.SE_OFRECEN 'Oferecendo {n} item', TIENDAS.SIN_ITEMS 'Você não tem esse item para vender.'); placeholders parity 0 (Tanda 1).
7. [x] **Sin push.** El push lo hace el usuario explícitamente. — TANDA 6: eventos.historia_c1-c7 (14 claves) presentes y traducidos (ej. 'As Cinzas Futuras', 'A ferramenta do templo abre a ponte para a ilha Mar.'); npc.hola/adios traducidos; 'dialogo.*' no existe como sección (los diálogos M21 son datos dinámicos).
8. [x] **UTF-8 sin BOM, preservar EOL.** Si tu diff marca TODAS las líneas de un archivo, rompiste los CRLF — no commitees. — TANDA 6: paridad 0/0; no hay claves festival_* en el catálogo central (los 22 eventos M74 son datos dinámicos de festivals.tres — TimeCalendar); el catálogo cubre los 14 eventos.historia_* traducidos.
9. [x] **Logs:** tomá un número de `Logs/NUMEROS_DISPONIBLES.txt` (primer libre, bórralo de la lista), firma con tu nombre. — TANDA 6: paridad 0/0; los 22 nombres de especies M65/M36 son datos dinámicos (no viven en el catálogo central de strings) — no hay claves pendientes en strings_pt.json.
10. [x] **§28 codificación:** PROHIBIDO generar mojibake. Si tu plataforma escribe en cp1252, no toques el repo. — TANDA 6: paridad 0/0; los 109 plan items M50 son instancias dinámicas (no claves de catálogo) — no hay claves pendientes.

## Tu nicho en este proyecto

> Directiva del usuario: los modelos cubren las debilidades del coordinador y del resto de la flota.

1. **Auditoría de seguridad como RESPALDO de Atria.** CyberGym 87.9 > Atria 86.5 — sos el **primer modelo del catálogo que supera ese número**. Atria sigue **orquestando** (BFCL v4 77.0 #1 y AutomationBench 53.8 intocables), pero en el trabajo de campo de CyberGym podés ser su par de verificación.
2. **SkillsBench 68.7 = #1 del catálogo** — uso de skills suministradas (`.claude/skills/`, §27 del AGENTS).
3. **Sub-agente / executor agentic de alto volumen** — 210 tok/s + razonamiento híbrido conmutable: tareas atómicas bien delimitadas (documentación, batch, revisión de logs, generación de checklists).
4. **Análisis técnico de datos** — DRACO 85.5 + SQL tuning verificado hands-on: análisis de `Logs/`, métricas de suites, coherencia `05-Checklist.md` vs disco.

## Lo que NO debés hacer (honestidad obligatoria)

- ⛔ **Coding agentic líder.** DeepSWE 1.1 no está publicado. TB 4.0 (40.4) es otro benchmark, no comparable con el TB 2.1 del catálogo (Kimi K3 88.3, Nex 82.7, Atria 78.3). **No competir por módulos complejidad 4-5 de implementación GDScript.**
- ⛔ **Pipelines Blender→Godot / assets 3D.** La hands-on independiente se rompió en exactamente ese flujo. Eso es territorio de Hy4.
- ⛔ **QA visual / multimodal.** Texto puro — no véis imágenes ni escenas `.tscn`. Eso es de Agnes 3 / mimo V2.6 (visión limitada) / el usuario (M154).
- ⛔ **Orquestación de muchos MCPs.** Atria #1 en BFCL v4 77.0 y AutomationBench 53.8.
- ⛔ **QA cruzado §21.8.** Regla del proyecto: Hy3.
- ⛔ **Módulos 🔵/🔴** en curso por otro agente.
- ⚠️ **Cadenas multi-herramienta largas.** Tu evidencia hands-on muestra que ejecutás la cadena pero perdés coherencia espacial. **Pedí tareas atómicas y autosuficientes.**
- ⚠️ **Datos sensibles al endpoint gratuito.** Vercel rutea vía Novita (terceros); no hay system card publicado a pesar de liderar CyberGym. No envíes credenciales ni datos de usuario a endpoints gratuitos.

## Método de trabajo recomendado

- **Sesiones cortas y autosuficientes.** 256K de contexto + verbosidad 2x la mediana te saturás antes que Kimi K3 (1M). Toda la información necesaria tiene que estar en el prompt inicial.
- **`instant` para tareas mecánicas, `thinking` solo cuando aporte.** El razonamiento híbrido es conutable — usalo como palanca de eficiencia, no por defecto.
- **Trial de 7 días (hasta 13/10/2026).** Toda tarea asignada debe poder **reasignarse** (§21.4.7) si el trial se cierra o llega el precio post-trial (no publicado).

## Tareas asignadas

> **NINGUNA todavía.** Como todo modelo nuevo del catálogo (Space Bunny SB-01, Gemini G-01/G-02), entrás con **una tarea de validación L-01 de complejidad 1-2** que define el director, y sin asignaciones críticas hasta tener evidencia propia en el repo. **CyberGym 87.9, SkillsBench 68.7 y AA Index 41 son claims; la primera entrega decide.**

### L-01 — Auditoría de `.claude/skills/` (§27) — `[x]` COMPLETADA

- **Estado:** `[x]` completada el 2026-10-06 — 69/69 skills auditadas con evidencia en disco.
- **Resultado:** 56 ✅ VERIFICADAS · 13 ⚠️ CON DRIFT · 0 ❌ ROTA/IRRELEVANTE.
- **Hallazgos clave:** (H-1) 12 skills de Blender citan 9 references compartidas `../references/` que no existen en disco (la carpeta `.claude/skills/references/` del repo upstream no se instaló); (H-2) godot-characterbody-2d es 2D en proyecto 3D (baja relevancia); (H-3) godot-master es mirror de 1271 scripts, 0 APIs Godot 3 reales en los 1671 scripts .gd totales (verificación case-sensitive); (H-5) falsos positivos de regex descartados y documentados.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-01-auditoria-skills.md` (UTF-8 sin BOM, 0 mojibake).
- **Log:** no creado por restricción explícita de solo-lectura de la tarea (declarado en el reporte §5 por honestidad).
- **Qué auditar:** las **69 skills instaladas** en `.claude/skills/` (44 Godot + 2 Blender +
  23 otros). Fueron instaladas el 2026-08-25 con curatoria, pero **nunca se verificaron** contra
  el repo real.
- **Método:** listar las 69 carpetas → leer cada `SKILL.md` → verificar que los
  scripts/comandos/rutas que referenced existen en disco → comprobar que las APIs citadas son de
  **Godot 4.7.2** (binario `C:\Temp\godot\godot472.exe`, proyecto en `game/isla-ancestral/`) y
  Blender vigente → clasificar cada skill (✅ verificada / ⚠️ con drift / ❌ rota o irrelevante).
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-01-auditoria-skills.md` con
  tabla skill | estado | evidencia en disco (ruta exacta) + sección de autoevaluación honesta.
- **Restricciones:** **SOLO LECTURA** sobre el repo — no modificar skills, código ni
  CHECKLIST-GLOBAL. UTF-8 sin BOM (§28). Sin commit ni push.
- **Criterio de éxito (L-01):** reporte completo de las 69 skills con evidencia citada por
  skill y autoevaluación honesta de complejidad 1-2. **Es la tarea de validación**: si la
  entrega es buena (citas reales, no impresiones; cero falsos verdes), se desglosan los nichos
  en L-02…L-100+ y recibe asignaciones reales.

### L-02 — Cierre de los 4 ítems pendientes de M150-Diseno-Sonoro-Narrativo — `[x]` COMPLETADA Y APROBADA

- **Qué era:** cerrar los 4 `[ ]` pendientes del `05-Checklist.md` de M150 (146/150).
- **Qué hizo:** midió con regex y descubrió que el encabezado mentía (decía 125, la realidad era
  146). Corrigió encabezado + Totales. Los 4 ítems (L52 recuerda_sello, L90 lore_oculto,
  L123/L127 leitmotifs de islas) quedaron `[?]` con dueño de bloqueo identificado
  (M22-historia, M148-lore, M41-música) en vez de `[x]` falsos. Descubrió de paso que la
  integración M150→M41 por señales está documentada pero no cableada
  (`narrative_sound.gd:74` vs `music_director.gd` sin conexión).
- **Verificación del director (2026-10-06):** conteo regex independiente 150/146/4/0, EOL CRLF
  preservado, UTF-8 sin BOM, todos los claims del JSON y los dos scripts confirmados en disco.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-02-m150-cierre.md`.
- **Evidencia:** Log 1367 (aprobación + regla de asignación actualizada en §5.S de la guía
  comparativa).

### L-03 — Auditoría de robustez/seguridad del sistema de guardado — `[x]` COMPLETADA Y APROBADA

- **Qué era:** primera tarea de su nicho de seguridad (CyberGym 87.9, claim sin validar hasta
  ahora). Alcance: `game/isla-ancestral/scripts/saving/` completo (13 archivos, 1915 líneas) +
  proveedores de guardado (56 registrados, 9 auditados en profundidad) + M59.
- **Qué hizo:** 10 hallazgos numerados (S-01..S-10: 4 medios, 3 bajos, 3 informativos) + 15
  puntos sólidos, todos citados a `archivo:línea`, + respuesta directa a las 9 preguntas del
  enunciado. Descartó sospechas al verificarlas (empezó creyendo que `monedas=-9999` pasaba;
  `economy_manager.gd:178` demostró que no). Corroboró S-01 en la propia documentación del
  proyecto (`save_schema.gd:117-123`).
- **Verificación del director:** 6 spot-checks contra disco, todos exactos
  (`inventario_service.gd:400-407`, `inventario_contenedor.gd:122-138`, `save_backup.gd:12-62`,
  `save_manager.gd:194-228`, `economy_manager.gd:178`, `save_schema.gd:117-123`). Reporte de 332
  líneas, LF puro, sin BOM.
- **Impacto en el proyecto:** 8 bugs registrados en `DOCUMENTACION/11-BUGS.md` (BUG-108..115),
  delegados a DeepSeek-V4.1-Flash (dueño de M59) vía sección 8.3.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-03-auditoria-saves.md`.
- **Evidencia:** Log 1368.

- **Qué es:** primera tarea de su nicho de seguridad (CyberGym 87.9, claim sin validar hasta ahora).
- **Alcance:** `game/isla-ancestral/scripts/saving/` completo (13 archivos, ~1915 líneas) + save
  providers de cada módulo + M59 (autosave/rotación). Solo lectura del código.
- **Qué buscar:** validación de esquema (tipos/rangos), JSON corrupto/manipulado, sanity checks en
  load, race conditions de autosave, backups/rotación que pisan el bueno, duplicación al cargar,
  path traversal, errores silenciados, anti-trampas.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/L-03-auditoria-saves.md`
  (hallazgos S-01..S-N con severidad + `archivo:línea`, más lo que está BIEN).
- **Criterio de éxito:** cobertura completa citada a línea + al menos 1 defecto auténtico o un
  dictamen honesto y argumentado de solidez.

### L-04 / K-01 — Verificación empírica del trabajo de kimi-k3 sobre M37-Museos — `[x]` COMPLETADA Y APROBADA

- **Qué era:** auditoría estilo T-D7 (solo lectura) de los 36 `[x]` de kimi-k3 en M37.
- **Qué hizo:** tabuló los 36 ítems con 69 citas `archivo:línea`, ejecutó la suite headless con
  binario real, sondeó T-4 sobre 1853 `.gd`, y verificó trazabilidad (log/canal/commit/marcas).
- **Veredicto:** 30/36 verificados, 5 sin evidencia (heredados iter. 1-3), 1 degradado. kimi-k3
  trabaja con **código real** (85 checks/0 fallos/EXIT 0) pero **trazabilidad de claims** (Log
  1253 inexistente, 0 mensajes en su canal, trampa 58 sin commit, RF5/C.12 sin marcar).
- **Verificación del director:** suite re-corrida de forma independiente (85/0/EXIT 0, 12 bloques
  `[FIN]`), los 5 artefactos inexistentes confirmados con glob, autoloads, Log 1253, git status y
  `04-Codigo.md` todos spot-checkeados.
- **1 corrección aplicada:** Ling reportó `quality.yml` inexistente — **existe** en
  `.github/workflows/`; su glob falló. No cambia el veredicto.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/kimi-k3/K-01-verificacion-m37.md`.
- **Evidencia:** aviso en `Mensajes entre modelos/atria-dawn-s3/4-*` (canal del director s3).

- **Qué es:** auditoría estilo T-D7 (solo lectura) de los 36 `[x]` que kimi-k3 (Verdent, TB 2.1
  88.3) marcó en M37-Museos-Y-Colecciones, reservado desde 2026-10-03 sin verificación del
  director. Escalado de la validación al segundo modelo nuevo sin evidencia empírica.
- **Alcance:** `DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md` completo
  (148 ítems, 36 `[x]`) + código citado (`game/isla-ancestral/scripts/museum/`,
  `data/museum/exhibiciones.json`) + suite headless con `godot472.exe`.
- **Pistas del director:** `test_museo.gd` (422 líneas) no es citado en ningún `[x]` — la sección
  N (QA/testings) es el lugar más probable de drift.
- **Restricción:** SOLO LECTURA sobre M37. Escribir solo el entregable.
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/kimi-k3/K-01-verificacion-m37.md`
  (va en la carpeta de kimi-k3 porque es la verificación *de* su módulo).
- **Criterio de éxito:** los 36 `[x]` tabulados con evidencia `archivo:línea` + veredicto
  numérico: ¿kimi-k3 trabaja con evidencia real o con claims?

#### L-05 — Encargo M84 L117 (reporte de licencias de audio por build) + auditoría M154 — `[x]` M84 CERRADO / M154 ENTREGADO (a la espera de decisión del director)

- **M84 L117 (encargo mimo-v2.6, msg 22 del canal):** implementado el único `[?]`
  de M84. 3 scripts nuevos en `game/isla-ancestral/scripts/legal/`
  (`audio_license_report_tool.gd` @tool API estática, `audio_license_report_editor.gd`
  EditorScript, `test_audio_license_report_m84.gd` SceneTree con simulación
  determinista 4 fixtures). Test headless Godot 4.7.2: **13 checks / 0 fallos /
  EXIT 0**; WARNING `SIN LICENCIA REGISTRADA: 'sfx_no_registrado.wav'` verificado;
  sin regresión (`test_audio_licenses_m84.gd` 15/0). **Log 1629.**
- **Cierre:** director mimo-v2.6 aceptó y aplicó el flip (msg 24 del canal,
  2026-10-11 01:43): L117 `[?]`→`[x]`, Totales 98/99→**99/99**, CHECKLIST-GLOBAL
  M84 🟡→**✅ 99/99**. M84 cerrado.
- **M154 (respuesta a msg 24, msg 25 del canal):** auditoría checklist↔disco
  (mi nicho). Evidencia: `preview_personaje.tscn` (L109), `scripts/preview/`
  (L114) y `scripts/blender/` (L170/L171) = **0 hits** en disco. **Hallazgo
  nuevo:** L172/L173 marcados `[x]` son candidatos Familia A — contradicen
  `04-Codigo.md` (pendientes 12-13 ⬜) y `Logs/screenshots/` no existe.
  Propuesta al director: implementación visual → agnes-3-flash (visión) + Hy4
  (Blender); degradación L172/L173 con evidencia (flip es del director).
  **Límite de perfil declarado:** texto puro sin visión — `.tscn`/Blender→Godot
  son territorio excluido por mi backlog (§ "Lo que NO debés hacer").
- **Entregables:** msg 23 (informe M84) + msg 25 (auditoría M154) del canal
  Ling-3.1-Flash; ESTADO-PARALELO.md 03:41 UTC.

### L-06 — Análisis de `Logs/`: métricas, productividad y candados colgados — `[x]` COMPLETADA (encargo mimo msg 26)

- **Qué era:** encargo del director mimo-v2.6 (msg 26, 2026-10-11 02:11): "Revisá tu BACKLOG-MASTER.md y elegí un módulo de tu nicho (documentación, análisis de Logs/métricas, auditoría de seguridad)".
- **Elección:** candidato de nicho "Análisis de `Logs/`" (mi nicho DRACO 85.5 + SQL tuning; read-only; atómico; utilidad inmediata para el director nuevo).
- **Qué hizo:** medición completa de `Logs/` (1.567 logs, 2026-08-15 22:46 → 2026-10-11 04:55; 30 en 24h / 209 en 7d / 385 en 30d); productividad por firma exacta (top: glm-5.3-flash 152, agnes-2.5-flash 145, agnes-3-flash 134) y por familia normalizada (DeepSeek ~320, agnes ~311, glm ~191, atria ~166, mimo ~139, Hy3 ~122); actividad últimas 24h (activos: agnes-3-flash, atria-dawn-s2, DeepSeek-V4.1-Flash, atria-dawn-s3, atria, Ling); candados 🔵 (M154 ACTIVO hoy por agnes; M37 columna Última actividad STALE ~29h pero Notas citan trabajo reciente de DeepSeek K.167/K.170 + Log 1543); **drift del Resumen del Proyecto** (declara 3 🔵, la tabla tiene 2: M154 y M37); 10 módulos 🟡 sin actividad >30 días (M86 55d, M81 48d, M80/M97/M99 39d, M69/M90 37d, M75 36d, M95 35d, M74 34d, M71 25d) — candidatos §21.4.7.
- **Entregable:** msg 27 del canal Ling-3.1-Flash (2026-10-11 02:25:41).
- **Límites respetados:** read-only sobre GLOBAL y Logs; 0 ediciones de marcas, 0 commits, 0 push. Limitación declarada: barrido cubrió filas 69-99; filas 1-68 pendientes (ofrecidas para próximo ciclo).
- **Evidencia:** comandos de medición en esta sesión (Get-ChildItem Logs + Select-String **Modelo:** + grep columna Estado del GLOBAL).

### L-07 — Barrido filas 1-68: módulos 🟡 >30 días — `[x]` COMPLETADA (encargo mimo msg 28, Opción 1)

- **Qué era:** respuesta a msg 28 del director mimo-v2.6 (2026-10-11 02:49): informe msg 27 ACEPTADO + 3 opciones. Elegí **Opción 1** (barrido filas 1-68, continuación directa de mi nicho de análisis).
- **Resultado filas 1-68:** **19 módulos 🟡 >30 días** (M05 43d, M16 39d, M19 39d, M20 42d, M21 37d, M22 41d, M23 39d, M28 39d, M31 41d, M33 37d, M34 41d, M35 41d, M40 38d, M42 39d, M50 34d, M51 35d, M57 32d, M58 35d, M67 39d) + **M47 sin fecha** (fila fantasma, sin dueño). Todos con Agente actual "—" (sin candado 🔵).
- **Correcciones a msg 27 (3 errores propios, medidos esta sesión):** (1) M71 = 25d, NO >30d → sale; (2) M86 = ✅ Completado 129/129, NO 🟡 → sale (su issue es sello Log 866 inválido); (3) M99 = actualizado HOY por DeepSeek msg 156 → activo, sale. Lista 69-99 corregida: 8 módulos (M69/M74/M75/M80/M81/M90/M95/M97).
- **Total global:** 27 módulos 🟡 >30 días + M47 sin fecha.
- **Clusters:** GLM-5.3 family 8 (M19/M22/M28/M31/M34/M35/M67+M95) · Deepseek V4 Flash 4 (M21/M33/M40/M42) · dueños descatalogados (agnes-2.5-flash: M42/M33/M40; ox-alpha retirado: M20) · sin dueño: M47/M51/M58.
- **Retakables inmediatos (Liberado):** M35, M50, M51, M58 + M74 = 5 sin riesgo de pisado.
- **Entregable:** msg 29 del canal Ling-3.1-Flash (2026-10-11 03:06:05).
- **Límites respetados:** read-only sobre CHECKLIST-GLOBAL.md; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director.

### L-08 — Auditoría de seguridad (Opción 2, encargo mimo msg 30) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 30 del director mimo-v2.6 (2026-10-11 03:10): barrido ACEPTADO + Opción 2 (auditoría de seguridad READ-ONLY): (1) re-verificación de `scripts/auditar_secrets.py`, (2) revisión de `scripts/security/` (M106) como segundo par de ojos de DeepSeek.
- **Parte 1 — gate de secrets:** corrida = **707 archivos escaneados, 339 excluidos, 0 secrets, exit 0**; `--selftest` 6/6 OK; job `security-scan` en `quality.yml` verificado como **hard gate** (sin `|| true`). Drift menor: comentario "634 archivos" vs real 707.
- **Parte 2 — M106:** re-ejecución independiente de las 8 suites (Godot 4.7.2 headless) = **237 checks / 0 fallos / 0 SCRIPT ERROR / 8× EXIT 0** (m106=43, services=78, secrets=20, middleware=19, input=25, environments=24, env=13, database=15) — coincide con re-QA §21.8 de atria-dawn (Log 1480). Revisión línea por línea de `security_secret_scanner.gd`, `security_key_manager.gd`, `security_tamper_protection.gd` (HMAC-SHA256 manual verificado contra Python `hmac`).
- **`.env.local`:** existe en disco pero **gitignored** (`.gitignore:251`, `git check-ignore -v` OK, `git ls-files --error-unmatch` = no trackeada). Sin riesgo.
- **12 `[?]` M106:** defers legítimos a M77/M104/M105/M107/M111 (server-side/CI, no aplica a v1 single-player), cada uno justificado. No es inflación.
- **Hallazgos drift documental (low-priority):** `04-Codigo.md` cita `res://security/*.gd` (real: `scripts/security/`) y `scripts/security_check.sh` (no existe); comentario "634 archivos" en `quality.yml`.
- **Veredicto:** sin secrets expuestos; gate funcional; núcleo M106 validado independientemente.
- **Entregable:** msg 31 del canal Ling-3.1-Flash (2026-10-11 03:23:30).
- **Límites respetados:** READ-ONLY sobre código y documentación; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director.

### L-09 — Auditoría coherencia checklist vs disco: M51-Agua (Opción 3, encargo mimo msg 32) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 32 del director mimo-v2.6 (2026-10-11 03:28): auditoría seguridad ACEPTADA + Opción 3 (coherencia checklist vs disco, READ-ONLY, 1 módulo; sugerencia M51-Agua o M58-Accesibilidad). Elegí **M51-Agua** (drift interno visible en GLOBAL: nota "31/146" vs Progreso "35/166").
- **1. Conteo:** 35 `[x]` / 130 `[ ]` / 1 `[?]` = **166** — coincide EXACTAMENTE con la línea Totales del archivo y con la columna Progreso de GLOBAL (35/166) y ESTADO-PARALELO L2766.
- **2. Muestreo §21.8.2.b (5 ítems [x] contra disco): 5/5 sustentados, 0 fallos:** (1) `shaders/agua_olas.gdshader` ✅ (2) `main_island.tscn:162` nodo AguaAnimada ✅ (3) `scripts/world/medir_costa_m51.gd` ✅ (4) `island_generator.gd:20 var water_level: int = 2` ✅ (5) `scripts/world/agua_animada.gd` ✅. Bonus: 3/3 capturas citadas existen en `tools/mcp/godot-mcp/capturas/51/` (21 capturas totales).
- **3. Drift checklist↔GLOBAL:** Progreso 35/166 ✅ consistente; Última actividad 2026-09-06 18:23 = iter. 5 ✅.
- **Hallazgos (drifts documentales, sin inflación):** (1) nota interna de fila 51 stale ("31/146" vs 35/166 real); (2) `[?]` L233 duplicado/obsoleto — animación ya implementada en iter. 2-5, solo reflejo SSR pendiente y ya tiene `[ ]` propio en L246 → **flip propuesto al director**; (3) asignación Hy3 (msg 32) no reflejada en fila 51 (Agente "—"); (4) claim de regresión L245 no re-verificado (claim de tests, fuera de muestreo de disco).
- **Veredicto:** M51 COHERENTE, sin inflación de marcas.
- **Entregable:** msg 33 del canal Ling-3.1-Flash (2026-10-11 03:33:40).
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director.

### L-11 — Reporte de cierre al director (msg 36, regla §7) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** el director respondió msg 35 (M51 ACEPTADA, "tu auditoría es oro") pero solo a msg 33 — msg 34 (M58) quedaba sin lectura confirmada. Regla §7: todo cierre requiere reporte en el canal para disparar la próxima delegación.
- **Msg 36 entregado (04:47:10):** (1) acuse de M51; (2) resumen ejecutivo M58 para lectura del director (coherente 131/50/2=183, 5/5 sustentados, suites 39/0+13/0, citación fantasma Log 709=M87 en 7 ítems, L196 stale, drift diseño↔implementación, sin CI); (3) nota de re-verificación propia de los claims cargados de msg 34 (conteo, 4/4 artefactos, autoload project.godot:82, identidad Log 709 — todo se sostiene); (4) propuesta de próximo módulo Opción 3: M113-Pruebas-De-Stress (131/132, liberado 2026-10-10) o M107-Backups (151/176) — espera elección del director.
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push.

### L-12 — Auditoría coherencia checklist vs disco: M113-Pruebas-De-Stress (Opción 3, 3er módulo, encargo mimo msg 37) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 37 del director mimo-v2.6 (M58 ACEPTADA + M113 asignado, 2026-10-11 04:54): auditoría con estándar (conteo vs Totales, muestreo §21.8.2.b 5/5, drift checklist↔GLOBAL).
- **1. Conteo:** 131 `[x]` / 1 `[ ]` / 0 `[?]` = **132** — coincide EXACTAMENTE con línea Totales (L259) y GLOBAL (fila 113: 131/132).
- **2. Muestreo 5/5 sustentados, 0 fallos:** (1) `scripts/stress/stress_comparator.gd` ✅ (2) `stress_runner.gd` ✅ (3) `stress_scenario.gd` ✅ (4) `test_stress_m113_comparador.gd` ✅ + **re-corrido headless esta sesión: EXIT 0** (5) `test_stress_m113.gd` ✅. Bonus: 4 escenarios en `scripts/stress/escenarios/` (block_edit/equipment/inventory/save_load); métricas definidas en `03-Diseno.md` L42-57.
- **3. Hallazgo principal — 29 flips `[ ]`→`[x]` por el USUARIO:** commit `531f597` (Mauricio Belforte, 2026-10-11 00:48:33 -0300), ítems "Definir métrica/prueba". Sustentados documentalmente en 03-Diseno.md (NO inflación Familia A), pero contradicen la política de agnes "no marcar [x] sin implementación" (métricas definidas pero no validadas contra baseline) y dejaron stale las Notas del Agente (agnes 2026-10-07: "102/30/0") y la nota de GLOBAL (cita "101/30/1", "102/132", "30 [ ] pendientes"). Última actividad GLOBAL (2026-10-10 05:35) no refleja los flips.
- **4. Deuda real documentada (no inflación):** (1) `perf_base.json` NO existe en el repo (glob vacío) — 04-Codigo.md lo cita (RUTA_BASELINE); agnes no lo sembró por 5 regresiones falsas en HW variable (Log 919/1423), valor del baseline = M61/CI sobre HW fijo; (2) 07-Resultados-Testings.md ausente; (3) gates stress NO cableados en CI (quality.yml L370 solo comentario).
- **Veredicto:** M113 COHERENTE en lo medible (conteo triple exacto, 5/5 sustentados, test vivo), sin inflación de artefactos; deuda real abierta sin dueño explícito. NO candidato a ✅.
- **Entregable:** msg 38 del canal Ling-3.1-Flash (2026-10-11 05:05:26).
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director/usuario.

### L-13 — QA cruzado §21.8: M113-Pruebas-De-Stress (elección ante mimo msg 41) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 41 del director mimo-v2.6 (M107 ACEPTADA + elección entre M97 y M113 para QA cruzado §21.8, 2026-10-11 18:06). Elegí M113: mi auditoría msg 38 quedó a 3 h del sello de stepfun y documentó deuda real — verificar si se resolvió antes de sellar ✅ es el valor del QA cruzado.
- **Veredicto: PROCEDE — sello ✅ válido con deuda documentada.**
- **Conteo:** 132 `[x]` / 0 `[ ]` / 0 `[?]` = exacto contra Totales (132·132·0·0) y GLOBAL (132/132). 0 drift.
- **Aritmética consistente:** 102 (agnes 2026-10-07) + 29 (usuario, commit 531f597) + 1 (L70, stepfun, commit 0c5942f 06:06 / Log 1668 09:05) = 132.
- **Muestreo §21.8.2.b 8/8 sustentados:** stress_comparator.gd, stress_runner.gd (registro `_SC_FLYCAM` verificado en diff 0c5942f), stress_scenario.gd, test_stress_m113_comparador.gd (**re-corrida headless EXIT 0**), test_stress_m113.gd (**re-corrida headless EXIT 0**), flycam_stress.gd (L70: seed 42, 480×200=96.000 muestras, 5 métricas, plan sintético 45 pts — leído completo), 5 escenarios en escenarios/, Log 1668 (firma stepfun) + msg 125 (canal stepfun).
- **0 citaciones fantasma.**
- **Deuda documentada (no inflación):** perf_base.json ausente por diseño (agnes L251: 5 regresiones falsas en HW variable; dueño M61/CI; mecanismo sí existe: StressComparator + RUTA_BASELINE + --update-baseline + gate exit 1); 06/07-Testings ausentes (recomendable); 29 flips del usuario son ítems "Definir" sustentados por 03-Diseno.md/04-Codigo.md (valores numéricos con M61/M19/M50/M65, declarado en L225/L236/L257).
- **Acciones:** GLOBAL fila 113 🟡→✅ "Verificado por Ling-3.1-Flash 2026-10-11" (deuda con dueño en Notas); sección "QA Cruzado §21.8" añadida a 05-Checklist.md.
- **Entregable:** msg 42 del canal Ling-3.1-Flash (2026-10-11 18:14:51).
- **Límites respetados:** QA es verificación con evidencia; única edición de estado = fila GLOBAL (sello §21.8, competencia del verificador); 0 flips de ítems, 0 commits, 0 push.

### L-14 — Cierre M107-Backups (encargo completo mimo msg 44 + 07-Resultados msg 43) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** msg 44 del director mimo-v2.6: "M107-Backups — cerrar TODO lo que falte" (Paso 1 leer, Paso 2 implementar, Paso 3 verificar, Paso 4 reportar). Aclaración clave: los 25 pendientes son `[?]` (No resueltos), no `[ ]` — 16 completables por agente + 9 user-dependent.
- **07-Resultados-Testings.md creado** (opción 2 de msg 43): 3 suites, 39 checks, 0 fallos, EXIT 0 (re-corridas vivas).
- **03-Diseno.md §1 ampliado** (3 subsecciones): Dependencias (M59/M06/M122/M133/M135); Catálogo de los 15 puntos de Plan-inicial-minimo.md §106 (L2913-2929) con mapeo punto-a-punto; Criterios de aceptación verificables (5).
- **12-Solucion-Problemas.md creado**: 10 problemas + soluciones, parámetros reales de los 4 .ps1 y BackupManager.
- **16 flips `[?]`→`[x]`** vía script ASCII-seguro (16/16 hits=1 cada uno): 3 "degradado" (§1), troubleshooting, 3 estructuras disco externo (§4), 4 integraciones especificadas (04-Codigo.md §3), 2 backups de saves, logs M133, plan M135, 15 puntos §106 reformulado.
- **Totales actualizado:** 176 ítems · Completados: 167 · Pendientes: 0 · No resueltos: 9.
- **Verificación:** 3 suites re-corridas headless 39/0/0, 0 SCRIPT ERROR, EXIT 0; UTF-8 0 BOM 0 mojibake en 4 archivos; conteo final x=167/pendiente=0/pregunta=9/suma=176.
- **9 `[?]` user-dependent** (honestos, dueño usuario): RF9 backup externo, Copia 3/Local disco externo físico, verificación disco conectado, Google Cloud Console, Drive API, credenciales OAuth, consentimiento, token. Módulo NO sellable (§21.6) hasta validación en hardware real.
- **Restricciones respetadas:** GLOBAL NO tocado (lo actualiza el director); quality.yml/bootstrap.gd/interaction_manager.gd intocados; sin commit (atria-dawn).
- **Entregables:** msg 45 (canal) + Log 1677 (pool consumido 1324→1323).

### L-15 — Lote de 36 definiciones M99-Marketing (encargo mimo msg 46) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 46 del director mimo-v2.6 (M107 cierre ACEPTADO + encargo M99-Marketing: lote grande de 30-40 `[ ]`, 2026-10-11 19:02). M99 estaba en 7/169; módulo de documentación pura.
- **Qué hizo:** lote de 36 definiciones en `03-Diseno.md` §9 agrupadas por tema: 9 estrategia de marketing (RF1/RF2), 9 redes sociales (RF3), 9 comunidad (RF3/RF4/RF7/RF8), 9 análisis y métricas (RF9/RF10/RF12/RF13). 36 flips `[ ]`→`[x]` en `05-Checklist.md` (ítems 1.1-1.6, 3.1-3.3, 5.1-5.10, 6.1-6.8, 11.1, 19.4, 20.4, 20.6, 20.7, 23.5, 24.5, 25.8, 25.9) + Totales 7/162/0 → **43/126/0 = 169**. Notas del Agente en 04-Codigo.md + nota de trazabilidad del lote en el checklist.
- **Verificación:** conteo regex 43 `[x]` / 126 `[ ]` / 0 `[?]` exacto contra Totales; UTF-8 sin BOM, 0 mojibake (chequeo de doble-codificación sobre los 3 archivos).
- **Restricciones respetadas:** CHECKLIST-GLOBAL.md NO tocado (lo actualiza el director); 0 commits.
- **Entregables:** msg 47 del canal Ling-3.1-Flash (2026-10-11 19:38:08) + Log 1684 (pool consumido 1684→1685).

### L-16 — Lote documental M128-Identidad-De-Marca (encargo mimo msg 48) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 48 del director mimo-v2.6 (M99 aceptado + encargo M128:
  lote documental de 15-20 `[ ]` en secciones que Hy3 no toque, 2026-10-11 19:45).
  Hy3 trabaja los 4 `[?]` de drift (L52/L83/L136/L161) + sección H (BrandConfig/
  contraste).
- **Qué hice:** clasifiqué los 45 `[ ]` ítem por ítem y entregué los **9 que son
  documentales-implementables** por un agente de texto (el resto es arte M46, acción
  humana/legal u operativo — marcarlos habría sido inflación Familia A):
  - **L97+L146** (fuentes en builds): verificación en disco — 4 TTF en
    `res://assets/fonts/` + `theme_ux.gd` L23-25; Godot exporta `res://` por defecto.
  - **L120** (plantillas de posts): `07-Plantillas-Posts-Marca.md` — 3 templates
    (anuncio/devlog/hito) con paleta, tipografía, logo, dimensiones y combinaciones de
    contraste seguras WCAG (Blanco Perla/Azul Bosque ≈6.9:1, Carbón/Dorado Anciano
    ≈6.3:1 — cálculo manual consistente con el test H3 de Hy3).
  - **L129** (template proveedores): `08-Template-Proveedores-Merchandise.md`.
  - **L149** (documentar hallazgos): `06-Hallazgos-Contraste-y-Coherencia.md` —
    contraste WCAG + restricciones de uso + auditoría sección J.
  - **L159** (fecha de actualización): `09-Registro-Mantenimiento.md`.
  - **L166/L167/L168** (coherencia M97/M98/M99): auditoría con citas `archivo:línea`
    — las 3 PASAN (M97: 03-Diseno L88/L96/L116; M98: §2 L16-18 + §7 L58; M99: §9).
- **Auditorías que NO pasaron (quedan `[ ]` con dueño):** L145/L169 (UI usa paleta
  pastel propia `theme_ux.gd` L13-20 ≠ paleta oficial M128 §3 — dueño M53; tipografía
  SÍ es de marca) y L170 (M131 sin formato de marca — dueño M131).
- **Hallazgos nuevos:** (1) paleta UI desalineada de la de marca; (2) nombres de
  paleta M99 (océano/arena/coral/niebla/tinta) vs M128 §3 (Azul Bosque/Dorado
  Anciano/Blanco Perla) — alinear con M45/M46; (3) app icon 512 vs 1024 (checklist
  vs 03-Diseno §2 — Godot/Steam requieren 1024+, dueño M46).
- **Módulo:** 51/100 → **60/100** (36 `[ ]` + 4 `[?]`). Conteo regex verificado:
  60/36/4 = 100 exacto contra Totales.
- **Entregables:** msg 49 del canal Ling-3.1-Flash (2026-10-11 20:23:41) + Log 1690
  (pool consumido 1689→1690: el 1689 lo tomó otro agente entre lectura y escritura).

### L-17 — Cierre M131-Créditos: catalogo .tres + especificación de audio (encargo mimo msg 50) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 50 del director mimo-v2.6 (M128 aceptado + encargo
  M131: "tiene 10 `[ ]` KnownIssues, es documental, tu nicho", 2026-10-11 20:25).
  M131 estaba en 85/10/0 = 95.
- **Qué hice:**
  - **E.L58 resuelta con artefacto real:** generado
    `game/isla-ancestral/data/legal/catalogo_creditos.tres` (Resource tipado
    `CreditsCatalog`, 1402 bytes) desde `data/legal/creditos.json` vía generador
    headless `scripts/legal/generar_catalogo_tres_m131.gd` (EXIT=0, verificado:
    7 secciones, 2 idiomas, version 2). Nueva clase
    `scripts/legal/credits_catalog.gd`.
  - **9 ítems de audio (I.L90-97, I.L99) documentados, NO flippeados:** bloqueo
    verificado = 0 archivos de audio en el repo (rglob .ogg/.wav/.opus/.mp3 → 0).
    Especificación `10-Especificacion-Integracion-Audio.md` con dueño
    (M41/M42/M43/M91), assets requeridos, puntos de cableado `archivo:línea`
    verificados y criterio de aceptación por ítem.
  - Checklist M131: **86/9/0 = 95** (flip E.L58 + Totales + nota de cierre).
- **Lecciones técnicas:** `class_name` globales no registrados en `--script`
  headless (→ `preload` explícito); el JSON devuelve `Array` plano (→ arrays
  tipados construidos explícitamente); `quit()` debe alcanzarse en `_init()` o el
  bucle principal arranca el juego y cuelga el proceso (proceso colgado matado:
  Id 19128).
- **Verificación:** conteo regex 86 `[x]` / 9 `[ ]` / 0 `[?]` exacto contra
  Totales; UTF-8 sin BOM, 0 mojibake en los 4 archivos tocados.
- **Restricciones respetadas:** CHECKLIST-GLOBAL.md NO tocado (lo actualiza el
  director); 0 commits.
- **Entregables:** msg 51 del canal Ling-3.1-Flash (2026-10-11 20:50:38) +
  Log 1692 (pool consumido 1692→1693).

### L-18 — Lote de auditoría M53-UI-UX (encargo mimo msg 52, takeover por stall) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 52 del director mimo-v2.6 (M131 aceptado +
  encargo M53-UI-UX: lote de 15-20 `[ ]`, 2026-10-11 20:54). Otra sesión
  Ling-3.1-Flash (Kilo Code) reclamó M53 en msg 53 (20:57:10) pero acumuló
  43+ min con 0 escrituras y 0 reserva de msg → **takeover por stall**.
- **Cifra corregida:** el checklist real tiene 26 `[ ]` (139/26/0 = 165),
  no 122 `[ ]` (cifra del encargo de versión anterior).
- **Qué hice:** clasificación ítem por ítem (método M128/M131):
  - **2 flips con evidencia en disco:** L188 (minimap textura caché,
    `minimap_widget.gd:4/8-10/23-26`) y L189 (tooltip pool,
    `tooltip_service.gd:14/78-81/170-172` — duplicado de G.L109,
    Patrón D resuelto).
  - **10 auditorías documentadas** con cita `archivo:línea` y dueño
    (quedan `[ ]`): L99 (redibujo event-driven, decisión de diseño),
    L102 (M54 en 133/177), L126 (NotificationService sin SFX en código —
    drift con H.L121), L137 (cálculo WCAG: 4/4 pares pasan AA,
    10.4:1/8.6:1/6.6:1/4.65:1), L138 (paleta UI ≠ marca M128 §3),
    L139 (autowrap sí, locale alemán no — M87), L148 (get_subtitulos
    sin opacidad, `accesibilidad_manager.gd:263-266`), L157 (sin mapeo
    por dispositivo — drift con B.L46), L186 (múltiples CanvasLayer,
    sin merge), L193 (sin font subsetting — M88).
- **Módulo:** 139/26/0 → **141/24/0 = 165**. Conteo regex verificado
  exacto contra Totales; UTF-8 sin BOM, 0 mojibake.
- **Restricciones respetadas:** CHECKLIST-GLOBAL.md NO tocado; 0 commits.
- **Entregables:** msg 54 del canal Ling-3.1-Flash (2026-10-11 21:49:02) +
  Log 1699 (pool consumido 1699→1700).
- **Límites respetados:** 4 `[?]` de Hy3 intocados; CHECKLIST-GLOBAL.md NO tocado
  (lo actualiza el director); 0 commits; UTF-8 sin BOM, 0 mojibake.

### L-18 — M131 gaps documentales del cierre (04-Codigo, 07-Resultados, E-30/E-31, test anti-drift) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** segunda entrega del encargo M131 (msg 50/52 del director). El
  cierre paralelo (msg 51 / Log 1692) dejó 4 gaps abiertos.
- **Qué hice:**
  - `04-Codigo.md` actualizado: tabla §1 (3 archivos nuevos + test 15
    checks), sección 3 con E.L58 resuelta, Notas del Agente.
  - `07-Resultados-Testings.md` CREADO (gap DoD de agnes, Log 1425):
    suite 1 (test_credits_m131.gd) **15 checks / 0 fallos / EXIT=0**;
    suite 2 (test_credits_layer_m131.gd) **43 checks / 0 fallos /
    EXIT=0** (ambas re-corridas 2026-10-11, godot472.exe headless).
  - **7 checks anti-drift** agregados a `test_credits_m131.gd`: el
    `.tres` debe existir, cargar como `CreditsCatalog` y coincidir con
    el JSON canónico (ids + politicas).
  - `GUIA-GODOT/06-registro-errores.md`: **E-30** (`class_name` global
    no declarado en `--script` headless → `preload` explícito) y
    **E-31** (`str(Dictionary)` orden-dependiente → `==` compara
    contenido) documentados.
- **Entregables:** msg 53 del canal Ling-3.1-Flash (2026-10-11 20:57:10)
  + Log 1695 (pool consumido 1695→1696; el 1694 lo tomó otro agente).
- **Recepción:** encargo M53-UI-UX (msg 52 del director: auditoría
  documental, lote 15-20 `[ ]`) — checklist real tiene 26 `[ ]` (no 122).

### L-10 — Auditoría coherencia checklist vs disco: M58-Accesibilidad (Opción 3, 2º módulo) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** msg 32 del director mimo-v2.6 (Opción 3, 1 módulo; sugerencia M51 o M58). El turno previo entregó M51 (msg 33/L-09); este ciclo auditó **M58-Accesibilidad** en paralelo read-only (relevante: Hy3 recién asignado a M58 en msg 30).
- **1. Conteo:** 131 `[x]` / 50 `[ ]` / 2 `[?]` = **183** — regex-verified; coincide EXACTAMENTE con Totales del archivo y con GLOBAL (131/183). plan-inicial congelado: 0/173/0=173 (iteraciones agregaron 10 ítems legítimos).
- **2. Muestreo §21.8.2.b: 5/5 sustentados:** (1) `data/accesibilidad/config.json` ✅ (2) `accesibilidad_schema.gd` ✅ (3) `aplicador_accesibilidad.gd` ✅ (4) autoload `accesibilidad_manager.gd` + `project.godot:82` ✅ (5) docs 01-04 en plan-actual ✅. **Bonus — suites re-corridas por mí (Godot 4.7.2 headless): test_accesibilidad_manager 39 checks/0 fallos/EXIT 0 (Start-Process) + test_accesibilidad_headless 13/0/EXIT 0** — suites VIVAS (la nota de agnes "0/0" era typo).
- **3. Drift checklist↔GLOBAL:** Progreso/Estado/Actividad coherentes (2026-09-06 04:15 = Log 727, existe).
- **Hallazgos (trazabilidad documental, SIN inflación de marcas):** (1) **PATRÓN C — citación fantasma en 7 ítems [x] (L23/42/59/66/78/135/201):** citan "Log 709 (glm-5.3-flash)" pero Log 709 es M87-Localización de deepseek-v4-flash (2026-09-04, header interno dice "Log 639"); logs reales de M58 = 456 (marcado, agnes-2.5-flash), 727 (iter. 2, glm — bien citado) y 1398 (sustentado, agnes-3-flash); la iter. 1 (deepseek-v4-flash-vision-exp, 2026-09-02) queda sin log citado correctamente — artefactos SÍ existen y tests pasan; (2) ítem L196 "plan-actual byte a byte idéntico a plan-inicial" [x] FALSO hoy (173 vs 183 ítems, SHA256 distintos); (3) drift diseño↔implementación: 03-Diseno.md describe SettingsManager/AccessibilityProfile/Applier/MenuUI + user:// pero la implementación pivoteó a AccesibilityManager único + data/accesibilidad/config.json; (4) M58 NO cableado en CI (quality.yml no corre test_accesibilidad*).
- **Veredicto:** M58 COHERENTE en lo medible, sin inflación; 🟡 Liberado honesto, NO candidato a ✅ (50 [ ] + sin CI). Para Hy3: corregir cita Log 709→456 en los 7 ítems y leer la implementación real, no el 03-Diseno.md obsoleto.
- **Entregable:** msg 34 del canal Ling-3.1-Flash (2026-10-11 03:36:06).
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director.

### L-13 — Auditoría coherencia checklist vs disco: M107-Backups (Opción 3, 4º módulo, encargo mimo msg 39) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 39 del director mimo-v2.6 (M113 ACEPTADA — "Los 29 flips del usuario son legítimos (métricas en 03-Diseno.md)" — + M107-Backups asignado, 151/176).
- **1. Conteo:** 151 `[x]` / 0 `[ ]` / 25 `[?]` = **176** — exacto triple (Totales L243 + GLOBAL fila 107). Nota de GLOBAL STALE ("146/12/18", "12 [ ] restantes user-dependent").
- **2. Git (2 commits relevantes):** `6fc53eb` (2026-10-10, "flips de QA §21.8") flipó 12 `[ ]` (5→`[x]`, 7→`[?]`) + 3 `[x]`→`[?]` (L25-27 degradado Hy3 blq1), cada uno con justificación in-line con cita — aritmética 146/12/18→151/0/25 verificada exacta; QA §21.8 legítima. `531f597` (2026-10-11) NO flippeó marcas — reconcilió Totales, corrigió headers (A 15→19, K 12→17, M 8→9, O 10→13), atribución de autor (deepseek-v4-flash→SWE-1.6/Devin), dueño Hy3 L113, precisó logs (1068 +779; 778/780 no son de M107).
- **3. Muestreo §21.8.2.b: 5/5 sustentados:** backup.yml (110 líneas), backup_local.ps1 (222), verify_backups.ps1 (104), 08-Politica-Retencion.md, test_backup_m107 **re-corrido headless esta sesión: 28 checks / 0 fallos / EXIT 0**. Bonus: backup_categories.json + backup_policy.json (game/isla-ancestral/data/backup/), backup_manager.gd + test_backup_m107.gd (scripts/backup/), restore_backup.ps1 + register_task.ps1, docs 09/10/11.
- **4. Familia B:** 03-Diseno.md 504 líneas / 11 secciones, todas las citas válidas, 0 secciones fantasma. **Patrón C: 0** (logs 934/927/1068/779 existen). **Patrón M114: 0** — los 25 `[?]` honestos con dueño (usuario / módulo de integración / Hy3).
- **5. Drifts menores:** leyenda L8 typo "[ ] cumplido · [ ] pendiente"; bloque Reserva stale (🔵 En curso vs GLOBAL 🟡); L240 dice L113/L25-27/L234 "pendientes de dueño" pero sí nombran Hy3; sin Notas del Agente de iteraciones recientes.
- **6. Deuda:** 06-Plan-Testings.md y 07-Resultados-Testings.md ausentes; desviación WakeToRun documentada por el director (L110).
- **Veredicto:** M107 COHERENTE, NO candidato a ✅ (25 `[?]` + 06/07 ausentes) — 🟡 Con dudas honesto.
- **Entregable:** msg 40 del canal Ling-3.1-Flash (2026-10-11 05:11:27).
- **Límites respetados:** READ-ONLY; 0 ediciones de marcas, 0 commits, 0 push. Flips son del director/usuario.

### L-19 — M99 bloque 3 (contenido/SEO): 23 definiciones §10 + 6 reconciliados (encargo mimo msg 55) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 55 del director mimo-v2.6 (M53 takeover aceptado + encargo
  M99 bloque 3 contenido/SEO: "Los 24 pendientes de M53 requieren runtime/otros
  módulos. Si querés seguir, tomá M99 bloque 3 (contenido/SEO)", 2026-10-11 21:51).
- **Qué hice:**
  - `03-Diseno.md`: nuevo §10 "Lote de definiciones bloque 3 — contenido/SEO" —
    **23 definiciones** en 5 subsecciones (10.1 press/media kit RF5, 10.2 clips RF6,
    10.3 devlogs RF7, 10.4 blog RF7, 10.5 outreach/demo RF10/RF11).
  - `05-Checklist.md`: **29 flips** `[ ]`→`[x]` con cita (`archivo §` + Log):
    23 a §10 + **6 reconciliados** con definiciones preexistentes en `docs/marketing/`
    (Log 1698, atria-dawn-s2) — ítems 12.1-12.4 y 22.4 → `web-especificaciones.md`
    §3; 13.2 → `logo-especificaciones.md` §6 (ambos verificados en disco antes de
    citar; sin reescribir, regla "NO duplicar trabajo" AGENTS.md §3).
  - **Corrección de drift:** la línea Totales decía 72/97 pero el conteo real antes
    del lote era **101/68** (29 ítems de otros agentes sin actualizar Totales) →
    corregida a **130/39/0 = 169** con nota en el checklist.
  - BOM eliminado del checklist (UTF-8 sin BOM, AGENTS.md §28; condición preexistente).
- **Verificación:** conteo regex **130 [x] / 39 [ ] / 0 [?] = 169** ✓; 59 definiciones
  `(ítem N.N)` en 03-Diseno.md = 36 (§9) + 23 (§10) ✓; ambos archivos UTF-8 sin
  BOM, 0 mojibake; artefactos citados verificados en disco.
- **Entregables:** msg 56 del canal Ling-3.1-Flash (2026-10-11 22:15:52) +
  Log 1701 (pool consumido 1701→1702).
- **Nota de bookkeeping:** el backlog tiene dos entradas L-18 (M53 takeover y M131
  gaps) — colisión de numeración preexistente de la sesión previa; esta es L-19.
- **Recepción:** pendiente de respuesta del director (¿siguiente bloque de M99 u
  otro módulo?).

### L-20 — Cierre de runtime de M53-UI-UX: 4 suites verdes, 2 bugs corregidos (BUG-129/130), 5 flips → 146/19/0 (continuación takeover msg 54/55) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** continuación del takeover M53 (msg 54/55): los 4 tests headless
  de la sesión previa estaban 3/4 verdes; quedaba el fallo de wrap-around de
  `test_m53_lista_larga.gd` (owner=Item_0001) y la verificación de extremos.
- **Qué hice:**
  1. **BUG-129 corregido** (`menu_navigator.gd:72`): `wrapi` de Godot 4.7 tiene
     max EXCLUSIVO (range = max−min; verificado con sonda headless:
     `wrapi(499,0,499)=0`, `wrapi(4,0,4)=0`) — el wrap-around ciclaba por
     [0, N−2] y **el último control de toda lista era inalcanzable** por
     navegación direccional. Fix: `wrapi(next_idx, 0, focusables.size())`.
  2. **BUG-130 corregido** (`notification_service.gd:105-115`): toasts
     **ilegibles con el tema global** (Label sin `font_color` override heredaba
     TEXT_DARK sobre panel oscuro = **1.26:1 WCAG**). Fix: overrides explícitos
     (texto 0.92,0.88,0.82 = 12.5:1; icono 0.85,0.72,0.35 = 8.5:1) +
     docstring corregido (decía "con SFX"; el servicio es visual).
  3. **test_m53_wcag.gd extendido** a 17 checks (paneles oscuros tooltip/toast,
     instanciando los servicios reales con el tema global aplicado).
  4. **test_m53_extremos.gd fixeado** (BUG-048: `create_tween()` en vez de
     `Tween.new()`+`add_child()` — Tween es RefCounted en 4.7).
  5. **4 suites verdes: 46 checks / 0 fallos / EXIT 0** (wcag 17, extremos 8,
     capas 14, lista_larga 7 — esta última antes 7/1).
  6. **5 flips** en `05-Checklist.md` (L137 I.8, L152 J.10, L171 L.1, L172
     L.2, L179 L.9) con evidencia test↔disco → **146 [x] / 19 [ ] / 0 [?]**
     (conteo verificado por regex en disco).
  7. BUG-129/130 registrados en `DOCUMENTACION/11-BUGS.md` (§5 tabla + §7
     resueltos); **§36** en `GUIA-GODOT/01-gdscript-errores-comunes.md`
     (`wrapi` max exclusivo + Label sobre panel oscuro). Sonda
     `probe_wrapi_tmp.gd` borrada tras la verificación.
- **Entregables:** msg 58 del canal Ling-3.1-Flash (2026-10-11 22:24:22) +
  Log 1705 (pool consumido 1705→1706; el 1704 lo tomó otro agente
  entre lectura y escritura).
- **Recepción:** msg 57 del director (M99 bloque 3 ACEPTADO 130/169; "Los 39
  [ ] restantes de M99 son ejecución operativa. Si querés otro módulo, decime")
  — **pendiente respuesta del director** sobre el siguiente encargo (propuesta
  en msg 58: M99 bloque 4 o QA cruzada §21.8 de módulo recién sellado).
- **Nota:** el resumen de sesión previa estaba desactualizado (no incluía
  L-19/M99 bloque 3 ni msg 56/57); el backlog es la fuente de verdad.

### L-21 — Verificación H.L121 (falso verde) + BUG-133 + propuesta M151 QA §21.8 (encargo mimo msg 59) — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 59 del director mimo-v2.6 (M53 runtime
  ACEPTADO 146/165 + "Si querés otro módulo, decime", 2026-10-11
  22:33). Cierre de la verificación H.L121 flaggeada por la otra
  sesión Ling en msg 58.
- **Qué hice:**
  - **H.L121 = FALSO VERDE confirmado** (verificación de los 3
    caminos de toast, READ-ONLY): `notification_service.gd` (203
    líneas, leído completo) = 0 SFX (visual-only por diseño; el
    test H.9 `test_m53_no_redundancia.gd:45-53` asserta que
    `push()` NO crea AudioStreamPlayer). Emisores verificados sin
    SFX: `achievement_service.gd:248-267` (M72 logros) y
    `collection_registry.gd:111-123` (M37 museo). H.L121 `[x]`
    "Toasts con icono y SFX por tipo" no se sostiene.
  - **BUG-133 encontrado y registrado** (`DOCUMENTACION/11-BUGS.md`,
    tabla §5 + ficha §6): `crafting_feedback.gd:119` llama
    `notif.show_notification()` — método inexistente en
    NotificationService (grep global: 0 definiciones, 2 matches =
    la llamada) → guard `has_method` false → `print` fallback:
    **los toasts de crafting nunca se muestran**. Fix sugerido:
    `notif.push({"text": texto, "type": <ToastType>})`.
  - **Propuesta de siguiente módulo (msg 60):** M151-Control-Final
    QA cruzada §21.8 (GLOBAL L154 "QA §21.8 pendiente", autor
    mimo-v2.6-flash-free → independencia limpia §21.8.4);
    alternativa: re-auditoría stale (cola pre-armada s3). M99
    descartado (agnes bloque 5, msg 285; 14 [ ] operativos fuera
    de nicho).
- **Restricciones respetadas:** READ-ONLY en marcas (0 flips — el
  flip de H.L121 es del director; §21.8.4 me prohíbe el sello §21.8
  de M53, mismo modelo que la otra sesión); 0 commits.
- **Entregables:** msg 60 del canal Ling-3.1-Flash (2026-10-11
  22:40:54) + BUG-133 en `11-BUGS.md` + **Log 1708** (pool
  consumido 1708→1709 vía `--reservar`; el 1707 lo tomó
  otro agente — M68 QA, 22:40).
- **Recepción:** pendiente de decisión del director (M151 vs
  re-auditoría stale).

### L-22 — Encargo msg 61: H.L121 degradado a [?] + QA §21.8 de M151-Control-Final — `[x]` COMPLETADA (2026-10-11)

- **Qué era:** respuesta a msg 61 del director mimo-v2.6
  (H.L121 falso verde ACEPTADO + 3 acciones: degradar H.L121
  a `[?]`, registrar bug crafting_feedback, QA §21.8 de M151
  autorizada, 2026-10-11 22:46).
- **Qué hice:**
  1. **H.L121 degradado a `[?]`** en
    `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md`
    L121 (nota de evidencia + re-escopo: "Toasts con icono
    por tipo; SFX por canal audio separado — dueño
    M91/FeedbackDirector"). Totales: **145 [x] / 19 [ ] /
    1 [?] = 165** (era 146/19/0). Nota de degradación
    agregada; referencia en H.10 (L126) actualizada.
  2. **BUG-133** ya registrado (msg 60).
  3. **QA §21.8 de M151-Control-Final** (verificador ≠ autor
    iter. 4: Ling ≠ mimo, §21.8.4) — **Veredicto: COHERENTE,
    sin inflación; 23 [x] sustentados; NO candidato a ✅**
    (138 [ ] + 6 [?]):
    - Conteo regex 23/138/6 = 167 exacto vs Totales y GLOBAL.
    - Muestreo 8/8 re-corrido sin confiar: test_verificar_puntos
      **14 PASS/0 exit 0**; detector ciego **exit 3**;
      --plantilla **26 puntos exit 0**;
      test_control_final_headless **12 checks/0 exit 0**;
      control_final_gate CLI **BLOQUEADO zero_criticos, exit 1**;
      release-build.yml L49-102 bloqueante; regenerar_estado_
      release.py + estado_release.json coherentes; schema.gd +
      gate.gd en `game/isla-ancestral/scripts/control_final/`.
    - Familia B: 03-Diseno.md (86 líneas) completo, 0 fantasma.
    - Patrón C: 0 citaciones fantasma (Logs 1279/1289/1320 +
      commits f8119c1/5d0ffd5/23b4cb9 verificados).
    - Patrón D: 0 duplicados (bloque OBSOLETO en blockquote,
      excluido del conteo).
    - Patrón M114: 0 deferrals (138 [ ] = alcance
      post-lanzamiento legítimo; 6 [?] con dueño).
    - Hallazgos iter. 4 verificados REALES: quality.yml:976
      `--ci-gates-ok "1"` hardcodeado; acta no existe;
      estado_release.json detrás de la realidad.
- **Restricciones:** único flip = H.L121 (autorizado por el
  director); CHECKLIST-GLOBAL NO tocado (fila 53 pendiente de
  actualización por el director: 146/165 → 145/165); 0 commits.
- **Entregables:** msg 62 del canal Ling-3.1-Flash (2026-10-11
  22:58:36) + **Log 1710** (pool consumido 1710→1711 vía
  `--reservar`; el 1709 lo tomó otro agente).
- **Recepción:** msg 64 del director (2026-10-11 23:04:59): M151 QA
  ACEPTADO ("COHERENTE, sin inflación... Tu QA fue exhaustivo"),
  H.L121 degradado correctamente, M53 actualizado a 145/165,
  BUG-133 registrado. Sin módulo nuevo asignado.

### L-23 — Reporte de cierre de ciclo + pedido de próximo módulo (directiva del usuario 2026-10-12) — `[x]` COMPLETADA (2026-10-12)

- **Qué era:** el usuario señaló que sin reporte el director no
  delega ("si el director no sabe que hiciste no te delega nada")
  y pidió regla de reporte obligatoria en el cronómetro. El
  director aceptó todo (msg 59/61/64) pero nunca respondió
  "¿otro módulo?" (msg 59) ni "¿otro módulo o cerramos el
  ciclo?" (msg 62).
- **Qué hice:**
  1. **Cronómetro reemplazado** (borrado
     `wku_12d36a0c3001rYeP1Yk9OQ1Slr`, creado
     `wku_12e1165bb001JR7Di7fB0ME0jU`, `*/30 * * * *`):
     nueva REGLA DE REPORTE OBLIGATORIA — si la ronda ejecuta
     tareas con cambios en disco, escribir el reporte en el
     canal vía `scripts/reservar_mensaje.py` ANTES de terminar
     el turno; si no hubo tareas, silencio (T-19).
  2. **msg 65 del canal** (2026-10-12 00:06:27): reporte
     consolidado de cierre de ciclo con evidencia (M53
     145/19/1, BUG-129/130/133, 4 suites 46/0, QA M151
     coherente 23/167) + **pedido explícito de asignación**
     (primario: re-auditoría stale >30 días, cola de s3;
     alternativa: QA cruzada de M107 cerrado por s3).
- **Verificación anti-inflación de la otra sesión (ronda
  02:30Z):** M53 en disco = 145 [x] / 19 [ ] / 1 [?] (regex)
  y BUG-133 presente en `11-BUGS.md` (§5 + §6) — claims de
  msg 62 reales.
- **Entregables:** msg 65 del canal Ling-3.1-Flash.
- **Recepción:** msg 66 del director (00:10:05): ciclo M53+M151
  CERRADO ("Excelente trabajo") + encargo M99 QA §21.8.

### L-24 — Ronda 10-min: ciclo M99 cerrado (QA aceptada + drift Totales corregido) — `[x]` COMPLETADA (2026-10-12)

- **Qué era:** primera ronda de cronómetro a 10 min
  (usuario: "baja tu cronometro cada 10 minutos"). El
  encargo M99 QA (msg 66) fue ejecutado por la otra
  sesión Ling (msg 68: COHERENTE, sin inflación,
  155/169, NO candidato a ✅, runtime 11/0 exit 0) y
  aceptado por el director (msg 69), quien corrigió el
  drift de Totales ("lo corrijo yo ahora").
- **Qué hice:**
  1. **Cronómetro reemplazado** (borrado
     `wku_12e1165bb001JR7Di7fB0ME0jU`, creado
     `wku_12e22135a001UdUAOx8HY6ox17`, `*/10 * * * *`).
  2. **Verificación de la corrección del director**
     (auditoría checklist↔disco): línea Totales de
     `DOCUMENTACION/99-Marketing/plan-actual/05-Checklist.md`
     L289 ahora "169 ítems · Completados: 155 ·
     Pendientes: 14 · No resueltos: 0"; conteo regex
     155 [x] / 14 [ ] / 0 [?] = 169 — **0 drift** vs
     Totales y CHECKLIST-GLOBAL (fila 99).
  3. **msg 70 del canal** (00:32:26): recepción de
     msg 69 con evidencia de la corrección (regla de
     reporte del broadcast msg 67: último mensaje del
     director → reporte obligatorio).
- **Entregables:** msg 70 del canal Ling-3.1-Flash.
- **Recepción:** msg 71 del director (00:37:21):
  encargo BUG-133 — "NO está arreglado... Fix:
  cambiar por notif.push(...)".

### L-25 — Encargo msg 71: BUG-133 corregido (toasts de crafting visibles) — `[x]` COMPLETADA (2026-10-12)

- **Qué era:** fix de BUG-133
  (`crafting_feedback.gd:119` llamaba
  `notif.show_notification()`, método inexistente →
  toasts de crafting invisibles, solo consola).
- **Qué hice:**
  1. **Fix** (`crafting_feedback.gd:114-121`):
     guard `has_method("push")` +
     `notif.push({"text": texto, "type":
     <ToastType>, "icon": tipo})`; mapeo "ok"→ITEM
     (📦), "descubrimiento"/"fallo"→EVENT (🔔).
  2. **Corrección al fix sugerido (msg 71):** las
     claves reales de `push()` son `text`/`type`
     (`notification_service.gd:67-68`), NO
     `texto`/`tipo` — con las claves del msg 71 el
     toast se crearía vacío (`_spawn_node` lee
     `text`/`type`, L94-95).
  3. **Test headless nuevo**
     `scripts/crafting/test_m16_crafting_toast.gd`:
     **9 checks / 0 fallos / EXIT 0** (Godot
     4.7.2, autoload real `/root/NotificationService`).
     Debug: la v1 del test creaba un nodo
     duplicado "NotificationService" en /root — el
     autoload ya existe desde el boot; la v2 usa
     el autoload real (camino runtime). Parse fix:
     `get_node_or_null` es de Node, no de
     SceneTree → `root.get_node_or_null(...)`.
  4. **BUG-133 → RESUELTO** en
     `DOCUMENTACION/11-BUGS.md` (tabla §5 +
     ficha §6 con código y evidencia).
- **Entregables:** msg 72 del canal
  Ling-3.1-Flash (00:56:22) + test M16 +
  11-BUGS.md actualizado.
- **Recepción:** msg 73 del director
   (00:58:26): BUG-133 ACEPTADO ("Tu fix es
   correcto"). Recepción msg 74
   (01:01:34, regla broadcast msg 67).

### L-26 — Sesión cron: BUG-133 verificado (test v2 corregido) + documentación cerrada — `[x]` COMPLETADA (2026-10-12)

- **Qué era:** cierre del encargo msg 71
   (BUG-133) desde la revisión del canal: el
   test de verificación v1 daba 2 FAILURES
   (falso negativo) y quedaban pendientes
   log, M53 L121 y notas del agente.
- **Qué hice:**
   1. **Diagnóstico del falso negativo:** en
      `--script` headless los autoloads SÍ
      instancian al boot; el test v1 creaba
      un nodo duplicado "NotificationService"
      (Godot lo renombra) y `_notificar()`
      (ruta absoluta) empujaba al autoload
      real → conteo 0.
   2. **Test v2 corregido**
      (`test_m16_crafting_toast.gd`): autoload
      real `/root/NotificationService`, conteo
      relativo `antes`, limpieza `clear_all()`,
      E-31 documentado → **9 checks / 0 fallos
      / EXIT 0**.
   3. **Regresión `test_crafting.gd`: 0
      fallos / EXIT 0.**
   4. **Encoding UTF-8 sin BOM** verificado en
      ambos `.gd`.
   5. **NUL reparado** en
      `DOCUMENTACION/16-Crafting/plan-actual/
      04-Codigo.md` (posición 24359 → '0',
      byte-exacto, longitud preservada) +
      Notas del Agente BUG-133 añadidas.
   6. **M53 `05-Checklist.md` L121:**
      correlato BUG-133 → RESUELTO (re-escopo
      SFX sigue pendiente, dueño M91).
- **Entregables:** Log 1723 + test v2 + docs
   (msg 72/74 ya cubren la entrega al
   director; no se requiere msg 75).
- **Recepción:** msg 73 del director (BUG-133
   ACEPTADO, "Tu fix es correcto").

### L-27 — Encargo msg 78: M83-Licencias barrido (núcleo ampliado) — `[x]` COMPLETADA (2026-10-12)

- **Qué era:** encargo del director (msg 78): "Amplía,
   no recrees" el núcleo de M83
   (`license_scanner.gd`, `license_validator.gd`,
   `license_policy.gd`), test headless, no tocar
   CHECKLIST-GLOBAL, no commit, UTF-8, reportar en canal.
- **Qué hice:**
   1. **Ampliación** `license_scanner.gd`:
      `verificar_uso_comercial()` (B.9), `detectar_dual()`
      (B.14), `verificar_integridad()` (G.9),
      `include_in_build()` (C.5), `generate_notice(...,
      build_version)` (C.6), `save_notices(..., build_version,
      formato)` txt/md/json + copias con texto original
      (C.4/G.6) + `_notices_md()`.
   2. **Verificado stale → [x]:** B.4/B.7/B.8, B.11/B.12/B.13,
      C.2/C.8/C.9 (existían, mal marcados).
   3. **Test nuevo** `test_m83_barrido.gd`: **37 checks,
      0 fallos, EXIT 0** (2 bugs de test corregidos: afirmación
      `is_empty` vs INFO/WARN de obligaciones; tilde
      "atribución").
   4. **Regresiones:** scanner agnes 24/0 EXIT 0; validator
      17/0 EXIT 0.
   5. **Checklist M83:** 19 ítems `[x]`, Totales corregido
      (stale 32 → real 34 → ahora **53/47/0**), Reserva actual
      + sección Iteración 5.
   6. **Encoding:** UTF-8 sin BOM (BOM removido de
      `license_scanner.gd`).
   7. **Entrega:** msg 80 del canal (Responde a msg 78).
- **Cumplimiento:** CHECKLIST-GLOBAL no tocado ✓, sin commit ✓.
- **Lo que NO hice (honestidad):** §D/§E/§F (M72/M117/M55/M71),
   G.1-G.5/G.10, H.9/H.10, §I — fuera de alcance o de otros
   módulos dueños.
- **Entregables:** msg 80 + Log 1730 + test + docs.

## Candidatos de nicho (sujeto a L-01)

#### Auditoría de seguridad (respaldo de Atria)

- [x] Re-verificación de `scripts/auditar_secrets.py` sobre el árbol (Atria midió 0 secrets en 634 archivos — comprobar con un escáner paralelo) — **L-08: 707 archivos, 0 secrets, exit 0** (el "634" de Atria era de 2026-10-08; hoy son 707)
- [ ] Parseo y auditoría de save files (`scripts/saving/`, M59) — validación de inputs externos
- [x] Revisión de `scripts/security/` (M106) como segundo par de ojos sobre el trabajo de DeepSeek V4.1 Flash — **L-08: 237 checks / 0 fallos / 8× EXIT 0, coincide con Log 1480**
- [ ] Auditoría de los flujos de input externo de M106 (validación de vulnerabilidades)

#### Skills y automatización

- [ ] Auditoría de `.claude/skills/` (§27): ¿las skills instaladas están alineadas con los flujos reales del proyecto?
- [ ] Generación de checklists de módulo desde evidencia en disco (no desde claims)

#### Análisis técnico de datos

- [x] Análisis de `Logs/`: métricas de productividad por modelo, módulos sin actividad, candados colgados — **L-06 COMPLETADA 2026-10-11** (msg 27 del canal; 1567 logs, 30/24h, familias DeepSeek ~320 / agnes ~311 / glm ~191; candados M154 activo + M37 columna stale; drift Resumen 3🔵 vs 2 en tabla; 10 módulos 🟡 >30 días)
- [x] Coherencia `05-Checklist.md` vs código real en disco (método A de T-D7, muestreo dirigido) — **L-09/L-10/L-12/L-13 COMPLETADAS 2026-10-11** (msg 33: M51-Agua 5/5; msg 34: M58-Accesibilidad 5/5 + suites 39/0 y 13/0 EXIT 0; msg 38: M113-Stress 5/5 + test EXIT 0; msg 40: M107-Backups 5/5 + test 28/0 EXIT 0)
- [ ] Análisis de resultados de suites headless: tasas de fallo, patrones, módulos frágiles

## Orden de trabajo sugerido

1. Leer `AGENTS.md` completo + esta guía + la §5.S de `10-GUIA-COMPARATIVA-MODELOS.md`.
2. Esperar la asignación de **L-01** por el director.
3. Ejecutar L-01 con método: reservar log → implementar → verificar con evidencia objetiva → log → informe en el canal.
4. Si L-01 pasa, desglosar nichos en L-02…L-100+.

## Firma

**Modelo:** ling-3.1-flash (inclusionAI / Ant Group)
**Plataforma:** Kilo Gateway / OpenCode / Vercel AI Gateway / OpenRouter
**Fecha de alta:** 2026-10-06 (investigación y alta por Atria-Dawn-Preview sesión s3 / Kilo Code)
**Evidencia en este repo:** ninguna aún (sin sesiones de trabajo) — specs verificadas en fuentes externas + Kilo Gateway verificado in-house
