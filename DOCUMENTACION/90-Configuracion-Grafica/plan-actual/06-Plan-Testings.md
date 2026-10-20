# 06-Plan-Testings.md — Módulo 90: Configuración Gráfica

**Creado:** 2026-10-20 (Step-5-WorkBuddy, tanda COLA ACTIVA REPOBLACION V3, ítem 171)
**Alcance:** pruebas de ajustes gráficos del juego (núcleo `scripts/settings/graphics_config.gd`
+ capa de aplicación + UI M53). Reemplaza el ítem "Diseñar 06-Plan-Testings.md (APLICA)".

## 1. Inventario de suites existentes (verde con binario real, medido 2026-10-20)

| Suite | Cubre | Resultado medido (Godot 4.7.2 console, --headless --script) |
|---|---|---|
| `scripts/settings/test_graphics_config.gd` | presets, sliders/clamps, clasificar_ram/cpu, recomendar_preset (regla MINI), from_dict/from_json, rangos | **85 checks / 0 fallos / 6 bloques / EXIT 0 / 0 SCRIPT ERROR** (guarda de 3 capas: CHECKS_MINIMOS 80 + BLOQUES_MINIMOS) |
| `scripts/settings/test_graphics_config_post_m90.gd` | mapeo_post, aplicar_env (null-safe + Environment real), validar_slider, volumetrico, upscaling, resolucion_vec2 | **57 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR** (sin guardia de 3 capas: confianza por lectura de flujo + resumen final) |

Comando de ejecución (referencia de la suite):
`Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/settings/test_graphics_config.gd`

## 2. Pruebas de ajustes individuales (ítem 172)

Una por control, todas ejecutables en headless contra el núcleo:

| # | Prueba | Afirmación clave | Estado |
|---|---|---|---|
| A1 | Cada preset aplica y `preset_actual()` lo reconoce | aplicar_preset("bajo"/"medio"/"alto"/"ultra") -> preset_actual() coincide | Cubierto por suite 1 |
| A2 | `fijar()` con clave inexistente devuelve false | fijar("clave_fantasma", 1) == false | Cubierto por suite 1 |
| A3 | Sliders clamplean a su rango | bloom_intensidad=9 -> validar_slider -> <= 1.0 | Cubierto por suite 2 |
| A4 | `post=false` apaga TODO el post | mapeo_post(): glow/motion_blur/dof todos false | Cubierto por suite 2 |
| A5 | Toggles individuales con `post=true` | mix ultra + bloom=false -> glow off, dof sigue on | Cubierto por suite 2 |
| A6 | Accesibilidad interactúa con post | reducir_bloom -> glow off; reducir_motion -> motion_blur off | Pendiente de suite (lógica medida en `mapeo_accesibilidad()`) |
| A7 | `from_json` inválido/array devuelve false | "esto no es json" y "[1,2,3]" | Cubierto por suite 1 |
| A8 | `to_dict`/`from_dict` round-trip | valores iniciales == from_dict(to_dict()) | Cubierto por suite 1 |

## 3. Pruebas de detección automática de hardware (ítem 174)

| # | Prueba | Afirmación clave | Estado |
|---|---|---|---|
| D1 | Clasificación de RAM por umbral | 2/8/16/64 GB -> baja/media/alta/ultra | Cubierto por suite 1 (L181-184) |
| D2 | Clasificación de CPU por núcleos | 2/8 núcleos -> baja/alta | Cubierto por suite 1 (L185-186) |
| D3 | Regla MINI (nunca recomendar de más) | GPU ultra + 4 GB -> baja; GPU débil + 32 GB -> baja | Cubierto por suite 1 (L189-190) |
| D4 | GPU desconocida -> default seguro | "GPU desconocida" + 8 GB + 4 núcleos -> baja | Cubierto por suite 1 (L194) |
| D5 | `detect_hardware()` headless no crashea | devuelve Dictionary con ram_gb/cpu/nucleos/recomendado | Pendiente de suite (requiere OS real; medible en CI Linux) |
| D6 | Modelo de GPU lo resuelve M115 | el núcleo deja `gpu: ""` como marcador | Verificado por lectura (L519) |

## 4. Pruebas de legibilidad (ítems 162-164) — NO headless

- Método: captura a resolución nativa (1280x720 / 1920x1080 / 3840x2160) con el glosario de
  referencia (`data/` de textos) renderizado en el HUD y el menú de ajustes; comparar contra
  la plantilla de tipografía (integración M88 para escala de fuente 0.5x-2x).
- Criterio: ningún texto recortado ni solapado; tamaño mínimo legible a 1 m de distancia
  nominal de TV (guía del proyecto).
- Evidencia: capturas `cap_90_<fecha>_legibilidad-<res>.png` en `tools/`.

## 5. Pruebas de soporte de tildes / ñ / símbolos (ítems 165-167) — NO headless

- Barrido automático del glosario: todo string con `á-ú`, `ñ`, `¿?¡!`, `€/$/%` renderiza sin
  placeholder (caja vacía) ni mojibake en la fuente del proyecto.
- Captura de una pantalla por clase de carácter; revisión del fundador.

## 6. Pruebas de localización (ítem 168) — NO headless

- 6 idiomas (español, portugués, francés, alemán, italiano, ruso): cambiar el locale del
  proyecto, verificar que el menú de ajustes y el HUD traducen y que ningún texto se sale de
  su contenedor (el ruso es el caso de ancho máximo).

## 7. Pruebas de ajustes de accesibilidad (ítem 169)

- Headless: `mapeo_accesibilidad()` con cada toggle (alto_contraste, reducir_motion,
  reducir_bloom, fuente_escala) -> estado efectivo correcto (A6).
- Visual: captura con alto contraste y fuente 2x; verificar contraste mínimo AA del proyecto.

## 8. Pruebas de rendimiento (ítem 170)

- Tiempo de carga hasta el menú principal por preset (bajo/medio): medir con `Time.get_ticks_msec()`
  alrededor del bootstrap; umbral de aceptación a definir con el fundador (no headless puro:
  el primer frame con texturas depende del driver).
- Spawn de vegetación/partículas por calidad ya medido en su módulo (M50: 65 instancias vs
  presupuesto 8.000); acá sólo se verifica que cambiar la calidad en caliente no reintroduce
  el trabajo ya hecho (regeneración idempotente).

## 9. Criterio de salida del módulo

- Suites 1 y 2 en verde (142 checks medidos hoy) + A1-A8 y D1-D6 verdes + capturas 4-7
  revisadas por el fundador. Los ítems 4-7 son de ejecución manual/visual: quedan como
  pendientes del fundador, no bloquean el cierre documental del diseño.
