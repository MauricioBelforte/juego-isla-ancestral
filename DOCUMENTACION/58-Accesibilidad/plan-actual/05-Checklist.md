**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 58: Accesibilidad

## A. Problema y objetivos (12)

- [ ] Definir el problema: jugadores con discapacidades visuales, auditivas, motoras, cognitivas o de lectura quedan excluidos sin opciones [S]
- [ ] Ubicar M58 como módulo transversal dependiente de M53 (UI-UX) y M57 (Interfaz de Control) [S]
- [ ] Registrar relaciones con M88 (fuentes), M90 (gráficos), M91 (audio/subtítulos) y M87 (traducciones) [S]
- [ ] Definir el objetivo: sistema completo, persistente y aplicable en tiempo real [S]
- [ ] Cubrir las cinco áreas: visual/color, auditiva, motora, cognitiva y lectoescritura [S]
- [ ] Garantizar acceso a las opciones desde el arranque, antes de cargar partida [M]
- [ ] Garantizar navegación del menú por teclado y mando [M]
- [ ] Garantizar que los cambios se apliquen en vivo sin reiniciar el juego [M]
- [ ] Asegurar persistencia del perfil entre sesiones [M]
- [ ] Definir alcance explícito (incluye y excluye) del módulo [S]
- [ ] Declarar restricciones: Godot 4.x, GDScript, sin lógica en capas de UI [S]
- [ ] Redactar criterios de aceptación verificables [S]

## B. RF — Área visual y color (16)

- [ ] RF1: definir los tres perfiles de daltonismo (protanopia, deuteranopia, tritanopia) [S]
- [ ] RF1: diseñar vista previa en vivo del filtro antes de confirmar [M]
- [ ] RF1: definir intensidad del filtro 0–100 % con valor por defecto conservador [M]
- [ ] RF2: definir modo alto contraste ≥ 4.5:1 para texto y ≥ 3:1 para elementos grandes [M]
- [ ] RF2: reforzar bordes y fondos de la UI en modo alto contraste [M]
- [ ] RF3: definir escala de interfaz 80 %–200 % en pasos de 10 % [S]
- [ ] RF4: definir niveles de texto Normal/Grande/Muy grande delegados a M88 [S]
- [ ] RF5: garantizar que ningún dato crítico se comunique solo por color [M]
- [ ] RF6: definir contornos destacados opcionales para objetos interactuables del mundo [M]
- [ ] RF7: definir opacidad configurable de fondos de UI y subtítulos [S]
- [ ] Verificar que el filtro de color cubra el mundo voxel, no solo la UI [C]
- [ ] Definir fallback del filtro para presets gráficos bajos (modulate sin shader) [M]
- [ ] Diseñar preview de color sobre una muestra real del mundo voxel [M]
- [ ] Definir que el estado de recursos/rarezas use icono + color + texto (redundancia) [M]
- [ ] Verificar legibilidad de la UI de M53 con escala 200 % sin cortes [C]
- [ ] Definir aviso de "reset por sección" para no perder todas las opciones al experimentar [S]

## C. RF — Área auditiva (13)

- [ ] RF8: subtítulos activos por defecto en diálogos y eventos ambientales [S]
- [ ] RF8: definir opciones de tamaño, fondo y velocidad de subtítulos (integra M91) [M]
- [ ] RF9: definir indicadores visuales (rizos/anillos) para sonidos no visualizables [M]
- [ ] RF9: cubrir insectos, agua, cofres y cantos de NPC con indicador visual [M]
- [ ] RF10: referenciar los buses de audio de M91 sin duplicar su lógica [S]
- [ ] RF10: definir opción de silenciar ambientes en eventos de diálogo [M]
- [ ] RF11: definir carteles visuales de alertas (baja vida, tormenta, hambre) [M]
- [ ] RF12: auditar que ningún puzzle dependa de oír un sonido específico [C]
- [ ] RF12: definir alternativa visual para las pistas auditivas existentes [M]
- [ ] Definir que los subtítulos cubran SFX importantes (M43) y feedback ASMR (M44) [M]
- [ ] Definir velocidad de subtítulos 0.5x–2x con valor por defecto 1x [S]
- [ ] Definir fondo de subtítulos de opaco a dado y tamaño grande [S]
- [ ] Verificar que los indicadores de audio no produzcan spam visual en sesiones largas [M]

## D. RF — Área motora (17)

- [ ] RF13: consumir la capa de acciones remapeables de M57 (nunca scancodes) [S]
- [ ] RF13: definir perfiles de control accesibles: single_hand y low_mobility [M]
- [ ] RF14: definir modo retención/alternancia por acción (correr, agachar, mirar) [M]
- [ ] RF15: definir asistencia de puntería 0–100 % (pesca, minería, combate) [C]
- [ ] RF15: garantizar 0 % = experiencia clásica sin ninguna corrección [M]
- [ ] RF15: definir magnetismo solo hacia el blanco más cercano dentro de amortiguador [M]
- [ ] RF16: permitir desactivar vibración y feedback háptico por completo [S]
- [ ] RF17: exponer dead zones, sensibilidad por eje e inversión como accesos directos (M57) [M]
- [ ] RF18: pausa inmediata con un único botón desde cualquier estado [M]
- [ ] RF18: garantizar pausa sin diálogos intermedios durante gameplay [S]
- [ ] Definir que los presets de control se carguen y persistan por jugador [M]
- [ ] Definir que el remapeo respete los conflictos detectados por M57 [M]
- [ ] Garantizar que los inputs alternados no penalicen la precisión de puntería [M]
- [ ] Definir latencia de entrada sin degradación frente a la exigencia < 16 ms de M57 [M]
- [ ] Verificar el preset single_hand con las 9 acciones principales del juego [C]
- [ ] Verificar el preset low_mobility con retención mínima de botones [C]
- [ ] Definir indicador visual del perfil de control activo en el menú [S]

## E. RF — Área cognitiva (15)

- [ ] RF19: definir presets de dificultad: Sereno, Estándar y Personalizado [S]
- [ ] RF19: modo Sereno sin combate estresante ni penalizaciones por muerte [M]
- [ ] RF20: timers de pesca y misiones extendidos o eliminados en modo Sereno [M]
- [ ] RF21: modo reducción de movimiento con factor 0–100 % (anti-mareo) [C]
- [ ] RF21: aplicar el factor a shake, parallax, transiciones y motion blur [C]
- [ ] RF21: preset predefinido "Prevenir mareos" con factor 20 % [M]
- [ ] RF22: tutoriales opcionales y pistas de objetivos reforzadas [M]
- [ ] RF22: marcador de dirección del objetivo sin exigir memorizar rutas [M]
- [ ] RF23: diálogos a ritmo del jugador, sin cuenta regresiva [S]
- [ ] RF23: reabrir el último diálogo sin perder contexto [M]
- [ ] Definir que la dificultad sea modificable en cualquier momento, incluso en partida [M]
- [ ] Definir que las opciones cognitivas no alteren la progresión de la historia principal [M]
- [ ] Garantizar que el modo Sereno conserve la economía cozy (sin socavar crafting/recursos) [M]
- [ ] Definir aviso claro al cambiar de dificultad en partida activa [S]
- [ ] Verificar que la reducción de movimiento no rompa la cámara en espacios cerrados (M26) [C]

## F. RF — Área lectoescritura (11)

- [ ] RF24: definir espaciado de texto 0.8–1.5 y line-height 0.9–1.6 [M]
- [ ] RF24: definir selección de estilo de fuente legible (Nunito/Fredoka One de M88) [S]
- [ ] RF25: subtítulos con fondo opaco, tamaño grande y velocidad configurable, activos por defecto [M]
- [ ] RF26: redactar guía de textos críticos con frases cortas y vocabulario simple [M]
- [ ] RF26: definir que las instrucciones clave no exijan lectura veloz [S]
- [ ] RF27: opción "Texto grande" global que escala todos los textos de UI [M]
- [ ] RF27: verificar que el texto grande no desborde diálogos ni inventario (M53) [C]
- [ ] RF28: exponer interfaz/evento de lectura de texto para TTS futuro (sin implementar) [M]
- [ ] Definir que los textos del mundo (letreros) tengan alternativa en diálogo o marca visual [M]
- [ ] Verificar la legibilidad del texto grande con las fuentes de M88 en español (tildes, ñ) [M]
- [ ] Definir que las opciones de lectura apliquen también a subtítulos de eventos sonoros [S]

## G. RN — Rendimiento y compatibilidad (12)

- [ ] NFR: aplicar el perfil con overhead menor a ~1 ms por frame [C]
- [ ] NFR: filtro de color vía shader en canvas sin allocate en _process [M]
- [ ] NFR: fallback modulate en calidad gráfica Baja de M90 [M]
- [ ] NFR: funcionar en Godot 4.x estable sin plugins externos [S]
- [ ] NFR: compatible con Steam Deck y mandos genéricos (via M57) [M]
- [ ] NFR: escritura atómica del JSON con backup [M]
- [ ] NFR: cero errores de consola al entrar en Play Mode [M]
- [ ] NFR: cero advertencias de tipos GDScript en el módulo [M]
- [ ] NFR: debounce de guardado (no escribir en cada tick de slider) [M]
- [ ] NFR: UI del menú navegable 100 % por teclado y mando [M]
- [ ] NFR: textos de ayuda de una línea por opción [S]
- [ ] NFR: documentación 100 % en español y checklist completo antes de delegar [S]

## H. Diseño y arquitectura (17)

- [ ] Diseñar AccessibilityProfile (Resource) con campos por área [M]
- [ ] Diseñar SettingsManager (autoload) como primer autoload del proyecto [M]
- [ ] Diseñar AccessibilityApplier (servicio estático) con aplicación por áreas [M]
- [ ] Diseñar AccessibilityMenuUI como vista pura sin lógica de gameplay [M]
- [ ] Diseñar ColorFilter con shader passthrough + fallback modulate [C]
- [ ] Diseñar MotionReducer que consume amplitudes de M12 [M]
- [ ] Diseñar AimAssist con slider de magnetismo y amortiguador [M]
- [ ] Diseñar InputPresets (single_hand, low_mobility) integrados a M57 [M]
- [ ] Diseñar DifficultyProvider que expone flags a sistemas de juego [M]
- [ ] Diseñar ProfileIO con validación, atomicidad y backup [M]
- [ ] Diseñar señales: profile_loaded, profile_changed, profile_reset [M]
- [ ] Diseñar presets estáticos: DEFAULT, PREVENT_MOTION_SICKNESS, HIGH_CONTRAST, SERENE_MODE, SINGLE_HAND [M]
- [ ] Diseñar el flujo de arranque: boot → load → apply → título [M]
- [ ] Diseñar el flujo de cambio en vivo: UI → SettingsManager → Applier → preview [M]
- [ ] Diseñar la persistencia con versión de perfil (version: 1) para migraciones [M]
- [ ] Diseñar recuperación ante corrupción con backup y aviso único [M]
- [ ] Diseñar el diagrama de estados del perfil (DEFAULT → EDITADO → PERSISTIDO → RECUPERADO) [S]

## I. Integración con M53 y M57 (12)

- [ ] Integrar con M53: pestaña "Accesibilidad" dentro del menú de Opciones [M]
- [ ] Integrar con M53: escalado aplicado al nodo raíz de UI (0.8–2.0) [C]
- [ ] Integrar con M53: foco/navegación del menú con el focus system existente [M]
- [ ] Integrar con M53: previews dentro del menú sin escenas externas [M]
- [ ] Integrar con M57: consumir inputs por nombre de acción [S]
- [ ] Integrar con M57: aplicar remapeo de presets accesibles sobre la capa de acciones [M]
- [ ] Integrar con M57: vibración OFF propagada al sistema de feedback [S]
- [ ] Integrar con M57: dead zones/sensibilidad expuestos como accesos directos en el menú [M]
- [ ] Integrar con M88: tamaños de texto y opciones de lectura sobre el theme [M]
- [ ] Integrar con M91: perfil de subtítulos consumido por SubtitleManager [M]
- [ ] Integrar con M90: fallback del filtro según preset gráfico y desactivar motion blur en modo reducido [M]
- [ ] Integrar con M12: factor motion_reduction aplicado a shake/parallax/transiciones [M]

## J. Edge cases (14)

- [ ] JSON corrupto o ilegible → defaults + aviso único + intento de backup [M]
- [ ] JSON de versión antigua → migración a la versión actual [M]
- [ ] Perfil con valores fuera de rango → coerce a rangos válidos [M]
- [ ] Slider arrastrado rápido → debounce de guardado sin pérdida del último valor [M]
- [ ] Jugador cambia de preset gráfico con filtro activo → aplicar fallback correcto sin reset [M]
- [ ] Mando desconectado a mitad de sesión → perfil intacto, prompts actualizados por M57 [M]
- [ ] Cambio de escala UI con diálogo abierto → el layout se reajusta sin desbordes [C]
- [ ] Texto grande con inventario lleno (36 slots) → sin elementos cortados [C]
- [ ] Reducción de movimiento en transiciones de escena → duraciones escaladas sin saltos [C]
- [ ] Apertura del menú de accesibilidad durante combate → pausa correcta sin pérdida de estado [M]
- [ ] Persistencia durante autosave simultáneo → escrituras atómicas sin corrupción [C]
- [ ] Focus del teclado perdido al abrir atajo global → restaurado al volver al menú [M]
- [ ] Subtítulos con velocidad 0.5x y diálogo largo → no se acumulan textos superpuestos [M]
- [ ] Cambio de idioma (M87) con perfil activo → textos del menú traducidos sin romper claves [M]

## K. Optimización (9)

- [ ] Aplicar el perfil solo con deltas por área, no reconstruir toda la UI [M]
- [ ] Evitar allocaciones en _process del SettingsManager [M]
- [ ] Shader de color con muestreo único y sin pasadas múltiples [C]
- [ ] Rizos de audio indicadores reutilizados con pooling (sin instancias infinitas) [M]
- [ ] Carteles de alerta con tiempo de vida y fade-out sin tween acumulados [M]
- [ ] Scale de UI aplicado una sola vez por cambio, no por frame [M]
- [ ] Consultas al perfil cacheadas cuando no hay cambios (is_dirty) [M]
- [ ] Escaneo de interactuables para contornos solo en radio cercano al jugador [C]
- [ ] Verificar que M58 no sume draw calls perceptibles en escenas pobladas (M61) [C]

## L. Documentación entregada (9)

- [ ] Crear 01-Requerimientos.md con problema, objetivo, alcance, restricciones, RF y RN [S]
- [ ] Crear 02-Analisis.md con análisis del dominio (5 áreas), alternativas A1–A8 y decisiones D1–D8 [S]
- [ ] Crear 03-Diseno.md con arquitectura, flujos y persistencia [S]
- [ ] Crear 04-Codigo.md con 20 archivos previstos y firmas GDScript [S]
- [ ] Crear 05-Checklist.md con 125+ ítems verificables [S]
- [ ] Marcar los archivos previstos como "Pendiente de implementación" [S]
- [ ] Firmar los documentos con modelo y plataforma [S]
- [ ] Mantener el plan-actual byte a byte idéntico a plan-inicial [S]
- [ ] No modificar archivos fuera de DOCUMENTACION/58-Accesibilidad/ [S]

## M. Testings (16)

- [ ] Planear prueba unitaria de ProfileIO: guardar, cargar, validar y fallback [M]
- [ ] Planear prueba de escritura atómica simulando interrupción a mitad de escritura [C]
- [ ] Planear prueba de coerce de rangos con valores extremos en el JSON [M]
- [ ] Planear prueba de migración de versión 1 del perfil [M]
- [ ] Planear prueba de cambio en vivo de escala UI en el menú de Opciones [M]
- [ ] Planear prueba de filtros de daltonismo comparando matices críticos (SVG/colores del juego) [C]
- [ ] Planear prueba de alto contraste sobre todos los estados de UI de M53 [M]
- [ ] Planear prueba del modo reducción de movimiento en escenas de M12 (shake, parallax) [C]
- [ ] Planear prueba de aim assist en pesca (M34) con slider en 0 %, 50 % y 100 % [C]
- [ ] Planear prueba del preset single_hand sin conflictos con el remapeo de M57 [C]
- [ ] Planear prueba de subtítulos a velocidad 0.5x y 2x con diálogos largos [M]
- [ ] Planear prueba de persistencia: cambiar, reiniciar el juego y verificar el perfil intacto [M]
- [ ] Planear prueba de recuperación ante corrupción del JSON [M]
- [ ] Planear prueba de rendimiento: overhead del perfil en escena poblada con profiler [C]
- [ ] Planear prueba de atajo global F10 desde título, pausa y gameplay [M]
- [ ] Planear prueba de sesión larga (≥ 30 min) verificando los autosaves cada 5 minutos [C]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
## Iteración 1 (2026-09-02 07:20 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `data/accesibilidad/config.json` — config data-driven (tamaño de texto, contraste, daltonismo, reducir efectos/parpadeo, alta visibilidad, sonido visual, subtítulos, sensor respeto, persistencia)
- [x] `scripts/accesibilidad/accesibilidad_schema.gd` — validador (tamaños/contrastes/daltonismos válidos, flags booleanos) + **función de contraste WCAG** (luminancia)
- [x] Test 8/8 OK: config válida + defaults + subtítulos ON + reducción OFF + **contraste medido blanco/fondo oscuro = 15.42 (AAA ≥ 7)** y pasto/arena = 4.94 (legible ≥ 3) + detección de daltonismo inválido
- [?] Aplicar la config a la UI (tamaño/contraste en runtime con M53) — iter 2 (dueño: deepseek-v4-flash-vision-exp)
## Iteración 2 (2026-09-02 18:05 — deepseek-v4-flash-vision-exp)

- [x] AccesibilidadAplicador (factores de escala texto 0.9/1.0/1.25 y contraste 0.7/0.85/1.0) + 3 checks nuevos → 11/11 tests OK
- [?] Aplicación real a la UI (M53) — iter 3
