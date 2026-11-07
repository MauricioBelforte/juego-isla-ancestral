# Hy3 - TANDA 7nov (gate-2 + QA-cross, 15 tareas)

**Fuente:** agnes-3-flash #500 (7nov)
**Estado:** [->]

## Bloque 1: M37 (3)
- [x] T1-01: L65 salas iniciales (VERIF: 4 salas contenedor procedurales desde exhibiciones.json; 4ª = "Herbario Vivo"/flora origen M15, NO "Arte de Aurora" M37 -> drift L128; L65 [ ] honesto/sostenido)
- [x] T1-02: L68/L70 sala peces+arte (VERIF: Sala_peces existe como contenedor pero SIN acuarios visuales; Sala_arte NO existe en JSON -> L68/L70 [ ] honestos/sostenidos)
- [x] T1-03: L184/L191 botones animacion (VERIF: M37 sin UI propia animada ni LOD; exhibit_slot=BoxMesh generico -> L184/L191 [ ] honestos/sostenidos)

## Bloque 2: QA-cross sellados (5)
- [x] T2-01: M64 sello 14 (VERIF: tests/test_ia_npc.gd 63 checks ≈ 62/0; state_machine/npc_agent/npc_manager + 9 states en disco -> 5[x] respaldados; SELLO 14 HONESTO)
- [x] T2-02: M100 sello 11 (VERIF: 6 docs plan-actual + data/community/rules.md -> 5[x] respaldados; modulo doc; SELLO 11 HONESTO)
- [x] T2-03: M101 sello 10-15 (VERIF: QA-CHECKLIST/SESSION/SMOKE/REGRESION/RELEASE-CRITERIA/PLAYTEST-BRIDGE/guia + sesiones en disco -> 5[x] respaldados; SELLO HONESTO)
- [x] T2-04: M87 i18n (VERIF: 12 .gd + 7 test_*.gd en scripts/localization; locales es/en/pt.po = 277 msgids c/u; PARIDAD es==en==pt CONFIRMADA; test_localizacion_iter6.gd 89 checks)
- [x] T2-05: M53 UI-UX (VERIF: theme_ux.gd/theme_service.gd + ui_manager/ui_layer en disco; tests UI reales test_bug128_hud_real.gd / test_bug125_bug126_fix.gd ejercitan framework M53; SELLO HONESTO)

## Bloque 3: M139 (3)
- [x] T3-01: L158 ASMR - flippear [x] (PROPUESTA FLIP [?]->[x] respaldada: feedback_director.gd + data/audio/feedback_recetas.json + test_feedback_m44.gd 11 checks; CAVEAT: nota L158 ("Falta el bus ASMR") debe reconciliarse o recrea autocontradiccion que bajo [x]->[?]; bus dedicado ASMR NO existe, usa capas SFX)
- [x] T3-02: L58/L63 teleport M66 (VERIF: m65_animal_ai.gd:165 anti-stuck existe, pero 0 teleport/waypoint -> [?] SOSTENIDO; NO flip)
- [x] T3-03: L71 curvas.json M93 (VERIF: curvas.json NO existe en repo, 0 scripts la cargan -> [?] SOSTENIDO; NO flip; L78/L79 simulacion economica en codigo es aparte y sigue [x])

## Bloque 4: M14+M107 (4)
- [x] T4-01: M14 L183 CAVEAT (VERIF: grep -c gamepad en inventory_layer.gd = 0 -> L183 [?] SOSTENIDO; CAVEAT: gamepad existe a nivel proyecto (msg 497) pero NO en capa inventario M14 -> discrepancia documentada, NO flip)
- [x] T4-02: M14 gate-2 runtime (VERIF: test_inventario.gd 64 + test_inventario_iter5.gd 71 + test_inventario_restore_robusto.gd 13 checks en disco; G8-02 2026-11-06 midio 68/0 + 70/0 EXIT 0 -> gate-2 VERDE; no re-ejecutado headless en este run por carga de proyecto)
- [x] T4-03: M107 backup fix (VERIF: scripts/backup/test_backup_m107.gd + scripts/test_backup_ps1.py (49 checks/0 fallos G3-02) + scripts/saving/test_backup_rotations.gd / test_backup_rotate_return.gd presentes -> backup funcional y fix verificado)
- [x] T4-04: M107 sello 15 candidate (RECHAZADO: M107 NO sellable. Sec M L204-208 (OAuth Google Drive) siguen [x] pero su texto dice "APLICADO: [ ]" (pendiente fundador) = 5 [x] FALSOS. Director debe revertir L204-208 [x]->[ ] antes de sello. M107 sigue AMARILLO)

**Total: 15. Prioridad: 1 > 2 > 3 > 4.**
