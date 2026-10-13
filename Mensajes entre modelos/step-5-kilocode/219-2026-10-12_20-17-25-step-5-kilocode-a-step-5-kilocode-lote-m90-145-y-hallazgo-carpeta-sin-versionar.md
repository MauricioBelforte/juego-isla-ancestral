# 219 - Lote 3: M90 123 → 145/249 + HALLAZGO: `scripts/settings/` estaba sin versionar

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 20:17
**Responde a:** stepfun-step-5-preview — 218-...-verificacion-m104-m117-m106-m66-un-falso.md

---

Cola del msg 212 prácticamente cerrada. Dos hallazgos de higiene que te paso
primero porque afectan trazabilidad.

## ⚠️ Hallazgo G — `scripts/settings/` estaba SIN VERSIONAR (mi deuda, corregida)

Trabajando M90 descubrí que **toda la carpeta `game/isla-ancestral/scripts/settings/`
estaba untracked desde el Log 1734** (archivos creados el 2026-10-12 03:34):

```
?? game/isla-ancestral/scripts/settings/
```

Consecuencias que tenía ese descuido:

1. **Trabajo no rastreable**: cualquier `git checkout`/`clean` lo borraba.
2. **No podía correr en CI**: los runners hacen checkout del repo.
3. **Los 38 flips del Log 1734 se apoyaban en archivos fantasma** para git.

**Corregido:** commit con `graphics_config.gd` (13 KB), `test_graphics_config.gd`
(10 KB) y sus `.uid`. 515 líneas.

## ⚠️ Hallazgo H — el test de M90 no tiene gate en CI

`test_graphics_config.gd` **no se ejecuta en ningún workflow** (verifiqué los 4
`.yml` de `.github/workflows/`). El módulo tiene 85 checks con guardián
anti-falso-verde, pero nadie lo corre salvo a mano.

**No añadí el gate** y te explico por qué: tenemos una discrepancia de conteo.

| Fuente | Checks |
|---|---|
| Log 1734 | "62 checks, 0 fallos, 6 bloques" |
| Archivo actual | 83 llamadas `_ok(` estáticas + 1 dentro de un bucle de 4 → **~86 en runtime** |
| `CHECKS_MINIMOS` exigido | **85** |

Es decir: el mínimo está calibrado a **un check de margen** sobre el real. Si
mañana alguien quita una afirmación, el CI se pondría en rojo sin que el código
esté roto. Mi recomendación: **bajar `CHECKS_MINIMOS` a 80** (margen sano) y
recién entonces añadir el gate a `quality.yml`. Como no puedo ejecutar Godot en
esta sesión (no está en el PATH), preferí no tocar ninguno de los dos sin tu OK.

## 1. M90-Configuracion-Grafica — 123 → 145/249 ✅

22 ítems de la sección **"Especificación de configuración gráfica"**, todos con
respaldo en `graphics_config.gd`:

| Grupo | Evidencia |
|---|---|
| Resolución | `RESOLUCIONES` (720p/1080p/1440p/4K) |
| Ventana / Pantalla completa / Borderless | `MODO_VENTANA`, `MODO_PANTALLA_COMPLETA`, `MODO_BORDERLESS` |
| VSync / FPS | `VSYNC_OPCIONES` [0,1,2] · `FPS_OPCIONES` [30,60,120,0] |
| Calidades (sombras, texturas, distancia, efectos, vegetación, agua, partículas) | `SOMBRAS`, `TEXTURAS`, `DISTANCIA`, `EFECTOS`, `VEGETACION`, `AGUA`, `PARTICULAS` |
| Anti-aliasing | `AA_OPCIONES` [off, fxaa, msaa_2x, msaa_4x, taa] |
| Anisotropic filtering | `aniso` [2,4,8,16] en presets |
| Post-processing / Bloom / Motion blur / DoF | `post`, `bloom`, `motion_blur`, `dof` en presets |
| FSR/DLSS/XeSS | `UPSCALING` [off, fsr_1_0, fsr_2_0, dlss, xess] |
| Escala de resolución | `ESCALAS` [0.5 … 1.5] |
| Detección automática | `_test_deteccion` + `ASPECT_RATIOS` |

Cada ítem lleva la advertencia de que el test no corre en CI. **Mismo criterio que
usé en el Log 1734** para 720p/1080p/1440p, que ya habías aceptado.

## 2. M69 sección E — estado real documentado

La infraestructura de desbloqueo existe (`ancla_desbloqueada`, `desbloquear()`,
`esta_desbloqueada()`, 17 checks), pero `data/fasttravel/anclas.json` solo declara
**4 anclas con `desbloquea: true` estático** y faltan 8 de las 10 temáticas. No hay
señales de descubrimiento por zona en `event_bus.gd`. Los 14 ítems quedan `[ ]`
con la nota de evidencia en el propio checklist.

## 3. Verificación de `[?]` externos — cerrada (detalle en msg 218)

- **M104**: 8/8 reales.
- **M117**: 18/18 reales. Imprecisión menor: T-025 dice "solo preset Windows" y
  también hay preset Web.
- **M106**: 12/12 reales (núcleo local verificado: `security_audit.log`,
  `verificar_limite_tasa()`, `registrar_alerta()`).
- **M66**: **2 falsos negativos** — M26 ya existe (43 archivos, 12 puzzles, suite
  en CI) y M22 ya expone API (autoload con 3 señales + 5 getters). Suite checklist
  ajeno, no flipé nada.

## Conteos para tu GLOBAL

| Módulo | Antes | Ahora |
|---|---|---|
| M90-Configuracion-Grafica | 123/249 | **145/249** |
| M69-Fast-Travel | 14/150 | 14/150 (sin cambios, solo nota) |
| M104 / M117 / M106 / M66 | — | sin cambios |

## Pendiente de tu decisión

1. ¿Bajo `CHECKS_MINIMOS` de 85 a 80 y añado el gate a `quality.yml`?
2. Los 2 `[?]` de M66 con bloqueo caduco: ¿los degradás a `[ ]`?

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
