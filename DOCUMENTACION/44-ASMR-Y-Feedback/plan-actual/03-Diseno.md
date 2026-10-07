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
## 8. Edge cases de integración, volumetría y revisión de pilar (T-M4)

> Añadido 2026-10-06 en el cierre documental T-M4 (mimo-v2.6-flash-free): cierra por
> diseño los huegos de los ítems de checklist K-«retroceso del reloj»,
> L-«volumetría coherente» y L-«revisión contra el pilar cozy».

### 8.1 Retroceso del reloj (M29) — capas sin desincronizar

- **Regla:** `FeedbackDirector` no mantiene estado temporal propio — `sensacion()` es
  inmediata por evento; el estado vivo es `_contexto` (interior/clima/hora).
- **Al retroceder el reloj (M29):**
  1. Las recetas en curso se **cancelan** (nada suena de un estado ya revertido).
  2. El contexto se **re-aplica** con `set_contexto()` tras el salto temporal
     (hora → M31, interior/clima → su fuente vigente).
  3. No quedan capas "huérfanas" del tiempo revertido (toda capa nace de un evento
     y muere con su receta; sin loops persistentes no ligados al contexto).
- **Verificación prevista (delegado):** test de rewind — tras `rewind`, `set_contexto`
  post-salto no conserva capas de la hora anterior.

### 8.2 Volumetría coherente entre todas las capas

- **Jerarquía relativa fija** (referencia: bus SFX con headroom -6 dB, 03 §4):

  | Capa | Nivel relativo | Regla |
  |---|---|---|
  | Ambiente M42 | fondo 0 dB | nunca tapado por microfoley (03 §1, 02 P10) |
  | Acción M43 | pico de atención | dentro de -3 LUFS de pico (03 §4) |
  | Microfoley M44 | -18 dB sobre SFX base | dulce y premiador (02 §2-3) |
  | Respuesta musical M41 | solo eventos | ducking -6 dB con diálogo (03 §5) |

- Los ajustes contextuales (03 §5) aplican **solo sobre estas bases**; la precedencia
  (interior > clima > día/noche > diálogo) garantiza que ningún caso supera el techo del
  master (**-1 dBFS**, 03 §4).
- **Coherencia = mismos límites y misma precedencia para las 4 capas, sin excepción por
  contexto.**

### 8.3 Revisión contra el pilar cozy (checklist de principios)

- El «checklist M0» del plan original corresponde al corpus de **M152-Principios-Innegociables**
  (`plan-actual/05-Checklist.md` → «Checklist de implementación»: Filosofía cozy,
  Principios de diseño, Principios técnicos). Revisión de M44 contra los principios aplicables:

  | Principio M152 | Cumplimiento en M44 | Sustento |
  |---|---|---|
  | Ambiente relajante y acogedor | M44 ES el sistema de sensación cozy (ASMR dulce, -18 dB, premiador) | 01 §1, 02 §2-3 |
  | Sin sustos / sin castigos | Blacklist prohíbe scare chords y sustos; evento prohibido → silencio | 03 §4, blacklist.json (4 prohibidas) |
  | Performance > visuals | Sin fuentes nuevas: reutiliza pool de 24 de M43 | 01 §3 |
  | Licencias claras de assets | Documento de permisos de assets (ítem L) | 05 §L |
  | Sistemas con propósito | 5º pilar cozy justificado; 17 puntos del plan resueltos | 01 §1, 02 §1 |
  | Sin FOMO / sin penalización | Pausa M29 sin residuos de microfoley (diseño §7/04 §2); sin penalización por ritmo | 03 §5, 04 §2 |

- **Resultado:** M44 cumple los 6 principios aplicables sin desviaciones registradas.
