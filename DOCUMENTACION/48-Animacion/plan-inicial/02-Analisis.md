**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 48: Animación

## 1. Análisis del Dominio

El dominio de animación de Aurora se descompone en ocho subsistemas:

### 1.1 Producción de animación (contenido)
- **Dominio:** los animadores producen clips 3D para rigs de M45 (humanoide, cuadrúpedo, ave, pez) y clips 2D vía Tween/AnimationPlayer para UI.
- **Flujo:** cada animación nace de un estado FSM (M11/M19/M36/M65) y se produce en 3 pasos: blocking (poses clave), polish (timing, anticipación, follow-through) y export (FBX 30 fps, T-pose única, bone subset).
- **Clave:** el catálogo mapea `estado FSM → animación`; nunca se anima "a mano" un estado sin antes definir el FSM.

### 1.2 Reproducción (AnimationPlayer + AnimationLibrary)
- **Dominio:** cada actor lleva un AnimationPlayer con AnimationLibrary (Godot 4). Las transiciones se resuelven con mezcla; los blend spaces (2D) para locution del jugador (dirección × velocidad).
- **Rendimiento (M61):** solo los actores de la burbuja (≤60 con M64) actualizan huesos completos; el resto usa LOD de animación (idle simplificado o sin update de huesos lejanos).
- **Clave:** la FSM de animación es un reflejo de la FSM de comportamiento: `animation_fsm.tick(estado_comportamiento) → play`.

### 1.3 Animación procedural acotada
- **Dominio:** vegetación (viento, M50), agua (ondas, M51), fuego (M52) no usan clips: se animan con shader/scripts ligeros deterministas por fase fija.
- **Clave:** el procedural NUNCA reemplaza clips donde el rig existe (si hay bones en un árbol, se anima con clips).

### 1.4 Sincronía de audio/feedback/partículas
- **Dominio:** los eventos (sonido M43, ASMR M44, partículas M52) se fijan en la LÍNEA DE TIEMPO de la animación (track de eventos/method call), no en gameplay.
- **Clave:** la desincronía (sonido antes que el impacto) rompe la ilusión cozy; la regla es "el evento se emite al frame que lo produce visualmente".

### 1.5 UI y diálogos
- **Dominio:** transiciones de menú (M53), retratos y diálogos (M21/M46), recompensas/descubrimientos (M71/M72) se animan con AnimationPlayer sobre Control/tweens a 60 fps.
- **Accesibilidad (M58):** todo movimiento de UI debe poder reducirse (Reduce Motion) o desactivarse.

### 1.6 Presupuesto y LOD de animación
- **Dominio:** el coste de animación se mide en huesos actualizados × actores visibles. Regla: burbuja (≤60 actores plenos con M64), fuera de burbuja idle o sin animar; blend trees limitados (≤4 nodos por actor); animaciones de mundo con shader (GPU) no CPU.
- **Registro:** `animation_budget.json` (RF14) por escena pivote contra M61.

### 1.7 Validación técnica
- **Dominio:** `validate_animation.gd` verifica: naming, frames (30 base), T-pose única, bones subset permitido, keyframes redundantes (bicubics minimizados), keyframes de evento correctos, coste por actor.
- **Clave:** la validación ocurre en el editor (previo a commit) y en CI (M118).

### 1.8 Coherencia cozy
- **Dominio:** el estilo M45 pide movimientos suaves, sin exageraciones físicas: amplitudes moderadas, anticipación corta (no slapstick), follow-through sutil; los NPC nunca "flotan" al girar (pose anticipada).

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Importar FBX con animación embebida por escena (Godot Plantilla) | **Descartado** | Duplica clips por escena y rompe reutilización; se usa AnimationLibrary central |
| Animación 100% por código (tweens por estado) | **Descartado** | CLips de animador dan mejor calidad y control; código solo para procedimentales |
| Un AnimationPlayer global del mundo | **Descartado** | Costo y acoplamiento; cada actor con player; pooling para objetos repetibles |
| Animación por splines/impostores 2D para todo | **Descartado** | Rompe la inmersión voxel 3D (M45); solo vegetación/humo usan GPU |
| Rigen de animación en tiempo real (retargeting genérico) | **Descartado** | Costo y complejidad; se usan rigs por familia estándar (M45) y same-rig retargeting manual |
| Blend trees ilimitados | **Descartado** | Costo explosivo; blend trees ≤ 4 nodos por actor |

## 3. Decisiones del Módulo

1. **AnimationLibrary por actor** (jugador, por familia de NPC, fauna, props), importación FBX 30 fps, T-pose única.
2. **FSM de animación espejo** del FSM de comportamiento, vía servicio `AnimationService` con API `play(actor, estado, blend_time)`.
3. **Blend spaces solo para locomoción** del jugador y del NPC (dirección × velocidad), ≤ 4 nodos.
4. **Eventos de audio/feedback/partículas en la línea de tiempo** de cada clip.
5. **LOD de animación:** burbuja con M64 (≤60 plenos), fuera idle/LOD, mundo procedural GPU.
6. **Procedimental solo donde no hay rig** (vegetación/agua/fuego) con fases fijas deterministas.
7. **Registro de presupuesto** `animation_budget.json` contra M61.

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Clips duplicados por escena durante producción | Alta | Medio | AnimationLibrary central + validación de referencias |
| Transiciones con snaps por mal blending | Media | Alto | Blend 250 ms default, pose de entrada en transición, review visual |
| Desincronía de sonido/feedback | Media | Alto | Eventos en timelines de animación + test de desincronía |
| Coste de huesos desbordado con NPC multitudinarios | Media | Alto | Burbuja con M64 + LOD de animación + registro |
| UI animada que molesta (accesibilidad) | Media | Medio | Reduce Motion (M58) + duraciones cortas |
| Naming/import inconsistentes | Media | Medio | validate_animation.gd + plantilla de import |