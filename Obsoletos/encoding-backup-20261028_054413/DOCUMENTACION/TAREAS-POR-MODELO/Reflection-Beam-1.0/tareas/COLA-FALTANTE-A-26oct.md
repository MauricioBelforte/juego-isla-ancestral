# COLA FINAL â€” pendientes A-DOC/FORMULA vivos de Beam (28oct, regenerado por GLM-5.3-Flash con el estado actual del disco)

Filtrado: SOLO items de su nicho A (excluidos 376 B-EDITOR/ARTE + C-SKIP/duenos/DEP-BLOQ y 51 que ya estaban [x] en el 05 de disco).
Ejecutar EN ORDEN. Por cada item: spec/fÃ³rmula en 03-Diseno (seccion unica, grep previo anti-duplicado) + flip del 05 CON CITA y marcar [x] ACA. Si no puede (dueno ajeno/dep), desmarcar a [ ] con motivo en el reporte (honesto).
Tandas de 5 items con reporte en canal (numeracion ultimo+1, firma). PROHIBIDO declarar completo: solo 'avance X/Y â€” pendiente re-medicion'.

| # | T-file origen | Modulo | Tarea | Hecho |
|---|---|---|---|---|
| 1 | T105-54.md | 54 | L93 | [x] | Niebla mÃ¡s clara en zonas visitadas y oscura en no exploradas â†’ agnes-2.5-flash 2026-09-13: politica documentada en 03-Diseno.md Â§4.22 (fog density by visited state); visual gradie |
| 2 | T110-33.md | 33 | L44 | [ ] | P21: recetas con cultivos â€” catÃ¡logo M16 (ensaladas, pan, tintes, ofrendas) [M] â€” SKIP: dependencia externa M16 (dueÃ±o ajeno)
| 3 | T110-33.md | 33 | L120 | [ ] | InteracciÃ³n F sobre tierra arada abre selector de semillas (M70/M53) [M] â€” SKIP: dependencia externa M70/M53 (dueÃ±o ajeno)
| 4 | T110-33.md | 33 | L126 | [ ] | CancelaciÃ³n segura del selector sin consumir semillas [S] â€” el selector UI no existe aÃºn (M53); plant() no consume semilla si la validaciÃ³n falla â€” SKIP: dependencia externa M53 (dueÃ±o ajeno)
| 5 | T110-33.md | 33 | L166 | [ ] | NavegaciÃ³n M64 evita celdas cultivadas cuando hay ruta alternativa [C] â€” SKIP: dependencia externa M64 (dueÃ±o ajeno)
| 6 | T110-33.md | 33 | L169 | Cosecha con inventario lleno: sobrante devuelto con notificaciÃ³n [M] â€” CUBO: A-DOC/FORMULA |
| 7 | T110-33.md | 33 | L173 | Borrado de parcela (M17) con cultivos activos: aviso previo y devoluciÃ³n de semillas [M] â€” CUBO: A-DOC/FORMULA |
| 8 | T123-40.md | 40 | L261 | Copiar plan-inicial a plan-actual byte a byte (verificaciÃ³n por hash) [S] â€” **Ãtem invÃ¡lido por diseÃ±o (orden del director mimo, msg 229, hallazgo K):** contradice AGENTS.md Â§3, qu |
| 9 | T135-53.md | 53 | L221 | Canvas merge por capa para minimizar draw calls [M] â€” AUDITORÃA 2026-10-12 (Ling 3.1 Flash): la UI usa MÃšLTIPLES CanvasLayer (UIRoot CanvasLayer 100 + HUDScreen + TooltipService + |
| 10 | T135-53.md | 53 | L229 | Font subsetting por idioma (M88) para evitar desperdicio de memoria [M] â€” AUDITORÃA 2026-10-12 (Ling 3.1 Flash): `theme_ux.gd:193-208` `_try_load_font` carga las TTF completas con |
| 11 | T140-50.md | 50 | L176 | Viento determinista con amplitud por bioma/clima [M] â€” [ ] honesto 2026-10-19 (Log 2022): no existe viento_shader.gdshader ni shader de viento en disco (find = 0 archivos). â€” CUBO: |
| 12 | T155-94.md | 94 | L99 | [?] DEGRADADO â€” Definir 3+ variantes por festividad (4 y 3 variantes en 2 festividades) [C] â€” degradado [?] 2026-10-15 (auditorÃ­a Step-5 47, Â§21.8.2.b) â€” CUBO: A-DEF/FORMULA (re-ve |
| 13 | T156-94.md | 94 | L123 | [?] DEGRADADO â€” Definir regalos del dia (catalogo) sin exclusividad [S] â€” **DEGRADADO por el director (2026-10-10, QA Â§21.8 de agnes-3-flash msg 198): PatrÃ³n D â€” duplicado idÃ©ntico |
| 14 | T156-94.md | 94 | L144 | [?] DEGRADADO â€” Definir prohibicion formal de streaks [S] â€” **DEGRADADO por el director (2026-10-10, QA Â§21.8 de agnes-3-flash msg 198): PatrÃ³n D â€” duplicado idÃ©ntico de la lÃ­nea 6 |
| 15 | T156-94.md | 94 | L145 | [?] DEGRADADO â€” Definir prohibicion de contenido exclusivo temporal [S] â€” **DEGRADADO por el director (2026-10-10, QA Â§21.8 de agnes-3-flash msg 198): PatrÃ³n D â€” duplicado idÃ©ntico |
| 16 | T156-94.md | 94 | L146 | [ ] | SKIP: Patrón D — duplicado idéntico de la línea 6 (vuelve o lo pierdes) |
| 17 | T156-94.md | 94 | L147 | [ ] | SKIP: Patrón D — duplicado idéntico de la línea 6 (penalización de ausencia) |
| 18 | T157-94.md | 94 | L165 | [x] | HECHO: spec en 03-Diseno.md L89-90 Beam 751; flip 05-Checklist L165 [x] con cita Beam 751 |
| 19 | T157-94.md | 94 | L172 | [x] | HECHO: spec en 03-Diseno.md L92-93 Beam 752; flip 05-Checklist L172 [x] con cita Beam 752 |
| 20 | T157-94.md | 94 | L191 | [x] | HECHO: spec en 03-Diseno.md L95-96 Beam 753; flip 05-Checklist L191 [x] con cita Beam 753 |
| 21 | T157-94.md | 94 | L192 | [ ] | SKIP: sin spec en 03-Diseno.md (no existe §20.3); director degradó como "M114 deferral disfrazado — contenido no existe hoy" |
| 22 | T158-11.md | 11 | L80 | [ ] | SKIP: sin spec en 03-Diseno.md (solo §5 Sistema de luz destellos=coleccionables, no streaming lejano) |
| 23 | T159-11.md | 11 | L109 | [ ] | SKIP: dependencia externa M65 (dueño ajeno) — assets finales pendiente de M65 |
| 24 | T204-131.md | 131 | L93 | [ ] | SKIP: dependencia externa M41 (dueño ajeno) — fade-out gradual al salir, dueño M41 |
| 25 | T225-62.md | 62 | L190 | [ ] | SKIP: NO MEDIBLE — no hay escena de menú (project.godot arranca en main_island.tscn; no existen scenes/main_menu.tscn ni similares) |
| 26 | T225-62.md | 62 | L193 | [ ] | SKIP: NO MEDIBLE — no existe templo/API de acceso (no hay escena *templo* ni *subterr* en scenes/) |



