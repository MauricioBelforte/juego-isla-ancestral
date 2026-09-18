**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

> **iter. 6 (Log 1002, 2026-09-18):** marcadores sincronizados in-place con
> `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/05-Checklist.md` (137/148).
> La evidencia de cada ítem vive en el checklist del módulo; acá solo se
> refleja el estado. **Esta checklist tiene 138 ítems y el módulo 148** — faltan
> 10 ítems por agregar (los últimos del módulo); se reporta, no se regenera
> (regenerarla borraría las notas de evidencia de otros agentes).

**Módulo:** 52-Particulas-Y-VFX (52)

# Checklist personal tareas — 52-Particulas-Y-VFX

> Extraídas del `05-Checklist.md` del módulo (71 pendientes / 1 dudas de 138 ítems). Fuente de verdad del ítem: el `05-Checklist.md`.

## Tareas

- [x] T-001 Definir el problema: sin sistema de VFX el feedback visual es inconsistente y caro [S]
- [x] T-002 Definir el objetivo: VFX baratos, deterministas y armónicos con el estilo cozy [S]
- [x] T-003 Registrar dependencias: M04 (GPUParticles), M45/M47 (materiales), M49 (glow/luz), M61/M62 (presupuestos), M58 (accesibilidad) [M]
- [x] T-004 Mapear la sección 51 "PARTÍCULAS Y VFX" del plan maestro al ID 52 de la tabla global [M]
- [x] T-005 Separar dentro/fuera de alcance: luz de fuego → M49, sonido → M43/M44, sprites → M45/M47 [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-006 Documentar restricciones: GPUParticles, sin RNG, sin luz por partícula, presupuesto verificable [M]
- [x] T-007 Definir criterios de aceptación verificables (8 criterios) [S]
- [x] T-008 Listar los 25 efectos del plan maestro [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-009 Humo y polvo [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-010 Hojas y pétalos [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-011 Chispas [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-012 Agua (salpicaduras) [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-013 Lluvia y nieve [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-014 Fuego y lava [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-015 Luz y magia tecnológica [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-016 Resonancia y activación de runas [S] — auditoría iter. 5 (Log 882): sin entrada en el catálogo real (8/25) — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-017 Teletransporte (si existe) [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-018 Obtención de Sello [S] — auditoría iter. 5 (Log 882): sin entrada en el catálogo real (8/25) — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-019 Resolución de puzzle [S] — auditoría iter. 5 (Log 882): sin entrada en el catálogo real (8/25) — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-020 Construcción, cosecha y pesca [S] — auditoría iter. 5 (Log 882): sin entrada en el catálogo real (8/25) — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-021 Descubrimiento [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-022 Cambio estacional [S] — auditoría iter. 5 (Log 882): sin entrada en el catálogo real (8/25) — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-023 Efectos de interfaz [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-024 Efectos atmosféricos [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-025 Definir parámetros por efecto (tipo, material, emisor, presupuesto) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-026 Definir VfxManager (autoload) [M]
- [x] T-027 Definir pool de emisores one-shot prestados/liberados [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-028 Definir loops registrados con culling [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-029 Definir precalentamiento del pool (8 emisores) [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-030 Definir máx emisores activos (12 preset medio) [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-031 Definir máx partículas vivas (4.000 preset medio) [M] — iter. 5 (Log 882): implementado y verificado headless
- [ ] T-032 Definir presupuesto por preset (M90) [M]
- [x] T-033 Definir log VFX-SKIP cuando se excede [M]
- [x] T-034 Definir semillas de contexto (M10) en one-shots [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-035 Definir loops con fase fija [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-036 Definir sin RNG por frame [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-037 Definir verificación de determinismo en validador [M]
- [ ] T-038 Definir triggers en timelines (M48) [M]
- [x] T-039 Minado, cosecha, pesca, construcción desde animación [M]
- [x] T-040 Definir trigger centralizado VFX+SFX+feedback [M]
- [x] T-041 Definir obtención de Sello (M22) [M]
- [x] T-042 Definir resolución de puzzle (M24) [M]
- [x] T-043 Definir descubrimiento (M71) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-044 Definir festivales (M74) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-045 Definir humo + ascuas de fuego [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [ ] T-046 Definir burbujas + ascuas de lava [M]
- [x] T-047 Definir sin luz por partícula (luz = M49) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-048 Definir salpicaduras al nadar (M51/M11) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-049 Definir gotas de cascada [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [ ] T-050 Definir chapoteo de balde (M13) [M]
- [x] T-051 Definir lluvia por clima (M32) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-052 Definir nieve por clima/estación (M32/M29) [M]
- [x] T-053 Definir polvo del desierto [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-054 Definir hojas al viento (M50) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-055 Definir pétalos primaverales (M29) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-056 Definir un emisor global por zona (no por chunk) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-057 Definir resonancia de runas (M24/M26) [M]
- [x] T-058 Definir activación de glifos [M]
- [ ] T-059 Definir estelas de luz (M47) [M]
- [x] T-060 Definir magia tecnológica (M86) [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [ ] T-061 Definir partículas 2D en menús/recompensas (M53) [M]
- [ ] T-062 Definir Reduce Motion (M58) [M]
- [x] T-063 Definir sin estroboscopios (>10 Hz prohibido) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-064 Definir transición de VFX por estación (M29) [M]
- [x] T-065 Definir pétalos ↔ hojas ↔ nieve [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-066 Definir estela de entrada/salida (si se implementa M28) [S]
- [x] T-067 Definir tope de partículas vivas [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-068 Definir culling por distancia (40 m pausa) [M]
- [x] T-069 Definir LOD de emisores (25% lejos) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-070 Definir pooling (M62) [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-071 Definir validate_vfx.gd [M]
- [x] T-072 Verificar presupuesto por escena [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-073 Verificar naming [S] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-074 Verificar determinismo (semillas) [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-075 Verificar sin luz por partícula [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-076 Verificar mapeo completo de eventos de juego [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-077 Definir prefijos vfx_, part_ [S]
- [x] T-078 Alinear con M108 [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-079 Rendimiento: límites + LOD + pooling (M61) [M] — iter. 5 (Log 882): límites y pooling SÍ; LOD por distancia NO — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-080 Memoria: pool precalentado (M62) [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-081 Determinismo: semillas + fases fijas [M] — iter. 5 (Log 882): semillas SÍ; fases fijas de loops NO (no hay loops) — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [ ] T-082 Cozy: amplitudes suaves, sin humo denso negro [M]
- [x] T-083 Accesible: vfx_quality 3 niveles (M58) [M]
- [x] T-084 Mantenible: catálogo central único [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-085 Descartar CPUParticles para todo [M]
- [x] T-086 Descartar emisores sin pool (GC/stutter) [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-087 Descartar luz integrada en partículas [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-088 Descartar RNG en runtime [S] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-089 Descartar sin límite de partículas [S] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-090 Descartar VFX 100% procedural por shaders [M]
- [x] T-091 Riesgo de overdraw → presupuesto + tope + LOD [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-092 Riesgo de desincronía → trigger centralizado [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-093 Riesgo de determinismo roto → semillas + validador [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-094 Riesgo de stutter → pool precalentado [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-095 Riesgo de molestias (fotosensibilidad) → vfx_quality (M58) [M]
- [ ] T-096 Riesgo de efectos fuera de estilo → guía de amplitudes + review [M]
- [x] T-097 Documentar integración con M04 (GPUParticles) [S]
- [x] T-098 Documentar integración con M13/M17/M22/M24/M33/M34/M71 (eventos) [S]
- [x] T-099 Documentar integración con M48 (timelines) [S]
- [x] T-100 Documentar integración con M43/M44 (audio/feedback) [S]
- [x] T-101 Documentar integración con M32/M29 (clima/estaciones) [S]
- [x] T-102 Documentar integración con M50/M51 (hojas/salpicaduras) [S]
- [x] T-103 Documentar integración con M47/M49 (materiales/luz) [S]
- [x] T-104 Documentar integración con M53/M58 (UI/accesibilidad) [S]
- [x] T-105 Documentar integración con M61/M62 (presupuestos) [S]
- [x] T-106 Documentar integración con M108/M118 (import/CI) [S]
- [x] T-107 Documentar flujo de emisión one-shot [M] — iter. 5 (Log 882): implementado y verificado headless
- [x] T-108 Documentar flujo de loop ambiental (humo) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-109 Documentar flujo de atmosféricos por clima/estación [M]
- [x] T-110 Todos los efectos del plan maestro en el catálogo [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [ ] T-111 Escena pivote sin exceder límites y sin caída de fps [M]
- [x] T-112 One-shots deterministas (misma semilla, misma distribución) [M]
- [x] T-113 Triggers sincronizados con animación/sonido/feedback [M]
- [x] T-114 Fuego/lava sin luz (solo M49) [M] — iter. 6 (Log 1002): ver `05-Checklist.md` del módulo.
- [x] T-115 Reduce Motion atenúa/desactiva VFX [M]
- [x] T-116 Atmosféricos responden a clima/estación sin lag [M]
- [x] T-117 Catálogo y validación integrados con CI (M118) [M]
- [x] T-118 Documentar el desfase de numeración del plan maestro (51=PARTÍCULAS Y VFX → ID 52) [S]
- [x] T-119 Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] T-120 Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]
- [x] T-121 Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
- [x] T-122 Escena `preview_particles.tscn` creada y ejecutada en Godot 4.7.2 [S]
- [x] T-123 Emisor CPUParticles3D corriendo sin errores en consola ("Polen creado OK") [M]
- [x] T-124 Confirmación visual humana: partículas amarillas visibles emergiendo desde abajo (tipo chispas/fuegos artificiales) [S]
- [x] T-125 Lanzamiento reproducible documentado (`scripts-reutilizables/lanzar_preview.py`) [S]
- [x] T-126 Primera captura automatizada real del juego: `capturas/52-Particulas-Y-VFX/cap_52_2026-08-24_21-19-22_polen-validacion.png` (verificada visualmente por el agente) [S]
- [x] T-127 Mejora estética: quad reducido 0.25→0.06 + textura radial suave generada por código (GradientTexture2D) + transparencia alpha. Verificado en capturas iter2/iter2b: polen pequeño redondeado difuminado, FPS 59 [M]
- [x] T-128 Iter 3: turbulencia (deriva orgánica tipo brisa) + caída lenta + damping + amount 150→220 + lifetime 6→9. FPS 59 confirmado en iter3b (el 24 inicial era transitorio del arranque) [M]
- [x] T-129 Iter 4: emisión en caja ancha (EMISSION_SHAPE_BOX, extents 3.5×0.5×1.0) para distribuir el polen por toda la escena en vez de amontonarlo en una columna. Verificado en captura: polen distribuido flotando a distintas alturas, FPS 59 [M]
- [x] T-130 Flujo completo V4+V2 ejercitado: lanzar (script) → capturar (MCP screen) → comparar → ajustar → recapturar, con historial de capturas por iteración [S]
- [x] T-131 Preview de polen (GPUParticles3D, amount 150, quad 0.06 textura radial) ejecutado y capturado: cientos de partículas flotando visibles, textura suave, sin frames rotos
- [x] T-132 **Rendimiento visual: FPS 59** en la escena (sin degradación con 150+ partículas — presupuesto OK)
- [x] T-133 GPUParticles3D (recomendado por M52) confirmado como vía correcta en D3D12 (no CPU)
- [?] T-134 Catálogo de VFX por evento (M44 feedback + M92 tutorial): iter 2 — catálogo data-driven (dueño: deepseek-v4-flash-vision-exp)
- [x] T-135 `scripts/particles/vfx_factory.gd` — VfxFactory: cargar_catalogo(), parametros(vfx) (color hex manual parseado, cantidad, emisión, tipo) y crear() (GPUParticles3D one_shot con material particle)
- [x] T-136 Test 8/8 OK (catálogo 8, parámetros de polen/crafteo, defaults seguros, color #F4E04D validado)
- [x] T-137 `scripts/particles/vfx_director.gd` — VfxDirector: carga el catálogo (8 eventos), registra el bus genérico si existe, disparar(evento_id, pos) → VfxFactory y estado (último disparo)
- [x] T-138 Test 4/4 OK (8 eventos, dispatch conocido, fallo para evento inexistente)
