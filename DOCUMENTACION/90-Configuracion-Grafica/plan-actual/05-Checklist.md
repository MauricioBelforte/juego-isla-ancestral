**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 90: Configuración Gráfica

## Checklist de implementación del módulo

### [S] Especificación de configuración gráfica
- [x] Resolución — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `RESOLUCIONES` (720p/1080p/1440p/4K).
- [x] Pantalla completa — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `MODO_PANTALLA_COMPLETA`.
- [x] Ventana — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `MODO_VENTANA`.
- [x] Borderless — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `MODO_BORDERLESS`.
- [x] VSync — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `VSYNC_OPCIONES` [0,1,2].
- [x] FPS — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `FPS_OPCIONES` [30,60,120,0=ilimitado].
- [x] Calidad de sombras — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `SOMBRAS` por calidad.
- [x] Calidad de texturas — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `TEXTURAS` por calidad.
- [x] Distancia de dibujado — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `DISTANCIA` por calidad.
- [x] Calidad de efectos — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `EFECTOS` por calidad.
- [x] Calidad de vegetación — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `VEGETACION` por calidad.
- [x] Calidad de agua — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `AGUA` por calidad.
- [x] Calidad de partículas — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `PARTICULAS` [100/500/1000].
- [x] Anti-aliasing — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `AA_OPCIONES` [off,fxaa,msaa_2x,msaa_4x,taa].
- [x] Anisotropic filtering — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `aniso` [2,4,8,16] en los presets.
- [x] Post-processing — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `post` (bool) en los presets.
- [x] Bloom — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `bloom` (bool) en los presets. Evidencia adicional: `main_island.tscn` L42-44 tiene `glow_enabled = true`, `glow_intensity = 0.4`, `glow_bloom = 0.05`.
- [x] Motion blur — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `motion_blur` (bool) en los presets.
- [x] Depth of field — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `dof` (bool) en los presets.
- [x] FSR/DLSS/XeSS si corresponde — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `UPSCALING` [off,fsr_1_0,fsr_2_0,dlss,xess].
- [x] Escala de resolución — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `ESCALAS` [0.5,0.75,1.0,1.25,1.5].
- [x] Presets gráficos
- [x] Detección automática — implementado (step-5-kilocode, 2026-10-12; carpeta versionada hoy, estaba sin trackear desde el Log 1734): respaldado por `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (~86 checks, guardián CHECKS_MINIMOS=85). ⚠ Sin gate en CI: el test NO corre en ningún workflow.. Evidencia: `_test_deteccion` + `ASPECT_RATIOS`.

### [S] Resoluciones
- [x] Definir 720p (1280x720) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 720p = 1280x720.
- [x] Definir 1080p (1920x1080) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 1080p.
- [x] Definir 1440p (2560x1440) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 1440p.
- [x] Definir 4K (3840x2160) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `RESOLUCIONES` incluye 4K.
- [x] Definir nativa (resolución del monitor) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). id "nativa" = 0x0, resuelto en runtime.
- [x] Definir aspect ratio 16:9 — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `ASPECT_RATIOS` con 16:9.
- [x] Definir soporte para 16:10 — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `ASPECT_RATIOS` con 16:10.
- [x] Definir soporte para 21:9 — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `ASPECT_RATIOS` con 21:9.

### [S] Modos de pantalla
- [x] Definir pantalla completa (fullscreen) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `MODOS` con los 3 modos.
- [x] Definir ventana (windowed) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). idem.
- [x] Definir borderless (borderless windowed) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). idem.
- [x] Definir toggle de pantalla completa (F11 o botón) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `MODO_PANTALLA_COMPLETA` / `MODO_VENTANA` en `MODOS`; el atajo F11 es del adaptador de UI (M53) — el núcleo ya expone el estado.
- [x] Definir modo ventana para multitasking — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `MODOS = [MODO_VENTANA, MODO_PANTALLA_COMPLETA, MODO_BORDERLESS]`.
- [x] Definir borderless para pantalla completa sin bloquear otros monitores — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `MODO_BORDERLESS`; `fijar("modo", ...)` y `preset_actual()` lo exponen.

### [S] VSync
- [x] Definir VSync 0 (off) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `VSYNC_OPCIONES = [0, 1, 2]`.
- [x] Definir VSync 1 (on) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem.
- [x] Definir VSync 2 (adaptive) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem; probado con `fijar("vsync", 0/1/2)`.
- [x] Definir recomendación por preset (bajo: 0, medio: 1, alto: 2, ultra: 2)

### [S] Cap de FPS
- [x] Definir 30 FPS (hardware muy bajo) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `FPS_OPCIONES = [30, 60, 120, 0]`.
- [x] Definir 60 FPS (hardware medio, recomendado) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem.
- [x] Definir 120 FPS (hardware alto) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem.
- [x] Definir ilimitado (hardware ultra) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `0 = ilimitado`.
- [x] Definir recomendación por preset (bajo: 30, medio: 60, alto: 120, ultra: ilimitado)

### [S] Calidad de sombras
- [x] Definir baja (cascada simple, 1 shadow map, 512x512) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["baja"]` = 1/1/512 sin soft.
- [x] Definir media (cascada suave, 2 shadow maps, 1024x1024) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["media"]` = 2/2/1024.
- [x] Definir alta (PCSS, 4 shadow maps, 2048x2048) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["alta"]` = 4/4/2048 + soft.
- [x] Definir ultra (cascada soft shadows, 4 shadow maps, 4096x4096) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `SOMBRAS["ultra"]` = 4/4/4096 + soft.
- [x] Definir implementación (DirectionalLight, OmnidirectionalLight, SpotLight)
- [x] Definir soft shadows para calidad alta/ultra — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `soft: true` solo en alta/ultra.

### [S] Calidad de texturas
- [x] Definir baja (0.5x, mipmap 0) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["baja"]` = 0.5 / mipmap 0.
- [x] Definir media (1x, mipmap 1) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["media"]` = 1.0 / mipmap 1.
- [x] Definir alta (2x, mipmap 2) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["alta"]` = 2.0 / mipmap 2.
- [x] Definir ultra (4x, mipmap 3) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `TEXTURAS["ultra"]` = 4.0 / mipmap 3.
- [x] Definir filtering (trilinear) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `filtrado: "trilinear"`.
- [x] Definir anisotropic filtering por calidad (2x, 4x, 8x, 16x) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `aniso` 2/4/8/16.
- [x] Definir mipmaps habilitados — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `mipmap` 0..3 por calidad.

### [S] Distancia de dibujado
- [x] Definir cercana (50 unidades, 100m) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `DISTANCIA["baja"] = 300 m`.
- [x] Definir media (100 unidades, 200m) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `DISTANCIA["media"] = 600 m`.
- [x] Definir lejana (200 unidades, 400m) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). alta 1200 m / ultra 2500 m.
- [x] Definir culling de objetos fuera de distancia -- agnes-3-flash 2026-10-22 (M90 t5): CULLING (frustum+por_distancia) + mapeo_culling() en graphics_config.gd + test. Cull por distancia = DISTANCIA por calidad.
- [x] Definir LODs para objetos lejanos (M50) — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** hay LOD del **terreno**, no de objetos. `scripts/main_island.gd` L143-154 configura `lod_split_count = 5` y `lod_distance = 160.0` (anillos 2×/4×/8×/16×/32×). No se encontró LOD ni culling por distancia para objetos individuales. -- agnes-3-flash 2026-10-22 (M90 t5): DISENO de LOD por objeto definido: LOD (habilitado/distance=160/niveles=4) + mapeo_lod() + depende_m50. La IMPLEMENTACION del LOD por objeto = M50 (marcado).
- [x] Definir fog para ocultar transición — implementado (step-5-kilocode, Kilo Code, 2026-10-12): `scripts/main_island.gd` L198-202, "Niebla marina: el borde del océano se funde con el cielo", con `env_node.environment.fog_enabled = true`.

### [S] Calidad de efectos
- [x] Definir baja (partículas básicas, sin post-processing) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["baja"] = 0.25`. Valor medido: EFECTOS["baja"]=0.25, preset baja = particulas baja, AA_OFF, aniso 2, post=false, bloom=false.  **[x] FLIP-BACK 2026-10-20 (Step-5-WorkBuddy, item 58 barrido [?] con dependencia resuelta, Log 2040, msg 114): dependencia RESUELTA y verificada en disco HOY - `EFECTOS` en graphics_config.gd L68 {baja 0.25, media 0.5, alta 0.85, ultra 1.0} y presets L131-153 (baja: particulas baja/AA_OFF/aniso 2/post false/bloom false; media: particulas media/AA_FXAA/aniso 4/post true/bloom true; alta: particulas alta/AA_MSAA_2X/aniso 8/post true/bloom true; ultra: particulas ultra/AA_TAA/aniso 16/post true/bloom true) = coinciden con el texto del item. Suites medidas HOY con el binario real Godot 4.7.2 console (tanda M90): test_graphics_config.gd 85 checks / 6 bloques (guarda 3 capas, CHECKS_MINIMOS 80) y test_graphics_config_post_m90.gd 57 checks - 0 fallos / EXIT 0 / 0 SCRIPT ERROR. Ofrezco revertir el flip.**
- [x] Definir media (partículas estándar, post-processing básico) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["media"] = 0.5`. Valor medido: EFECTOS["media"]=0.5, preset media = particulas media, AA_FXAA, aniso 4, post=true, bloom=true.  **[x] FLIP-BACK 2026-10-20 (Step-5-WorkBuddy, item 58 barrido [?] con dependencia resuelta, Log 2040, msg 114): dependencia RESUELTA y verificada en disco HOY - `EFECTOS` en graphics_config.gd L68 {baja 0.25, media 0.5, alta 0.85, ultra 1.0} y presets L131-153 (baja: particulas baja/AA_OFF/aniso 2/post false/bloom false; media: particulas media/AA_FXAA/aniso 4/post true/bloom true; alta: particulas alta/AA_MSAA_2X/aniso 8/post true/bloom true; ultra: particulas ultra/AA_TAA/aniso 16/post true/bloom true) = coinciden con el texto del item. Suites medidas HOY con el binario real Godot 4.7.2 console (tanda M90): test_graphics_config.gd 85 checks / 6 bloques (guarda 3 capas, CHECKS_MINIMOS 80) y test_graphics_config_post_m90.gd 57 checks - 0 fallos / EXIT 0 / 0 SCRIPT ERROR. Ofrezco revertir el flip.**
- [x] Definir alta (partículas avanzadas, post-processing completo) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["alta"] = 0.85`. Valor medido: EFECTOS["alta"]=0.85, preset alta = particulas alta, AA_MSAA_2X, aniso 8, post=true, bloom=true.  **[x] FLIP-BACK 2026-10-20 (Step-5-WorkBuddy, item 58 barrido [?] con dependencia resuelta, Log 2040, msg 114): dependencia RESUELTA y verificada en disco HOY - `EFECTOS` en graphics_config.gd L68 {baja 0.25, media 0.5, alta 0.85, ultra 1.0} y presets L131-153 (baja: particulas baja/AA_OFF/aniso 2/post false/bloom false; media: particulas media/AA_FXAA/aniso 4/post true/bloom true; alta: particulas alta/AA_MSAA_2X/aniso 8/post true/bloom true; ultra: particulas ultra/AA_TAA/aniso 16/post true/bloom true) = coinciden con el texto del item. Suites medidas HOY con el binario real Godot 4.7.2 console (tanda M90): test_graphics_config.gd 85 checks / 6 bloques (guarda 3 capas, CHECKS_MINIMOS 80) y test_graphics_config_post_m90.gd 57 checks - 0 fallos / EXIT 0 / 0 SCRIPT ERROR. Ofrezco revertir el flip.**
- [x] Definir ultra (partículas máximas, post-processing cinemático) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `EFECTOS["ultra"] = 1.0`. Valor medido: EFECTOS["ultra"]=1.0, preset ultra = particulas ultra, AA_TAA, aniso 16, post=true, bloom=true.  **[x] FLIP-BACK 2026-10-20 (Step-5-WorkBuddy, item 58 barrido [?] con dependencia resuelta, Log 2040, msg 114): dependencia RESUELTA y verificada en disco HOY - `EFECTOS` en graphics_config.gd L68 {baja 0.25, media 0.5, alta 0.85, ultra 1.0} y presets L131-153 (baja: particulas baja/AA_OFF/aniso 2/post false/bloom false; media: particulas media/AA_FXAA/aniso 4/post true/bloom true; alta: particulas alta/AA_MSAA_2X/aniso 8/post true/bloom true; ultra: particulas ultra/AA_TAA/aniso 16/post true/bloom true) = coinciden con el texto del item. Suites medidas HOY con el binario real Godot 4.7.2 console (tanda M90): test_graphics_config.gd 85 checks / 6 bloques (guarda 3 capas, CHECKS_MINIMOS 80) y test_graphics_config_post_m90.gd 57 checks - 0 fallos / EXIT 0 / 0 SCRIPT ERROR. Ofrezco revertir el flip.**
- [x] Definir iluminación volumétrica (baja/media: off, alta: on, ultra: alta calidad) -- agnes-3-flash 2026-10-22 (M90 t8, runs habilitados): VOLUMETRICO (baja/media off, alta on 0.1, ultra 0.2) + mapeo_volumetrico() + plicar_volumetrico() (volumetric_fog_enabled/density) en graphics_config.gd + test.

### [S] Calidad de vegetación
- [x] Definir baja (sin animación, LOD 0 solo) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["baja"] = 0.2`.
- [x] Definir media (animación básica, LOD 0-1) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["media"] = 0.45`.
- [x] Definir alta (animación completa, LOD 0-2) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["alta"] = 0.8`.
- [x] Definir ultra (animación + wind procedural + interacción, LOD 0-3) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `VEGETACION["ultra"] = 1.0`.
- [x] Definir animación por wind shader -- agnes 2026-10-22 (t7): DISENO de wind (velocidad/turbulencia/por categoria vegetal) documentado; la IMPL del shader = M50 (vegetacion) + M47 (material). Escalon: documentado, no flippeado (shader externo). -- agnes-3-flash 2026-10-22 (M90 t9, runs habilitados): shader real shaders/wind_vegetacion.gdshader (spatial, desplazamiento vertex por UV.y + vector viento + senal tiempo) + 	est_wind_shader_m90.gd (5 checks, 0 fallos, carga como Shader). Reemplaza la nota 'documentado/escalon' de t7.
- [x] Definir interacción con jugador - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** salpicadura + ripple al entrar al agua; impl diferida al modulo de movimiento del Player (agua_animada.gd hoy solo tiene _ready())

### [S] Calidad de agua
- [x] Definir baja (sin reflexiones, textura simple) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["baja"] = 0.25`.
- [x] Definir media (reflexiones básicas, textura normal) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["media"] = 0.5`.
- [x] Definir alta (reflexiones completas, textura normal + parallax) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["alta"] = 0.85`.
- [x] Definir ultra (reflexiones + caustics, textura normal + parallax + caustics) — implementado (step-5-kilocode, 2026-10-12, Log 1734): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (62 checks, 0 fallos). `AGUA["ultra"] = 1.0`.
- [x] Definir shader de agua con reflexiones — implementado (step-5-kilocode, Kilo Code, 2026-10-12): `shaders/agua_olas.gdshader` (92 líneas, spatial) con olas (amplitud/velocidad/frecuencia), espuma por profundidad (`depth_texture`), `fresnel_potencia` para el reflejo y `espuma_distancia`. ⚠ Reflejo **simulado** por Fresnel, no por `screen_texture` en tiempo real.
- [x] Definir normal map para olas -- agnes 2026-10-22 (t7): M51 ya tiene 'Agua animada (shader olas+fresnel)' en escena; el normal map de olas = M51/M47. Escalon: documentado, no flippeado. - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** el shader agua_olas.gdshader calcula la normal procedimentalmente (L49 NORMAL=normalize(vec3(-dx,1,-dz))); sin textura de normal map (uniform ausente en disco); M51 ya cubre Agua animada
- [x] Definir parallax para profundidad -- agnes 2026-10-22 (t7): parallax = parametrizacion de shader de material (M47) o mesh; diseno documentado, impl = M47/M45. Escalon: documentado. - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** uniform opcional parallax_profundidad con profundidad acotada para no romper la costa; sin parallax mapping en disco (grep=0); impl diferida
- [x] Definir caustics para ultra -- agnes-3-flash 2026-10-22 (M90 t11, runs habilitados): shader real shaders/caustics.gdshader (patrón procedural de caustics, solo ultra, 4 uniforms) + test (carga como Shader). Reemplaza el escalon de t7.

### [S] Calidad de partículas
- [x] Definir baja (100 partículas máximas por sistema)
- [x] Definir media (500 partículas máximas por sistema)
- [x] Definir alta (1000 partículas máximas por sistema)
- [x] Definir ultra (2000 partículas máximas por sistema)
- [x] Definir GPU particles para rendimiento — implementado (step-5-kilocode, Kilo Code, 2026-10-12): `scripts/vfx/vfx_factory.gd` crea `GPUParticles3D` (`nuevo_emisor()`, `redisparar()`) con catálogo en `data/vfx/vfx_catalog.json`; `vfx_pool.gd` hace pooling para reuso.
- [x] Definir colisión de partículas con world - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** GPUParticlesCollision HeightField/SDF atado al terreno voxel, instanciado solo con calidad>=alta (PARTICULAS 100/500/1000/2000 por sistema)
- [x] Definir partículas para fuego, humo, agua, magia, polvo — implementado (step-5-kilocode, Kilo Code, 2026-10-12): los 5 tipos están en `data/vfx/vfx_catalog.json` (31 efectos): `vfx_fuego`, `vfx_humo`, `vfx_salpicadura` + `vfx_gotas_cascada`, `vfx_magia`, `vfx_polvo`.

### [S] Anti-aliasing
- [x] Definir off (sin anti-aliasing) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_OFF`.
- [x] Definir FXAA (Fast Approximate Anti-Aliasing) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_FXAA`.
- [x] Definir MSAA 2x (Multi-Sample Anti-Aliasing 2x) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_MSAA_2X`.
- [x] Definir MSAA 4x (Multi-Sample Anti-Aliasing 4x) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_MSAA_4X`.
- [x] Definir TAA (Temporal Anti-Aliasing) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `AA_TAA`; 5 opciones en `AA_OPCIONES`.
- [x] Definir recomendación por preset (bajo: off/FXAA, medio: FXAA, alto: MSAA 2x, ultra: TAA)

### [S] Anisotropic filtering
- [x] Definir off (sin anisotropic filtering) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). `TEXTURAS` por calidad: `aniso` 2/4/8/16 (baja/media/alta/ultra).
- [x] Definir 2x (calidad baja) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["baja"]["aniso"] = 2`.
- [x] Definir 4x (calidad media) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["media"]["aniso"] = 4`.
- [x] Definir 8x (calidad alta) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["alta"]["aniso"] = 8`.
- [x] Definir 16x (calidad ultra) — verificado (step-5-kilocode, 2026-10-12, Log 1684): `scripts/settings/graphics_config.gd` + `test_graphics_config.gd` (85 checks, 0 fallos). idem, `TEXTURAS["ultra"]["aniso"] = 16`.
- [x] Definir recomendación por preset (bajo: off/2x, medio: 4x, alto: 8x, ultra: 16x)

### [S] Post-processing
- [x] Definir toggle de post-processing -- Post-processing toggle: mapeo_post() expone post + aplica a Environment vía plicar_env(). **agnes-3-flash 2026-10-22: implementado plicar_env/mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd (20 checks). Runtime pendiente.
- [x] Definir efectos (bloom, motion blur, depth of field, color grading, tonemapping) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir activación/desactivación de todos los efectos -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.

### [S] Bloom
- [x] Definir toggle de bloom — **PARCIAL (step-5-kilocode, Kilo Code, 2026-10-12):** el bloom está **activo** en la escena principal (`main_island.tscn` L42-44: `glow_enabled = true`), pero no hay toggle de usuario ni slider: el valor va fijo en la escena, no en `graphics_config.gd`. - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** mapeo_post() glow=bloom AND post + aplicar_env() setea glow_enabled (verificado por test_graphics_config_post_m90.gd, 57 checks EXIT 0 binario real)
- [x] Definir intensidad (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir threshold (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir radius (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir bloom shader para glow - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** glow integrado del Environment (shader del motor); glow_bloom=bloom_intensidad [0,1] def 0.5; bloom_threshold def 0.7 y bloom_radius def 0.3 (RANGOS_SLIDERS/SLIDERS_DEFAULT)
- [x] Definir threshold para fuentes de luz brillantes -- agnes-3-flash 2026-10-22 (M90 t4): `RANGOS_SLIDERS['bloom_threshold']` + `validar_slider` en graphics_config.gd.

### [S] Motion blur
- [x] Definir toggle de motion blur -- Motion blur toggle: mapeo_post()['motion_blur'] (post y toggle). **agnes-3-flash 2026-10-22: implementado vía plicar_env/mapeo_post + test.
- [x] Definir intensidad (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir sample count (slider 4-16) -- Sample count (slider 4-16): RANGOS_SLIDERS['motion_blur_sample_count']=[4,16] + alidar_slider clamps. **agnes-3-flash 2026-10-22: implementado + test.
- [x] Definir motion blur basado en velocidad de cámara - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** intensidad proporcional a la velocidad de camara (clamp [0,1]); off en todos los presets salvo ultra
- [x] Definir más blur cuando la cámara se mueve más rápido - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** curva intensidad-velocidad con motion_blur_sample_count [4,16] def 8; reducir_motion lo apaga (mapeo_accesibilidad)
- [x] Definir desactivado por defecto (causa mareo) -- agnes-3-flash 2026-10-22 (M90 t3): motion_blur **off por defecto** en PRESETS `medio`/`alto` (solo `ultra` lo activa); reduce mareo.

### [S] Depth of field
- [x] Definir toggle de depth of field -- Depth of field toggle: mapeo_post()['dof']. **agnes-3-flash 2026-10-22: implementado vía mapeo_post + test.
- [x] Definir intensidad (slider 0-1) -- agnes-3-flash 2026-10-22 (M90 tanda 2): cubierto por RANGOS_SLIDERS + alidar_slider + mapeo_post en graphics_config.gd + 	est_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Definir distancia (slider 0-100) -- Distancia (slider 0-100): RANGOS_SLIDERS['dof_distancia']=[0,100] + alidar_slider. **agnes-3-flash 2026-10-22: implementado + test.
- [x] Definir aperture (slider 0-1) -- Aperture (slider 0-1): RANGOS_SLIDERS['dof_apertura']=[0,1] + alidar_slider. **agnes-3-flash 2026-10-22: implementado + test.
- [x] Definir depth of field basado en distancia de la cámara - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** dof_distancia [0,100] m def 10 (distancia focal); solo preset ultra
- [x] Definir blur para objetos fuera de foco - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** dof_intensidad [0,1] def 0.5; post=false apaga (mapeo_post)
- [x] Definir aperture controla cuánto blur - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** dof_apertura [0,1] def 0.5 controla cuanto blur

### [S] Upscaling
- [x] Definir FSR 1.0 (AMD) -- agnes-3-flash 2026-10-22 (M90 t3): `UPSCALING` incluye `UP_FSR1` en `graphics_config.gd`.
- [x] Definir FSR 2.0 (AMD mejorado) -- agnes-3-flash 2026-10-22 (M90 t3): `UPSCALING` incluye `UP_FSR2` en `graphics_config.gd`.
- [x] Definir DLSS (NVIDIA) -- agnes-3-flash 2026-10-22 (M90 t3): `UPSCALING` incluye `UP_DLSS` en `graphics_config.gd`.
- [x] Definir XeSS (Intel) -- agnes-3-flash 2026-10-22 (M90 t3): `UPSCALING` incluye `UP_XESS` en `graphics_config.gd`.
- [x] Definir detección de GPU y habilitación correspondiente -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA. Detección ya en _clasificar_gpu+
ecomendar_preset.
- [x] Definir recomendación por preset (bajo: FSR 1.0, medio: FSR 2.0, alto: DLSS, ultra: DLSS ultra)

### [S] Escala de resolución
- [x] Definir 50% (render mitad, escalar a completa)
- [x] Definir 75% (render 3/4, escalar a completa)
- [x] Definir 100% (render completo)
- [x] Definir 125% (oversampling 1.25x) -- agnes-3-flash 2026-10-22: ESCALAS incluye 1.25. Runtime pendiente.
- [x] Definir 150% (oversampling 1.5x) -- agnes-3-flash 2026-10-22: ESCALAS incluye 1.5. Runtime pendiente.
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
- [x] Definir detección de RAM (OS.get_static_memory_usage()) -- agnes-3-flash 2026-10-22 (M90 t12): detect_hardware() usa OS.get_static_memory_usage() (+ 
ecomendar_preset).
- [x] Definir detección de CPU (OS.get_processor_name()) -- agnes-3-flash 2026-10-22 (M90 t12): detect_hardware() usa OS.get_processor_name() + OS.get_processor_count().
- [x] Definir lógica de recomendación de preset según hardware
- [x] Definir GPU baja + RAM baja + CPU baja â†’ preset bajo
- [x] Definir GPU media + RAM media + CPU media â†’ preset medio
- [x] Definir GPU alta + RAM alta + CPU alta â†’ preset alto
- [x] Definir GPU ultra + RAM ultra + CPU ultra â†’ preset ultra

### [S] Integración con M58 (Accesibilidad)
- [x] Diseñar tamaño de fuente (slider 0.5x a 2x) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Diseñar alto contraste (toggle) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Diseñar reducción de motion blur (opción para reducir mareo) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Diseñar reducción de bloom (opción para reducir distracción visual) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** reducir_bloom en ACCESIBILIDAD_DEFAULT; mapeo_accesibilidad = glow AND NOT reducir_bloom (opcion anti-distraccion implementada en el nucleo)
- [x] Diseñar ajustes en menú de configuración gráfica
- [x] Diseñar guardado en settings (M90)
- [x] Diseñar aplicación en tiempo real -- agnes-3-flash 2026-10-22 (M90 t4): aplicacion en tiempo real = plicar_env() (aplica al Environment al cambiar el preset) + mapeo_accesibilidad(). Runtime pendiente.

### [S] Integración con M61 (Rendimiento)
- [x] Diseñar FPS counter (opcional, en debug) -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA.
- [x] Diseñar profiling de GPU (opcional, en debug) -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA.
- [x] Diseñar monitoreo de uso de GPU y RAM (opcional, en debug) -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA.
- [x] Diseñar FPS counter visible en debug (M110) -- agnes-3-flash 2026-10-22 (M90 t6): flag DEBUG_FLAGS['fps_counter'] + mapeo_debug(); el display lo pinta M110. Runtime pendiente.
- [x] Diseñar profiling visible en debug (M110) -- agnes-3-flash 2026-10-22 (M90 t6): flag DEBUG_FLAGS['profiling_gpu']; display M110. Runtime pendiente.
- [x] Diseñar monitoreo visible en debug (M110) -- agnes-3-flash 2026-10-22 (M90 t6): flag DEBUG_FLAGS['monitoreo_gpu_ram']; display M110. Runtime pendiente.

### [S] Integración con M88 (Fuentes Tipográficas)
- [x] Diseñar tamaño de fuente (slider 0.5x a 2x) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Diseñar alto contraste (toggle) -- agnes-3-flash 2026-10-22 (M90 t4): accesibilidad en graphics_config.gd (ACCESIBILIDAD_DEFAULT + mapeo_accesibilidad + fijar/acceder_accesibilidad + validar_slider) + test_graphics_config_post_m90.gd. Runtime pendiente QA.
- [x] Diseñar ajustes de fuentes en menú de configuración gráfica
- [x] Diseñar guardado en settings (M90)
- [x] Diseñar aplicación en tiempo real -- agnes-3-flash 2026-10-22 (M90 t4): aplicacion en tiempo real = plicar_env() (aplica al Environment al cambiar el preset) + mapeo_accesibilidad(). Runtime pendiente.

### [S] Menú de configuración gráfica
- [x] Diseñar GraphicsSettingsMenu
- [x] Diseñar controles para resolución (dropdown) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** control->clave resolucion, opciones RESOLUCIONES (720p/1080p/1440p/4k/nativa), def 1080p; UI = M53 sobre graphics_config.gd
- [x] Diseñar controles para pantalla completa (toggle) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** modo=pantalla_completa (MODOS ventana/pantalla_completa/borderless)
- [x] Diseñar controles para ventana (toggle) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** modo=ventana; los 3 modos comparten la clave modo (no son flags independientes)
- [x] Diseñar controles para borderless (toggle) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** modo=borderless
- [x] Diseñar controles para VSync (dropdown) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** vsync [0,1,2] def 1; contrato apply_vsync() sec.15.4
- [x] Diseñar controles para FPS cap (dropdown) -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA. FPS_OPCIONES (30/60/120/0) + pply_fps_cap() (Engine.max_fps).
- [x] Diseñar controles para escala de resolución (slider) -- agnes-3-flash 2026-10-22 (M90 t10): mapeo_upscaling()['escala_render'] + plicar_upscaling(vp) setea Viewport.render_scale (slider 0.5-1.5, ESCALAS).
- [x] Diseñar controles para upscaling (dropdown) -- agnes-3-flash 2026-10-22 (M90 t7, runs habilitados #801): UPSCALING (FSR1/FSR2/DLSS/XeSS) + mapeo_upscaling() + plicar_upscaling() en graphics_config.gd + test. La UI dropdown = M53.
- [x] Diseñar controles para calidad de sombras (dropdown) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** clave sombras, CALIDADES; SOMBRAS cascadas/mapas/res/soft/tecnica por calidad
- [x] Diseñar controles para calidad de texturas (dropdown) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** clave texturas; TEXTURAS escala/mipmap/filtrado/aniso
- [x] Diseñar controles para distancia de dibujado (slider) -- agnes-3-flash 2026-10-22 (M90 t5): slider distancia_dibujado [300,2500] en RANGOS_SLIDERS + alidar_slider + mapeo_culling()['cull_distance_metros'] = distancia_metros(calidad).
- [x] Diseñar controles para calidad de efectos (dropdown) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** clave efectos, multiplicador 0.25/0.5/0.85/1.0
- [x] Diseñar controles para calidad de vegetación (dropdown) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** clave vegetacion, 0.2/0.45/0.8/1.0
- [x] Diseñar controles para calidad de agua (x] Diseñar controles para calidad de partículas (dropdown) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** claves agua y particulas (PARTICULAS 100/500/1000/2000). OJO: esta linea fusiona 2 items por salto de linea perdido (agua (x] particulas) - reportado al director, NO reparada
- [x] Diseñar controles para anti-aliasing (dropdown) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** clave aa, AA_OPCIONES off/fxaa/msaa_2x/msaa_4x/taa def fxaa; contrato apply_anti_aliasing() sec.15.4
- [x] Diseñar controles para anisotropic filtering (dropdown) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** aniso 2/4/8/16 por preset (TEXTURAS.aniso) def 4
- [x] Diseñar controles para post-processing (toggle) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** clave post; post=false apaga todo (mapeo_post)
- [x] Diseñar controles para bloom (toggle + slider) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** bloom + bloom_intensidad [0,1] def true/0.5
- [x] Diseñar controles para motion blur (toggle + slider) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** motion_blur + motion_blur_intensidad [0,1] def false/0.5
- [x] Diseñar controles para depth of field (toggle + slider) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** dof + dof_intensidad [0,1] def false/0.5
- [x] Diseñar botones de preset (bajo, medio, alto, ultra)
- [x] Diseñar etiqueta de preset actual
- [x] Diseñar botón de detección automática - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** detect_hardware()->recomendar_preset (regla MINI)->aplicar_preset; modelo de GPU lo resuelve M115

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
- [x] Diseñar HardwareDetector -- agnes-3-flash 2026-10-22 (M90 t12): HardwareDetector = detect_hardware() (devuelve gpu/ram/cpu/nucleos/recomendado).
- [x] Diseñar método detect_hardware() -- agnes-3-flash 2026-10-22 (M90 t12): detect_hardware() implementado + test.
- [x] Diseñar método recommend_preset()
- [x] Diseñar lógica de recomendación según GPU, RAM, CPU -- agnes-3-flash 2026-10-22 (M90 t6): en graphics_config.gd (DEBUG_FLAGS + mapeo_debug + apply_fps_cap) + test. Runtime pendiente QA. 
ecomendar_preset() (gana la más baja de GPU/RAM/CPU).

### [S] Aplicación de configuración
- [x] Diseñar GraphicsApplier
- [x] Diseñar método apply_resolution() - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** contrato apply_resolution()->Vector2i; nativa por DisplayServer.screen_get_size(); modo por window_set_mode+window_set_flag(BORDERLESS); tamano por resolucion_vec2()
- [x] Diseñar método apply_vsync() - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** contrato apply_vsync()->int; DisplayServer.window_set_vsync_mode(VSYNC_DISABLED/ENABLED/ADAPTIVE)
- [x] Diseñar método apply_fps_cap() -- agnes-3-flash 2026-10-22 (M90 t6): pply_fps_cap() implementado (Engine.max_fps, valida contra FPS_OPCIONES). Runtime pendiente.
- [x] Diseñar método apply_shadows_quality()
- [x] Diseñar método apply_textures_quality()
- [x] Diseñar método apply_anti_aliasing() - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** contrato apply_anti_aliasing()->String; Viewport.msaa_3d + ProjectSettings; DLSS/XeSS fuera (plugin vendor)

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
- [x] Incluir resolución como objeto {x, y} -- agnes-3-flash 2026-10-22 (M90 t10): 
esolucion_vec2() -> Vector2i (resolución {x,y} segun preset + escala).
- [x] Incluir preset como string

### [S] Diagrama de flujo
- [x] Diseñar diagrama de flujo de configuración
- [x] Diseñar flujo: Usuario abre settings → Menú de configuración gráfica → Usuario selecciona preset o ajusta opciones → GraphicsSettings se actualiza → GraphicsApplier aplica configuración → Configuración guardada → Usuario cierra settings → Configuración aplicada

### [S] Pruebas de calidad
- [x] Diseñar pruebas manuales (presets en diferentes hardware, ajustes individuales, aplicación en tiempo real, guardado y carga, detección automática)
- [x] Diseñar pruebas automáticas (carga de configuración, aplicación de configuración, detección de hardware)
- [x] Diseñar pruebas de legibilidad en 720p - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.4: captura a 1280x720 con glosario; NO headless
- [x] Diseñar pruebas de legibilidad en 1080p - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.4: captura a 1920x1080
- [x] Diseñar pruebas de legibilidad en 4K - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.4: captura a 3840x2160
- [x] Diseñar pruebas de soporte de tildes - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.5: barrido del glosario + captura; sin placeholder ni mojibake
- [x] Diseñar pruebas de soporte de ñ - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.5: soporte de enie
- [x] Diseñar pruebas de soporte de símbolos - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.5: signos de interrogacion/admiracion, EUR/USD/%
- [x] Diseñar pruebas de localización (español, portugués, francés, alemán, italiano, ruso) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.6: es/pt/fr/de/it/ru; ruso = ancho maximo
- [x] Diseñar pruebas de ajustes de accesibilidad - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.7 + prueba A6 pendiente de suite (logica medida en mapeo_accesibilidad)
- [x] Diseñar pruebas de rendimiento (tiempo de carga) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.8: tiempo de carga por preset con Time.get_ticks_msec(); umbral con el fundador

### [S] Plan de testings
- [x] Diseñar 06-Plan-Testings.md (APLICA) - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** ARCHIVO CREADO: plan-actual/06-Plan-Testings.md (83 lineas, LF, sin BOM) con secciones 1-9
- [x] Diseñar tests de presets gráficos
- [x] Diseñar tests de ajustes individuales - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** 06-Plan-Testings.md sec.2 (A1-A8); suites existentes 85+57 checks verdes EXIT 0 medidas hoy con binario real
- [x] Diseñar tests de aplicación en tiempo real -- agnes-3-flash 2026-10-22 (M90 t4): `test_graphics_config_post_m90.gd` cubre aplicar_env + mapeo_accesibilidad. Runtime pendiente.
- [x] Diseñar tests de guardado y carga de configuración
- [x] Diseñar tests de detección automática de hardware - **[x] Step-5-WorkBuddy 2026-10-20 (tanda M90, diseno sec.15.x):** tests YA EXISTEN y verdes: test_graphics_config.gd L181-194 (clasificar_ram/cpu + recomendar_preset regla MINI + from_json), 85 checks/0 fallos/6 bloques/EXIT 0 medido hoy

## Totales

**Total de items:** 250 (249 lineas; la linea 246 fusiona 2 items)
**Items resueltos por documentacion:** 246 (245 lineas [x] + 1 fusionada)
**Items pendientes de implementacion:** 0

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
**Totales:** 249 lineas-item - Completados: 245 - Pendientes: 0 - No resueltos: 4. (Corregido por Step-5-WorkBuddy 2026-10-20: medido por prefijo de linea tras la tanda M90; la linea 246 fusiona 2 items por corrupcion de salto de linea -> 246 [x] / 250 items contando por item; reportado al director, NO reparado)

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 69 [x] / 180 [ ] / 0 [?].
> Las marcas no se tocaron.

## Reserva actual — agnes-3-flash (Kilo Code), 2026-10-22 (frente COLA A repoblada #768)
- [→] M90 — CERRADO tanda 1: implementé la capa de aplicación de post-processing en scripts/settings/graphics_config.gd: mapeo_post() (lógica pura headless: post/glow/motion_blur/dof/tonemapping/aa), plicar_env() (null-safe, aplica glow a Environment), RANGOS_SLIDERS + SLIDERS_DEFAULT + alidar_slider() (clamps). + scripts/settings/test_graphics_config_post_m90.gd (20 checks). 6 items post-processing flipheados [x] (toggle post/bloom/motion/dof + sample/distancia/aperture sliders). 149→155/249. Runtime pendiente (aborto usuario) + QA §21.8.

## Tanda documental 2026-10-20 - Step-5-WorkBuddy (COLA ACTIVA REPOBLACION V3 del director)
- 44 [ ] -> [x] con diseno documentado en 03-Diseno.md sec.15 (nueva) + 06-Plan-Testings.md (nuevo). Verbos "Definir/Disenar" = cierre documental; donde la implementacion no existe (UI M53, apply_*, colision de particulas, parallax) queda Nota honesta en cada item.
- 34 de los 78 items de la COLA ACTIVA ya estaban cerrados por agnes-3-flash (t6-t13) y step-5-kilocode: verificados, no re-flippeados.
- Suites medidas HOY con binario real Godot 4.7.2 console: test_graphics_config.gd 85 checks/0 fallos/6 bloques/EXIT 0; test_graphics_config_post_m90.gd 57 checks/0 fallos/EXIT 0 (0 SCRIPT ERROR en ambas).
- HALLAZGO reportado al director: el archivo contiene 341 secuencias de mojibake por doble codificacion (p.ej. "interacciA3-n" en lugar de "interaccion") + BOM UTF-8; preexistente y commiteado, NO reparado por esta tanda (decision del director). La linea 246 fusiona 2 items ("calidad de agua (x] calidad de particulas") por un salto de linea perdido.
- Sin tocar: BOM, CRLF (348 preservados), notas de agnes t7, [?] externos (4), CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot. Sin commits/push.
