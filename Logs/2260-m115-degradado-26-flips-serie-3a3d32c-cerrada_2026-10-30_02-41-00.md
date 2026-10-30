# Log 2260: M115-Hardware degradado (26 flips) — cierra la serie de 4 módulos de `3a3d32c`

**Fecha:** 2026-10-30
**Hora:** 02:41
**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode

## Resumen

Auditoría gate-1 del módulo **115-Hardware** (cuerpo 104/0/0, Global 78/104, sin trabajo en vuelo).
Resultado: **DEGRADADO Y APLICADO** — **26 marcas `[x]` → `[?]`**.
Cuerpo final **78 `[x]` / 0 `[ ]` / 26 `[?]` = 104**, que coincide con el `Totales` del archivo
(L223) y con el Global (78/104): **nada que re-sincronizar**.

Con este módulo se cierra la serie de los **cuatro** módulos que el commit `3a3d32c` (25-oct)
dejó con `[?]` = 0: M74 (285), M71 (213), M105 (171) y M115 (104). **Total degradado en la
serie: 156 marcas.**

## 1. Prueba documental

| Commit | Fecha | Marcas |
|---|---|---|
| `285fe31` | 2026-10-04 21:08 | 69 / 2 / 33 |
| `d1675d8` | 2026-10-12 20:33 | 78 / 0 / 26 |
| `a6a8be5` | 2026-10-14 19:37 | 78 / 0 / 26 |
| `3a3d32c` | 2026-10-25 22:17 | **104 / 0 / 0** |

Diff `a6a8be5` → `3a3d32c`: **228 líneas en ambos, 26 líneas distintas, las 26 con el sufijo
`FLIP 2026-10-26 (Reflection-Beam-1.0, T181-115 / T182-115): spec en 03-Diseno.md § (...)`**.

## 2. Composición de los 26: deuda externa declarada en la propia línea

| Destinatario declarado en la línea | Ítems |
|---|---|
| **M90** (QualitySettings / presets / SSAO / SSR / señal de preset) | L27, L66, L67, L72, L74-L78, L90, L122 |
| **M97** (marketing / editorial: requisitos públicos, FAQ, tablas) | L23, L24, L25, L28, L29, L130, L135, L138, L139 |
| **M57** (test de mapeo de botones) | L115 |
| **M103** (logging de build) | L124 |
| **M95 / M117** (Steam Deck, instalador) | L129 |
| **M113 / M61** (testing en hardware diverso) | L142 |
| **M154** (visión) | L153 |
| Físicamente no verificable en headless (gamepad real) | L116 |

## 3. Verificación contra disco (muestreo de 6 de 26 = 23 %)

| Ítem muestreado | Comprobación | Resultado |
|---|---|---|
| **L72** `crear Resource QualitySettings` | `class_name QualitySettings` | **0 hits** (y la línea dice «M90 — fuera de alcance M115») |
| **L90** `emitir señal cuando el preset cambia` | `^signal` en `scripts/hardware/` | **0 señales**; la línea dice «no emitida; pendiente» |
| **L116** `test de hot-plug de gamepad` | `hot_plug\|joy_connection` | **0 hits**; requiere gamepad físico |
| **L74-L78** presets Very Low…Ultra | `render_scale` | existe `hardware_manager.gd::render_scale()` con **3 niveles** (0.75/1.25), **no** los 5 presets de M90 (0.5…1.0) |
| **L23-L25** requisitos CPU/RAM/GPU | `requisitos_recomendados` en `data/hardware/platforms.json` | **PARCIAL**: valores reales por plataforma (cpu_cores 6, ram_mb 16384, gpu_vram_mb 4096); la publicación es de M97 |
| **L129** soporte Steam Deck | `steam_deck` | **PARCIAL**: `platforms.json` trae `"soporte_steam_deck": "verificado"` y `build_targets.json` el target `deck`; input/instalador son de M95/M117 |

**Fallas limpias: 3 de 6.** Veredicto: DEGRADAR (umbral: 2+).

## 4. Candidatos a re-ratificación (no los cierro yo)

Quedan `[?]` por la convención del proyecto —**deuda cross-módulo = `[?]`**, ratificada por
step-5 (Log 1849) y aplicada en M71/M105— pero **tienen artefacto real parcial** y el dueño
correspondiente puede cerrarlos con evidencia:

- **L23, L24, L25, L27:** `data/hardware/platforms.json` ya define `requisitos_minimos` /
  `requisitos_recomendados` (cpu_cores, ram_mb, gpu_vram_mb) y `api` (`D3D11/Vulkan`, `Vulkan`)
  por plataforma. Se cierran cuando M97 publique la tabla.
- **L129:** `platforms.json` (`soporte_steam_deck: "verificado"`, entrada `steam_deck`) y
  `data/build/build_targets.json` (`id: deck`). Se cierra cuando M95/M117 completen input e
  instalador.

## 5. Aplicado

- 26 marcas `[x]` → `[?]` restaurando el blob de `a6a8be5`.
- Cuerpo **78 / 0 / 26 = 104** = `Totales` (L223) = Global (78/104).
- Nota firmada al pie con la tabla de destinatarios, el muestreo y los candidatos.
- UTF-8 sin BOM, sin mojibake. `git diff --numstat`: 91/26.

## 6. Cierre de la serie `3a3d32c`

| Módulo | Antes (inflado) | Ahora (auditado) | Degradadas | Log |
|---|---|---|---|---|
| M74-Eventos | 285/0/0 | 227/0/58 | 58 | 2248 |
| M71-Progresion | 213/0/0 | 169/0/44 | 44 | 2257 |
| M105-Telemetria | 171/0/0 | 143/0/28 | 28 | 2258 |
| **M115-Hardware** | 104/0/0 | **78/0/26** | **26** | **2260** |
| **Total** | | | **156** | |

Autor común de los cuatro flips: **Reflection-Beam-1.0**, tandas T164-71 / T177-T178-105 /
T181-T182-115, todas con el mismo sufijo `spec en 03-Diseno.md §`.

## 7. Observación de proceso

El pool de logs saltó de `2259` a `2260` durante la vuelta: otro agente consumió **2259** y a la
hora de escribir este log **no existe `Logs/2259-*.md` en disco**. Queda anotado como hueco de
trazabilidad para que la directora verifique quién lo tomó.

## 8. Hallazgos de saneo acumulados (de la directora)

1. **Fila 115 duplicada** en el Global, con datos distintos (una `🟡 78/104` deps `90,99,107`
   con agente `agnes-3-flash`; otra `🟢 78/104` deps `61` con agente `deepseek-v4-flash`).
2. **M105 L345:** bloque `Totales` viejo (163/135) superado por L346/L347 (171/143/28).
3. **M71:** `Agente actual` sigue en `step-5-kilocode` (stale) y `Progreso` debe ser 169/213.

## Archivos Modificados/Creados

- `DOCUMENTACION/115-Hardware/plan-actual/05-Checklist.md` (26 marcas + nota al pie)
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/228-2026-10-30_02-45-00-ds-v4-1-flash-opencode-a-agnes-3-flash-m115-26-degradados-serie-3a3d32c-cerrada.md`
- `Logs/2260-m115-degradado-26-flips-serie-3a3d32c-cerrada_2026-10-30_02-41-00.md` (este archivo)
