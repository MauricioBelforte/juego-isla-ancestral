**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 58: Accesibilidad

## 1. Análisis del dominio

La accesibilidad en videojuegos se organiza en cinco grandes áreas. Para cada una se analiza el problema concreto en "Isla Ancestral" y cómo impacta a los jugadores.

### 1.1 Área visual / color

- **Daltonismo:** el mundo voxel y la UI usan paletas de colores (recursos, rarezas, biomas, estado de cultivos). Un jugador con deuteranopia confunde verdes/marrones (vegetación de la isla Aurora); uno con protanopia los rojos/verdes de alertas y rareza de objetos.
- **Guías de referencia:** el contraste de texto debe ser ≥ 4.5:1 (AA) y ≥ 3:1 para elementos gráficos grandes (WCAG 2.2). El gameplay cozy no debe depender de leer colores pequeños a primera vista.
- **Fatiga visual:** el contraste de la UI sobre mundo voxel ruidoso es crítico en sesiones largas; los fondos translúcidos ayudan pero deben poder volverse sólidos.
- **Contexto del juego:** "terreno generado procedimentalmente" (M08/M10) produce regiones de color variado; un filtro único de UI no basta, hay que poder realzar contornos de interactuables también en el mundo.

### 1.2 Área auditiva

- **Pérdida auditiva:** los sonidos no siempre pueden percibirse; los indicios auditivos (insectos raros, cofres cercanos, tormenta entrante, cantos de NPC) requieren equivalente visual.
- **Dependencia del audio en gameplay:** los cambios de estación, el clima y algunos eventos del templo (M26) avisan por sonido; sin alternativa visual el jugador pierde información.
- **Subtítulos:** deben cubrir no solo diálogos sino SFX importantes (M43) y AMSR/feedback (M44). Velocidad, tamaño y fondo deben ser configurables (integra M91).

### 1.3 Área motora

- **Movimiento y puntería:** la pesca (M34) por timing, la minería (M35) por precisión, el combate y la cámara libre exigen retención prolongada de botones y puntería fina; jugadores con temblor o movilidad reducida se frustran.
- **Remapeo:** cada jugador tiene un esquema cómodo distinto; el remapeo completo (M57) es la base, pero accesibilidad añade perfiles predefinidos (una mano, alternancia de mantener).
- **Vibración:** el feedback háptico puede provocar molestias o ser inútil; debe poder desactivarse.
- **Dead zones y sensibilidad:** mandos con drift o precisión reducida necesitan dead zones mayores y sensibilidad ajustable (ya definido en M57, se exporta aquí como accesos directos).

### 1.4 Área cognitiva

- **Ansiedad y estrés:** el combate con presión de tiempo, los timers de pesca y las consecuencias de "perder objetos" excluyen a jugadores con ansiedad o dificultades de procesamiento. El juego es cozy: el modo relajado debe ser la carta de bienvenida.
- **Mareo por movimiento:** el movimiento de cámara, el parallax de biomas y las transiciones de resolución/extión provocan cinetosis. Reducir desplazamiento, sacudidas y motion blur mitiga el mareo sin romper la estética.
- **Carga cognitiva:** objetivos difusos, inventario abrumador y multitud de iconos exigen marcadores claros (M22/M69) y una guía de objetivos fuerte.
- **Recuperación tras error:** la muerte o el fallo no deben borrar progreso de la sesión; el autosave frecuente (RF29) protege a jugadores con tiempo limitado o dificultad para repetir tareas.

### 1.5 Área lectoescritura

- **Dislexia y baja lectura:** los diálogos (M21), la historia (M22/M23) y las descripciones de objetos son el corazón narrativo del juego; deben leerse sin esfuerzo: fuentes legibles (M88), espaciado generoso, frases cortas.
- **Idioma y subtítulos:** el texto grande y los subtítulos con fondo opaco ayudan sin importar el idioma (la traducción es M87).
- **Textos en el mundo:** letreros y placas deben ser opcionalmente sustituibles por diálogo redundante o marcas visuales.

## 2. Análisis de alternativas

| # | Decisión | Alternativas consideradas | Elección y justificación |
|---|---|---|---|
| A1 | Filtros de daltonismo | (a) Filtro matricial sobre la pantalla (fullscreen shader); (b) permutación selectiva de la paleta del juego; (c) solo cambiar etiquetas/iconos | Se elige **filtro matricial en canvas (fullscreen passthrough)** como primario más permutación de paleta de UI como refuerzo: el filtro es barato y funciona en todo el mundo voxel; la permutación de UI refuerza los casos donde el filtro no alcanza. Fallback a `modulate` de nodos raíz si la calidad gráfica es Baja (M90). |
| A2 | Escalado de UI | (a) Escalar el viewport con resolución interna; (b) escalar el nodo raíz de UI; (c) re-flag de estilos por tema | Se elige **(b) escala del nodo raíz de UI de M53** (multiplicador 0.8–2.0): preserva texturas vectoriales y no reimporta assets; el tamaño de fuente se escala por separado según M88, dando dos ejes independientes (layout y texto). |
| A3 | Asistencia de puntería | (a) Autoapuntado total; (b) magnetismo suave con slider; (c) solo agrandar hitboxes | Se elige **(b) slider 0–100 % de magnetismo suave**: quita fricción sin quitar control; 0 % = juego clásico, 100 % = autoapuntado casi total. Hitbox ampliada se suma como refuerzo sutil (M34/M35/M64 sin cambios de core). |
| A4 | Reducción de movimiento | (a) Desactivar todo movimiento de cámara; (b) reducir amplitudes con factor 0–100 %; (c) solo apagar motion blur | Se elige **(b) factor global de reducción 0–100 %** aplicado a shake, parallax, transiciones y motion blur: el jugador conserva la sensación del mundo pero sin estímulos que marean. Modo predefinido "Prevenir mareos" fija el factor en 20 %. |
| A5 | Dificultad relajada | (a) Modo invencible; (b) presets con variables (timers, daño, penalizaciones); (c) sliders individuales | Se eligen **(b) presets + (c) personalización granular**: "Sereno" (sin penalizaciones, timers extendidos), "Estándar" y "Personalizado". Los sistemas de combate/IA se consultan por configuración, no se reescriben (regla de flujos estables del proyecto). |
| A6 | Persistencia | (a) `ConfigFile` de Godot; (b) JSON manual; (c) Resource binario | Se elige **(b) JSON** (`user://accesibilidad/profile.json`): legible, versionable y compatible con el patrón JSON atómico ya usado por M57. Escritura temporal + renombrado atómico y backup. |
| A7 | Subtítulos | (a) Un solo estilo fijo; (b) opciones de tamaño/fondo/velocidad; (c) delegar todo a M91 | Se elige **(b) opciones completas expuestas desde M58** pero implementadas en el SubtitleManager de M91 (no hay duplicación): M58 define el perfil de accesibilidad de subtítulos; M91 renderiza. |
| A8 | Filtro de color de alto contraste | (a) Shader por nodo (muchos materiales); (b) passthrough global con parámetro de contraste/brillo; (c) solo UI | Se elige **(b) passthrough global** con ajuste de contraste, brillo y saturación, más realce de bordes en interactuables (M08/M10) activable: un solo shader, overhead mínimo. |

## 3. Decisiones clave

- **D1 — Transversalidad por configuración:** M58 no toca los sistemas existentes; expone un `AccessibilityProfile` (Resource) que los demás módulos consultan. Esto mantiene estables los flujos ya verificados (M16-flujos estables).
- **D2 — Desacoplamiento UI:** los menús de M53 leen/escriben el perfil a través de `SettingsManager`; ningún script de canvas contiene lógica de accesibilidad (regla 9 del proyecto).
- **D3 — Dos ejes de escala independientes:** escala de layout (nodo raíz UI) y escala de texto (M88) por separado; evita romper layouts al agrandar solo texto.
- **D4 — Atajo global y acceso pre-partida:** el menú de accesibilidad se abre desde la pausa, la pantalla de título y con atajo global (F10 por defecto); el perfil se carga al arranque antes de mostrar el título para que las opciones visuales afecten también el logo/menús.
- **D5 — Redundancia siempre:** ninguna señal (estado, rareza, peligro) depende solo de color o solo de sonido. Regla de diseño permanente que M53/M91 verifican en sus escenas.
- **D6 — Autosave como política de accesibilidad:** autosave cada 5 min + hitos, sin pausas ni pantallas; la política se expone a través de SettingsManager para que M-persistencia la implemente.
- **D7 — Contraste AA como umbral:** los colores de UI nuevos deben cumplir ≥ 4.5:1 texto / ≥ 3:1 elementos grandes; queda como regla de revisión para M53/M88.
- **D8 — TTS como extensión futura:** se expone el evento de "texto leído por accesibilidad" sin implementar síntesis; el costo de agregarla luego es mínimo.

## 4. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Filtros de daltonismo rompen la estética cozy | Preview en vivo + slider de intensidad 0–100 % + reset rápido; intensidad por defecto conservadora. |
| Escalar UI rompe layouts de M53 | El escalado se aplica en el nodo raíz con anclas ya previstas por M53; test de layouts con escalas 80/100/150/200 %. |
| Asistencia de puntería hace "trampa" en pesca/minería | Magnetismo solo hacia el blanco más cercano dentro de un amortiguador; la precisión del jugador sigue importando; 0 % por defecto. |
| Sobrecarga de opciones abruma al jugador | Menú organizado por áreas con subcategorías, descripción de 1 línea por opción y presets ("Todo por defecto", "Prevenir mareos", "Alto contraste"). |
| Persistencia corrupta | Escritura atómica, backup, validación de tipos al cargar y fallback a defaults con aviso. |
| Rendimiento del shader global en máquinas débiles | Passthrough con muestreo simple; en calidad Baja (M90) se reemplaza por `modulate`/efectos de canvas 2D sin shader. |

## 5. Conclusiones

La accesibilidad de "Isla Ancestral" se resuelve como **módulo de configuración transversal**: un perfil único persistido en JSON, aplicado en vivo por un manager global, consumido por M53 (UI), M57 (controles), M88 (fuentes), M90 (gráficos) y M91 (audio/subtítulos). Las cinco áreas tienen opciones específicas, presets de arranque sensatos y la garantía de que ningún dato crítico se comunica por un solo canal sensorial.