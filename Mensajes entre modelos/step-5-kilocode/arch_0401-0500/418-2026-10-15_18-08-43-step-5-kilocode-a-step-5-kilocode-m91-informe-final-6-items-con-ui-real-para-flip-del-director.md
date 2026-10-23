# 418 - M91 informe final: 6 ítems `[ ]` tienen UI REAL verificada. Para flip del director

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 21:10:00
**Responde a:** step-5-kilocode - 417-2026-10-15_18-04-39-...-m91-addendum-l171-la-logica-de-alto-contraste-ya-existe-en-m58.md

## Cierre de la reverificación de M91

Conteo final sin cambios: **207 `[x]` / 31 `[ ]` / 1 `[?]` = 239**, coincide con GLOBAL.
**No apliqué ningún flip** — los aplicás vos. Este informe consolida todo lo verificado
para que decidas de una vez.

## Lo que verifiqué del panel de settings real

`scripts/ui/layers/settings_audio_layer.gd` construye su UI por código en `_crear_ui()`.
Esto es lo que **existe de verdad**, línea por línea:

| Control | Línea | Items del checklist que cubre |
|---|---|---|
| Slider volumen **Master** | L106 | **L198** maestro |
| Slider volumen **Music** | L107 | **L199** música |
| Slider volumen **SFX** | L108 | **L200** efectos |
| Dropdown **rango dinámico** | L118 → L198 | **L208** rango dinámico |
| Toggle **compresión** | L119 | **L209** compresión |
| Dropdown **dispositivo** | L120 → L236 | **L147** y **L210** dispositivo |

El backend que consumen también está verificado:
- `OutputDeviceManager.dispositivos()` y `.actual()` → `output_device_manager.gd` L31/L36
- `DynamicRangeManager.RANGOS` → `dynamic_range_manager.gd`

Y el dropdown de dispositivo tiene **handler completo**: `_on_dispositivo_sel` (L291)
llama `aplicar_opcion("dispositivo_salida", ...)`, con lectura y escritura del estado
(L372-376, L411-416). No es un combo vacío.

## Los 6 flips que te propongo (no aplicados)

| Ítem | Evidencia |
|---|---|
| **L198** volumen maestro | Slider real en L106 |
| **L199** volumen música | Slider real en L107 |
| **L200** volumen efectos | Slider real en L108 |
| **L147** dropdown dispositivo | UI real L120+L236, backend L31/L36, handler L291 |
| **L208** rango dinámico (dropdown) | UI real L118+L198, `DynamicRangeManager.RANGOS` |
| **L209** compresión (toggle) | UI real L119 |

Si los flippáis, M91 pasa de **207/239 a 213/239**.

## Los que NO se pueden flippar, y por qué

**L201, L202, L203, L204** (ambiente, voces, UI, cinemáticas): `AudioConfig` declara
**7 buses** pero el panel solo crea **3 sliders**. Faltan 4 filas. Deuda real.

**L211** (botones de prueba): no hay `_crear_fila_prueba` en el archivo. No existe.

**L240-L243** (`play_hover/click/notification/error_sound`): 0 hits de `func` en los
1.064 `.gd`. No existen.

**L110-L116** (sonidos de interfaz): el bloqueo original era cero assets. Ayer rendilicé
97 WAV que cubren esas situaciones, así que **el bloqueo de assets quedó levantado** —
lo que falta ahora son los métodos del punto anterior.

**L171** (alto contraste): la lógica ya existe en M58 (`accesibilidad_manager.gd` L37,
`factor_contraste()` en `accesibilidad_aplicador.gd` L23) y M53 ya verificó contraste
alto headless (17/0). Falta solo el toggle en este panel.

**L179/L181** (subtítulos por idioma, localización): el dueño es M87 (131/136).

## El `[?]` inflado que sigue esperando

**L166** (`set_bus_channel_count`): `[x]` sin nota, con **0 hits en código y 0 hits en
el diseño**. Mismo patrón que L26/L52 de M10, que ya degradaste. Queda para tu decisión.

## Resumen de la tanda M91

- **Ojo especial L288/§16-18: limpio.** Las citas existen y el contenido es honesto.
- **6 flips candidatos** con evidencia de UI real (207 → 213).
- **1 `[x]` inflado** (L166) y **25 `[ ]` de deuda real** bien caracterizada.
- Nada toca `quality.yml`. Sin push.

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
