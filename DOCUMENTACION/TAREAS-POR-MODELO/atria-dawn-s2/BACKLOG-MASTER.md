**Modelo:** Atria-Dawn-Preview (Shanghai AI Laboratory) — **sesion 2**
**Plataforma:** Kilo Code
**Fecha:** 2026-09-20
**Creado por:** atria-dawn sesion 1 (coordinacion, Log 1091/1092)

# BACKLOG-MASTER — atria-dawn-s2 (auditoria y verificacion)

> **Sos la otra sesion de Atria-Dawn-Preview.** Tu especialidad medida en este repo
> **NO es implementar features** — es **auditar, verificar y parchar**:
>
> **Evidencia propia (Logs 1054, 1058, 1059, 1063, 1065, 1083, 1085, 1089, 1090):**
> - Encontraste **2 sobre-cierres reales** que los autores marcaron ✅ (BUG-061 M94,
>   BUG-062 M84) — auditoria con dientes
> - Resolviste **AMBOS** con causa raiz (M94: objetivos.json esquema divergente → 38/0;
>   M84: tipado Array → 15/0)
> - Drift scan de **167 filas** en una pasada (163 OK, 3 delta)
> - 57 locks 🔵 stale liberados (ronda 3)
> - Barrido historico completo (Log 1093): Deepseek V4 Flash fundador, 1039 logs,
>   56 variantes de firma
> - Auto-correccion honesta: detectaste que un "Log 47" citado NO existia
>
> **NO compitas con los otros modelos en implementacion.** Verificá su trabajo.

## Reglas de tu rol

1. **Verificador, no autor.** No implementes features nuevas (excepto parches puntuales
   de drift/bugs como BUG-061/062).
2. **Binario real siempre.** Godot 4.7.2, anti-falso-verde (leccion 28): exit code **Y**
   0 SCRIPT ERROR en stderr.
3. **No toques modulos 🔵** de otros agentes.
4. **Cada hallazgo se documenta** en `11-BUGS.md` (con firma) y en el log.
5. **Honestidad absoluta:** si no podes verificar algo, reporta "no verificable".

---

## PRIORIDAD 1 — Barrido de drift de `**Totales:**` (159 modulos auditables)

> Drift **endemico** (M09/M11/M12/M126/M128/M115/M149 esta semana). Metodo por modulo
> (~2 min): (1) cuenta marcas `^(?:\s*)- \[x\]` / `- \[?\]` / `- \[ \]` en
> `plan-actual/05-Checklist.md`, (2) compara con la linea `**Totales:**`,
> (3) **corrige solo la linea Totales, nunca las marcas**, (4) reporta en tu log.
>
> **Marca `[→]` en este backlog** la tarea que tomas; `[x]` al terminar.

### 1A. Modulos 🟡 Con dudas/Liberados (62) — drift mas probable

- [x] **T-DA001:** M09 Terreno-Y-Geografia (98/105, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA002:** M10 Generacion-Del-Mundo (90/106, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA003:** M11 Personaje-Del-Jugador (50/123, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA004:** M12 Camara (57/102, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA005:** M13 Herramientas (84/120, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA006:** M15 Recursos (99/222, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA007:** M16 Crafting (43/186, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA008:** M21 Dialogos (13/143, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA009:** M25 Ruinas (107/122, prio=Media) — verificar Totales vs marcas
- [x] **T-DA010:** M26 Templo-Subterraneo (62/129, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA011:** M27 Islas-Del-Mundo (99/192, prio=Media) — verificar Totales vs marcas
- [x] **T-DA012:** M30 Reloj-En-Tiempo-Real (107/120, prio=Media) — verificar Totales vs marcas
- [x] **T-DA013:** M31 Ciclo-Dia-Noche (115/169, prio=Media) — verificar Totales vs marcas
- [x] **T-DA014:** M34 Pesca (84/153, prio=Media) — verificar Totales vs marcas
- [x] **T-DA015:** M35 Mineria (60/142, prio=Media) — verificar Totales vs marcas
- [x] **T-DA016:** M38 Economia (158/164, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA017:** M39 Tiendas (127/181, prio=Media) — verificar Totales vs marcas
- [x] **T-DA018:** M40 Infraestructura (95/211, prio=Media) — verificar Totales vs marcas
- [x] **T-DA019:** M46 Arte-2D (0/110, prio=Media) — verificar Totales vs marcas
- [x] **T-DA020:** M49 Iluminacion (53/143, prio=Media) — verificar Totales vs marcas
- [x] **T-DA021:** M50 Vegetacion (29/142, prio=Media) — verificar Totales vs marcas
- [x] **T-DA022:** M51 Agua (35/166, prio=Media) — verificar Totales vs marcas
- [x] **T-DA023:** M52 Particulas-Y-VFX (137/148, prio=Media) — verificar Totales vs marcas
- [x] **T-DA024:** M56 Fotografia (21/137, prio=glm-5.3-flash) — verificar Totales vs marcas
- [x] **T-DA025:** M57 Interfaz-De-Control (91/119, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA026:** M58 Accesibilidad (131/183, prio=glm-5.3-flash) — verificar Totales vs marcas
- [x] **T-DA027:** M60 Datos-Y-Serializacion (189/196, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA028:** M61 Rendimiento (39/144, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA029:** M64 IA-De-NPC (100/117, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA030:** M66 Anti-Softlock (109/117, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA031:** M68 Transporte-Y-Navegacion (70/131, prio=Media) — verificar Totales vs marcas
- [x] **T-DA032:** M69 Fast-Travel (18/150, prio=Baja) — verificar Totales vs marcas
- [x] **T-DA033:** M71 Progresion (72/213, prio=Media) — verificar Totales vs marcas
- [x] **T-DA034:** M72 Sistema-De-Logros (1/185, prio=Media) — verificar Totales vs marcas
- [x] **T-DA035:** M73 Coleccionables (28/135, prio=Media) — verificar Totales vs marcas
- [x] **T-DA036:** M74 Eventos (95/285, prio=glm-5.3-flash) — verificar Totales vs marcas
- [x] **T-DA037:** M83 Licencias-De-Software (16/100, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA038:** M87 Localizacion (129/136, prio=Media) — verificar Totales vs marcas
- [x] **T-DA039:** M88 Fuentes-Tipograficas (10/177, prio=Baja) — verificar Totales vs marcas
- [x] **T-DA040:** M92 Tutorial (97/185, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA041:** M96 Plataformas (71/106, prio=Media) — verificar Totales vs marcas
- [x] **T-DA042:** M105 Telemetria-De-Gameplay (120/165, prio=Media) — verificar Totales vs marcas
- [x] **T-DA043:** M107 Backups (93/176, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA044:** M108 Pipeline-De-Assets (124/205, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA045:** M109 Herramientas-Internas (27/138, prio=Media) — verificar Totales vs marcas
- [x] **T-DA046:** M110 Debug-Menu (121/225, prio=Media) — verificar Totales vs marcas
- [x] **T-DA047:** M113 Pruebas-De-Stress (102/132, prio=Media) — verificar Totales vs marcas
- [x] **T-DA048:** M115 Hardware (68/104, prio=Media) — verificar Totales vs marcas
- [x] **T-DA049:** M117 Build-System (92/110, prio=Media) — verificar Totales vs marcas
- [x] **T-DA050:** M124 Contenido-Generado-Por-Usuarios (83/108, prio=Media) — verificar Totales vs marcas
- [x] **T-DA051:** M126 Marketing-Legal (59/101, prio=—) — verificar Totales vs marcas
- [x] **T-DA052:** M127 Copyright-Del-Juego (51/101, prio=Baja) — verificar Totales vs marcas
- [x] **T-DA053:** M128 Identidad-De-Marca (53/100, prio=Media) — verificar Totales vs marcas
- [x] **T-DA054:** M147 World-Building (65/134, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA055:** M148 Lore-Ambiental (23/117, prio=Media) — verificar Totales vs marcas
- [x] **T-DA056:** M151 Control-Final (10/151, prio=Media) — verificar Totales vs marcas
- [x] **T-DA057:** M155 Vestimenta-Y-Accesorios (84/108, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA058:** M156 Terrenos-Y-Movimiento (206/307, prio=glm-5.3-flash) — verificar Totales vs marcas
- [x] **T-DA059:** M159 Catalogo-De-Objetos (69/146, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA060:** M161 Diseno-Visual-De-NPCs (94/138, prio=Alta) — verificar Totales vs marcas
- [x] **T-DA061:** M162 Dialogos-Contextuales-De-NPCs (80/120, prio=glm-5.3-flash) — verificar Totales vs marcas
- [x] **T-DA062:** M164 Isla-De-Combate-Endgame (70/130, prio=Alta) — verificar Totales vs marcas

### 1B. Modulos ✅ Completados (36) — verificar que no tengan `[?]` (viola DoD)

- [x] **T-DC001:** M07 Arquitectura-General (105/105) — 0 `[?]` + codigo real + logs
- [x] **T-DC002:** M08 Mundo-Voxel (105/105) — 0 `[?]` + codigo real + logs
- [x] **T-DC003:** M14 Inventario (136/140) — ❗ **4 `[?]` con dueno externo → REVERTIDO ✅→🟡** (Log 1110, directriz usuario)
- [x] **T-DC004:** M29 Tiempo-Y-Calendario (190/195) — ❗ **3 `[ ]` + 2 `[?]` → REVERTIDO ✅→🟡** (Log 1110; mi QA Log 984 verifico codigo, no DoD)
- [x] **T-DC005:** M32 Clima (121/121) — 0 `[?]` + codigo real + logs
- [x] **T-DC006:** M36 Fauna (228/228) — 0 `[?]` + codigo real + logs
- [x] **T-DC007:** M65 Animales-IA (89/89) — 0 `[?]` + codigo real + logs
- [x] **T-DC008:** M78 Legal-Propiedad-Intelectual (157/157) — 0 `[?]` + codigo real + logs
- [x] **T-DC009:** M80 Legal-Privacidad (144/144) — 0 `[?]` + codigo real + logs
- [x] **T-DC010:** M81 Legal-Menores (137/137) — 0 `[?]` + codigo real + logs
- [x] **T-DC011:** M82 Clasificacion-Por-Edades (100/100) — 0 `[?]` + codigo real + logs
- [x] **T-DC012:** M84 Musica-Y-Audio-Legal (99/99) — 0 `[?]` + codigo real + logs
- [x] **T-DC013:** M85 Modelos-3D-Legal (100/100) — 0 `[?]` + codigo real + logs
- [x] **T-DC014:** M86 IA-Generativa (129/129) — 0 `[?]` + codigo real + logs
- [x] **T-DC015:** M93 Balance (134/134) — ❗ **3 over-marks Familia A (simulate_economy.gd NO existe) → REVERTIDO ✅→🟡 131/134** (Log 1116)
- [x] **T-DC016:** M94 Retencion-Sin-FOMO (135/135) — 0 `[?]` + codigo real + logs
- [x] **T-DC016:** M94 Retencion-Sin-FOMO (135/135) — 0 `[?]` + codigo real + logs
- [x] **T-DC017:** M101 QA-General (209/209) — 0 `[?]` + codigo real + logs

### 1D. Over-marks "KnownIssue no bloqueante" (directriz usuario 2026-09-20)

- [x] **T-OM01:** Escaneo de over-marks en los 33 ✅ — **145 items en 17 modulos**,
  clasificados con evidencia de codigo REAL (`game/`, 6008 archivos): Familia A (8:
  marcaron hecho sin codigo) vs Familia B (120: plan/checklist no corresponden).
  Reporte: `overmarks_clasificacion_2026-09-20.txt`. Log 1116.
- [x] **T-OM02:** **Familia A aplicada** — 8 marcas `[x]`->`[ ]` (M93 x3, M85, M36 x2,
  M65, M167); 5 modulos revertidos ✅->🟡; ✅ global **33->28**. BUG-070 registrado.
  Log 1116.
- [ ] **T-OM03:** **Familia B (120 items, 16 modulos)** — reevaluar `plan-actual/` +
  `05-Checklist.md` por modulo: paths Unity->Godot stale en 04-Codigo (renombres
  `behavior.gd`->`fauna_behavior.gd`, `balance.gd`->`balance_service.gd`,
  `isla_generador.gd`->`island_generator.gd`), items de spec mezclados con
  implementacion. **NO es descartar marcas; es arreglar el plan.**
- [ ] **T-OM04:** Re-auditar con `python scripts/verificar_checklist.py` tras OM02.
- [x] **T-DC018:** M102 Bug-Tracking (140/140) — 0 `[?]` + codigo real + logs
- [x] **T-DC019:** M111 Codigo-De-Calidad (209/209) — 0 `[?]` + codigo real + logs
- [x] **T-DC020:** M112 Testing-Automatico (208/208) — 0 `[?]` + codigo real + logs
- [x] **T-DC021:** M114 Playtest (186/186) — 0 `[?]` + codigo real + logs
- [x] **T-DC022:** M116 Instalador (192/192) — 0 `[?]` + codigo real + logs
- [x] **T-DC023:** M118 CI-CD (106/106) — 0 `[?]` + codigo real + logs
- [x] **T-DC024:** M119 Actualizaciones (118/118) — 0 `[?]` + codigo real + logs
- [x] **T-DC025:** M123 Modding (108/108) — 0 `[?]` + codigo real + logs
- [x] **T-DC026:** M133 Gestion-Del-Proyecto (127/127) — 0 `[?]` + codigo real + logs
- [x] **T-DC027:** M134 Presupuesto (100/100) — 0 `[?]` + codigo real + logs
- [x] **T-DC028:** M135 Riesgos-Del-Proyecto (134/134) — 0 `[?]` + codigo real + logs
- [x] **T-DC029:** M136 Roadmap (199/199) — 0 `[?]` + codigo real + logs
- [x] **T-DC030:** M145 Diseno-De-Experiencia (105/105) — 0 `[?]` + codigo real + logs
- [x] **T-DC031:** M146 Diseno-Emocional (100/100) — 0 `[?]` + codigo real + logs
- [x] **T-DC032:** M153 Objetivo-Final (120/130) — ❗ **10 `[ ]` KnownIssue-no-bloqueante → REVERTIDO ✅→🟡** (Log 1110; caso mas defendible, a decidir por usuario)
- [x] **T-DC033:** M154 Vision-Del-Agente (155/155) — 0 `[?]` + codigo real + logs
- [x] **T-DC034:** M165 Voxel-Tools-Guia (48/48) — 0 `[?]` + codigo real + logs
- [x] **T-DC035:** M167 Isla-Raiz (114/114) — 0 `[?]` + codigo real + logs
- [x] **T-DC036:** M168 Plantilla-De-Isla (0/104) — 0 `[?]` + codigo real + logs

### 1C. Modulos 🟢 Disponibles (61) — Totales sincronizado para futuros agentes

- [x] **T-DG001:** M01 Fundamentos-Del-Proyecto (0/152) — Totales vs marcas
- [x] **T-DG002:** M02 Vision-Y-Concepto (0/172) — Totales vs marcas
- [x] **T-DG003:** M03 Documentacion-Del-Proyecto (0/133) — Totales vs marcas
- [x] **T-DG004:** M04 Game-Engine (14/128) — Totales vs marcas
- [x] **T-DG005:** M05 Lenguaje-Y-Programacion (4/103) — Totales vs marcas
- [x] **T-DG006:** M06 Control-De-Versiones (0/100) — Totales vs marcas
- [x] **T-DG007:** M17 Construccion (11/175) — Totales vs marcas
- [x] **T-DG008:** M18 Casas (4/126) — Totales vs marcas
- [x] **T-DG009:** M20 Sistema-De-Amistad (50/148) — Totales vs marcas
- [x] **T-DG010:** M22 Historia-Principal (51/100) — Totales vs marcas
- [x] **T-DG011:** M23 Historias-Secundarias (24/104) — Totales vs marcas
- [x] **T-DG012:** M24 Templos-Y-Puzzles (31/128) — Totales vs marcas
- [x] **T-DG013:** M28 Viajes (50/130) — Totales vs marcas
- [x] **T-DG014:** M33 Agricultura (67/153) — Totales vs marcas
- [x] **T-DG015:** M37 Museos-Y-Colecciones (36/148) — Totales vs marcas
- [x] **T-DG016:** M41 Musica (61/110) — Totales vs marcas
- [x] **T-DG017:** M42 Sonido-Ambiental (63/100) — Totales vs marcas
- [x] **T-DG018:** M43 Efectos-De-Sonido (61/100) — Totales vs marcas
- [x] **T-DG019:** M44 ASMR-Y-Feedback (76/113) — Totales vs marcas
- [x] **T-DG020:** M45 Arte-3D (22/171) — Totales vs marcas
- [x] **T-DG021:** M47 Texturas-Y-Materiales (18/119) — Totales vs marcas
- [x] **T-DG022:** M48 Animacion (9/123) — Totales vs marcas
- [x] **T-DG023:** M53 UI-UX (131/158) — Totales vs marcas
- [x] **T-DG024:** M54 Mapa (34/177) — Totales vs marcas
- [x] **T-DG025:** M55 Diario-Del-Jugador (8/131) — Totales vs marcas
- [x] **T-DG026:** M59 Guardado (55/130) — Totales vs marcas
- [x] **T-DG027:** M62 Memoria (59/150) — Totales vs marcas — READ-ONLY: modulo en curso (azul), linea NO agregada; conteo 93/150 coincide con global
- [x] **T-DG028:** M63 Cargas-Y-Streaming (16/101) — Totales vs marcas
- [x] **T-DG029:** M67 Vehiculos (19/131) — Totales vs marcas
- [x] **T-DG030:** M70 Interacciones (77/198) — Totales vs marcas
- [x] **T-DG031:** M75 Postgame (17/130) — Totales vs marcas
- [x] **T-DG032:** M76 Multijugador (4/130) — Totales vs marcas
- [x] **T-DG033:** M77 Online-Y-Red (4/130) — Totales vs marcas
- [x] **T-DG034:** M79 Legal-Contratos (60/103) — Totales vs marcas
- [x] **T-DG035:** M89 Diseno-De-Menus (24/125) — Totales vs marcas
- [x] **T-DG036:** M90 Configuracion-Grafica (69/249) — Totales vs marcas
- [x] **T-DG037:** M91 Configuracion-De-Audio (92/239) — Totales vs marcas
- [x] **T-DG038:** M95 Monetizacion (19/113) — Totales vs marcas
- [x] **T-DG039:** M97 Steam-Store-Page (129/195) — Totales vs marcas
- [x] **T-DG040:** M98 Trailer (4/102) — Totales vs marcas
- [x] **T-DG041:** M99 Marketing (7/169) — Totales vs marcas
- [x] **T-DG042:** M100 Community-Management (146/222) — Totales vs marcas
- [x] **T-DG043:** M104 Analytics (49/117) — Totales vs marcas
- [x] **T-DG044:** M120 DLC-Y-Expansiones (163/222) — Totales vs marcas
- [x] **T-DG045:** M121 Soporte-Post-Lanzamiento (123/211) — Totales vs marcas
- [x] **T-DG046:** M125 Terminos-De-Servicio (75/105) — Totales vs marcas
- [x] **T-DG047:** M129 Merchandising (68/108) — Totales vs marcas
- [x] **T-DG048:** M130 Artbook (96/146) — Totales vs marcas
- [x] **T-DG049:** M132 Produccion-De-Equipo (63/105) — Totales vs marcas
- [x] **T-DG050:** M137 Prototipo (10/131) — Totales vs marcas
- [x] **T-DG051:** M138 Vertical-Slice (11/131) — Totales vs marcas
- [x] **T-DG052:** M139 Pre-Alpha (12/142) — Totales vs marcas
- [x] **T-DG053:** M140 Alpha (14/124) — Totales vs marcas
- [x] **T-DG054:** M141 Beta (15/151) — Totales vs marcas
- [x] **T-DG055:** M142 Release-Candidate (23/129) — Totales vs marcas
- [x] **T-DG056:** M143 Lanzamiento (18/111) — Totales vs marcas
- [x] **T-DG057:** M144 Despues-Del-Lanzamiento (4/105) — Totales vs marcas
- [x] **T-DG058:** M149 Nombres-Y-Nomenclatura (99/100) — Totales vs marcas
- [x] **T-DG059:** M152 Principios-Innegociables (115/202) — Totales vs marcas
- [x] **T-DG060:** M158 Herramientas-Y-Desbloqueo-De-Zonas (53/140) — Totales vs marcas
- [x] **T-DG061:** M163 Sistema-De-Encantamientos (23/124) — Totales vs marcas

---

## PRIORIDAD 2 — QA cruzado §21.8 (10 modulos ✅ sin sello)

> Verificador ≠ autor. Por cada uno: (1) `05-Checklist.md` sin `[?]` (DoD §21.6),
> (2) codigo existe y no es stub, (3) `plan-actual/` coincide con codigo, (4) logs y
> firmas del autor, (5) suite re-corrida con binario 4.7.2.

- [x] **T-Q01:** M32 Clima (tu Log 942 ya lo verifico — confirma sello)
- [x] **T-Q02:** M84 Musica-Y-Audio-Legal (**tú lo arreglaste, BUG-062 Log 1085** — el
  verificador debe ser otro; delega o marca como auto-verificado con caveat)
- [x] **T-Q03:** M94 Retencion-Sin-FOMO (**tú lo arreglaste, BUG-061 Log 1083** — idem)
- [x] **T-Q04:** M102 Bug-Tracking
- [x] **T-Q05:** M112 Testing-Automatico
- [x] **T-Q06:** M153 Objetivo-Final — QA ejecutado: revertido a 🟡 (Log 1110, 10 ítems [ ])
- [x] **T-Q07:** M154 Vision-Del-Agente
- [x] **T-Q08:** M167 Isla-Raiz — QA ejecutado: revertido a 🟡 (Log 1116, 1 ítem Familia A)
- [x] **T-Q09:** M78 Legal-Propiedad-Intelectual
- [x] **T-Q10:** M93 Balance — QA ejecutado: revertido a 🟡 (Log 1116, 3 ítems Familia A)

---

## PRIORIDAD 3 — Limpieza y sanidad del repositorio

- [ ] **T-L01:** **Mojibake:** correr `python scripts/fix_encoding.py --dry-run` y
  reportar alcance. **Exclusiones obligatorias** (NO tocar): `AGENTS.md`,
  `scripts/verify_final.py`, `scripts/fix_coordinacion.py`, `scripts/fix_emoji3.py`,
  `Logs/`. Si el dry-run es seguro, aplicar y verificar con
  `python scripts/diagnosticar_mojibake.py` (debe salir 0).
- [x] **T-L02:** **11-BUGS.md:** verificar que TODAS las entradas tengan Modelo,
  Plataforma, Fecha y (en Resueltas) Causa raiz. Tu Log 1089 dejo 0 sin Causa —
  confirmar que no se agregaron nuevas incompletas.
- [ ] **T-L03:** **Logs huerfanos:** buscar logs citados en checklists/docs que NO
  existan en `Logs/` (como el "Log 47" que detectaste). Reportar todos.
- [x] **T-L04:** **Backlogs por modelo:** verificar que cada `TAREAS-POR-MODELO/*/`
  tenga BACKLOG-MASTER y que sus tareas existan en los checklists (0 inventadas).
- [ ] **T-L05:** **GUIA-GODOT/06-registro-errores.md:** agregar cualquier error nuevo
  encontrado durante tus verificaciones (mensaje exacto + causa + solucion + fecha).
- [ ] **T-L06:** **`Logs/_t39_test_*.txt`** (3 archivos sueltos en Logs/): pertenecen a
  `scripts-prueba/` de M39, no a Logs/. Moverlos a su sitio correcto.
- [ ] **T-L07:** **CHECKLIST-GLOBAL:** 131 marcas mojibake pre-existentes (emojis
  doble-codificados). Plan de reparacion incremental (fila por fila, sin pisar Notas).
- [x] **T-L08:** ** locks 🔵 colgados:** modulos 🔵 sin actividad >24h (§21.4.7).
  Reportar; liberarlos si confirmas que el agente no esta activo.
- [ ] **T-L09:** **`game/isla-ancestral/scripts/debug/test_m110_iter_atria.gd`** y
  `test_player_m11.gd` estan **untracked** (git). Verificar si deben commitearse o son
  temporales (M110 bloqueado — el tuyo probablemente temporal).
- [ ] **T-L10:** **Auditoria anti-sobre-cierre de los ✅**: samplear 5 modulos ✅ al azar
  y verificar que el codigo respalda los `[x]`. Si encuentras falso, abrir bug.

---

## Tareas adicionales (asignadas por atria s1, 2026-09-20)

- [x] **T-L11:** **Limpiar la frase falsa ` ` Verificado por Hy3 ` ` de la columna
  Notas de CHECKLIST-GLOBAL.md** (~42 modulos). Es una **misatribucion**: cita los logs
  866/867 de **agnes**, no de hy3, e indica una verificacion §21.8 que nunca ocurrio.
  **Alcance estricto:** solo la frase de Notas. **No tocar** Estado, Progreso, ni ninguna
  marca [x]/[?] — los conteos estan **verificados como exactos** (atría s1 conto 12
  modulos uno por uno). Para los modulos que SI son ✅ y no tienen sello real, dejar la
  fila en ✅ pero **quitar la atribucion falsa** (el sello §21.8 real vive en
  CHECKLIST-QA-SEALS.md). Ver Log 1113-s1 para el detalle.

## Recordatorios del protocolo

- **Reserva log:** `python scripts/reservar_log.py --reservar --agente atria-dawn-preview --modulo <X>`
  (identidad: **atria-dawn-preview**; sesion 2, pero la firma es el modelo)
- **Binario Godot 4.7.2:** `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
  `--headless --path game/isla-ancestral --quit --script res://...`
- **Anti-falso-verde (leccion 28):** exit code **Y** 0 SCRIPT ERROR en stderr
- **Push a git: NEGATIVO** (instruccion del usuario)
- **Codificacion UTF-8 obligatoria** (sin BOM)
- **Honestidad:** un `[?]` con dueno vale mas que un `[x]` falso (DoD §21.6)

---

## Logs

- [x] Log creado: **1098** — drift de Totales lote 1 (T-DA001 a T-DA010, bloque 1A).
- [x] Log creado: **1103** — drift lote 2 (renumerado desde **1097**, colision con hy3 QA-cruzado).
- [x] Log creado: **1099** — drift lote 3.
- [x] Log creado: **1104** — drift lote 4 (renumerado desde **1100**, colision con hy3 M25).
- [x] Log creado: **1102** — drift lote 5.
- [x] Log creado: **1107** — drift lote 6 + cierre bloque 1A (renumerado desde **1103**,
  colision residual creada por la propia renumeracion de s1: mi lote-2 fue renombrado
  a 1103 sin saber que yo ya habia tomado 1103 para el lote 6).
- [x] Log creado: **1105** — bloque 1B completo (36 modulos ✅) + auditoria DoD.
- [x] Log creado: **1106** — bloque 1C completo (61 modulos 🟢) + CIERRE PRIORIDAD 1.
- [x] Log creado: **1108** — colision 1103 residual resuelta + sync de numeracion.
- [x] Log creado: **1110** — escaneo DoD §21.6 + 3 reversiones (M14/M29/M153, directriz
  usuario "si no esta terminado por alguna razon se revierte"). ✅ 36→33.
- [x] Log creado: **1116** — over-marks Familia A: 8 marcas `[x]`→`[ ]` (codigo ausente
  verificado en `game/`), 5 modulos revertidos ✅→🟡 (M93, M85, M36, M65, M167),
  ✅ 33→28. BUG-070 registrado (Familia B, 120 items, abierta).
  > **Aviso (2026-09-20, atria s1):** tus lotes 1, 2 y 4 colisionaron con logs de mimo/hy3 — el
  > protocolo v3 no es a prueba de lecturas simultaneas. **Renumera siempre con
  > python scripts/reservar_log.py --reservar (consume el numero del pool) en vez de
  > tomarlo a mano.** Estado actual del pool: **sin conflictos**.
  >
  > **Aviso (2026-09-20, atria s2):** confirmado — la renumeracion de s1 dejo una
  > colision 1103 doble (lote 2 + lote 6). Reservé **1107** por la via correcta
  > (reservar_log.py) y renombre el lote 6. Serie drift final de s2: **lotes 1-6 =
  > logs 1098 / 1103 / 1099 / 1104 / 1102 / 1107**, mas 1105 (1B) y 1106 (1C).
  > **Leccion:** ejecutar `reservar_log.py --estado` despues de CADA log, no solo al
  > cerrar el lote, cuando hay sesiones paralelas activas.

- [x] Log creado: **1124** — QA cruzado §21.8 con **binario Godot real**: suites
  headless M07 (6/0 PASS), M101 (12/0), M119 (15/0), todas EXIT 0 + 0 SCRIPT
  ERROR; re-grounding M133-M136/M145/M146. **3 sellos nuevos** (M101, M145,
  M146). T-Q01..T-Q10 cerradas. **Auto-corrección:** apliqué sello a 6 módulos
  que ya tenían sello legítimo (cruce solo contra SEALS, no contra Notas de
  CHECKLIST-GLOBAL) — revertidos inmediatamente; lección documentada en el log.

## Meta

179 tareas totales (159 drift + 10 QA + 10 limpieza). Trabajá en lotes de 10;
cada lote = 1 log + sync de registros.
---

## IMPORTANTE: Cobertura que le debes al coordinador (s1) (Atria-Dawn-Preview)

> Directiva del usuario (2026-09-20): los modelos cubren las debilidades del coordinador.
> Registro completo: `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` **seccion 21.12**.

### ⚠️ LO PRIMERO: sos el MISMO modelo que el coordinador

El coordinador (s1) es **Atria-Dawn-Preview, igual que vos**. Sus 6 defectos (M-01 a M-06)
**son los tuyos**. Si a el no le sale algo, **a vos tampoco**. El usuario lo dejo claro:
no te asignes tareas que toquen nuestras debilidades compartidas esperando que las hagas
mejor — **delegalas hacia afuera**:

| Debilidad compartida | A quien delegar |
|---|---|
| M-03 (destruir CRLF) | **DeepSeek** (P-19, el guard) |
| M-05 (ruido de boot en conteos) | **agnes-3-flash** (ella cuenta, nosotros no) |
| M-06 (regex estrecho) | **DeepSeek** |
| M-02 (QA en suite muerta) | **hy3** |

### Lo que SI cubris (M-01, con salvaguardas)

El coordinador a veces da por buena una entrega sin verificacion empirica. Tu cobertura
(P-17, cola de verificacion) **solo vale si aplicas las salvaguardas** que compensan
nuestra debilidad compartida:

1. **Binario Godot real**, nunca checklist leido.
2. **NO sellar desde una sola fuente.** Tu propio cruce sobre `CHECKLIST-QA-SEALS.md`
   vendio 6 modulos que ya tenian sello legitimo (M07, M119, M133-M136) — lo detectaste
   inspectando las Notas y revertiste. **Cruzá siempre las Notas de la fila global.**
3. **No verifiques tu propio trabajo.** P-13 lo implementa DeepSeek, lo verificas vos.

**Regla:** si una verificacion requiere conteo de suites Godot o edicion de archivos
CRLF, **delega** (agnes / DeepSeek). Vos haces la auditoria de documentacion y la
verificacion cruzada entre fuentes.

## P-17 — Ejecución (2026-09-20 07:55, Log 1131)

- [x] **P-17.1** Verificar P-13 (exit 3 + job CI) — 3 casos inyectados por
  `--checklist` (inexistente / 0 bytes / sin tabla) → **exit 3** los tres;
  control real → **exit 1 (85 alertas)**. No colapsan. Job CI en
  `quality.yml` traduce 3 → fail, 1 → warning. **FUNCIONA.**
- [x] **P-17.2** Merge sección 9 de `11-BUGS.md` — header duplicado unificado,
  2 filas huérfanas reubicadas al final de la tabla.
- [x] **P-17.3** Documentar trampa de los 6 sellos → **T-101** en
  `GUIA-GODOT/06-registro-errores.md` (con regla «no verifiques tu propio trabajo»).
- [→] **P-17.4** Seguimiento 6 bugs sin firma (BUG-068/069/071 DeepSeek,
  BUG-058/072 hy3, BUG-043) — **siguen sin firma**; reportado, dueños no
  respondieron aún. No las firmo yo (trabajo ajeno).
- [x] **P-17.5** Re-aplicar 3 sellos perdidos por BUG-075 (M101, M145, M146)
  cruzando AMBAS fuentes esta vez.
- [x] **P-17.6** Gate de detección en `scripts/generar_checklist_global.py`
  (parte del fix BUG-075 que me corresponde — DeepSeek cubrió solo el parser).
  Implementado + probado (vacío→3, sin tabla→3, inexistente→0, control→0).
  **Verificación final delegada a otro agente** (regla T-101).

## P-23 — Cierre de sesión (2026-09-20 08:25, Log 1135, commit 39fb8af)

- [x] **P-23.1** Notificación a dueños de bugs sin firma en ESTADO-PARALELO,
  con línea, dueño, módulo y **plazo 2026-09-21**.
- [x] **P-23.2** BUG-043 firmado — era mío (Log 945), el único de los 6 que
  podía firmar. Contador 6→5.
- [x] **P-23.3** Commit `39fb8af` con **solo trabajo propio** (36 archivos).
  Protegidos: CHECKLIST-GLOBAL.md (EOL), 11-BUGS.md, GUIA-GODOT/06,
  ESTADO-PARALELO.md (todos con trabajo ajeno sin commitear mezclado).
- [x] **P-23.4** No se ejecutó `generar_checklist_global.py` en modo
  escritura (pisaría M93/M94 de DeepSeek) — solo `--dry-run`.

**Sesión s2 cerrada.** Resumen completo en Log 1135.

---

## Sesión s3 (2026-09-25) — Soporte al merge final

- [x] **P-30.1** Clasificación de los 224 archivos M por autor: A=182,
      B=29, C=13 (6%). Reporte con evidencia por archivo.
- [x] **P-30.2** Verificación extra: diff sin commitear de los 4
      compartidos. 11-BUGS.md → C (multi-autor real); GUIA-GODOT/06 → A
      (solo mi T-101); CHECKLIST-GLOBAL.md → C (EOL); pool sano.
- [x] **P-30.3** QA documental §21.8 de M07/M133/M134/M135/M136: todos
      pasan, PERO ya tenían sello legítimo de Hy3. Regla T-101 aplicada —
      no se agregaron sellos redundantes.
- [x] Log creado: **1152** — Soporte-Merge-QA.

### P-40 — Cierra la discrepancia de M07 (asignada por el coordinador)

- [x] **P-40.1** Verificar `git log --all` de thread_pool/voxel_world/
      game_state: **nunca existieron** (solo skills de terceros). Plan
      aspiracional documentado como código.
- [x] **P-40.2** Corregir `04-Codigo.md` de M07: 3 rutas reubicadas a
      sección "Scripts previstos (NO implementados)" con advertencia.
- [x] **P-40.3** Notificar a mimo en ESTADO-PARALELO.md (su sello Log
      1148 puede ser over-mark; M07 → 🟡 si no confirma).
- [x] **P-40.4** Corregir `qa_documental.txt`: M07 → NO limpio, los
      otros 4 limpios.
- [x] **P-40.5** Trampa **T-102** en GUIA-GODOT/06: "el detalle manda".
- [x] Log creado: **1155** — P-40-M07-drift-T102.
- [ ] **P-40.6** Esperar respuesta/confirmación de mimo sobre su sello
      de M07. Sin commitear nada de M07 (visto bueno del coordinador).
      → **CANCELADO por el coordinador:** M07 se queda ✅, el sello de
      mimo (Log 1148) es válido, mi corrección del 04-Codigo ya resolvió
      la ambigüedad. No baja a 🟡.

### P-44 — Merge de modelos inactivos huérfanos (asignada por el coordinador)

- [x] **P-44.1** Driver con estado live + verificaciones (EOL, hunks
      ajenos, índice vacío, `git show --stat` por commit).
- [x] **P-44.2** 7 commits, 56 archivos: glm 20+3, swe 13, nemotron 11,
      ox-alpha 4, kimi 2, step 3. Sin tocar activos ni compartidos.
- [x] **P-44.3** 1 excluido por hunks mezclados:
      `38-Economia/plan-actual/05-Checklist.md` (base glm + mi auditoría
      Log 1048) → bucket C del coordinador.
- [x] **P-44.4** Verificación post-commit: 0 protegidos commiteados,
      165 M restantes, sin push.
- [x] Log creado: **1158** — P-44-Merge-Huerfanos.

### P-46 — Clasificación y merge de untracked (asignada por el coordinador)

- [x] **P-46.1** Clasificador de untracked en 3 rondas: firma
      `**Modelo:**`/`**Origen:**` de cualquier .md (no solo plan-actual),
      companions .uid heredan, `re.MULTILINE` necesario para `$`.
- [x] **P-46.2** Hallazgo: FAMILIA-B-REPLANIFICACION.md usa `**Origen:**
      atria-dawn` → son míos, NO trabajo de glm/step (mala atribución
      evitada).
- [x] **P-46.3** 2 commits, 8 archivos: glm 3 (Log 1017 + tutorial M92),
      kimi 5 (backlog + security_environments.json M106). Verificados.
- [x] **P-46.4** Categorías aparte: scratch 118, artefactos reports/ 70,
      míos 86, bucket C 58.
- [x] Log creado: **1162** — P-46-Untracked.

### Acumulado de la sesión s3

- P-40 (M07 drift doc↔código) + T-102 — Log 1155
- P-44 (merge M de inactivos, 56 archivos / 7 commits) — Log 1158
- P-46 (merge untracked de inactivos, 8 archivos / 2 commits) — Log 1162
- **Total: 64 archivos commiteados en 9 commits, todos verificados por
  modelo. Sin push en ningún momento.**

### Cierre de sesión s3 (2026-09-29)

- [x] **Trampa T-103** en GUIA-GODOT/06: atribuir por header atribuye al
      último que tocó, no al autor de los hunks sin commitear (lo que
      DeepSeek generalizó como trampa 110). Caso real P-44/P-45/P-48.
- **SESIÓN LIBRE** — el coordinador no tiene más tareas. Pendientes
  opcionales si me vuelve a llamar: clasificar los 5 AMBIGUO, decidir los
  70 artefactos de `reports/report_1..7/`.


---

## Guia de comunicacion (Modo Canal) - 2026-10-03

**El detalle va a tu carpeta de mensajes; el chat solo avisa.**

Cuando termines (o abortes) un item, escribis el informe completo en `Mensajes entre modelos/atria-dawn-s2/` (archivo nuevo numerado, con firma y Responde a) y, por el chat, **una sola linea**:

> termine `[item]`, informe en mi carpeta

No repitas el contenido del informe por el chat: ya esta escrito, el director lo lee de tu carpeta. Si abortaste: `aborte [item]: [motivo de una linea]. informe en mi carpeta`. Si tenes una pregunta que bloquea: escribi el archivo con la pregunta y una linea en el chat: `pregunta en mi carpeta: [la pregunta]`.

Guia completa: `Mensajes entre modelos/GUIA-COMUNICACION.md` (lectura obligatoria).

## Sesion 2026-10-07/08 — frentes del director (canal atria-dawn-s2)

- [x] Log creado: **1414** — huella §4.3 retroactiva de commits fantasma 7a8d24c/44c2aa8.
- [x] Log creado: **1416** — S-01 M25 auditoria §21.8 veredicto negativo (deuda implementacion).
- [x] Log creado: **1418** — BUG-095 doble firma + huella rebase DeepSeek M24 iter.4.
- [x] Log creado: **1428** — volumen + 17 alertas (3 violaciones ✅ + 14 🟢).
- [x] Log creado: **1432** — 3 violaciones ✅ auditadas (M150 falso / M153 real / M44 real con stubs `pass`).
- [x] Log creado: **1435** — 12 inconsistencias 🟢 auditadas (M121 y M97 con deuda real).
- [x] Log creado: **1439** — push documental autorizado + rebase contra DeepSeek M24 iter.4/5.
- [x] Log creado: **1446** — **frente C-consolida cerrado**: 3 drifts corregidos (M24 70→100/128, M39 180→181/181, M70 155→77/198) + re-verificacion independiente de la suite de M39 de agnes (8/0 EXIT 0). Verificador 15→12 alertas. Commit `00ef41a` (push pendiente de autorizacion, msg 125).
- [x] **Frente BUG-080 + M65 (89/90) — investigado y concluido (msg 126)**: BUG-080 resuelto por agnes (P-38, Log 1154) cerro 3 [?], NO el [ ] restante. El [ ] es un KnownIssue no bloqueante con dueno M08 (NavigationServer3D sobre voxels). M08 esta ✅ 105/105 sin NavigationServer3D; en todo el repo solo hay NavigationAgent3D en npc_agent.gd (M64) sin NavigationRegion sobre VoxelTerrain. M65 GLOBAL 89/90 = plan 89/90, **sin drift**. Flip a ✅ queda a decision del director (aceptar KnownIssue externo o esperar M08).
- [x] **M90 — pasado formalmente al director (msg 127)**: 69/249 consistente (sin drift), pero 180 [ ] de implementacion real con ~0 codigo (solo `scripts/core/game_settings.gd` con fullscreen + resolution_index). No es ✅ falso ni drift: es trabajo genuinamente sin hacer. Decision sobre asignacion/reescala queda con el director.
- [x] **Msg 128 — M112: el ✅ 208/208 era FALSO** (punto 3 del msg 125 respondido): BUG-120 reportado por el director (msg 57 a mimo) y resuelto por mimo (Log 1451, msg 58) — `run_tests.gd` reportaba EXIT 0 con **0 tests** (falso-verde total, severidad Alta, encubrio 26 suites). Plan real = 220 [x] / 0 [ ] / 5 [?] = 225; la seccion T-M112 de mimo (L296) pide sumarla aparte del conteo historico 208. No toque el estado (no flips). Recomende bajar M112 a 🟡 220/225 con cita del Log 1451.

### Leccion repetida — commit contaminado (2026-10-08 00:10)

Mi commit `97ca63b` se llevo **12 archivos ajenos de mimo** porque su "staging quirurgico" vive en el **index compartido** y yo NO verifique `git diff --cached --name-only` antes de commitear. Deshecho con `git reset --soft HEAD~1` + `git restore --staged -- <12 ajenos>`; working tree de mimo intacto (8 modified + 6 untracked); re-commiteado limpio como `03821ce` (2 archivos).

**REGLA (infringida 2 veces esta jornada): `git diff --cached --name-only` es OBLIGATORIO y debe ir en una LLAMADA SEPARADA, ANTES de `git commit`. Nunca encadenar `git add` + diff + commit en un mismo bloque de comandos: el commit se ejecuta igual aunque el diff muestre archivos ajenos. Nunca asumir que el index solo tiene lo que uno acaba de hacer `git add`.** Incidentes: `e97ec9e` (6 archivos ajenos M163), `97ca63b` (12 ajenos mimo) y `749228a` (15 ajenos mimo + testing.yml). Los tres deshechos con `git reset --soft HEAD~1` + `git restore --staged -- <ajenos>` sin perder trabajo ajeno.

## M17-Construccion — volumen DoD (reclamado 2026-10-08 02:39, msg 130 del director)

- [x] **Reclamo registrado** en los 3 registros (plan-actual Reserva actual, ESTADO-PARALELO, CHECKLIST-GLOBAL fila M17). NOTA: mis 3 ediciones sin commitear fueron **absorbidas por commits de otras sesiones** (`b7bcaa4`, `394a3a5`, `0f252e6`) por el index compartido; verificadas con `git show`, sin perdida.
- [x] **3 suites ejecutadas, Godot 4.7.2 headless**: base 131/0, iter2 99/0, iter3 138/0 = **368 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR**.
- [x] **Sustancia verificada**: 13 scripts reales (~2.700 lineas) + 33 recetas `.tres` en `data/construccion/piezas/`. NO es patron M25.
- [x] **Spot-check por verbo**: LOD 40m, pooling, `obra_activa`/`navmesh_delta` (M64), serializacion (M58/M60), stress 251 piezas, permisos narrativa/agua, limite suave, capa raycast, M154 — todos respaldados en codigo.
- [x] **Hallazgo: 1 [x] FALSO** de 59 — "La demolicion de piezas funcionales (camas, almacenamiento) libera su contenido": `demolir_pieza` (build_manager.gd:355-398) solo devuelve materiales; no existe `build_interaction.gd` ni tests del claim. Reportado al director (msg 133); decision sobre el [x] es suya.
- [x] **Veredicto (msg 133)**: modulo sano, 58/59 respaldados, 116 [ ] legitimos. Sin flips (no autorizados).
- [x] **Respuesta del director (msg 135)**: veredicto ACEPTADO; flip del `[x]` falso a `[?]` con dueño M18 aplicado por el director (Log 1465); M17 queda 58/116/1 = 175. **Sello §21.8 AUTORIZADO** (sobre la parte implementada, `[?]` de M18 EXCLUIDO del alcance).
- [x] **Sello §21.8 registrado** en `CHECKLIST-QA-SEALS.md` (fila M17, tabla Notas QA) — cita 368 checks + 3 suites + el `[x]` falso documentado + exclusión M18. NO flipeado a ✅ (regla: flips = solo director).
- [x] **Totales del plan M17 corregidos** (L248): 59/116/0 → 58/116/1, consistente con el flip del director.
- [x] **Log 1468 creado** — volumen DoD M17 + sello §21.8 registrado (reservado del pool global, consumido).

## Frente: 86 timestamps stale del GLOBAL (msg 135 §3, 2026-10-08)

- [x] Entregable L-06 de s3 leído (86 stale / 22 sin log / 60 consistentes).
- [x] Script `extraer_stales.py`: metadata de los 86 logs citados (titulo + resumen + MID en cuerpo). 86/86 encontrados, 0 faltantes.
- [x] Clasificación a/b/c de los 86: **(a)=30 / (b)=56 / (c)=0**. Criterio operacional definido en el entregable.
- [x] Reporte `stales-clasificacion-a-b-c.md` escrito — desglose ANTES de tocar el GLOBAL (lo pidió el director). **Esperando OK del director para aplicar (a)/(c)**.
- [x] **OK del director recibido (msg 137)**: criterio aprobado tal cual; los 3 casos límite (M64/M85/M156) se quedan en (a).
- [x] **30 (a) APLICADOS al GLOBAL** (commit `4701b02`, 2026-10-08): 29 actualizados + M156 saltado (su fecha 2026-10-08 ya es posterior al log citado, no se retrocede). Solo columna Última actividad; LF preservado; sin push.

## M17 — liberado por el director (msg 137, 2026-10-08)

- [x] **M17 liberado**: flip 🟡 aplicado por el director en el GLOBAL (Agente actual = —). No lo retengo más.
- [x] Reserva actual del plan-actual actualizada a liberado; backlog sincronizado.
- [ ] **Cuando M18 cierre el `[?]`** (build_interaction.gd / demolición libera contenido): M17 puede re-auditar y pasar a ✅. Fuera de mi alcance por ahora.

## BUG-120 — falso-verde de run_tests.gd (M112) (msg 137 §4, asignado a s2)

- [x] **run_tests.gd localizado y leído**: `game/isla-ancestral/tests/run_tests.gd` (309 líneas, v2c de mimo, Log 1451). El BUG-120 original (v1) ya resuelto por mimo.
- [x] **Auditar la v2c actual**: guardas intactas (tests_total>0, suites_ok, rc, timeout). Causa real = (iv) formatos no reconocidos. Sonda 12/12.
- [x] **Veredicto honesto**: arreglado con 3 patrones nuevos. Fix autorizado (msg 139) y aplicado.
- [x] **Fix AUTORIZADO (msg 139 del director)**: patrón 4 `passed=N failed=M` + detección `FALLO:` sin corchetes + patrón `N fallo(s)` en `_analizar_salida()`.
- [x] **Sonda unitaria en rojo y verde: 12/12 OK, 0 fallos, EXIT 0** (M111 verde/rojo, inventory_unificado verde/rojo, rc != 0, regresiones `[FIN]` y `OK/fallos`).
- [x] **Runner real con fix: M111 checks=0 → 62; tests totales 718 → 780**; los 3 fallos del runner son los `[?]` conocidos de M112.
- [x] **Fix ya en HEAD** (merge `41765e6` del director, absorbido con mis comentarios exactos).
- [x] **Log 1491 creado** — restricción del pool LEVANTADA por el director (msg 143); número 1491 consumido por mí, cabeza 1492. Commit `0deb44f`.
- [x] **Segundo falso-verde encontrado y fixeado (commit `dc057fa`)**: `test_inventory_unificado.gd` — `_run()` no esperaba a `_test_toggle()`/`_test_overlay()` (tienen `await`), `quit()` mataba las coroutines → **6 de 8 checks nunca se ejecutaban**. Verificado por el director en runtime (msg 143): 8 checks, 0 fallos.
- [x] **"familia B" aclarada (msg 143)**: los 37 ítems Familia B del barrido BUG-070 (Hy3 Log 1472) — verbo Diseñar/Definir + artefacto documental. Verificación completada: ver sección siguiente.
- Restricciones: nada de `quality.yml` (BUG-091), `interaction_manager.gd` (kimi), `service_registry.gd`/`bootstrap.gd` (BUG-097). **Pool de logs: restricción levantada (msg 143).**

## Cola Familia B — barrido BUG-070 (msg 143 orden 3, completado)

- [x] **52 ítems con `citado-inexistente`** en `scripts-prueba-temp/fama_full.txt` verificados uno a uno contra planes-actuales + repo (git ls-files + disco).
- [x] **43 artefactos citados: ninguno existe** (tracked ni en disco) — pero 41 ítems sostienen por artefacto documental.
- [x] **8 Familia A pendientes para el flip del director** (msg 144): M112 L74/76/77/78/154, M156 L258, M42 L120, M41 L123.
- [x] **3 ya revertidos por el director** (2026-10-08): M73 L15/L203, M108 L115.
- [x] **1 falso negativo del script de Hy3**: M163 L113 cita `enchant_system.gd:78` → el real es `enchantment_system.gd:78` con el guard `if is_enchanted(tool_id): return false`. `[x]` verdadero.
- [x] **Discrepancia de conteo reportada**: director dijo 37 B, obtuve 41 sostienen (52 − 8 A − 3 revertidos).
- [x] **Runner completo: flake documentado** — 2 abortos del entorno en fase SceneTree (no GdUnit), 675 checks parciales en 16 suites OK. 767/788 sin confirmar.

## Push pendiente de confirmacion (msgs 131-132)

- [ ] **Fundador autorizo push (msg 131)** pero la situacion local cambio: **23 commits ahead / 0 behind**, de los cuales 14 son de otras sesiones (mimo, director, agnes, flota) encima de mis 9. Mi trabajo no commiteado fue absorbido por commits ajenos. Pedi confirmacion sobre si empujar los 23 tal cual (incluye scripts temporales del director en la raiz, `cdfba18`) — msg 132. Esperando respuesta.



## QA sec21.8 de M105 (msg 147 orden 1, completada) — SELLO REGISTRADO

- [x] **Runtime medido**: 4 suites, **64 checks, 0 fallos, 4x EXIT 0** (16/10/11/27). Coincide con DeepSeek iter 7-bis.
- [x] **Conteo triple coincidencia**: 120 [x] / 0 [ ] / 45 [?] = 165 (real = GLOBAL = verificar_checklist.py).
- [x] **Artefactos verificados**: telemetry_director.gd (autoload L29), 4 suites, stub huerfano declarado, quality.yml L403-406.
- [x] **SELLO REGISTRADO por el director** en CHECKLIST-GLOBAL fila M105 (Log 1502). M105 queda 🟡 deliberado (45 [?] con deps reales).
- [x] **H-1/H-2 fijados** (autorizado msg 149, commit 7aad24c): 04-Codigo 59->64 checks / iter7 22->27; autoload linea 65->29.
- [x] **H-3 (23 [?] sin justificacion inline)**: opcional segun el director, no hecho.

## Re-auditoria H2-estricta de los 52 (msg 147 orden 2, completada)

- [x] **Criterio H2-estricta** (formalizado por el director msg 147): un [x] Familia B sostiene solo si el doc citado existe Y no se autocontradice.
- [x] **52 items auditados uno a uno** contra planes-actuales + repo (msgs 150/151/152).
- [x] **Balance final**: 22 sostienen / 12 no-sostienen (para flip del director) / 6 dudosos / 12 ya revertidos.
- [x] **Correccion de mi conteo del msg 144**: "41 sostienen" era incorrecto (conte M154 L109 ya revertido) → 22 reales.
- [x] **2 over-marks nuevos colaterales**: M112 L166 y M84 L117 ([x] que admiten no-hecho en su propio texto).

## BUG-119 diagnostico race terreno M163 (msg 155, completado)

- [x] **Race reproducido 3/3, deterministico** (timing de arranque, no de semilla).
- [x] **Cadena aislada**: bootstrap.gd:168 (change_scene diferido) -> main_island.gd:24 _crear_shaman -> L414 get_height sincronico -> terrain_locator.gd:46-47 return -1 (_terrain null) -> main_island.gd:417-418 fallback y=35.
- [x] **Mitigacion ACTIVA ya aplicada**: shaman_npc.gd L19-60 (retry _process, timeout 8000ms, autorizado msg 74). Spawn y=35 -> reposicionado y=17; get_height(2320,2300)=16 -> h+1=17.
- [x] **ACEPTADO por el director (msg 157)**: "12 encargos correctos consecutivos". Veredicto MITIGADO; flash y=35 delegado a M09/M167 (no tocarlo, restriccion).

## QA sec21.8 de M87 Localizacion (msg 157, completada) — SELLO VALIDO

- [x] **Runtime medido**: test_validador_po_m87.gd **84 checks, 0 fallos, exit 0** (independiente; DeepSeek reporto 82/0 — los 2 extra son la asercion de regresion del fix iter8).
- [x] **Conteo**: 131 [x] / 0 [ ] / 5 [?] = 136 (coincide GLOBAL). Los 5 [?] son deudas de integracion con dueno nombrado y justificacion inline (M53/M58, usuario, M14-M39, M29/M30).
- [x] **Artefactos verificados**: auditor_claves.gd, test_validador_po_m87.gd, localization_manager.gd, validador_po.gd, retraductor_ui.gd + 7 suites localizacion + 2 integracion.
- [x] **Barrido H2-estricta**: 0 autocontradicciones activas (menciones "pendiente" son notas de iter.1 historicamente corregidas en 04-Codigo L383).
- [x] **Hallazgo menor**: 04-Codigo L380 documenta 82 checks; medicion real 84 (post-fix-iter8 no reflejado).
- [x] **Informe entregado (msg 158)**: director debe registrar el sello en fila M87 de GLOBAL.

## QA sec21.8 de M102 Bug-Tracking (msg 157 frente opcional, completada) — RECONFIRMA

- [x] **Hallazgo clave**: M102 YA tiene QA sec21.8 valida (Log 767, Hy3/Kilo Code, 2026-09-07): "M102 aprobado en QA cruzado. Mantiene estado Completado." Hy3 != ox-alpha (dueno) -> independencia cumplida.
- [x] **Conteo**: 140 [x] / 0 [ ] / 0 [?] = 140 (coincide GLOBAL).
- [x] **Artefactos verificados**: los 5 citados existen (.github/ISSUE_TEMPLATE/bug_report.md, create_labels.sh, workflows/bug_metrics.yml, docs/bug_tracking_guide.md, docs/bug_metrics.md).
- [x] **Barrido H2-estricta**: 0 autocontradicciones (5 hits "futuro" son extensiones opcionales explicitas; modulo complejidad 1, sin runtime GDScript).
- [x] **Observacion menor**: GLOBAL atribuye a ox-alpha (Cline) pero plan-actual firmado SWE-1.6/Devin — inconsistencia documental solo.
- [x] **Informe entregado (msg 159)**: no se necesita nuevo sello; reconfirmacion sin accion.

## Auditoria de volumen M46 Arte-2D y M77 Online-Y-Red (msg 160, completada)

- [x] **M46 (0/110)**: NO es Familia A (0 [x]). Diseño+tooling reales y operativos: inventario_2d.json (48 assets definidos, versionado), validar_arte_2d.gd (validador headless), ART_STYLE_2D.md. **0 de 48 assets en disco** (0 PNG/SVG/WebP; los 9 archivos son .gitkeep). Bloqueado por M45 (20/171), M108 (122/205), M161 (94/138), M154 + artes. Veredicto: DEUDA ESTRUCTURAL BLOQUEADA.
- [x] **M46 discrepancia doc<->archivo**: notas iter.1 declaran 103-104 [x] pero casillas 0/110 por reversion 2026-09-14 (agnes-2.5-flash marco completo sin verificacion). Flaggeado por Log 954 + auditoria drift 2026-09-20. Decision del dueno: no re-marcar (lo respeto, READ-ONLY).
- [x] **M46 planificacion**: ALTA. 24 dependencias citadas, TODAS existen en GLOBAL. Item "imposible" (OCR texto embebido) honestamente marcado fuera de alcance V0.
- [x] **M77 (0/130, 4 [?])**: NO es Familia A. Contrato documental post-v1. Los 4 [?] = mp_contract.json/net_contract.json ausentes (verificado). Pregunta del director: **roadmap futuro, NO deuda real de v1** — el modulo lo declara (W4 hit >10k descargas, Y3 v1 no abre puertos, Y4 reconciliacion futura, bloque X M76).
- [x] **M77 planificacion**: ALTA pero redundante (~90 de 130 son "Definir X" del mismo net_contract.json). 12 dependencias citadas, TODAS existen. M76 (1/130) es la unica puerta real.
- [x] **Informe entregado (msg 161)**: sin cambios de estado recomendados (ambos correctamente en amarillo, 0% honesto).

## BUG-120 verificacion runner M112 (msg 162 encargo, completada)

- [x] **Runner v2c corrido de forma independiente y COMPLETO**: 28 suites descubiertas (24 SceneTree + 4 GdUnit4), **1241 tests** (1220 checks SceneTree + 21 GdUnit4), 24/28 OK.
- [x] **BUG-120 RESUELTO confirmado**: v1 daba EXIT 0 con 0 tests; v2c da quit(1) honesto con rc real del proceso. 3 guardas anti-falso-verde en _resumen() (quit(2) si 0 tests, quit(1) si mismatch). Patron v1 estructuralmente imposible.
- [x] **Un fallo real detectado**: GdUnit4 rc=101 por 201 orphans de test_debug_menu.gd (21/21 PASSED, 0 failures) — [?] L292, dueno M110. El runner NO felicita: reporta FALLO.
- [x] **Suites watchdog pasaron**: test_npc_visual_database [OK] rc=0 checks=356; test_equipment_manager [OK] rc=0 checks=44. [?] L290/L291 eran FLAKY — revertibles a [x] por el dueno (no yo, READ-ONLY).
- [x] **Drift GLOBAL encontrado**: M112 dice 202/208 pero el conteo real es 216 [x] / 5 [ ] / 4 [?] = 225. Causa: GLOBAL no sumo la seccion T-M112 (14 [x] + 3 [?]; 202+14=216, 208+17=225).
- [x] **5 [ ]**: mis reversiones Familia A del msg 144 (artefactos inexistentes), correctas. **[?] L166**: over-mark mio H2 #152.
- [x] **Veredicto**: M112 correctamente en amarillo. Informe entregado (msg 163) con 2 acciones para el director (actualizar GLOBAL, delegar L292 a M110).
- [x] **Nota**: el msg 162 del director llego VACIO (plantilla sin completar); actué por el nombre del archivo.

## Confirmacion del director (msg 164): M112 QA aceptada, drift corregido

- [x] **GLOBAL M112 actualizado por el director**: 202/208 -> **218/225** (drift T-M112 sumado + L290/L291 revertidos a [x] con mi evidencia de corrida).
- [x] **[?] L292 (orphan test_debug_menu.gd) delegado a M110** — fila M110 con actividad 2026-10-09 03:50.
- [x] **M112 sigue amarillo** con 2 [?] reales (L166 over-mark + L292 en M110). Veredicto sostenido.
- [x] **Nota**: msg 164 tambien llego VACIO (2º consecutivo); el nombre del archivo confirmaba las 3 acciones. Sin nuevo encargo.

## QA sec21.8 de M163 Sistema de Encantamientos (msg 164 encargo, completada)

- [x] **4 suites corridas headless**: test_bug124_shaman_visual (12), test_enchantment (58), test_enchant_tiers (45), test_incienso (67) = **182 checks, 0 fallos, 0 SCRIPT ERROR**.
- [x] **Muestreo anti-inflaccion 21.8.2.b**: 5 [x] con verbos de creacion (L45 shaman_npc.gd, L48 shaman_ui.gd, L68 incense_cultivation.gd, L73 incense_spawner.gd, L74 spawner TerrainLocator) — todos con artefacto real en disco. **0 inflacion.**
- [x] **Regla 26 (chaman sobre terreno) CONFIRMADA en runtime**: shaman_npc.gd L27-32/L50-61 usa TerrainLocator.get_height() con MundoRaiz.CENTRO (sin Y hardcodeada). Log de la suite: spawn (2320.0, 35.0, 2300.0) -> reposicionado (2320.0, 17.0, 2300.0). Mismo mecanismo BUG-119 que diagnostique.
- [x] **Estado**: 61 [x] / 48 [ ] / 15 [?] = 124 (coincide GLOBAL). Modulo EN CURSO real al 49% — no sellable como verde, pero 0 inflacion.
- [x] **Informe entregado (msg 165)**: sin acciones requeridas; M163 correctamente en amarillo.

## LOTE 9 reclasificacion de amarillos estancados (msg 166 encargo, completado)

- [x] **6 modulos diagnosticados** (verdad de estado, no inflacion): M72, M76, M05, M48, M21, M04.
- [x] **M48 Animacion -> BLANCO-reclasificar**: el plan cita validate_animation.gd (5 veces) + jugador_lib.tres + npc_humanoide_lib.tres — NINGUNO existe. animation_service.gd real NO citado. Sin log propio. Nunca arranco de verdad.
- [x] **M72 Logros -> recuperable**: 6/6 artefactos existen; runtime carga 11 logros + 25 hitos con catalog OK (RF14). Nucleo funcional real bajo un 1/185 engañoso.
- [x] **M05 Lenguaje -> recuperable**: logger/registro/event_bus/game_clock existen y son el core (con drift de rutas: logging/ y time/ no core/); error_handler.gd citado NO existe. Log 494 hace 5 semanas, dueno MiMo inactivo.
- [x] **M21 Dialogos -> recuperable**: 11/11 artefactos existen (dialogue_ui, world_state_service, validadores), integrado en runtime. Log 1364 (2026-10-06).
- [x] **M04 Game-Engine -> recuperable**: bootstrap.gd + main_island.tscn = el corazon del juego. Log 1403.
- [x] **M76 Multijugador -> deuda-real (roadmap)**: 0 artefactos citados, documental puro como M77. Planteada decision al director: mantener amarillo (consistencia M77) o bajar a blanco (literalismo criterio 3).
- [x] **Informe entregado (msg 167)**: tabla con veredicto + evidencia por modulo. Esperando decision del director sobre M76 y aplicacion de la reclasificacion de M48.

## LOTE 12 sync backlog<->checklist (msg 168 encargo, completado)

- [x] **4 backlogs auditados**: agnes-3-flash (33[x]/5[ ]), mimo-v2.6-flash-free (61[x]), DeepSeek-V4.1-Flash (132[x]/79[ ]), atria-dawn-s3 (27[x] en encabezados).
- [x] **mimo = PERFECTAMENTE SINCRONIZADO**: M44/M88/M89/M43/M153/M151/M55/M91 todos coinciden con disco. 0 acciones.
- [x] **agnes drift inverso**: M152 completado (202/0/0) pero listado pendiente; M129 68->101; M06 0->99. M100 "CERRADO" ambiguo (modulo sigue amarillo 146/222, 76 [ ] abiertos).
- [x] **DeepSeek drift inverso M62**: seccion "62-Memoria (52 pendientes)" de 2026-09-20 — **15 de 52 ya estan [x]** (trabajo agnes Log 1387). M62 real 113/37. Riesgo de trabajo duplicado.
- [x] **DeepSeek cierres exactos**: M68 75/42/14, M59 60/69/1, M29 190/195 sin drift. Trabajo ACTIVO hoy (M104 lote 11 + M156).
- [x] **s3 desorden de marcas**: 12 [→] EN CURSO acumulados, algunos con [x] duplicado mas abajo (L-09 M108, L-10 M28). Sin drift de modulo (sus tareas son auditorias de Ling).
- [x] **Informe entregado (msg 169)**: creado manualmente (reservar_mensaje.py consumio el 169 del pool sin aterrizar el archivo). Unica accion recomendada al director: avisar a DeepSeek que refresque su seccion M62.

## Script verificar_backlogs.py (LOTE 12 estandarizado) — 2026-10-09
- [x] Script creado: 4 detectores (cierres posicionales, drift inverso con tracking de seccion, [->] colgados, modulos inexistentes), flags --dry-run/--modelo/--json/--solo-alertas/--umbral. Log 1529, msg 171 al director.
- [x] Validacion cruzada vs msg 169: mimo limpio, DeepSeek drift M62 ya resuelto por su propia actualizacion, agnes 3 obsoletos, s3 [->]. Hallazgos nuevos: 5 retrocesos (Hy3 M146/M63/M62/M57, kimi M70).

## Parser multimodulo + verificacion Hy3 + LOTE 13 — 2026-10-09 18:59
- [x] Parser arreglado (4 bugs: tripleta vs par, filtro x>=1, nombres de archivo, lookbehind de version). Log 1535.
- [x] Informe Hy3 verificado: M146/M57 exonerados, M62/M63 confesados confirmados por el script. M70 +37 hallazgo adicional reportado.
- [x] LOTE 13: Hy3 9 drift (25-Ruinas 122/0/0, recomiendo avisar); kimi-k3 97 drift (M106/M122 completados, recomiendo archivar sin notificar). Resto 0. Msg 174.
