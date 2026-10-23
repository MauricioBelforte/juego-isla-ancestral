# 316 — M139 sección 10 CERRADA (Save v3 + menú): 98 → 109/142

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14 07:20
**Responde a:** step-5-kilocode — 315-2026-10-14_07-00-00-step-5-kilocode-a-step-5-kilocode-m139-seccion9-cerrada-98-142.md

Sección 10 completa (11 ítems). Commit `71cf67d`.

## Conteo

| | Sección 9 | Ahora |
|---|---|---|
| `[x]` | 98 | **109** |
| `[ ]` | 31 | 31 |

**Voy por el 77% del módulo** (109/142). Quedan 3 secciones.

## 9 ítems con respaldo real en disco

El motor de save ya está implementado y testeado:
- **Schema versionado** — `save_schema.gd` con `schema_version` por save.
- **Escritura transaccional** — `save_writer.gd` con temp/rename, verificado por el fix BUG-112.
- **Integridad** — `validate_save.gd` + `test_checksum_hmac.gd` (checksum HMAC).
- **Recuperación** — `save_backup.gd` con `test_backup_rotations.gd` y `test_rotate_m59.gd`.
- **Pantalla de carga** — `pantalla_carga.gd` con **barra de progreso real del StreamManager** +
  consejos rotando (`tips.txt` vía `ConsejosCarga`) + fundido.
- **Navegación de menú** — `menu_navigator.gd` con test M64.
- **Tutorial** — `tutorial_manager.gd` (autoload "Tutorial", M92) con capítulos, pasos y triggers.

## Definición nueva (§2.7.1)

- Migración de schema en cadena (y rechazo si la versión es mayor). Versión de fase: **3**.
- Secuencia de recuperación: save actual → backup → partida nueva (nunca se pierde el acceso).
- Umbral de carga < 2 s medido contra el StreamManager con la barra real.
- Menú principal de 4 opciones (Continuar / Nuevo juego / Ajustes / Créditos).
- Flujo "nuevo juego" con confirmación explícita (tiempo de juego + fecha del save).
- Regla de los 3 primeros pasos del tutorial 100% visuales (sin texto).

**Nota honesta:** el menú principal **no existe aún en disco** — quedó escrito que es la pieza de
UI que falta construir para la fase, en lugar de fliparla como hecha.

## próXIMO

Sección 11 (Primer sistema de audio global, M41-M44). Conteo vigente: **109/142**.

---

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
