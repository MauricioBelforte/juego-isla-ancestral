# BACKLOG 100 TAREAS PARA ATRIA-DAWN — Investigación para mañana

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 15:46:00
**Origen:** orden del fundador (15:37): *"planea de antemano 100 tareas para cada modelo ... ling y
kimi no"* (relegados)

## Perfil de ATRIA-DAWN (§30.1, §31)

**DEEP WORK por excepción** — tareas duras que superan a Step 5 (razonamiento profundo real). **No
está en el circuito normal de delegación**: el director (mimo) le asigna solo lo que los demás no
pueden resolver. Su backlog es una **lista priorizada de deep work disponible**, no una cola que se
agota — el director pickea de aquí cuando algo se atasca.

## LAS 100 TAREAS

### Bugs ABIERTOS (prioridad máxima — el director los ve en 11-BUGS.md)

1. BUG-124: Chaman del Monte (M163) sin representación visual — `ShamanMonte` es Node3D invisible
   (sin malla). Crossover M163/M161. Requiere decisión de asset (Blender V5) + integración.
2. BUG-125: `InventoryPanel` doble `add_child` (`player.gd:554` + `:700`) — ERROR de engine en cada
   primera apertura. Crossover M11/M53. Fix mecánico pero toca jugador (⚠️ §15: no romper M11).
3. BUG-054: M39↔M15 — 13 referencias rotas (8 item_ids inexistentes) en las 3 tiendas oficiales.
   Deep work: reconciliación de catálogos `catalogo_venta` Y `catalogo_recompra`.
4. BUG-055: `test_logros.gd:291` usa `_ach.desbloqueados` (propiedad inexistente) — corregir el test
   de M72, no el código.
5. BUG-025: Sección `npc` del save no coincide con el schema default (M19 vs M59) — deep work de
   serialización cross-módulo.
6. BUG-057: `buildings_save_provider.gd` no restaura estructuras (no-op hasta que M17 implemente
   `restaurar_estructuras`) — bloqueado por M17 (WorkBuddy). Vigilar y tomar cuando M17 cierre.
7. BUG-053: QA visual orbitales V-1/V-2/V-4/V-5 (mesh) delegados a Hy4 (no disponible) — cuando
   Hy4 vuelva, coordinar; V-6/V-7 ya cubiertos por M167/M51.
8. BUG-059: ~33 citas colgantes a `03-Diseno.md` inexistente + 8 fantasmas en M71/M80/M86/M108/M127
   — barrido de reconciliación documental (M127 ya encolado a DeepSeek).
9. BUG-069 parte A2: 10 referencias a autoload declarado después (dependencias vivas) — inversión de
   dependencias en ≥8 módulos ajenos. Deep work real: diseñar la migración sin romper nada.
10. BUG-021 cierre total: chunks invisibles a distancia — verificación del fix del LOD (Log 587).

### Deep work de módulos complejos

11. M164-Isla-De-Combate-Endgame (4 `[?]`) — diseño del endgame: balance, loot, progresión final
12. M9-Terreno-Y-Geografia (5 `[?]`) — geografía/altura del mundo, crossover con M167
13. M10-Generacion-Del-Mundo (16 `[?]`) — generación procedural (deep work por definición)
14. M156 — pendiente de su sesión anterior (colisión TerrainModifiers/TerrainDetector, BUG-008)
15. M24-Templos-Y-Puzzles (DoD REVOCADO) — las 2 unidades requieren verificación profunda antes de
    cualquier sello. ⚠️ No promover sin evidencia.
16. M167 shore-fade (KnownIssue, dueño M49/M51) — el único `[ ]` de la Isla Raíz; requiere shader
    de transición costa/agua. Crossover M49 (agnes) — coordinar.
17. M61-Rendimiento (89 `[ ]` + 6 `[?]`) — frame budget, profiling (crossover BUG-067)
18. M63-Cargas-Y-Streaming (27 `[?]`) — arquitectura de streaming profunda
19. M159-Catalogo-De-Objetos (52 `[?]`) — el catálogo central; tocarlo afecta a M39/M15 (BUG-054)
20. M12-Camara (45 `[?]`) — si Kilo se atasca en la lógica de cámara/zoom (guía 16), tomarlo

### Arquitectura y gates (su especialidad histórica)

21. Grafo de servicios: auditoría `auditar_arquitectura_m62.py` completa (reglas A1-A10)
22. `architecture-guard` — allowlist obsoleta (`A1|ThemeService,UIManager`) — borrar con s2
23. BUG-051/071: gate de sintaxis — verificar que sigue byte-idéntico (855 preloads)
24. CI `godot-lint` — monitorear que no vuelva a ser no-op (familia BUG-051/071)
25. `gen_colector_sintaxis.py` versionado — verificar `.gitignore:130` sigue excluyéndolo bien
26. Pools de numeración: salud de TODOS los pools (logs + canales) con `verificar_pool_numeros.py`
27. Colisiones de numeración: 2 no borrables restantes (msg 275) — decisión final
28. `test_scripts.py` — mantener 8 PASS / 0 FAIL tras cualquier cambio de scripts
29. `verificar_checklist.py` — drift global (insumo del barrido anti-inflación de Hy3)
30. `verificar_backlogs.py` — sincronización backlog ↔ checklist de toda la flota
31. `fix_encoding.py` + `diagnosticar_mojibake.py` — pasada de saneamiento si aparecen corruptos
32. Godot 4.7.2 headless — suite maestra: 0 SCRIPT ERROR tras los cierres del día
33. Boot global — verificar 0 errores en `get_debug_output` (regresión BUG-003)
34. Renombre de identidad step-5-kilocode — consistencia de firmas en todos los archivos
35. `11-BUGS.md` — reconciliación: cerrar entradas `[x]` sin Log citado, retriage de delegados

### Commits pendientes (ruteados a él, msg 256)

36. Commit M45+M105 — diff review antes de push (§4.2 protocolo completo)
37. Commit del renombre de identidad step-5-kilocode
38. Commit de colisiones de numeración (12 limpiadas)
39. Commit de los fixes de bugs cuando cierre BUG-124/125
40. Limpieza de worktree: archivos sin versionar que matchean `.gitignore` (auditoría)
41. `Obsoletos/` — respaldos de la sesión, nomenclatura AAAA-MM-DD_HH-MM-SS (§5)
42. Log de push obligatorio (§4.3): TODO push deja línea con rango viejo..nuevo
43. Verificación de remoto: `git log origin/main -1` + `git diff --stat origin/main`

### Revisión de documentación canónica

44. `GUIA-GODOT/` — los 12 archivos: vigencia de las recetas tras los cambios del día
45. `GUIA-GODOT/06-registro-errores.md` — registrar los bugs nuevos que cierre
46. `GUIA-GODOT/19-diagnostico-tildes.md` — vigencia del protocolo de freeze
47. `GUIA-BLENDER/` — los 10 archivos (V5 Hy4 vuelve: coordinar)
48. `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` — estado de vías V1-V5
49. `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` — fases habilitadas tras los cierres
50. `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` — §21.21-21.23: actualizar con la vuelta 8
51. `AGENTS.md` — vigencia de §30 (asistentes) y §31 (identidad) tras el renombre
52. `Mensajes entre modelos/GUIA-COMUNICACION.md` — T-12/T-15/T-19 vigentes
53. `DOCUMENTACION/167-Isla-Raiz/` — recovery procedure vigente (post shore-fade)
54. `DOCUMENTACION/168-Plantilla-De-Isla/` — placeholders para islas nuevas
55. `docs/` — material complementario: verificar que nadie creó documentación nueva ahí (§3)

### Soporte a la flota (deep work reaccivo)

56. Desbloquear a Step 5 si se atasca en M27/M74/M34 (auditoría masiva de `[?]`)
57. Desbloquear a DeepSeek si M01 (131 `[ ]`) revela dependencias ocultas
58. Desbloquear a agnes en M49 (iluminación) si el shader coast-fade supera su capacidad
59. Desbloquear a Kilo en M31/M12 (cámara/día-noche) si la lógica temporal es compleja
60. Revisar las propuestas de flip de Hy3 que el director no sepa resolver
61. Revisar los veredictos de s2 en casos límite (§30.2 regla 6 invertida)
62. Coordinar Hy4 (Blender) cuando vuelva — BUG-053 V-1..V-5 + BUG-124 asset del chamán
63. Revisión de la guía 08: ¿la vuelta 8 se puede armar? (msg 256: NO hasta que alguien espere)
64. Análisis de cuellos de botella de la flota (rol s3, su otra sesión)
65. Revisión de los 7 sellos §21.8 en corte del director (M101, M111, M78, M38, M84, M29, M52, M34)

### Bugs delegados con contexto complejo (de §8 de 11-BUGS.md)

66. BUG-067 cierre total — documentar la decisión de diseño §3 vs §10-Regla-5 en M103
67. BUG-068 — verificar que el fix de 2 pasos (P-32) sigue intacto tras cambios de M115
68. BUG-042 — fuentes .ttf: verificar que el gate de bytes mágicos sigue en CI
69. BUG-052 — trinquete max 418: verificar que nadie subió assets nuevos a `assets/3d`
70. BUG-058 — `validar_nombres.py`: 45 violaciones reales LOC-/NPC- (M160/M161)
71. BUG-081 — tipos en scripts legales: regresión de `credits_manager.gd` y `audio_credit.gd`
72. BUG-035 — M107 backups: el test fallaba 1/9, verificar suite 9/9
73. BUG-039 — generador de checklist: verificar que no vuelve a borrar el encabezado
74. BUG-040 — `inventory_layer.gd` señal item_added: verificar 22/0 EXIT 0
75. BUG-041 — código muerto `log_buffer`/`_flush()`: limpieza segura en `logger.gd`

### Optimización profunda (§21.4: si no sabés optimizar, no lo hagas)

76. Frame budget global — medir con el profiler real (no estimaciones)
77. Draw calls — auditoría de batching/instancing en el terreno voxel
78. Memoria M62 — leaks potenciales en signals (familia BUG-015)
79. Streaming M63 — pop-in de chunks (familia BUG-021)
80. LOD de vegetación M50 — distancia vs consistencia con terreno
81. Culling — frustum culling de NPCs (M64/M65)
82. Pooling — objetos coleccionables (M73) y partículas (M52)
83. Compresión de texturas — auditoría de assets 4K (M46/M56)
84. Godot 4.7.2 — features de rendimiento sin usar (forward+, Vulkan)
85. Profiling de boot — tiempo de arranque con 76 módulos de autoload

### Cierre de sesión

86. Log de su sesión (protocolo §6.1: reservar número, escribir, marcar backlog)
87. Backlog personal `TAREAS-POR-MODELO/atria-dawn/BACKLOG-MASTER.md` — marcar completados
88. Reporte al director en `Mensajes entre modelos/atria-dawn/` (REGLA CERO §7)
89. Notas del Agente en los `04-Codigo.md` de los módulos que toque (§21.3 regla 8)
90. Firma de documentos (§3: modelo + plataforma, UTF-8 estricto §28)
91. Respaldos en `Obsoletos/` antes de cambios grandes (§5)
92. Verificación UTF-8 de TODO lo que escriba (`diagnosticar_mojibake.py`)
93. Sin tocar `CHECKLIST-GLOBAL.md` (regla de la sesión) ni commits sin orden explícita
94. Sin tocar módulos 🔵 de otros agentes (§21.4)
95. QA §21.8 de lo que cierre él mismo — lo verifica s2 o Hy3 (independencia)
96. Documentación de nuevos descubrimientos en las guías (§26: no arrancar de cero)
97. Actualizar §21.21-21.23 de la guía 10 con las lecciones del día
98. Re-verificar que los crons están apagados (orden del fundador 04:24)
99. Estado final de la flota para el director: quién quedó en qué
100. Preparar la siguiente ronda de backlogs si el fundador los pide

## Reglas para atria

1. **Por excepción:** el director le asigna de esta lista SOLO lo que supera a Step 5. No tomar
   trabajo del circuito normal sin orden del director.
2. **No romper lo establecido (§15):** M11, sistema de combate, IA de NPCs — agregar scripts nuevos
   antes que modificar los que funcionan.
3. **Optimización §21.4:** si una optimización supera su conocimiento, documentar en `[?]` y
   delegar. No entregar trabajo "funcional pero mal".
4. **UTF-8 estricto (§28):** su plataforma escribió mojibake antes — verificar antes de notificar.

## Entrega al director

Lista priorizada, no cola. El director pickea por prioridad: **tareas 1-10 (bugs abiertos) →
11-20 (módulos complejos) → 21-35 (arquitectura) → resto según necesidad**. No se entregan en 10
mensajes como los demás: atria recibe encargos puntuales del director cuando algo se atasca.

**Firma:** atria-dawn-s3 (Atria-Dawn-Preview / Kilo Code) — 2026-10-13 15:46:00
