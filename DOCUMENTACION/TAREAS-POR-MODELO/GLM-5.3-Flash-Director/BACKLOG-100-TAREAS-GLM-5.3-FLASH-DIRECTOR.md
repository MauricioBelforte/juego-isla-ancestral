# BACKLOG 100+ TAREAS — GLM-5.3 FLASH-DIRECTOR (rol ejecutante propio)

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 (nuevo día — directiva del fundador 2026-10-16/17: backlog del ROL DIRECTOR para delegarme a MÍ MISMO en tiempos libres, cuando no haya mensajes que responder)
**Diferencia con los otros backlogs:** estos son tareas que el DIRECTOR ejecuta CON SUS PROPIAS MANOS (rol de pasamanos ejecutante + agente ocasional directamente ordenado) — no las que delega a la flota. El detalle está en `ROLES-DE-AGENTES.md` (los otros 5 backlogs son para los agentes).
**Reglas:** numeración de hilo/pool (Log 1875), catch-up sin `-A` (lección 63), filas a 11 celdas, T-19 en mensajes vacíos, UTF-8 estricto siempre, novedad material al fundador. Cron del director a 15 min (`CRON-DIRECTOR-COMO-CREARLO.md`).

## LAS 105 TAREAS

### Bloque A — Ronda diaria del director (lo mínimo diario)

1. Leer los 8 canales activos reconocidos y listar mensajes nuevos (ventana desde el último chequeo) — respuesta a cada uno.
2. Re-base reactivo del tren de agnes (colisiones 6xx) — patrón conocido: detección por python de duplicados → rename al siguiente libre → pool.
3. Push diario trazado (commits de catch-up + line de log con rango empujado, §4.3).
4. Estado del remoto vs local (HEAD == origin/main o divergencia medida).
5. Sanitizado de `ESTADO-PARALELO.md` (bytes NUL/CRLF — ya limpié 04; re-verificación).
6. Lectura de la fila del día de cada módulo tocado (fila GLOBAL: estado real vs editado).
7. Respuesta a cualquier plantilla vacía T-19 madurada (≥2 ciclos) — aviso o espera.
8. Normalización del pool de Logs global (cabeza real, sin huecos no documentados).
9. Registro del día del director (log en Logs/ con número del pool global).
10. Aplicación de fila de cierre del día (como el 1905) cuando toque.

### Bloque B — Verificaciones directas con MCP (lo que solo yo validé hoy)

11. `test_settings_audio_roundtrip.gd` re-verificación semanal (79/0 esperado — el pie de checks fue medido).
12. `test_templo_m26.gd` re-verificación (110/0 — el que double-verifiqué).
13. Run de `quality.yml` o local-parse equivalente del YAML (confirmar el fix de 830efc5 sigue verde a nivel de parseo aunque run OK).
14. Spot-check de los 5 flips de M91 en `settings_audio_layer.gd` (qué fueron flips de L201-L204 + L210).
15. Claves i18n `SETTINGS.AMBIENTE/VOCES/UI/CINEMATICAS` en `strings_es/en.json` (verificación que siguen).
16. Conteo por script de checklist de los módulos de los cierres del día (M26/M30/M32/M55/M76 medidos).
17. Corridas de tests headless comprados (Godot 4.7.2 binario en GODOT_PATH — réplicas de los del día).
18. Verificación por `git merge-base --is-ancestor <hash-of-day> HEAD` para los commits candidatos (patrón Hy3 para mis sellos).
19. Reconciliación sub-sección: cada "fila GLOBAL 26/30/32/55/76/91/118/117" — comprobar señal exacta de las 11 celdas y head de fila exacto.
20. Verificación de la "fila 680" newbie si se carga el tar de agnes (frecuencia)... general report.

### Bloque C — La cola estrella del archivo directo (L199/CI)

21. **M118 L199** — flip a [x] cuando el run de `quality.yml` dé VERDE (con `gh run list` evidencia — precondición ya en push `dfc4126...`).
22. Si el CI sigue rojo en la capa por "test_diario_perf" u otro WIP de Step: confirmar si el commit del fix ya llegó (stress de catch-up: según Step 5).
23. Si el CI está rojo por la capa de economía (M38 — los tests de guardas añadidas por DeepSeek): verificar con el mismo conteo de guardas (11/20/23 matriz).
24. Correr `scripts/validar_workflows.py` y verificar 6/6 (como DeepSeek midió).
25. Si alguna suite queda roja por SCRIPT ERROR de archivos de autores nuevos (agnes/Step): reportar al dueño del módulo con puntero, no lo tapa el director.
26. Seguimiento de `gh run list --workflow=quality.yml --limit 5` (respuesta por cana al canal de DeepSeek si hay cierre directo).
27. Seguimiento del resolver de run: "CI ROJO 3/3 → VERDE" (la deuda L199 queda — como marcó Hy3 y DeepSeek) — no tan solo en flip sino en evidencia completa del run verde de dos días consecutivos.
28. Cierre directo del run: si el run queda verde 2 veces aglomerado, configurar release check day (propuesta al fundador).
29. Documentación de historial de los runs por día (leve track log si el run nollega a verde durante 48 horas — el estado real queda capturado en la fila del módulo).

### Bloque D — Material de dirección (mantenimiento continuo)

30. `CRON-DIRECTOR-COMO-CREARLO.md`: afinar con lecciones nuevas (ya corregí "modelle" typo y el corte del prompt).
31. `ROLES-DE-AGENTES.md`: refresco semanal con evidencia (el afinal "jornada 16" ya lo tengo).
32. `MATERIAL-DIRECTOR.md`: disponibilidad de flota declarada por el fundador (re-confirmar con cada arranque).
33. Backlogs de flota (agnes/DeepSeek/Hy3/Step5/DS-Opencode): marcar tareas completas/cerradas cada bloque de cierre → mantener 100+ disponibles cada uno.
34. Backlog DIRECTOR (este archivo): tick las tareas [x] de cada cierre diario.
35. Pool de agnes: normalizar (cabeza correcta después del re-base — el próximo de agnes debe ser siempre la cabeza del pool o siguiente libre).
36. Pools de canal: limpiar BOM si reaparece al reescribirlos por agentes:
37. Pool global de Logs: normalizar (cabeza siendo 1906 tras mi 1905).
38. Filas GLOBAL: detección/修复 de anomalías (10/11 celdas — reparar como 76/55).
39. ESTADO-PARALELO.md: sanear bytes CR/NUL — ya en parte; y nueva actualización del relevo.
40. Logs/NUMEROS_DISPONIBLES global: normalizar (cabeza 1906: después de mis Logs 1875-1905 + los de la flota).
41. Logs duplicados (1876/1878/1888/1904-doble?): tratamiento como historial coexistente (no borrar, solo anotado en el registro).

### Bloque E — Coordinación y ruteo del director (delegaciones puntuales)

42. Delegación con puntero exacto a Step-5 para el frente activo en su cola (M55 rendimiento → M55 catálogo → M51/M50/M49...).
43. Delegación a DS-Opencode para el micro-lote → M112 → fix de economía → M159 (ya autorizado).
44. Delegación a DeepSeek-WB: ruteo claro de M159 con medición L216.
45. Delegación a agnes: continuar barrido con control de número (638+ — hay que avanzar la estructura de rangos cada ronda: 500-599 completo, 600+ en raíz mientras sea ≤100).
46. Delegación a Hy3 "de a poco" (su saturación declarada) — QA con medición real, colas cortas.
47. Notificación del relevo a kimi-k3 / Claude-Haiku-5.5 / muse-spark cuando den señal de vida (no crítico).
48. DELEGACIÓN de los 17 [ ] de M159 con conteo L216 como marco (lote DeepSeek aprobado — ver msg 275).
49. Ruteo de los ex-[?] del M30: L71 queda para M45/M46 (dueño) — hasta que se desbloquee.
50. Ruteo del frente de M29: flecha HUD ×2 → agnes (fila M53) cuando libere.
51. Ruteo de los [?] honestos de M55 (12 con dueño externo: M36/M34/M50/M35/M16/M24/M26/M25/M71/M56).
52. Ruteo de los 11 manifiestos de M76 (ya los [x] flipó Step-5 — sigue OK).
53. Apuntar los **[ ] 4 de M76** (fase MP) — pendiente de implementación real de multijugador (lote de diseño/patrón contractual).
54. Re-ruteo del frente de M56 (fotografías del diario) — los 5 [?] del frente del archivo/galería.

### Bloque F — QA externo en cola (ruteo objetivo)

55. QA §21.8 de M76 (126/130) — pendiente de verificador externo (agnes/Hy3 con cola libre).
56. QA §21.8 de M55 (58/131) — pendiente idem.
57. QA §21.8 de M29 (192/195) — Hy3 apuntó el sello... (verificar la segunda firma).
58. QA §21.8 de M30 (119/120) y M32 (119/121) — en la cola de los veredictos.
59. QA §21.8 de M117 (94/110) y M26 (122/129) — ✅ sellados (verificar coherencia semanal).
60. QA §21.8 de M91 (217/239) — ✅ sellado.
61. QA §21.8 de M118 (105/106) — ✅ sellado (L199 [?] aparte).

### Bloque G — Auditoría y limpieza diaria

62. Duplicados físicos de los canales activos (detección por prefijo, como el patrón agnes) — re-base diario.
63. Logs que llegan con el mismo prefijo (1904 doble etc.): anotación en el pequeño registro de colisiones (coexistencia histórica).
64. Filas GLOBAL: revisión de 10/12 celdas (reparación patrón fila 76/55).
65. `ESTADO-PARALELO.md`: sin duplicación de cabecera (lección del relevo del director — la cabecera del relevo con título).
66. Backup de encoding habitual (like el b27caed atrapado — verificable con `verificar_bom.py`).
67. `10-GUIA-COMPARATIVA-MODELOS.md` (afinar como hago en la ronda: agrega specs nuevas si cambio).
68. `AGENTS.md`: actualización de reglas nuevas (§10.2 fijo de numeración ya está, §31 relevo ya está).
69. Propuestas de mejora en la GUIA-COMUNICACION.md (si el flujo lo pide).
70. Chequear los LISTADOs de pendientes de los mensajes no respondidos (T-19 maduros).

### Bloque H — Flujo agente-directo (módulos sin bloqueo, cuando el fundador ordene directamente)

71. M139-Pre-Alpha (mi M139): continuaciónd Hugo/Aurora — el frente de agnes sigue activo (barrido) — no pisar, pero puedo colaborar en los [ ] si queda desbloqueado.
72. M52-Particulas: los [sub-flips L144 y L60] ya resueltos — el cierre del frente espera la decisión del autoload VfxManager → con DeepSeek/others.
73. M49/46/30 (bloqueo L71): depende de M45/M46 — puedo aportar el análisis de diseño del bloqueo.
74. M137-Prototipo (8/131 — 123 [ ]): el drift de agnes ya detectado — puedo acometer el módululo con Continue (no asumo por ejemplo, lo trato como D74 con asignación del fundador).
75. M55-121: catálogo cleaning por el otro frente (36/44 sin descripción).
76. M159-Catálogo (77/146): con DeepSeek el lote — puede continuar con compromiso del fondo (puedo aportar segunda oleada si la medición L216 lo decide).
77. M64-Memoria (113/150 — 37 [ ] non-headless): convertir sería muy largo — solo con el fundador para diseño pool.
78. M59-Guardado (60/130): mientras for pesos.
79. M67/M70-Transportes (19/131, 98/145): espera diseño — puedo colaborar si el fundador me da vista del requirimiento.
80. M56-Fotografía (26/137): el frente del diario del jugador — puede ser un frente Step/DS; puedo solo overlapping no pisar.
81. M54-Mapa (133/177): los 44 [ ] en su frente — sin opacity.
82. M53-UI-UX (144/165): integrado: el front de los sliders de audio (ya 21 steps en el roundtrip test)... el resto de [ ] quedan para el propio frente UI.
83. M117-Build (94/110): 16 [?] con dueño REAL (M118, M96, M116, M113): no se quedan en mi mano.
84. M118-CI (105/106): L199 = el flip dependiente de run verde (ya es el frente del CI — arriba #21).
85. M120-CGU (83/108): sandbox/validación — puedo acometer el frente si el fundador pide integración CI Métrik.
86. M123-Modding (106/108 — 2 pendientes): se puede cerrar rápido con el frente de DS/Step5 — puedo self-executar si el plan-actual parece listo en 2 ítems.
87. M124-Marketplace-mods: sandbox de seguridad — deferred alto esfuerzo (requiere diseño de permisos modder — trabajo agente largo).
88. M126-Marketing-Legal (101/101): cierre de iteración solo el [1] — se puede self-executar rápido (slug conocida).
89. M91 3 [?]: flecha HUD → agnes (visual), H123 → DS (M112)... no me lo tomo self.
90. M71-Progresión: pendiente de integraciones del run — no me lo tomo (frente activo).

### Bloque I — Interfaces de reporte al fundador y trazabilidad

91. ReporteJuice: informe al fundador de cierre de cada jornada (resumen de cierres, pendientes, rama libre).
92. Push log con trazabilidad del rango (§4.3) — identidad del ejecutante (patrón Log 1888/1905).
93. Filas de cierre del día como el 1905 (para cada cierre de jornada por orden del fundador).
94. Historial del relevo/archivo de dirección (MATERIAL/soporte directo del relevo).
95. Enlaces de circulación interna de mensajes (fiujos de cierre con los agentes — sin falso cierre de T-19 prematuro).
96. Playlist de propaGO de tareas diarias del director (cron activation diary — template receta CRON-COMO-CREARLO).
97. Modelo de comunidad (cada mensaje numerado del día — registrar el índice de interpolación del commitñana).
98. Propósito de set de la flota: disponibilidad NO disponibles (Ling/s2/s3/atria/kimi/Haiku/muse) — re-confirmar con el fundador en cada arranque.
99. Registro de colisiones de pool de Logs (1904 doble etc.) — en la receta se ya; seguir patrón (nada que hacer hoy, son históricos coexistiendo).
100. Plantilla de cierre de martes-viernes: cambios estructurales del día (re-bases, filas aplicadas, QA sellada, sellos, automatización de catch-up) con nombre GLM-5.3-Flash-Director/en-log-formato.
101. Deuda del stagger del CI (el trabajo negro: rutina cd Q. — el job de formato de calidad — se engineer por el job de CI formatting check a lo largo del pipeline del día).

---
**Total: 101 tareas** (números D1-D101 — cada una con alcance concrete del rol DIRECTOR; las de la flota YA están separadas en los 5 BACKLOG-100-TAREAS-<MODELO>.md, los barridos y cierres se marcan a mano en cada ciclo `cron`).

**Al marcar:** completar con `[x]` + fecha + evidencia (hash del commit, run CI, test salida) — las pendientes quedan números de cola.

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-17
