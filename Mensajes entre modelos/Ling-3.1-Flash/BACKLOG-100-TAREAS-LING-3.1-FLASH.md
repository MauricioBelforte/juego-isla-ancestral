# METODOLOGIA V2 (directiva del fundador 2026-10-17) — COMO USAR ESTE ARCHIVO

**Modelo mantenimiento:** GLM-5.3-Flash-Director (GLM-5.3-Flash) / Kilo Code
**Fecha de alta:** 2026-10-17

Este archivo es TU backlog de tareas, y lo mantiene ACTUALIZADO el DIRECTOR (GLM-5.3-Flash-Director) en TU carpeta de canal. Ya no resides en DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/.

## Tu ciclo como agente (en este orden):

1. **PRIMERA INSTANCIA:** lee si el director te escribio un mensaje en tu canal (Mensajes entre modelos/Ling-3.1-Flash/). Si hay mensaje dirigido a ti, RESPONDELO primero (numeracion de hilo: ultimo + 1; borra SOLO ese numero del pool NUMEROS_DISPONIBLES.txt de tu carpeta — pools NO se commitean).
2. **SEGUNDA INSTANCIA:** si NO hay mensajes del director, toma el proximo item [ ] de ESTE backlog que puedas hacer segun tu nicho (GUIA-COMPARATIVA DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md). Trabaja una TANDA de tareas (las que elijas).
3. **CIERRE DE TANDA:** al terminar tu tanda, escribe un REPORTE en tu canal al director: que tasks cerraste (ids), evidencia (archivos/tenets/tests), y actualiza las marcas [ ]->[x] de las que completaste (marca solo lo verificable en disco, honestidad del protocolo).
4. El director actualizara este backlog, llevara la fila de CHECKLIST-GLOBAL.md y te respondera.

## Reglas que NO cambian:

- Reserva de modulo (§21.3 azules) en CHECKLIST-GLOBAL + ESTADO-PARALELO + 05-Checklist antes de tocar modulos.
- Numeracion de mensajes por hilo (ultimo + 1) con pool por canal. Pools gitignoreados.
- UTF-8 estricto (apendice 28), firmas de documento, logs de cierre en Logs/ (tareas de cierre formal).
- Independencia de modelo en QA (§21.8/21.23).
- NO delegues ni edites el backlog de OTRO modelo ni la carpeta de OTRO agente.

---

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
5. M87: documentar los cierres en el Log 19XX (patrón del 1906 de DeepSeek).

### Bloque B — PT restante (el fruto del 144-145)

6. `strings_pt.json`: WEAPONS/JUEGO — las claves restantes de `tools.csv`/catálogo M13/M15 que usan placeholders.
7. `strings_pt.json`: claves M21-Diálogos (`eventos.*`, `dialogo.*` — las 32 claves de conversaciones).
8. `strings_pt.json`: claves M74-Eventos (los 22 eventos del catálogo — `festival_*_nombre` etc.).
9. `strings_pt.json`: claves M65/M36-Fauna (las especies de fauna — 22 nombres).
10. `strings_pt.json`: claves M50-Vegetación (los 109 plan items — 65 instanciadas).
11. `strings_pt.json`: claves M15-Recursos (los nodos madera/piedra/baya/etc).
12. `strings_pt.json`: claves M76-Multijugador (el contrato MP de Step-5 — los strings por el contrato).
13. `strings_pt.json`: claves M95-Monetización (3 ediciones + 2 DLC).
14. `strings_pt.json`: claves M37-Museo (4 exposiciones + items).
15. `strings_pt.json`: claves M160-Ubicaciones (39 catálogo + 48 ubicaciones).
16. `strings_pt.json`: clave huérfana `eventos.historia_c2_nome` -> decision si rename a `_nombre` (con mi acuse).
17. `strings_pt.json`: revisar el fallback del localization_manager si losцат claves PT faltan (hoy: cae a ES).
18. `strings_pt.json`: reporte final del PT (conteo total, par E-W, validación all).

### Bloque C — Estado de integridad (estándar informe 142)

19. Control integridad semanal de los 3 catálogos (ES/EN/PT): conteo, UTF-8 strict, BOM, 0 U+FFFD.
20. Control placeholders ES<-EN: 0 discrepancias (el estándar 142 §3).
21. Control placeholders EN<-PT.
22. Control claves muertas (claves presentes en catálogo pero nunca referenciadas en código).
23. Control claves huérfanas (referenciadas en código pero ausentes del catálogo).
24. Control duplicadas exactas en cada catálogo.
25. Control claves de usuario-visible vs técnico (las `key_*` de UI).
26. Reporte de auditoría mensual (el estándar 142 — report-only).
27. Validador de integridad como script reusuaje (el "control integridad" adaptado del 142 — `scripts/validar_i18n_integridad.gd` o el de su metodología python).
28. Control claves SETTINGS.* las 4 M91 (AMBIENTE/VOCES/UI/CINEMATICAS) presentes en ES/EN — PT dodatnie en curso.

### Bloque D — M88 Fuentes (el estado de fuentes para idiomas)

29. M88: medición del estado (`05-Checklist M88` — 174/185).
30. M88: resolver los ítems pendientes (11 `[ ]`/`[?]`).
31. Control de glifos: los caracteres especiales de each idioma (á, ñ, ß, п...) presentes en la fuente.
32. Control fuente tamanho (la precisa en UI con fuente personalizada).

### Bloque E — Subtítulos y diálogos multi-idioma (nicho Hy3/mío)

33. M113: los subtítulos multi-idioma (los diálogos de M21/M162 con interliniado).
34. Subtítulos: control de longitud de texto por idioma (ES vs PT — el draw de text ancho).

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

46. Control placeholder `%1$s`-estilos vs `{n}`-estilos (los 2 estilos en uso — el estándar del proyecto unificar).
47. Control pluralización (los plurales por idioma ES/EN/PT si aplican — las cantidades del juego).
48. Control 3rd language 3er idioma (los 3er idioma del juego — la decisión del scope multilingüe).
49. Control de formato de números/fecha por idioma (los TimeCalendar strings).
50. Control de los sufixes de idioma en los archivos (es/en/pt — sistemático).

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
