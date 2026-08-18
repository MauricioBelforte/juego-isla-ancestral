**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 52: Partículas y VFX

## 1. Análisis del Dominio

El dominio de VFX de Aurora se descompone en siete subsistemas:

### 1.1 Catálogo de efectos (contenido)
- **Dominio:** 25+ efectos del plan maestro (sección 51) agrupados por familia: ambientales (humo, polvo, hojas, pétalos, lluvia, nieve), activos (fuego, lava, chispas, magia, runas, Sello, puzzle), de interacción (minado, construcción, cosecha, pesca, agua) y de UI (interfaz, descubrimiento, recompensas).
- **Clave:** cada efecto define: tipo (one-shot/loop), material (M45/M47), emisor, duración, y presupuesto (partículas máx).

### 1.2 Motor de partículas (Godot)
- **Dominio:** GPUParticles3D (3D) y GPUParticles2D (UI) son lo estándar en Godot 4: baratos y en GPU. CPUParticles solo como excepción documentada (efectos de pocas partículas en CPU con lógica custom).
- **Clave:** el VfxManager reutiliza emisores (pool); los one-shot se liberan al terminar; los loops se registran y cullen por distancia (M61).

### 1.3 Presupuesto (M61)
- **Dominio:** el costo dominante es overdraw/fill-rate del blend additivo y la cantidad de partículas vivas. Reglas: máx emisores activos por escena (ej: 12), máx partículas vivas (ej: 4.000 en preset medio), culling por distancia y LOD de emisores (lejos: 25% partículas).
- **Clave:** el validador revisa que cada escena del registro cumpla el presupuesto.

### 1.4 Determinismo
- **Dominio:** los one-shot inicializan posiciones/velocidades con PRNG de contexto (M10, semilla por evento); los loops usan fase fija (TIME + semilla del emisor). Cero RNG por frame en runtime.
- **Clave:** visualmente, la aleatoriedad perceptiva se logra con semillas estables (misma escena → mismo resultado), no con RNG.

### 1.5 Sincronía con el resto del juego
- **Dominio:** los triggers vienen de: timelines de animación (M48: minado, cosecha, pesca, construcción), eventos de juego (M22 Sello, M24 puzzle/runas, M71 descubrimiento, M74 festival), sistemas de mundo (M50 viento → hojas, M51 agua → salpicaduras, M32 clima → lluvia/nieve) y estaciones (M29).
- **Clave:** VFX + sonido (M43) + feedback (M44) se disparan juntos desde el MISMO trigger (coordinación central), evitando desincronía.

### 1.6 Accesibilidad y estilo cozy
- **Dominio:** M58 pide reducir movimiento; aquí: `vfx_quality` global (full/reduced/off) que atenúa opacidad/velocidad o desactiva; sin estroboscopios (> 10 Hz prohibido); amplitudes cozy (chispas pequeñas, humo suave).
- **Clave:** el toggle de VFX no afecta mecánicas (solo visuales).

### 1.7 Validación técnica
- **Dominio:** `validate_vfx.gd` recorre el catálogo y las escenas: presupuesto de emisores/partículas, naming, determinismo (semillas), ausencia de luces por partícula (la luz es de M49), y consistencia del catálogo (todos los eventos de juego mapeados).

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| CPUParticles para todo | **Descartado** | Costo CPU; GPU es el estándar (M61) |
| Emisor por evento sin pool (instanciar y destruir) | **Descartado** | GC y stutter (M62); pool obligatorio |
| VFX con luz integrada | **Descartado** | Fill-rate explota; la luz la centraliza M49 |
| Partículas con RNG runtime | **Descartado** | Rompe determinismo M10 |
| Sin límite de partículas (dejar que el artista ajuste) | **Descartado** | Presupuesto verificado obligatorio |
| VFX procedural 100% (shaders sin emisores) | **Descartado** | Rigidez; mezcla emisores + shaders |

## 3. Decisiones del Módulo

1. **VfxManager (autoload)** con pool de emisores y catálogo central.
2. **GPUParticles3D/2D** estándar; CPUParticles solo excepción documentada.
3. **Presupuesto verificable** por escena (emisores ≤ 12, partículas ≤ 4.000 preset medio).
4. **Triggers centralizados** (un solo punto dispara VFX + sonido + feedback).
5. **Determinismo:** semillas de contexto (M10) y fases fijas.
6. **Sin luz por partícula** (la luz es M49).
7. **Accesibilidad:** `vfx_quality` con 3 niveles (M58).

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Overdraw de partículas aditivas en combate/efectos | Media | Alto | Presupuesto + tope de partículas vivas + LOD |
| Desincronía VFX/sonido | Media | Alto | Trigger centralizado (VFX+SFX+feedback) |
| Determinismo roto por emisores | Media | Medio | Semillas de contexto (M10) + validador |
| Stutter por instanciar emisores | Media | Alto | Pool con precalentamiento (M62) |
| VFX molestos (fotosensibilidad) | Media | Medio | vfx_quality 3 niveles (M58) |
| Efectos que no "pegan" con el estilo cozy | Media | Medio | Guía de amplitudes + review visual |