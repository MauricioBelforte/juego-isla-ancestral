**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 44: ASMR y Feedback

## 1. Arquitectura

```
                        ┌──────────────────────────────┐
   M34 (animación/key) ──►  FeedbackDirector.gd (autoload) │
   M13/M17 (acción)   ──►  - recetas de sensación           │
   M20 (cocina)       ──►  - sincronía keyframes            │
   M21 (diálogo)      ──►  - microfoley                      │
   M45 (UI/cajas)     ──►  - reglas contextuales            │
                        └──────┬───────────────────────┘
                               ▼
                  Pool de voces M43 (24) + Bus SFX
                               ▼
              Capas de sonido (4 estrictas):
        1) Ambiente M42  2) Acción M43  3) Microfoley M44
        4) Respuesta musical M41 (eventos/logros)
                               ▼
              Master: limitador -1 dBFS · SFX -6 dB headroom
```

## 2. Recetas de sensación (por acción)

| Acción | Capas apiladas (en orden) | Duración |
|---|---|---|
| Cortar madera | impacto seco → rumble → crujido + astillas | 0.8 s |
| Cavar | golpe blando → tierra suelta → granulación | 0.7 s |
| Picar piedra | percusión seca + gravilla + eco filo | 0.7 s |
| Colocar bloque | impacto corto + clic de encaje | 0.3 s |
| Cosechar | rizoma follaje + nota ascendente ligera | 0.5 s |
| Cocinar | sizzle + chasquido grasa + vapor (loop corto) | 2.0 s |
| Abrir caja/cofre | cerrojo + madera + crujido tapa | 0.6 s |
| Caminar superficie | microfoley superficie + reverb del interior | continuo |

## 3. Sincronía con animaciones (M34)

- **Regla de oro:** el SFX se dispara en el keyframe del impacto (señal `animacion_key(accion, frame)`) — margen ±15 ms respecto del impacto visual.
- Si la animación se cancela (interrupción), el sonido de impacto NO suena (evita "fantasma auditivo").
- Tabla de keyframes por acción y variación de pitch ligera por repetición (PRNG M29).

## 4. Blacklist anti-agresión y anti-saturación

| Regla | Verificación |
|---|---|
| Ningún evento supera -3 LUFS de pico | Analyser en bus SFX (test M112) |
| Sin distorsión de clip (True Peak > -1 dBFS) | Sidechain True Peak en master |
| Sin buzz (2-4 kHz sostenidos > 300 ms) | Detector de banda en test de QA |
| Sin scare chords ni sustos | Regla de diseño M44 (revisión de lista por evento) |
| ≤ 6 SFX simultáneos | Pool M43 |
| SFX bus con -6 dB headroom | Config del árbol de audio |

## 5. Reglas contextuales (precedencia fija)

| Contexto | Efecto |
|---|---|
| Interior (casa/cobertizo) | -3 dB todo, reverb 0.5 s |
| Cueva/templo/ruinas | reverb 1.5/1.2/1.0 s + oclusión 30% |
| Bajo el agua | low-pass fuerte + volumen muy suave |
| Lluvia/tormenta (M32) | ambiente +2 dB, SFX -2 dB |
| Noche profunda (M31) | micro-latido de microfoley -30% (misterio suave) |
| Diálogo (M21) | SFX/microfoley -6 dB (ducking) |

**Precedencia:** interior > clima > día/noche > diálogo.

## 6. Accesibilidad (M58)

- Opción "Feedback reducido": microfoley y capa 3 a -6 dB.
- Opción "Sonido direccional": refuerza la espacialización 3D (pan) para jugadores con sensibilidad.
- Todas las opciones en Config de Audio (M91).

## 7. QA

- Test M112: receta→capas correctas; keyframes sincronizados; blacklist de picos no dispara.
- Recorrido M114: 15 min jugando sin fatiga; ninguna acción "chincha".
- Master test: True Peak ≤ -1 dBFS en toda la sesión.