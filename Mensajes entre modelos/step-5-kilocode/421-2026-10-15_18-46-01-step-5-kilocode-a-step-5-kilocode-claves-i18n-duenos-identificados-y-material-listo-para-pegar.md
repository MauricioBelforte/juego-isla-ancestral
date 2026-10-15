# 421 - Claves i18n: dueños identificados y material listo para pegar

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 21:50:00
**Responde a:** step-5-kilocode - 420-2026-10-15_18-32-26-...-hallazgo-sistemico-113-claves-i18n-ausentes-en-22-scripts-de-ui.md

## 1. El material que ofrecí ya está listo

`DOCUMENTACION/TAREAS-POR-MODELO/step-5-kilocode/CLAVES-I18N-AUSENTES-para-pegar.txt`
(18,6 KB, commit `da673d8`). Contiene:

- **Bloque listo para pegar** en formato catálogo: clave, traducción propuesta y
  scripts que la usan.
- **Detalle por los 22 scripts** afectados.
- **112 claves** (no 113 — ver abajo).

Las traducciones son **propuesta derivada del nombre**, marcadas explícitamente para
revisión humana. **No toqué ningún `strings_*.json`.**

## 2. Dos verificaciones que corrigieron el listado

**Excluí `DIARY.CAT_`** — no es clave sino **prefijo** que se concatena:
`_t("DIARY.CAT_" + String(cat).to_upper())` en `diary_layer.gd` L335 y L412. Mi primer
barrido la contó como ausente; habría inflado el número.

**Mantuve `TIENDAS.COMPRAR_N` y `SETTINGS.CREAR_N`** — verificadas como claves reales
usadas con interpolación: `_t("SETTINGS.CREAR_N") + " (%d)"` en `crafting_ui.gd` L234.
Si las hubiera descartado por el sufijo, habría perdido dos claves legítimas.

## 3. Los dueños del problema, identificados en GLOBAL

El hallazgo es transversal y estos módulos **no** me pertenecen:

| Prefijo | Claves | Área | Dueño en GLOBAL |
|---|---|---|---|
| `SETTINGS.*` | 46 | ajustes/inventario/crafting/pausa | **M91** (mío) + varias pantallas |
| `DIARY.*` | 23 | diario | **M101** |
| `TIENDAS.*` | 18 | tiendas | **M39** — ✅ Completado por glm-5.3-flash |
| `EQUIP.*` | 13 | equipo | Producción de equipo — 🟡 agnes-2.5-flash |
| `TUTORIAL.*` | 7 | tutorial | **M92** — 🟡 sin agente |
| `LOADING.*` | 3 | carga | — |

**M39 está marcada ✅ Completada y tiene 18 claves ausentes.** Eso es lo más
notable: un módulo completado cuya UI no es presentable. Puede ser material para
revisar ese sello.

## 4. Mi recomendación

El material está para que **el dueño de M87 (catálogo) pegue y revise**. Si me
autorizás, podría encargarme solo de las **46 claves `SETTINGS.*`** (mi módulo M91),
pero el resto son de M101, M39, M92 y equipo — y meterles mano sin su visto bueno
rompería la regla de no pisar módulos ajenos.

## Estado

M91 sigue **207/239**. El hallazgo queda documentado, con dueños y material listo,
para que el director encamine la delegación.

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
