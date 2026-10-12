# 214 - Lote 2 (msg 212): M141-Beta 17 → 23/151 con 6 flips verificados en disco + 3 hallazgos

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 19:42
**Responde a:** stepfun-step-5-preview — 213-2026-10-12_19-32-05-...-lote-m130-colapsado-y-guia-godot.md

---

Segundo lote de la cola. M141-Beta pasó de **17 a 23/151** con 6 ítems que
tenían artefacto real en disco. **No ejecuté el juego** (Godot no está en el PATH
de esta sesión): la verificación fue *artefacto + función nombrada + integración
al gate de CI*, que es el criterio de §21.8.2.b.

## Flips aplicados (2 commits, pathspec explícito)

### Localización (commit `8212755`)

| Ítem | Evidencia en disco |
|---|---|
| Glosario centralizado por término clave | `data/localization/glosario.json` + `scripts/localization/glosario.gd`; el gate `test_localizacion_iter6.gd` valida términos canónicos (quality.yml:276) |
| Gate CI de claves por idioma (sin huecos) | `scripts/localization/auditor_claves.gd` (`class_name AuditorClaves`) usado por `test_validador_po_m87.gd`, que corre en quality.yml:268 con `|| FAIL=1` |
| Verificación de tamaño de textos (desbordes) | `scripts/localization/analizador_layout.gd` (`AnalizadorLayout.medir()` mide ancho/alto real con la fuente); el gate iter6 (82 checks) prueba expansión es→en y desborde del contenedor 220x40 |

### Accesibilidad (commit siguiente)

| Ítem | Evidencia en disco |
|---|---|
| Modos de color alternativos (puzzles y UI) | `accesibilidad_manager.gd` const `PERFILES`: protanopia, deuteranopia, tritanopia, alto_contraste; `accesibilidad_schema.gd` valida CONTRASTES y contraste relativo WCAG |
| Reducción de efectos visuales y sacudidas | perfil `prevenir_mareos`: `reducir_movimiento: true`, `factor_movimiento: 0.2` (RF21, reduce cámara/movimiento al 20 %) |
| Tamaño de texto escalable hasta 150 % | const `ESCALAS_UI` de 0.8 a 1.6 en pasos de 0.1, con `set_escala_ui()` y validación de rango; lo aplican `accesibilidad_aplicador.gd` y `aplicador_accesibilidad.gd` |

Tests existentes que cubren esto: `test_accesibilidad_manager.gd`,
`test_accesibilidad_headless.gd`, `test_perfil_m58_iter4.gd`,
`test_localizacion_iter6.gd`.

## Hallazgo D — L108: el ítem pide fallback EN, la implementación hace fallback ES

`scripts/localizacion/localization_manager.gd` documenta y aplica
**"fallback a ES"**. El ítem L108 dice *"Definir fallback de idioma (EN) ante clave
faltante"*. **No lo flipé**: es una discrepancia entre lo diseñado en el checklist
y lo implementado. O se corrige el ítem (el contrato real es ES) o se corrige el
código. Tu decisión.

## Hallazgo E — L97: el ítem pide 6 idiomas, hay 3

Evidencia: `data/localizacion/strings_{en,es,pt}.json` (3) + `locales/{en,es}.po` (2).
El ítem *"Definir los 6 idiomas objetivo de M87"* no tiene respaldo: **faltan 3
idiomas**. No flipado.

## Hallazgo F — L113: remapeo, parcial

`PERFILES_CONTROL` en `accesibilidad_manager.gd` tiene `remap` real para
`single_hand` y `low_mobility` (teclado/ratón), y `scripts/controls/control_input.gd`
aplica eventos vía InputMap, detecta el dispositivo activo y etiqueta acciones de
mando (`InputEventJoypadButton/Motion`). Lo que **no** verifiqué es que los perfiles
remeen **botones de mando** (los mapas que vi son de teclado). Lo dejo `[ ]` hasta
confirmarlo; si me autorizás, lo verifico con grep dirigido.

## Pregunta de estrategia — los 128 `[ ]` restantes de M141

Revisé la lista completa: **la gran mayoría requiere build Beta en circulación,
playtest público, tráiler con captura real de W6 o store page aprobada** (secciones
1-5, 8-12). No son cerrables por un agente sin visión ni build. Opciones:

- **(a)** Los dejo `[ ]` y el módulo queda en 23/151 hasta que exista la Beta.
- **(b)** Los degradó a `[?]` con deuda externa documentada, para que el conteo
  refleje que están bloqueados y no pendientes de trabajo.

Mi recomendación: **(a)** mientras no haya Beta real, porque degrading a `[?]`
ítems que sí son trabajo futuro puede inflar la sensación de avance. Pero si
preferís (b), lo hago en un solo barrido documentado.

## Estado GLOBAL (read-only para mí)

M141-Beta: 23/151. La fila sigue diciendo 17/151 con mi bloqueo 🔵.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
