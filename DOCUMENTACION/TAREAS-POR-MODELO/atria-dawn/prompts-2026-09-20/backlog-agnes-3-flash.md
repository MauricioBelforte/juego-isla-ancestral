**Generado por:** atria-dawn (Kilo Code) — coordinacion Log 1091/1092
**Fecha:** 2026-09-20

# BACKLOG AUTONOMO — agnes-3-flash

> **Tareas extraidas de los `05-Checklist.md` reales** (no inventadas). Cada una es
> verificable contra el codigo. **Trabajalas en orden**; al completar una, marca `[x]`
> en los **3 registros**: este backlog, el `05-Checklist.md` del modulo (marcas **Y**
> linea `**Totales:**`) y la fila de `CHECKLIST-GLOBAL.md`.
>
> **Rol asignado:** Visual / arte / animacion (vision nativa verificada)
>
> **Recordatorios del protocolo:**
> - Reserva log: `python scripts/reservar_log.py --reservar --agente agnes-3-flash --modulo <X>`
> - Push a git: **NEGATIVO** (instruccion del usuario)
> - Anti-falso-verde (leccion 28): exit code **Y** 0 SCRIPT ERROR en stderr
> - Codificacion UTF-8 obligatoria
> - Binario Godot 4.7.2: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
>   `--headless --path game/isla-ancestral --quit --script res://...`

---

## 46-Arte-2D (110 pendientes)

- [ ] **T-001 46:** Definir el problema: sin dirección 2D, iconos/retratos/UI se sienten de otro juego e incoherentes con el 3D [S] — Log 726 (ART_STYLE_2D §1)
- [ ] **T-002 46:** Definir el objetivo: guía de estilo 2D heredada del 3D, bancos de iconos/retratos, atlas y validación [S] — Log 726
- [ ] **T-003 46:** Registrar dependencias: M45 (3D), M53 (UI), M88 (fuentes), M14 (iconos), M47 (texturas), M57 (input), M108 (pipeline) [S] — Log 726 (inventario_2d....
- [ ] **T-004 46:** Mapear la sección 45 "ARTE 2D" del plan maestro al ID 46 de la tabla global (desfase de numeración) [M] — Log 726 (ART_STYLE_2D §10)
- [ ] **T-005 46:** Separar dentro/fuera de alcance: layout de UI → M53, fuentes → M88, animación → M48, texturas 3D → M47
- [ ] **T-006 46:** Documentar restricciones: estilo heredado, sin texto en arte, atlas ≤2K, resoluciones estándar, SVG fuente [S] — Log 726 (ART_STYLE_2D §7)
- [ ] **T-007 46:** Definir criterios de aceptación verificables (8 criterios) [S] — Log 726 (sección W del checklist)
- [ ] **T-008 46:** Incluir contexto del plan de producción §4: paleta pastel, "el juego cozy vive y muere por sus menús" [M] — Log 726 (ART_STYLE_2D §1-2)
- [ ] **T-009 46:** Definir ART_STYLE_2D.md derivado de M45: paleta, trazo, sombreado, redondeo [M] — Log 726 (DOCUMENTACION/46-Arte-2D/plan-actual/ART_STYLE_2D.md)
- [ ] **T-010 46:** Definir trazo exterior redondeado 2-3 px a 128 px [S] — Log 726 (§3)
- [ ] **T-011 46:** Definir sombra plana inferior 10% [S] — Log 726 (§3)
- [ ] **T-012 46:** Prohibir gradientes complejos, ruido, texturas foto, neón [S] — Log 726 (§3)
- [ ] **T-013 46:** Definir recetas visuales por familia de iconos [M] — Log 726 (§4)
- [ ] **T-014 46:** Definir logo principal + variante clara/oscura + icono solo [M] — Log 726 (§4 familia logo; asset en inventario)
- [ ] **T-015 46:** Definir fuentes SVG y raster 1024 [S] — Log 726 (inventario: logo_principal 1024)
- [ ] **T-016 46:** Definir submarca para iconos de plataforma (Steam M97) [S] — Log 726 (§4)
- [ ] **T-017 46:** Definir iconos de todos los ítems de M14/M15 con claves i18n [M] — Log 726: inventario data-driven (inventario_2d.json, 6 iconos de recursos M15 se...
- [ ] **T-018 46:** Definir tamaño de trabajo 128×128 [S] — Log 726
- [ ] **T-019 46:** Definir legibilidad mínima 32 px (prueba obligatoria) [M] — Log 726 (§6)
- [ ] **T-020 46:** Definir fondo de rareza por color según M38 [M] — Log 726 (§4 receta ico_)
- [ ] **T-021 46:** Definir ángulo canónico 3/4 con plantilla 3D [M] — Log 726 (§3/§9)
- [ ] **T-022 46:** Definir iconos de 9 herramientas × 4 niveles (M13) [M] — Log 726: 24 assets ico_herr_<tipo>_t<1-4> en inventario (pico/hacha/pala/martillo/caña/rie...
- [ ] **T-023 46:** Definir diferencias visuales de nivel (mango, hoja, aura) [M] — Log 726 (§4 receta ico_herr_: cabeza por material)
- [ ] **T-024 46:** Definir variante de nivel 4 ancestral con símbolo [S] — Log 726 (§4: T4 con símbolo ancestral)
- [ ] **T-025 46:** Definir retrato de cada NPC (M19) y jugador [M] — Log 726: pt_npc_riz_001_* (5 expresiones) sembrados en inventario; patrón replicable por NPC
- [ ] **T-026 46:** Definir 5 expresiones base: base, alegre, triste, sorprendido, pensativo [M] — Log 726 (§5)
- [ ] **T-027 46:** Definir +3 expresiones extra para NPCs románticos (M20) [M] — Log 726 (§5: coqueteo/sonrojado/corazon)
- [ ] **T-028 46:** Definir plantilla 3D obligatoria (render del modelo + repintado) [M] — Log 726 (§4 receta pt_)
- [ ] **T-029 46:** Definir tamaño 256×256 y prueba a 96 px [S] — Log 726 (§6)
- [ ] **T-030 46:** Definir iconos de acciones (M57): interactuar, atacar, saltar, menú [M] — Log 726 (§4 familia ui_art_; estados en inventario)
- [ ] **T-031 46:** Definir botones, marcos y paneles como slice9 para M53 [M] — Log 726 (§4: esquinas 8 px, ui_art_panel_slice9 en inventario)
- [ ] **T-032 46:** Definir estados visuales: normal, hover, pressed, disabled [M] — Log 726 (4 assets en inventario)
- [ ] **T-033 46:** Definir set de símbolos para M24/M25/M26 sin palabras [M] — Log 726: 4 sym_sello_* (RIZ/COR/CEN/AUR) en inventario
- [ ] **T-034 46:** Definir geometría suave y reutilizable [S] — Log 726 (§4)
- [ ] **T-035 46:** Definir símbolos en superficies: ruinas, templos, sellos [M] — Log 726 (§4; coordenadas de superficie en M160 templos/ruinas)
- [ ] **T-036 46:** Definir ilustración pergamino para mapas del tesoro (M25) [M] — Log 726: illus_mapa_tesoro 1024 en inventario
- [ ] **T-037 46:** Definir estilo con safe zone central para UI [S] — Log 726 (§4)
- [ ] **T-038 46:** Definir integración con M54 (mapa) como skin artística opcional [M] — Log 726 (§4)
- [ ] **T-039 46:** Definir marco común de insignias (círculo + figura + borde de rareza) [M] — Log 726 (§4; badge_logro_marco en inventario)
- [ ] **T-040 46:** Definir tamaño grande 100 px y pequeño 48 px [S] — Log 726 (§6)
- [ ] **T-041 46:** Definir integración con logros (M72) y sellos (M22) [M] — Log 726 (§4)
- [ ] **T-042 46:** Definir fondo de museo para coleccionables (M37) [S] — Log 726 (§4)
- [ ] **T-043 46:** Definir pantallas de carga con arte de Aurora [M] — Log 726: illus_carga_aurora 1024 en inventario
- [ ] **T-044 46:** Definir formato 1024×1024 con área de texto libre [S] — Log 726 (§6)
- [ ] **T-045 46:** Definir integración con M63 (progreso real sobre el arte) [M] — Log 726 (§4)
- [ ] **T-046 46:** Definir icono del jugador en mapa/minimapa coherente con personaje 3D [M] — Log 726 (§4 receta ico_ con plantilla 3D; asset por agregar al inventario)
- [ ] **T-047 46:** Definir variante de dirección (heading) para minimapa [S] — Log 726 (§4)
- [ ] **T-048 46:** Definir ui_atlas, icons_atlas, portraits_atlas, story_atlas, badges_atlas [M] — Log 726 (§7; carpetas por familia en assets/2d/)
- [ ] **T-049 46:** Definir límite 2048×2048 por atlas [S] — Log 726 (§7)
- [ ] **T-050 46:** Definir padding ≥ 2 px [S] — Log 726 (§7)
- [ ] **T-051 46:** Definir sin rotaciones en empaquetado [S] — Log 726 (§7)
- [ ] **T-052 46:** Definir regeneración por script (pack_atlas.gd)
- [ ] **T-053 46:** Definir SVG como fuente editable (Inkscape/Krita) [S] — Log 726 (§7)
- [ ] **T-054 46:** Definir PNG/WebP como runtime (M108) [S] — Log 726 (§7)
- [ ] **T-055 46:** Definir transparencia sin halos (alfa limpio) [M] — Log 726 (§7; verificado por validador)
- [ ] **T-056 46:** Definir tamaños múltiplos de 4 (compresión) [S] — Log 726 (§7; verificado por validador)
- [ ] **T-057 46:** Definir script validate_2d.gd en Assets/_Project/Editor/
- [ ] **T-058 46:** Verificar formato y tamaño cuadrado permitido [S] — Log 726: validador chequea cuadrado para ico_/pt_/sym_/badge_ (probado con asset 126x128 rechaz...
- [ ] **T-059 46:** Verificar resolución múltiplo de 4 [S] — Log 726: validador (probado)
- [ ] **T-060 46:** Verificar alfa sin halos en bordes [M] — Log 726: _alfa_bordes_limpio() inspecciona píxeles del borde (0 o 255)
- [ ] **T-061 46:** Verificar duplicados de id contra catálogo [M] — Log 726: cobertura contra inventario_2d.json (ids únicos por definición de catálogo)
- [ ] **T-062 46:** Verificar convenciones de nombres por tipo [S] — Log 726: NAMING_PATTERN extendido a 7 prefijos RF15 (probado)
- [ ] **T-063 46:** Definir prefijos: ico_, pt_, illus_, sym_, badge_, ui_art_ [S] — Log 726 (validador + ART_STYLE_2D §4)
- [ ] **T-064 46:** Alinear con M108 (Pipeline de Assets) [M] — Log 726 (§7)
- [ ] **T-065 46:** Definir sufijos de variantes de expresión (pt_<npc>_alegre) [S] — Log 726 (§5)
- [ ] **T-066 46:** Definir regla dura: 0 textos en arte [S] — Log 726 (§7)
- [ ] **T-067 46:** Documentar que M87/M88 superponen todo texto [M] — Log 726 (§7)
- [ ] **T-068 46:** Incluir verificacion de regiones de texto en el validador [M] -- agnes-2.5-flash 2026-09-12: regla 0-texto documentada en 03-Diseno.md §7 + Log 726...
- [ ] **T-069 46:** Legibilidad a 32 px con contraste AA (M58) [M] — Log 726 (§6 prueba obligatoria definida)
- [ ] **T-070 46:** Consistencia: un solo set de iconos en todas las superficies [M] — Log 726 (catálogo único inventario_2d.json)
- [ ] **T-071 46:** Rendimiento: atlas únicos, carga diferida (M63), sin duplicados (M62) [M] — Log 726 (§7)
- [ ] **T-072 46:** Cozy: colores amables, sin parpadeos, insignias que celebran [M] — Log 726 (§1-2)
- [ ] **T-073 46:** Mantenible: SVG editable, regeneración por script
- [ ] **T-074 46:** Accesibilidad: variantes de alto contraste separadas [M] — agnes-2.5-flash 2026-09-12: sufijo de variante documentado en 03-Diseno.md §8; IMPLEMENT...
- [ ] **T-075 46:** Descartar iconos sin referencia 3D (incoherencia) [M] — Log 726 (§9 flujo con plantilla 3D obligatoria)
- [ ] **T-076 46:** Descartar retratos por IA directa (inconsistencia + legal) [M] — Log 726 (§9: render 3D + repintado)
- [ ] **T-077 46:** Descartar un solo atlas gigante (memoria M62) [M] — Log 726 (§7 atlas por superficie)
- [ ] **T-078 46:** Descartar texto embebido (localización M87) [M] — Log 726 (§7 regla dura)
- [ ] **T-079 46:** Adoptar atlas por superficie + SVG fuente [M] — Log 726 (§7)
- [ ] **T-080 46:** Riesgo de iconos incoherentes → guía + recetas + review [M] — Log 726 (§3-4, §9)
- [ ] **T-081 46:** Riesgo de retratos que no parecen al NPC → plantilla 3D + comparación [M] — Log 726 (§9)
- [ ] **T-082 46:** Riesgo de atlas descontrolados → límite 2K + regeneración [M] — Log 726 (§7)
- [ ] **T-083 46:** Riesgo de texto en arte → regla dura + validador [M] — Log 726 (§7, §8)
- [ ] **T-084 46:** Riesgo de memoria por texturas 2D → compresión + carga diferida [M] — Log 726 (§7 múltiplo de 4 + WebP)
- [ ] **T-085 46:** Documentar integración con M45 (plantillas 3D, catálogo compartido) [S] — Log 726 (§4, §9)
- [ ] **T-086 46:** Documentar integración con M53 (piezas UI) [S] — Log 726 (§4)
- [ ] **T-087 46:** Documentar integración con M87 (localización, cero texto) [S] — Log 726 (§7)
- [ ] **T-088 46:** Documentar integración con M88 (fuentes) [S] — Log 726 (§7)
- [ ] **T-089 46:** Documentar integración con M63 (carga diferida) [S] — Log 726 (§7)
- [ ] **T-090 46:** Documentar integración con M62 (memoria) [S] — Log 726 (§7)
- [ ] **T-091 46:** Documentar integración con M108 (importación) [S] — Log 726 (§7)
- [ ] **T-092 46:** Documentar integración con M72/M22/M37 (insignias, sellos, coleccionables) [M] — Log 726 (§4)
- [ ] **T-093 46:** Documentar integración con M58 (accesibilidad) [M] — Log 726 (§6/§8)
- [ ] **T-094 46:** Documentar flujo de creación de icono (plantilla 3D → ilustrar → validar → atlas) [M] — Log 726 (§9)
- [ ] **T-095 46:** Documentar flujo de creación de retrato (render → repintado → expresiones → atlas) [M] — Log 726 (§9)
- [ ] **T-096 46:** Documentar flujo de empaquetado (pack_atlas.gd) [M] — Log 726 (§9)
- [ ] **T-097 46:** Documentar herramientas: Inkscape, Krita, Blender para renders [S] — Log 726 (§7/§9)
- [ ] **T-098 46:** Documentar uso de IA como base + repintado (M86) [M] — Log 726 (§9: repintado obligatorio sobre plantilla 3D)
- [ ] **T-099 46:** ART_STYLE_2D.md permite dibujar sin preguntar [M] — Log 726: paleta + recetas + tamaños + flujos completos
- [ ] **T-100 46:** Icono de cada objeto legible a 32 px en inventario y tienda [M] — agnes-2.5-flash 2026-09-12: criterio definido en 03-Diseno.md §6; prueba se ejecu...
- [ ] **T-101 46:** Retrato del NPC se parece al modelo 3D (comparacion lado a lado) [M] — agnes-2.5-flash 2026-09-12: flujo §9 define comparacion; se ejecutara cuando...
- [ ] **T-102 46:** Símbolos ancestrales sin texto reutilizables [M] — agnes-2.5-flash 2026-09-12: receta §4 + 4 sym_sello en inventario; verificacion al crearlos requ...
- [ ] **T-103 46:** Atlas con carga diferida sin duplicados en memoria [M] — agnes-2.5-flash 2026-09-12: regla §7 definida; verificacion cuando existan atlas (M108 pip...
- [ ] **T-104 46:** Validador rechaza pieza con resolución o halo incorrectos [M] — Log 726: PROBADO (asset 126x128 rechazado, halos verificados por píxel)
- [ ] **T-105 46:** Botón con texto usa fuente M88, nunca arte [M] — Log 726 (§7 regla dura)
- [ ] **T-106 46:** Piezas cumplen M108 y Git LFS [M] — agnes-2.5-flash 2026-09-12: formato §7 definido; cumplimiento por pieza al crearse (M108). KnownIssue no bloque...
- [ ] **T-107 46:** Documentar el desfase de numeración del plan maestro (45=ARTE 2D → ID 46) [S] — Log 726 (ART_STYLE_2D §10)
- [ ] **T-108 46:** Marcar el módulo como DELEGABLE PARA IMPLEMENTAR
- [ ] **T-109 46:** Registrar dependencia de implementación con el hito M1 (proyecto Godot)
- [ ] **T-110 46:** Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de est...

## 48-Animacion (114 pendientes)

- [ ] **T-111 48:** Definir el objetivo: kit de animación central con producción coherente, FSM espejo y presupuesto verificado
- [ ] **T-112 48:** Registrar dependencias: M45 (rigs), M11/M19/M36 (FSM), M64/M65 (IA), M04 (Godot), M61/M62 (presupuestos), M43/M44/M52 (eventos)
- [ ] **T-113 48:** Mapear la sección 47 "ANIMACIÓN" del plan maestro al ID 48 de la tabla global
- [ ] **T-114 48:** Separar dentro/fuera de alcance: rigs → M45, FSM de comportamiento → M11/M64/M65, VFX → M52, sonido → M43
- [ ] **T-115 48:** Documentar restricciones: Godot 4.x, FPS 30 base (UI 60), determinismo de mundo, sin RNG, sincronía en timelines
- [ ] **T-116 48:** Definir criterios de aceptación verificables (8 criterios)
- [ ] **T-117 48:** Incluir contexto del plan de producción §4 (rigs por familia, coherencia)
- [ ] **T-118 48:** Definir pipeline: rig (M45) → blocking → polish → export 30 fps
- [ ] **T-119 48:** Definir convenciones de exportación: FBX, T-pose única, bones subset por familia
- [ ] **T-120 48:** Definir familias de rigs: humanoide, cuadrúpedo, ave, pez
- [ ] **T-121 48:** Definir plantilla de import en editor (import_animation_defaults.gd)
- [ ] **T-122 48:** Definir máximos de duración por categoría
- [ ] **T-123 48:** Cubrir los 10 estados de la FSM de M11 con animaciones
- [ ] **T-124 48:** Idle, caminar, correr del jugador
- [ ] **T-125 48:** Saltar, nadar, escalar del jugador
- [ ] **T-126 48:** Extraer, colocar, minar, pescar del jugador
- [ ] **T-127 48:** Cosecha, regado, diálogo, dormir del jugador
- [ ] **T-128 48:** Definir blend space 2D de locomoción (dirección × velocidad)
- [ ] **T-129 48:** Definir sockets de herramientas (grip) con M45
- [ ] **T-130 48:** Idle y caminata de NPC (M19)
- [ ] **T-131 48:** Rutinas de trabajo de NPC (M64)
- [ ] **T-132 48:** Conversación y gestos de amistad (M20)
- [ ] **T-133 48:** Animaciones festivas (M74)
- [ ] **T-134 48:** Definir variantes por personalidad (≤3 por gesto)
- [ ] **T-135 48:** Estados de M36/M65: idle, pastorear, huir, volar, nadar, dormir
- [ ] **T-136 48:** Variantes de fase en manadas/bancos (fases escalonadas)
- [ ] **T-137 48:** Definir LOD de animación de fauna (distancia)
- [ ] **T-138 48:** 9 herramientas × 4 niveles con animación de uso
- [ ] **T-139 48:** Swing de minado/pico con eventos de impacto
- [ ] **T-140 48:** Plantación, regado y cosecha
- [ ] **T-141 48:** Pesca: lanzar, espera, tensión, cobro
- [ ] **T-142 48:** Martillo y lupa (mecánicas infinitas)
- [ ] **T-143 48:** Puertas: abrir/cerrar con easing
- [ ] **T-144 48:** Puentes: bajar/subir
- [ ] **T-145 48:** Mecanismos: activar/desactivar
- [ ] **T-146 48:** Ascensores: subir/bajar con easing
- [ ] **T-147 48:** Construcción: colocar/levantar piezas (M17)
- [ ] **T-148 48:** Puzzles: mover piezas, activación (M24)
- [ ] **T-149 48:** Barcos: balanceo en agua, atraque (M28/M67)
- [ ] **T-150 48:** Dirigibles: ascender/descender, balanceo
- [ ] **T-151 48:** Submarinos: sumergir/emergir
- [ ] **T-152 48:** Vegetación: viento procedural determinista (M50)
- [ ] **T-153 48:** Agua: ondas procedurales deterministas (M51)
- [ ] **T-154 48:** Fuego: procedural de partículas (M52)
- [ ] **T-155 48:** Sin RNG en runtime (fases fijas por TIME)
- [ ] **T-156 48:** Transiciones de menú 60 fps (M53)
- [ ] **T-157 48:** Recompensas, contadores, sparkles (M71/M72)
- [ ] **T-158 48:** Descubrimientos y tooltips
- [ ] **T-159 48:** Diálogos: retratos, burbujas, gestos (M21/M46)
- [ ] **T-160 48:** Reducir movimiento con M58 (Reduce Motion)
- [ ] **T-161 48:** No animar UI fuera de pantalla
- [ ] **T-162 48:** Eventos de sonido embebidos en timelines (M43)
- [ ] **T-163 48:** Eventos de feedback ASMR en timelines (M44)
- [ ] **T-164 48:** Triggers de partículas en timelines (M52)
- [ ] **T-165 48:** Regla: el evento se emite al frame que lo produce visualmente
- [ ] **T-166 48:** Test de desincronía sonido/impacto
- [ ] **T-167 48:** Burbuja ≤60 actores plenos (M64)
- [ ] **T-168 48:** Fuera de burbuja: idle simplificado o sin animación por distancia
- [ ] **T-169 48:** Blend trees ≤4 nodos por actor
- [ ] **T-170 48:** Pooling de AnimationPlayer (M62)
- [ ] **T-171 48:** Keyframes optimizados sin redundancia (M61)
- [ ] **T-172 48:** Verificar naming anim_[actor]_[estado]
- [ ] **T-173 48:** Verificar fps 30 base / UI 60
- [ ] **T-174 48:** Verificar duración dentro de máximos por categoría
- [ ] **T-175 48:** Verificar T-pose única y bones subset
- [ ] **T-176 48:** Verificar keyframes de evento requeridos
- [ ] **T-177 48:** Definir prefijos anim_, librerías por actor
- [ ] **T-178 48:** Alinear con M108
- [ ] **T-179 48:** Definir suma por escena pivote contra presupuesto M61
- [ ] **T-180 48:** Definir alerta de excedente en editor
- [ ] **T-181 48:** La gameplay llama por ESTADO, no por clip
- [ ] **T-182 48:** Definir fallback idle ante estado sin clip (log WARN)
- [ ] **T-183 48:** Definir señales animation_started/finished/missing
- [ ] **T-184 48:** Prohibir que la capa de animación decida comportamiento
- [ ] **T-185 48:** Rendimiento: burbuja, LOD, pooling, blend trees acotados
- [ ] **T-186 48:** Memoria (M62): bibliotecas compartidas, sin duplicados por escena
- [ ] **T-187 48:** Cozy: movimientos suaves, anticipación corta, follow-through sutil
- [ ] **T-188 48:** Accesible: Reduce Motion en UI (M58)
- [ ] **T-189 48:** Determinismo: mundo procedural sin RNG
- [ ] **T-190 48:** Mantenible: catálogo estado→clip único
- [ ] **T-191 48:** Descartar animación embebida por escena (duplicados)
- [ ] **T-192 48:** Descartar animación 100% por código (calidad)
- [ ] **T-193 48:** Descartar AnimationPlayer global único
- [ ] **T-194 48:** Descartar retargeting genérico en tiempo real
- [ ] **T-195 48:** Descartar blend trees ilimitados
- [ ] **T-196 48:** Descartar animación 2D/impostores para todo el mundo
- [ ] **T-197 48:** Riesgo de clips duplicados → AnimationLibrary central + validación
- [ ] **T-198 48:** Riesgo de snaps por blending → blend 250 ms + revisión visual
- [ ] **T-199 48:** Riesgo de desincronía → eventos en timelines + tests
- [ ] **T-200 48:** Riesgo de coste de huesos → burbuja + LOD + registro
- [ ] **T-201 48:** Riesgo de UI molesta → Reduce Motion + duraciones cortas
- [ ] **T-202 48:** Riesgo de imports inconsistentes → plantilla + validador
- [ ] **T-203 48:** Documentar integración con M11/M19/M36 (FSM)
- [ ] **T-204 48:** Documentar integración con M64/M65 (burbuja)
- [ ] **T-205 48:** Documentar integración con M45 (rigs/sockets)
- [ ] **T-206 48:** Documentar integración con M13 (herramientas)
- [ ] **T-207 48:** Documentar integración con M43/M44/M52 (eventos)
- [ ] **T-208 48:** Documentar integración con M50/M51 (procedural)
- [ ] **T-209 48:** Documentar integración con M21/M53/M58 (UI)
- [ ] **T-210 48:** Documentar integración con M61/M62 (presupuesto)
- [ ] **T-211 48:** Documentar integración con M74 (festivales)
- [ ] **T-212 48:** Documentar integración con M108/M118 (import + CI)
- [ ] **T-213 48:** Documentar flujo de producción de un clip
- [ ] **T-214 48:** Documentar flujo de validación al importar
- [ ] **T-215 48:** Documentar plantilla de import FBX
- [ ] **T-216 48:** 100% de estados FSM de actores cubiertos con animaciones
- [ ] **T-217 48:** Toda mecánica lista tiene animación o "intencional sin animación" definida
- [ ] **T-218 48:** Clips generados con un flujo único y validados sin errores
- [ ] **T-219 48:** Transiciones sin snaps (blend ≤250 ms)
- [ ] **T-220 48:** Sonido y feedback al frame correcto
- [ ] **T-221 48:** Coste de escena pivote dentro del presupuesto M61
- [ ] **T-222 48:** Mundo determinista sin RNG visible
- [ ] **T-223 48:** UI respeta M58 y corre a 60 fps
- [ ] **T-224 48:** Documentar el desfase de numeración del plan maestro (47=ANIMACIÓN → ID 48)

---

## Meta

224 tareas pendientes en total. Trabaja en lotes de 5;
cada lote = 1 log + sync de los 3 registros.

**Si una tarea te supera (scope, contexto, vision):** dejala `[?]` con
dueno y explicacion. **Mejor un `[?]` honesto que un `[x]` falso** (DoD §21.6).
