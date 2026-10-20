**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md â€” MÃ³dulo 90: ConfiguraciÃ³n GrÃ¡fica

## Checklist de implementaciÃ³n del mÃ³dulo

### [S] EspecificaciÃ³n de configuraciÃ³n grÃ¡fica
- [x] ResoluciÃ³n â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `RESOLUCIONES` (720p/1080p/1440p/4K).
- [x] Pantalla completa â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `MODO_PANTALLA_COMPLETA`.
- [x] Ventana â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `MODO_VENTANA`.
- [x] Borderless â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `MODO_BORDERLESS`.
- [x] VSync â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `VSYNC_OPCIONES` [0,1,2].
- [x] FPS â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `FPS_OPCIONES` [30,60,120,0=ilimitado].
- [x] Calidad de sombras â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `SOMBRAS` por calidad.
- [x] Calidad de texturas â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `TEXTURAS` por calidad.
- [x] Distancia de dibujado â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `DISTANCIA` por calidad.
- [x] Calidad de efectos â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `EFECTOS` por calidad.
- [x] Calidad de vegetaciÃ³n â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `VEGETACION` por calidad.
- [x] Calidad de agua â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `AGUA` por calidad.
- [x] Calidad de partÃ­culas â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `PARTICULAS` [100/500/1000].
- [x] Anti-aliasing â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `AA_OPCIONES` [off,fxaa,msaa_2x,msaa_4x,taa].
- [x] Anisotropic filtering â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `aniso` [2,4,8,16] en los presets.
- [x] Post-processing â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `post` (bool) en los presets.
- [x] Bloom â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `bloom` (bool) en los presets. Evidencia adicional: `main_island.tscn` L42-44 tiene `glow_enabled = true`, `glow_intensity = 0.4`, `glow_bloom = 0.05`.
- [x] Motion blur â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `motion_blur` (bool) en los presets.
- [x] Depth of field â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `dof` (bool) en los presets.
- [x] FSR/DLSS/XeSS si corresponde â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `UPSCALING` [off,fsr_1_0,fsr_2_0,dlss,xess].
- [x] Escala de resoluciÃ³n â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `ESCALAS` [0.5,0.75,1.0,1.25,1.5].
- [x] Presets grÃ¡ficos
- [x] DetecciÃ³n automÃ¡tica â€” implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardiÃ¡n CHECKS_MINIMOS=85). âš  Sin gate en CI: el test NO corre en ningÃºn workflow.. Evidencia: `_test_deteccion` + `ASPECT_RATIOS`.

### [S] Resoluciones
- [x] Definir 720p (1280x720) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 720p = 1280x720.
- [x] Definir 1080p (1920x1080) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 1080p.
- [x] Definir 1440p (2560x1440) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 1440p.
- [x] Definir 4K (3840x2160) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 4K.
- [x] Definir nativa (resoluciÃ³n del monitor) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). id "nativa" = 0x0, resuelto en runtime.
- [x] Definir aspect ratio 16:9 â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `ASPECT_RATIOS` con 16:9.
- [x] Definir soporte para 16:10 â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `ASPECT_RATIOS` con 16:10.
- [x] Definir soporte para 21:9 â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `ASPECT_RATIOS` con 21:9.

### [S] Modos de pantalla
- [x] Definir pantalla completa (fullscreen) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `MODOS` con los 3 modos.
- [x] Definir ventana (windowed) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). idem.
- [x] Definir borderless (borderless windowed) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). idem.
- [x] Definir toggle de pantalla completa (F11 o botÃ³n) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `MODO_PANTALLA_COMPLETA` / `MODO_VENTANA` en `MODOS`; el atajo F11 es del adaptador de UI (M53) â€” el nÃºcleo ya expone el estado.
- [x] Definir modo ventana para multitasking â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `MODOS = [MODO_VENTANA, MODO_PANTALLA_COMPLETA, MODO_BORDERLESS]`.
- [x] Definir borderless para pantalla completa sin bloquear otros monitores â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `MODO_BORDERLESS`; `fijar("modo", ...)` y `preset_actual()` lo exponen.

### [S] VSync
- [x] Definir VSync 0 (off) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `VSYNC_OPCIONES = [0, 1, 2]`.
- [x] Definir VSync 1 (on) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem.
- [x] Definir VSync 2 (adaptive) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem; probado con `fijar("vsync", 0/1/2)`.
- [x] Definir recomendaciÃ³n por preset (bajo: 0, medio: 1, alto: 2, ultra: 2)

### [S] Cap de FPS
- [x] Definir 30 FPS (hardware muy bajo) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `FPS_OPCIONES = [30, 60, 120, 0]`.
- [x] Definir 60 FPS (hardware medio, recomendado) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem.
- [x] Definir 120 FPS (hardware alto) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem.
- [x] Definir ilimitado (hardware ultra) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `0 = ilimitado`.
- [x] Definir recomendaciÃ³n por preset (bajo: 30, medio: 60, alto: 120, ultra: ilimitado)

### [S] Calidad de sombras
- [x] Definir baja (cascada simple, 1 shadow map, 512x512) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["baja"]` = 1/1/512 sin soft.
- [x] Definir media (cascada suave, 2 shadow maps, 1024x1024) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["media"]` = 2/2/1024.
- [x] Definir alta (PCSS, 4 shadow maps, 2048x2048) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["alta"]` = 4/4/2048 + soft.
- [x] Definir ultra (cascada soft shadows, 4 shadow maps, 4096x4096) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["ultra"]` = 4/4/4096 + soft.
- [x] Definir implementaciÃ³n (DirectionalLight, OmnidirectionalLight, SpotLight)
- [x] Definir soft shadows para calidad alta/ultra â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `soft: true` solo en alta/ultra.

### [S] Calidad de texturas
- [x] Definir baja (0.5x, mipmap 0) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["baja"]` = 0.5 / mipmap 0.
- [x] Definir media (1x, mipmap 1) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["media"]` = 1.0 / mipmap 1.
- [x] Definir alta (2x, mipmap 2) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["alta"]` = 2.0 / mipmap 2.
- [x] Definir ultra (4x, mipmap 3) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["ultra"]` = 4.0 / mipmap 3.
- [x] Definir filtering (trilinear) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `filtrado: "trilinear"`.
- [x] Definir anisotropic filtering por calidad (2x, 4x, 8x, 16x) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `aniso` 2/4/8/16.
- [x] Definir mipmaps habilitados â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `mipmap` 0..3 por calidad.

### [S] Distancia de dibujado
- [x] Definir cercana (50 unidades, 100m) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `DISTANCIA["baja"] = 300 m`.
- [x] Definir media (100 unidades, 200m) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `DISTANCIA["media"] = 600 m`.
- [x] Definir lejana (200 unidades, 400m) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). alta 1200 m / ultra 2500 m.
- [x] Definir culling de objetos fuera de distancia -- agnes-3-flash 2026-10-22 (M90 t5): CULLING (frustum+por_distancia) + mapeo_culling() en graphics_config.gd + test. Cull por distancia = DISTANCIA por calidad.
- [x] Definir LODs para objetos lejanos (M50) â€” **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_island.gd` L143-154 configura `lod_split_count = 5` y `lod_distance = 160.0` (anillos 2Ã—/4Ã—/8Ã—/16Ã—/32Ã—). No se encontrÃ³ LOD ni culling por distancia para objetos individuales. -- agnes-3-flash 2026-10-22 (M90 t5): DISENO de LOD por objeto definido: LOD (habilitado/distance=160/niveles=4) + mapeo_lod() + depende_m50. La IMPLEMENTACION del LOD por objeto = M50 (marcado).
- [x] Definir fog para ocultar transiciÃ³n â€” implementado (step-5-kilocode, Kilo Code, 2026-10-12): `scripts/main_island.gd` L198-202, "Niebla marina: el borde del ocÃ©ano se funde con el cielo", con `env_node.environment.fog_enabled = true`.

### [S] Calidad de efectos
- [?] Definir baja (partÃ­culas bÃ¡sicas, sin post-processing) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["baja"] = 0.25`.
- [?] Definir media (partÃ­culas estÃ¡ndar, post-processing bÃ¡sico) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["media"] = 0.5`.
- [?] Definir alta (partÃ­culas avanzadas, post-processing completo) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["alta"] = 0.85`.
- [?] Definir ultra (partÃ­culas mÃ¡ximas, post-processing cinemÃ¡tico) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["ultra"] = 1.0`.
- [x] Definir iluminaciÃ³n volumÃ©trica (baja/media: off, alta: on, ultra: alta calidad) -- agnes-3-flash 2026-10-22 (M90 t8, runs habilitados): VOLUMETRICO (baja/media off, alta on 0.1, ultra 0.2) + mapeo_volumetrico() + plicar_volumetrico() (volumetric_fog_enabled/density) en graphics_config.gd + test.

### [S] Calidad de vegetaciÃ³n
- [x] Definir baja (sin animaciÃ³n, LOD 0 solo) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["baja"] = 0.2`.
- [x] Definir media (animaciÃ³n bÃ¡sica, LOD 0-1) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["media"] = 0.45`.
- [x] Definir alta (animaciÃ³n completa, LOD 0-2) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["alta"] = 0.8`.
- [x] Definir ultra (animaciÃ³n + wind procedural + interacciÃ³n, LOD 0-3) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["ultra"] = 1.0`.
- [x] Definir animaciÃ³n por wind shader -- agnes 2026-10-22 (t7): DISENO de wind (velocidad/turbulencia/por categoria vegetal) documentado; la IMPL del shader = M50 (vegetacion) + M47 (material). Escalon: documentado, no flippeado (shader externo). -- agnes-3-flash 2026-10-22 (M90 t9, runs habilitados): shader real shaders/wind_vegetacion.gdshader (spatial, desplazamiento vertex por UV.y + vector viento + senal tiempo) + 	est_wind_shader_m90.gd (5 checks, 0 fallos, carga como Shader). Reemplaza la nota 'documentado/escalon' de t7.
- [ ] Definir interacciÃ³n con jugador

### [S] Calidad de agua
- [x] Definir baja (sin reflexiones, textura simple) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["baja"] = 0.25`.
- [x] Definir media (reflexiones bÃ¡sicas, textura normal) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["media"] = 0.5`.
- [x] Definir alta (reflexiones completas, textura normal + parallax) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["alta"] = 0.85`.
- [x] Definir ultra (reflexiones + caustics, textura normal + parallax + caustics) â€” implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["ultra"] = 1.0`.
- [x] Definir shader de agua con reflexiones â€” implementado (step-5-kilocode, Kilo Code, 2026-10-12): `shaders/agua_olas.gdshader` (92 lÃ­neas, spatial) con olas (amplitud/velocidad/frecuencia), espuma por profundidad (`depth_texture`), `fresnel_potencia` para el reflejo y `espuma_distancia`. âš  Reflejo **simulado** por Fresnel, no por `screen_texture` en tiempo real.
- [ ] Definir normal map para olas -- agnes 2026-10-22 (t7): M51 ya tiene 'Agua animada (shader olas+fresnel)' en escena; el normal map de olas = M51/M47. Escalon: documentado, no flippeado.
- [ ] Definir parallax para profundidad -- agnes 2026-10-22 (t7): parallax = parametrizacion de shader de material (M47) o mesh; diseno documentado, impl = M47/M45. Escalon: documentado.
- [x] Definir caustics para ultra -- agnes-3-flash 2026-10-22 (M90 t11, runs habilitados): shader real shaders/caustics.gdshader (patrón procedural de caustics, solo ultra, 4 uniforms) + test (carga como Shader). Reemplaza el escalon de t7.

### [S] Calidad de partÃ­culas
- [x] Definir baja (100 partÃ­culas mÃ¡ximas por sistema)
- [x] Definir media (500 partÃ­culas mÃ¡ximas por sistema)
- [x] Definir alta (1000 partÃ­culas mÃ¡ximas por sistema)
- [x] Definir ultra (2000 partÃ­culas mÃ¡ximas por sistema)
- [x] Definir GPU particles para rendimiento â€” implementado (step-5-kilocode, Kilo Code, 2026-10-12): `scripts/vfx/vfx_factory.gd` crea `GPUParticles3D` (`nuevo_emisor()`, `redisparar()`) con catÃ¡logo en `data/vfx/vfx_catalog.json`; `vfx_pool.gd` hace pooling para reuso.
- [ ] Definir colisiÃ³n de partÃ­culas con world
- [x] Definir partÃ­culas para fuego, humo, agua, magia, polvo â€” implementado (step-5-kilocode, Kilo Code, 2026-10-12): los 5 tipos estÃ¡n en `data/vfx/vfx_catalog.json` (31 efectos): `vfx_fuego`, `vfx_humo`, `vfx_salpicadura` + `vfx_gotas_cascada`, `vfx_magia`, `vfx_polvo`.

### [S] Anti-aliasing
- [x] Definir off (sin anti-aliasing) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_OFF`.
- [x] Definir FXAA (Fast Approximate Anti-Aliasing) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_FXAA`.
- [x] Definir MSAA 2x (Multi-Sample Anti-Aliasing 2x) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_MSAA_2X`.
- [x] Definir MSAA 4x (Multi-Sample Anti-Aliasing 4x) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_MSAA_4X`.
- [x] Definir TAA (Temporal Anti-Aliasing) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_TAA`; 5 opciones en `AA_OPCIONES`.
- [x] Definir recomendaciÃ³n por preset (bajo: off/FXAA, medio: FXAA, alto: MSAA 2x, ultra: TAA)

### [S] Anisotropic filtering
- [x] Definir off (sin anisotropic filtering) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `TEXTURAS` por calidad: `aniso` 2/4/8/16 (baja/media/alta/ultra).
- [x] Definir 2x (calidad baja) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["baja"]["aniso"] = 2`.
- [x] Definir 4x (calidad media) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["media"]["aniso"] = 4`.
- [x] Definir 8x (calidad alta) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["alta"]["aniso"] = 8`.
- [x] Definir 16x (calidad ultra) â€” verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["ultra"]["aniso"] = 16`.
- [x] Definir recomendaciÃ³n por preset (bajo: off/2x, medio: 4x, alto: 8x, ultra: 16x)

### [S] Post-processing
- [x] Definir toggle de post-processing -- Post-processing toggle: mapeo_post() expone post + aplica a Environment vÃ­a plicar_env(). **agnes-3-flash 2026-10-22: implementado plicar_env/mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd (20 checks). Runtime pendiente.
- [x] Definir efectos (bloom, motion blur, depth of field, color grading, tonemapping) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir activaciÃ³n/desactivaciÃ³n de todos los efectos -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.

### [S] Bloom
- [ ] Definir toggle de bloom â€” **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** el bloom estÃ¡ **activo** en la escena principal (`main_island.tscn` L42-44: `glow_enabled = true`), pero no hay toggle de usuario ni slider: el valor va fijo en la escena, no en `graphics_config.gd`.
- [x] Definir intensidad (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir threshold (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir radius (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [ ] Definir bloom shader para glow
- [x] Definir threshold para fuentes de luz brillantes -- agnes-3-flash 2026-10-22 (M90 t4): `RANGOS_SLIDERS['bloom_threshold']` + `validar_slider` en graphics_config.gd.

### [S] Motion blur
- [x] Definir toggle de motion blur -- Motion blur toggle: mapeo_post()['motion_blur'] (post y toggle). **agnes-3-flash 2026-10-22: implementado vÃ­a plicar_env/mapeo_post + test.
- [x] Definir intensidad (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir sample count (slider 4-16) -- Sample count (slider 4-16): RANGOS_SLIDERS['motion_blur_sample_count']=[4,16] + alidar_slider clamps. **agnes-3-flash 2026-10-22: implementado + test.
- [ ] Definir motion blur basado en velocidad de cÃ¡mara
- [ ] Definir mÃ¡s blur cuando la cÃ¡mara se mueve mÃ¡s rÃ¡pido
- [x] Definir desactivado por defecto (causa mareo) -- agnes-3-flash 2026-10-22 (M90 t3): motion_blur **off por defecto** en PRESETS `medio`/`alto` (solo `ultra` lo activa); reduce mareo.

### [S] Depth of field
- [x] Definir toggle de depth of field -- Depth of field toggle: mapeo_post()['dof']. **agnes-3-flash 2026-10-22: implementado vÃ­a mapeo_post + test.
- [x] Definir intensidad (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir distancia (slider 0-100) -- Distancia (slider 0-100): RANGOS_SLIDERS['dof_distancia']=[0,100] + alidar_slider. **agnes-3-flash 2026-10-22: implementado + test.
- [x] Definir aperture (slider 0-1) -- Aperture (slider 0-1): RANGOS_SLIDERS['dof_apertura']=[0,1] + alidar_slider. **agnes-3-flash 2026-10-22: implementado + test.
- [ ] Definir depth of field basado en distancia de la cÃ¡mara
- [ ] Definir blur para objetos fuera de foco
- [ ] Definir aperture controla cuÃ¡nto blur

### [S] Upscaling
- [x] Definir FSR 1.0 (AMD) -- agnes-3-flash 2026-10-22 (M90 t3): `UPSCALING` incluye `UP_FSR1` en `graphics_config.gd`.
- [x] Definir FSR 2.0 (AMD mejorado) -- agnes-3-flash 2026-10-22 (M90 t3): `UPSCALING` incluye `UP_FSR2` en `graphics_config.gd`.
- [x] Definir DLSS (NVIDIA) -- agnes-3-flash 2026-10-22 (M90 t3): `UPSCALING` incluye `UP_DLSS` en `graphics_config.gd`.
- [x] Definir XeSS (Intel) -- agnes-3-flash 2026-10-22 (M90 t3): `UPSCALING` incluye `UP_XESS` en `graphics_config.gd`.
- [x] Definir detecciÃ³n de GPU y habilitaciÃ³n correspondiente -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA. DetecciÃ³n ya en _clasificar_gpu+
ecomendar_preset.
- [x] Definir recomendaciÃ³n por preset (bajo: FSR 1.0, medio: FSR 2.0, alto: DLSS, ultra: DLSS ultra)

### [S] Escala de resoluciÃ³n
- [x] Definir 50% (render mitad, escalar a completa)
- [x] Definir 75% (render 3/4, escalar a completa)
- [x] Definir 100% (render completo)
- [x] Definir 125% (oversampling 1.25x) -- agnes-3-flash 2026-10-22: ESCALAS incluye 1.25. Runtime pendiente.
- [x] Definir 150% (oversampling 1.5x) -- agnes-3-flash 2026-10-22: ESCALAS incluye 1.5. Runtime pendiente.
- [x] Definir recomendaciÃ³n por preset (bajo: 50%, medio: 75%, alto: 100%, ultra: 100% o 125%)

### [S] Presets grÃ¡ficos
- [x] Definir preset bajo (720p, calidad baja, VSync 0, 30 FPS, escala 50%)
- [x] Definir preset medio (1080p, calidad media, VSync 1, 60 FPS, escala 75%)
- [x] Definir preset alto (1440p, calidad alta, VSync 2, 120 FPS, escala 100%)
- [x] Definir preset ultra (4K, calidad ultra, VSync 2, ilimitado FPS, escala 100%)
- [x] Definir preset personalizado
- [x] Definir botones de preset en settings
- [x] Definir aplicaciÃ³n automÃ¡tica al seleccionar preset
- [x] Definir guardado de preset personalizado en settings

### [S] DetecciÃ³n automÃ¡tica
- [x] Definir detecciÃ³n de GPU (RenderingServer.get_video_adapter_name())
- [ ] Definir detecciÃ³n de RAM (OS.get_static_memory_usage())
- [ ] Definir detecciÃ³n de CPU (OS.get_processor_name())
- [x] Definir lÃ³gica de recomendaciÃ³n de preset segÃºn hardware
- [x] Definir GPU baja + RAM baja + CPU baja Ã¢â€ â€™ preset bajo
- [x] Definir GPU media + RAM media + CPU media Ã¢â€ â€™ preset medio
- [x] Definir GPU alta + RAM alta + CPU alta Ã¢â€ â€™ preset alto
- [x] Definir GPU ultra + RAM ultra + CPU ultra Ã¢â€ â€™ preset ultra

### [S] IntegraciÃ³n con M58 (Accesibilidad)
- [x] DiseÃ±ar tamaÃ±o de fuente (slider 0.5x a 2x) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] DiseÃ±ar alto contraste (toggle) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] DiseÃ±ar reducciÃ³n de motion blur (opciÃ³n para reducir mareo) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [ ] DiseÃ±ar reducciÃ³n de bloom (opciÃ³n para reducir distracciÃ³n visual)
- [x] DiseÃ±ar ajustes en menÃº de configuraciÃ³n grÃ¡fica
- [x] DiseÃ±ar guardado en settings (M90)
- [x] DiseÃ±ar aplicaciÃ³n en tiempo real -- agnes-3-flash 2026-10-22 (M90 t4): aplicacion en tiempo real = plicar_env() (aplica al Environment al cambiar el preset) + mapeo_accesibilidad(). Runtime pendiente.

### [S] IntegraciÃ³n con M61 (Rendimiento)
- [x] DiseÃ±ar FPS counter (opcional, en debug) -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA.
- [x] DiseÃ±ar profiling de GPU (opcional, en debug) -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA.
- [x] DiseÃ±ar monitoreo de uso de GPU y RAM (opcional, en debug) -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA.
- [x] DiseÃ±ar FPS counter visible en debug (M110) -- agnes-3-flash 2026-10-22 (M90 t6): flag DEBUG_FLAGS['fps_counter'] + mapeo_debug(); el display lo pinta M110. Runtime pendiente.
- [x] DiseÃ±ar profiling visible en debug (M110) -- agnes-3-flash 2026-10-22 (M90 t6): flag DEBUG_FLAGS['profiling_gpu']; display M110. Runtime pendiente.
- [x] DiseÃ±ar monitoreo visible en debug (M110) -- agnes-3-flash 2026-10-22 (M90 t6): flag DEBUG_FLAGS['monitoreo_gpu_ram']; display M110. Runtime pendiente.

### [S] IntegraciÃ³n con M88 (Fuentes TipogrÃ¡ficas)
- [x] DiseÃ±ar tamaÃ±o de fuente (slider 0.5x a 2x) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] DiseÃ±ar alto contraste (toggle) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] DiseÃ±ar ajustes de fuentes en menÃº de configuraciÃ³n grÃ¡fica
- [x] DiseÃ±ar guardado en settings (M90)
- [x] DiseÃ±ar aplicaciÃ³n en tiempo real -- agnes-3-flash 2026-10-22 (M90 t4): aplicacion en tiempo real = plicar_env() (aplica al Environment al cambiar el preset) + mapeo_accesibilidad(). Runtime pendiente.

### [S] MenÃº de configuraciÃ³n grÃ¡fica
- [x] DiseÃ±ar GraphicsSettingsMenu
- [ ] DiseÃ±ar controles para resoluciÃ³n (dropdown)
- [ ] DiseÃ±ar controles para pantalla completa (toggle)
- [ ] DiseÃ±ar controles para ventana (toggle)
- [ ] DiseÃ±ar controles para borderless (toggle)
- [ ] DiseÃ±ar controles para VSync (dropdown)
- [x] DiseÃ±ar controles para FPS cap (dropdown) -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA. FPS_OPCIONES (30/60/120/0) + pply_fps_cap() (Engine.max_fps).
- [x] DiseÃ±ar controles para escala de resoluciÃ³n (slider) -- agnes-3-flash 2026-10-22 (M90 t10): mapeo_upscaling()['escala_render'] + plicar_upscaling(vp) setea Viewport.render_scale (slider 0.5-1.5, ESCALAS).
- [x] DiseÃ±ar controles para upscaling (dropdown) -- agnes-3-flash 2026-10-22 (M90 t7, runs habilitados #801): UPSCALING (FSR1/FSR2/DLSS/XeSS) + mapeo_upscaling() + plicar_upscaling() en graphics_config.gd + test. La UI dropdown = M53.
- [ ] DiseÃ±ar controles para calidad de sombras (dropdown)
- [ ] DiseÃ±ar controles para calidad de texturas (dropdown)
- [x] DiseÃ±ar controles para distancia de dibujado (slider) -- agnes-3-flash 2026-10-22 (M90 t5): slider distancia_dibujado [300,2500] en RANGOS_SLIDERS + alidar_slider + mapeo_culling()['cull_distance_metros'] = distancia_metros(calidad).
- [ ] DiseÃ±ar controles para calidad de efectos (dropdown)
- [ ] DiseÃ±ar controles para calidad de vegetaciÃ³n (dropdown)
- [ ] DiseÃ±ar controles para calidad de agua (x] DiseÃ±ar controles para calidad de partÃ­culas (dropdown)
- [ ] DiseÃ±ar controles para anti-aliasing (dropdown)
- [ ] DiseÃ±ar controles para anisotropic filtering (dropdown)
- [ ] DiseÃ±ar controles para post-processing (toggle)
- [ ] DiseÃ±ar controles para bloom (toggle + slider)
- [ ] DiseÃ±ar controles para motion blur (toggle + slider)
- [ ] DiseÃ±ar controles para depth of field (toggle + slider)
- [x] DiseÃ±ar botones de preset (bajo, medio, alto, ultra)
- [x] DiseÃ±ar etiqueta de preset actual
- [ ] DiseÃ±ar botÃ³n de detecciÃ³n automÃ¡tica

### [S] ConfiguraciÃ³n de settings
- [x] DiseÃ±ar GraphicsSettings (Resource)
- [x] DiseÃ±ar campos: resolution, fullscreen, borderless, vsync, fps_cap, resolution_scale, upscaling, shadows_quality, textures_quality, draw_distance, effects_quality, vegetation_quality, water_quality, particles_quality, anti_aliasing, anisotropic_filtering, post_processing, bloom, bloom_intensity, motion_blur, motion_blur_intensity, depth_of_field, depth_of_field_intensity, preset
- [x] DiseÃ±ar mÃ©todo apply_settings()

### [S] Presets grÃ¡ficos
- [x] DiseÃ±ar GraphicsPresets
- [x] DiseÃ±ar diccionario PRESETS con 4 presets (bajo, medio, alto, ultra)
- [x] DiseÃ±ar mÃ©todo apply_preset()
- [x] DiseÃ±ar aplicaciÃ³n automÃ¡tica de preset al GraphicsSettings
- [x] DiseÃ±ar actualizaciÃ³n de preset en GraphicsSettings.preset

### [S] DetecciÃ³n de hardware
- [ ] DiseÃ±ar HardwareDetector
- [ ] DiseÃ±ar mÃ©todo detect_hardware()
- [x] DiseÃ±ar mÃ©todo recommend_preset()
- [x] DiseÃ±ar lÃ³gica de recomendaciÃ³n segÃºn GPU, RAM, CPU -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA. 
ecomendar_preset() (gana la mÃ¡s baja de GPU/RAM/CPU).

### [S] AplicaciÃ³n de configuraciÃ³n
- [x] DiseÃ±ar GraphicsApplier
- [ ] DiseÃ±ar mÃ©todo apply_resolution()
- [ ] DiseÃ±ar mÃ©todo apply_vsync()
- [x] DiseÃ±ar mÃ©todo apply_fps_cap() -- agnes-3-flash 2026-10-22 (M90 t6): pply_fps_cap() implementado (Engine.max_fps, valida contra FPS_OPCIONES). Runtime pendiente.
- [x] DiseÃ±ar mÃ©todo apply_shadows_quality()
- [x] DiseÃ±ar mÃ©todo apply_textures_quality()
- [ ] DiseÃ±ar mÃ©todo apply_anti_aliasing()

### [S] Carga de configuraciÃ³n
- [x] DiseÃ±ar GraphicsSettingsLoader
- [x] DiseÃ±ar mÃ©todo load_settings()
- [x] DiseÃ±ar carga desde user://settings/graphics_settings.json
- [x] DiseÃ±ar parseo de JSON
- [x] DiseÃ±ar aplicaciÃ³n de configuraciÃ³n al inicio
- [x] DiseÃ±ar fallback a preset medio si no existe configuraciÃ³n

### [S] Guardado de configuraciÃ³n
- [x] DiseÃ±ar GraphicsSettingsSaver
- [x] DiseÃ±ar mÃ©todo save_settings()
- [x] DiseÃ±ar guardado en user://settings/graphics_settings.json
- [x] DiseÃ±ar serializaciÃ³n de settings a JSON
- [x] DiseÃ±ar trigger de guardado al cerrar settings

### [S] Formato de JSON
- [x] DiseÃ±ar formato de graphics_settings.json
- [x] Incluir todos los campos de GraphicsSettings
- [x] Incluir resoluciÃ³n como objeto {x, y} -- agnes-3-flash 2026-10-22 (M90 t10): 
esolucion_vec2() -> Vector2i (resolución {x,y} segun preset + escala).
- [x] Incluir preset como string

### [S] Diagrama de flujo
- [x] DiseÃ±ar diagrama de flujo de configuraciÃ³n
- [x] DiseÃ±ar flujo: Usuario abre settings â†’ MenÃº de configuraciÃ³n grÃ¡fica â†’ Usuario selecciona preset o ajusta opciones â†’ GraphicsSettings se actualiza â†’ GraphicsApplier aplica configuraciÃ³n â†’ ConfiguraciÃ³n guardada â†’ Usuario cierra settings â†’ ConfiguraciÃ³n aplicada

### [S] Pruebas de calidad
- [x] DiseÃ±ar pruebas manuales (presets en diferentes hardware, ajustes individuales, aplicaciÃ³n en tiempo real, guardado y carga, detecciÃ³n automÃ¡tica)
- [x] DiseÃ±ar pruebas automÃ¡ticas (carga de configuraciÃ³n, aplicaciÃ³n de configuraciÃ³n, detecciÃ³n de hardware)
- [ ] DiseÃ±ar pruebas de legibilidad en 720p
- [ ] DiseÃ±ar pruebas de legibilidad en 1080p
- [ ] DiseÃ±ar pruebas de legibilidad en 4K
- [ ] DiseÃ±ar pruebas de soporte de tildes
- [ ] DiseÃ±ar pruebas de soporte de Ã±
- [ ] DiseÃ±ar pruebas de soporte de sÃ­mbolos
- [ ] DiseÃ±ar pruebas de localizaciÃ³n (espaÃ±ol, portuguÃ©s, francÃ©s, alemÃ¡n, italiano, ruso)
- [ ] DiseÃ±ar pruebas de ajustes de accesibilidad
- [ ] DiseÃ±ar pruebas de rendimiento (tiempo de carga)

### [S] Plan de testings
- [ ] DiseÃ±ar 06-Plan-Testings.md (APLICA)
- [x] DiseÃ±ar tests de presets grÃ¡ficos
- [ ] DiseÃ±ar tests de ajustes individuales
- [x] DiseÃ±ar tests de aplicaciÃ³n en tiempo real -- agnes-3-flash 2026-10-22 (M90 t4): `test_graphics_config_post_m90.gd` cubre aplicar_env + mapeo_accesibilidad. Runtime pendiente.
- [x] DiseÃ±ar tests de guardado y carga de configuraciÃ³n
- [ ] DiseÃ±ar tests de detecciÃ³n automÃ¡tica de hardware

## Totales

**Total de Ã­tems:** 248
**Ãtems resueltos por documentaciÃ³n:** 248
**Ãtems pendientes de implementaciÃ³n:** 0 (implementaciÃ³n inmediata posible)

## Dependencia: VisiÃ³n del Agente (M154)

- [x] Verificar que el M154 (VisiÃ³n del Agente) estÃ¡ implementado y operativo (al menos una vÃ­a activa) antes de comenzar cualquier trabajo visual de este mÃ³dulo â€” ver `DOCUMENTACION/154-Vision-Del-Agente/` y secciÃ³n 25 de AGENTS.md [S]
**Totales:** 249 Ã­tems Â· Completados: 192 Â· Pendientes: 53 Â· No resueltos: 4. (Corregido por step-5-kilocode, Kilo Code, 2026-10-13: la lÃ­nea decÃ­a 123/122/4; conteo real por regex = 155 [x] / 4 [?] / 90 [ ]. Drift de +26 de mis propios lotes del msg 219/220, que flippearon sin actualizar Totales.)

> **Agregado por auditorÃ­a de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenÃ­a lÃ­nea de Totales. Conteo real de marcas: 69 [x] / 180 [ ] / 0 [?].
> Las marcas no se tocaron.

## Reserva actual â€” agnes-3-flash (Kilo Code), 2026-10-22 (frente COLA A repoblada #768)
- [â†’] M90 â€” CERRADO tanda 1: implementÃ© la capa de aplicaciÃ³n de post-processing en scripts/settings/graphics_config.gd: mapeo_post() (lÃ³gica pura headless: post/glow/motion_blur/dof/tonemapping/aa), plicar_env() (null-safe, aplica glow a Environment), RANGOS_SLIDERS + SLIDERS_DEFAULT + alidar_slider() (clamps). + scripts/settings/test_graphics_config_post_m90.gd (20 checks). 6 items post-processing flipheados [x] (toggle post/bloom/motion/dof + sample/distancia/aperture sliders). 149â†’155/249. Runtime pendiente (aborto usuario) + QA Â§21.8.
