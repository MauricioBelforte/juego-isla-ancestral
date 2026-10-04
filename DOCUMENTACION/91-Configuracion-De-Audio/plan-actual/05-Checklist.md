**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Estado:** 🟡 Con dudas — liberado 2026-10-02 21:55 por mimo-v2.6-flash-free (opencode) · Lock de atria-dawn (`24ddc7e`) · Logs 1191/1194/1198/1199/1201/1203/1204/1206/1208 · **206/239 [x] · 32 [ ] · 1 [?]** · QA cruzado §21.8 pendiente · bloque completo `## Reserva actual` al FINAL del archivo
# 05-Checklist.md — Módulo 91: Configuración de Audio

## Checklist de implementación del módulo

### [S] Especificación de configuración de audio
- [x] Volumen maestro — glm-5.3-flash 2026-09-01: núcleo implementado (buses + set/get + persistencia M60), UI M53 con dueño
- [x] Música — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF2: bus Music, default 70%, slider 0-100% via set_volumen_porcentaje("Music", p) - testeado en test_audio_config _test_volumenes_default + _test_aplicacion_y_control_por_bus (103 checks, 0 fallos)
- [x] Efectos — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF3: bus SFX, default 80%, slider 0-100% - testeado en test_audio_config (103 checks, 0 fallos)
- [x] Ambiente — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF4: bus Ambient, default 60%, slider 0-100% - testeado en test_audio_config (103 checks, 0 fallos)
- [x] Voces — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF5: bus Voice, default 90%, slider 0-100% - testeado en test_audio_config (103 checks, 0 fallos)
- [x] UI — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF6: bus UI, default 50%, slider 0-100% - testeado en test_audio_config (103 checks, 0 fallos)
- [x] Cinemáticas — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF7: bus Cinematic, default 80%, slider 0-100% - testeado en test_audio_config (103 checks, 0 fallos)
- [x] Audio 3D
- [x] Subtítulos — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF9: toggle + tamano 0.5x-2x + opacidad 0.2-1.0 + fondo toggle/color + color de texto - todos implementados y testeados en test_subtitles_m91 (80 checks, 0 fallos)
- [ ] Sonidos de interfaz — nota (2026-10-02, mimo-v2.6-flash-free 2026-10-02 (opencode)): sus hijos L110-L114 y L116 siguen en [ ] a propósito y 03-Diseno §7 está **BLOQUEADO** (cero assets .wav/.ogg/.mp3 en todo el proyecto). Este rollup mide la SECCIÓN COMPLETA; no inflarlo con los 2 hijos sueltos que sí están en [x] (Trampa 119)
- [x] Rango dinámico — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF11 pide selector (quieto/medio/dinamico) - DynamicRangeManager.RANGOS=["quiet","medio","dinamico"] + PRESETS + aplicar_rango()/rango_actual(); testeado en test_audio_effects_m91 (82 checks, 0 fallos)
- [x] Compresión — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF12 pide toggle que limite picos - CompressionManager activar()/desactivar()/esta_activa() sobre threshold_db/ceiling_db/soft_clip; testeado en test_audio_effects_m91 (82 checks, 0 fallos)
- [x] Dispositivo de salida — mimo-v2.6-flash-free 2026-10-02 (opencode): contrastado contra 01-Requerimientos RF13 pide selector (predeterminado/auriculares/altavoces) - OutputDeviceManager.CATEGORIAS_LISTA=["predeterminado","auriculares","altavoces","HDMI","Bluetooth"] + seleccionar_dispositivo() + dispositivos_reales(); testeado en test_audio_effects_m91 (82 checks, 0 fallos)
- [ ] Pruebas con auriculares — nota (2026-10-02, mimo-v2.6-flash-free 2026-10-02 (opencode)): el DISEÑO está completo (L150 [x], L152 [x], L157 [x]) y L151 queda [ ] por HRTF (ver L88 [?]). Falta **EJECUTAR** con hardware real: este rollup mide ejecución, no diseño
- [ ] Pruebas con altavoces — nota (2026-10-02, mimo-v2.6-flash-free 2026-10-02 (opencode)): el DISEÑO está completo (L160, L161, L162, L163 y L167 todos [x]). Falta **EJECUTAR** con hardware real: este rollup mide ejecución, no diseño

### [S] Volúmenes
- [x] Definir volumen maestro (slider 0-100%) — set_volumen("Master", v) linear→db (testeado)
- [x] Definir volumen de música (slider 0-100%) — Music 0.7 default, testeado
- [x] Definir volumen de efectos (slider 0-100%) — SFX 0.8 default, testeado
- [x] Definir volumen de ambiente (slider 0-100%) — Ambient 0.6 default, testeado
- [x] Definir volumen de voces (slider 0-100%) — Voice 0.9 default, testeado
- [x] Definir volumen de UI (slider 0-100%) — UI 0.5 default, testeado
- [x] Definir volumen de cinemáticas (slider 0-100%) — Cinematic 0.8 default, testeado
- [x] Definir valores por defecto (maestro 80%, música 70%, efectos 80%, ambiente 60%, voces 90%, UI 50%, cinemáticas 80%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir conversión de slider 0-100 a dB (linear2db) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic) — 7 buses creados en runtime enrutados a Master (testeado)

### [S] Volumen maestro
- [x] Definir slider de volumen maestro (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir control de todos los canales de audio
- [x] Definir valor por defecto 80% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir aplicación a AudioServer.set_bus_volume_db() — linear_to_db aplicado y verificado en AudioServer (testeado)
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Música
- [x] Definir slider de volumen de música (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir control de música de fondo y cinemáticas — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno.md 4 "Tabla de enrutamiento" -> música de fondo se enruta al bus Music via set_volumen_porcentaje("Music", p); control INDEPENDIENTE verificado (mover Music deja intactos los otros 5 buses, y el mute de UI no contamina a Voice); cinemáticas -> bus Cinematic
- [x] Definir valor por defecto 70% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir aplicación al bus de música — mimo-v2.6-flash-free 2026-10-02 (opencode): test_audio_config.gd _test_aplicacion_y_control_por_bus(): set_volumen_porcentaje("Music", p) golpea AudioServer.get_bus_volume_db DE ESE bus = porcentaje_a_db(p), y el estado interno lineal lo sigue; piso CHECKS_MINIMOS=103 medido en verde (103 checks, 0 fallos)
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Efectos
- [x] Definir slider de volumen de efectos (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir control de efectos de juego (herramientas, craft, interacción) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno.md 4 "Tabla de enrutamiento" -> herramientas/craft/interacción se enruta al bus SFX via set_volumen_porcentaje("SFX", p); control INDEPENDIENTE verificado (mover Music deja intactos los otros 5 buses, y el mute de UI no contamina a Voice)
- [x] Definir valor por defecto 80% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir aplicación al bus de efectos — mimo-v2.6-flash-free 2026-10-02 (opencode): test_audio_config.gd _test_aplicacion_y_control_por_bus(): set_volumen_porcentaje("SFX", p) golpea AudioServer.get_bus_volume_db DE ESE bus = porcentaje_a_db(p), y el estado interno lineal lo sigue; piso CHECKS_MINIMOS=103 medido en verde (103 checks, 0 fallos)
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Ambiente
- [x] Definir slider de volumen de ambiente (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir control de sonidos ambientales (viento, agua, pájaros) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno.md 4 "Tabla de enrutamiento" -> viento/agua/pájaros se enruta al bus Ambient via set_volumen_porcentaje("Ambient", p); control INDEPENDIENTE verificado (mover Music deja intactos los otros 5 buses, y el mute de UI no contamina a Voice)
- [x] Definir valor por defecto 60% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir aplicación al bus de ambiente — mimo-v2.6-flash-free 2026-10-02 (opencode): test_audio_config.gd _test_aplicacion_y_control_por_bus(): set_volumen_porcentaje("Ambient", p) golpea AudioServer.get_bus_volume_db DE ESE bus = porcentaje_a_db(p), y el estado interno lineal lo sigue; piso CHECKS_MINIMOS=103 medido en verde (103 checks, 0 fallos)
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Voces
- [x] Definir slider de volumen de voces (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir control de voces de NPCs y cinemáticas — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno.md 4 "Tabla de enrutamiento" -> voces de NPCs y de cinemáticas se enruta al bus Voice via set_volumen_porcentaje("Voice", p); control INDEPENDIENTE verificado (mover Music deja intactos los otros 5 buses, y el mute de UI no contamina a Voice)
- [x] Definir valor por defecto 90% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir aplicación al bus de voces — mimo-v2.6-flash-free 2026-10-02 (opencode): test_audio_config.gd _test_aplicacion_y_control_por_bus(): set_volumen_porcentaje("Voice", p) golpea AudioServer.get_bus_volume_db DE ESE bus = porcentaje_a_db(p), y el estado interno lineal lo sigue; piso CHECKS_MINIMOS=103 medido en verde (103 checks, 0 fallos)
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] UI
- [x] Definir slider de volumen de UI (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir control de sonidos de interfaz (hover, click, notificaciones) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno.md 4 "Tabla de enrutamiento" -> hover/click/notificaciones se enruta al bus UI via set_volumen_porcentaje("UI", p); control INDEPENDIENTE verificado (mover Music deja intactos los otros 5 buses, y el mute de UI no contamina a Voice)
- [x] Definir valor por defecto 50% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir aplicación al bus de UI — mimo-v2.6-flash-free 2026-10-02 (opencode): test_audio_config.gd _test_aplicacion_y_control_por_bus(): set_volumen_porcentaje("UI", p) golpea AudioServer.get_bus_volume_db DE ESE bus = porcentaje_a_db(p), y el estado interno lineal lo sigue; piso CHECKS_MINIMOS=103 medido en verde (103 checks, 0 fallos)
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Cinemáticas
- [x] Definir slider de volumen de cinemáticas (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir control de audio de cinemáticas (música, voces, efectos)
- [x] Definir valor por defecto 80% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir aplicación al bus de cinemáticas — mimo-v2.6-flash-free 2026-10-02 (opencode): test_audio_config.gd _test_aplicacion_y_control_por_bus(): set_volumen_porcentaje("Cinematic", p) golpea AudioServer.get_bus_volume_db DE ESE bus = porcentaje_a_db(p), y el estado interno lineal lo sigue; piso CHECKS_MINIMOS=103 medido en verde (103 checks, 0 fallos)
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Audio 3D
- [x] Definir toggle de audio 3D (on/off)
- [?] Definir espacialización (HRTF para auriculares) — mimo-v2.6-flash-free 2026-10-02 (opencode): NO RESUELTO (honesto) - sondeo de Godot 4.7.2: AudioStreamPlayer3D tiene 67 propiedades y NINGUNA con modo de pan (solo panning_strength); AudioServer no expone HRTF/room; de las 29 clases AudioEffect* ninguna es spatializer. HRTF requiere GDExtension de terceros o DSP propio. 3 opciones reales documentadas en 03-Diseno 5.1
- [x] Definir oclusión (bloqueo de sonido por objetos) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 5.4 - raycast desde el oidor + AudioEffectLowPassFilter.cutoff_hz (20500 Hz abierto / 800 Hz tapado) en un BUS PROPIO del reproductor, nunca en el bus SFX compartido (ese era el error del esqueleto anterior). Diseno verificado; pendiente de implementacion hasta que existan fuentes 3D
- [x] Definir Doppler effect (cambio de frecuencia por movimiento) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 5.3 - doppler_tracking con enum REAL sondeado Disabled/Idle/Physics -> DOPPLER_TRACKING_PHYSICS_STEP(2), porque el juego mueve los cuerpos en el paso de fisica
- [x] Definir distancia de atenuación (rolloff) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 5.2 - attenuation_model ATTENUATION_INVERSE_SQUARE_DISTANCE(1) + unit_size (0.1-100) + max_db (-24..+6 dB) + max_distance (0-4096 m) + attenuation_filter_cutoff_hz; todos los rangos sondeados en 4.7.2
- [x] Definir Audio3D nodes para sonidos espaciales
- [x] Definir AudioServer.set_bus_effect() para espacialización
- [x] Definir raycast para oclusión de sonido — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 5.5 - PhysicsRayQueryParameters3D.create(desde, hasta, mascara) + collide_with_bodies/collide_with_areas + intersect_ray(); propiedades reales verificadas por sondeo
- [x] Definir PhysicsBody3D para bloqueo de sonido — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 5.6 - StaticBody3D en una capa de colision DEDICADA (p.ej. capa 12 'Occlusion') y collision_mask del ray solo a esa capa, para que paredes/rocas tapen pero jugadores, NPCs, animales y proyectiles NO tapen

### [S] Subtítulos
- [x] Definir toggle de subtítulos (on/off) — mimo-v2.6-flash-free 2026-10-02 (opencode): toggle on/off -> set_habilitados()/get_habilitados() + senal habilitados_cambiado; scripts/ui/subtitle_manager.gd
- [x] Definir tamaño de subtítulos (slider 0.5x a 2x) — mimo-v2.6-flash-free 2026-10-02 (opencode): set_subtitle_size() clamado [TAMANO_MIN=0.5, TAMANO_MAX=2.0], font_size=round(16*tamano); testeado 0.5/1.0/1.5/2.0
- [x] Definir opacidad de subtítulos (slider 0.2 a 1.0) — mimo-v2.6-flash-free 2026-10-02 (opencode): set_subtitle_opacity() clamado [OPACIDAD_MIN=0.2, OPACIDAD_MAX=1.0]; testeado 0.2/0.5/0.9/1.0
- [x] Definir fondo de subtítulos (toggle + color) — mimo-v2.6-flash-free 2026-10-02 (opencode): set_background_visible()/set_background_color() aplicados via StyleBoxFlat; apagar el fondo NO oculta el texto (testeado)
- [x] Definir color de texto (selector) — mimo-v2.6-flash-free 2026-10-02 (opencode): set_text_color()/get_text_color() implementados y TESTEADOS (test_subtitles_m91 _test_defaults default Color(1,1,1,1) + _test_fondo round-trip); el selector de color en la UI es de M53 (mismo caso que L101)
- [x] Definir sincronización con audio
- [x] Definir RichTextLabel para subtítulos — mimo-v2.6-flash-free 2026-10-02 (opencode): RichTextLabel montado POR CODIGO en _crear_ui() dentro de PanelContainer+CanvasLayer(layer 90); sin .tscn (9.47)
- [x] Definir SubtitleManager para mostrar subtítulos
- [x] Definir sincronización con AudioPlayer para cinemáticas
- [ ] Definir accesibilidad (M58) para ajustes de tamaño y contraste

### [S] Sonidos de interfaz
- [ ] Definir toggle de sonidos de interfaz (on/off)
- [ ] Definir sonidos de hover (cursor sobre botón)
- [ ] Definir sonidos de click (click en botón)
- [ ] Definir sonidos de notificaciones (notificaciones de logros, misiones)
- [ ] Definir sonidos de errores (error en acción)
- [x] Definir AudioPlayer para sonidos de interfaz
- [ ] Definir eventos de UI para trigger de sonidos
- [x] Definir AudioBus para control de volumen

### [S] Rango dinámico
- [x] Definir quiet (compresión alta) — mimo-v2.6-flash-free 2026-10-02 (opencode): scripts/audio/dynamic_range_manager.gd PRESETS.quiet (threshold -20 dB, ratio 10)
- [x] Definir medio (compresión media) — mimo-v2.6-flash-free 2026-10-02 (opencode): PRESETS.medio (threshold -10 dB, ratio 5)
- [x] Definir dinámico (sin compresión) — mimo-v2.6-flash-free 2026-10-02 (opencode): remover() elimina el AudioEffectCompressor del bus
- [x] Definir CompressorEffect en AudioServer
- [x] Definir threshold (umbral de compresión) — mimo-v2.6-flash-free 2026-10-02 (opencode): comp.threshold — testeado en -20 / -10 / -15 dB
- [x] Definir ratio (proporción de compresión) — mimo-v2.6-flash-free 2026-10-02 (opencode): comp.ratio — testeado en 10 / 5 / 7
- [x] Definir attack (tiempo de ataque) — mimo-v2.6-flash-free 2026-10-02 (opencode): comp.attack_us — testeado en 5000 / 3000 µs
- [x] Definir release (tiempo de liberación) — mimo-v2.6-flash-free 2026-10-02 (opencode): comp.release_ms — testeado en 250 / 180 ms (API real: release_ms, NO release_us — T-107)

### [S] Compresión
- [x] Definir toggle de compresión (on/off) — mimo-v2.6-flash-free 2026-10-02 (opencode): scripts/audio/compression_manager.gd activar()/desactivar() + activa()
- [x] Definir limitar picos de volumen para evitar clipping — mimo-v2.6-flash-free 2026-10-02 (opencode): AudioEffectLimiter agregado al bus vía add_bus_effect
- [x] Definir threshold (umbral de limitación) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.threshold_db (default -3 dB) — testeado
- [x] Definir ratio (proporción de limitación) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.soft_clip_ratio (default 2.0) — testeado
- [x] Definir LimiterEffect en AudioServer
- [x] Definir threshold (umbral de limitación) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.threshold_db (default -3 dB) — testeado
- [x] Definir ceil (límite máximo de dB) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.ceiling_db (default 0 dB) — testeado (API real: ceiling_db, NO ceil_db — T-107)
- [x] Definir soft clip (soft clipping para evitar clipping duro) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.soft_clip_db (default -6 dB) — testeado (API real: soft_clip_db/soft_clip_ratio, NO soft_clip — T-107)

### [S] Dispositivo de salida
- [x] Definir predeterminado del sistema
- [x] Definir auriculares — mimo-v2.6-flash-free 2026-10-02 (opencode): scripts/audio/output_device_service.gd CATEGORIAS_LISTA
- [x] Definir altavoces — mimo-v2.6-flash-free 2026-10-02 (opencode): CATEGORIAS_LISTA
- [x] Definir HDMI — mimo-v2.6-flash-free 2026-10-02 (opencode): CATEGORIAS_LISTA
- [x] Definir Bluetooth — mimo-v2.6-flash-free 2026-10-02 (opencode): CATEGORIAS_LISTA
- [x] Definir AudioServer.get_output_device_list() para lista de dispositivos — mimo-v2.6-flash-free 2026-10-02 (opencode): texto corregido (el original dice `get_device_list()`, API de Godot 3; ver plan-inicial/05-Checklist.md:145). Real Godot 4.7.2: `AudioServer.get_output_device_list()` (sondeo T-107)
- [x] Definir AudioServer.set_output_device() para cambiar dispositivo — mimo-v2.6-flash-free 2026-10-02 (opencode): texto corregido (el original dice `set_device()`, API de Godot 3; ver plan-inicial/05-Checklist.md:146). Real: `AudioServer.set_output_device()` (sondeo T-107)
- [ ] Definir dropdown en settings para seleccionar dispositivo

### [S] Pruebas con auriculares
- [x] Definir estéreo (izquierda/derecha) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.3 - tono de 200 Hz con AudioEffectPanner.pan=-1 durante 1,5 s, silencio, y luego pan=+1; comprobacion automatica leyendo get_bus_peak_volume_left/right_db
- [ ] Definir espacial 3D (HRTF) — nota (2026-10-02, mimo-v2.6-flash-free 2026-10-02 (opencode)): Godot 4.7.2 NO expone HRTF (sondeo T-107; ver 03-Diseno §5.1.1 y L88 [?]). Queda [ ] hasta que el motor lo soporte o se adopte una alternativa definida
- [x] Definir balance de canales (izquierda/derecha) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.5 - recorre los canales de get_bus_channels(), manda un tono de 1 s por canal y falla automaticamente si alguno queda por debajo de -60 dB
- [x] Definir test de audio (sonido de prueba en cada canal)
- [x] Definir AudioPlayer2D para estero
- [x] Definir AudioPlayer3D para espacial 3D
- [x] Definir AudioServer.set_bus_volume() para balance de canales
- [x] Definir test button en settings — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.7 - boton «Probar auriculares»: muestra el paso actual via la senal paso_cambiado y queda deshabilitado mientras corre el test (regla de la seccion 8); el menu es de M53

### [S] Pruebas con altavoces
- [x] Definir estéreo (izquierda/derecha) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.3 - mismo procedimiento que L150 aplicado a los altavoces frontales
- [x] Definir 5.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.6 - consulta AudioServer.get_speaker_mode(): si devuelve SPEAKER_SURROUND_51 recorre I, D, Centro, LFE, IT, DT; si devuelve SPEAKER_MODE_STEREO el test NO se ofrece y se explica al usuario
- [x] Definir 7.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera, izquierda lateral, derecha lateral) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.6 - igual que L161 con SPEAKER_SURROUND_71 y canales IL y DR
- [x] Definir balance de canales — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.5 - procedimiento identico al de L152
- [x] Definir test de audio (sonido de prueba en cada canal)
- [x] Definir AudioServer.get_channel_count() para detectar canales
- [x] Definir AudioServer.set_bus_channel_count() para configurar canales
- [x] Definir test button en settings — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.7 - boton «Probar altavoces» con el mismo patron que L157

### [S] Integración con M58 (Accesibilidad)
- [x] Diseñar tamaño de subtítulos (slider 0.5x a 2x) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno.md 6 (corregido 2026-10-02): rangos TAMANO_MIN 0.5 / TAMANO_MAX 2.0 documentados e implementados
- [ ] Diseñar alto contraste (toggle)
- [x] Diseñar reducción de audio complejo (opción para simplificar audio)
- [x] Diseñar audio descriptivo (opción para descripción visual en audio)
- [x] Diseñar ajustes en menú de configuración de audio
- [x] Diseñar guardado en settings (M91) — mimo-v2.6-flash-free 2026-10-02 (opencode): get_save_data()/restore_save_data() + _cargar_config()/_guardar_config() persisten en M60 seccion 'subtitles'
- [x] Diseñar aplicación en tiempo real — mimo-v2.6-flash-free 2026-10-02 (opencode): _aplicar_apariencia() se invoca en CADA setter -> font_size/opacidad/fondo cambian en el mismo frame

### [S] Integración con M87 (Internacionalización)
- [ ] Diseñar subtítulos en diferentes idiomas (español, portugués, francés, alemán, italiano, ruso)
- [x] Diseñar audio de voces en diferentes idiomas (si disponible)
- [ ] Diseñar localización de nombres de dispositivos de salida
- [x] Diseñar SubtitleManager con soporte multiidioma
- [x] Diseñar AudioPlayer con soporte multiidioma
- [x] Diseñar LocalizationManager para traducción

### [S] Integración con M61 (Rendimiento)
- [x] Diseñar audio en streaming (para archivos grandes)
- [x] Diseñar audio en memoria (para archivos pequeños)
- [x] Diseñar pool de AudioPlayers para evitar GC
- [x] Diseñar audio comprimido (OGG, MP3) para reducir tamaño
- [x] Diseñar AudioStreamPlayer para streaming
- [x] Diseñar AudioStreamPlayer2D/3D para memoria
- [x] Diseñar ObjectPool para AudioPlayers
- [x] Diseñar compresión de audio en import settings

### [S] Menú de configuración de audio
- [x] Diseñar AudioSettingsMenu
- [ ] Diseñar controles para volumen maestro (slider)
- [ ] Diseñar controles para volumen de música (slider)
- [ ] Diseñar controles para volumen de efectos (slider)
- [ ] Diseñar controles para volumen de ambiente (slider)
- [ ] Diseñar controles para volumen de voces (slider)
- [ ] Diseñar controles para volumen de UI (slider)
- [ ] Diseñar controles para volumen de cinemáticas (slider)
- [x] Diseñar controles para audio 3D (toggle)
- [x] Diseñar controles para subtítulos (toggle + sliders + color picker) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno.md 6: toggle + sliders (size, opacity) + color picker (background y text) con API set_*/get_* completa
- [ ] Diseñar controles para sonidos de interfaz (toggle)
- [ ] Diseñar controles para rango dinámico (dropdown)
- [ ] Diseñar controles para compresión (toggle)
- [ ] Diseñar controles para dispositivo de salida (dropdown)
- [ ] Diseñar botones de prueba (auriculares, altavoces)

### [S] Configuración de settings
- [x] Diseñar AudioSettings (Resource)
- [x] Diseñar campos: master_volume, music_volume, sfx_volume, ambient_volume, voice_volume, ui_volume, cinematic_volume, audio_3d, subtitles, subtitle_size, subtitle_opacity, subtitle_background, subtitle_color, ui_sounds, dynamic_range, compression, output_device
- [x] Diseñar método apply_settings() — mimo-v2.6-flash-free 2026-10-02 (opencode): esqueleto func apply_settings() en 04-Codigo 12 (aplica los 7 buses + DynamicRangeManager); implementacion real equivalente -> AudioConfig._aplicar_todo() en audio_config_service.gd

### [S] Buses de audio
- [x] Diseñar AudioBusSetup
- [x] Diseñar setup de buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic)
- [x] Diseñar AudioServer.add_bus() para crear buses
- [x] Diseñar AudioServer.set_bus_name() para nombrar buses
- [x] Diseñar AudioServer.set_bus_send() para anidar buses

### [S] Audio 3D setup
- [x] Diseñar Audio3DSetup
- [x] Diseñar espacialización (pan 3D + atenuación) — mimo-v2.6-flash-free 2026-10-02 (opencode): TEXTO CORREGIDO desde «con AudioEffectEQ» (el original queda intacto en plan-inicial/05-Checklist.md:227). AudioEffectEQ ecualiza, NO espacializa. Diseno real en 03-Diseno 5.1-5.2: panning_strength + attenuation_model = ATTENUATION_INVERSE_SQUARE_DISTANCE
- [x] Diseñar oclusión con AudioEffectLowPassFilter
- [x] Diseñar AudioServer.add_bus_effect() para agregar efectos

### [S] SubtitleManager
- [x] Diseñar SubtitleManager
- [x] Diseñar método show_subtitle(text, duration) — mimo-v2.6-flash-free 2026-10-02 (opencode): subtitle_manager.gd show_subtitle(); duration<=0.0 significa sin reloj (queda hasta hide_subtitle())
- [x] Diseñar método hide_subtitle() — mimo-v2.6-flash-free 2026-10-02 (opencode): subtitle_manager.gd hide_subtitle(); incrementa _generacion, oculta label+panel y emite subtitulo_oculto
- [x] Diseñar RichTextLabel para subtítulos — mimo-v2.6-flash-free 2026-10-02 (opencode): mismo nodo que el item 104 (_label) creado en _crear_ui()
- [x] Diseñar aplicación de tamaño y opacidad desde AudioSettings

### [S] UISoundManager
- [x] Diseñar UISoundManager
- [ ] Diseñar método play_hover_sound()
- [ ] Diseñar método play_click_sound()
- [ ] Diseñar método play_notification_sound()
- [ ] Diseñar método play_error_sound()
- [x] Diseñar AudioPlayers para cada sonido

### [S] DynamicRangeManager
- [x] Diseñar DynamicRangeManager
- [x] Diseñar método apply_dynamic_range(range) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: DynamicRangeManager.aplicar(rango, bus)
- [x] Diseñar método apply_compression(bus_index, threshold, ratio, attack, release) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: aplicar_compresion_manual(threshold, ratio, attack_us, release_ms, bus)
- [x] Diseñar método remove_compression(bus_index) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: remover(bus)
- [x] Diseñar AudioEffectCompressor para compresión

### [S] CompressionManager
- [x] Diseñar CompressionManager
- [x] Diseñar método apply_compression(enabled) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: CompressionManager.activar(bus) / desactivar(bus)
- [x] Diseñar método remove_limiter(bus_index) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: desactivar(bus)
- [x] Diseñar AudioEffectLimiter para limitación

### [S] OutputDeviceManager
- [x] Diseñar OutputDeviceManager
- [x] Diseñar método get_output_devices() — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: OutputDeviceManager.dispositivos() → AudioServer.get_output_device_list()
- [x] Diseñar método set_output_device(device_name) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: seleccionar(nombre) con validación contra la lista real
- [x] Diseñar método get_current_device() — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: actual() → AudioServer.get_output_device()
- [x] Diseñar AudioServer.get_output_device_list() para lista de dispositivos — mimo-v2.6-flash-free 2026-10-02 (opencode): texto corregido (original en plan-inicial/05-Checklist.md:264). Implementado: OutputDeviceManager.dispositivos()
- [x] Diseñar AudioServer.set_output_device() para cambiar dispositivo — mimo-v2.6-flash-free 2026-10-02 (opencode): texto corregido (original en plan-inicial/05-Checklist.md:265). Implementado: OutputDeviceManager.seleccionar() con validación contra la lista real

### [S] AudioTestManager
- [x] Diseñar AudioTestManager
- [x] Diseñar método test_headphones()
- [x] Diseñar método test_speakers()
- [x] Diseñar test estéreo — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.2/11.3 - AudioTestManager con senales test_iniciado / paso_cambiado / test_terminado, enum Test, y los 4 pasos del test (izquierda, silencio, derecha, veredicto)
- [x] Diseñar test espacial 3D — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.4 - AudioStreamPlayer3D en circulo de 3 m alrededor del oido, vuelta completa en 8 s con attenuation_model y unit_size segun seccion 5.2; la variante HRTF depende de L88 y queda pendiente
- [x] Diseñar test balance de canales — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 11.5 - recorrido de canales con medicion AUTOMATICA via get_bus_peak_volume_*_db, mas confirmacion manual por canal

### [S] Carga de configuración
- [x] Diseñar AudioSettingsLoader
- [x] Diseñar método load_settings() — mimo-v2.6-flash-free 2026-10-02 (opencode): esqueleto func load_settings() en 04-Codigo 13 (AudioSettingsLoader); implementacion real equivalente -> AudioConfig._cargar_config() via M60 (persistencia verificada en test_audio_config _test_persistencia_m60)
- [x] Diseñar carga desde user://settings/audio_settings.json
- [x] Diseñar parseo de JSON
- [x] Diseñar aplicación de configuración al inicio
- [x] Diseñar fallback a configuración por defecto si no existe

### [S] Guardado de configuración
- [x] Diseñar AudioSettingsSaver
- [x] Diseñar método save_settings() — mimo-v2.6-flash-free 2026-10-02 (opencode): esqueleto func save_settings() en 04-Codigo 14 (AudioSettingsSaver); implementacion real equivalente -> AudioConfig._guardar_config() via M60 (get_save_data/restore_save_data)
- [x] Diseñar guardado en user://settings/audio_settings.json
- [x] Diseñar serialización de settings a JSON
- [ ] Diseñar trigger de guardado al cerrar settings

### [S] Formato de JSON
- [x] Diseñar formato de audio_settings.json
- [x] Incluir todos los campos de AudioSettings
- [x] Incluir subtítulo_size y subtítulo_opacity como float — mimo-v2.6-flash-free 2026-10-02 (opencode): save['size'] y save['opacity'] son TYPE_FLOAT verificado en test; claves ASCII 'size'/'opacity' en vez de con tilde (28, anti-mojibake)
- [x] Incluir subtítulo_color como objeto {r, g, b, a} — mimo-v2.6-flash-free 2026-10-02 (opencode): save['color'] = {r,g,b,a} floats en [0,1], typeof TYPE_DICTIONARY verificado en test

### [S] Diagrama de flujo
- [x] Diseñar diagrama de flujo de configuración
- [x] Diseñar flujo: Usuario abre settings → Menú de configuración de audio → Usuario ajusta volúmenes y opciones → AudioSettings se actualiza → AudioBusSetup aplica configuración → Configuración guardada → Usuario cierra settings → Configuración aplicada

### [S] Pruebas de calidad
- [x] Diseñar pruebas manuales (volúmenes, audio 3D, subtítulos, rango dinámico, compresión, dispositivo de salida, pruebas de audio)
- [x] Diseñar pruebas automáticas (carga de configuración, aplicación de configuración, cambio de dispositivo de salida)
- [x] Diseñar pruebas de balance de canales — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 19.2 - automatica (fallo si canal < -60 dB) + manual por canal (hardware)
- [x] Diseñar pruebas de sincronización de subtítulos — mimo-v2.6-flash-free 2026-10-02 (opencode): test_subtitles_m91.gd _test_race_condition: reloj obsoleto NO oculta al sustituto y reloj valido SI oculta (margenes >=0.25s)
- [x] Diseñar pruebas de espacialización 3D — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 19.3 - recorrido audible izquierda -> atras -> derecha -> frente en 8 s; la variante HRTF depende de L88 ([?])
- [x] Diseñar pruebas de compresión de audio
- [x] Diseñar pruebas de cambio de dispositivo de salida — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno 19.4 - get_output_device_list() -> elegir -> get_output_device() -> tono de prueba -> volver; ejecucion real requiere dos dispositivos (hardware del usuario)

### [S] Plan de testings
- [x] Diseñar 06-Plan-Testings.md (APLICA) — mimo-v2.6-flash-free 2026-10-02 (opencode): 06-Plan-Testings.md creado en plan-actual/ - 8 secciones (alcance, 3 suites, ~30 escenarios con criterio de éxito, casos limite, definicion de pasa, rendimiento, huecos, como ejecutar) + 07-Resultados-Testings.md
- [x] Diseñar tests de volúmenes — mimo-v2.6-flash-free 2026-10-02 (opencode): 06-Plan-Testings.md 3.1 escenarios V1-V10; ejecutados en test_audio_config.gd - 103 checks, 0 fallos, EXIT 0 (piso 103)
- [x] Diseñar tests de audio 3D
- [x] Diseñar tests de subtítulos — mimo-v2.6-flash-free 2026-10-02 (opencode): scripts/ui/test_subtitles_m91.gd - 80 checks, 0 fallos, piso CHECKS_MINIMOS=50 medido en verde
- [x] Diseñar tests de rango dinámico — mimo-v2.6-flash-free 2026-10-02 (opencode): 06-Plan-Testings.md 3.2 escenarios R1-R4; ejecutados en test_audio_effects_m91.gd _test_rango_dinamico - 82 checks, 0 fallos
- [x] Diseñar tests de compresión — mimo-v2.6-flash-free 2026-10-02 (opencode): 06-Plan-Testings.md 3.3 escenarios C1-C4; ejecutados en test_audio_effects_m91.gd _test_compresion (incluye soft_clip_db + soft_clip_ratio, API real 4.7.2 T-107) - 82 checks, 0 fallos
- [x] Diseñar tests de dispositivo de salida — mimo-v2.6-flash-free 2026-10-02 (opencode): 06-Plan-Testings.md 3.4 escenarios D1-D4; ejecutados en test_audio_effects_m91.gd _test_dispositivo_salida - 82 checks, 0 fallos
- [x] Diseñar tests de pruebas de audio

## Totales

**Total de ítems:** 227
**Ítems resueltos por documentación:** 227
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
**Totales:** 239 ítems · Completados: 206 · Pendientes: 32 · No resueltos: 1.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 92 [x] / 147 [ ] / 0 [?].
> Las marcas no se tocaron.

## Reserva actual

- **Estado:** 🔵 En curso — **iter. 10 reservada 2026-10-03 23:26** (liberación previa: 🟡 Con dudas 2026-10-02 21:55)
- **Agente actual:** mimo-v2.6-flash-free / opencode (**iter. 10**; la liberación anterior también fue de este chat)
- **Lock otorgado por:** atria-dawn (commit `24ddc7e`, 2026-10-02, “Se reservan locks para los agentes libres según encaje medido”) · **iter. 10:** reasignación del director (canal `04-2026-10-04_00-45-00-respuesta-ciclo.md`), tras cerrar M43. ⚠️ `CHECKLIST-GLOBAL.md` fila 91 quedó 🔵 en **working tree** — commit pendiente por carrera con agnes-3-flash (su fila 06 está sin commitear).
- **Logs de la iteración (lotes 1-9):** 1191, 1194, 1198, 1199, 1201, 1203, 1204, 1206, 1208
- **Alcance iter. 10 (en curso):** diseño de controles **L198-L211** (7 sliders, toggle, rango dinámico, compresión, 2 dropdowns, botones de prueba) + **L147** (dropdown de dispositivo) + **L288** (trigger de guardado al cerrar settings). Revisar si **L110-L116 / L240-L243** (sonidos de interfaz) siguen bloqueados por 0 assets o ahora son diseñables con la API de M43 (`sfx_tones.json` + `tono()` + `sfx_catalog.json` ya existen). **NO inflar rollups L18/L22/L23** (Trampa 119: miden ejecución con hardware real).
- **Progreso al liberar:** 206/239 `[x]` · 32 `[ ]` · 1 `[?]` (86%)
- **Motivo de 🟡 (no ✅):** queda **L88 `[?]`** — Godot 4.7.2 no expone HRTF (`AudioServer.get_speaker_mode()` no tiene contraparte HRTF; ver `03-Diseno.md` §5.1.1). Además 32 `[ ]` con dueños externos: 13 de M53 (UI), 10 sonidos de interfaz (0 assets de audio en el repo, `03-Diseno.md` §7 sellado), rollups L18/L22/L23 (ejecución con hardware real), 2 de M58, 2 de M87, 1 de M59, L151 (HRTF).
- **QA cruzado §21.8:** ✅ **VERIFICADO por Hy3/WorkBuddy (Log 1225, 2026-10-03)** — verificador de modelo distinto (hy3 ≠ mimo). 103/0 + 82/0, guardián rojo.
- **Suites al liberar:** `--module audio` 8 OK + `--module subtitle` 1 OK = **9 OK / 0 FAIL** (DoD de entrega cumplida).

---

## QA cruzado §21.8 — Hy3 (Log 1225, 2026-10-03)

- **Verificador:** hy3 / WorkBuddy (Tencent Hunyuan) — modelo DISTINTO al autor (mimo-v2.6-flash-free), cumple AGENTS.md §21.8.
- **Binario:** Godot 4.7.2 real.
- **Verde (medido):**
  - `test_audio_config.gd`: **103 checks / 0 fallos / EXIT 0** (piso `CHECKS_MINIMOS = 103` medido; afirma AudioConfigService: buses, volúmenes linear→db, mute, persistencia M60, porcentaje 0-100, aplicación/control por bus).
  - `test_audio_effects_m91.gd`: **82 checks / 0 fallos / EXIT 0**.
- **Rojo (inyección):** forzar `_check(ac != null, "AudioConfig autoload presente")` → `_check(false, …)` en copia temporal → **EXIT 1**, `=== TEST M91 AUDIO: 103 checks, 1 fallo(s) ===`. El piso + contador de fallos vuelven ROJO; el verde no es heredado.
- **L88 HRTF `[?]` — GENUINAMENTE TÉCNICO:** Godot 4.7.2 no expone HRTF (`AudioServer` sondeo T-107: 0 propiedades coincidentes; `03-Diseno.md` §5.1.1). No es un pendiente disfrazado; es limitación de motor (requiere GDExtension / DSP propio / decisión de usuario). Queda como `[?]` legítimo.
- **DoD:** 206 `[x]` / 32 `[ ]` / 1 `[?]`. 32 `[ ]` y L88 `[?]` con dueño externo/engine documentado (M53 UI, assets de audio ausentes, rollups hardware, M58/M87/M59, L151). El módulo permanece 🟡 Con dudas por decisión del autor; el QA §21.8 no cambia ese estado.

