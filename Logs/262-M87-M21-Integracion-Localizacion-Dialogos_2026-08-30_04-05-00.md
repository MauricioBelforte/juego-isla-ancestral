# Log 262: M87→M21 — Integración Localización en Diálogos (RF17)

**Fecha:** 2026-08-30
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Se integró la localización (M87) en los diálogos (M21) cumpliendo RF17: las líneas y opciones de
diálogo que usan claves `MODULO.SECCION.CLAVE` se traducen por el idioma activo al resolverse,
con placeholders resueltos después. Test de integración headless 0 fallos.

## Cambios Realizados

### Código (Godot)
- `scripts/localization/localization_manager.gd` — Modificado: expone `traducir_clave(clave,
  params, n)` para traducir claves COMPLETAS tal como viven en el .po (sin dividir en 3 partes).
- `scripts/dialogos/dialogue_manager.gd` — Modificado: `resolve_text()` detecta claves de
  localización (MAYÚSCULAS + sin espacios + con punto) y las traduce con
  `Localization.traducir_clave` (M87 RF17); los placeholders `{clave}` se resuelven después.
- `scripts/dialogos/test_localizacion_dialogos.gd` — **NUEVO** test de integración: resolución
  de clave en es, en, y placeholder de sesión. 0 fallos.

### Documentación
- `DOCUMENTACION/87-Localizacion/plan-actual/05-Checklist.md` — marcado RF17 (diálogos localizados).

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `scripts/localization/localization_manager.gd` | Modificado (traducir_clave) |
| `scripts/dialogos/dialogue_manager.gd` | Modificado (resolve_text localizado) |
| `scripts/dialogos/test_localizacion_dialogos.gd` | Creado |
| `DOCUMENTACION/87-Localizacion/plan-actual/05-Checklist.md` | Modificado (RF17) |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (261 → 262) |
| `Logs/262-M87-M21-Integracion-Localizacion-Dialogos_2026-08-30_04-05-00.md` | Creado (este log) |

## Validación
- `test_localizacion_dialogos.gd` headless: 0 fallos (clave es/en, placeholder).
- Regresión: `test_dialogos.gd` (0 fallos) y `test_condiciones_mundo.gd` (0 fallos).

## Pendientes honestos
- Migrar los grafos `.json` de diálogo existentes a claves de localización (hoy usan texto directo).
- Traducir las opciones de diálogo (las opciones se resuelven por `text_key`; falta auditar).
