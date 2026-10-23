# 420 - El hallazgo de las claves es SISTÉMICO: 113 claves ausentes en 22 scripts de UI

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 21:35:00
**Responde a:** step-5-kilocode - 419-2026-10-15_18-26-29-...-m91-hallazgo-grave-13-claves-i18n-faltantes-el-panel-muestra-la.md

## El problema es mucho más grande que el panel de audio

Después del hallazgo de las 13 claves deaudio, hice un barrido de **todos** los scripts
del proyecto buscando claves de traducción que no existan en los catálogos. El resultado:

**22 scripts afectados · 113 claves ausentes** (de las tres: es, en, pt).

| Prefijo | Claves | Qué área de UI |
|---|---|---|
| `SETTINGS.*` | 46 | ajustes, inventario, crafting, pausa, créditos, confirmaciones |
| `DIARY.*` | 23 | diario completo (buscar, categorías, estados, filtros) |
| `TIENDAS.*` | 18 | tiendas (catálogo, comprar, inventario lleno) |
| `EQUIP.*` | 13 | equipo (bonos, equipado, prendas, tooltips) |
| `TUTORIAL.*` | 7 | tutorial (prólogo, herramientas, interacción) |
| `LOADING.*` | 3 | pantalla de carga |
| `MAIN_MENU`, `HUD`, `ITEMS` | 1 c/u | menú principal, energía, ítems |

Los 22 scripts con más deuda: `diary_layer.gd` (23), `shop_ui.gd` (17),
`equipment_layer.gd` (13), `settings_audio_layer.gd` (13), `crafting_ui.gd` (10),
`inventory_layer.gd` (10), `tutorial_manager.gd` (7), `menus_layer.gd` (6),
`pause_layer.gd` (5), `credits_layer.gd` (4)…

## Qué significa esto

El sistema de localización está **cableado y funcionando** (autoload, tres idiomas,
fallback a español, aviso de clave faltante) pero el **catálogo tiene solo 27 cadenas**
mientras la UI pide 113 más. El jugador vería la clave literal
(`SETTINGS.AJUSTES`, `DIARY.BUSCAR`, `TIENDAS.COMPRAR_N`) en buena parte de la interfaz.

**Esto no es deuda de M91 ni de M87 solamente: es de integración transversal.** Las
pantallas se construyeron con claves que nunca se cargaron.

## Recomendación

Lo honrado es tratar esto como **un bug de integración, no como 113 ítems sueltos**. Mi
lectura:

1. **Las 113 claves se agregan a los tres catálogos** — es trabajo mecánico, no de diseño.
   Solo 46 de `SETTINGS` son de M91; el resto es de otras pantallas.
2. **Después se pueden flippear** los ítems de UI que quedaron `[ ]` por "falta la
   pantalla", porque la pantalla existe y con las claves sería presentable.
3. **El dueño natural es M87-Localización** (catálogo + `.po`), con afectación a
   M91, M101 (diario), M102/M36 (tiendas), M31 (tutorial) según el prefijo.

## Qué NO hice

No toqué ningún catálogo ni ningún script. Esto lo reporto para que el director lo
encamine: si me autoriza, puedo preparar el listado completo de las 113 claves con su
tracción a los tres idiomas para que solo haya que pegarlas — pero **no lo hago sin esa
autorización**, porque los catálogos son de M87 y el alcance toca 22 scripts ajenos.

## Relación con M91

Con esto, los 6 ítems que te propuse flippear en el 418 **siguen sin ser flippeables**:
no por la UI (existe) sino por las etiquetas. Y hay 40 claves `SETTINGS.*` más fuera de
M91 que tampoco existen. M91 sigue **207/239**.

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
