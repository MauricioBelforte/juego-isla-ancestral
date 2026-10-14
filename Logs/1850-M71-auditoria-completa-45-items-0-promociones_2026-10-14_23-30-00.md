# Log 1850: M71-Progresión — auditoría completa de 45 `[?]` (0 promociones)

**Fecha:** 2026-10-14
**Hora:** 23:30
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Auditoría de los 45 `[?]` de M71-Progresión (encargo del director mimo, msgs 365/367; módulo
siguió a M31 en la cola). Método Patrón D: verificación contra disco. Commit `8230499`.

## Resultado: 0 promociones, 45 anotados

Evidencia base verificada en disco:
- `scripts/progresion/progression_manager.gd` (autoload, 36 KB): hitos, desbloqueos, títulos,
  evaluación pura de condiciones, dirty-flagging O(1) por estadística (§7), detección de condiciones
  imposibles estáticas, validación de catálogo.
- `data/progresion/hitos.json` (8875 B, 25 hitos, 5 dominios: generales 10, economía 5, amistad 6,
  historia 3, colecciones 1).
- `scripts/progresion/player_profile.gd` (3831 B) y `test_progresion.gd` (20 KB).

## Por qué 0 promociones

| Concepto del ítem | Estado real |
|---|---|
| Registro de logros con progreso parcial | No existe: solo hay hitos |
| `MilestoneDefinition` / `AchievementDefinition` | No existen como clases; los hitos son diccionarios |
| `get_milestone/get_unlock/get_logro/get_titulo` | 0 hits; acceso interno por `_hitost` |
| `milestone_catalog.tres` | No existe; el catálogo real es `hitos.json` |
| Curvas temprana/media/tardía | No definidas en datos ni código |
| Reflejos M13/M18 | **SÍ implementados**: `nivel_herramienta_cambio` (L216), `house_nivel` por player_profile |
| Consumo de señales M22 (sello/capitulo) | No implementado en M71 |

## Coherencia

M71 está bien implementado en su núcleo (autoload con evaluación pura y sucia, cacheo, detección de
imposibles). Los 45 `[?]` son de **API de datos y capa de presentación**: getters, clases de
definición, catálogo .tres, curvas de frecuencia y reflejo narrativo de M22.

## Archivos Modificados

- `DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md` (45 `[?]` anotados; commit `8230499`)
