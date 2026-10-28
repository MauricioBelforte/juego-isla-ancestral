# COLA FINAL — pendientes A-DOC/FORMULA vivos de Beam (28oct, regenerado por GLM-5.3-Flash con el estado actual del disco)

Filtrado: SOLO items de su nicho A (excluidos 376 B-EDITOR/ARTE + C-SKIP/duenos/DEP-BLOQ y 51 que ya estaban [x] en el 05 de disco).
Ejecutar EN ORDEN. Por cada item: spec/fórmula en 03-Diseno (seccion unica, grep previo anti-duplicado) + flip del 05 CON CITA y marcar [x] ACA. Si no puede (dueno ajeno/dep), desmarcar a [ ] con motivo en el reporte (honesto).
Tandas de 5 items con reporte en canal (numeracion ultimo+1, firma). PROHIBIDO declarar completo: solo 'avance X/Y — pendiente re-medicion'.

| # | T-file origen | Modulo | Tarea | Hecho |
|---|---|---|---|---|
| 1 | T105-54.md | 54 | L93 | Niebla más clara en zonas visitadas y oscura en no exploradas → agnes-2.5-flash 2026-09-13: politica documentada en 03-Diseno.md §4.22 (fog density by visited state); visual gradie |
| 2 | T110-33.md | 33 | L44 | P21: recetas con cultivos — catálogo M16 (ensaladas, pan, tintes, ofrendas) [M] — CUBO: A-DOC/FORMULA |
| 3 | T110-33.md | 33 | L120 | Interacción F sobre tierra arada abre selector de semillas (M70/M53) [M] — CUBO: A-DOC/FORMULA |
| 4 | T110-33.md | 33 | L126 | Cancelación segura del selector sin consumir semillas [S] — el selector UI no existe aún (M53); plant() no consume semilla si la validación falla — CUBO: A-DOC/FORMULA |
| 5 | T110-33.md | 33 | L166 | Navegación M64 evita celdas cultivadas cuando hay ruta alternativa [C] — CUBO: A-DOC/FORMULA |
| 6 | T110-33.md | 33 | L169 | Cosecha con inventario lleno: sobrante devuelto con notificación [M] — CUBO: A-DOC/FORMULA |
| 7 | T110-33.md | 33 | L173 | Borrado de parcela (M17) con cultivos activos: aviso previo y devolución de semillas [M] — CUBO: A-DOC/FORMULA |
| 8 | T123-40.md | 40 | L261 | Copiar plan-inicial a plan-actual byte a byte (verificación por hash) [S] — **Ítem inválido por diseño (orden del director mimo, msg 229, hallazgo K):** contradice AGENTS.md §3, qu |
| 9 | T135-53.md | 53 | L221 | Canvas merge por capa para minimizar draw calls [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash): la UI usa MÚLTIPLES CanvasLayer (UIRoot CanvasLayer 100 + HUDScreen + TooltipService + |
| 10 | T135-53.md | 53 | L229 | Font subsetting por idioma (M88) para evitar desperdicio de memoria [M] — AUDITORÍA 2026-10-12 (Ling 3.1 Flash): `theme_ux.gd:193-208` `_try_load_font` carga las TTF completas con |
| 11 | T140-50.md | 50 | L176 | Viento determinista con amplitud por bioma/clima [M] — [ ] honesto 2026-10-19 (Log 2022): no existe viento_shader.gdshader ni shader de viento en disco (find = 0 archivos). — CUBO: |
| 12 | T155-94.md | 94 | L99 | [?] DEGRADADO — Definir 3+ variantes por festividad (4 y 3 variantes en 2 festividades) [C] — degradado [?] 2026-10-15 (auditoría Step-5 47, §21.8.2.b) — CUBO: A-DEF/FORMULA (re-ve |
| 13 | T156-94.md | 94 | L123 | [?] DEGRADADO — Definir regalos del dia (catalogo) sin exclusividad [S] — **DEGRADADO por el director (2026-10-10, QA §21.8 de agnes-3-flash msg 198): Patrón D — duplicado idéntico |
| 14 | T156-94.md | 94 | L144 | [?] DEGRADADO — Definir prohibicion formal de streaks [S] — **DEGRADADO por el director (2026-10-10, QA §21.8 de agnes-3-flash msg 198): Patrón D — duplicado idéntico de la línea 6 |
| 15 | T156-94.md | 94 | L145 | [?] DEGRADADO — Definir prohibicion de contenido exclusivo temporal [S] — **DEGRADADO por el director (2026-10-10, QA §21.8 de agnes-3-flash msg 198): Patrón D — duplicado idéntico |
| 16 | T156-94.md | 94 | L146 | [?] DEGRADADO — Definir prohibicion de vuelve o lo pierdes [S] — **DEGRADADO por el director (2026-10-10, QA §21.8 de agnes-3-flash msg 198): Patrón D — duplicado idéntico de la lí |
| 17 | T156-94.md | 94 | L147 | [?] DEGRADADO — Definir prohibicion de penalizacion de ausencia [S] — **DEGRADADO por el director (2026-10-10, QA §21.8 de agnes-3-flash msg 198): Patrón D — duplicado idéntico de |
| 18 | T157-94.md | 94 | L165 | [?] DEGRADADO — Definir notificación suave de objetivo cumplido [S] — degradado [?] 2026-10-15 (auditoría Step-5 47, §21.8.2.b) — CUBO: A-DEF/FORMULA (re-verificar y definir) |
| 19 | T157-94.md | 94 | L172 | [?] DEGRADADO — Definir 30 ciclos de carga/guardado sin pérdida de objetivos [M] — degradado [?] 2026-10-15 (auditoría Step-5 47, §21.8.2.b) — CUBO: A-DEF/FORMULA (re-verificar y d |
| 20 | T157-94.md | 94 | L191 | [?] DEGRADADO — Definir suite MigraciónMotivacion (v3.1→3.2) [M] — degradado [?] 2026-10-15 (auditoría Step-5 47, §21.8.2.b) — CUBO: A-DEF/FORMULA (re-verificar y definir) |
| 21 | T157-94.md | 94 | L192 | [?] DEGRADADO — Definir playtest de 5 usuarios: ¿sienten presión de volver? (M114) [M] -- agnes-2.5-flash 2026-09-12: protocolo disenado en 03-Diseno.md §20.3 (playtest guide); eje |
| 22 | T158-11.md | 11 | L80 | [?] DEGRADADO — Destellos visibles en streaming lejano (no se cargan inútilmente fuera del radio) [M] |
| 23 | T159-11.md | 11 | L109 | [?] DEGRADADO — Assets finales → M65 (terceros) → Pendiente de M65 [M] |
| 24 | T204-131.md | 131 | L93 | [?] DEGRADADO — Fade-out gradual al salir [S] - KnownIssue no bloqueante DoD: dueño M41; no hay pista que atenuar; los motores M41/M42/M43/M91 EXISTEN y pasan tests (M41 14/0, M43 |
| 25 | T225-62.md | 62 | L190 | [?] DEGRADADO — Baseline menú principal: objetivo < 600 MB [S] — **[?] 2026-10-20 (Tanda 78, DS-Opencode): NO MEDIBLE, no hay escena de menú.** `project.godot` arranca en `res://sc |
| 26 | T225-62.md | 62 | L193 | [?] DEGRADADO — Baseline subterráneo del templo (M26): objetivo < 2.000 MB [S] — **[?] 2026-10-20 (Tanda 81, DS-Opencode): NO MEDIBLE, no existe templo/API de acceso.** No hay ning |
