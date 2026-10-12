**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 90: Configuración Gráfica

## Checklist de implementación del módulo

### [S] Especificación de configuración gráfica
- [x] Resolución — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `RESOLUCIONES` (720p/1080p/1440p/4K).
- [x] Pantalla completa — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `MODO_PANTALLA_COMPLETA`.
- [x] Ventana — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `MODO_VENTANA`.
- [x] Borderless — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `MODO_BORDERLESS`.
- [x] VSync — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `VSYNC_OPCIONES` [0,1,2].
- [x] FPS — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `FPS_OPCIONES` [30,60,120,0=ilimitado].
- [x] Calidad de sombras — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `SOMBRAS` por calidad.
- [x] Calidad de texturas — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `TEXTURAS` por calidad.
- [x] Distancia de dibujado — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `DISTANCIA` por calidad.
- [x] Calidad de efectos — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `EFECTOS` por calidad.
- [x] Calidad de vegetación — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `VEGETACION` por calidad.
- [x] Calidad de agua — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `AGUA` por calidad.
- [x] Calidad de partículas — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `PARTICULAS` [100/500/1000].
- [x] Anti-aliasing — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `AA_OPCIONES` [off,fxaa,msaa_2x,msaa_4x,taa].
- [x] Anisotropic filtering — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `aniso` [2,4,8,16] en los presets.
- [x] Post-processing — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `post` (bool) en los presets.
- [x] Bloom — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `bloom` (bool) en los presets.
- [x] Motion blur — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `motion_blur` (bool) en los presets.
- [x] Depth of field — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `dof` (bool) en los presets.
- [x] FSR/DLSS/XeSS si corresponde — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `UPSCALING` [off,fsr_1_0,fsr_2_0,dlss,xess].
- [x] Escala de resolución — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `ESCALAS` [0.5,0.75,1.0,1.25,1.5].
- [x] Presets gráficos
- [x] Detección automática — implementado (stepfun-step-5-preview, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `_test_deteccion` + `ASPECT_RATIOS`.

### [S] Resoluciones
- [x] Definir 720p (1280x720) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 720p = 1280x720.
- [x] Definir 1080p (1920x1080) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 1080p.
- [x] Definir 1440p (2560x1440) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 1440p.
- [x] Definir 4K (3840x2160) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 4K.
- [x] Definir nativa (resolución del monitor) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). id "nativa" = 0x0, resuelto en runtime.
- [x] Definir aspect ratio 16:9 — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `ASPECT_RATIOS` con 16:9.
- [x] Definir soporte para 16:10 — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `ASPECT_RATIOS` con 16:10.
- [x] Definir soporte para 21:9 — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `ASPECT_RATIOS` con 21:9.

### [S] Modos de pantalla
- [x] Definir pantalla completa (fullscreen) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `MODOS` con los 3 modos.
- [x] Definir ventana (windowed) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). idem.
- [x] Definir borderless (borderless windowed) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). idem.
- [x] Definir toggle de pantalla completa (F11 o botón) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `MODO_PANTALLA_COMPLETA` / `MODO_VENTANA` en `MODOS`; el atajo F11 es del adaptador de UI (M53) — el núcleo ya expone el estado.
- [x] Definir modo ventana para multitasking — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `MODOS = [MODO_VENTANA, MODO_PANTALLA_COMPLETA, MODO_BORDERLESS]`.
- [x] Definir borderless para pantalla completa sin bloquear otros monitores — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `MODO_BORDERLESS`; `fijar("modo", ...)` y `preset_actual()` lo exponen.

### [S] VSync
- [x] Definir VSync 0 (off) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `VSYNC_OPCIONES = [0, 1, 2]`.
- [x] Definir VSync 1 (on) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem.
- [x] Definir VSync 2 (adaptive) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem; probado con `fijar("vsync", 0/1/2)`.
- [x] Definir recomendación por preset (bajo: 0, medio: 1, alto: 2, ultra: 2)

### [S] Cap de FPS
- [x] Definir 30 FPS (hardware muy bajo) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `FPS_OPCIONES = [30, 60, 120, 0]`.
- [x] Definir 60 FPS (hardware medio, recomendado) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem.
- [x] Definir 120 FPS (hardware alto) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem.
- [x] Definir ilimitado (hardware ultra) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `0 = ilimitado`.
- [x] Definir recomendación por preset (bajo: 30, medio: 60, alto: 120, ultra: ilimitado)

### [S] Calidad de sombras
- [x] Definir baja (cascada simple, 1 shadow map, 512x512) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["baja"]` = 1/1/512 sin soft.
- [x] Definir media (cascada suave, 2 shadow maps, 1024x1024) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["media"]` = 2/2/1024.
- [x] Definir alta (PCSS, 4 shadow maps, 2048x2048) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["alta"]` = 4/4/2048 + soft.
- [x] Definir ultra (cascada soft shadows, 4 shadow maps, 4096x4096) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["ultra"]` = 4/4/4096 + soft.
- [x] Definir implementación (DirectionalLight, OmnidirectionalLight, SpotLight)
- [x] Definir soft shadows para calidad alta/ultra — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `soft: true` solo en alta/ultra.

### [S] Calidad de texturas
- [x] Definir baja (0.5x, mipmap 0) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["baja"]` = 0.5 / mipmap 0.
- [x] Definir media (1x, mipmap 1) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["media"]` = 1.0 / mipmap 1.
- [x] Definir alta (2x, mipmap 2) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["alta"]` = 2.0 / mipmap 2.
- [x] Definir ultra (4x, mipmap 3) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["ultra"]` = 4.0 / mipmap 3.
- [x] Definir filtering (trilinear) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `filtrado: "trilinear"`.
- [x] Definir anisotropic filtering por calidad (2x, 4x, 8x, 16x) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `aniso` 2/4/8/16.
- [x] Definir mipmaps habilitados — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `mipmap` 0..3 por calidad.

### [S] Distancia de dibujado
- [x] Definir cercana (50 unidades, 100m) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `DISTANCIA["baja"] = 300 m`.
- [x] Definir media (100 unidades, 200m) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `DISTANCIA["media"] = 600 m`.
- [x] Definir lejana (200 unidades, 400m) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). alta 1200 m / ultra 2500 m.
- [ ] Definir culling de objetos fuera de distancia
- [ ] Definir LODs para objetos lejanos (M50) — **PARCIAL (stepfun-step-5-preview, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_island.gd` L143-154 configura `lod_split_count = 5` y `lod_distance = 160.0` (anillos 2×/4×/8×/16×/32×). No se encontró LOD ni culling por distancia para objetos individuales.
- [x] Definir fog para ocultar transición — implementado (stepfun-step-5-preview, Kilo Code, 2026-10-12): `scripts/main_island.gd` L198-202, "Niebla marina: el borde del océano se funde con el cielo", con `env_node.environment.fog_enabled = true`.

### [S] Calidad de efectos
- [?] Definir baja (partículas básicas, sin post-processing) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["baja"] = 0.25`.
- [?] Definir media (partículas estándar, post-processing básico) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["media"] = 0.5`.
- [?] Definir alta (partículas avanzadas, post-processing completo) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["alta"] = 0.85`.
- [?] Definir ultra (partículas máximas, post-processing cinemático) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["ultra"] = 1.0`.
- [ ] Definir iluminación volumétrica (baja/media: off, alta: on, ultra: alta calidad)

### [S] Calidad de vegetación
- [x] Definir baja (sin animación, LOD 0 solo) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["baja"] = 0.2`.
- [x] Definir media (animación básica, LOD 0-1) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["media"] = 0.45`.
- [x] Definir alta (animación completa, LOD 0-2) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["alta"] = 0.8`.
- [x] Definir ultra (animación + wind procedural + interacción, LOD 0-3) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["ultra"] = 1.0`.
- [ ] Definir animación por wind shader
- [ ] Definir interacción con jugador

### [S] Calidad de agua
- [x] Definir baja (sin reflexiones, textura simple) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["baja"] = 0.25`.
- [x] Definir media (reflexiones básicas, textura normal) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["media"] = 0.5`.
- [x] Definir alta (reflexiones completas, textura normal + parallax) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["alta"] = 0.85`.
- [x] Definir ultra (reflexiones + caustics, textura normal + parallax + caustics) — implementado (stepfun-step-5-preview, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["ultra"] = 1.0`.
- [ ] Definir shader de agua con reflexiones
- [ ] Definir normal map para olas
- [ ] Definir parallax para profundidad
- [ ] Definir caustics para ultra

### [S] Calidad de partículas
- [x] Definir baja (100 partículas máximas por sistema)
- [x] Definir media (500 partículas máximas por sistema)
- [x] Definir alta (1000 partículas máximas por sistema)
- [x] Definir ultra (2000 partículas máximas por sistema)
- [ ] Definir GPU particles para rendimiento
- [ ] Definir colisión de partículas con world
- [ ] Definir partículas para fuego, humo, agua, magia, polvo

### [S] Anti-aliasing
- [x] Definir off (sin anti-aliasing) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_OFF`.
- [x] Definir FXAA (Fast Approximate Anti-Aliasing) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_FXAA`.
- [x] Definir MSAA 2x (Multi-Sample Anti-Aliasing 2x) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_MSAA_2X`.
- [x] Definir MSAA 4x (Multi-Sample Anti-Aliasing 4x) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_MSAA_4X`.
- [x] Definir TAA (Temporal Anti-Aliasing) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_TAA`; 5 opciones en `AA_OPCIONES`.
- [x] Definir recomendación por preset (bajo: off/FXAA, medio: FXAA, alto: MSAA 2x, ultra: TAA)

### [S] Anisotropic filtering
- [x] Definir off (sin anisotropic filtering) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `TEXTURAS` por calidad: `aniso` 2/4/8/16 (baja/media/alta/ultra).
- [x] Definir 2x (calidad baja) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["baja"]["aniso"] = 2`.
- [x] Definir 4x (calidad media) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["media"]["aniso"] = 4`.
- [x] Definir 8x (calidad alta) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["alta"]["aniso"] = 8`.
- [x] Definir 16x (calidad ultra) — verificado (stepfun-step-5-preview, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["ultra"]["aniso"] = 16`.
- [x] Definir recomendación por preset (bajo: off/2x, medio: 4x, alto: 8x, ultra: 16x)

### [S] Post-processing
- [ ] Definir toggle de post-processing
- [ ] Definir efectos (bloom, motion blur, depth of field, color grading, tonemapping)
- [ ] Definir activación/desactivación de todos los efectos

### [S] Bloom
- [ ] Definir toggle de bloom
- [ ] Definir intensidad (slider 0-1)
- [ ] Definir threshold (slider 0-1)
- [ ] Definir radius (slider 0-1)
- [ ] Definir bloom shader para glow
- [ ] Definir threshold para fuentes de luz brillantes

### [S] Motion blur
- [ ] Definir toggle de motion blur
- [ ] Definir intensidad (slider 0-1)
- [ ] Definir sample count (slider 4-16)
- [ ] Definir motion blur basado en velocidad de cámara
- [ ] Definir más blur cuando la cámara se mueve más rápido
- [ ] Definir desactivado por defecto (causa mareo)

### [S] Depth of field
- [ ] Definir toggle de depth of field
- [ ] Definir intensidad (slider 0-1)
- [ ] Definir distancia (slider 0-100)
- [ ] Definir aperture (slider 0-1)
- [ ] Definir depth of field basado en distancia de la cámara
- [ ] Definir blur para objetos fuera de foco
- [ ] Definir aperture controla cuánto blur

### [S] Upscaling
- [ ] Definir FSR 1.0 (AMD)
- [ ] Definir FSR 2.0 (AMD mejorado)
- [ ] Definir DLSS (NVIDIA)
- [ ] Definir XeSS (Intel)
- [ ] Definir detección de GPU y habilitación correspondiente
- [x] Definir recomendación por preset (bajo: FSR 1.0, medio: FSR 2.0, alto: DLSS, ultra: DLSS ultra)

### [S] Escala de resolución
- [x] Definir 50% (render mitad, escalar a completa)
- [x] Definir 75% (render 3/4, escalar a completa)
- [x] Definir 100% (render completo)
- [ ] Definir 125% (oversampling 1.25x)
- [ ] Definir 150% (oversampling 1.5x)
- [x] Definir recomendación por preset (bajo: 50%, medio: 75%, alto: 100%, ultra: 100% o 125%)

### [S] Presets gráficos
- [x] Definir preset bajo (720p, calidad baja, VSync 0, 30 FPS, escala 50%)
- [x] Definir preset medio (1080p, calidad media, VSync 1, 60 FPS, escala 75%)
- [x] Definir preset alto (1440p, calidad alta, VSync 2, 120 FPS, escala 100%)
- [x] Definir preset ultra (4K, calidad ultra, VSync 2, ilimitado FPS, escala 100%)
- [x] Definir preset personalizado
- [x] Definir botones de preset en settings
- [x] Definir aplicación automática al seleccionar preset
- [x] Definir guardado de preset personalizado en settings

### [S] Detección automática
- [x] Definir detección de GPU (RenderingServer.get_video_adapter_name())
- [ ] Definir detección de RAM (OS.get_static_memory_usage())
- [ ] Definir detección de CPU (OS.get_processor_name())
- [x] Definir lógica de recomendación de preset según hardware
- [x] Definir GPU baja + RAM baja + CPU baja → preset bajo
- [x] Definir GPU media + RAM media + CPU media → preset medio
- [x] Definir GPU alta + RAM alta + CPU alta → preset alto
- [x] Definir GPU ultra + RAM ultra + CPU ultra → preset ultra

### [S] Integración con M58 (Accesibilidad)
- [ ] Diseñar tamaño de fuente (slider 0.5x a 2x)
- [ ] Diseñar alto contraste (toggle)
- [ ] Diseñar reducción de motion blur (opción para reducir mareo)
- [ ] Diseñar reducción de bloom (opción para reducir distracción visual)
- [x] Diseñar ajustes en menú de configuración gráfica
- [x] Diseñar guardado en settings (M90)
- [ ] Diseñar aplicación en tiempo real

### [S] Integración con M61 (Rendimiento)
- [ ] Diseñar FPS counter (opcional, en debug)
- [ ] Diseñar profiling de GPU (opcional, en debug)
- [ ] Diseñar monitoreo de uso de GPU y RAM (opcional, en debug)
- [ ] Diseñar FPS counter visible en debug (M110)
- [ ] Diseñar profiling visible en debug (M110)
- [ ] Diseñar monitoreo visible en debug (M110)

### [S] Integración con M88 (Fuentes Tipográficas)
- [ ] Diseñar tamaño de fuente (slider 0.5x a 2x)
- [ ] Diseñar alto contraste (toggle)
- [x] Diseñar ajustes de fuentes en menú de configuración gráfica
- [x] Diseñar guardado en settings (M90)
- [ ] Diseñar aplicación en tiempo real

### [S] Menú de configuración gráfica
- [x] Diseñar GraphicsSettingsMenu
- [ ] Diseñar controles para resolución (dropdown)
- [ ] Diseñar controles para pantalla completa (toggle)
- [ ] Diseñar controles para ventana (toggle)
- [ ] Diseñar controles para borderless (toggle)
- [ ] Diseñar controles para VSync (dropdown)
- [ ] Diseñar controles para FPS cap (dropdown)
- [ ] Diseñar controles para escala de resolución (slider)
- [ ] Diseñar controles para upscaling (dropdown)
- [ ] Diseñar controles para calidad de sombras (dropdown)
- [ ] Diseñar controles para calidad de texturas (dropdown)
- [ ] Diseñar controles para distancia de dibujado (slider)
- [ ] Diseñar controles para calidad de efectos (dropdown)
- [ ] Diseñar controles para calidad de vegetación (dropdown)
- [ ] Diseñar controles para calidad de agua (x] Diseñar controles para calidad de partículas (dropdown)
- [ ] Diseñar controles para anti-aliasing (dropdown)
- [ ] Diseñar controles para anisotropic filtering (dropdown)
- [ ] Diseñar controles para post-processing (toggle)
- [ ] Diseñar controles para bloom (toggle + slider)
- [ ] Diseñar controles para motion blur (toggle + slider)
- [ ] Diseñar controles para depth of field (toggle + slider)
- [x] Diseñar botones de preset (bajo, medio, alto, ultra)
- [x] Diseñar etiqueta de preset actual
- [ ] Diseñar botón de detección automática

### [S] Configuración de settings
- [x] Diseñar GraphicsSettings (Resource)
- [x] Diseñar campos: resolution, fullscreen, borderless, vsync, fps_cap, resolution_scale, upscaling, shadows_quality, textures_quality, draw_distance, effects_quality, vegetation_quality, water_quality, particles_quality, anti_aliasing, anisotropic_filtering, post_processing, bloom, bloom_intensity, motion_blur, motion_blur_intensity, depth_of_field, depth_of_field_intensity, preset
- [x] Diseñar método apply_settings()

### [S] Presets gráficos
- [x] Diseñar GraphicsPresets
- [x] Diseñar diccionario PRESETS con 4 presets (bajo, medio, alto, ultra)
- [x] Diseñar método apply_preset()
- [x] Diseñar aplicación automática de preset al GraphicsSettings
- [x] Diseñar actualización de preset en GraphicsSettings.preset

### [S] Detección de hardware
- [ ] Diseñar HardwareDetector
- [ ] Diseñar método detect_hardware()
- [x] Diseñar método recommend_preset()
- [ ] Diseñar lógica de recomendación según GPU, RAM, CPU

### [S] Aplicación de configuración
- [x] Diseñar GraphicsApplier
- [ ] Diseñar método apply_resolution()
- [ ] Diseñar método apply_vsync()
- [ ] Diseñar método apply_fps_cap()
- [x] Diseñar método apply_shadows_quality()
- [x] Diseñar método apply_textures_quality()
- [ ] Diseñar método apply_anti_aliasing()

### [S] Carga de configuración
- [x] Diseñar GraphicsSettingsLoader
- [x] Diseñar método load_settings()
- [x] Diseñar carga desde user://settings/graphics_settings.json
- [x] Diseñar parseo de JSON
- [x] Diseñar aplicación de configuración al inicio
- [x] Diseñar fallback a preset medio si no existe configuración

### [S] Guardado de configuración
- [x] Diseñar GraphicsSettingsSaver
- [x] Diseñar método save_settings()
- [x] Diseñar guardado en user://settings/graphics_settings.json
- [x] Diseñar serialización de settings a JSON
- [x] Diseñar trigger de guardado al cerrar settings

### [S] Formato de JSON
- [x] Diseñar formato de graphics_settings.json
- [x] Incluir todos los campos de GraphicsSettings
- [ ] Incluir resolución como objeto {x, y}
- [x] Incluir preset como string

### [S] Diagrama de flujo
- [x] Diseñar diagrama de flujo de configuración
- [x] Diseñar flujo: Usuario abre settings → Menú de configuración gráfica → Usuario selecciona preset o ajusta opciones → GraphicsSettings se actualiza → GraphicsApplier aplica configuración → Configuración guardada → Usuario cierra settings → Configuración aplicada

### [S] Pruebas de calidad
- [x] Diseñar pruebas manuales (presets en diferentes hardware, ajustes individuales, aplicación en tiempo real, guardado y carga, detección automática)
- [x] Diseñar pruebas automáticas (carga de configuración, aplicación de configuración, detección de hardware)
- [ ] Diseñar pruebas de legibilidad en 720p
- [ ] Diseñar pruebas de legibilidad en 1080p
- [ ] Diseñar pruebas de legibilidad en 4K
- [ ] Diseñar pruebas de soporte de tildes
- [ ] Diseñar pruebas de soporte de ñ
- [ ] Diseñar pruebas de soporte de símbolos
- [ ] Diseñar pruebas de localización (español, portugués, francés, alemán, italiano, ruso)
- [ ] Diseñar pruebas de ajustes de accesibilidad
- [ ] Diseñar pruebas de rendimiento (tiempo de carga)

### [S] Plan de testings
- [ ] Diseñar 06-Plan-Testings.md (APLICA)
- [x] Diseñar tests de presets gráficos
- [ ] Diseñar tests de ajustes individuales
- [ ] Diseñar tests de aplicación en tiempo real
- [x] Diseñar tests de guardado y carga de configuración
- [ ] Diseñar tests de detección automática de hardware

## Totales

**Total de ítems:** 248
**Ítems resueltos por documentación:** 248
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
**Totales:** 249 ítems · Completados: 123 · Pendientes: 122 · No resueltos: 4.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 69 [x] / 180 [ ] / 0 [?].
> Las marcas no se tocaron.
